package survival

import "core:fmt"
import "core:math"

land_northern_lat :: 40

land: Land = {
	// start_ring    = 40,
	start_ring    = 0,

	// Need to make sure the start segment is not inside of a tile
	// start_segment = globe_land_segments - 2,
	start_segment = 0,
	rows          = []LandRow {
		{start = 5, width = 20},
		{start = 0, width = 30},
		{start = 0, width = 30},
		{start = 0, width = 30},
		{start = 0, width = 30},
		{start = 0, width = 30},
		{start = 0, width = 30},
		{start = 0, width = 30},
		{start = 0, width = 30},
		{start = 0, width = 30},
		{start = 0, width = 30},
		{start = 0, width = 15},
		{start = 0, width = 15},
		{start = 0, width = 15},
		{start = 0, width = 15},
		{start = 0, width = 15},
		{start = 0, width = 15},
		{start = 0, width = 15},
		{start = 0, width = 15},
		{start = 0, width = 15},
		{start = 0, width = 15},
	},
}

land_init :: proc() {
	land.start_ring = lat_to_ring(land_northern_lat) + 12
	globe_tilt_angle = ring_to_lat(land.start_ring + len(land.rows) / 2)
	globe_spin_angle = segment_to_lon(land.start_segment + get_land_width(land) / 2)
}

lat_to_ring :: proc(lat: int) -> int {
	return globe_land_rings / 2 + int(math.round(f32(globe_land_rings) / 180 * land_northern_lat))
}

ring_to_lat :: proc(ring: int) -> f32 {
	return 180 / f32(globe_land_rings) * f32(ring) - 90
}

segment_to_lon :: proc(segment: int) -> f32 {
	return -360 / f32(globe_land_segments) * f32(segment) + 90
}

// Returns the width in tiles
get_land_width :: proc(land: Land) -> int {
	width := 0
	for row in land.rows {
		row_reach := row.start + row.width
		width = max(width, row_reach)
	}
	return width
}
