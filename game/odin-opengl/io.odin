package game

import "base:runtime"
import "core:fmt"
import m "core:math/linalg"
// import glsl "core:math/linalg/glsl"
// import m "core:math"
import gl "vendor:OpenGL"
import "vendor:glfw"

mouse_sensitivity :: 0.1
mouse_right_pressed := false
ctrl_pressed := false
first_cursor_pos := true
prev_cursor_x, prev_cursor_y: f64

init_io :: proc() {
	glfw.SetKeyCallback(window, key_callback)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
	glfw.SetMouseButtonCallback(window, mouse_button_callback)
	glfw.SetCursorPosCallback(window, cursor_pos_callback)

	update_camera()
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	context = runtime.default_context()

	// if mode == glfw.MOD_CONTROL {
	// 	ctrl_pressed = true
	// 	if (creature_selected > -1 && key == glfw.KEY_S && action == glfw.PRESS) {
	// 		// Toggle shooting
	// 		player_creature = creature_selected if creature_selected != player_creature else -1
	// 		// If shooting, target the other guy, otherwise remove target
	// 		if player_creature > -1 {
	// 			ai_creature = 1 if creature_selected == 0 else 0
	// 		} else {
	// 			ai_creature = -1
	// 		}
	// 		time_prev_shot = time_now
	// 	}
	// 	return
	// }

	ctrl_pressed = false
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	} else if key == glfw.KEY_SPACE && action == glfw.PRESS {
		if (soldier_dead) {
			// Restart game
			clear(&enemies)
			soldier_dead = false
		}
		playing = !playing
	}
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
	gl.Viewport(0, 0, width, height)
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
		window_width, window_height := glfw.GetWindowSize(window)

		// Turn cursor coordinates into OpenGL normalized device coordinates
		// by changing their range from [0,1] to [-1,1]), and flipping y:
		x := f32(cursor_x / f64(window_width) * 2 - 1)
		y := -f32(cursor_y / f64(window_height) * 2 - 1)

		ray_clip := [4]f32{x, y, -1.0, 1.0}
		proj := m.matrix4_perspective_f32(
			m.to_radians(camera.fov),
			f32(window_width) / f32(window_height),
			camera.near,
			camera.far,
		)
		invp := m.inverse(proj) * ray_clip
		ray_eye := [4]f32{invp[0], invp[1], -1, 0}
		view := m.matrix4_look_at_f32(camera.pos, camera.pos + camera.front, camera.up)
		ray_world := m.normalize((m.inverse(view) * ray_eye).xyz)

		// SELECT CREATURE
		prev_selected := soldier_selected
		soldier_selected = -1
		prev_d: f32 = 9999999
		for c, i in soldiers {
			// bb: BoundingBox
			// bb.min = c.pos - CREATURE_CENTER_XZ
			// bb.max = bb.min + CREATURE_SIZE
			bb := BoundingBox {
				min = c.pos,
				max = c.pos + CREATURE_DIMENSIONS,
			}
			d := hit_distance(bb, camera.pos, ray_world)
			if (d > 0 && d < prev_d) {
				soldier_selected = i
				prev_d = d
			}
		}

		// Check hit on ground if no hits on creatures
		if (prev_selected != -1 && soldier_selected == -1) {
			bb := BoundingBox {
				min = GROUND_POSITION,
				max = GROUND_POSITION + GROUND_DIMENSIONS,
			}
			d := hit_distance(bb, camera.pos, ray_world)
			if (d > 0) {
				entry_point := camera.pos + ray_world * d
				target := entry_point - CREATURE_CENTER_XZ

				soldier_selected = prev_selected
				soldier := soldiers[soldier_selected]

				target_direction := m.normalize(target - soldier.pos)
				target_d := m.length(target - soldier.pos)

				soldier_sees_target := true
				for w in walls_x {
					wall_d := hit_distance(w.bb, soldier.pos + CREATURE_CENTER, target_direction)
					if wall_d > 0 && wall_d < target_d {
						soldier_sees_target = false
						break
					}
				}
				if soldier_sees_target {
					for w in walls_z {
						wall_d := hit_distance(
							w.bb,
							soldier.pos + CREATURE_CENTER,
							target_direction,
						)
						if wall_d > 0 && wall_d < target_d {
							soldier_sees_target = false
							break
						}
					}
				}

				if soldier_sees_target {
					soldiers[prev_selected].target = target
				}
			}
		}
	}
}

hit_distance :: proc(bb: BoundingBox, ray_start: [3]f32, ray_direction: [3]f32) -> f32 {
	// Get the distances where the ray enters and exits the bounding box on each axis
	dmin := (bb.min - ray_start) / ray_direction
	dmax := (bb.max - ray_start) / ray_direction

	// Get the distances where the ray enters and exits the bounding box
	d_to_entry := max(min(dmin.x, dmax.x), min(dmin.y, dmax.y), min(dmin.z, dmax.z))
	d_to_exit := min(max(dmin.x, dmax.x), max(dmin.y, dmax.y), max(dmin.z, dmax.z))

	return d_to_entry if d_to_entry < d_to_exit else 0
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

update_camera :: proc() {
	camera.front[0] = m.cos(m.to_radians(camera.yaw)) * m.cos(m.to_radians(camera.pitch))
	camera.front[1] = m.sin(m.to_radians(camera.pitch))
	camera.front[2] = m.sin(m.to_radians(camera.yaw)) * m.cos(m.to_radians(camera.pitch))
	camera.front = m.normalize(camera.front)
	camera.right = m.cross(camera.front, camera.up)
	camera.right = m.normalize(camera.right)
}

handle_camera_movement_keys :: proc() {
	if ctrl_pressed {
		return
	}
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
		camera.pos += camera.up * camera_movement
	}
	if glfw.GetKey(window, glfw.KEY_C) == glfw.PRESS {
		camera.pos -= camera.up * camera_movement
	}
}
