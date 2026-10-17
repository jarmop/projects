package main

import "core:fmt"
import "core:math/linalg"
import "core:math/linalg/glsl"
import "vendor:glfw"

camera_offset: Vec3 : {0, 2, -8}

camera3rd_update_position :: proc() {

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

	camera3rd_update_position()
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
