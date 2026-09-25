package daw

import "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 600

window: glfw.WindowHandle

window_init :: proc() {
	glfw.Init()
	window = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "DAW", nil, nil)

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	glfw.MakeContextCurrent(window)

	gl.load_up_to(3, 3, glfw.gl_set_proc_address)
	// gl.Viewport(0, 0, INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)

	glfw.SetKeyCallback(window, key_callback)
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}
