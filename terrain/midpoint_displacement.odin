package terrain

import "core:math"
import "core:math/rand"

roughness: f32 = 1.0

create_midpoint_displacement :: proc() {
	rect_size := calc_next_power_of_two(size)
	height := f32(rect_size) / 2
	height_reduction := math.pow(2, -roughness)

	for rect_size > 0 {
		diamond_step(rect_size, height)
		square_step(rect_size, height)
		rect_size /= 2
		height *= height_reduction
	}
}

calc_next_power_of_two :: proc(x: int) -> int {
	ret := 1

	if x == 1 {
		return 2
	}

	for ret < x {
		ret = ret * 2
	}

	return ret
}

diamond_step :: proc(rect_size: int, height: f32) {
	half_rect_size := rect_size / 2

	for z := 0; z < size; z += rect_size {
		for x := 0; x < size; x += rect_size {
			next_x := (x + rect_size) % size
			next_z := (z + rect_size) % size
			if next_x < x {
				next_x = size - 1
			}
			if next_z < z {
				next_z = size - 1
			}

			top_left_y := height_map[z * size + x]
			top_right_y := height_map[z * size + next_x]
			bottom_left_y := height_map[next_z * size + x]
			bottom_right_y := height_map[next_z * size + next_x]
			center_y := (top_left_y + top_right_y + bottom_left_y + bottom_right_y) / 4

			center_x := (x + half_rect_size) % size
			center_z := (z + half_rect_size) % size
			rand_value := rand.float32_range(-height, height)
			height_map[center_z * size + center_x] = center_y + rand_value
		}
	}
}

square_step :: proc(rect_size: int, height: f32) {
	half_rect_size := rect_size / 2

	for z := 0; z < size; z += rect_size {
		for x := 0; x < size; x += rect_size {
			next_x := (x + rect_size) % size
			next_z := (z + rect_size) % size
			if next_x < x {
				next_x = size - 1
			}
			if next_z < z {
				next_z = size - 1
			}

			center_x := (x + half_rect_size) % size
			center_z := (z + half_rect_size) % size

			prev_center_x := (x - half_rect_size + size) % size
			prev_center_z := (z - half_rect_size + size) % size

			top_left_y := height_map[z * size + x]
			top_right_y := height_map[z * size + next_x]
			bottom_left_y := height_map[next_z * size + x]

			center_y := height_map[center_z * size + center_x]
			center_y_prev_x := height_map[center_z * size + prev_center_x]
			center_y_prev_z := height_map[prev_center_z * size + center_x]

			center_left_y :=
				(top_left_y + center_y + bottom_left_y + center_y_prev_x) / 4 +
				rand.float32_range(-height, height)
			center_top_y :=
				(top_left_y + center_y + top_right_y + center_y_prev_z) / 4 +
				rand.float32_range(-height, height)

			height_map[z * size + center_x] = center_top_y
			height_map[center_z * size + x] = center_left_y
		}
	}
}
