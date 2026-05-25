package game

import glfw "vendor:glfw"

// -------------- MAIN --------------

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

window: glfw.WindowHandle

time_now: f32 = 0.0
time_prev_frame: f32 = 0.0
time_delta: f32

// -------------- SCENE --------------

playing := true
game_time: f32 = 0
game_time_delta: f32 = 0.0
game_time_speed: f32 = 1

GROUND_SIZE :: 20.0
GROUND_CENTER :: [3]f32{GROUND_SIZE / 2, 0.0, GROUND_SIZE / 2}
GROUND_DIMENSIONS :: [3]f32{GROUND_SIZE, 0.5, GROUND_SIZE}
GROUND_POSITION :: [3]f32{0.0, -GROUND_DIMENSIONS.y, 0.0}
ground_vao: u32

// CREATURE_DIMENSIONS :: [3]f32{0.46, 1.43, 0.23}
CREATURE_DIMENSIONS :: [3]f32{0.5, 1.74, 0.23}
CREATURE_CENTER := CREATURE_DIMENSIONS / 2
CREATURE_CENTER_XZ :: [3]f32{(CREATURE_DIMENSIONS.x / 2), 0, (CREATURE_DIMENSIONS.z / 2)}
CREATURE_COLOR :: [3]f32{1.0, 0.6, 0.2}
CREATURE_COLOR_SELECTED :: [3]f32{0.0, 0.0, 1.0}
CREATURE_COLOR_SHOOTING :: [3]f32{1.0, 0.0, 0.0}
CREATURE_COLOR_TARGET :: [3]f32{0.0, 1.0, 0.0}
CREATURE_SPEED :: 1.0

creature_vao: u32
creatures := []Creature {
	{pos = GROUND_CENTER - {5.0, 0.0, 0.0}},
	{pos = GROUND_CENTER + {5.0, 0.0, 0.0}},
}
creature_selected := 0
creature_shooting := 0
creature_target := 1

BULLET_DIMENSIONS :: [3]f32{0.1, 0.1, 0.1}
BULLET_SPEED :: 300.0
MIN_TIME_BETWEEN_SHOTS :: 1.0
BULLET_RANGE :: 1000
HIT_CHECK_INTERVAL: f32 = 0.1
BULLET_CENTER := BULLET_DIMENSIONS / 2
bullet_vao: u32
bullets: [dynamic]Bullet

PATH_COLOR :: [3]f32{1.0, 1.0, 1.0}
PATH_WIDTH :: 3.0
PATH_VERTEX_COUNT :: 2
path_vao: u32
path_vbo: u32

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
