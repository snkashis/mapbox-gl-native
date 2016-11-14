#pragma once

#include <mbgl/gl/types.hpp>
#include <mbgl/gl/object.hpp>
#include <mbgl/gl/context.hpp>
#include <mbgl/gl/vertex_buffer.hpp>
#include <mbgl/gl/index_buffer.hpp>
#include <mbgl/gl/attribute.hpp>
#include <mbgl/gl/uniform.hpp>

#include <string>

namespace mbgl {
namespace gl {

template <class P, class As, class Us>
class Program {
public:
    using Primitive = P;
    using Attributes = As;
    using Uniforms = Us;

    using UniformValues = typename Uniforms::Values;
    using AttributeValues = typename Attributes::Values;

    Program(Context& context, const std::string& vertexSource, const std::string& fragmentSource)
        : vertexShader(context.createShader(ShaderType::Vertex, vertexSource)),
          fragmentShader(context.createShader(ShaderType::Fragment, fragmentSource)),
          program(context.createProgram(vertexShader, fragmentShader)),
          attributesState(Attributes::state(program)),
          uniformsState((context.linkProgram(program), Uniforms::state(program))) {}

    template <class DrawMode>
    void draw(Context& context,
              DrawMode drawMode,
              DepthMode depthMode,
              StencilMode stencilMode,
              ColorMode colorMode,
              UniformValues&& uniformValues,
              AttributeValues&& attributeValues,
              const IndexBuffer<DrawMode>& indexBuffer,
              const SegmentVector<Attributes>& segments) {
        static_assert(std::is_same<Primitive, typename DrawMode::Primitive>::value, "incompatible draw mode");

        context.setDrawMode(drawMode);
        context.setDepthMode(depthMode);
        context.setStencilMode(stencilMode);
        context.setColorMode(colorMode);

        context.program = program;

        Uniforms::bind(uniformsState, std::move(uniformValues));

        for (const auto& segment : segments) {
            if (segment.needAttributeBinding(context, indexBuffer.buffer)) {
                Attributes::bind(context,
                                 attributesState,
                                 std::move(attributeValues),
                                 segment);
            }

            context.draw(drawMode.primitiveType,
                         segment.indexOffset,
                         segment.indexLength);
        }
    }

private:
    UniqueShader vertexShader;
    UniqueShader fragmentShader;
    UniqueProgram program;

    typename Attributes::State attributesState;
    typename Uniforms::State uniformsState;
};

} // namespace gl
} // namespace mbgl
