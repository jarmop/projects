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

	init_io()
	// init_world()

	init_dashboard()

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.ClearColor(0.1, 0.1, 0.1, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		// draw_world()
		draw_dashboard()

		glfw.SwapBuffers(window)
	}
}
