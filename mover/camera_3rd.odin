package main

import "core:fmt"
import "core:math/linalg"
import "core:math/linalg/glsl"

// camera3rd_update_position :: proc() {
// 	// this is correct
// 	camera.pos = humanoid.position + humanoid.front * -5 + {0, 3, 0}
// 	// camera.pos = humanoid.position + humanoid.front * -5

// 	fmt.println("------------------")
// 	fmt.println(humanoid.position, camera.pos)

// 	camera.front = linalg.normalize(humanoid.position - camera.pos)
// 	// camera.front = linalg.normalize(humanoid.front)

// 	fmt.println("cam front:", camera.front)

// 	// fmt.println

// 	// world_front: Vec3 = {0, 0, 1}
// 	world_front: Vec3 = {1, 0, 0}
// 	world_up: Vec3 = {0, 1, 0}

// 	angle := linalg.dot(world_front, linalg.normalize(camera.front * {1, 0, 1}))
// 	// angle := linalg.dot(world_front, linalg.normalize(camera.front))
// 	// angle := linalg.dot(world_front, camera.front)

// 	angle2 := linalg.dot(world_up, camera.front * {0, 1, 0})

// 	yaw := linalg.to_degrees(linalg.acos(angle))
// 	pitch := linalg.to_degrees(linalg.asin(angle2))

// 	fmt.println(yaw, pitch)

// 	camera.yaw = yaw
// 	camera.pitch = pitch

// 	// camera.yaw = linalg.to_degrees(linalg.asin(angle))
// 	// camera.pitch = linalg.to_degrees(linalg.asin(angle2))

// 	update_camera()
// }

camera3rd_update_position :: proc() {
	camera_offset := Vec3{0, 2, -5}
	// camera_offset := Vec3{-5, 2, 0}

	// camera_position := humanoid.position + rotate_vector(humanoid.yaw, camera_offset)
	camera.pos = humanoid.position + rotate_vector(humanoid.yaw, camera_offset)
	// camera.pos = camera_offset
	camera.yaw = 90 - humanoid.yaw
	// camera.yaw = 90

	update_camera()

	target := humanoid.position + Vec3{0, 1.5, 0}

}

// Make sure yaw is in radians!!!

rotate_vector :: proc(yaw: f32, pos: Vec3) -> Vec3 {
	y_axis := Vec3{0, 1, 0}
	model := glsl.mat4Rotate(y_axis, linalg.to_radians(yaw))

	v := (model * Vec4{pos.x, pos.y, pos.z, 1}).xyz

	return v
}
