package game

import glfw "vendor:glfw"

// -------------- MAIN --------------

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

window: glfw.WindowHandle

time_prev_frame: f32 = 0.0
time_now: f32 = 0.0

// -------------- SCENE --------------

scene_shader_program: u32

GROUND_SIZE :: 20.0
GROUND_CENTER :: [3]f32{GROUND_SIZE / 2, 0.0, GROUND_SIZE / 2}
GROUND_DIMENSIONS :: [3]f32{GROUND_SIZE, 0.5, GROUND_SIZE}
GROUND_POSITION :: [3]f32{0.0, -GROUND_DIMENSIONS.y, 0.0}
ground_vao: u32

CREATURE_DIMENSIONS :: [3]f32{0.5, 0.5, 0.5}
CREATURE_CENTER_XZ :: [3]f32{(CREATURE_DIMENSIONS.x / 2), 0, (CREATURE_DIMENSIONS.z / 2)}
CREATURE_COLOR :: [3]f32{1.0, 0.6, 0.2}
CREATURE_COLOR_SELECTED :: [3]f32{0.0, 0.0, 1.0}
creature_vao: u32
creatures := []Creature {
	{pos = GROUND_CENTER - {5.0, 0.0, 0.0}},
	{pos = GROUND_CENTER + {5.0, 0.0, 0.0}},
}
selected_creature := -1

PATH_COLOR :: [3]f32{1.0, 1.0, 1.0}
PATH_WIDTH :: 3.0
PATH_VERTEX_COUNT :: 2
path_vao: u32
path_vbo: u32

playing := false

// -------------- IO --------------

mouse_sensitivity :: 0.1
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
mouse_right_pressed := false
first_cursor_pos := true
prev_cursor_x, prev_cursor_y: f64

// -------------- MODEL --------------

CUBOID_VERTEX_COUNT :: 36
