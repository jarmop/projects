package game


create_rectangle :: proc(d: [3]f32, vertices: ^[rectangle_vertex_count]Vertex) {
	faces := []Face {
		// top and bottom (XZ)
		{
			normal = {0.0, 1.0, 0.0},
			vertices = {
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
			normal = {0.0, 0.0, 1.0},
			vertices = {
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
			normal = {1.0, 0.0, 0.0},
			vertices = {
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
		for j in 0 ..= 5 {
			vertices[i].normal = -f.normal
			vertices[i].pos = f.vertices[j]
			i += 1
		}
		for j in 0 ..= 5 {
			vertices[i].normal = f.normal
			vertices[i].pos = f.vertices[j] + (d * f.normal)
			i += 1
		}
	}
}
