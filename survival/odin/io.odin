package survival

import "base:runtime"
import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

window: glfw.WindowHandle

mouse_right_pressed := false
first_cursor_pos_right := true
prev_cursor_x, prev_cursor_y: f64

io_init :: proc() {
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
	glfw.SetKeyCallback(window, key_callback)
	glfw.SetMouseButtonCallback(window, mouse_button_callback)
	glfw.SetCursorPosCallback(window, cursor_pos_callback)
	glfw.SetScrollCallback(window, scroll_callback)
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
	gl.Viewport(0, 0, width, height)
	WINDOW_WIDTH = width
	WINDOW_HEIGHT = height
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}

	globe_io_key_callback(window, key, scancode, action, mode)
}

mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()

	if button == glfw.MOUSE_BUTTON_RIGHT {
		if action == glfw.PRESS {
			mouse_right_pressed = true
		} else {
			mouse_right_pressed = false
			first_cursor_pos_right = true
		}
	}

	dashboard_mouse_button_callback(window, button, action, mods)
	globe_io_mouse_button_callback(window, button, action, mods)
}

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, x, y: f64) {
	context = runtime.default_context()

	if mouse_right_pressed {
		if first_cursor_pos_right {
			prev_cursor_x = x
			prev_cursor_y = y
			first_cursor_pos_right = false
		}
		world_pos.x = world_pos.x + f32(x - prev_cursor_x)
		world_pos.y = world_pos.y + f32(y - prev_cursor_y)

		prev_cursor_x = x
		prev_cursor_y = y
	}

	globe_io_cursor_pos_callback(window, x, y)
}

scroll_callback :: proc "c" (window: glfw.WindowHandle, xoffset: f64, yoffset: f64) {
	context = runtime.default_context()
	// fmt.println(xoffset, yoffset)
	globe_io_scroll_callback(window, xoffset, yoffset)
}
