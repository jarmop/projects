package survival

import "core:fmt"
import "core:math"

tile_width_avg_km: f32 = 40

TERRAIN_TYPE :: enum {
	OCEAN,
	FOREST,
}

land_init :: proc() {
	lat: f32 = 40
	ring := lat_to_ring(lat)
	segment := 0

	segment_index := ring * globe_land_segments + segment
	land_segments[segment_index] = 1

	globe_tilt_angle = lat
	globe_spin_angle = segment_to_lon(segment)
}

lat_to_ring :: proc(lat: f32) -> int {
	return globe_land_rings / 2 + int(math.round(f32(globe_land_rings) / 180 * lat))
}

ring_to_lat :: proc(ring: int) -> f32 {
	return 180 / f32(globe_land_rings) * f32(ring) - 90
}

segment_to_lon :: proc(segment: int) -> f32 {
	return -360 / f32(globe_land_segments) * f32(segment) + 90
}

// // Returns the width in tiles
get_land_width :: proc(land: Land) -> int {
	width := 0
	for row in land.slices {
		row_reach := row.segment + row.width
		width = max(width, row_reach)
	}
	return width
}

get_land_max_tile_width :: proc(land: Land) -> int {
	return max(
		tile_width_per_ring[land.ring],
		tile_width_per_ring[land.ring + len(land.slices) - 1],
	)
}

get_land_width_segments :: proc(land: Land) -> int {
	// land_max_tile_width := get_land_max_tile_width(land)
	// max_tile_width := max(
	// 	tile_width_per_ring[land.start_ring],
	// 	tile_width_per_ring[land.start_ring + len(land.rows)],
	// )
	max_segments := 0
	for row, i in land.slices {
		ring := land.ring + i
		tile_width_km := tile_width_per_ring_km[ring]
		row_width_km := f32(row.width) * tile_width_avg_km
		tiles := int(math.round(row_width_km / tile_width_km))

		start_km := f32(row.segment) * tile_width_avg_km
		start_tile := int(math.round(start_km / tile_width_km))
		// fmt.println(tile_width_km, start_tile, tiles)

		tiles_in_the_row := start_tile + tiles

		segments_in_the_row := tile_width_per_ring[ring] * tiles_in_the_row
		max_segments = max(max_segments, segments_in_the_row)
	}
	// Round up to be divisible by the max tile width
	// fmt.println(max_tile_width)
	return max_segments
	// return(
	// 	land_max_tile_width == 1 ? max_segments : land_max_tile_width * (max_segments / land_max_tile_width + 1) \
	// )
}

// get_land_width_km :: proc(land: Land) -> f32 {
// 	width_km: f32 = 0
// 	for row, y in land.rows {
// 		ring := land.ring + y
// 		row_width_km := f32(row.width) * tile_width_avg_km
// 		start_km := f32(row.segment) * tile_width_avg_km

// 		row_reach := start_km + row_width_km
// 		width_km = max(width_km, row_reach)
// 	}
// 	return width_km
// }
