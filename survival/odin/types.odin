package survival

Vec4 :: [4]f32
Vec3 :: [3]f32
Vec2 :: [2]f32
Mat4 :: matrix[4, 4]f32

Vertex :: struct {
	position: Vec3,
	uv:       Vec2,
}

Mesh :: struct {
	vertices: []Vertex,
	indices:  []u32,
}

LandRow :: struct {
	ring:    int,
	segment: int,
	width:   int,
}

Land :: struct {
	ring:    int,
	segment: int,
	slices:  []LandRow,
}
