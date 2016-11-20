#pragma once

#include <string>
#include <vector>

#include <mbgl/util/noncopyable.hpp>

struct UBiDiTransform;
struct UBiDi;

namespace mbgl {
    
enum class WritingDirection : bool { LeftToRight, RightToLeft };    
    
class BiDi : private util::noncopyable {
public:
    BiDi();
    ~BiDi();

    std::u16string bidiTransform(const std::u16string&);
    WritingDirection baseWritingDirection(const std::u16string&);
    
    std::u16string applyArabicShaping(const std::u16string&);
    
    // Calling applyBidiToParagraph resets internal state depended on by applyBidiLineBreaking
    std::u16string applyBidiToParagraph(const std::u16string&);
    std::vector<std::u16string> applyBidiLineBreaking(const std::vector<int32_t>&);

private:
    std::u16string getLine(int32_t start, int32_t end);
    
    UBiDiTransform* transform;
    UBiDi* bidiParagraph;
    UBiDi* bidiLine;
};

} // end namespace mbgl
