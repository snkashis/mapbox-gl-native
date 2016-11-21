#include <memory>

#include <mbgl/text/bidi.hpp>
#include <unicode/ubidi.h>
#include <unicode/ushape.h>

namespace mbgl {
    
// Takes UTF16 input in logical order and applies Arabic shaping to the input while maintaining logical order
//  Output won't be intelligible until the bidirectional algorithm is applied
std::u16string applyArabicShaping(const std::u16string& input) {
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

ProcessedBiDiText::ProcessedBiDiText( BiDi& p_bidi ) : bidi( p_bidi ) {}
    
void ProcessedBiDiText::mergeParagraphLineBreaks(std::set<int32_t>& lineBreakPoints)
{
    for ( int32_t i = 0; i < ubidi_countParagraphs(bidi.bidiText); i++ )
    {
        UErrorCode errorCode = U_ZERO_ERROR;
        int32_t paragraphEndIndex;
        ubidi_getParagraphByIndex(bidi.bidiText, i, NULL, &paragraphEndIndex, NULL, &errorCode);
        
        if (U_FAILURE(errorCode))
            throw std::runtime_error(std::string("ProcessedBiDiText::mergeParagraphLineBreaks: ") + u_errorName(errorCode));
        
        lineBreakPoints.insert(paragraphEndIndex);
    }
}
    
std::vector<std::u16string> ProcessedBiDiText::applyLineBreaking(std::set<int32_t> lineBreakPoints)
{
    // BiDi::getLine will error if called across a paragraph boundary, so we need to ensure that all paragraph
    //  boundaries are included in the set of line break points. The calling code might not include the line break because it
    //  didn't need to wrap at that point, or because the text was separated with a more exotic code point such as (U+001C)
    mergeParagraphLineBreaks(lineBreakPoints);
    
    std::vector<std::u16string> transformedLines;
    int32_t start = 0;
    for ( int32_t lineBreakPoint : lineBreakPoints )
    {
        transformedLines.push_back(bidi.getLine(start,lineBreakPoint));
        start = lineBreakPoint;
    }
    
    return transformedLines;
}
    
BiDi::BiDi() {
    bidiText = ubidi_open();
    bidiLine = ubidi_open();
}

BiDi::~BiDi() {
    if (bidiText)
        ubidi_close(bidiText);
    
    if (bidiLine)
        ubidi_close(bidiLine);
}

ProcessedBiDiText BiDi::processText(const std::u16string& input)
{
    UErrorCode errorCode = U_ZERO_ERROR;
    
    ubidi_setPara(bidiText, input.c_str(), static_cast<int32_t>(input.size()), UBIDI_DEFAULT_LTR, NULL, &errorCode);

    if (U_FAILURE(errorCode))
        throw std::runtime_error(std::string("BiDi::processText: ") + u_errorName(errorCode));
    
    return ProcessedBiDiText(*this);
}
    
std::u16string BiDi::getLine(int32_t start, int32_t end)
{
    UErrorCode errorCode = U_ZERO_ERROR;
    ubidi_setLine(bidiText, start, end, bidiLine, &errorCode);
    
    if (U_FAILURE(errorCode))
        throw std::runtime_error("msg");
    
    // Only valid as long as UBIDI_REMOVE_BIDI_CONTROLS and UBIDI_INSERT_LRM_FOR_NUMERIC are not set
    int32_t outputLength = ubidi_getProcessedLength(bidiLine);
    std::unique_ptr<UChar[]> outputText = std::make_unique<UChar[]>(outputLength);
    ubidi_writeReordered(bidiLine, outputText.get(),outputLength, UBIDI_DO_MIRRORING, &errorCode);
    
    if (U_FAILURE(errorCode))
        throw std::runtime_error(std::string("BiDi::getLine: ") + u_errorName(errorCode));
    
    return std::u16string(outputText.get(), outputLength);
}
    
} // end namespace mbgl
