#pragma once

#include <mbgl/gl/object.hpp>
#include <mbgl/gl/vertex_buffer.hpp>
#include <mbgl/util/optional.hpp>

#include <cstddef>
#include <vector>

namespace mbgl {
namespace gl {

class Segment {
public:
    Segment(std::size_t vertexOffset_,
            std::size_t indexOffset_,
            std::size_t vertexLength_ = 0,
            std::size_t indexLength_ = 0)
        : vertexOffset(vertexOffset_),
          indexOffset(indexOffset_),
          vertexLength(vertexLength_),
          indexLength(indexLength_) {}

    const std::size_t vertexOffset;
    const std::size_t indexOffset;

    std::size_t vertexLength;
    std::size_t indexLength;

    bool needAttributeBinding(Context&, BufferID indexBuffer) const;

private:
    friend class Context;
    mutable optional<UniqueVertexArray> vao;
};

template <class Attributes>
class SegmentVector : public std::vector<Segment> {
public:
    SegmentVector() = default;
};

} // namespace gl
} // namespace mbgl
