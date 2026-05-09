package game

import "base:runtime"
import m "core:math/linalg"
import "vendor:glfw"

Camera :: struct {
	pos:   [3]f32,
	front: [3]f32,
	right: [3]f32,
	yaw:   f32,
	pitch: f32,
	speed: f32,
	fov:   f32,
}

camera := Camera {
	pos   = {-0.5, 0.5, 1.0},
	front = {0.0, 0.0, -1.0},
	right = {1.0, 0.0, 0.0},
	yaw   = -52.0,
	pitch = -12.0,
	speed = 2.5,
	fov   = 45.0,
}

world_up := [3]f32{0.0, 1.0, 0.0}

mouse_right_pressed := false
first_cursor_pos := true
prev_cursor_x, prev_cursor_y: f64
mouse_sensitivity :: 0.1
time_prev_frame: f32 = 0.0

frame_buffer_resized := false

init_io :: proc() {
	glfw.SetKeyCallback(window, key_callback)
	glfw.SetMouseButtonCallback(window, mouse_button_callback)
	glfw.SetCursorPosCallback(window, cursor_pos_callback)
	glfw.SetFramebufferSizeCallback(window, frame_buffer_size_callback)

	update_camera()
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	if (key == glfw.KEY_ESCAPE && action == glfw.PRESS) {
		glfw.SetWindowShouldClose(window, true)
	}
}

mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	if button == glfw.MOUSE_BUTTON_RIGHT {
		if action == glfw.PRESS {
			mouse_right_pressed = true
			glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
		} else {
			mouse_right_pressed = false
			first_cursor_pos = true
			glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_NORMAL)
		}
	}
}

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, x, y: f64) {
	context = runtime.default_context()

	if !mouse_right_pressed {
		return
	}

	if first_cursor_pos {
		prev_cursor_x = x
		prev_cursor_y = y
		first_cursor_pos = false
	}

	camera.yaw += f32((x - prev_cursor_x) * mouse_sensitivity)
	camera.pitch -= f32((y - prev_cursor_y) * mouse_sensitivity)
	prev_cursor_x = x
	prev_cursor_y = y

	if camera.pitch > 89.0 {
		camera.pitch = 89.0
	} else if camera.pitch < -89.0 {
		camera.pitch = -89.0
	}

	update_camera()
}

frame_buffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	frame_buffer_resized = true
}

update_camera :: proc() {
	camera.front[0] = m.cos(m.to_radians(camera.yaw)) * m.cos(m.to_radians(camera.pitch))
	camera.front[1] = m.sin(m.to_radians(camera.pitch))
	camera.front[2] = m.sin(m.to_radians(camera.yaw)) * m.cos(m.to_radians(camera.pitch))
	camera.front = m.normalize(camera.front)
	camera.right = m.cross(camera.front, world_up)
	camera.right = m.normalize(camera.right)
}

handle_camera_movement_keys :: proc() {
	time_now := f32(glfw.GetTime())
	camera_movement := camera.speed * (time_now - time_prev_frame)
	time_prev_frame = time_now

	// WASD
	if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {
		camera.pos += camera.front * camera_movement
	}
	if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS {
		camera.pos -= camera.front * camera_movement
	}
	if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {
		camera.pos -= camera.right * camera_movement
	}
	if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS {
		camera.pos += camera.right * camera_movement
	}

	// Elevation
	if (glfw.GetKey(window, glfw.KEY_E) == glfw.PRESS) {
		camera.pos += world_up * camera_movement
	}
	if (glfw.GetKey(window, glfw.KEY_C) == glfw.PRESS) {
		camera.pos -= world_up * camera_movement
	}
}
