### Types
"""has to have view(::Camera) and projection(::Camera)"""
abstract type AbstractCamera end

struct Group
    localTransform::Node{Mat4f0}
    globalTransform::Node{Mat4f0}
    children::Vector{Any}
    Group(localTx::Node{Mat4f0}, children::Vector{Any} = Any[]) = new(localTx, Node(Mat4f0(I)), children)
end
Group() = Group(Node(SMatrix{4,4,Float32}(I)))
Group(children::AbstractVector) = Group(Node(SMatrix{4,4,Float32}(LinearAlgebra.I)), convert(Vector{Any}, children))

Base.push!(group::Group, child) = (push!(group.children, child), group)[2]


### Updates

update!(o::GLAbstraction.RenderObject, lineage) = o

function update!(group::Group, lineage::Vector{Group} = Group[])
    isempty(lineage) || (group.globalTransform[] = group.localTransform[] * lineage[end].globalTransform[])
    update!.(group.children, Ref(push!(lineage, group)))
    pop!(lineage)
end


## Render

render(group::Group, camera::AbstractCamera) = render.(group.children, Ref(camera), Ref(group.globalTransform[]))
render(group::Group, camera::AbstractCamera, ::Mat4f0) = render(group, camera)
render(::AbstractCamera, ::AbstractCamera, ::Mat4f0) = nothing

function render(obj::GLAbstraction.RenderObject, camera::AbstractCamera, model::Mat4f0)
    haskey(obj.uniforms, :model) && (obj.uniforms[:model] = model)
    haskey(obj.uniforms, :view) && (obj.uniforms[:view] = view(camera))
    haskey(obj.uniforms, :projection) && (obj.uniforms[:projection] = projection(camera))
    haskey(obj.uniforms, :modelview) && (obj.uniforms[:modelview] = view(camera) * model)
    haskey(obj.uniforms, :viewprojection) && (obj.uniforms[:viewprojection]  = projection(camera) * view(camera))
    haskey(obj.uniforms, :modelviewprojection) && (obj.uniforms[:modelviewprojection] = projection(camera) * view(camera) * model)

    GLAbstraction.render(obj)
end
