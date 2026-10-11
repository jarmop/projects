package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

Vertex :: struct {
	pos: Vec3,
}

TextureVertex :: struct {
	pos: Vec3,
	uv:  Vec2,
}

Face :: struct {
	pos:    [6]Vec3,
	uv:     [6]Vec2,
	normal: Vec3,
}

CUBOID_VERTEX_COUNT :: 36

box_vbo, box_vao: u32
ground_vbo, ground_vao: u32

ground_vertices: [CUBOID_VERTEX_COUNT]TextureVertex
box_vertices: [CUBOID_VERTEX_COUNT]TextureVertex

vertices_init :: proc() {
	physics_init()

	init_ground_vertices()
	init_box_vertices()
}

init_ground_vertices :: proc() {
	make_texture_cuboid(&ground_vertices, GROUND_SIZE, {false, true, false}, int(GROUND_SIZE.x))

	gl.GenVertexArrays(1, &ground_vao)
	gl.BindVertexArray(ground_vao)

	vbo_init_uv(&ground_vbo)

	gl.BufferData(
		gl.ARRAY_BUFFER,
		size_of(ground_vertices),
		raw_data(&ground_vertices),
		gl.STATIC_DRAW,
	)
}

init_box_vertices :: proc() {
	make_texture_cuboid(&box_vertices, {CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {true, true, true}, 1)

	gl.GenVertexArrays(1, &box_vao)
	gl.BindVertexArray(box_vao)

	vbo_init_uv(&box_vbo)

	gl.BufferData(gl.ARRAY_BUFFER, size_of(box_vertices), raw_data(&box_vertices), gl.STATIC_DRAW)
}

vbo_init_basic :: proc(vbo: ^u32) {
	gl.GenBuffers(1, vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo^)

	stride := i32(size_of(Vertex))

	gl.VertexAttribPointer(
		0,
		size_of(Vec3) / size_of(f32),
		gl.FLOAT,
		gl.FALSE,
		stride,
		offset_of(Vertex, pos),
	)
	gl.EnableVertexAttribArray(0)
}

vbo_init_uv :: proc(vbo: ^u32) {
	gl.GenBuffers(1, vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo^)

	stride := i32(size_of(TextureVertex))

	gl.VertexAttribPointer(
		0,
		size_of(Vec3) / size_of(f32),
		gl.FLOAT,
		gl.FALSE,
		stride,
		offset_of(TextureVertex, pos),
	)
	gl.EnableVertexAttribArray(0)

	gl.VertexAttribPointer(
		1,
		size_of(Vec2) / size_of(f32),
		gl.FLOAT,
		gl.FALSE,
		stride,
		offset_of(TextureVertex, uv),
	)
	gl.EnableVertexAttribArray(1)
}

make_cuboid :: proc(d: Vec3, vertices: ^[CUBOID_VERTEX_COUNT]Vertex, texture_repeat: int) {
	faces: [3]Face
	make_cuboid_faces(&faces, d, texture_repeat)
	i := 0
	for f, fi in faces {
		// The first side
		for j in 0 ..= 5 {
			vertices[i].pos = f.pos[j] - 0.5
			i += 1
		}
		// The opposite side
		for j in 0 ..= 5 {
			vertices[i].pos = f.pos[j] + (d * f.normal) - 0.5
			i += 1
		}
	}
}

make_texture_cuboid :: proc(
	vertices: ^[CUBOID_VERTEX_COUNT]TextureVertex,
	d: Vec3,
	texture_faces: [3]bool,
	texture_repeat: int,
) {
	faces: [3]Face
	make_cuboid_faces(&faces, d, texture_repeat)
	i := 0
	for f, fi in faces {
		// The first side
		for j in 0 ..= 5 {
			vertices[i].pos = f.pos[j]
			if texture_faces[fi] {
				vertices[i].uv = f.uv[j]
			}
			i += 1
		}
		// The opposite side
		for j in 0 ..= 5 {
			vertices[i].pos = f.pos[j] + (d * f.normal)
			if texture_faces[fi] {
				vertices[i].uv = f.uv[j]
			}
			i += 1
		}
	}
}

make_cuboid_faces :: proc(faces: ^[3]Face, d: Vec3, texture_repeat: int) {
	uv_low: f32 = 0
	uv_high: f32 = f32(texture_repeat)
	// left and right (YZ)
	faces[0] = {
		uv     = {
			{uv_low, uv_high},
			{uv_high, uv_high},
			{uv_high, uv_low},
			{uv_high, uv_low},
			{uv_low, uv_low},
			{uv_low, uv_high},
		},
		pos    = {
			{0.0, 0.0, 0.0},
			{0.0, d.y, 0.0},
			{0.0, d.y, d.z},
			{0.0, d.y, d.z},
			{0.0, 0.0, d.z},
			{0.0, 0.0, 0.0},
		},
		normal = {1.0, 0.0, 0.0},
	}
	// top and bottom (XZ)
	faces[1] = {
		uv     = {
			{uv_low, uv_high},
			{uv_high, uv_high},
			{uv_high, uv_low},
			{uv_high, uv_low},
			{uv_low, uv_low},
			{uv_low, uv_high},
		},
		pos    = {
			{0.0, 0.0, 0.0},
			{d.x, 0.0, 0.0},
			{d.x, 0.0, d.z},
			{d.x, 0.0, d.z},
			{0.0, 0.0, d.z},
			{0.0, 0.0, 0.0},
		},
		normal = {0.0, 1.0, 0.0},
	}
	// Front and back (XY)
	faces[2] = {
		uv     = {
			{uv_low, uv_high},
			{uv_high, uv_high},
			{uv_high, uv_low},
			{uv_high, uv_low},
			{uv_low, uv_low},
			{uv_low, uv_high},
		},
		pos    = {
			{0.0, 0.0, 0.0},
			{d.x, 0.0, 0.0},
			{d.x, d.y, 0.0},
			{d.x, d.y, 0.0},
			{0.0, d.y, 0.0},
			{0.0, 0.0, 0.0},
		},
		normal = {0.0, 0.0, 1.0},
	}

	// Put the center of the shape at [0,0,0]
	for &f in faces {
		for &p in f.pos {
			p -= d / 2
		}
	}
}

vertices_draw :: proc() {
	draw_ground()
	draw_boxes()
}

draw_ground :: proc() {
	gl.UseProgram(shader_program_grid)

	view: glsl.mat4 = 1
	view *= glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)

	projection: glsl.mat4 = 1
	projection *= glsl.mat4Perspective(
		glsl.radians_f32(camera.fov),
		f32(WINDOW_WIDTH) / f32(WINDOW_HEIGHT),
		camera.near,
		camera.far,
	)

	shader_set_mat4(shader_program_grid, "projection", projection)
	shader_set_mat4(shader_program_grid, "view", view)
	c: f32 = .26
	shader_set_vec4(shader_program_grid, "bg_color", {c, c, c, 1})
	c = .24
	shader_set_vec4(shader_program_grid, "grid_color", {c, c, c, 1})

	gl.BindVertexArray(ground_vao)

	model: glsl.mat4 = 1
	model *= glsl.mat4Translate(GROUND_CENTER_POSITION)
	shader_set_mat4(shader_program_texture, "model", model)

	gl.DrawArrays(gl.TRIANGLES, 0, len(ground_vertices))
}

draw_boxes :: proc() {
	gl.UseProgram(shader_program_grid)

	view: glsl.mat4 = 1
	view *= glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)

	projection: glsl.mat4 = 1
	projection *= glsl.mat4Perspective(
		glsl.radians_f32(camera.fov),
		f32(WINDOW_WIDTH) / f32(WINDOW_HEIGHT),
		camera.near,
		camera.far,
	)

	shader_set_mat4(shader_program_grid, "projection", projection)
	shader_set_mat4(shader_program_grid, "view", view)
	shader_set_vec4(shader_program_grid, "bg_color", {0, .4, .8, 1})
	shader_set_vec4(shader_program_grid, "grid_color", {0, .3, .6, 1})

	gl.BindVertexArray(box_vao)

	shader_set_int(shader_program_grid, "texture_sampler", 0)


	physics_step()
	for i in 0 ..< box_count {
		shader_set_mat4(shader_program_grid, "model", physics_get_model(i))

		gl.DrawArrays(gl.TRIANGLES, 0, len(box_vertices))
	}
}
