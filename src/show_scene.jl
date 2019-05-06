function createContext()
    GLFW.Init()

    window = GLFW.CreateWindow(1920, 1080, "Shiny.jl")
    GLFW.ShowWindow(window)
    GLFW.MakeContextCurrent(window)
    GLAbstraction.switch_context!(window)
    glEnable(GL_PROGRAM_POINT_SIZE)
    GLFW.SwapInterval(-1)

    window
end

function show(scene::Group, camera::AbstractCamera, window::GLFW.Window; rate = 1/60)
    GLFW.ShowWindow(window)
    GLFW.SetWindowShouldClose(window, false)
    glClearColor(0.5,0.5,0.5,1)

    frames = 0
    lastprint = time()

    while !GLFW.WindowShouldClose(window)
        framestart = time()
        GLFW.PollEvents();

        Shiny.update!(scene)

        glViewport(0, 0, GLFW.GetWindowSize(window)...)

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glEnable(ModernGL.GL_DEPTH_TEST)
        glDepthMask(GL_TRUE)

        Shiny.render(scene, camera)

        GLFW.SwapBuffers(window)
        frames += 1

        sleep(max(0.001, rate - 1.5 * (time() - framestart)))

        now = time()
        if now - lastprint > 1
            delta = now - lastprint

            frametime = round(delta / frames * 1000, digits=2)
            fps = round(frames / delta, digits=1)

            GLFW.SetWindowTitle(window, "Shiny.jl - $(frametime)ms/frame - $(fps) FPS")

            frames = 0
            lastprint = now
        end
    end
    GLFW.HideWindow(window)
end
