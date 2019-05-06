struct GLFWCamera <: AbstractCamera
    globalView::Node{Mat4f0}
    projection::Node{Mat4f0}
    fov::Node{Float32}
    window::GLFW.Window
    GLFWCamera(window) = new(Mat4f0(I), Mat4f0(I), 64f0, window)
end

view(cam::GLFWCamera) = cam.globalView[]
projection(cam::GLFWCamera) = cam.projection[]

function update!(cam::GLFWCamera, lineage::Vector{Group})
    fb = GLFW.GetFramebufferSize(cam.window)
    cam.projection[] = perspectiveprojection(cam.fov[], Float32(fb[1] / fb[2]), 1f-2, 1f3)

    if isempty(lineage)
        cam.globalView[] = Mat{4,4,Float32}(LinearAlgebra.I)
    else
        cam.globalView[] = lineage[end].globalTransform[] ^ -1
    end
end
