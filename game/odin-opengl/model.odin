package game

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
