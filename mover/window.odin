package main

import "base:runtime"
import "core:fmt"
import "core:math"
import l "core:math/linalg"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"

WINDOW_WIDTH: i32 = 800
WINDOW_HEIGHT: i32 = 600

mouse_sensitivity :: 0.1

Camera :: struct {
	pos:   Vec3,
	front: Vec3,
	right: Vec3,
	up:    Vec3,
	yaw:   f32,
	pitch: f32,
	speed: f32,
	fov:   f32,
	near:  f32,
	far:   f32,
}

camera := Camera {
	pos   = humanoid_position.whole + {-4, 0, 0},
	front = {0, 0, -1},
	right = {1, 0, 0},
	up    = {0, 1, 0},
	yaw   = 0,
	pitch = 0,
	speed = 2.5,
	fov   = 45,
	near  = 0.1,
	far   = 100,
}

prev_cursor_x: f32 = 800 / 2
prev_cursor_y: f32 = 600 / 2

window: glfw.WindowHandle

mouse_right_pressed := false
mouse_left_pressed := false
first_cursor_pos := true

CameraMode :: enum {
	Basic,
	Camera_3rd,
}

camera_mode: CameraMode = .Camera_3rd

window_init :: proc() {
	glfw.Init()
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.SAMPLES, 4)

	window = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Mover", nil, nil)
	if window == nil {
		fmt.println("Failed to create GLFW window")
		glfw.Terminate()
		os.exit(-1)
	}
	glfw.MakeContextCurrent(window)

	gl.load_up_to(3, 3, glfw.gl_set_proc_address)

	gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
	glfw.SetCursorPosCallback(window, cursor_pos_callback)
	glfw.SetMouseButtonCallback(window, mouse_button_callback)
	glfw.SetScrollCallback(window, scroll_callback)
	glfw.SetKeyCallback(window, key_callback)

	update_camera()
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	context = runtime.default_context()

	if action != glfw.PRESS {
		return
	}

	if key == glfw.KEY_ESCAPE {
		glfw.SetWindowShouldClose(window, true)

	} else if key == glfw.KEY_SPACE {
		playing = !playing

	} else if key == glfw.KEY_S && mode == glfw.MOD_CONTROL {
		angles := make([]HumanoidJointAngles, 4)
		defer delete(angles)
		for i in 0 ..< 4 {
			// angles[i] = {
			// 	torso           = h.parts[0].rotation_angle,
			// 	head            = h.parts[13].rotation_angle,
			// 	right_upper_arm = h.parts[7].rotation_angle,
			// 	right_forearm   = h.parts[8].rotation_angle,
			// 	right_hand      = h.parts[9].rotation_angle,
			// 	left_upper_arm  = h.parts[10].rotation_angle,
			// 	left_forearm    = h.parts[11].rotation_angle,
			// 	left_hand       = h.parts[12].rotation_angle,
			// 	right_thigh     = h.parts[1].rotation_angle,
			// 	right_shin      = h.parts[2].rotation_angle,
			// 	right_foot      = h.parts[3].rotation_angle,
			// 	left_thigh      = h.parts[4].rotation_angle,
			// 	left_shin       = h.parts[5].rotation_angle,
			// 	left_foot       = h.parts[6].rotation_angle,
			// }
			h := animation.poses[i]
			angles[i] = {
				torso           = l.to_degrees(h.parts[0].rotation_angle),
				head            = l.to_degrees(h.parts[13].rotation_angle),
				right_upper_arm = l.to_degrees(h.parts[7].rotation_angle),
				right_forearm   = l.to_degrees(h.parts[8].rotation_angle),
				right_hand      = l.to_degrees(h.parts[9].rotation_angle),
				left_upper_arm  = l.to_degrees(h.parts[10].rotation_angle),
				left_forearm    = l.to_degrees(h.parts[11].rotation_angle),
				left_hand       = l.to_degrees(h.parts[12].rotation_angle),
				right_thigh     = l.to_degrees(h.parts[1].rotation_angle),
				right_shin      = l.to_degrees(h.parts[2].rotation_angle),
				right_foot      = l.to_degrees(h.parts[3].rotation_angle),
				left_thigh      = l.to_degrees(h.parts[4].rotation_angle),
				left_shin       = l.to_degrees(h.parts[5].rotation_angle),
				left_foot       = l.to_degrees(h.parts[6].rotation_angle),
			}
		}
		save(angles)

	} else if key == glfw.KEY_LEFT || key == glfw.KEY_RIGHT {
		increment := key == glfw.KEY_LEFT ? -1 : 1
		current_pose += increment
		if current_pose < 0 {
			current_pose = len(animation.poses) - 1
		} else if current_pose > len(animation.poses) - 1 {
			current_pose = 0
		}
		// current_pose = current_pose < len(animation.poses) - 1 ? current_pose + increment : 0
		humanoid = &animation.poses[current_pose]

	} else if key >= glfw.KEY_1 && key <= glfw.KEY_4 {
		current_pose = int(key - glfw.KEY_1)
		humanoid = &animation.poses[current_pose]
	} else if key == glfw.KEY_C {

	}
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
	gl.Viewport(0, 0, width, height)
	WINDOW_WIDTH = width
	WINDOW_HEIGHT = height
}

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, xf64: f64, yf64: f64) {
	context = runtime.default_context()

	if mouse_left_pressed {
		if selected_body_part == -1 {
			return
		}

		x := f32(xf64)
		y := f32(yf64)

		if first_cursor_pos {
			prev_cursor_x = x
			prev_cursor_y = y
			first_cursor_pos = false
		}

		bp := &humanoid.parts[selected_body_part]

		// deg_diff := (x - prev_cursor_x) * humanoid_front.x * camera.front.x
		deg_diff := (x - prev_cursor_x)

		bp.rotation_angle = bp.rotation_angle + l.to_radians(deg_diff)

		for &bp, i in humanoid.parts {
			humanoid.bbs[i] = get_bb(humanoid, &bp)
		}

		prev_cursor_x = x
		prev_cursor_y = y

	} else if mouse_right_pressed {
		x := f32(xf64)
		y := f32(yf64)

		if first_cursor_pos {
			prev_cursor_x = x
			prev_cursor_y = y
			first_cursor_pos = false
		}

		camera.yaw += f32((x - prev_cursor_x) * mouse_sensitivity)
		if (camera.yaw > 180) {
			camera.yaw -= 360
		} else if (camera.yaw < -180) {
			camera.yaw += 360
		}
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
}

mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()

	if button == glfw.MOUSE_BUTTON_LEFT {
		if action == glfw.PRESS {
			mouse_left_pressed = true
			check_body_part_hit()
		} else {
			mouse_left_pressed = false
			first_cursor_pos = true
		}
	} else if button == glfw.MOUSE_BUTTON_RIGHT {
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

scroll_callback := proc "c" (window: glfw.WindowHandle, xoffset: f64, yoffset: f64) {
	camera.fov -= f32(yoffset)
	if camera.fov < 1 {
		camera.fov = 1
	}
	if camera.fov > 45 {
		camera.fov = 45
	}
}

handle_camera_movement_keys :: proc() {
	camera_d := time_delta * camera.speed

	if glfw.GetKey(window, glfw.KEY_LEFT_CONTROL) == glfw.PRESS {
		return
	}

	// WASD
	if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {
		camera.pos += camera.front * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS {
		camera.pos -= camera.front * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {
		camera.pos -= camera.right * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS {
		camera.pos += camera.right * camera_d
	}

	// Elevation
	if glfw.GetKey(window, glfw.KEY_E) == glfw.PRESS {
		camera.pos += camera.up * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_C) == glfw.PRESS {
		camera.pos -= camera.up * camera_d
	}
}

update_camera :: proc() {
	camera.front[0] = l.cos(l.to_radians(camera.yaw)) * l.cos(l.to_radians(camera.pitch))
	camera.front[1] = l.sin(l.to_radians(camera.pitch))
	camera.front[2] = l.sin(l.to_radians(camera.yaw)) * l.cos(l.to_radians(camera.pitch))
	camera.front = l.normalize(camera.front)
	camera.right = l.cross(camera.front, camera.up)
	camera.right = l.normalize(camera.right)
}

check_body_part_hit :: proc() {
	ray := get_ray()
	min_triangle_d: f32 = math.F32_MAX
	for bp, i in humanoid.parts {
		bb := humanoid.bbs[i]
		bb_d := hit_distance(bb, camera.pos, ray)
		if bb_d > 0 {
			triangle_d: f32 = 0
			triangle_i := 0
			triangle: [3][3]f32
			min_t: f32 = math.INF_F32
			model := get_bp_model(&humanoid.parts[i])

			for ti := 0; ti < len(box_vertices) / 3; ti += 1 {
				i := ti * 3
				v0 := box_vertices[i + 0].pos
				v1 := box_vertices[i + 1].pos
				v2 := box_vertices[i + 2].pos
				v0 = (model * Vec4{v0.x, v0.y, v0.z, 1}).xyz
				v1 = (model * Vec4{v1.x, v1.y, v1.z, 1}).xyz
				v2 = (model * Vec4{v2.x, v2.y, v2.z, 1}).xyz
				t: f32 = 0
				if ray_triangle_intersect(camera.pos, ray, v0, v1, v2, &t) {
					min_t = min(min_t, t)

					if min_t != triangle_d {
						triangle_d = min_t
						triangle_i = ti
						triangle = {v0, v1, v2}
					}
				}
			}

			if triangle_d != 0 && triangle_d < min_triangle_d {
				min_triangle_d = triangle_d
				selected_body_part = i
			}
		}
	}
}
