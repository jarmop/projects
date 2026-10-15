package main

import l "core:math/linalg"
import "vendor:glfw"
BoundingBox :: struct {
	min: [3]f32,
	max: [3]f32,
}

hit_distance :: proc(bb: BoundingBox, ray_start: [3]f32, ray_direction: [3]f32) -> f32 {
	// Get the distances where the ray enters and exits the bounding box on each axis
	dmin := (bb.min - ray_start) / ray_direction
	dmax := (bb.max - ray_start) / ray_direction

	// Get the distances where the ray enters and exits the bounding box
	d_to_entry := max(min(dmin.x, dmax.x), min(dmin.y, dmax.y), min(dmin.z, dmax.z))
	d_to_exit := min(max(dmin.x, dmax.x), max(dmin.y, dmax.y), max(dmin.z, dmax.z))

	return d_to_entry if d_to_entry < d_to_exit else 0
}

get_ray :: proc() -> Vec3 {
	cursor_x, cursor_y := glfw.GetCursorPos(window)
	window_width, window_height := glfw.GetWindowSize(window)

	// Turn cursor coordinates into OpenGL normalized device coordinates
	// by changing their range from [0,1] to [-1,1]), and flipping y:
	x := f32(cursor_x / f64(window_width) * 2 - 1)
	y := -f32(cursor_y / f64(window_height) * 2 - 1)

	ray_clip := [4]f32{x, y, -1.0, 1.0}
	proj := l.matrix4_perspective_f32(
		l.to_radians(camera.fov),
		f32(window_width) / f32(window_height),
		camera.near,
		camera.far,
	)
	invp := l.inverse(proj) * ray_clip
	ray_eye := [4]f32{invp[0], invp[1], -1, 0}
	view := l.matrix4_look_at_f32(camera.pos, camera.pos + camera.front, camera.up)
	ray_world := l.normalize((l.inverse(view) * ray_eye).xyz)

	return ray_world
}

// The smallest possible difference between two floating point numbers that the computer can recognize
EPSILON :: 0.000001

ray_triangle_intersect :: proc(
	ray_origin: [3]f32,
	ray_dir: [3]f32, // should be normalized
	v0: [3]f32,
	v1: [3]f32,
	v2: [3]f32,
	t: ^f32,
) -> bool {
	edge1 := v1 - v0
	edge2 := v2 - v0

	h := l.cross(ray_dir, edge2)
	a := l.dot(edge1, h)

	if abs(a) < EPSILON {
		// Ray is parallel to the triangle
		return false
	}

	f := 1.0 / a

	s := ray_origin - v0
	u := f * l.dot(s, h)

	if u < 0.0 || u > 1.0 {
		return false
	}

	q := l.cross(s, edge1)
	v := f * l.dot(ray_dir, q)

	if v < 0.0 || (u + v) > 1.0 {
		return false
	}

	hit_t := f * l.dot(edge2, q)

	if hit_t <= EPSILON {
		// Triangle is behind the ray origin
		return false
	}

	t^ = hit_t

	return true
}
