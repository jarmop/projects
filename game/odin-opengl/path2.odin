package game

import "core:math"

Vec3 :: [3]f32

Triangle :: struct {
	verts:     [3]u32,
	neighbors: [3]int, // -1 = no neighbor
}

NavMesh :: struct {
	vertices:  []Vec3,
	triangles: []Triangle,
}

Node :: struct {
	tri:    int,
	g_cost: f32,
	h_cost: f32,
	parent: int,
}

node_f :: proc(n: Node) -> f32 {
	return n.g_cost + n.h_cost
}

triangle_center :: proc(mesh: ^NavMesh, tri_idx: int) -> Vec3 {
	tri := mesh.triangles[tri_idx]

	a := mesh.vertices[tri.verts[0]]
	b := mesh.vertices[tri.verts[1]]
	c := mesh.vertices[tri.verts[2]]

	return {(a[0] + b[0] + c[0]) / 3.0, (a[1] + b[1] + c[1]) / 3.0, (a[2] + b[2] + c[2]) / 3.0}
}

distance3 :: proc(a, b: Vec3) -> f32 {
	dx := a[0] - b[0]
	dy := a[1] - b[1]
	dz := a[2] - b[2]

	return math.sqrt(dx * dx + dy * dy + dz * dz)
}

heuristic :: proc(mesh: ^NavMesh, tri_a, tri_b: int) -> f32 {
	return distance3(triangle_center(mesh, tri_a), triangle_center(mesh, tri_b))
}

astar_triangles :: proc(mesh: ^NavMesh, start_tri: int, goal_tri: int) -> []int {
	path: []int

	// open set
	// closed set
	// parent array

	// standard A*

	// neighbors are:
	//
	// tri.neighbors[0]
	// tri.neighbors[1]
	// tri.neighbors[2]

	return path
}

Portal :: struct {
	left:  Vec3,
	right: Vec3,
}

// portals := []Portal{
//     {start, start},
//     {edge0_a, edge0_b},
//     {edge1_a, edge1_b},
//     {edge2_a, edge2_b},
//     {goal, goal},
// }

triarea2 :: proc(a, b, c: Vec3) -> f32 {
	abx := b[0] - a[0]
	abz := b[2] - a[2]

	acx := c[0] - a[0]
	acz := c[2] - a[2]

	return acx * abz - abx * acz
}

string_pull :: proc(portals: []Portal) -> [dynamic]Vec3 {

	// path := make([]Vec3, 0)
	path: [dynamic]Vec3

	apex := portals[0].left
	left := portals[0].left
	right := portals[0].right

	apex_idx := 0
	left_idx := 0
	right_idx := 0

	append(&path, apex)

	for i in 1 ..< len(portals) {

		new_left := portals[i].left
		new_right := portals[i].right

		//
		// tighten right edge
		//

		if triarea2(apex, right, new_right) <= 0 {

			if apex == right || triarea2(apex, left, new_right) > 0 {

				right = new_right
				right_idx = i

			} else {

				append(&path, left)

				apex = left

				apex_idx = left_idx

				left = apex
				right = apex

				left_idx = apex_idx
				right_idx = apex_idx

				// i = apex_idx
				continue
			}
		}

		//
		// tighten left edge
		//

		if triarea2(apex, left, new_left) >= 0 {

			if apex == left || triarea2(apex, right, new_left) < 0 {

				left = new_left
				left_idx = i

			} else {

				append(&path, right)

				apex = right

				apex_idx = right_idx

				left = apex
				right = apex

				left_idx = apex_idx
				right_idx = apex_idx

				// i = apex_idx
				continue
			}
		}
	}

	append(&path, portals[len(portals) - 1].left)

	return path
}
