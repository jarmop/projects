package survival

import "core:fmt"
import "core:os"
import "core:slice"

land_segments_filename := "data/land_segments"

save_land :: proc() {
	land_count := 0
	for s in land_segments {
		if s == 1 {
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
