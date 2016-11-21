#include <mbgl/text/glyph_set.hpp>
#include <mbgl/platform/log.hpp>
#include <mbgl/math/minmax.hpp>
#include <mbgl/util/i18n.hpp>
#include <mbgl/util/utf.hpp>

#include <boost/algorithm/string.hpp>

#include <cassert>
#include <algorithm>

namespace mbgl {

void GlyphSet::insert(uint32_t id, SDFGlyph&& glyph) {
    auto it = sdfs.find(id);
    if (it == sdfs.end()) {
        // Glyph doesn't exist yet.
        sdfs.emplace(id, std::move(glyph));
    } else if (it->second.metrics == glyph.metrics) {
        if (it->second.bitmap != glyph.bitmap) {
            // The actual bitmap was updated; this is unsupported.
            Log::Warning(Event::Glyph, "Modified glyph changed bitmap represenation");
        }
        // At least try to update it in case it's currently unsused.
        // If it is already used; we won't attempt to update the glyph atlas texture.
        it->second.bitmap = std::move(glyph.bitmap);
    } else {
        // The metrics were updated; this is unsupported.
        Log::Warning(Event::Glyph, "Modified glyph has different metrics");
        return;
    }
}

const std::map<uint32_t, SDFGlyph> &GlyphSet::getSDFs() const {
    return sdfs;
}

std::u16string trim(const std::u16string& input)
{
    // We have to round-trip to UTF8 to use boost::algorithm::trim because ctype<char16_t> isn't defined in our STL
    std::string u8string = util::utf16_to_utf8::convert(input);
    boost::algorithm::trim(u8string);
    return util::utf8_to_utf16::convert(u8string);
}

const Shaping GlyphSet::getShaping(const std::u16string &logicalInput, const float maxWidth,
                                    const float lineHeight, const float horizontalAlign,
                                    const float verticalAlign, const float justify,
                                    const float spacing, const Point<float> &translate, BiDi& bidi) const {
    
    // The string stored in shaping.text is used for finding duplicates, but may end up quite different from the glyphs that get shown
    Shaping shaping(translate.x * 24, translate.y * 24, logicalInput);
    
    ProcessedBiDiText processedText = bidi.processText(logicalInput);
    
    std::vector<std::u16string> reorderedLines =
        processedText.applyLineBreaking(
            determineLineBreaks(logicalInput,
                                spacing,
                                maxWidth,
                                util::i18n::allowsIdeographicBreaking(logicalInput)));


    shapeLines(shaping, reorderedLines, spacing, lineHeight, horizontalAlign, verticalAlign, justify, translate);

    return shaping;
}

void align(Shaping &shaping, const float justify, const float horizontalAlign,
           const float verticalAlign, const uint32_t maxLineLength, const float lineHeight,
           const uint32_t lineCount, const Point<float> &translate) {
    const float shiftX = (justify - horizontalAlign) * maxLineLength + ::round(translate.x * 24/* one em */);
    const float shiftY = (-verticalAlign * lineCount + 0.5) * lineHeight + ::round(translate.y * 24/* one em */);

    for (auto& glyph : shaping.positionedGlyphs) {
        glyph.x += shiftX;
        glyph.y += shiftY;
    }
}

// justify left = 0, right = 1, center = .5
void justifyLine(std::vector<PositionedGlyph> &positionedGlyphs, const std::map<uint32_t, SDFGlyph> &sdfs, uint32_t start,
                 uint32_t end, float justify) {
    if (!justify)
        return;

    PositionedGlyph &glyph = positionedGlyphs[end];
    auto it = sdfs.find(glyph.glyph);
    if (it != sdfs.end()) {
        const uint32_t lastAdvance = it->second.metrics.advance;
        const float lineIndent = float(glyph.x + lastAdvance) * justify;

        for (uint32_t j = start; j <= end; j++) {
            positionedGlyphs[j].x -= lineIndent;
        }
    }
}

// We determine line breaks based on shaped text in logical order. Working in visual order would be
//  more intuitive, but we can't do that because the visual order may be changed by line breaks!
std::set<int32_t> GlyphSet::determineLineBreaks(const std::u16string& logicalInput, const float spacing, float maxWidth, bool useBalancedIdeographicBreaking) const
{
    if ( !maxWidth )
        return {};
    
    std::set<int32_t> lineBreakPoints;
   
    if (useBalancedIdeographicBreaking) {
        float totalWidth = 0;
        
        for (char16_t chr : logicalInput) {
            totalWidth += sdfs.find(chr)->second.metrics.advance + spacing;
        }
        
        uint32_t estimatedLineCount = std::fmax(1, std::ceil(totalWidth / maxWidth));
        maxWidth = totalWidth / estimatedLineCount;
    }
    
    float currentX = 0;
    uint32_t lastSafeBreak = 0;
    float lastSafeBreakX = 0;

    for (uint32_t i = 0; i < logicalInput.size(); i++) {
        char16_t chr = logicalInput[i];
        const SDFGlyph& glyph = sdfs.find(chr)->second;
        currentX += glyph.metrics.advance + spacing;
        if ( currentX > maxWidth && lastSafeBreak > 0 )
        {
            lineBreakPoints.insert(lastSafeBreak);
            currentX -= lastSafeBreakX;
            lastSafeBreakX = 0;
        }
        // Ideographic characters, spaces, and word-breaking punctuation that often appear without surrounding spaces.
        if (useBalancedIdeographicBreaking
            || util::i18n::allowsWordBreaking(glyph.id)
            || util::i18n::allowsIdeographicBreaking(glyph.id)) {
            lastSafeBreak = i;
            lastSafeBreakX = currentX;
        }
    }

    return lineBreakPoints;
}

void GlyphSet::shapeLines(Shaping& shaping, const std::vector<std::u16string>& lines,
                             const float spacing, const float lineHeight, const float horizontalAlign, const float verticalAlign,
                             const float justify, const Point<float> &translate) const {

    // the y offset *should* be part of the font metadata
    const int32_t yOffset = -17;
    
    float x = 0;
    float y = yOffset;
    
    float maxLineLength = 0;
    
    for (std::u16string line : lines)
    {
        // Filter out any missing glyphs ahead of time, after this assume we have all glyphs
        line.erase(std::remove_if(line.begin(),
                                  line.end(),
                                  [ & ] (const char16_t& chr) -> bool { auto it = sdfs.find(chr); return it == sdfs.end(); }),
                   line.end());
        
        // Collapse whitespace so it doesn't throw off justification
        line = trim(line);
        
        if (line.empty())
            continue;
        
        uint32_t lineStartIndex = shaping.positionedGlyphs.size();
        for (char16_t chr : line)
        {
            const SDFGlyph& glyph = sdfs.find(chr)->second;
            shaping.positionedGlyphs.emplace_back(chr, x, y);
            x += glyph.metrics.advance + spacing;
        }
        
        maxLineLength = util::max(x,maxLineLength);
        
        justifyLine(shaping.positionedGlyphs, sdfs, lineStartIndex, shaping.positionedGlyphs.size() - 1, justify);
        
        x = 0; y += lineHeight;  // Move to next line
    }
    
    align(shaping, justify, horizontalAlign, verticalAlign, maxLineLength, lineHeight, lines.size(), translate);
    const uint32_t height = lines.size() * lineHeight;
    
    // Calculate the bounding box
    shaping.top += -verticalAlign * height;
    shaping.bottom = shaping.top + height;
    shaping.left += -horizontalAlign * maxLineLength;
    shaping.right = shaping.left + maxLineLength;
}

} // end namespace mbgl
