package game

import "base:runtime"
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
	near:  f32,
	far:   f32,
}

camera := Camera {
	pos   = map_center + {0.0, 6.0 * y_up, 12.0},
	front = {0.0, 0.0, -1.0},
	right = {1.0, 0.0, 0.0},
	yaw   = -90.0,
	pitch = -25.0 * y_up,
	speed = 5.0,
	fov   = 45.0,
	near  = 0.1,
	far   = 1000.0,
}

world_up := [3]f32{0.0, 1.0, 0.0}
// world_up := [3]f32{0.0, -1.0, 0.0}

mouse_right_pressed := false
first_cursor_pos := true
prev_cursor_x, prev_cursor_y: f64
mouse_sensitivity :: 0.1

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
	} else if key == glfw.KEY_SPACE && action == glfw.PRESS {
		playing = !playing
	}
}

get_proj :: proc() -> matrix[4, 4]f32 {
	proj := m.matrix4_perspective_f32(
		m.to_radians(camera.fov),
		f32(swapchain_extent.width) / f32(swapchain_extent.height),
		camera.near,
		camera.far,
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

		// Turn cursor coordinates into normalized device coordinates
		// by changing their range from [0,1] to [-1,1]):
		x := f32(cursor_x / f64(swapchain_extent.width) * 2 - 1)
		y := f32(cursor_y / f64(swapchain_extent.height) * 2 - 1)

		ray_clip := [4]f32{x, y, -1.0, 1.0}
		invp := m.inverse(get_proj()) * ray_clip
		ray_eye := [4]f32{invp[0], invp[1], -1, 0}
		ray_world := m.normalize((m.inverse(get_view()) * ray_eye).xyz)

		prev_selected := selected_creature
		selected_creature = -1
		prev_tmin: f32 = 9999999
		for o, i in creatures {
			bb := BoundingBox {
				min = o.pos,
				max = o.pos + creature_size,
			}
			d := hit_distance(bb, ray_world)
			if (d > 0 && d < prev_tmin) {
				selected_creature = i
				prev_tmin = d
			}
		}

		if (prev_selected != -1 && selected_creature == -1) {
			bb := BoundingBox {
				min = ground.pos,
				max = ground.pos + ground_size,
			}
			d := hit_distance(bb, ray_world)
			if (d > 0) {
				selected_creature = prev_selected
				entry_point := camera.pos + ray_world * d
				creatures[prev_selected].target = entry_point
			}
		}
	}
}

hit_distance :: proc(bb: BoundingBox, ray_world: [3]f32) -> f32 {
	vmin := (bb.min - camera.pos) / ray_world
	vmax := (bb.max - camera.pos) / ray_world

	tmin := max(min(vmin.x, vmax.x), min(vmin.y, vmax.y), min(vmin.z, vmax.z))
	tmax := min(max(vmin.x, vmax.x), max(vmin.y, vmax.y), max(vmin.z, vmax.z))

	d: f32 = 0
	if (tmin < tmax) {
		d = tmin
	}

	return d
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
	camera_movement := camera.speed * (time_now - time_prev_frame)

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
