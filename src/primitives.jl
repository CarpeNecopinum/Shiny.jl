bufferify(data) = data
bufferify(data::Node{Vector{T}} where T) = GLAbstraction.GLBuffer(data)
bufferify(data::Vector) = GLAbstraction.GLBuffer(data)

MaybeNode{T} = Union{Node{T},T}
ArrayOrUniform{T} = Union{Vector{T}, MaybeNode{T}}

function cloud(positions, color = Vec4f0(0,0,0,1.0))
   dyn_colors = isa(color, Vector) || isa(color, Node{Vector{T}} where {T}) || isa(color, GLAbstraction.GLBuffer)

   obj = GLAbstraction.RenderObject(
      Dict{Symbol,Any}(
         :position => bufferify(positions),
         :color => bufferify(color),
         :modelviewprojection => Node(Mat4f0(I))
      ),
      (dyn_colors ? Materials.vertex_color() : Materials.uniform_color()),
      GLAbstraction.StandardPrerender(false, false))
   obj.postrenderfunction = GLAbstraction.StandardPostrender(obj.vertexarray, GL_POINTS);
   obj
end

function splats(positions, normals; color = Vec3f0(1,0,1), radius = 5f-2)
   dyn_colors = isa(color, Vector) || isa(color, Node{Vector{T}} where {T}) || isa(color, GLAbstraction.GLBuffer)
   dyn_radii = isa(radius, Vector) || isa(radius, Node{Vector{T}} where {T})  || isa(radius, GLAbstraction.GLBuffer)

   defines = Dict{String,Int}()
   dyn_colors && (defines["COLOR_PER_SPLAT"] = 1)
   dyn_radii && (defines["RADIUS_PER_SPLAT"] = 1)

   obj = GLAbstraction.RenderObject(
      Dict{Symbol,Any}(
         :position => bufferify(positions),
         :normal => bufferify(normals),
         :color => bufferify(color),
         :modelview => Mat4f0(I),
         :projection => Mat4f0(I),
         :radius => bufferify(radius)
      ),
      cool_shader(Materials.shaders * "/splats.glsl", defines),
      GLAbstraction.StandardPrerender(false, false))
   obj.postrenderfunction = GLAbstraction.StandardPostrender(obj.vertexarray, GL_POINTS);
   obj
end

function mesh(positions, indices; color = Vec3f0(1,0,1))
   color_attribute = bufferify(color)

   defines = Dict("DFDX_NORMALS" => 1)
   (color_attribute isa GLAbstraction.GLBuffer) && (defines["COLOR_PER_VERTEX"] = 1)

   obj = GLAbstraction.RenderObject(
      Dict{Symbol,Any}(
         :position => bufferify(positions),
         :color => color_attribute,
         :indices => bufferify(indices),
         :modelview => Mat4f0(I),
         :projection => Mat4f0(I)
      ),
      cool_shader(Materials.shaders * "/mesh.glsl", defines),
      GLAbstraction.StandardPrerender(false, false))
   obj.postrenderfunction = () -> (
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, obj.vertexarray.indices.id);
      GLAbstraction.render(obj.vertexarray, GL_TRIANGLES))
   obj
end

function mesh(prim::GeometryTypes.GeometryPrimitive; color = Vec3f0(1,0,1), resolution = 512)
   mesh(GeometryTypes.decompose(Point3f0, prim, resolution),
        GeometryTypes.decompose(Face{3,OffsetInteger{-1,UInt32}}, prim, resolution);
        color = color)
end

function arrows(interleaved::AbstractArray, colors::AbstractArray)
   arrows(interleaved[1:2:end], interleaved[2:2:end], colors)
end

function arrows(positions_from::AbstractArray, positions_to::AbstractArray, colors::AbstractArray)
   @assert length(positions_from) == length(positions_to)
   obj = GLAbstraction.RenderObject(
      Dict{Symbol,Any}(
         :tip => bufferify(positions_to),
         :tail => bufferify(positions_from),
         :color => bufferify(colors),
         :modelview => Mat4f0(I),
         :projection => Mat4f0(I)
      ),
      cool_shader(Materials.shaders * "/arrows.glsl"),
      GLAbstraction.StandardPrerender(false, false))
   obj.postrenderfunction = GLAbstraction.StandardPostrender(obj.vertexarray, GL_POINTS)
   obj
end

function lines(positions_from::AbstractArray, positions_to::AbstractArray, colors::AbstractArray)
   @assert length(positions_from) == length(positions_to)
   obj = GLAbstraction.RenderObject(
      Dict{Symbol,Any}(
         :tip => bufferify(positions_to),
         :tail => bufferify(positions_from),
         :color => bufferify(colors),
         :modelview => Mat4f0(I),
         :projection => Mat4f0(I)
      ),
      cool_shader(Materials.shaders * "/lines.glsl"),
      GLAbstraction.StandardPrerender(false, false))
   obj.postrenderfunction = GLAbstraction.StandardPostrender(obj.vertexarray, GL_POINTS)
   obj
end
