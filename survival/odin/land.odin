package survival

import "core:fmt"
import "core:math"

land_northern_lat :: 40

tile_width_avg_km: f32 = 40

max_tile_width := 8

land: Land = {
	// start_ring    = 40,
	start_ring    = 0,

	// Need to make sure the start segment is not inside of a tile
	// start_segment = globe_land_segments - 2,
	start_segment = 0,
	rows          = []LandRow {
		{start = 5, width = 20},
		{start = 2, width = 31},
		{start = 0, width = 36},
		{start = 0, width = 37},
		{start = 0, width = 36},
		{start = 0, width = 34},
		{start = 1, width = 32},
		{start = 1, width = 30},
		{start = 1, width = 30},
		{start = 1, width = 30},
		{start = 2, width = 30},
		{start = 2, width = 15},
		{start = 2, width = 15},
		{start = 2, width = 15},
		{start = 3, width = 15},
		{start = 4, width = 15},
		{start = 6, width = 15},
		{start = 6, width = 15},
		{start = 7, width = 15},
		{start = 9, width = 15},
		{start = 10, width = 10},
	},
}

land_init :: proc() {
	// land.start_ring = lat_to_ring(land_northern_lat) + 12
	// land.start_ring = lat_to_ring(land_northern_lat) + 23
	// land.start_ring = lat_to_ring(land_northern_lat) + 110
	// land.start_ring = lat_to_ring(land_northern_lat) + 90
	land.start_ring = lat_to_ring(0)
	globe_tilt_angle = ring_to_lat(land.start_ring + len(land.rows) / 2)
	// globe_spin_angle = segment_to_lon(land.start_segment + get_land_width(land) / 2)
	// globe_spin_angle = segment_to_lon(land.start_segment + get_land_width_tiles(land) / 2)
	globe_spin_angle = segment_to_lon(land.start_segment + get_land_width_segments(land) / 2)

	// fmt.println(get_land_width_segments(land))

	// fmt.println("ring_len(490", ring_len(490, globe_land_rings) * earth_circumference)

	// land_width_km := get_land_width_km(land)
	// globe_spin_angle = segment_to_lon(land.start_segment + get_land_width_segments(land) / 2)
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
	for row in land.rows {
		row_reach := row.start + row.width
		width = max(width, row_reach)
	}
	return width
}

// Returns the width in tiles
// get_land_width_tiles :: proc(land: Land) -> int {
// 	area_width_km := get_land_width_km(land)
// 	width := 0
// 	for row, y in land.rows {
// 		ring := land.start_ring + y
// 		tile_width_km := tile_width_per_ring_km[ring]
// 		tiles := int(math.round(area_width_km / tile_width_km))
// 		width = max(width, tiles)
// 	}
// 	return width
// }

// get_land_width_segments :: proc(land: Land) -> int {
// 	area_width_km := get_land_width_km(land)
// 	width := 0
// 	for row, y in land.rows {
// 		ring := land.start_ring + y
// 		segments_per_tile := tile_width_per_ring[ring]
// 		tile_width_km := tile_width_per_ring_km[ring]
// 		tiles := int(math.round(area_width_km / tile_width_km))
// 		width = max(width, tiles * segments_per_tile)
// 	}
// 	return width
// }

get_land_width_segments :: proc(land: Land) -> int {
	// area_width_km := get_land_width_km(land)
	max_segments := 0
	for row, i in land.rows {
		ring := land.start_ring + i
		tile_width_km := tile_width_per_ring_km[ring]
		row_width_km := f32(row.width) * tile_width_avg_km
		tiles := int(math.round(row_width_km / tile_width_km))

		start_km := f32(row.start) * tile_width_avg_km
		start_tile := int(math.round(start_km / tile_width_km))

		tiles_in_the_row := start_tile + tiles

		// tiles_in_the_row := int(math.round(area_width_km / tile_width_km))
		// tiles_in_the_row := tiles

		segments_in_the_row := tile_width_per_ring[ring] * tiles_in_the_row
		max_segments = max(max_segments, segments_in_the_row)

		// ring := land.start_ring + y
		// segments_per_tile := tile_width_per_ring[ring]
		// tile_width_km := tile_width_per_ring_km[ring]
		// tiles := int(math.round(area_width_km / tile_width_km))
		// width = max(width, tiles * segments_per_tile)
	}
	return max_tile_width * (max_segments / max_tile_width + 1)
}

get_land_width_km :: proc(land: Land) -> f32 {
	width_km: f32 = 0
	for row, y in land.rows {
		ring := land.start_ring + y
		// tile_width_km := tile_width_per_ring_km[ring]
		row_width_km := f32(row.width) * tile_width_avg_km
		// tiles := int(math.round(row_width_km / tile_width_km))
		start_km := f32(row.start) * tile_width_avg_km

		row_reach := start_km + row_width_km
		width_km = max(width_km, row_reach)


		// row_reach := row.start + row.width
		// width = max(width, row_reach)
	}
	return width_km
}
