package game

import gl "vendor:OpenGL"
import "vendor:glfw"

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
	gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
}
