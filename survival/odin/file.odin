package survival

import "core:fmt"
import "core:os"
import "core:slice"

// land_segments_filename := "data/land_segments1024"
// land_segments_filename := "data/custom1024"
// land_segments_filename := "data/custom512"
land_segments_filename := "data/earth1024"
// land_segments_filename := "data/earth512"
// land_segments_filename := "data/full_of_land1024"

save_land :: proc() {
	land_count := 0
	for s in land_segments {
		if s > TERRAIN_TYPE.OCEAN {
			land_count += 1
		}
	}

	bytes := slice.to_bytes(land_segments[:])
	write_err := os.write_entire_file(land_segments_filename, bytes)
	if (write_err != nil) {
		fmt.println(write_err)
	}

	segment_count := len(land_segments)
	fmt.printfln(
		"Saved %d segments with %.1f%% land",
		segment_count,
		f32(land_count) / f32(segment_count) * 100,
	)
}

load_land :: proc() {
	data_bytes, read_err := os.read_entire_file(land_segments_filename, context.allocator)
	if (read_err != nil) {
		fmt.println(read_err)
	}
	defer delete(data_bytes)

	data_integers := slice.reinterpret([]TERRAIN_TYPE, data_bytes)
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

load_and_convert_land :: proc(from: string, to: string) {
	data_bytes, read_err := os.read_entire_file(from, context.allocator)
	if (read_err != nil) {
		fmt.println(read_err)
	}
	defer delete(data_bytes)

	data_integers := slice.reinterpret([]TERRAIN_TYPE, data_bytes)

	stride512 := globe_land_segments / 2
	stride1024 := globe_land_segments

	y2 := 0
	for y in 0 ..< globe_land_rings / 2 {
		x2 := 0
		for x in 0 ..< globe_land_segments / 2 {
			s := data_integers[y * stride512 + x]

			land_segments[y2 * stride1024 + x2] = s
			land_segments[y2 * stride1024 + x2 + 1] = s
			land_segments[(y2 + 1) * stride1024 + x2] = s
			land_segments[(y2 + 1) * stride1024 + x2 + 1] = s

			x2 += 2
		}
		y2 += 2
	}
}
