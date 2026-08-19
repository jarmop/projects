package survival

import gl "vendor:OpenGL"
import glfw "vendor:glfw"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720

main :: proc() {
	glfw.Init()

	window = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Odin OpenGL Text", nil, nil)

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	glfw.MakeContextCurrent(window)

	// Load OpenGL functions
	gl.load_up_to(3, 3, glfw.gl_set_proc_address)

	init_io()

	// init_world()
	init_table()

	init_text()

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

		gl.ClearColor(0.1, 0.1, 0.1, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		// draw_world()
		draw_table()

		glfw.SwapBuffers(window)
	}
}
