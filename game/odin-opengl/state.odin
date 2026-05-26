package game

import glfw "vendor:glfw"

// -------------- MAIN --------------

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

window: glfw.WindowHandle

time_now: f32 = 0.0
time_prev_frame: f32 = 0.0
time_delta: f32

// -------------- IO --------------

camera := Camera {
	pos   = GROUND_CENTER + {0.0, 6.0, 12.0},
	front = {0.0, 0.0, -1.0},
	right = {1.0, 0.0, 0.0},
	up    = {0.0, 1.0, 0.0},
	yaw   = -90.0,
	pitch = -25.0,
	speed = 5.0,
	fov   = 45.0,
	near  = 0.1,
	far   = 1000.0,
}

// -------------- MODEL --------------

CUBOID_VERTEX_COUNT :: 36
