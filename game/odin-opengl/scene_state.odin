package game

playing := true
game_time: f32 = 0
game_time_delta: f32 = 0.0
game_time_speed: f32 = 1

// -------------- GROUND --------------

GROUND_SIZE :: 20.0
GROUND_CENTER :: [3]f32{GROUND_SIZE / 2, 0.0, GROUND_SIZE / 2}
GROUND_DIMENSIONS :: [3]f32{GROUND_SIZE, 0.5, GROUND_SIZE}
GROUND_POSITION :: [3]f32{0.0, -GROUND_DIMENSIONS.y, 0.0}
ground_vao: u32

// -------------- CREATURE --------------

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

// -------------- BULLET --------------

BULLET_DIMENSIONS :: [3]f32{0.1, 0.1, 0.1}
BULLET_SPEED :: 300.0
MIN_TIME_BETWEEN_SHOTS :: 1.0
BULLET_RANGE :: 500
HIT_CHECK_INTERVAL: f32 = 0.0
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
