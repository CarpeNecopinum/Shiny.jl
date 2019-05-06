bufferify(data::AbstractArray) = GLAbstraction.GLBuffer(data)
bufferify(data::GLAbstraction.GLBuffer) = data

MaybeNode{T} = Union{Node{T},T}
ArrayOrUniform{T} = Union{Vector{T}, MaybeNode{T}}

function cloud(positions::AbstractArray; color::MaybeNode{Vec4f0} = Vec4f0(0,0,0,1.0))
   obj = GLAbstraction.RenderObject(
      Dict{Symbol,Any}(
         :position => bufferify(positions),
         :color => color,
         :modelviewprojection => Node(Mat4f0(I))
      ),
      Materials.uniform_color(),
      GLAbstraction.StandardPrerender(false, false))
   obj.postrenderfunction = GLAbstraction.StandardPostrender(obj.vertexarray, GL_POINTS);
   obj
end

function cloud(positions::AbstractArray; colors::AbstractArray)
   obj = GLAbstraction.RenderObject(
      Dict{Symbol,Any}(
         :position => bufferify(positions),
         :color => bufferify(colors),
         :modelviewprojection => Node(Mat4f0(I))
      ),
      Materials.vertex_color(),
      GLAbstraction.StandardPrerender(false, false))
   obj.postrenderfunction = GLAbstraction.StandardPostrender(obj.vertexarray, GL_POINTS);
   obj
end

function splats(positions::AbstractArray, normals::AbstractArray; color = Vec3f0(1,0,1), radius = 5f-2)
   dyn_colors = isa(color, Vector)
   dyn_radii = isa(radius, Vector)

   defines = Dict{String,Int}()
   dyn_colors && (defines["COLOR_PER_SPLAT"] = 1)
   dyn_radii && (defines["RADIUS_PER_SPLAT"] = 1)

   obj = GLAbstraction.RenderObject(
      Dict{Symbol,Any}(
         :position => bufferify(positions),
         :normal => bufferify(normals),
         :color => (dyn_colors ? bufferify(color) : color),
         :modelview => Mat4f0(I),
         :projection => Mat4f0(I),
         :radius => (dyn_radii ? bufferify(radius) : radius)
      ),
      cool_shader(Materials.shaders * "/splats.glsl", defines),
      GLAbstraction.StandardPrerender(false, false))
   obj.postrenderfunction = GLAbstraction.StandardPostrender(obj.vertexarray, GL_POINTS);
   obj
end

function mesh(positions::AbstractArray, indices::AbstractArray; colors::AbstractArray)
   obj = GLAbstraction.RenderObject(
      Dict{Symbol,Any}(
         :position => bufferify(positions),
         :color => bufferify(colors),
         :indices => indices,
         :modelviewprojection => Mat4f0(I)
      ),
      Materials.vertex_color(),
      GLAbstraction.StandardPrerender(false, false))
   obj.postrenderfunction = GLAbstraction.StandardPostrender(obj.vertexarray, GL_TRIANGLES);
   obj
end
