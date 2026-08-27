package survival

import "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

WINDOW_WIDTH: i32 = 800
WINDOW_HEIGHT: i32 = 600

main :: proc() {
	glfw.Init()

	window = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Survival", nil, nil)

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	glfw.MakeContextCurrent(window)

	// Load OpenGL functions
	gl.load_up_to(3, 3, glfw.gl_set_proc_address)
	gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

	// game_init()
	io_init()
	// world_init()
	globe_init()
	// dashboard_init()

	gl.Enable(gl.DEPTH_TEST)
	gl.ClearColor(0.1, 0.1, 0.1, 1.0)

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		// world_draw()
		globe_draw()
		// dashboard_draw()

		glfw.SwapBuffers(window)
	}
}
