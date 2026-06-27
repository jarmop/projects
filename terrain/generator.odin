package terrain

import "core:math"
import "core:math/linalg"

height_map: [vertices_per_side * vertices_per_side]f32
size :: vertices_per_side
min_height: f32 = 0
max_height: f32 = 250

generate_data :: proc() {
	// create_fault_formation()
	create_midpoint_displacement()

	normalize_height_map()

	// Fill vertices
	index := 0
	for z := 0; z < vertices_per_side; z += 1 {
		for x := 0; x < vertices_per_side; x += 1 {
			f := height_map[z * vertices_per_side + x]
			// f: f32 = 0.0
			vertices[index] = {
				pos = {f32(x) * scale, f, f32(z) * scale},
				// uv  = {f32(x), f32(z)},
				// uv  = {f32(x) / f32(vertices_per_side), f32(z) / f32(vertices_per_side)},
				uv  = {
					f32(x) * scale / f32(vertices_per_side),
					f32(z) * scale / f32(vertices_per_side),
				},
			}
			index += 1
		}
	}

	// Fill indices
	index = 0
	for z: u32 = 0; z < quads_per_side; z += 1 {
		for x: u32 = 0; x < quads_per_side; x += 1 {
			top_left := z * vertices_per_side + x
			top_right := z * vertices_per_side + x + 1
			bottom_left := (z + 1) * vertices_per_side + x
			bottom_right := (z + 1) * vertices_per_side + x + 1

			indices[index] = top_left
			indices[index + 1] = top_right
			indices[index + 2] = bottom_right
			indices[index + 3] = bottom_right
			indices[index + 4] = bottom_left
			indices[index + 5] = top_left

			index += 6
		}
	}

	calculate_normals()
}

normalize_height_map :: proc() {
	min_h: f32 = math.INF_F32
	max_h: f32 = 0
	for h in height_map {
		min_h = math.min(h, min_h)
		max_h = math.max(h, max_h)
	}

	for &h in height_map {
		h = (h - min_h) / (max_h - min_h) * max_height
	}
}

calculate_normals :: proc() {
	for i := 0; i < indices_count; i += 3 {
		i0 := indices[i]
		i1 := indices[i + 1]
		i2 := indices[i + 2]
		v0 := &vertices[i0]
		v1 := &vertices[i1]
		v2 := &vertices[i2]
		normal := -linalg.normalize(linalg.cross(v1.pos - v0.pos, v2.pos - v0.pos))
		v0.normal = normal
		v1.normal = normal
		v2.normal = normal
	}
}
