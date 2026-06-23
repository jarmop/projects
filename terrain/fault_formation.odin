package terrain

import "core:math/linalg"
import "core:math/rand"

iterations := 500
filter: f32 = 0.5

create_fault_formation :: proc() {
	min_max_d := max_height - min_height

	for i in 0 ..< iterations {
		iteration_ratio := f32(i) / f32(iterations)
		height_increment := max_height - iteration_ratio * min_max_d

		fault_line_start, fault_line_end := get_random_terrain_points()
		fault_line := fault_line_end - fault_line_start

		index := 0
		for z := 0; z < size; z += 1 {
			for x := 0; x < size; x += 1 {
				p: [3]f32 = {f32(x), 0, f32(z)}

				if linalg.cross(fault_line, p - fault_line_start).y > 0 {
					height_map[z * size + x] += height_increment
				}

				index += 3
			}
		}
	}

	apply_fir_filter()
}

get_random_terrain_points :: proc() -> ([3]f32, [3]f32) {
	p1: [3]f32 = {rand.float32_range(0, size), 0, rand.float32_range(0, size)}

	p2: [3]f32 = {rand.float32_range(0, size), 0, rand.float32_range(0, size)}

	return p1, p2
}

apply_fir_filter :: proc() {
	// left to right
	for z in 0 ..< size {
		prev_h := height_map[z * size]
		for x in 1 ..< size {
			prev_h = fir(x, z, prev_h)
		}
	}

	// right to left
	for z in 0 ..< size {
		prev_h := height_map[z * size + size - 1]
		for x := size - 2; x >= 0; x -= 1 {
			prev_h = fir(x, z, prev_h)
		}
	}

	// top to bottom
	for x in 0 ..< size {
		prev_h := height_map[x]
		for z in 1 ..< size {
			prev_h = fir(x, z, prev_h)
		}
	}

	// bottom to top
	for x in 0 ..< size {
		prev_h := height_map[(size - 1) * size + x]
		for z := size - 2; z >= 0; z -= 1 {
			prev_h = fir(x, z, prev_h)
		}
	}
}

fir :: proc(x, z: int, prev_h: f32) -> f32 {
	i := z * size + x
	h := height_map[i]
	height_map[i] = prev_h + (h - prev_h) * filter
	return height_map[i]
}
