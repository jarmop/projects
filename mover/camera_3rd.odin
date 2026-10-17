package main

import "core:fmt"
import "core:math/linalg"
camera3rd_update_position :: proc() {
	camera.pos = humanoid.position + humanoid.front * -5
	// camera.pos = humanoid.position + {0, 0, -5}
	// fmt.println(humanoid.position)
	// camera.front = {0, 0, 1}
	camera.front = linalg.normalize(humanoid.position - camera.pos)

	// fmt.println(humanoid.position - camera.pos)

	// fmt.println(camera.pos)
	// fmt.println(linalg.normalize(camera.pos))

	world_front: Vec3 = {0, 0, 1}
	world_up: Vec3 = {0, 1, 0}

	angle := linalg.dot(world_front, camera.front)
	angle2 := linalg.dot(world_up, camera.front)
	// angle := linalg.dot(Vec3{0, 0, 1}, Vec3{0, 0, 1})
	// angle2 := linalg.dot(Vec3{0, 0, 1}, Vec3{1, 0, 0})

	// camera.yaw = linalg.to_degrees(linalg.acos(angle))
	camera.yaw = linalg.to_degrees(linalg.asin(angle))
	camera.pitch = linalg.to_degrees(linalg.asin(angle2))

	// fmt.println()

	// fmt.println(camera.yaw)

	fmt.println(angle, angle2)
	// fmt.println(linalg.to_degrees(linalg.acos(angle)))
	// fmt.println(linalg.to_degrees(linalg.acos(angle2)))
	// fmt.println(linalg.to_degrees(linalg.asin(angle2)))


	update_camera()
}
