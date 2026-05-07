package game

import "vendor:glfw"

key_callback :: proc "c" (
	window: glfw.WindowHandle,
	key: i32,
	scancode: i32,
	action: i32,
	mode: i32,
) {
	if (key == glfw.KEY_ESCAPE && action == glfw.PRESS) {
		glfw.SetWindowShouldClose(window, true)
	}
}
