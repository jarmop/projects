package game

playing := true
game_time: f32 = 0
game_time_delta: f32 = 0.0
game_time_speed: f32 = 1

// -------------- GROUND --------------

y: f32 = 0.5

GRID_COUNT :: 5
height_map := [GRID_COUNT + 1][GRID_COUNT + 1]f32 {
	{0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0},
	{0, 0, y, y, 0, 0},
	{0, 0, y, y, 0, 0},
	{0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0},
}

// GRID_COUNT :: 20
// height_map := [GRID_COUNT + 1][GRID_COUNT + 1]f32 {
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, y, y, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, y, y, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// }

// height_map := [GRID_COUNT + 1][GRID_COUNT + 1]f32 {
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.4, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1.2, 0.4, 0.3, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.2, 3.5, 0.6, 0.2, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0.2, 0.3, 1, 3.1, 4.5, 1, 0.7, 0.3, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 2.4, 5.7, 4.3, 2.5, 0.2, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 3.2, 4.5, 4, 3.9, 1.6, 0.2, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0.7, 1, 2.4, 3.7, 4.6, 2.4, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0.4, 0.5, 1, 2.3, 2.3, 1.2, 1, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.2, 1, 2.1, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.5, 1, 0, 0, 0, 0, 0, 0, 0, 0},
// 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
// }

GRID_SIZE :: 1.0
GROUND_SIZE :: GRID_COUNT * GRID_SIZE
GROUND_CENTER :: [3]f32{GROUND_SIZE / 2, 0.0, GROUND_SIZE / 2}
GROUND_DIMENSIONS :: [3]f32{GROUND_SIZE, 0.01, GROUND_SIZE}
GROUND_POSITION :: [3]f32{0.0, -GROUND_DIMENSIONS.y, 0.0}

GROUND_BB := BoundingBox {
	min = GROUND_POSITION,
	max = GROUND_POSITION + GROUND_DIMENSIONS,
}

GRID_BBS: [GRID_COUNT * GRID_COUNT]BoundingBox

ground_vao: u32
ground_vertices: [GRID_COUNT * GRID_COUNT * 12]Vertex

// -------------- WALL --------------
WALL_X_DIMENSIONS :: [3]f32{1.2, 2.0, 0.2}
WALL_Z_DIMENSIONS :: [3]f32{0.2, 2.0, 1.2}
WALL_X_CENTER := WALL_X_DIMENSIONS / 2
WALL_Z_CENTER := WALL_Z_DIMENSIONS / 2
wall_x_vao: u32
wall_z_vao: u32
walls_x := []Wall {
	// {pos = {-0.1 + GRID_SIZE * 10, 0, -0.1 + GRID_SIZE * 10}},
	// {pos = {-0.1 + GRID_SIZE * 11, 0, -0.1 + GRID_SIZE * 10}},
	// {pos = {-0.1 + GRID_SIZE * 12, 0, -0.1 + GRID_SIZE * 10}},
	// {pos = {-0.1 + GRID_SIZE * 13, 0, -0.1 + GRID_SIZE * 10}},
	// {pos = {-0.1 + GRID_SIZE * 10, 0, -0.1 + GRID_SIZE * 14}},
	// {pos = {-0.1 + GRID_SIZE * 11, 0, -0.1 + GRID_SIZE * 14}},
	// {pos = {-0.1 + GRID_SIZE * 12, 0, -0.1 + GRID_SIZE * 14}},
	// {pos = {-0.1 + GRID_SIZE * 13, 0, -0.1 + GRID_SIZE * 14}},
}
walls_z := []Wall {
	// {pos = {-0.1 + GRID_SIZE * 14, 0, -0.1 + GRID_SIZE * 10}},
	// {pos = {-0.1 + GRID_SIZE * 14, 0, -0.1 + GRID_SIZE * 11}},
	// {pos = {-0.1 + GRID_SIZE * 14, 0, -0.1 + GRID_SIZE * 12}},
	// {pos = {-0.1 + GRID_SIZE * 14, 0, -0.1 + GRID_SIZE * 13}},
	// {pos = {-0.1 + GRID_SIZE * 10, 0, -0.1 + GRID_SIZE * 10}},
	// {pos = {-0.1 + GRID_SIZE * 10, 0, -0.1 + GRID_SIZE * 11}},
	// {pos = {-0.1 + GRID_SIZE * 10, 0, -0.1 + GRID_SIZE * 12}},
	// {pos = {-0.1 + GRID_SIZE * 10, 0, -0.1 + GRID_SIZE * 13}},
}

// -------------- CREATURE --------------

CREATURE_DIMENSIONS :: [3]f32{0.5, 1.74, 0.23}
CREATURE_CENTER := CREATURE_DIMENSIONS / 2
CREATURE_CENTER_XZ :: [3]f32{(CREATURE_DIMENSIONS.x / 2), 0, (CREATURE_DIMENSIONS.z / 2)}
CREATURE_COLOR :: [3]f32{1.0, 0.6, 0.2}
CREATURE_COLOR_SELECTED :: [3]f32{0.0, 0.0, 1.0}
CREATURE_COLOR_SHOOTING :: [3]f32{1.0, 0.0, 0.0}
CREATURE_COLOR_TARGET :: [3]f32{0.0, 1.0, 0.0}
CREATURE_SPEED :: 2.0
creature_vao: u32

// -------------- SOLDIER --------------
soldiers := []Creature{{pos = {0.0, 0.0, 0.0}}}
soldier_selected := 0
soldier_fire_at_will := false
soldier_dead := false

// -------------- ENEMY --------------
ENEMY_COUNT_INITIAL :: 0
ENEMY_COUNT_MAX :: 0
ENEMY_SPAWN_RATE :: 1
enemies: [dynamic]Creature
enemy_spawn_prev_time: f32 = 0
enemy_attack := false

// -------------- CORPSE --------------
CORPSE_DIMENSIONS :: [3]f32{1.0, 0.01, 1.0}
CORPSE_CENTER := CORPSE_DIMENSIONS / 2
CORPSE_CENTER_XZ :: [3]f32{(CORPSE_DIMENSIONS.x / 2), 0, (CORPSE_DIMENSIONS.z / 2)}

corpses: [dynamic][3]f32
corpse_vao: u32

// -------------- BULLET --------------

BULLET_DIMENSIONS :: [3]f32{0.1, 0.1, 0.1}
BULLET_SPEED :: 300.0
MIN_TIME_BETWEEN_SHOTS :: 1.0
BULLET_RANGE :: 500
// HIT_CHECK_INTERVAL: f32 = 0.0
BULLET_CENTER := BULLET_DIMENSIONS / 2
bullet_vao: u32

BULLETS_MAX :: 1000
BULLET_BUFFERS_MAX :: 2
bullet_buffer_index := 0
bullet_buffers: [BULLET_BUFFERS_MAX][BULLETS_MAX]Bullet
bullet_nexts: [BULLET_BUFFERS_MAX]int
bul_fill := &bullet_buffers[bullet_buffer_index]
bul_fill_next := &bullet_nexts[bullet_buffer_index]
bul_check := &bullet_buffers[(bullet_buffer_index + 1) % BULLET_BUFFERS_MAX]
bul_check_next := &bullet_nexts[(bullet_buffer_index + 1) % BULLET_BUFFERS_MAX]

// ---------- BULLET PATH -----------

BULLET_PATH_COLOR :: [3]f32{1.0, 0.8, 0.4}
BULLET_PATH_WIDTH :: 1.0
bullet_path_vertex_next := 0
// Two vertices per bullet
bullet_path_vertices: [2 * BULLETS_MAX]BulletVertex
bullet_path_vao: u32
bullet_path_vbo: u32

// -------------- PATH --------------

PATH_COLOR :: [3]f32{1.0, 1.0, 1.0}
PATH_WIDTH :: 3.0
PATH_VERTEX_COUNT :: 2
path_vao: u32
path_vbo: u32
