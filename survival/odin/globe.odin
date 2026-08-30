package survival

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"
import stbi "vendor:stb/image"

Vec3 :: [3]f32
Vec2 :: [2]f32

Vertex :: struct {
	position: Vec3,
	normal:   Vec3,
	uv:       Vec2,
}

Sphere_Mesh :: struct {
	vertices: []Vertex,
	indices:  []u32,
}

globe_program: u32
globe_vao: u32
globe_mesh: Sphere_Mesh
globe_rings := 32
globe_radius: f32 = 1
globe_spin_angle: f32 = -90
globe_tilt_angle: f32 = 0

globe_grid_vao: u32
globe_grid_mesh: Sphere_Mesh
globe_grid_radius: f32 = 1.01

globe_init :: proc() {
	shaders_ok: bool
	globe_program, shaders_ok = gl.load_shaders_file("./shaders/globe.vs", "./shaders/globe.fs")
	if !shaders_ok {
		fmt.println("Shaders not ok")
		os.exit(-1)
	}

	globe_init_layer(&globe_vao, &globe_mesh, globe_radius)
	globe_init_layer(&globe_grid_vao, &globe_grid_mesh, globe_grid_radius)
}

globe_init_layer :: proc(vao: ^u32, mesh: ^Sphere_Mesh, radius: f32) {
	mesh^ = generate_uv_sphere(globe_rings * 2, globe_rings, radius)

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

	// normal
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, stride, uintptr(12))
	gl.EnableVertexAttribArray(1)

	// UV
	gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, stride, uintptr(24))
	gl.EnableVertexAttribArray(2)

	gl.BindVertexArray(0)
}

globe_draw :: proc() {
	gl.UseProgram(globe_program)

	// shader_set_int(program, "texture_sampler", 0)

	view: glsl.mat4 = 1
	view *= glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)

	window_width, window_height := glfw.GetWindowSize(window)
	projection: glsl.mat4 = 1
	projection *= glsl.mat4Perspective(
		glsl.radians_f32(camera.fov),
		f32(window_width) / f32(window_height),
		camera.near,
		camera.far,
	)

	model: glsl.mat4 = 1
	model *= glsl.mat4Rotate({1.0, 0.0, 0.0}, glsl.radians(globe_tilt_angle))
	model *= glsl.mat4Rotate({0.0, 1.0, 0.0}, glsl.radians(globe_spin_angle))

	shader_set_mat4(globe_program, "view", view)
	shader_set_mat4(globe_program, "projection", projection)
	shader_set_mat4(globe_program, "model", model)

	globe_draw_ocean()
	globe_draw_grid()
}

globe_draw_ocean :: proc() {
	gl.BindVertexArray(globe_vao)
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
	shader_set_vec4(globe_program, "color", glsl.vec4({0.4, 0.9, 1, 1}))
	gl.DrawElements(gl.TRIANGLES, i32(len(globe_mesh.indices)), gl.UNSIGNED_INT, nil)
}

globe_draw_grid :: proc() {
	gl.BindVertexArray(globe_grid_vao)
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	shader_set_vec4(globe_program, "color", glsl.vec4({0, 0, 0, 1}))
	gl.DrawElements(gl.TRIANGLES, i32(len(globe_grid_mesh.indices)), gl.UNSIGNED_INT, nil)
}

generate_uv_sphere :: proc(segments: int, rings: int, radius: f32) -> Sphere_Mesh {

	vertex_count := (segments + 1) * (rings + 1)
	index_count := segments * rings * 6

	vertices := make([]Vertex, vertex_count)
	indices := make([]u32, index_count)

	vertex_index := 0

	for y in 0 ..= rings {
		// 0 = north pole
		// 1 = south pole
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

			// For a sphere centered at the origin,
			// the normalized position is the normal.
			normal := Vec3{px, py, pz}

			vertices[vertex_index] = Vertex {
				position = position,
				normal   = normal,
				uv       = Vec2{u, v},
			}

			vertex_index += 1
		}
	}

	index := 0

	for y in 0 ..< rings {
		for x in 0 ..< segments {
			a := u32(y * (segments + 1) + x)
			b := a + 1
			c := u32((y + 1) * (segments + 1) + x)
			d := c + 1

			// First triangle
			indices[index + 0] = a
			indices[index + 1] = c
			indices[index + 2] = b

			// Second triangle
			indices[index + 3] = b
			indices[index + 4] = c
			indices[index + 5] = d

			index += 6
		}
	}

	return Sphere_Mesh{vertices = vertices, indices = indices}
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
