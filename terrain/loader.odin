package terrain

import "core:fmt"
import "core:os"
import "core:slice"

load_data :: proc() {
	height_map_filename := "data/heightmap.save"

	data, read_err := os.read_entire_file(height_map_filename, context.allocator)
	if (read_err != nil) {
		fmt.println(read_err)
	}
	defer delete(data)

	// terrain_size := math.sqrt(f32(len(data)) / size_of(f32))
	// fmt.println(terrain_size)

	// Fill vertices
	index := 0
	for z := 0; z < vertices_per_side; z += 1 {
		for x := 0; x < vertices_per_side; x += 1 {
			i := z * vertices_per_side * size_of(f32) + x * size_of(f32)
			f := slice.to_type(data[i:(i + size_of(f32))], f32)
			vertices[index] = {
				pos = {f32(x) * scale, f, f32(z) * scale},
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
}
