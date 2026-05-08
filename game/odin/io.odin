package game

import "vendor:glfw"

Camera :: struct {
	pos:   [3]f32,
	front: [3]f32,
	right: [3]f32,
	yaw:   f32,
	pitch: f32,
	speed: f32,
	fov:   f32,
}

camera := Camera {
	pos   = {0.0, 0.0, 2.0},
	front = {0.0, 0.0, -1.0},
	right = {1.0, 0.0, 0.0},
	yaw   = -90.0,
	pitch = 0.0,
	speed = 2.5,
	fov   = 45.0,
}

worldUp := [3]f32{0.0, 1.0, 0.0}

key_callback :: proc "c" (
	window: glfw.WindowHandle,
	key: i32,
	scancode: i32,
	action: i32,
	mode: i32,
) {
	if (key == glfw.KEY_ESCAPE && action == glfw.PRESS) {
		glfw.SetWindowShouldClose(window, true)
	}
}
