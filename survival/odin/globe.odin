package survival

import "core:fmt"
import "core:math"
import "core:math/fixed"
import "core:math/linalg"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import stbi "vendor:stb/image"

earth_radius: f32 : 6371
earth_circumference: f32 : 40960

// globe_layer_separation: f32 = 0.01
globe_layer_separation: f32 : 0.0006
// globe_layer_separation: f32 : 0.00001
// globe_layer_separation: f32 : 0.001

globe_program: u32
globe_radius: f32 : 1
globe_rings :: 32
globe_segments :: globe_rings * 2

globe_ocean_vao: u32
globe_ocean_mesh: Mesh
globe_ocean_radius: f32 : globe_radius - globe_layer_separation
globe_ocean_rings := globe_rings
globe_ocean_segments := globe_segments

globe_land_segments :: 1024
globe_land_rings :: globe_land_segments / 2
globe_land_vao: u32
globe_land_ebo: u32
globe_land_mesh: Mesh
globe_land_radius: f32 : globe_radius

globe_edit_area_segments :: globe_land_segments
globe_edit_area_rings :: globe_land_rings
globe_edit_area_vao: u32
globe_edit_area_mesh: Mesh
// globe_edit_area_radius: f32 : globe_land_radius + globe_layer_separation
globe_edit_area_radius: f32 : globe_land_radius
// globe_edit_area_radius: f32 = globe_ocean_radius

globe_grid_rings := globe_rings
globe_grid_vao: u32
globe_grid_mesh: Mesh
globe_grid_radius: f32 : globe_radius + globe_layer_separation
// globe_grid_radius: f32 = globe_radius

// Width in segments
tile_width_per_ring: [globe_land_rings]int
tile_width_per_ring_km: [globe_land_rings]f32

max_tile_width :: globe_land_segments / globe_segments
rings_per_plane :: globe_land_rings / globe_rings
segments_per_plane :: globe_land_segments / globe_segments

globe_init :: proc() {
	globe_init_tiles()
	// globe_init_planes()
	land_init()

	shaders_ok: bool
	globe_program, shaders_ok = gl.load_shaders_file("./shaders/globe.vs", "./shaders/globe.fs")
	if !shaders_ok {
		fmt.println("Shaders not ok")
		os.exit(-1)
	}

	globe_ocean_mesh = generate_uv_sphere(
		globe_ocean_segments,
		globe_ocean_rings,
		globe_ocean_radius,
	)
	globe_init_layer(&globe_ocean_vao, &globe_ocean_mesh)

	globe_land_mesh = globe_generate_land_on_planes(
		globe_segments,
		globe_rings,
		globe_radius,
		// globe_land_segments,
		// globe_land_rings,
		// globe_land_radius,
		land,
	)
	globe_init_land(&globe_land_mesh)

	// globe_land_mesh = globe_generate_land(
	// 	globe_land_segments,
	// 	globe_land_rings,
	// 	globe_land_radius,
	// 	land,
	// )
	// globe_init_layer(&globe_land_vao, &globe_land_mesh)

	globe_edit_area_mesh = globe_generate_edit_area(
		globe_edit_area_segments,
		globe_edit_area_rings,
		globe_edit_area_radius,
		land,
	)
	globe_init_layer(&globe_edit_area_vao, &globe_edit_area_mesh)

	globe_grid_mesh = globe_generate_grid(
		globe_grid_rings * 2,
		globe_grid_rings,
		globe_grid_radius,
	)
	globe_init_layer(&globe_grid_vao, &globe_grid_mesh)
}

// globe_init_planes :: proc() {
// 	for ring in 0 ..< globe_rings {
// 		ring_length_bottom := ring_len(ring, globe_rings) * earth_circumference
// 		ring_length_top := ring_len(ring + 1, globe_rings) * earth_circumference
// 		ring_length_avg := (ring_length_bottom + ring_length_top) / 2

// 		segment_width_avg := ring_length_avg / globe_land_segments
// 		segments_per_tile_avg := tile_width_avg_km / segment_width_avg

// 		segments_per_tile := 1
// 		diff: f32 = 9999
// 		for i := 1; i <= max_tile_width; i *= 2 {
// 			d := math.abs(tile_width_avg_km - f32(i) * segment_width_avg)
// 			if d < diff {
// 				diff = d
// 				segments_per_tile = i
// 			}
// 		}

// 		// fmt.printfln("%d\t%d", ring, segments_per_tile)

// 		tile_width_km := f32(segments_per_tile) * segment_width_avg

// 		// for r in ring ..< ring + rings_per_plane {
// 		for r in 0 ..< rings_per_plane {
// 			i := ring * rings_per_plane + r
// 			tile_width_per_ring[i] = segments_per_tile
// 			tile_width_per_ring_km[i] = tile_width_km
// 			// fmt.println(i, segments_per_tile, tile_width_km)
// 		}
// 	}
// }

globe_init_tiles :: proc() {
	// fmt.printfln("Ring\tR len\tT width 1\tT width 2\t Final W\tFinal T")
	// fmt.printfln("-------------------------")
	rings := globe_land_rings
	segs := globe_land_segments
	segs_per_tile := 1
	step := 1
	// for y in 0 ..< globe_land_rings {
	equator_ring := rings / 2
	max_tile_width := 8
	tile_width_per_ring[0] = max_tile_width
	tile_width_per_ring[equator_ring] = 1
	tile_width := 0
	// The loop goes through only one half of the rings as they mirror each other
	// ring_north 0 --> 255
	// ring_south 256 --> 1
	// tile_width_per_ring[equator_ring + ring_north]
	// tile_width_per_ring[ring_south]
	for ring_north := 0; ring_north < equator_ring; ring_north += step {
		ring_south := equator_ring - ring_north
		ring_length_bottom := ring_len(ring_south, rings) * earth_circumference
		ring_length_top := ring_len(ring_south - step, rings) * earth_circumference

		tile_width_bottom := ring_length_bottom / f32(segs)
		tile_width_top := ring_length_top / f32(segs)

		tile_width_bottom2 := ring_length_bottom / (f32(segs) / 2)
		tile_width_top2 := ring_length_top / (f32(segs) / 2)

		diff1 := math.abs(tile_width_avg_km - (tile_width_bottom + tile_width_top) / 2)
		diff2 := math.abs(tile_width_avg_km - (tile_width_bottom2 + tile_width_top2) / 2)

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

		// fmt.println(y, tile_width)

		// tile_width = 1
		// conc_tiles = globe_land_segments

		tile_width_per_ring[equator_ring + ring_north] = tile_width
		tile_width_per_ring[ring_south] = tile_width

		tile_width_km := ring_length_bottom / f32(conc_tiles)
		tile_width_per_ring_km[equator_ring + ring_north] = tile_width_km
		tile_width_per_ring_km[ring_south] = tile_width_km
	}

	// for width, y in tile_width_per_ring {
	// 	fmt.println(y, width)
	// }
}

globe_init_land :: proc(mesh: ^Mesh) {
	vbo: u32

	// gl.GenVertexArrays(1, vao)
	gl.GenVertexArrays(1, &globe_land_vao)
	gl.GenBuffers(1, &vbo)
	gl.GenBuffers(1, &globe_land_ebo)

	gl.BindVertexArray(globe_land_vao)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(mesh.vertices) * size_of(Vertex),
		raw_data(mesh.vertices),
		gl.STATIC_DRAW,
	)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, globe_land_ebo)
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

globe_init_layer :: proc(vao: ^u32, mesh: ^Mesh) {
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
	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

	gl.UseProgram(globe_program)

	// shader_set_int(program, "texture_sampler", 0)

	view := get_view()

	projection := get_projection()

	model := get_model()

	shader_set_mat4(globe_program, "view", view)
	shader_set_mat4(globe_program, "projection", projection)
	shader_set_mat4(globe_program, "model", model)

	globe_draw_area(globe_ocean_vao, globe_ocean_mesh, {0.4, 0.9, 1, 1})
	// globe_draw_area(globe_land_vao, globe_land_mesh, {0.8, 0.6, 0.4, 1})
	// globe_draw_area(globe_land_vao, globe_land_mesh, {0.3, 0.9, 0.5, 1})
	globe_draw_area(globe_land_vao, globe_land_mesh, {0.2, 0.6, 0.4, 1})
	globe_draw_edit_area()
	globe_draw_grid()
}

globe_draw_area :: proc(vao: u32, mesh: Mesh, color: Vec4) {
	gl.BindVertexArray(vao)
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
	shader_set_vec4(globe_program, "color", color)
	gl.DrawElements(gl.TRIANGLES, i32(len(mesh.indices)), gl.UNSIGNED_INT, nil)
}

globe_draw_edit_area :: proc() {

	gl.BindVertexArray(globe_edit_area_vao)
	shader_set_vec4(globe_program, "color", glsl.vec4({0, 0, 0, 0.1}))
	gl.LineWidth(1.0)
	gl.DrawElements(gl.LINES, i32(len(globe_edit_area_mesh.indices)), gl.UNSIGNED_INT, nil)
}

globe_draw_grid :: proc() {
	gl.BindVertexArray(globe_grid_vao)
	// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	color: f32 = 0
	shader_set_vec4(globe_program, "color", glsl.vec4({color, color, color, 1}))
	// gl.DrawElements(gl.TRIANGLES, i32(len(globe_grid_mesh.indices)), gl.UNSIGNED_INT, nil)
	gl.LineWidth(1.0)
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

globe_generate_land_indices :: proc(land: Land) -> []u32 {
	land_height_tiles := len(land.slices)
	land_width_tile_segments := get_land_width_segments(land)

	indices_per_vertex := 6

	tile_rings := land_height_tiles

	tile_segments := land_width_tile_segments

	tile_vertex_count_x := tile_segments + 1
	tile_vertex_count_y := tile_rings + 1

	tile_vertex_count := tile_vertex_count_x * tile_vertex_count_y
	tile_index_count := tile_segments * tile_rings * indices_per_vertex

	tile_indices := make([]u32, tile_index_count)

	tile_index := 0

	land_width_tiles := get_land_width(land)

	// fmt.println(land_width_tile_segments, land_width_tiles)

	// for y in 0 ..< tile_rings {
	for row in land.slices {
		// fmt.println("-------")

		y := row.ring

		ring := land.ring + y
		tile_width := tile_width_per_ring[ring]
		tiles := row.width / tile_width
		start_tile := row.segment / tile_width

		for x in start_tile ..< start_tile + tiles {
			// for x in start_tile ..< start_tile + 1 {
			// for x in 0 ..< 1 {
			bottom_left := u32(y * (tile_vertex_count_x) + x * tile_width)
			// bottom_left := u32(y * (segments_per_plane + 1) + x)
			bottom_right := bottom_left + u32(tile_width)
			top_left := u32((y + 1) * (tile_vertex_count_x) + x * tile_width)
			// top_left := u32((y + 1) * (segments_per_plane + 1) + x)
			top_right := top_left + u32(tile_width)

			// fmt.println(bottom_left, bottom_right, top_left, top_right)

			tile_indices[tile_index + 0] = bottom_left
			tile_indices[tile_index + 1] = top_left
			tile_indices[tile_index + 2] = bottom_right

			// Second triangle
			tile_indices[tile_index + 3] = bottom_right
			tile_indices[tile_index + 4] = top_left
			tile_indices[tile_index + 5] = top_right

			tile_index += indices_per_vertex
		}
	}

	return tile_indices
}

// Plane_segments and plane_rings define a plane. Tile_segments and tile_rings define a tile.
// Each plane is divided into 16 tile rings and 16/8/4/2/1 tile segments.
globe_generate_land_on_planes :: proc(segments: int, rings: int, radius: f32, land: Land) -> Mesh {
	land_height_tiles := len(land.slices)
	land_width_tile_segments := get_land_width_segments(land)

	start_plane_ring_f := f32(land.ring) / f32(globe_land_rings) * f32(rings)
	start_plane_ring := int(start_plane_ring_f)
	reminder := start_plane_ring_f - f32(start_plane_ring)

	end_plane_ring_f := f32(land.ring + land_height_tiles) / f32(globe_land_rings) * f32(rings)
	end_plane_ring := int(end_plane_ring_f)
	reminder2 := end_plane_ring_f - f32(end_plane_ring)

	start_plane_segment_f := f32(land.segment) / f32(globe_land_segments) * f32(segments)
	start_plane_segment := int(start_plane_segment_f)
	reminder_segment := start_plane_segment_f - f32(start_plane_segment)

	end_plane_segment_f :=
		f32(land.segment + land_width_tile_segments) / f32(globe_land_segments) * f32(segments)
	end_plane_segment := int(end_plane_segment_f)
	reminder_segment2 := end_plane_segment_f - f32(end_plane_segment)

	indices_per_vertex := 6

	plane_rings := end_plane_ring - start_plane_ring + 1
	plane_segments := end_plane_segment - start_plane_segment + 1

	plane_vertex_count := (plane_segments + 1) * (plane_rings + 1)
	plane_index_count := plane_segments * plane_rings * indices_per_vertex

	plane_vertices := make([]Vertex, plane_vertex_count)
	plane_indices := make([]u32, plane_index_count)

	plane_vertex_index := 0

	tile_rings := land_height_tiles

	tile_segments := land_width_tile_segments

	tile_vertex_count_x := tile_segments + 1
	tile_vertex_count_y := tile_rings + 1

	tile_vertex_count := tile_vertex_count_x * tile_vertex_count_y

	tile_vertices := make([]Vertex, tile_vertex_count)

	start_tile_ring := int(f32(rings_per_plane) * reminder)
	end_tile_ring := int(f32(rings_per_plane) * reminder2)
	start_tile_segment := int(f32(segments_per_plane) * reminder_segment)
	end_tile_segment := int(f32(segments_per_plane) * reminder_segment2)

	t_ring_start := start_tile_ring

	tile_vertex_index := 0
	tile_offset_y := 0

	for y, py in start_plane_ring ..= end_plane_ring + 1 {
		t_segment_start := start_tile_segment

		v := f32(y) / f32(rings)

		theta := v * math.PI

		sin_theta := f32(math.sin(theta))
		cos_theta := f32(math.cos(theta))

		tile_offset_x := 0

		segments_per_plane_f := f32(segments_per_plane)

		t_ring_end := y == end_plane_ring + 1 ? end_tile_ring : (rings_per_plane - 1)

		for x, px in start_plane_segment ..= end_plane_segment + 1 {
			u := f32(x) / f32(segments)

			phi := u * 2.0 * math.PI

			sin_phi := f32(math.sin(phi))
			cos_phi := f32(math.cos(phi))

			// Unit sphere position
			pos_x := -sin_theta * cos_phi
			pos_y := -cos_theta
			pos_z := sin_theta * sin_phi

			position := Vec3{pos_x * radius, pos_y * radius, pos_z * radius}

			plane_vertices[plane_vertex_index] = Vertex {
				position = position,
				uv       = Vec2{u, v},
			}

			plane_vertex_index += 1

			if py > 0 && px > 0 {
				t_segment_end :=
					x == end_plane_segment + 1 ? end_tile_segment : (segments_per_plane - 1)

				bottom_left_i := (py - 1) * (plane_segments + 1) + px - 1
				bottom_right_i := bottom_left_i + 1
				top_left_i := py * (plane_segments + 1) + px - 1
				top_right_i := top_left_i + 1

				bottom_left := plane_vertices[bottom_left_i]
				bottom_right := plane_vertices[bottom_right_i]
				top_left := plane_vertices[top_left_i]
				top_right := plane_vertices[top_right_i]


				left_step_up := (top_left.position - bottom_left.position) / segments_per_plane_f
				right_step_up :=
					(top_right.position - bottom_right.position) / segments_per_plane_f
				bottom_step_right :=
					(bottom_right.position - bottom_left.position) / segments_per_plane_f
				top_step_right := (top_right.position - top_left.position) / segments_per_plane_f

				for ty, ty_i in t_ring_start ..= t_ring_end {
					tile_vertex_index = tile_offset_y + ty_i * tile_vertex_count_x + tile_offset_x

					for tx, tx_i in t_segment_start ..= t_segment_end {
						tile_u := f32(land.segment + tx_i) / f32(globe_land_segments)
						tile_v := f32(land.ring + ty_i) / f32(globe_land_rings)

						left_up := bottom_left.position + left_step_up * f32(ty)
						right_up := bottom_right.position + right_step_up * f32(ty)
						step_right := (right_up - left_up) / segments_per_plane_f

						vertice := Vertex {
							position = bottom_left.position + left_step_up * f32(ty) + step_right * f32(tx),
							uv       = Vec2{tile_u, tile_v},
						}

						tile_vertices[tile_vertex_index] = vertice

						tile_vertex_index += 1
					}
				}
				t_segment_start = 0
				tile_offset_x = px * segments_per_plane - start_tile_segment
			}
		}
		tile_offset_y = tile_vertex_index
		if py > 0 {
			t_ring_start = 0
		}
	}

	tile_index := 0

	land_width_tiles := get_land_width(land)

	tile_indices := globe_generate_land_indices(land)

	index := 0

	return Mesh{vertices = tile_vertices, indices = tile_indices}
}

// globe_generate_land :: proc(segments: int, rings: int, radius: f32, land: Land) -> Mesh {
// 	area_start_ring := land.ring
// 	area_start_segment := land.segment

// 	area_rows := len(land.rows)
// 	area_width_km := get_land_width_km(land)

// 	indices_per_tile := 6

// 	index_count := 0
// 	area_cols_segments := 0
// 	for row, i in land.rows {
// 		ring := area_start_ring + i
// 		tile_width_km := tile_width_per_ring_km[ring]
// 		row_width_km := f32(row.width) * tile_width_avg_km
// 		tiles := int(math.round(row_width_km / tile_width_km))

// 		index_count += tiles * indices_per_tile

// 		start_km := f32(row.segment) * tile_width_avg_km
// 		start_tile := int(math.round(start_km / tile_width_km))

// 		tiles_in_the_row := start_tile + tiles

// 		segments_in_the_row := tile_width_per_ring[ring] * tiles_in_the_row
// 		if segments_in_the_row > area_cols_segments {
// 			area_cols_segments = segments_in_the_row
// 		}
// 	}
// 	vertex_count := (area_rows + 1) * (area_cols_segments + 1)
// 	vertices := make([]Vertex, vertex_count)
// 	indices := make([]u32, index_count)

// 	vertex_index := 0

// 	for y in area_start_ring ..= area_start_ring + area_rows {
// 		// 0 = south pole
// 		// 1 = nouth pole
// 		v := f32(y) / f32(rings)

// 		theta := v * math.PI

// 		sin_theta := f32(math.sin(theta))
// 		cos_theta := f32(math.cos(theta))

// 		// Either need to use the area_cols_segments here or make the vertices span multiple
// 		// segments, but then would need to have extra vertices at the tile width zone borders
// 		for x in area_start_segment ..= area_start_segment + area_cols_segments {
// 			// fmt.println(x)

// 			u := f32(x) / f32(segments)

// 			phi := u * 2.0 * math.PI

// 			sin_phi := f32(math.sin(phi))
// 			cos_phi := f32(math.cos(phi))

// 			// Unit sphere position
// 			px := -sin_theta * cos_phi
// 			py := -cos_theta
// 			pz := sin_theta * sin_phi

// 			position := Vec3{px * radius, py * radius, pz * radius}

// 			vertices[vertex_index] = Vertex {
// 				position = position,
// 				uv       = Vec2{u, v},
// 			}

// 			vertex_index += 1
// 		}
// 	}

// 	vertices_per_row := area_cols_segments + 1
// 	index := 0
// 	for row, y in land.rows {
// 		// vertices_per_row := area_cols_tiles + 1
// 		ring := area_start_ring + y
// 		vertices_per_tile := tile_width_per_ring[ring]
// 		tile_width_km := tile_width_per_ring_km[ring]
// 		// row_width_km := f32(row.width) * tile_width_km
// 		row_width_km := f32(row.width) * tile_width_avg_km
// 		tiles := int(math.round(row_width_km / tile_width_km))

// 		start_km := f32(row.segment) * tile_width_avg_km
// 		start_tile := int(math.round(start_km / tile_width_km))
// 		// fmt.println(vertices_per_tile)
// 		// for x in row.start ..< row.start + row.width {
// 		// for x in row.start ..< row.start + tiles {
// 		for x in start_tile ..< start_tile + tiles {
// 			bottom_left := u32(y * vertices_per_row + x * vertices_per_tile)
// 			// bottom_right := bottom_left + 1
// 			bottom_right := bottom_left + u32(vertices_per_tile)
// 			top_left := u32((y + 1) * vertices_per_row + x * vertices_per_tile)
// 			// top_right := top_left + 1
// 			top_right := top_left + u32(vertices_per_tile)

// 			// First triangle
// 			indices[index + 0] = bottom_left
// 			indices[index + 1] = top_left
// 			indices[index + 2] = bottom_right

// 			// Second triangle
// 			indices[index + 3] = bottom_right
// 			indices[index + 4] = top_left
// 			indices[index + 5] = top_right

// 			index += indices_per_tile
// 		}
// 	}

// 	return Mesh{vertices = vertices, indices = indices}
// }

globe_generate_edit_area :: proc(segments: int, rings: int, radius: f32, land: Land) -> Mesh {
	pole_rings := 10
	max_editable_ring := rings - pole_rings

	land_width_segs := get_land_width_segments(land)

	// The x buffer needs to be divisible by the biggest tile size (which is 8 segments currently)
	// buffer_segments_x := 16
	buffer_segments_left := max_tile_width + land.segment % max_tile_width
	buffer_segments_right := max_tile_width + (land.segment + land_width_segs) % max_tile_width
	buffer_segments_y := 500
	bottom_buffer := min(land.ring - pole_rings, buffer_segments_y)
	top_buffer := min(rings - pole_rings - (land.ring + len(land.slices)), buffer_segments_y)

	edit_area_start_ring := land.ring - bottom_buffer
	// edit_area_segments := land_width_segs + buffer_segments_x * 2
	edit_area_segments := land_width_segs + buffer_segments_left + buffer_segments_right
	edit_area_height := bottom_buffer + len(land.slices) + top_buffer

	// edit_area_start_segment := land.start_segment - buffer_segments_x
	edit_area_start_segment := land.segment - buffer_segments_left

	// edit_area_start_segment :=
	// 	((land.start_segment - buffer_segments_x) / max_tile_width) * max_tile_width
	// fmt.println(edit_area_start_segment)

	indices_per_vertex := 4
	index_count := edit_area_height * 2
	tiles_per_final_row := 0
	for ring in edit_area_start_ring ..< edit_area_start_ring + edit_area_height {
		segments_per_tile := tile_width_per_ring[ring]
		tiles_per_row := edit_area_segments / segments_per_tile
		index_count += tiles_per_row * indices_per_vertex
		tiles_per_final_row = tiles_per_row
	}

	index_count += tiles_per_final_row * 2
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

	vertices_per_row := edit_area_segments + 1
	index := 0

	for y in 0 ..< edit_area_height {
		ring := edit_area_start_ring + y
		segments_per_tile := tile_width_per_ring[ring]
		tiles_per_row := edit_area_segments / segments_per_tile
		vertices_per_tile := segments_per_tile

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

	// y_gap := (rings - 2) / 6
	// for y := 1; y < rings; y += y_gap {
	// 	for x in 0 ..< segments {
	// 		bottom_left := u32(y * (segments + 1) + x)
	// 		bottom_right := bottom_left + 1

	// 		indices[index + 0] = bottom_left
	// 		indices[index + 1] = bottom_right
	// 		index += 2
	// 	}
	// }

	// // x_gap := (rings - 2) / 6
	// x_gap := segments / 8
	// for y in 0 ..< rings {
	// 	for x := 0; x < segments; x += x_gap {
	// 		bottom_left := u32(y * (segments + 1) + x)
	// 		top_left := u32((y + 1) * (segments + 1) + x)

	// 		indices[index + 0] = top_left
	// 		indices[index + 1] = bottom_left
	// 		index += 2
	// 	}
	// }

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
