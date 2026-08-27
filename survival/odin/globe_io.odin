package survival

import "base:runtime"
import "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

Camera :: struct {
	pos:   [3]f32,
	front: [3]f32,
	right: [3]f32,
	up:    [3]f32,
	yaw:   f32,
	pitch: f32,
	speed: f32,
	fov:   f32,
	near:  f32,
	far:   f32,
}

camera := Camera {
	pos   = {0, 0, 4},
	front = {0.0, 0.0, -1.0},
	right = {1.0, 0.0, 0.0},
	up    = {0.0, 1.0, 0.0},
	yaw   = -90,
	pitch = -0,
	speed = 80,
	fov   = 45.0,
	near  = 0.1,
	far   = 10000.0,
}

globe_io_mouse_left_pressed := false
globe_io_first_cursor_pos_left := true
globe_io_prev_cursor_x, globe_io_prev_cursor_y: f64

globe_io_mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()

	if button == glfw.MOUSE_BUTTON_LEFT {
		if action == glfw.PRESS {
			globe_io_mouse_left_pressed = true
		} else {
			globe_io_mouse_left_pressed = false
			globe_io_first_cursor_pos_left = true
		}
	}
}

globe_io_cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, x, y: f64) {
	context = runtime.default_context()

	if globe_io_mouse_left_pressed {
		if globe_io_first_cursor_pos_left {
			globe_io_prev_cursor_x = x
			globe_io_prev_cursor_y = y
			globe_io_first_cursor_pos_left = false
		}

		speed: f32 = 0.22
		globe_spin_angle += f32(x - globe_io_prev_cursor_x) * speed
		globe_tilt_angle += f32(y - globe_io_prev_cursor_y) * speed
		if globe_tilt_angle > 90 {
			globe_tilt_angle = 90
		} else if globe_tilt_angle < -90 {
			globe_tilt_angle = -90
		}

		globe_io_prev_cursor_x = x
		globe_io_prev_cursor_y = y
	}
}
