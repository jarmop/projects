package survival

import "core:fmt"
import "core:os"
import "core:slice"

land_segments_filename := "data/land_segments"

save_land :: proc() {
	ocean_count := 0
	forest_count := 0
	plain_count := 0
	void_count := 0

	for ring in 0 ..< globe_land_rings {
		for segment := 0; segment < globe_land_segments; {
			tile_width := tile_width_per_ring[ring]
			tile_index := ring * globe_land_rings + segment / tile_width
			s := land_segments[tile_index]

			if s == 1 {
				ocean_count += tile_width
			} else if s == 2 {
				forest_count += tile_width
			} else if s == 3 {
				plain_count += tile_width
			} else {
				void_count += tile_width

			}

			segment += tile_width
		}
	}

	land_count := forest_count + plain_count

	// fmt.println(land_count, ocean_count, forest_count, plain_count, void_count)
	// fmt.println(f32(land_count) / f32(land_count + ocean_count))

	bytes := slice.to_bytes(land_segments[:])
	write_err := os.write_entire_file(land_segments_filename, bytes)
	if (write_err != nil) {
		fmt.println(write_err)
	}

	segment_count := len(land_segments)
	fmt.printfln(
		"Saved %d segments with %.1f%% land",
		segment_count,
		f32(land_count) / f32(land_count + ocean_count) * 100,
	)
}

load_land :: proc() {
	data_bytes, read_err := os.read_entire_file(land_segments_filename, context.allocator)
	if (read_err != nil) {
		fmt.println(read_err)
	}
	defer delete(data_bytes)

	data_integers := slice.reinterpret([]int, data_bytes)
	// land_count := 0
	for s, i in data_integers {
		land_segments[i] = s
		// if s == 1 {
		// 	land_count += 1
		// }
	}

	// fmt.println("Load")
	// fmt.println(len(data_integers))
	// fmt.println(land_count)
}
