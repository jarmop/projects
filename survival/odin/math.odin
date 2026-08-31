package survival

import "core:math"
import "core:math/linalg"

sphere_points_d :: proc(r: f32, a: Vec3, b: Vec3) -> f32 {
	return r * math.acos((a.x * b.x + a.y * b.y + a.z * b.z) / math.pow(r, 2))
}

points_d_3 :: proc(a: Vec3, b: Vec3) -> f32 {
	return math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2) + math.pow(b.z - a.z, 2))
}

points_d_2 :: proc(a: Vec2, b: Vec2) -> f32 {
	return math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2))
}

points_d :: proc {
	points_d_2,
	points_d_3,
}

lat_length :: proc(lat: f32, equator_length: f32) -> f32 {
	return math.sin(lat) * equator_length
}
