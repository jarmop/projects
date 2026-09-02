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

earth_radius: f32 = 6371
earth_circumference: f32 = 40960

// globe_layer_separation: f32 = 0.01
globe_layer_separation: f32 = 0.0006

globe_program: u32
globe_radius: f32 = 1
globe_spin_angle: f32 = 90
// globe_tilt_angle: f32 = 80
globe_tilt_angle: f32 = 0
globe_max_tilt_abs: f32 = 90

globe_ocean_vao: u32
globe_ocean_mesh: Mesh
globe_ocean_radius: f32 = globe_radius - globe_layer_separation

globe_land_segments := 1024
globe_land_rings := globe_land_segments / 2
globe_land_vao: u32
globe_land_mesh: Mesh
globe_land_radius: f32 = globe_radius

globe_grid_rings := 32
globe_grid_vao: u32
globe_grid_mesh: Mesh
globe_grid_radius: f32 = globe_radius + globe_layer_separation
// globe_grid_radius: f32 = globe_radius

globe_init :: proc() {
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

	globe_land_mesh = globe_generate_land(
		globe_land_segments,
		globe_land_rings,
		globe_land_radius,
		1,
		// globe_land_rings - globe_land_rings / globe_grid_rings * 2,
		globe_land_rings / 2 + 1,
	)
	globe_init_layer(&globe_land_vao, &globe_land_mesh, globe_land_radius)

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
	globe_draw_grid()
}

globe_draw_area :: proc(vao: u32, mesh: Mesh, color: Vec4) {
	gl.BindVertexArray(vao)
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
	shader_set_vec4(globe_program, "color", color)
	gl.DrawElements(gl.TRIANGLES, i32(len(mesh.indices)), gl.UNSIGNED_INT, nil)
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

globe_generate_land :: proc(
	segments: int,
	rings: int,
	radius: f32,
	segment: int,
	ring: int,
) -> Mesh {
	indices_per_vertex := 6

	// vertex_count := (segments + 1) * (rings + 1)
	vertex_count := 4
	// index_count := segments * rings * indices_per_vertex
	index_count := 6

	vertices := make([]Vertex, vertex_count)
	indices := make([]u32, index_count)

	vertex_index := 0

	// for y in 0 ..= rings {
	for y in ring ..= ring + 1 {
		// fmt.println(y)
		// 0 = south pole
		// 1 = nouth pole
		v := f32(y) / f32(rings)

		theta := v * math.PI

		sin_theta := f32(math.sin(theta))
		cos_theta := f32(math.cos(theta))

		// for x in 0 ..= segments {
		for x in segment ..= segment + 1 {
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

	// for y in 0 ..< rings {
	// for y in rings / 2 ..= rings / 2 {
	for y in 0 ..= 0 {
		for x in 0 ..= 0 {
			bottom_left := u32(y * (1 + 1) + x)
			bottom_right := bottom_left + 1
			top_left := u32((y + 1) * (1 + 1) + x)
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

	fmt.printfln("Ring\tR len\tT width 1\tT width 2\t Final W\tFinal T")
	fmt.printfln("-------------------------")
	segs := segments
	step := 8
	tile_size := earth_circumference / f32(segments)
	for y := 256; y > 0; y -= step {
		ring_length_bottom := ring_len(y, rings) * earth_circumference
		ring_length_top := ring_len(y - step, rings) * earth_circumference
		tile_width_bottom := ring_length_bottom / f32(segs)
		tile_width_top := ring_length_top / f32(segs)

		tile_width_bottom2 := ring_length_bottom / (f32(segs) / 2)
		tile_width_top2 := ring_length_top / (f32(segs) / 2)
		// tile_width3 := ring_length / (f32(seg) / 4)

		diff1 := math.abs(40 - (tile_width_bottom + tile_width_top) / 2)
		diff2 := math.abs(40 - (tile_width_bottom2 + tile_width_top2) / 2)
		// conc := diff1 < diff2 ? tile_width_bottom : tile_width_bottom2
		conc_width := tile_width_bottom
		conc_tiles := ring_length_bottom / tile_width_bottom
		if diff2 < diff1 {
			conc_width = tile_width_bottom2
			conc_tiles = ring_length_bottom / tile_width_bottom2
			segs = segs / 2
		}

		fmt.printfln(
			"%d:\t%.0f\t%.2f - %.2f\t%.2f - %.2f\t%.2f\t%.2f",
			y,
			ring_length_bottom,
			tile_width_bottom,
			tile_width_top,
			tile_width_bottom2,
			tile_width_top2,
			conc_width,
			conc_tiles,
		)
	}

	// for i in vertices {
	// 	fmt.println(i.position)
	// }
	// fmt.println("*********")
	// fmt.println(indices)

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

			// if x == 0 && y <= rings / 2 {
			// 	a := vertices[bottom_left].position
			// 	b := vertices[top_left].position
			// 	c := vertices[bottom_right].position

			// 	// v := f32(y) / f32(rings)
			// 	// theta := v * math.PI
			// 	// sin_theta := f32(math.sin(theta))
			// 	sin_theta := ring_len(y, rings)
			// 	fmt.printfln(
			// 		"%d: %.0f",
			// 		y,
			// 		// the distance is relative to the radius
			// 		// sphere_points_d(radius, a, c) * earth_radius,
			// 		sin_theta * 40960,
			// 	)
			// }
		}
		// } else {
		// 	for x := 0; x < segments; x += 2 {
		// 		bottom_left := u32(y * (segments + 1) + x)
		// 		bottom_right := bottom_left + 2
		// 		top_left := u32((y + 1) * (segments + 1) + x)
		// 		top_right := top_left + 2

		// 		// Meridian
		// 		indices[index + 0] = top_left
		// 		indices[index + 1] = bottom_left
		// 		// Parallel
		// 		indices[index + 2] = bottom_left
		// 		indices[index + 3] = bottom_right

		// 		index += indices_per_vertex
		// 	}
		// }
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
