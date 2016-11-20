#include <memory>

#include <mbgl/text/bidi.hpp>
#include <unicode/ubidi.h>
#include <unicode/ubiditransform.h>
#include <unicode/ushape.h>

namespace mbgl {

BiDi::BiDi() {
    UErrorCode errorCode = U_ZERO_ERROR;
    transform = ubiditransform_open(&errorCode); // Only error is failure to allocate memory, in
                                                 // that case ubidi_transform would fall back to
                                                 // creating transform object on the fly
    bidiParagraph = ubidi_open();
    bidiLine = ubidi_open();
}

BiDi::~BiDi() {
    if (transform)
        ubiditransform_close(transform);
    
    if (bidiParagraph)
        ubidi_close(bidiParagraph);
    
    if (bidiLine)
        ubidi_close(bidiLine);
    
}

std::u16string BiDi::bidiTransform(const std::u16string& input) {
    UErrorCode errorCode = U_ZERO_ERROR;

    std::unique_ptr<UChar[]> outputText =
        std::make_unique<UChar[]>(input.size() * 2); // Maximum output of ubidi_transform is twice
                                                     // the size of input according to
                                                     // ubidi_transform.h
    uint32_t outputLength = ubiditransform_transform(
        transform, input.c_str(), static_cast<int32_t>(input.size()), outputText.get(),
        static_cast<int32_t>(input.size()) * 2,
        UBIDI_DEFAULT_LTR,     // Assume input is LTR unless strong RTL characters are found
        UBIDI_LOGICAL,         // Input is in logical order
        UBIDI_LTR,             // Output is in "visual LTR" order
        UBIDI_VISUAL,          //  ''
        UBIDI_MIRRORING_ON,    // Use mirroring lookups for things like parentheses that need mirroring
                               // in RTL text
        U_SHAPE_LETTERS_SHAPE, // Add options here for handling numbers in bidirectional text
        &errorCode);

    // If the algorithm fails for any reason, fall back to non-transformed text
    if (U_FAILURE(errorCode))
        return input;

    return std::u16string(outputText.get(), outputLength);
}

WritingDirection BiDi::baseWritingDirection(const std::u16string& input) {
    // This just looks for the first character with a strong direction property, it does not perform
    // the BiDi algorithm
    return ubidi_getBaseDirection(input.c_str(), static_cast<int32_t>(input.size())) == UBIDI_RTL
    ? WritingDirection::RightToLeft
    : WritingDirection::LeftToRight;
}
    
// Takes UTF16 input in logical order and applies Arabic shaping to the input while maintaining logical order
//  Output won't be intelligible until the bidirectional algorithm is applied
std::u16string BiDi::applyArabicShaping(const std::u16string& input) {
    UErrorCode errorCode = U_ZERO_ERROR;
    
    int32_t outputLength = u_shapeArabic(input.c_str(), static_cast<int32_t>(input.size()), NULL, 0,
                                         (U_SHAPE_LETTERS_SHAPE&U_SHAPE_LETTERS_MASK)|(U_SHAPE_TEXT_DIRECTION_LOGICAL&U_SHAPE_TEXT_DIRECTION_MASK),
                                         &errorCode);
    
    // Pre-flighting will always set U_BUFFER_OVERFLOW_ERROR
    errorCode = U_ZERO_ERROR;
    
    std::unique_ptr<UChar[]> outputText = std::make_unique<UChar[]>(outputLength);
    u_shapeArabic(input.c_str(), static_cast<int32_t>(input.size()), outputText.get(), outputLength,
                  (U_SHAPE_LETTERS_SHAPE&U_SHAPE_LETTERS_MASK)|(U_SHAPE_TEXT_DIRECTION_LOGICAL&U_SHAPE_TEXT_DIRECTION_MASK),
                  &errorCode);
    
    // If the algorithm fails for any reason, fall back to non-transformed text
    if (U_FAILURE(errorCode))
        return input;
    
    return std::u16string(outputText.get(), outputLength);
}
    
std::u16string BiDi::applyBidiToParagraph(const std::u16string& input)
{
    UErrorCode errorCode = U_ZERO_ERROR;
    
    ubidi_setPara(bidiParagraph, input.c_str(), static_cast<int32_t>(input.size()), UBIDI_DEFAULT_LTR, NULL, &errorCode);

    // TODO: Returning input string here is weird, since subsequent calls to setLine, etc. won't work. Maybe hold onto the errorCode so everything errors until setParagraph is called again?
    if (U_FAILURE(errorCode))
        return input;
    
    // Only valid as long as UBIDI_REMOVE_BIDI_CONTROLS and UBIDI_INSERT_LRM_FOR_NUMERIC are not set
    int32_t outputLength = ubidi_getProcessedLength(bidiParagraph);
    std::unique_ptr<UChar[]> outputText = std::make_unique<UChar[]>(outputLength);
    ubidi_writeReordered(bidiParagraph, outputText.get(),outputLength, UBIDI_DO_MIRRORING, &errorCode);
    if (U_FAILURE(errorCode))
        return input;
    
    return std::u16string(outputText.get(), outputLength);
}
    
std::u16string BiDi::getLine(int32_t start, int32_t end)
{
    UErrorCode errorCode = U_ZERO_ERROR;
    ubidi_setLine(bidiParagraph, start, end, bidiLine, &errorCode);
    
    // TODO: At this point we're committed to the line breaking working. As a fallback we could try to just return the equivalent substring of the original reordered paragraph, but maybe we should just throw an exception?
    if (U_FAILURE(errorCode))
        return u"";
    
    // Only valid as long as UBIDI_REMOVE_BIDI_CONTROLS and UBIDI_INSERT_LRM_FOR_NUMERIC are not set
    int32_t outputLength = ubidi_getProcessedLength(bidiLine);
    std::unique_ptr<UChar[]> outputText = std::make_unique<UChar[]>(outputLength);
    ubidi_writeReordered(bidiLine, outputText.get(),outputLength, UBIDI_DO_MIRRORING, &errorCode);
    if (U_FAILURE(errorCode))
        return u"";
    
    return std::u16string(outputText.get(), outputLength);
}

std::vector<std::u16string> BiDi::applyBidiLineBreaking(const std::vector<int32_t>& lineBreakPoints)
{

    std::vector<std::u16string> transformedLines;
    int32_t start = 0;
    for ( int32_t lineBreakPoint : lineBreakPoints )
    {
        transformedLines.push_back(getLine(start,lineBreakPoint));
        start = lineBreakPoint;
    }
    transformedLines.push_back(getLine(start, ubidi_getLength(bidiParagraph)));
    
    return transformedLines;
}

} // end namespace mbgl
