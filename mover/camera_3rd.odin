package main

import "core:fmt"
import "core:math/linalg"
camera3rd_update_position :: proc() {
	// camera.pos = humanoid.position + humanoid.front
	camera.pos = humanoid.position + {0, 0, -5}
	fmt.println(humanoid.position)
	// camera.front = {0, 0, 1}

	// fmt.println(camera.pos)
	// fmt.println(linalg.normalize(camera.pos))

	front_0: Vec3 = {0, 0, 1}

	angle := linalg.dot(front_0, camera.front)
	// angle := linalg.dot(Vec3{0, 0, 1}, Vec3{0, 0, 1})
	// angle2 := linalg.dot(Vec3{0, 0, 1}, Vec3{1, 0, 0})

	camera.yaw = linalg.to_degrees(linalg.acos(angle))

	fmt.println(camera.yaw)

	// fmt.println(angle, angle2)
	// fmt.println(linalg.to_degrees(linalg.acos(angle)))
	// fmt.println(linalg.to_degrees(linalg.acos(angle2)))


	update_camera()
}
