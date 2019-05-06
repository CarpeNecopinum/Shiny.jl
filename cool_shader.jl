function solve_includes!(source::String, include_dir::String)
    while (mat = match(r"\#include *\"(?'file'\S+)\"", source)) !== nothing
        included_source = open(x->read(x,String), mat[:file])
        source = source[1:mat.offset] * "\n" *
            included_source * "\n" *
            source[mat.offset + length(mat.match):end]
    end
end

function cool_shader(sourcefile::AbstractString, defines::Dict = Dict{String,String}())
    source = open(x->read(x,String), sourcefile)

    solve_includes!(source, dirname(sourcefile))

    header = "#version 450 core\n"
    for (k,v) in defines
        header *= "#define $(k) $(v)\n"
    end

    shaders = Vector{Tuple{String,UInt32}}()

    if occursin("VERTEX_SHADER", source)
        push!(shaders, (header * "#define VERTEX_SHADER\n#line 1\n" * source, GL_VERTEX_SHADER))
    end

    if occursin("TESSELATION_CONTROL_SHADER", source)
        push!(shaders, (header * "#define TESSELATION_CONTROL_SHADER\n#line 1\n" * source, GL_TESS_CONTROL_SHADER))
    end

    if occursin("TESSELATION_EVALUATION_SHADER", source)
        push!(shaders, (header * "#define TESSELATION_EVALUATION_SHADER\n#line 1\n" * source, GL_TESS_EVALUATION_SHADER))
    end

    if occursin("GEOMETRY_SHADER", source)
        push!(shaders, (header * "#define GEOMETRY_SHADER\n#line 1\n" * source, GL_GEOMETRY_SHADER))
    end

    if occursin("FRAGMENT_SHADER", source)
        push!(shaders, (header * "#define FRAGMENT_SHADER\n#line 1\n" * source, GL_FRAGMENT_SHADER))
    end

    GLAbstraction.LazyShader(shaders...)
end
