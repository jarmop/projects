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
	// fmt.println(soldiers[0].path[0:10])
	fmt.println("start_triangle", start_triangle.corners)
	fmt.println("end_triangle:", end_triangle.corners)
	// fmt.println(soldiers[0].path_len)
	// fmt.println(soldiers[0].path_i)
	// fmt.println(soldiers[0].pos)

	soldiers[0].path_i = 0
	soldiers[0].path_len = 0

	// soldiers[0].path[i] = p
	// soldiers[0].path_len = i + 1
	// soldiers[0].target = soldiers[0].path[0]

	/*
	If start is close enough to any corner of the closest edge, pick that as 
	the exit portal and set intersection as that corner
	*/


	start_waypoint := start
	entrance_edge: [2][3]f32
	for i := 0; start_triangle != nil && i < PATH_MAX_LENGTH; i += 1 {
		// for i := 0; start_triangle != nil && i < 10; i += 1 {
		fmt.println("------------- loop", i, "-------------")

		// If the distance from the start of the waypoint to the corner nearest to the end is longer
		// if linalg.length(p1 - start_waypoint) > linalg.length(end - start_waypoint) {
		if end_triangle.corners == start_triangle.corners {
			// fmt.println("finish the path")

			soldiers[0].path[i] = end
			soldiers[0].path_len += 1
			// soldiers[0].path_len += 1
			// soldiers[0].target = soldiers[0].path[0]
			break
		}

		// nearest_point_i, nearest_point_d, other_indices := get_nearest_point(
		// 	end,
		// 	start_triangle.corners,
		// )
		// p1 := start_triangle.corners[nearest_point_i]


		// // Check which of the edges containing the vertex is intersecting with the path (on the xz plane)
		// // p1 := start_triangle.corners[nearest_point_i]

		// p0_0 := start_triangle.corners[other_indices[0]]
		// p0_1 := start_triangle.corners[other_indices[1]]
		// isect_xz0 := intersect_xz(start.xz, end.xz, p0_0.xz, p1.xz)
		// isect_xz1 := intersect_xz(start.xz, end.xz, p0_1.xz, p1.xz)

		// len_p := linalg.length(end.xz - p1.xz)
		// len_0 := linalg.length(end.xz - isect_xz0)
		// len_1 := linalg.length(end.xz - isect_xz1)

		// p0 := p0_0
		// pi_xz := isect_xz0

		// // Edge option 1 length from start to intersection
		// edge1_xz := p1.xz - p0_1.xz
		// edge1_xz_start_to_isect := isect_xz1 - p0_1.xz
		// edge1_xz_isect_to_end := p1.xz - isect_xz1

		// edge_start_to_isect_shorter_than_edge :=
		// 	linalg.length(edge1_xz_start_to_isect) <= linalg.length(edge1_xz)

		// edge_isect_to_end_shorter_than_edge :=
		// 	linalg.length(edge1_xz_isect_to_end) <= linalg.length(edge1_xz)

		// // Also, the exit portal can't be the same as the entrance portal
		// // p0_1 != entrance_edge[0] &&
		// exit_portal_not_entrance := !((p0_1 == entrance_edge[0] && p1 == entrance_edge[1]) ||
		// 	(p0_1 == entrance_edge[1] && p1 == entrance_edge[0]))

		// isect_to_target_shorter_than_waypoint_start_to_target :=
		// 	linalg.length(end.xz - isect_xz1) <= linalg.length(end.xz - start_waypoint.xz)

		// edge1_isect_is_valid :=
		// 	edge_start_to_isect_shorter_than_edge &&
		// 	edge_isect_to_end_shorter_than_edge &&
		// 	isect_to_target_shorter_than_waypoint_start_to_target &&
		// 	exit_portal_not_entrance &&
		// 	p0_1.x >= 0 &&
		// 	p0_1.z >= 0


		// next_triangle: ^Triangle
		// if (edge1_isect_is_valid) {
		// 	// fmt.println("p0_1 is closer")
		// 	p0 = p0_1
		// 	pi_xz = isect_xz1

		// 	if nearest_point_i == 0 {
		// 		// 0, 2
		// 		// fmt.println("a")
		// 		// fmt.println("triangle.right")
		// 		next_triangle = start_triangle.right
		// 		// entrance_edge = {p0, p1}
		// 	} else if nearest_point_i == 1 {
		// 		// 1, 2
		// 		// fmt.println("b")
		// 		// fmt.println("triangle.left")
		// 		next_triangle = start_triangle.left
		// 	} else {
		// 		// 2, 1
		// 		// fmt.println("c")
		// 		// fmt.println("triangle.left")
		// 		next_triangle = start_triangle.left
		// 	}
		// } else {
		// 	if nearest_point_i == 0 {
		// 		// 0, 1
		// 		// fmt.println("d")
		// 		// next_triangle = {p0, p1, 0}
		// 		next_triangle = start_triangle.bottom
		// 	} else if nearest_point_i == 1 {
		// 		// 1, 0
		// 		// fmt.println("e")
		// 		// next_triangle = {p1, p0, 0}
		// 		next_triangle = start_triangle.bottom
		// 	} else {
		// 		// 2, 0
		// 		// fmt.println("f")
		// 		// fmt.println("triangle.right")
		// 		next_triangle = start_triangle.right
		// 	}
		// }


		sorted := get_sorted_triangle_corners(end, start_triangle.corners)

		nearest_point_i := sorted[0]

		p1 := start_triangle.corners[sorted[0]] // closest corner
		p0_1 := start_triangle.corners[sorted[1]] // second closest corner
		p0_2 := start_triangle.corners[sorted[2]] // farthest corner

		isect_xz1 := intersect_xz(start.xz, end.xz, p0_1.xz, p1.xz)

		edge1_xz := p1.xz - p0_1.xz
		edge1_xz_start_to_isect := isect_xz1 - p0_1.xz
		edge1_xz_isect_to_end := p1.xz - isect_xz1

		edge_start_to_isect_shorter_than_edge :=
			linalg.length(edge1_xz_start_to_isect) <= linalg.length(edge1_xz)

		edge_isect_to_end_shorter_than_edge :=
			linalg.length(edge1_xz_isect_to_end) <= linalg.length(edge1_xz)

		edge1_isect_is_valid := edge_start_to_isect_shorter_than_edge
		//  && edge_isect_to_end_shorter_than_edge
		// 	isect_to_target_shorter_than_waypoint_start_to_target &&
		// 	exit_portal_not_entrance &&
		// 	p0_1.x >= 0 &&
		// 	p0_1.z >= 0

		next_triangle: ^Triangle
		p0 := p0_2
		pi_xz: [2]f32
		p1_i := sorted[0]
		p0_i := sorted[2]
		if edge1_isect_is_valid {
			p0 = p0_1
			p0_i = sorted[1]
			pi_xz = isect_xz1
		} else {
			pi_xz = intersect_xz(start.xz, end.xz, p0_2.xz, p1.xz)
		}
		if p1_i == 0 && p0_i == 2 {
			next_triangle = start_triangle.right
		} else if p1_i == 1 && p0_i == 2 {
			next_triangle = start_triangle.left
		} else if p1_i == 2 && p0_i == 1 {
			next_triangle = start_triangle.left
		} else if p1_i == 0 && p0_i == 1 {
			next_triangle = start_triangle.bottom
		} else if p1_i == 1 && p0_i == 0 {
			next_triangle = start_triangle.bottom
		} else {
			// p1_i == 2 && p0_i == 0
			next_triangle = start_triangle.right
		}

		p := get_intersection_y(p0, p1, pi_xz)

		soldiers[0].path[i] = p
		soldiers[0].path_len += 1

		start_triangle = next_triangle

		// This can point in the wrong direction
		entrance_edge = {p0, p1}

		// if (i < 10) {
		if (i == 0) {
			fmt.println("------------- loop", i, "-------------")
			fmt.println("sorted", sorted)

			// fmt.println("nearest_point_i:", nearest_point_i)
			fmt.println("nearest_point_i:", sorted[0])
			fmt.println("p1:", p1)
			fmt.println("p0:", p0)
			fmt.println("p1_i:", p1_i)
			fmt.println("p0_i:", p0_i)
			fmt.println("edge1_isect_is_valid:", edge1_isect_is_valid)
			fmt.println(
				"Check is edge1 intersection point valid:",
				edge_start_to_isect_shorter_than_edge,
				edge_isect_to_end_shorter_than_edge,
				// isect_to_target_shorter_than_waypoint_start_to_target,
				// exit_portal_not_entrance,
				// p0_1.x >= 0,
				// p0_1.z >= 0,
			)
			fmt.println("Next_triangle:", next_triangle.corners)
			fmt.println("Waypoint:", p)
		}
	}
	fmt.println("----- Path created -----")
	fmt.println("Path (max 10):", soldiers[0].path[0:min(soldiers[0].path_len, 10)])
	// fmt.println("First 10 in path", soldiers[0].path[0:10])
	fmt.println("start_triangle.corners:", start_triangle.corners)
	fmt.println("Path length:", soldiers[0].path_len)
	fmt.println("path_i:", soldiers[0].path_i)

	soldiers[0].path_i = 0
	soldiers[0].target = soldiers[0].path[0]

	// fmt.println("Will the path be drawn", soldiers[0].pos != soldiers[0].target)
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
	nearest_point_d = linalg.length(target_point.xz - triangle[0].xz)
	other_indices = {1, 2}
	l1 := linalg.length(target_point.xz - triangle[1].xz)
	l2 := linalg.length(target_point.xz - triangle[2].xz)
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

/*
	1: closest to target (end point of the two closest edges)
	2: start point of the closest (not necessarily the second closest corner)
	3: start point of the second closest edge
*/
get_sorted_triangle_corners :: proc(target_point: [3]f32, triangle: [3][3]f32) -> [3]int {
	// d of corners to target
	lc: []f32 = {
		linalg.length(target_point.xz - triangle[0].xz),
		linalg.length(target_point.xz - triangle[1].xz),
		linalg.length(target_point.xz - triangle[2].xz),
	}
	nearest_point_i := 0
	other_indices: [dynamic]int
	for i := 1; i < 3; i += 1 {
		if lc[i] < lc[nearest_point_i] {
			append(&other_indices, nearest_point_i)
			nearest_point_i = i
		} else {
			append(&other_indices, i)
		}
	}

	// edges: [2][2][3]f32 = {
	// edges: [2][3]f32 = {
	// 	triangle[nearest_point_i] - triangle[other_indices[0]],
	// 	triangle[nearest_point_i] - triangle[other_indices[1]],
	// }

	// wtf0 :=
	// 	triangle[nearest_point_i] -
	// 	linalg.normalize(triangle[nearest_point_i] - triangle[other_indices[0]])

	// wtf1 :=
	// 	triangle[nearest_point_i] -
	// 	linalg.normalize(triangle[nearest_point_i] - triangle[other_indices[1]])

	normalized_edge_start_points: [2][3]f32 = {
		triangle[nearest_point_i] -
		linalg.normalize(triangle[nearest_point_i] - triangle[other_indices[0]]),
		triangle[nearest_point_i] -
		linalg.normalize(triangle[nearest_point_i] - triangle[other_indices[1]]),
	}

	// lprkl: [2]f32 = {
	// 	linalg.length(triangle[nearest_point_i].xz - triangle[0].xz),
	// 	linalg.length(triangle[nearest_point_i].xz - triangle[0].xz),
	// }

	// d of equal point on edge to target

	// l: []f32 = {
	// 	lc[nearest_point_i],
	// 	// linalg.length(target_point.xz - triangle[1].xz),
	// 	linalg.length(target_point.xz - normalized_edge_start_points[0].xz),
	// 	linalg.length(target_point.xz - normalized_edge_start_points[1].xz),
	// }
	l: [3]f32
	l[nearest_point_i] = lc[nearest_point_i]
	l[other_indices[0]] = linalg.length(target_point.xz - normalized_edge_start_points[0].xz)
	l[other_indices[1]] = linalg.length(target_point.xz - normalized_edge_start_points[1].xz)

	// nearest:= 0
	// second_nearest:= 1
	// if (second_nearest <)
	// l0 := linalg.length(target_point.xz - triangle[0].xz)
	// l1 := linalg.length(target_point.xz - triangle[1].xz)
	// l2 := linalg.length(target_point.xz - triangle[2].xz)

	/*
	Handle situation where nearest edge is the bottom edge but another edge is 
	mistakenly considered nearer because it	is shorter. So can't rely on 
	checking the edge start point. Check some equal distance from the end instead
	*/

	sorted: [3]int = {0, 1, 2}
	if (l[1] < l[0]) {
		sorted = {1, 0, 2}
	}
	if l[2] < l[sorted[0]] {
		sorted[2] = sorted[1]
		sorted[1] = sorted[0]
		sorted[0] = 2
	} else if l[2] < l[sorted[1]] {
		sorted[2] = sorted[1]
		sorted[1] = 2
	}
	// if l[1] < l[0] {
	// 	sorted = {1, 0}
	// }
	// if l[2] < l[sorted[0]] {
	// 	sorted[1] = sorted[0]
	// 	sorted[0] = 2
	// } else if l[2] < l[sorted[1]] {
	// 	sorted[1] = 2
	// }
	return sorted
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
