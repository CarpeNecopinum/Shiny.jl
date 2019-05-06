using FileIO

const shaders = (@__DIR__) * "/shaders"

uniform_color() = GLAbstraction.LazyShader(
    shaders * "/uniform_color.vert",
    shaders * "/uniform_color.frag")

splats() = cool_shader(shaders * "/splats.glsl")
vertex_color() = cool_shader(shaders * "/vertex_color.glsl")
colored_splats() = cool_shader(shaders * "/splats.glsl",
    Dict("COLOR_PER_SPLAT" => 1))
colored_radius_splats() = cool_shader(shaders * "/splats.glsl",
    Dict("COLOR_PER_SPLAT" => 1, "RADIUS_PER_SPLAT" => 1))
colored_splats_tess() = cool_shader(shaders * "/colored_splats_tess.glsl")
