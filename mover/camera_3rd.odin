package main

import "base:runtime"
import "core:fmt"
import "core:math/linalg"
import "core:math/linalg/glsl"
import "vendor:glfw"

camera_d :: 5
camera_offset: Vec3

camera3rd_init :: proc() {
	camera.yaw = humanoid.yaw
	camera.pitch = -10
	// camera_offset = calculate_orbit_offset(camera.yaw, camera.pitch, camera_d)
}

calculate_orbit_offset :: proc(camera_yaw, camera_pitch, camera_distance: f32) -> Vec3 {
	fmt.println(camera_yaw)
	fmt.println(camera_pitch)

	yaw_r := linalg.to_radians(camera_yaw)
	pitch_r := linalg.to_radians(camera_pitch)

	fmt.println()

	return {0, 2, -8}
}

camera3rd_update_position :: proc() {
	camera_offset = calculate_orbit_offset(camera.yaw, camera.pitch, camera_d)

	camera.pos = humanoid.position + rotate_vector(humanoid.yaw, camera_offset)
}

rotate_vector :: proc(yaw: f32, pos: Vec3) -> Vec3 {
	y_axis := Vec3{0, 1, 0}
	model := glsl.mat4Rotate(y_axis, linalg.to_radians(yaw))

	v := (model * Vec4{pos.x, pos.y, pos.z, 1}).xyz

	return v
}

camera_3rd_get_view :: proc() -> Mat4 {
	view: Mat4 = 1
	target := humanoid.position + Vec3{0, 1.5, 0}
	view *= glsl.mat4LookAt(camera.pos, target, camera.up)

	return view
}

// rotate_dir: f32 = 1

camera_3rd_handle_frame :: proc() {
	camera_d := time_delta * camera.speed

	if glfw.GetKey(window, glfw.KEY_LEFT_CONTROL) == glfw.PRESS {
		return
	}

	playing = false

	rotate_dir: f32 = 1

	// WASD
	if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {
		playing = true
		humanoid.position += humanoid.front * camera_d
		// rotate_dir = 1
	}
	if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS {
		playing = true
		humanoid.position -= humanoid.front * camera_d
		// Rotate the other way if on reverse
		rotate_dir = -1
	}

	angle_increment := camera_d * 20 * rotate_dir

	if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {
		playing = true
		humanoid.yaw += angle_increment
		update_humanoid_orientation(&humanoid)
	}
	if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS {
		playing = true
		humanoid.yaw -= angle_increment
		update_humanoid_orientation(&humanoid)
	}

	// camera3rd_update_position()
}

movement_keys: []i32 : {glfw.KEY_W, glfw.KEY_A, glfw.KEY_S, glfw.KEY_D}

camera_3rd_key_callback :: proc(key, action, mode: i32) {
	// if key == glfw.KEY_W || key == glfw.KEY_A || key == glfw.KEY_S || key == glfw.KEY_D {
	// 	if action == glfw.PRESS {
	// 		playing = true
	// 	} else if action == glfw.RELEASE {
	// 		playing = false
	// 	}
	// 	fmt.println(playing)
	// }

}

camera_3rd_cursor_pos_callback :: proc "c" (xf64: f64, yf64: f64) {
	context = runtime.default_context()

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
