package game

wall_blocks_ray :: proc(ray_start: [3]f32, ray_direction: [3]f32, ray_length: f32) -> bool {
	ray_hits_wall := false
	for w in walls_x {
		wall_d := hit_distance(w.bb, ray_start, ray_direction)
		if wall_d > 0 && wall_d < ray_length {
			return true
		}
	}
	for w in walls_z {
		wall_d := hit_distance(w.bb, ray_start, ray_direction)
		if wall_d > 0 && wall_d < ray_length {
			return true
		}
	}

	return false
}
