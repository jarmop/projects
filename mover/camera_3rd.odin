package main

import "core:fmt"
import "core:math/linalg"

camera3rd_update_position :: proc() {
	// this is correct
	camera.pos = humanoid.position + humanoid.front * -5 + {0, 3, 0}

	camera.front = linalg.normalize(humanoid.position - camera.pos)
	// camera.front = linalg.normalize(humanoid.front)

	fmt.println("cam front:", camera.front)

	world_front: Vec3 = {0, 0, 1}
	world_up: Vec3 = {0, 1, 0}

	angle := linalg.dot(world_front, linalg.normalize(camera.front * {1, 0, 1}))

	angle2 := linalg.dot(world_up, camera.front * {0, 1, 0})

	camera.yaw = linalg.to_degrees(linalg.asin(angle))
	camera.pitch = linalg.to_degrees(linalg.asin(angle2))

	update_camera()
}
