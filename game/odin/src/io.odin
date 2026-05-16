package game

import "base:runtime"
import "core:fmt"
import m "core:math/linalg"
import "vendor:glfw"

// Used to adjust camera movement to match the y axis direction
//  1 = OpenGL
// -1 = Vulkan / D3D / Meta
y_up :: 1
// y_up :: -1

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
	pos   = {2.0, 1.2 * y_up, 2.2},
	front = {0.0, 0.0, -1.0},
	right = {1.0, 0.0, 0.0},
	yaw   = -122.0,
	pitch = -22.0 * y_up,
	speed = 2.5,
	fov   = 45.0,
}

world_up := [3]f32{0.0, 1.0, 0.0}
// world_up := [3]f32{0.0, -1.0, 0.0}

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
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	} else if key == glfw.KEY_1 && action == glfw.PRESS {
		selected_object = 0
	} else if key == glfw.KEY_2 && action == glfw.PRESS {
		selected_object = 1
	} else if key == glfw.KEY_3 && action == glfw.PRESS {
		selected_object = -1
	}
}

get_proj :: proc() -> matrix[4, 4]f32 {
	proj := m.matrix4_perspective_f32(
		m.to_radians(camera.fov),
		f32(swapchain_extent.width) / f32(swapchain_extent.height),
		0.1,
		100.0,
	)
	proj[1][1] *= -y_up
	return proj
}

get_view :: proc() -> matrix[4, 4]f32 {
	return m.matrix4_look_at_f32(camera.pos, camera.pos + camera.front, world_up)
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
	} else if button == glfw.MOUSE_BUTTON_LEFT && action == glfw.PRESS {
		context = runtime.default_context()
		cursor_x, cursor_y := glfw.GetCursorPos(window)
		// normalized device coordinates:
		// Change range from [0,1] to [-1,1], and flip y
		x := f32(cursor_x / f64(swapchain_extent.width) * 2 - 1)
		// y := f32((cursor_y / f64(swapchain_extent.height) * 2 - 1) * -y_up)
		// no need to flip y here because it's flipped in get_proj
		y := f32((cursor_y / f64(swapchain_extent.height) * 2 - 1))

		ray_clip := [4]f32{x, y, -1.0, 1.0}
		invp := m.inverse(get_proj()) * ray_clip
		ray_eye := [4]f32{invp[0], invp[1], -1, 0}
		ray_world := m.normalize((m.inverse(get_view()) * ray_eye).xyz)

		selected_object = -1
		prev_tmin: f32 = 9999999
		for o, i in objects {
			bb := get_bb(o)

			tx1 := (bb.min.x - camera.pos.x) / ray_world.x
			tx2 := (bb.max.x - camera.pos.x) / ray_world.x
			txmin := min(tx1, tx2)
			txmax := max(tx1, tx2)

			ty1 := (bb.min.y - camera.pos.y) / ray_world.y
			ty2 := (bb.max.y - camera.pos.y) / ray_world.y
			tymin := min(ty1, ty2)
			tymax := max(ty1, ty2)

			tz1 := (bb.min.z - camera.pos.z) / ray_world.z
			tz2 := (bb.max.z - camera.pos.z) / ray_world.z
			tzmin := min(tz1, tz2)
			tzmax := max(tz1, tz2)

			tmin := max(txmin, tymin, tzmin)
			tmax := min(txmax, tymax, tzmax)

			if (tmax >= tmin && tmin < prev_tmin) {
				selected_object = i
				prev_tmin = tmin
			}
		}

		a := [3]f32{1.0, 0.0, 0.0}
		b := [3]f32{0.0, 1.0, 0.0}

		// f1 := [3]f32{0.0, 0.0, 0.0}
		// f2 := [3]f32{0.5, 0.0, 0.0}
		// f3 := [3]f32{0.5, 0.0, 0.5}
		// a := f2 - f1
		// b := f3 - f1

		// Calculate the cross product
		c := m.cross(a, b)
		c2 := m.normalize(m.cross(b, a))

		// fmt.printf("Vector A: %v\n", a)
		// fmt.printf("Vector B: %v\n", b)
		// fmt.printf("Cross Product (A x B): %v\n", c)
		// fmt.printf("Cross Product (B x A): %v\n", c2)

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
	camera.pitch -= y_up * f32((y - prev_cursor_y) * mouse_sensitivity)
	// camera.pitch += f32((y - prev_cursor_y) * mouse_sensitivity)
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
	if glfw.GetKey(window, glfw.KEY_E) == glfw.PRESS {
		camera.pos += y_up * world_up * camera_movement
	}
	if glfw.GetKey(window, glfw.KEY_C) == glfw.PRESS {
		camera.pos -= y_up * world_up * camera_movement
	}
}
