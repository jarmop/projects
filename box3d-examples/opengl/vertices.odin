package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

Vertex :: struct {
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

ground_vertices: [CUBOID_VERTEX_COUNT]Vertex
box_vertices: [CUBOID_VERTEX_COUNT]Vertex

vertices_init :: proc() {
	physics_init()

	init_box_vertices()
	init_ground_vertices()
}

init_box_vertices :: proc() {
	make_cuboid({CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, &box_vertices)

	gl.GenVertexArrays(1, &box_vao)
	gl.BindVertexArray(box_vao)

	vbo_init(&box_vbo)

	gl.BufferData(gl.ARRAY_BUFFER, size_of(box_vertices), raw_data(&box_vertices), gl.STATIC_DRAW)
}

init_ground_vertices :: proc() {
	make_cuboid(GROUND_SIZE, &ground_vertices)

	gl.GenVertexArrays(1, &ground_vao)
	gl.BindVertexArray(ground_vao)

	vbo_init(&ground_vbo)

	gl.BufferData(
		gl.ARRAY_BUFFER,
		size_of(box_vertices),
		raw_data(&ground_vertices),
		gl.STATIC_DRAW,
	)
}

vbo_init :: proc(vbo: ^u32) {
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

	gl.VertexAttribPointer(
		1,
		size_of(Vec2) / size_of(f32),
		gl.FLOAT,
		gl.FALSE,
		stride,
		offset_of(Vertex, uv),
	)
	gl.EnableVertexAttribArray(1)
}

make_cuboid :: proc(d: Vec3, vertices: ^[CUBOID_VERTEX_COUNT]Vertex) {
	uv_low: f32 = 0
	uv_high: f32 = 1
	faces := []Face {
		// left and right (YZ)
		{
			uv = {
				{uv_low, uv_high},
				{uv_high, uv_high},
				{uv_high, uv_low},
				{uv_high, uv_low},
				{uv_low, uv_low},
				{uv_low, uv_high},
			},
			pos = {
				{0.0, 0.0, 0.0},
				{0.0, d.y, 0.0},
				{0.0, d.y, d.z},
				{0.0, d.y, d.z},
				{0.0, 0.0, d.z},
				{0.0, 0.0, 0.0},
			},
			normal = {1.0, 0.0, 0.0},
		},
		// top and bottom (XZ)
		{
			uv = {
				{uv_low, uv_high},
				{uv_high, uv_high},
				{uv_high, uv_low},
				{uv_high, uv_low},
				{uv_low, uv_low},
				{uv_low, uv_high},
			},
			pos = {
				{0.0, 0.0, 0.0},
				{d.x, 0.0, 0.0},
				{d.x, 0.0, d.z},
				{d.x, 0.0, d.z},
				{0.0, 0.0, d.z},
				{0.0, 0.0, 0.0},
			},
			normal = {0.0, 1.0, 0.0},
		},
		// Front and back (XY)
		{
			uv = {
				{uv_low, uv_high},
				{uv_high, uv_high},
				{uv_high, uv_low},
				{uv_high, uv_low},
				{uv_low, uv_low},
				{uv_low, uv_high},
			},
			pos = {
				{0.0, 0.0, 0.0},
				{d.x, 0.0, 0.0},
				{d.x, d.y, 0.0},
				{d.x, d.y, 0.0},
				{0.0, d.y, 0.0},
				{0.0, 0.0, 0.0},
			},
			normal = {0.0, 0.0, 1.0},
		},
	}
	i := 0
	for f, fi in faces {
		// The first side
		for j in 0 ..= 5 {
			vertices[i].pos = f.pos[j] - 0.5
			// if texture_faces[fi] {
			vertices[i].uv = f.uv[j]
			// }
			i += 1
		}
		// The opposite side
		for j in 0 ..= 5 {
			vertices[i].pos = f.pos[j] + (d * f.normal) - 0.5
			// if texture_faces[fi] {
			vertices[i].uv = f.uv[j]
			// }
			i += 1
		}
	}
}

vertices_draw :: proc() {
	gl.UseProgram(shader_program_texture)

	view: glsl.mat4 = 1
	view *= glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)

	projection: glsl.mat4 = 1
	projection *= glsl.mat4Perspective(
		glsl.radians_f32(camera.fov),
		f32(WINDOW_WIDTH) / f32(WINDOW_HEIGHT),
		camera.near,
		camera.far,
	)

	shader_set_mat4(shader_program_texture, "projection", projection)
	shader_set_mat4(shader_program_texture, "view", view)

	draw_ground()
	draw_boxes()
}

draw_ground :: proc() {
	gl.BindVertexArray(ground_vao)

	model: glsl.mat4 = 1
	model *= glsl.mat4Translate(GROUND_CORNER_POSITION)
	shader_set_mat4(shader_program_texture, "model", model)

	gl.DrawArrays(gl.TRIANGLES, 0, len(ground_vertices))
}

draw_boxes :: proc() {
	gl.BindVertexArray(box_vao)

	shader_set_int(shader_program_texture, "texture_sampler", 0)


	physics_step()
	for i in 0 ..< box_count {
		pos, axis, angle := physics_get_box_data(i)

		model: glsl.mat4 = 1
		model *= glsl.mat4Translate(pos)

		if axis.x != 0 || axis.y != 0 || axis.z != 0 {
			model *= glsl.mat4Rotate(axis, angle)
		}

		shader_set_mat4(shader_program_texture, "model", model)

		gl.DrawArrays(gl.TRIANGLES, 0, len(box_vertices))
	}
}
