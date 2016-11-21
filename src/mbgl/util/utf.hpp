#pragma once

#include <memory>

#include <locale>
#include <codecvt>

namespace mbgl {
namespace util {

class utf8_to_utf16 {
public:
    static std::u16string convert(std::string const& utf8) {
        std::wstring_convert<std::codecvt_utf8_utf16<char16_t>, char16_t> converter;
        return converter.from_bytes(utf8);
    }
};
    
class utf16_to_utf8 {
public:
    static std::string convert(std::u16string const& utf16) {
        std::wstring_convert<std::codecvt_utf8_utf16<char16_t>, char16_t> converter;
        return converter.to_bytes(utf16);
    }
};

} // namespace util
} // namespace mbgl
