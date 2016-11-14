#include <mbgl/gl/segment.hpp>
#include <mbgl/gl/context.hpp>
#include <mbgl/gl/vertex_array.hpp>

namespace mbgl {
namespace gl {

bool Segment::needAttributeBinding(Context& context, BufferID indexBuffer) const {
    if (!gl::GenVertexArrays || !gl::BindVertexArray) {
        return true;
    }

    if (vao) {
        context.vertexArrayObject = *vao;
        return true; // HACK
    }

    VertexArrayID id = 0;
    MBGL_CHECK_ERROR(gl::GenVertexArrays(1, &id));
    context.vertexArrayObject = id;
    vao = UniqueVertexArray(std::move(id), { &context });

    // If we are initializing a new VAO, we need to force the index
    // buffer to be rebound. VAOs don't inherit the existing binding.
    context.elementBuffer.setDirty();
    context.elementBuffer = indexBuffer;

    return true;
}

} // namespace gl
} // namespace mbgl
