package survival

import "core:fmt"
import "core:math"
import "core:math/fixed"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import stbi "vendor:stb/image"

Vec4 :: [4]f32
Vec3 :: [3]f32
Vec2 :: [2]f32
Mat4 :: matrix[4, 4]f32

Vertex :: struct {
	position: Vec3,
	uv:       Vec2,
}

Mesh :: struct {
	vertices: []Vertex,
	indices:  []u32,
}

earth_radius: f32 : 6371
earth_circumference: f32 : 40960

// globe_layer_separation: f32 = 0.01
globe_layer_separation: f32 : 0.0006

globe_program: u32
globe_radius: f32 : 1
globe_spin_angle: f32 = 90
globe_tilt_angle: f32 = -60
globe_max_tilt_abs: f32 : 90

globe_ocean_vao: u32
globe_ocean_mesh: Mesh
globe_ocean_radius: f32 : globe_radius - globe_layer_separation

globe_land_segments :: 1024
globe_land_rings :: globe_land_segments / 2
globe_land_vao: u32
globe_land_mesh: Mesh
globe_land_radius: f32 : globe_radius

globe_edit_area_segments :: globe_land_segments
globe_edit_area_rings :: globe_land_rings
globe_edit_area_vao: u32
globe_edit_area_mesh: Mesh
globe_edit_area_radius: f32 : globe_land_radius + globe_layer_separation
// globe_edit_area_radius: f32 = globe_ocean_radius

globe_grid_rings :: 32
globe_grid_vao: u32
globe_grid_mesh: Mesh
globe_grid_radius: f32 : globe_radius + globe_layer_separation
// globe_grid_radius: f32 = globe_radius

// Width in segments
tile_width_per_ring: [globe_land_rings]int

globe_init_tiles :: proc() {
	// fmt.printfln("Ring\tR len\tT width 1\tT width 2\t Final W\tFinal T")
	// fmt.printfln("-------------------------")
	rings := globe_land_rings
	segs := globe_land_segments
	segs_per_tile := 1
	step := 1
	// for y in 0 ..< globe_land_rings {
	start_y := rings / 2
	tile_width_per_ring[0] = 1
	tile_width_per_ring[start_y] = 1
	tile_width := 0
	max_tile_width := 8
	for i := 0; i < start_y; i += step {
		y := start_y - i
		ring_length_bottom := ring_len(y, rings) * earth_circumference
		ring_length_top := ring_len(y - step, rings) * earth_circumference

		tile_width_bottom := ring_length_bottom / f32(segs)
		tile_width_top := ring_length_top / f32(segs)

		tile_width_bottom2 := ring_length_bottom / (f32(segs) / 2)
		tile_width_top2 := ring_length_top / (f32(segs) / 2)

		diff1 := math.abs(40 - (tile_width_bottom + tile_width_top) / 2)
		diff2 := math.abs(40 - (tile_width_bottom2 + tile_width_top2) / 2)

		conc_width := tile_width_bottom
		conc_tiles := int(ring_length_bottom / tile_width_bottom)

		if diff2 < diff1 {
			conc_width = tile_width_bottom2
			conc_tiles = int(ring_length_bottom / tile_width_bottom2)
			segs = segs / 2
		}

		if tile_width < max_tile_width {
			tile_width = globe_land_segments / conc_tiles
		}

		// fmt.printfln(
		// 	"%d:\t%.0f\t%.2f - %.2f\t%.2f - %.2f\t%.2f\t%d",
		// 	y,
		// 	ring_length_bottom,
		// 	tile_width_bottom,
		// 	tile_width_top,
		// 	tile_width_bottom2,
		// 	tile_width_top2,
		// 	conc_width,
		// 	conc_tiles,
		// )

		// tile_width = globe_land_segments / conc_tiles

		// fmt.println(y, segs, conc_tiles, tile_width)
		// fmt.println(y, globe_land_segments, conc_tiles, tile_width)

		tile_width_per_ring[start_y + i] = tile_width
		tile_width_per_ring[y] = tile_width
	}

	// for width, y in tile_width_per_ring {
	// 	fmt.println(y, width)
	// }
}

globe_init :: proc() {
	globe_init_tiles()

	shaders_ok: bool
	globe_program, shaders_ok = gl.load_shaders_file("./shaders/globe.vs", "./shaders/globe.fs")
	if !shaders_ok {
		fmt.println("Shaders not ok")
		os.exit(-1)
	}

	globe_ocean_mesh = generate_uv_sphere(
		globe_grid_rings * 2,
		globe_grid_rings,
		globe_ocean_radius,
	)
	globe_init_layer(&globe_ocean_vao, &globe_ocean_mesh, globe_ocean_radius)

	land: Land = {
		start_ring    = 60,
		// start_ring    = globe_land_rings - globe_land_rings / 5,

		// Need to make sure the start segment is not inside of a tile
		// start_segment = globe_land_segments - 2,
		start_segment = 0,
		rows          = []LandRow {
			{start = 0, width = 2},
			{start = 1, width = 3},
			{start = 0, width = 5},
			{start = 1, width = 2},
		},
	}

	globe_land_mesh = globe_generate_land(
		globe_land_segments,
		globe_land_rings,
		globe_land_radius,
		land,
	)
	globe_init_layer(&globe_land_vao, &globe_land_mesh, globe_land_radius)

	globe_edit_area_mesh = globe_generate_edit_area(
		globe_edit_area_segments,
		globe_edit_area_rings,
		globe_edit_area_radius,
		land,
	)
	globe_init_layer(&globe_edit_area_vao, &globe_edit_area_mesh, globe_edit_area_radius)

	globe_grid_mesh = globe_generate_grid(
		globe_grid_rings * 2,
		globe_grid_rings,
		globe_grid_radius,
	)
	globe_init_layer(&globe_grid_vao, &globe_grid_mesh, globe_grid_radius)
}

globe_init_layer :: proc(vao: ^u32, mesh: ^Mesh, radius: f32) {
	vbo: u32
	ebo: u32

	gl.GenVertexArrays(1, vao)
	gl.GenBuffers(1, &vbo)
	gl.GenBuffers(1, &ebo)

	gl.BindVertexArray(vao^)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(mesh.vertices) * size_of(Vertex),
		raw_data(mesh.vertices),
		gl.STATIC_DRAW,
	)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(mesh.indices) * size_of(u32),
		raw_data(mesh.indices),
		gl.STATIC_DRAW,
	)

	stride := i32(size_of(Vertex))

	// position
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, stride, uintptr(0))
	gl.EnableVertexAttribArray(0)

	// UV
	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, stride, uintptr(12))
	gl.EnableVertexAttribArray(1)

	gl.BindVertexArray(0)
}

globe_draw :: proc() {
	gl.UseProgram(globe_program)

	// shader_set_int(program, "texture_sampler", 0)

	view := get_view()

	projection := get_projection()

	model := get_model()

	shader_set_mat4(globe_program, "view", view)
	shader_set_mat4(globe_program, "projection", projection)
	shader_set_mat4(globe_program, "model", model)

	globe_draw_area(globe_ocean_vao, globe_ocean_mesh, {0.4, 0.9, 1, 1})
	globe_draw_area(globe_land_vao, globe_land_mesh, {0.8, 0.6, 0.4, 1})
	globe_draw_edit_area()
	// globe_draw_grid()
}

globe_draw_area :: proc(vao: u32, mesh: Mesh, color: Vec4) {
	gl.BindVertexArray(vao)
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
	shader_set_vec4(globe_program, "color", color)
	gl.DrawElements(gl.TRIANGLES, i32(len(mesh.indices)), gl.UNSIGNED_INT, nil)
}

globe_draw_edit_area :: proc() {
	gl.BindVertexArray(globe_edit_area_vao)
	shader_set_vec4(globe_program, "color", glsl.vec4({0, 0, 0, 1}))
	gl.DrawElements(gl.LINES, i32(len(globe_edit_area_mesh.indices)), gl.UNSIGNED_INT, nil)
}

globe_draw_grid :: proc() {
	gl.BindVertexArray(globe_grid_vao)
	// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	shader_set_vec4(globe_program, "color", glsl.vec4({0, 0, 0, 1}))
	// gl.DrawElements(gl.TRIANGLES, i32(len(globe_grid_mesh.indices)), gl.UNSIGNED_INT, nil)
	// gl.LineWidth(1.0)
	gl.DrawElements(gl.LINES, i32(len(globe_grid_mesh.indices)), gl.UNSIGNED_INT, nil)
}

generate_uv_sphere :: proc(segments: int, rings: int, radius: f32) -> Mesh {
	indices_per_vertex := 6

	vertex_count := (segments + 1) * (rings + 1)
	index_count := segments * rings * indices_per_vertex

	vertices := make([]Vertex, vertex_count)
	indices := make([]u32, index_count)

	vertex_index := 0

	for y in 0 ..= rings {
		// 0 = south pole
		// 1 = nouth pole
		v := f32(y) / f32(rings)

		theta := v * math.PI
		// fmt.printfln("%d: %.0f", y, lat_length(theta, 40000))

		sin_theta := f32(math.sin(theta))
		cos_theta := f32(math.cos(theta))

		for x in 0 ..= segments {
			u := f32(x) / f32(segments)

			phi := u * 2.0 * math.PI

			sin_phi := f32(math.sin(phi))
			cos_phi := f32(math.cos(phi))

			// Unit sphere position
			px := -sin_theta * cos_phi
			py := -cos_theta
			pz := sin_theta * sin_phi

			position := Vec3{px * radius, py * radius, pz * radius}

			vertices[vertex_index] = Vertex {
				position = position,
				uv       = Vec2{u, v},
			}

			vertex_index += 1
		}
	}

	index := 0

	for y in 0 ..< rings {
		for x in 0 ..< segments {
			bottom_left := u32(y * (segments + 1) + x)
			bottom_right := bottom_left + 1
			top_left := u32((y + 1) * (segments + 1) + x)
			top_right := top_left + 1

			// First triangle
			indices[index + 0] = bottom_left
			indices[index + 1] = top_left
			indices[index + 2] = bottom_right

			// Second triangle
			indices[index + 3] = bottom_right
			indices[index + 4] = top_left
			indices[index + 5] = top_right

			index += indices_per_vertex
		}
	}

	return Mesh{vertices = vertices, indices = indices}
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

globe_generate_land :: proc(segments: int, rings: int, radius: f32, land: Land) -> Mesh {
	area_start_ring := land.start_ring
	area_start_segment := land.start_segment

	area_rows := len(land.rows)
	area_cols_tiles := get_land_width(land)

	// fmt.println("area_start_ring", area_start_ring)
	// fmt.println("area_rows", area_rows)
	// fmt.println("area_cols", area_cols)

	indices_per_tile := 6
	// vertex_count := (area_rows + 1) * (area_cols_tiles + 1)

	index_count := 0
	area_cols_segments := 0
	for row, i in land.rows {
		// for y := area_start_ring; y < area_start_ring + len(land.rows); y += 1 {
		ring := area_start_ring + i
		index_count += row.width * indices_per_tile
		segments_in_the_row := tile_width_per_ring[ring] * area_cols_tiles
		// fmt.println(segments_in_the_row, tile_width_per_ring[ring], area_cols_tiles)
		// fmt.println(ring, segments_in_the_row, tile_width_per_ring[ring], area_cols_tiles)
		if segments_in_the_row > area_cols_segments {
			area_cols_segments = segments_in_the_row
		}
	}
	vertex_count := (area_rows + 1) * (area_cols_segments + 1)

	// fmt.println("index_count", index_count)

	vertices := make([]Vertex, vertex_count)
	indices := make([]u32, index_count)

	// fmt.println(vertex_count)

	vertex_index := 0

	for y in area_start_ring ..= area_start_ring + area_rows {
		// fmt.println(y)
		// 0 = south pole
		// 1 = nouth pole
		v := f32(y) / f32(rings)

		theta := v * math.PI

		sin_theta := f32(math.sin(theta))
		cos_theta := f32(math.cos(theta))

		// area_cols_segments := tile_width_per_ring[y] * area_cols_tiles
		// segment := area_start_segment

		// Either need to use the area_cols_segments here or make the vertices span multiple segments
		// for x in area_start_segment ..= area_start_segment + area_cols_tiles {
		for x in area_start_segment ..= area_start_segment + area_cols_segments {
			// fmt.println(x)

			u := f32(x) / f32(segments)

			phi := u * 2.0 * math.PI

			sin_phi := f32(math.sin(phi))
			cos_phi := f32(math.cos(phi))

			// Unit sphere position
			px := -sin_theta * cos_phi
			py := -cos_theta
			pz := sin_theta * sin_phi

			position := Vec3{px * radius, py * radius, pz * radius}

			vertices[vertex_index] = Vertex {
				position = position,
				uv       = Vec2{u, v},
			}

			vertex_index += 1
		}
	}

	index := 0

	for row, y in land.rows {
		// vertices_per_row := area_cols_tiles + 1
		vertices_per_row := area_cols_segments + 1
		ring := area_start_ring + y
		vertices_per_tile := tile_width_per_ring[ring]
		// fmt.println(vertices_per_tile)
		for x in row.start ..< row.start + row.width {
			bottom_left := u32(y * vertices_per_row + x * vertices_per_tile)
			// bottom_right := bottom_left + 1
			bottom_right := bottom_left + u32(vertices_per_tile)
			top_left := u32((y + 1) * vertices_per_row + x * vertices_per_tile)
			// top_right := top_left + 1
			top_right := top_left + u32(vertices_per_tile)

			// First triangle
			indices[index + 0] = bottom_left
			indices[index + 1] = top_left
			indices[index + 2] = bottom_right

			// Second triangle
			indices[index + 3] = bottom_right
			indices[index + 4] = top_left
			indices[index + 5] = top_right

			index += indices_per_tile
		}
	}

	// fmt.printfln("Ring\tR len\tT width 1\tT width 2\t Final W\tFinal T")
	// fmt.printfln("-------------------------")
	// segs := segments
	// step := 1
	// tile_size := earth_circumference / f32(segments)
	// for y := 256; y > 0; y -= step {
	// 	ring_length_bottom := ring_len(y, rings) * earth_circumference
	// 	ring_length_top := ring_len(y - step, rings) * earth_circumference

	// 	tile_width_bottom := ring_length_bottom / f32(segs)
	// 	tile_width_top := ring_length_top / f32(segs)

	// 	tile_width_bottom2 := ring_length_bottom / (f32(segs) / 2)
	// 	tile_width_top2 := ring_length_top / (f32(segs) / 2)

	// 	diff1 := math.abs(40 - (tile_width_bottom + tile_width_top) / 2)
	// 	diff2 := math.abs(40 - (tile_width_bottom2 + tile_width_top2) / 2)

	// 	conc_width := tile_width_bottom
	// 	conc_tiles := ring_length_bottom / tile_width_bottom
	// 	if diff2 < diff1 {
	// 		conc_width = tile_width_bottom2
	// 		conc_tiles = ring_length_bottom / tile_width_bottom2
	// 		segs = segs / 2
	// 	}

	// 	fmt.printfln(
	// 		"%d:\t%.0f\t%.2f - %.2f\t%.2f - %.2f\t%.2f\t%.2f",
	// 		y,
	// 		ring_length_bottom,
	// 		tile_width_bottom,
	// 		tile_width_top,
	// 		tile_width_bottom2,
	// 		tile_width_top2,
	// 		conc_width,
	// 		conc_tiles,
	// 	)
	// }

	return Mesh{vertices = vertices, indices = indices}
}

globe_generate_edit_area :: proc(segments: int, rings: int, radius: f32, land: Land) -> Mesh {
	pole_rings := 10
	max_editable_ring := rings - pole_rings

	buffer := 10
	buffer_y := 10
	// bottom_buffer := min(land.start_ring, buffer)
	bottom_buffer := min(land.start_ring - pole_rings, buffer_y)
	// bottom_buffer := min(land.start_ring, 60)
	// top_buffer := min(rings - land.start_ring + len(land.rows), buffer)
	top_buffer := min(rings - land.start_ring + len(land.rows), buffer_y)
	// top_buffer := min(rings - (land.start_ring + len(land.rows)), 80)
	// top_buffer := min(max_editable_ring - (land.start_ring + len(land.rows)), 20)
	land_width := get_land_width(land)
	// fmt.println("land_width", land_width)

	edit_area_start_ring := land.start_ring - bottom_buffer
	edit_area_width := land_width + buffer * 2
	edit_area_height := bottom_buffer + len(land.rows) + top_buffer
	// fmt.println("edit_area_width", edit_area_width)

	indices_per_vertex := 4
	// index_count :=
	// 	edit_area_width * edit_area_height * indices_per_vertex +
	// 	(edit_area_width + edit_area_height) * 2
	max_segments_per_tile := 0
	for ring in edit_area_start_ring ..< edit_area_start_ring + edit_area_height {
		segments_per_tile := tile_width_per_ring[ring]
		max_segments_per_tile = max(max_segments_per_tile, segments_per_tile)
	}

	edit_area_start_segment := land.start_segment - buffer * max_segments_per_tile
	edit_area_segments := edit_area_width * max_segments_per_tile

	// index_count := (edit_area_width + edit_area_height) * 2
	index_count := edit_area_height * 2
	// index_count := 0
	tiles_per_final_row := 0
	for ring in edit_area_start_ring ..< edit_area_start_ring + edit_area_height {
		segments_per_tile := tile_width_per_ring[ring]
		tiles_per_row := edit_area_segments / segments_per_tile
		index_count += tiles_per_row * indices_per_vertex
		tiles_per_final_row = tiles_per_row
	}
	index_count += tiles_per_final_row * 2

	fmt.println(index_count)
	vertex_count := (edit_area_segments + 1) * (edit_area_height + 1)

	indices := make([]u32, index_count)
	vertices := make([]Vertex, vertex_count)

	vertex_index := 0

	for y in edit_area_start_ring ..= edit_area_start_ring + edit_area_height {
		// 0 = south pole
		// 1 = nouth pole

		v := f32(y) / f32(rings)

		theta := v * math.PI

		sin_theta := f32(math.sin(theta))
		cos_theta := f32(math.cos(theta))
		// fmt.println(edit_area_start_segment, edit_area_segments)

		for x in edit_area_start_segment ..= edit_area_start_segment + edit_area_segments {
			u := f32(x) / f32(segments)

			phi := u * 2.0 * math.PI

			sin_phi := f32(math.sin(phi))
			cos_phi := f32(math.cos(phi))

			// Unit sphere position
			px := -sin_theta * cos_phi
			py := -cos_theta
			pz := sin_theta * sin_phi

			position := Vec3{px * radius, py * radius, pz * radius}

			vertices[vertex_index] = Vertex {
				position = position,
				uv       = Vec2{u, v},
			}

			vertex_index += 1
		}
	}

	index := 0

	for y in 0 ..< edit_area_height {
		// for y in 0 ..< 7 {
		vertices_per_row := edit_area_segments + 1
		ring := edit_area_start_ring + y
		vertices_per_tile := tile_width_per_ring[ring]

		segments_per_tile := tile_width_per_ring[ring]
		tiles_per_row := edit_area_segments / segments_per_tile

		// row_width := vertices_per_tile
		// fmt.println(ring, vertices_per_tile)
		// for x in 0 ..< edit_area_width {
		// fmt.println(y, tiles_per_row)
		fmt.println(y, edit_area_height)
		for x in 0 ..< tiles_per_row {
			bottom_left := u32(y * vertices_per_row + x * vertices_per_tile)
			bottom_right := bottom_left + u32(vertices_per_tile)
			top_left := u32((y + 1) * vertices_per_row + x * vertices_per_tile)
			top_right := top_left + u32(vertices_per_tile)

			indices[index + 0] = top_left
			indices[index + 1] = bottom_left
			indices[index + 2] = bottom_left
			indices[index + 3] = bottom_right
			index += indices_per_vertex

			if y == edit_area_height - 1 {
				indices[index + 0] = top_left
				indices[index + 1] = top_right
				index += 2
			}

			// if x == edit_area_width - 1 {
			if x == tiles_per_row - 1 {
				indices[index + 0] = top_right
				indices[index + 1] = bottom_right
				index += 2

			}
		}
	}

	return Mesh{vertices = vertices, indices = indices}
}

globe_generate_grid :: proc(segments: int, rings: int, radius: f32) -> Mesh {
	// vertex_count := (segments1 + 1) * (rings1) + (segments2 + 1) * (rings2 + 1)
	vertex_count := (segments + 1) * (rings + 1)
	// fmt.println(vertex_count)

	vertices := make([]Vertex, vertex_count)

	vertex_index := 0

	for y in 0 ..= rings {
		// 0 = south pole
		// 1 = nouth pole

		// relative height of a ring
		v := f32(y) / f32(rings)

		theta := v * math.PI

		sin_theta := f32(math.sin(theta))
		cos_theta := f32(math.cos(theta))

		for x in 0 ..= segments {
			// relative width of a segment
			u := f32(x) / f32(segments)

			phi := u * 2.0 * math.PI

			sin_phi := f32(math.sin(phi))
			cos_phi := f32(math.cos(phi))

			// Unit sphere position
			px := -sin_theta * cos_phi
			py := -cos_theta
			pz := sin_theta * sin_phi

			position := Vec3{px * radius, py * radius, pz * radius}

			vertices[vertex_index] = Vertex {
				position = position,
				uv       = Vec2{u, v},
			}

			vertex_index += 1
		}
	}

	indices_per_vertex := 4

	// The middle half of the rings use all the segments.
	// The rest of the rings (closer to the poles) use only half of the segments.
	// index_count := (segments * rings / 2 + segments / 2 * rings / 2) * indices_per_vertex

	index_count := segments * rings * indices_per_vertex
	// fmt.println(index_count)

	indices := make([]u32, index_count)


	index := 0

	for y in 0 ..< rings {
		// if y > rings / 4 && y < (rings / 4 * 3) {
		for x in 0 ..< segments {
			bottom_left := u32(y * (segments + 1) + x)
			bottom_right := bottom_left + 1
			top_left := u32((y + 1) * (segments + 1) + x)
			top_right := top_left + 1

			// Meridian
			indices[index + 0] = top_left
			indices[index + 1] = bottom_left
			// Parallel
			indices[index + 2] = bottom_left
			indices[index + 3] = bottom_right

			index += indices_per_vertex
		}
	}

	return Mesh{vertices = vertices, indices = indices}
}

// Relative to equator length
ring_len :: proc(ring: int, rings: int) -> f32 {
	return math.sin(f32(ring) / f32(rings) * math.PI)
}

// globe_init_texture :: proc() {
// 	// TEXTURE
// 	globe_texture: u32

// 	gl.GenTextures(1, &globe_texture)
// 	gl.BindTexture(gl.TEXTURE_2D, globe_texture)
// 	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
// 	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
// 	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
// 	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

// 	stbi.set_flip_vertically_on_load(1)
// 	width, height, nrChannels: i32
// 	// data := stbi.load("./Ground075_1K-JPG_Color.jpg", &width, &height, &nrChannels, 0)
// 	data := stbi.load("./world.jpg", &width, &height, &nrChannels, 0)
// 	if data == nil {
// 		fmt.println("Failed to load texture")
// 		os.exit(-1)
// 	}

// 	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
// 	gl.GenerateMipmap(gl.TEXTURE_2D)

// 	stbi.image_free(data)
// }
