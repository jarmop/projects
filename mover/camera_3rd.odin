package main

import "core:fmt"
import "core:math/linalg"
import "core:math/linalg/glsl"

camera3rd_update_position :: proc() {
	camera_offset := Vec3{0, 2, -5}

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
