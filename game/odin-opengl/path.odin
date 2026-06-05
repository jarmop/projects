package game

import "core:fmt"
import "core:math"
import "core:math/linalg"

Triangle :: struct {
	corners: [3][3]f32,
	bottom:  ^Triangle,
	left:    ^Triangle,
	right:   ^Triangle,
}

Cell :: struct {
	triangles: [4]^Triangle, // Array of pointers/indices to the triangle_map
}

VERTICES_PER_TRIANGLE :: 3
TRIANGLES_PER_CELL :: 4
VERTICES_PER_CELL :: VERTICES_PER_TRIANGLE * TRIANGLES_PER_CELL
CELL_COUNT :: GROUND_VERTICES_COUNT / VERTICES_PER_CELL

triangle_table: [CELL_COUNT * TRIANGLES_PER_CELL]Triangle

cell_table: [CELL_COUNT]Cell

init_path :: proc() {
	// fmt.println("----------")

	TRIANGLES_PER_ROW :: GRID_SIZE * TRIANGLES_PER_CELL

	for cell_i := 0; cell_i < CELL_COUNT; cell_i += 1 {
		// TRIANGLE 0
		triangle_i := cell_i * TRIANGLES_PER_CELL
		is_first_row := cell_i < GRID_SIZE
		triangle_table[triangle_i] = {
			bottom = nil if is_first_row else &triangle_table[triangle_i + 2 - TRIANGLES_PER_ROW],
			left   = &triangle_table[triangle_i + 1],
			right  = &triangle_table[triangle_i + TRIANGLES_PER_CELL - 1],
		}
		ground_vertex_i := cell_i * VERTICES_PER_CELL
		for i in 0 ..< 3 {
			triangle_table[triangle_i].corners[i] = ground_vertices[ground_vertex_i + i].pos
		}
		cell_table[cell_i].triangles[0] = &triangle_table[triangle_i]

		// TRIANGLE 1
		triangle_i += 1
		is_last_col := (cell_i + 1) % GRID_SIZE == 0
		triangle_table[triangle_i] = {
			bottom = nil if is_last_col else &triangle_table[triangle_i + 2 + TRIANGLES_PER_CELL],
			left   = &triangle_table[triangle_i + 1],
			right  = &triangle_table[triangle_i - 1],
		}
		ground_vertex_i += 3
		for i in 0 ..< 3 {
			triangle_table[triangle_i].corners[i] = ground_vertices[ground_vertex_i + i].pos
		}
		cell_table[cell_i].triangles[1] = &triangle_table[triangle_i]

		// TRIANGLE 2
		triangle_i += 1
		is_last_row := cell_i >= GRID_SIZE * (GRID_SIZE - 1)
		triangle_table[triangle_i] = {
			bottom = nil if is_last_row else &triangle_table[triangle_i - 2 + TRIANGLES_PER_ROW],
			left   = &triangle_table[triangle_i + 1],
			right  = &triangle_table[triangle_i - 1],
		}
		ground_vertex_i += 3
		for i in 0 ..< 3 {
			triangle_table[triangle_i].corners[i] = ground_vertices[ground_vertex_i + i].pos
		}
		cell_table[cell_i].triangles[2] = &triangle_table[triangle_i]

		// TRIANGLE 3
		triangle_i += 1
		is_first_col := cell_i % GRID_SIZE == 0
		triangle_table[triangle_i] = {
			bottom = nil if is_first_col else &triangle_table[triangle_i - 2 - TRIANGLES_PER_CELL],
			// left   = &triangle_table[cell_i * TRIANGLES_PER_CELL],
			left   = &triangle_table[triangle_i - 3],
			right  = &triangle_table[triangle_i - 1],
		}
		ground_vertex_i += 3
		for i in 0 ..< 3 {
			triangle_table[triangle_i].corners[i] = ground_vertices[ground_vertex_i + i].pos
		}
		cell_table[cell_i].triangles[3] = &triangle_table[triangle_i]
	}
}

get_triangle :: proc(p: [3]f32) -> ^Triangle {
	cell_x := int(math.floor(p.x))
	cell_z := int(math.floor(p.z))
	cell := cell_table[cell_z * GRID_SIZE + cell_x]
	triangles := cell.triangles

	l: [4]f32
	for triangle, i in triangles {
		l[i] = linalg.length(p.xz - triangle.corners[0].xz)
	}

	// Nearest edge is the one whose combined distance of vertices from the point is the shortest.
	// Start by guessing that the last triangle has the nearest edge.
	nearest_edge_d := l[3] + l[0]
	triangle := triangles[3]
	for i in 0 ..< 3 {
		edge_d := l[i] + l[i + 1]
		if edge_d < nearest_edge_d {
			nearest_edge_d = edge_d
			triangle = triangles[i]
		}
	}

	return triangle
}

funnel :: proc(start, end: [3]f32, triangle: ^Triangle, end_triangle: ^Triangle) {
	fmt.println("########################")
	start_triangle := triangle

	fmt.println(soldiers[0].path[0:10])
	fmt.println(start_triangle.corners)
	fmt.println(soldiers[0].path_len)
	fmt.println(soldiers[0].path_i)

	// soldiers[0].path[i] = p
	// soldiers[0].path_len = i + 1
	// soldiers[0].target = soldiers[0].path[0]

	start_waypoint := start
	entrance_edge: [2][3]f32
	for i := 0; start_triangle != nil && i < PATH_MAX_LENGTH; i += 1 {
		// for i := 0; start_triangle != nil && i < 20; i += 1 {
		// fmt.println("------------- loop", i, "-------------")

		nearest_point_i, nearest_point_d, other_indices := get_nearest_point(
			end,
			start_triangle.corners,
		)
		p1 := start_triangle.corners[nearest_point_i]

		// If the distance from the start of the waypoint to the corner nearest to the end is longer
		// if linalg.length(p1 - start_waypoint) > linalg.length(end - start_waypoint) {
		if end_triangle.corners == start_triangle.corners {
			// fmt.println("finish the path")

			soldiers[0].path[i] = end
			soldiers[0].path_len = i + 1
			soldiers[0].target = soldiers[0].path[0]
			break
		}

		// Check which of the edges containing the vertex is intersecting with the path (on the xz plane)
		// p1 := start_triangle.corners[nearest_point_i]

		p0_0 := start_triangle.corners[other_indices[0]]
		p0_1 := start_triangle.corners[other_indices[1]]
		isect_xz0 := intersect_xz(start.xz, end.xz, p0_0.xz, p1.xz)
		isect_xz1 := intersect_xz(start.xz, end.xz, p0_1.xz, p1.xz)

		len_p := linalg.length(end.xz - p1.xz)
		len_0 := linalg.length(end.xz - isect_xz0)
		len_1 := linalg.length(end.xz - isect_xz1)

		p0 := p0_0
		pi_xz := isect_xz0
		// next_triangle: [3][3]f32
		next_triangle: ^Triangle

		// Edge option 1 length from start to intersection
		edge1_xz := p1.xz - p0_1.xz
		edge1_xz_start_to_isect := isect_xz1 - p0_1.xz
		edge1_xz_isect_to_end := p1.xz - isect_xz1

		// foo_d0 := linalg.length(isect_xz0 - start_waypoint.xz) + len_0
		// foo_d1 := linalg.length(isect_xz1 - start_waypoint.xz) + len_1

		// Also, the exit portal can't be the same as the entrance portal
		// p0_1 != entrance_edge[0] &&
		exit_portal_not_entrance := !((p0_1 == entrance_edge[0] && p1 == entrance_edge[1]) ||
			(p0_1 == entrance_edge[1] && p1 == entrance_edge[0]))

		edge1_isect_is_valid :=
			linalg.length(edge1_xz_start_to_isect) < linalg.length(edge1_xz) &&
			linalg.length(edge1_xz_isect_to_end) < linalg.length(edge1_xz) &&
			exit_portal_not_entrance &&
			linalg.length(end.xz - isect_xz1) < linalg.length(end.xz - start_waypoint.xz) &&
			p0_1.x >= 0 &&
			p0_1.z >= 0


		// isect can't be further away from end than waypoint start
		// linalg.length(edge1_xz_isect_to_end) < linalg.length(end - start_waypoint.xz)

		// Doesn't work because p1 does not always have greater x and z values than p0.
		// edge1_isect_is_valid :=
		// 	isect_xz1[0] >= p0_1.x &&
		// 	isect_xz1[0] <= p1.x &&
		// 	isect_xz1[1] >= p0_1.z &&
		// 	isect_xz1[1] <= p1.z

		if (edge1_isect_is_valid) {
			// fmt.println("p0_1 is closer")
			p0 = p0_1
			pi_xz = isect_xz1

			if nearest_point_i == 0 {
				// 0, 2
				// fmt.println("a")
				// fmt.println("triangle.right")
				next_triangle = start_triangle.right
				// entrance_edge = {p0, p1}
			} else if nearest_point_i == 1 {
				// 1, 2
				// fmt.println("b")
				// fmt.println("triangle.left")
				next_triangle = start_triangle.left
			} else {
				// 2, 1
				// fmt.println("c")
				// fmt.println("triangle.left")
				next_triangle = start_triangle.left
			}
		} else {
			if nearest_point_i == 0 {
				// 0, 1
				// fmt.println("d")
				// next_triangle = {p0, p1, 0}
				next_triangle = start_triangle.bottom
			} else if nearest_point_i == 1 {
				// 1, 0
				// fmt.println("e")
				// next_triangle = {p1, p0, 0}
				next_triangle = start_triangle.bottom
			} else {
				// 2, 0
				// fmt.println("f")
				// fmt.println("triangle.right")
				next_triangle = start_triangle.right
			}
		}

		p := get_intersection_y(p0, p1, pi_xz)

		soldiers[0].path[i] = p
		soldiers[0].path_len = i + 1

		start_triangle = next_triangle

		// This can point in the wrong direction
		entrance_edge = {p0, p1}

		if (i < 10) {
			fmt.println("------------- loop", i, "-------------")
			fmt.println(
				"Check is edge1 intersection point valid:",
				linalg.length(edge1_xz_start_to_isect) < linalg.length(edge1_xz),
				linalg.length(edge1_xz_isect_to_end) < linalg.length(edge1_xz),
				// This for some reason is false
				p0_1 != entrance_edge[0],
				linalg.length(end.xz - isect_xz1) < linalg.length(end.xz - start_waypoint.xz),
				p0_1.x >= 0,
				p0_1.z >= 0,
			)
			fmt.println("Next_triangle:", next_triangle.corners)
			fmt.println("Waypoint:", p)
		}
	}

	// fmt.println(soldiers[0].path[0:soldiers[0].path_len])
	fmt.println(soldiers[0].path[0:10])
	fmt.println(start_triangle.corners)
	fmt.println(soldiers[0].path_len)
	fmt.println(soldiers[0].path_i)

	soldiers[0].path_i = 0
	soldiers[0].target = soldiers[0].path[0]
}

get_nearest_point :: proc(
	target_point: [3]f32,
	triangle: [3][3]f32,
) -> (
	nearest_point_i: int,
	nearest_point_d: f32,
	other_indices: [2]int,
) {
	nearest_point_i = 0
	nearest_point_d = linalg.length(target_point - triangle[0])
	other_indices = {1, 2}
	l1 := linalg.length(target_point - triangle[1])
	l2 := linalg.length(target_point - triangle[2])
	if l1 < nearest_point_d {
		nearest_point_i = 1
		nearest_point_d = l1
		other_indices = {0, 2}
	}
	if l2 < nearest_point_d {
		nearest_point_i = 2
		nearest_point_d = l2
		other_indices = {0, 1}
	}

	return nearest_point_i, nearest_point_d, other_indices
}

intersect_xz :: proc(p1, p2, p3, p4: [2]f32) -> [2]f32 {
	A1 := p2.y - p1.y
	B1 := p1.x - p2.x
	C1 := A1 * p1.x + B1 * p1.y

	A2 := p4.y - p3.y
	B2 := p3.x - p4.x
	C2 := A2 * p3.x + B2 * p3.y

	determinant := A1 * B2 - A2 * B1

	if (determinant == 0) {
		// Parallel or coincident
		fmt.println("wtf")
		return {0, 0}
	} else {
		x := (B2 * C1 - B1 * C2) / determinant
		y := (A1 * C2 - A2 * C1) / determinant
		return {x, y}
	}
}

get_intersection_y :: proc(p0, p1: [3]f32, pi_xz: [2]f32) -> [3]f32 {
	p_dir := linalg.normalize(p1 - p0)
	y: f32
	if (abs(p_dir.x) > 0) {
		y = p_dir.y * (pi_xz[0] - p0.x) / p_dir.x
	} else {
		y = p_dir.y * (pi_xz[1] - p0.z) / p_dir.z
	}
	p := [3]f32{pi_xz.x, p0.y + y, pi_xz[1]}

	return p
}
