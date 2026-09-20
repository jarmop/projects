#+feature dynamic-literals

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

globe_program_texture: u32

globe_program: u32
globe_radius: f32 : 1
globe_rings :: 32
globe_segments :: globe_rings * 2

globe_ocean_vao: u32
globe_ocean_mesh: Mesh
globe_ocean_radius: f32 : globe_radius - globe_layer_separation
globe_ocean_rings := globe_rings
globe_ocean_segments := globe_segments

// globe_land_segments :: 1024
globe_land_segments :: 512
globe_land_rings :: globe_land_segments / 2
globe_land_vao: u32
globe_land_ebos: map[TERRAIN_TYPE]u32

globe_land_mesh: Land_Mesh
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

globe_latitudes_program: u32
globe_latitudes_vao: u32
globe_latitudes_rings :: 5
// globe_latitudes_vertices: [2 * (world_width + world_height + 2)]WorldVertex
globe_latitudes_vertices_per_ring :: 2 * globe_land_segments
globe_latitudes_vertices: [globe_latitudes_rings * globe_latitudes_vertices_per_ring]VertexColor
globe_latitudes_radius: f32 : globe_radius + globe_layer_separation

// Width in segments
tile_width_per_ring: [globe_land_rings]int
tile_width_per_ring_km: [globe_land_rings]f32

max_tile_width :: globe_land_segments / globe_segments
rings_per_plane :: globe_land_rings / globe_rings
tile_vertex_count_x := globe_land_segments + 1
tile_vertex_count_y := globe_land_rings + 1

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

	shaders_ok2: bool
	globe_latitudes_program, shaders_ok2 = gl.load_shaders_file(
		"./shaders/globe_latitudes.vs",
		"./shaders/globe_latitudes.fs",
	)
	if !shaders_ok2 {
		fmt.println("Shaders not ok")
		os.exit(-1)
	}

	shaders_ok3: bool
	globe_program_texture, shaders_ok3 = gl.load_shaders_file(
		"./shaders/texture.vs",
		"./shaders/texture.fs",
	)
	if !shaders_ok3 {
		fmt.println("Shaders not ok")
		os.exit(-1)
	}

	globe_ocean_mesh = generate_uv_sphere(
		globe_ocean_segments,
		globe_ocean_rings,
		globe_ocean_radius,
	)
	globe_init_ocean()

	globe_generate_vertices(globe_segments, globe_rings, globe_radius)
	globe_generate_land_indices()
	globe_init_land(&globe_land_mesh)
	// globe_init_texture_land()

	// globe_edit_area_mesh = globe_generate_edit_area(
	// 	globe_edit_area_segments,
	// 	globe_edit_area_rings,
	// 	globe_edit_area_radius,
	// 	land,
	// )
	// globe_init_layer(&globe_edit_area_vao, &globe_edit_area_mesh)

	globe_grid_mesh = globe_generate_grid(
		globe_grid_rings * 2,
		globe_grid_rings,
		globe_grid_radius,
	)
	globe_init_layer(&globe_grid_vao, &globe_grid_mesh)

	globe_generate_latitudes_vertices()
	globe_init_latitudes()
}

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

globe_init_land :: proc(mesh: ^Land_Mesh) {
	vbo: u32

	gl.GenVertexArrays(1, &globe_land_vao)
	gl.BindVertexArray(globe_land_vao)

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(mesh.vertices) * size_of(Vertex),
		raw_data(mesh.vertices),
		gl.STATIC_DRAW,
	)
	stride := i32(size_of(Vertex))
	// position
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, stride, uintptr(0))
	gl.EnableVertexAttribArray(0)
	// UV
	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, stride, uintptr(12))
	gl.EnableVertexAttribArray(1)

	for terrain_type, i in terrain_types {
		globe_land_ebos[terrain_type] = 0
		gl.GenBuffers(1, &globe_land_ebos[terrain_type])
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, globe_land_ebos[terrain_type])
		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			len(globe_land_mesh.indice[terrain_type]) * size_of(u32),
			raw_data(globe_land_mesh.indice[terrain_type]),
			gl.STATIC_DRAW,
		)
	}
}

globe_init_latitudes :: proc() {
	vbo: u32

	gl.GenVertexArrays(1, &globe_latitudes_vao)
	gl.BindVertexArray(globe_latitudes_vao)

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(globe_latitudes_vertices) * size_of(VertexColor),
		raw_data(globe_latitudes_vertices[:]),
		gl.STATIC_DRAW,
	)
	stride := i32(size_of(VertexColor))
	// position
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, stride, uintptr(0))
	gl.EnableVertexAttribArray(0)

	gl.VertexAttribPointer(1, 4, gl.FLOAT, gl.FALSE, stride, uintptr(12))
	gl.EnableVertexAttribArray(1)
}

globe_init_layer :: proc(vao: ^u32, mesh: ^Mesh) {
	vbo: u32
	ebo: u32

	gl.GenVertexArrays(1, vao)
	gl.BindVertexArray(vao^)

	// Vertex buffers
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(mesh.vertices) * size_of(Vertex),
		raw_data(mesh.vertices),
		gl.STATIC_DRAW,
	)
	stride := i32(size_of(Vertex))
	// position
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, stride, uintptr(0))
	gl.EnableVertexAttribArray(0)
	// UV
	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, stride, uintptr(12))
	gl.EnableVertexAttribArray(1)

	// Element buffers
	gl.GenBuffers(1, &ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(mesh.indices) * size_of(u32),
		raw_data(mesh.indices),
		gl.STATIC_DRAW,
	)

	gl.BindVertexArray(0)
}

globe_init_vertex_buffers_texture :: proc(vertices: []Vertex) {
	vbo: u32

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(Vertex),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)
	stride := i32(size_of(Vertex))
	// position
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, stride, uintptr(0))
	gl.EnableVertexAttribArray(0)
	// UV
	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, stride, uintptr(12))
	gl.EnableVertexAttribArray(1)
}

globe_init_ebo :: proc(indices: []u32) {
	ebo: u32

	gl.GenBuffers(1, &ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(indices) * size_of(u32),
		raw_data(indices),
		gl.STATIC_DRAW,
	)

	gl.BindVertexArray(0)
}

globe_init_ocean :: proc() {
	gl.GenVertexArrays(1, &globe_ocean_vao)
	gl.BindVertexArray(globe_ocean_vao)

	globe_init_vertex_buffers_texture(globe_ocean_mesh.vertices)

	globe_init_ebo(globe_ocean_mesh.indices)

	globe_init_texture_ocean()
}

globe_draw :: proc() {
	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

	view := get_view()
	projection := get_projection()
	model := get_model()

	gl.UseProgram(globe_program_texture)
	gl.BindTexture(gl.TEXTURE_2D, globe_ocean_texture)
	shader_set_mat4(globe_program, "view", view)
	shader_set_mat4(globe_program, "projection", projection)
	shader_set_mat4(globe_program, "model", model)

	globe_draw_area(globe_ocean_vao, globe_ocean_mesh, TERRAIN_COLORS[TERRAIN_TYPE.OCEAN])

	gl.UseProgram(globe_program)
	shader_set_mat4(globe_program, "view", view)
	shader_set_mat4(globe_program, "projection", projection)
	shader_set_mat4(globe_program, "model", model)

	globe_draw_land(globe_land_vao, globe_land_mesh)
	// globe_draw_edit_area()
	// globe_draw_grid()

	globe_draw_latitudes()
}

globe_draw_area :: proc(vao: u32, mesh: Mesh, color: Vec4) {
	gl.BindVertexArray(vao)
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
	shader_set_vec4(globe_program, "color", color)
	gl.DrawElements(gl.TRIANGLES, i32(len(mesh.indices)), gl.UNSIGNED_INT, nil)
}

globe_draw_land :: proc(vao: u32, mesh: Land_Mesh) {
	gl.BindVertexArray(vao)
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)

	for terrain_type, ebo in globe_land_ebos {
		gl.BindTexture(gl.TEXTURE_2D, globe_land_textures[terrain_type])
		shader_set_vec4(globe_program, "color", TERRAIN_COLORS[terrain_type])
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
		gl.DrawElements(
			gl.TRIANGLES,
			i32(len(globe_land_mesh.indice[terrain_type])),
			gl.UNSIGNED_INT,
			nil,
		)
	}
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

globe_draw_latitudes :: proc() {
	gl.UseProgram(globe_latitudes_program)

	view := get_view()
	projection := get_projection()
	model := get_model()

	shader_set_mat4(globe_program, "view", view)
	shader_set_mat4(globe_program, "projection", projection)
	shader_set_mat4(globe_program, "model", model)

	gl.BindVertexArray(globe_latitudes_vao)
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	// color: f32 = 0
	// shader_set_vec4(globe_program, "color", glsl.vec4({color, color, color, 1}))
	// gl.DrawElements(gl.TRIANGLES, i32(len(globe_grid_mesh.indices)), gl.UNSIGNED_INT, nil)
	// shader_set_vec4(globe_program, "color", {0, 0, 0, 1})

	gl.LineWidth(1.0)
	// gl.DrawElements(gl.LINES, i32(len(globe_grid_mesh.indices)), gl.UNSIGNED_INT, nil)

	gl.DrawArrays(gl.LINES, 0, i32(len(globe_latitudes_vertices)))
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

globe_generate_vertices :: proc(segments: int, rings: int, radius: f32) {
	start_plane_ring := 0
	end_plane_ring := globe_rings - 1

	start_plane_segment := 0
	end_plane_segment := globe_segments - 1

	plane_segments := end_plane_segment - start_plane_segment + 1
	plane_vertex_count_y := globe_rings + 1
	plane_vertex_count_x := globe_segments + 1
	plane_vertex_count := plane_vertex_count_y * plane_vertex_count_x

	plane_vertices := make([]Vertex, plane_vertex_count)

	plane_vertex_index := 0

	for y, py in start_plane_ring ..= end_plane_ring + 1 {
		v := f32(y) / f32(rings)

		theta := v * math.PI

		sin_theta := f32(math.sin(theta))
		cos_theta := f32(math.cos(theta))

		for x, px in start_plane_segment ..= end_plane_segment + 1 {
			u := f32(x) / f32(segments)

			phi := u * 2.0 * math.PI

			sin_phi := f32(math.sin(phi))
			cos_phi := f32(math.cos(phi))

			pos_x := -sin_theta * cos_phi
			pos_y := -cos_theta
			pos_z := sin_theta * sin_phi

			position := Vec3{pos_x * radius, pos_y * radius, pos_z * radius}

			plane_vertices[plane_vertex_index] = Vertex {
				position = position,
				uv       = Vec2{u, v},
			}

			plane_vertex_index += 1
		}
	}

	segments_per_plane :: globe_land_segments / globe_segments
	segments_per_plane_f := f32(segments_per_plane)

	tile_vertex_count := tile_vertex_count_x * tile_vertex_count_y

	// tile_vertices := make([]Vertex, tile_vertex_count)
	globe_land_mesh.vertices = make([]Vertex, tile_vertex_count)

	tile_vertex_index := 0
	tile_offset_y := 0

	for y, py in start_plane_ring ..= end_plane_ring + 1 {
		v := f32(y) / f32(rings)
		prev_v := f32(y - 1) / f32(rings)

		tile_offset_x := 0

		for x, px in start_plane_segment ..= end_plane_segment + 1 {
			u := f32(x) / f32(segments)
			prev_u := f32(x - 1) / f32(segments)

			if py > 0 && px > 0 {
				bottom_left_i := (py - 1) * plane_vertex_count_x + px - 1
				bottom_right_i := bottom_left_i + 1
				top_left_i := py * plane_vertex_count_x + px - 1
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

				// add extra vertex at the end of the last plane ring
				end_ring := y == end_plane_ring + 1 ? rings_per_plane : rings_per_plane - 1
				for ty in 0 ..= end_ring {
					tile_v := prev_v + (v - prev_v) * f32(ty) / f32(end_ring + 1)

					tile_vertex_index = tile_offset_y + ty * tile_vertex_count_x + tile_offset_x

					// add extra vertex at the end of the last plane segment
					end_seg :=
						x == end_plane_segment + 1 ? segments_per_plane : segments_per_plane - 1
					for tx in 0 ..= end_seg {
						tile_u := prev_u + (u - prev_u) * f32(tx) / f32(end_seg + 1)

						left_up := bottom_left.position + left_step_up * f32(ty)
						right_up := bottom_right.position + right_step_up * f32(ty)
						step_right := (right_up - left_up) / segments_per_plane_f

						vertice := Vertex {
							position = bottom_left.position + left_step_up * f32(ty) + step_right * f32(tx),
							uv       = Vec2{tile_u, tile_v},
						}

						globe_land_mesh.vertices[tile_vertex_index] = vertice

						tile_vertex_index += 1
					}
				}
				tile_offset_x = px * segments_per_plane
			}
		}
		tile_offset_y = tile_vertex_index
	}
}

indices_per_vertex := 6

globe_generate_land_indices :: proc() {
	add_tile :: proc(indices: []u32, index: ^int, ring: int, segment: int, tile_width: int) {
		bottom_left := u32(ring * (tile_vertex_count_x) + segment)
		bottom_right := bottom_left + u32(tile_width)
		top_left := u32((ring + 1) * (tile_vertex_count_x) + segment)
		top_right := top_left + u32(tile_width)

		indices[index^ + 0] = bottom_left
		indices[index^ + 1] = top_left
		indices[index^ + 2] = bottom_right

		indices[index^ + 3] = bottom_right
		indices[index^ + 4] = top_left
		indices[index^ + 5] = top_right

		index^ += indices_per_vertex
	}

	terrain_type_counts: [int(TERRAIN_TYPE.MASK) + 1]int
	for terrain_type in land_segments {
		if terrain_type == TERRAIN_TYPE.OCEAN {
			continue
		}
		terrain_type_counts[terrain_type] += 1
	}

	vertex_indices: [int(TERRAIN_TYPE.MASK) + 1][]u32
	for terrain_type in terrain_types {
		c := terrain_type_counts[terrain_type]
		vertex_indices[terrain_type] = make([]u32, c * indices_per_vertex)
	}

	vertex_index_indices: [int(TERRAIN_TYPE.MASK) + 1]int

	for ring in 0 ..< globe_land_rings {
		tile_width := tile_width_per_ring[ring]
		for segment := 0; segment < globe_land_segments; segment += tile_width {
			terrain_type := land_segments[ring * globe_land_segments + segment]

			if terrain_type == TERRAIN_TYPE.OCEAN {
				continue
			}

			add_tile(
				vertex_indices[terrain_type],
				&vertex_index_indices[terrain_type],
				ring,
				segment,
				tile_width,
			)
		}
	}

	for t, i in terrain_types {
		globe_land_mesh.indice[t] = vertex_indices[t]
	}
}

globe_update_land_indices :: proc() {
	delete(globe_land_mesh.indice[.FOREST])
	delete(globe_land_mesh.indice[.PLAIN])
	delete(globe_land_mesh.indice[.MASK])

	globe_generate_land_indices()

	gl.BindVertexArray(globe_land_vao)

	for terrain_type, ebo in globe_land_ebos {
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			len(globe_land_mesh.indice[terrain_type]) * size_of(u32),
			raw_data(globe_land_mesh.indice[terrain_type]),
			gl.STATIC_DRAW,
		)
	}
}

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

get_position :: proc(x: int, sin_theta: f32, cos_theta: f32) -> Vec3 {
	u := f32(x) / f32(globe_segments)
	phi := u * 2.0 * math.PI

	sin_phi := f32(math.sin(phi))
	cos_phi := f32(math.cos(phi))

	// Unit sphere position
	px := -sin_theta * cos_phi
	py := -cos_theta
	pz := sin_theta * sin_phi

	return Vec3 {
		px * globe_latitudes_radius,
		py * globe_latitudes_radius,
		pz * globe_latitudes_radius,
	}
}

globe_generate_latitudes_vertices :: proc() {
	index := 0
	for y in 1 ..= globe_latitudes_rings {
		v := f32(y) / 6
		theta := v * math.PI
		sin_theta := f32(math.sin(theta))
		cos_theta := f32(math.cos(theta))
		color: Vec4 = y % 2 == 0 ? {1, 0, 0, 1} : {0, 0, 0, 1}

		for x in 0 ..< globe_segments {
			globe_latitudes_vertices[index] = VertexColor {
				position = get_position(x, sin_theta, cos_theta),
				color    = color,
			}
			index += 1

			globe_latitudes_vertices[index] = VertexColor {
				position = get_position(x + 1, sin_theta, cos_theta),
				color    = color,
			}
			index += 1
		}
	}
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

globe_land_textures: map[TERRAIN_TYPE]u32

globe_ocean_texture: u32

texture_filename_world: cstring = "./textures/world.jpg"
texture_filename_grass: cstring = "./textures/grass.jpg"

globe_init_texture :: proc(texture: ^u32, file: cstring) {
	gl.GenTextures(1, texture)
	gl.BindTexture(gl.TEXTURE_2D, texture^)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	stbi.set_flip_vertically_on_load(1)
	width, height, nrChannels: i32
	data := stbi.load(file, &width, &height, &nrChannels, 0)
	if data == nil {
		fmt.println("Failed to load texture")
		os.exit(-1)
	}

	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
	gl.GenerateMipmap(gl.TEXTURE_2D)

	stbi.image_free(data)
}

globe_init_texture_ocean :: proc() {
	globe_init_texture(&globe_ocean_texture, texture_filename_world)
}

globe_init_texture_land :: proc() {
	globe_land_textures[.FOREST] = 0
	globe_init_texture(&globe_land_textures[.FOREST], texture_filename_world)

	globe_land_textures[.PLAIN] = 0
	globe_init_texture(&globe_land_textures[.PLAIN], texture_filename_grass)
}
