package game

import m "core:math/linalg"

create_grid :: proc(vertices: []Vertex) {
	uv_low: f32 = 0.0
	uv_high: f32 = 1.0
	// uv_high: f32 = 0.0
	normal := [3]f32{0.0, 1.0, 0.0}
	top_left: Vertex = {
		pos     = {0.0, 0.0, 0.0},
		normal  = normal,
		texture = {uv_low, uv_high},
	}
	top_right: Vertex = {
		pos     = {1.0, 0.0, 0.0},
		normal  = normal,
		texture = {uv_high, uv_high},
	}
	bottom_right: Vertex = {
		pos     = {1.0, 0.0, 1.0},
		normal  = normal,
		texture = {uv_high, uv_low},
	}
	bottom_left: Vertex = {
		pos     = {0.0, 0.0, 1.0},
		normal  = normal,
		texture = {uv_low, uv_low},
	}
	center: Vertex = {
		pos     = {0.5, 0.0, 0.5},
		normal  = normal,
		texture = {uv_high / 2, uv_high / 2},
	}
	grid_i := 0
	for i := 0; i < GRID_COUNT; i += 1 {
		top_left.pos.x = 0
		top_right.pos.x = 1
		bottom_left.pos.x = 0
		bottom_right.pos.x = 1
		center.pos.x = 0.5
		for j := 0; j < GRID_COUNT; j += 1 {
			top_left.pos.y = height_map[i][j]
			top_right.pos.y = height_map[i][j + 1]
			bottom_left.pos.y = height_map[i + 1][j]
			bottom_right.pos.y = height_map[i + 1][j + 1]
			center.pos.y = 0
			// y: f32 = 1
			foo: f32 = 2 * y
			if top_left.pos.y + bottom_right.pos.y == foo ||
			   bottom_left.pos.y + top_right.pos.y == foo {
				center.pos.y = y
			} else if (top_left.pos.y + top_right.pos.y == foo ||
				   bottom_left.pos.y + bottom_right.pos.y == foo ||
				   top_left.pos.y + bottom_left.pos.y == foo ||
				   top_right.pos.y + bottom_right.pos.y == foo) {
				center.pos.y = y / 2
			}

			// TOP
			vertices[grid_i + 0] = top_left
			vertices[grid_i + 1] = top_right
			vertices[grid_i + 2] = center

			// RIGHT
			vertices[grid_i + 3] = top_right
			vertices[grid_i + 4] = bottom_right
			vertices[grid_i + 5] = center

			// BOTTOM
			vertices[grid_i + 6] = bottom_right
			vertices[grid_i + 7] = bottom_left
			vertices[grid_i + 8] = center

			// LEFT
			vertices[grid_i + 9] = bottom_left
			vertices[grid_i + 10] = top_left
			vertices[grid_i + 11] = center

			// Calculate normals
			for k := 0; k < 12; k += 3 {
				ti := grid_i + k
				v0 := vertices[ti + 0].pos
				v1 := vertices[ti + 1].pos
				v2 := vertices[ti + 2].pos
				normal := -m.normalize(m.cross(v1 - v0, v2 - v0))
				vertices[ti + 0].normal = normal
				vertices[ti + 1].normal = normal
				vertices[ti + 2].normal = normal
				// fmt.println(normal)
			}

			grid_i += 12

			// for v in vertices {
			// 	fmt.println(v.pos)
			// }
			// fmt.println("****************")
			// fmt.println(grid_i)
			// fmt.println("****************")

			top_left.pos.x += GRID_SIZE
			top_right.pos.x += GRID_SIZE
			bottom_left.pos.x += GRID_SIZE
			bottom_right.pos.x += GRID_SIZE
			center.pos.x += GRID_SIZE
		}

		top_left.pos.z += GRID_SIZE
		top_right.pos.z += GRID_SIZE
		bottom_left.pos.z += GRID_SIZE
		bottom_right.pos.z += GRID_SIZE
		center.pos.z += GRID_SIZE

		// fmt.println(top_left.pos.z)
	}
}

create_cuboid :: proc(
	d: [3]f32,
	vertices: ^[CUBOID_VERTEX_COUNT]Vertex,
	texture_repeat: int,
	texture_faces: [3]bool,
) {
	uv_low: f32 = 0.0
	uv_high := f32(texture_repeat)
	faces := []Face {
		// top and bottom (XZ)
		{
			normal    = {0.0, 1.0, 0.0},
			textures  = {
				// Comment needed to fix formatting
				// {0.0, 1.0},
				// {1.0, 1.0},
				// {1.0, 0.0},
				// {1.0, 0.0},
				// {0.0, 0.0},
				// {0.0, 1.0},
				{uv_low, uv_high},
				{uv_high, uv_high},
				{uv_high, uv_low},
				{uv_high, uv_low},
				{uv_low, uv_low},
				{uv_low, uv_high},
			},
			positions = {
				{0.0, 0.0, 0.0},
				{d.x, 0.0, 0.0},
				{d.x, 0.0, d.z},
				{d.x, 0.0, d.z},
				{0.0, 0.0, d.z},
				{0.0, 0.0, 0.0},
			},
		},
		// Front and back (XY)
		{
			normal    = {0.0, 0.0, 1.0},
			textures  = {
				// Comment needed to fix formatting
				// {0.0, 0.0},
				// {1.0, 0.0},
				// {1.0, 1.0},
				// {1.0, 1.0},
				// {0.0, 1.0},
				// {0.0, 0.0},
				{uv_low, uv_high},
				{uv_high, uv_high},
				{uv_high, uv_low},
				{uv_high, uv_low},
				{uv_low, uv_low},
				{uv_low, uv_high},
			},
			positions = {
				{0.0, 0.0, 0.0},
				{d.x, 0.0, 0.0},
				{d.x, d.y, 0.0},
				{d.x, d.y, 0.0},
				{0.0, d.y, 0.0},
				{0.0, 0.0, 0.0},
			},
		},
		// left and right (YZ)
		{
			normal    = {1.0, 0.0, 0.0},
			textures  = {
				// Comment needed to fix formatting
				// {1.0, 0.0},
				// {1.0, 1.0},
				// {0.0, 1.0},
				// {0.0, 1.0},
				// {0.0, 0.0},
				// {1.0, 0.0},
				{uv_low, uv_high},
				{uv_high, uv_high},
				{uv_high, uv_low},
				{uv_high, uv_low},
				{uv_low, uv_low},
				{uv_low, uv_high},
			},
			positions = {
				{0.0, 0.0, 0.0},
				{0.0, d.y, 0.0},
				{0.0, d.y, d.z},
				{0.0, d.y, d.z},
				{0.0, 0.0, d.z},
				{0.0, 0.0, 0.0},
			},
		},
	}
	i := 0
	for f, fi in faces {
		// The first side
		for j in 0 ..= 5 {
			vertices[i].pos = f.positions[j]
			vertices[i].normal = -f.normal
			if texture_faces[fi] {
				vertices[i].texture = f.textures[j]
			}
			i += 1
		}
		// The opposite side
		for j in 0 ..= 5 {
			vertices[i].pos = f.positions[j] + (d * f.normal)
			vertices[i].normal = f.normal
			if texture_faces[fi] {
				vertices[i].texture = f.textures[j]
			}
			i += 1
		}
	}
}
