function spaceship_style_move!(group::Group, translation::Vec3f0, rotation::Vec3f0)
    model = group.localTransform[]
    model = model * rotationmatrix_y(rotation[1]) * rotationmatrix_x(rotation[2]) * rotationmatrix_z(rotation[3]) * translationmatrix(translation)
    group.localTransform[] = model
end

struct SpaceShipControl
    window::GLFW.Window
    mouseLast::Node{Vec2f0}
    translation_speed::Float32
    rotation_speed::Float32

    SpaceShipControl(window::GLFW.Window; translation_speed = 1, rotation_speed = 1) = new(window, Vec2f0(-1,-1), translation_speed, rotation_speed)
end

function update!(control::SpaceShipControl, lineage::Vector{Group})
    trans = zero(Vec3f0)
    rotat = zero(Vec3f0)

    GLFW.GetKey(control.window, GLFW.KEY_W) && (trans += Vec3f0(0,0,-1))
    GLFW.GetKey(control.window, GLFW.KEY_A) && (trans += Vec3f0(-1,0,0))
    GLFW.GetKey(control.window, GLFW.KEY_S) && (trans += Vec3f0(0,0,1))
    GLFW.GetKey(control.window, GLFW.KEY_D) && (trans += Vec3f0(1,0,0))
    GLFW.GetKey(control.window, GLFW.KEY_LEFT_SHIFT) && (trans += Vec3f0(0,1,0))
    GLFW.GetKey(control.window, GLFW.KEY_LEFT_CONTROL) && (trans += Vec3f0(0,-1,0))

    GLFW.GetKey(control.window, GLFW.KEY_Q) && (rotat += Vec3f0(0,0,-1))
    GLFW.GetKey(control.window, GLFW.KEY_R) && (rotat += Vec3f0(0,0,1))

    if (GLFW.GetMouseButton(control.window, GLFW.MOUSE_BUTTON_LEFT))
        mouseNow = Vec2f0(GLFW.GetCursorPos(control.window)...)
        if control.mouseLast[][1] > 0
            rotat -= Vec3f0(((mouseNow - control.mouseLast[]) ./ 800f0)..., 0)
        end
        control.mouseLast[] = mouseNow
    else
        control.mouseLast[] = Vec2f0(-9f4,-9f4)
    end

    # display(trans)

    trans = trans .* control.translation_speed
    rotat = rotat .* control.rotation_speed
    spaceship_style_move!(lineage[end], trans, rotat)
end

render(c::SpaceShipControl, ::AbstractCamera, ::Mat4f0) = c
