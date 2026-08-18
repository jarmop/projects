package survival

import "vendor:glfw"

window: glfw.WindowHandle

init_io :: proc() {
	glfw.SetKeyCallback(window, key_callback)
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}
