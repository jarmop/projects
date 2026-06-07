package game

import "base:runtime"
import "core:fmt"
import m "core:math"
import l "core:math/linalg"
import gl "vendor:OpenGL"
import "vendor:glfw"

mouse_sensitivity :: 0.1
mouse_right_pressed := false
mouse_left_pressed := false
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

	if mode == glfw.MOD_CONTROL {
		ctrl_pressed = true
		if soldier_selected > -1 && key == glfw.KEY_S && action == glfw.PRESS {
			soldier_fire_at_will = !soldier_fire_at_will
		}
		return
	}

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
	} else if button == glfw.MOUSE_BUTTON_LEFT {
		if action == glfw.PRESS {
			if (soldier_selected == -1) {
				mouse_left_pressed = true
				glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
			}

			context = runtime.default_context()
			cursor_x, cursor_y := glfw.GetCursorPos(window)
			window_width, window_height := glfw.GetWindowSize(window)

			// Turn cursor coordinates into OpenGL normalized device coordinates
			// by changing their range from [0,1] to [-1,1]), and flipping y:
			x := f32(cursor_x / f64(window_width) * 2 - 1)
			y := -f32(cursor_y / f64(window_height) * 2 - 1)

			ray_clip := [4]f32{x, y, -1.0, 1.0}
			proj := l.matrix4_perspective_f32(
				l.to_radians(camera.fov),
				f32(window_width) / f32(window_height),
				camera.near,
				camera.far,
			)
			invp := l.inverse(proj) * ray_clip
			ray_eye := [4]f32{invp[0], invp[1], -1, 0}
			view := l.matrix4_look_at_f32(camera.pos, camera.pos + camera.front, camera.up)
			ray_world := l.normalize((l.inverse(view) * ray_eye).xyz)

			// SELECT CREATURE
			new_soldier_selected := false
			prev_d: f32 = 9999999
			for c, i in soldiers {
				bb := BoundingBox {
					min = c.pos,
					max = c.pos + CREATURE_DIMENSIONS,
				}
				d := hit_distance(bb, camera.pos, ray_world)
				if (d > 0 && d < prev_d) {
					soldier_selected = i
					new_soldier_selected = true
					prev_d = d
				}
			}
			if new_soldier_selected {
				return
			}

			// Check hit on ground if no hits on creatures
			if (soldier_selected > -1) {
				triangle_d: f32 = 0
				triangle_i := 0
				triangle: [3][3]f32
				// Get triangle hit distance
				min_t: f32 = m.INF_F32
				for ti := 0; ti < len(ground_vertices) / 3; ti += 1 {
					i := ti * 3
					v0 := ground_vertices[i + 0].pos
					v1 := ground_vertices[i + 1].pos
					v2 := ground_vertices[i + 2].pos

					t: f32 = 0
					if ray_triangle_intersect(camera.pos, ray_world, v0, v1, v2, &t) {
						min_t = min(min_t, t)
						if min_t != triangle_d {
							triangle_d = min_t
							triangle_i = ti
							triangle = {v0, v1, v2}
						}
					}
				}

				if (triangle_d > 0) {
					entry_point := camera.pos + ray_world * triangle_d
					target := entry_point - CREATURE_CENTER_XZ

					soldier := soldiers[soldier_selected]

					target_direction := l.normalize(target - soldier.pos)
					target_d := l.length(target - soldier.pos)

					soldier_sees_target := !wall_blocks_ray(
						soldier.pos + CREATURE_CENTER,
						target_direction,
						target_d,
					)

					if soldier_sees_target {
						start_triangle := get_triangle(soldier.pos)

						end_triangle := get_triangle(entry_point)
						funnel(soldier.pos, entry_point, start_triangle, end_triangle)

						// // This entry point provides a tricky corner case if
						// // used with soldier position "6.0, 0.0, 7.0"
						// e: [3]f32 = {8.5231419, 0.073619366, 4.2638073}
						// end_triangle := get_triangle(e)
						// funnel(soldier.pos, e, start_triangle, end_triangle)
					}
				} else {
					soldier_selected = -1
				}
			}
		} else {
			mouse_left_pressed = false
			first_hover = true
			glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_NORMAL)
		}
	}
}

first_hover := true

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, x, y: f64) {
	context = runtime.default_context()

	if mouse_right_pressed {
		drag_on_right_press(x, y)
	} else if mouse_left_pressed {
		drag_on_left_press(x, y)
	}
}

height_d := 0.0

drag_on_left_press :: proc(x, y: f64) {
	if first_hover {
		prev_cursor_y = y
		first_hover = false
	}

	height_d -= (y - prev_cursor_y) * 0.01
	step :: 0.1
	if (abs(height_d) > step) {
		height_map_pos.y += f32(height_d / abs(height_d) * step)
		height_map[int(height_map_pos.z)][int(height_map_pos.x)] = height_map_pos.y
		create_grid(ground_vertices[:])
		gl.BindVertexArray(ground_vao)
		gl.BindBuffer(gl.ARRAY_BUFFER, ground_vbo)
		gl.BufferData(
			gl.ARRAY_BUFFER,
			size_of(ground_vertices),
			raw_data(&ground_vertices),
			gl.STATIC_DRAW,
		)

		height_d = 0
	}


	prev_cursor_y = y
}

drag_on_right_press :: proc(x, y: f64) {
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
	camera.front[0] = l.cos(l.to_radians(camera.yaw)) * l.cos(l.to_radians(camera.pitch))
	camera.front[1] = l.sin(l.to_radians(camera.pitch))
	camera.front[2] = l.sin(l.to_radians(camera.yaw)) * l.cos(l.to_radians(camera.pitch))
	camera.front = l.normalize(camera.front)
	camera.right = l.cross(camera.front, camera.up)
	camera.right = l.normalize(camera.right)
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
