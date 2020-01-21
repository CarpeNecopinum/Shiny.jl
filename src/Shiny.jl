module Shiny
    import Observables
    Node = Observables.Observable

    import GeometryTypes: SimpleRectangle, Vec2f0, Vec3f0, Vec4f0, Mat3f0, Mat4f0, Vec, Mat, Point3f0
    import LinearAlgebra
    import LinearAlgebra: I
    import GLFW

    using GLMakie: GLAbstraction
    using ModernGL

    include("quaternion.jl")
    include("matrix_math.jl")

    include("scenegraph.jl")
    include("camera.jl")
    include("movement.jl")

    include("show_scene.jl")

    include("cool_shader.jl")

    module Materials
        using GLMakie: GLAbstraction
        using ...Shiny: cool_shader
        include("materials.jl")
    end

    module Primitives
        import GeometryTypes
        import LinearAlgebra: I
        using GLMakie: GLAbstraction
        using ...Shiny: Point3f0, Vec3f0, Vec4f0, Mat4f0, Node, Materials, cool_shader
        using GeometryTypes: Face, OffsetInteger
        using ModernGL
        include("primitives.jl")
    end

    # Workaround for https://github.com/JuliaPlots/AbstractPlotting.jl/issues/250
    Base.convert(::Type{Node{T}}, x) where {T} = Node{T}(x)
end
