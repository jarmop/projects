package game

Creature :: struct {
	pos:    [3]f32,
	target: [3]f32,
}

BoundingBox :: struct {
	min: [3]f32,
	max: [3]f32,
}

Camera :: struct {
	pos:   [3]f32,
	front: [3]f32,
	right: [3]f32,
	up:    [3]f32,
	yaw:   f32,
	pitch: f32,
	speed: f32,
	fov:   f32,
	near:  f32,
	far:   f32,
}

Vertex :: struct {
	pos:     [3]f32,
	normal:  [3]f32,
	texture: [2]f32,
}

Face :: struct {
	normal:    [3]f32,
	textures:  [6][2]f32,
	positions: [6][3]f32,
}
