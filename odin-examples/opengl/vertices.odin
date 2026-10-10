package main

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
CUBE_SIZE: f32 : 1

VBO, VAO: u32

vertices: [CUBOID_VERTEX_COUNT]Vertex

cubePositions: [2]Vec3 = {{0.05, 2.0, 0.0}, {-0.05, 4.5, 0.0}}

vertices_init :: proc() {
	make_vertices()

	gl.GenVertexArrays(1, &VAO)
	gl.GenBuffers(1, &VBO)

	gl.BindVertexArray(VAO)

	gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), raw_data(&vertices), gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 3 * size_of(f32))
	gl.EnableVertexAttribArray(1)
}

vertices_draw :: proc() {
	gl.UseProgram(shaderProgram)

	view: glsl.mat4 = 1
	view *= glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)

	projection: glsl.mat4 = 1
	projection *= glsl.mat4Perspective(
		glsl.radians_f32(camera.fov),
		f32(f32(SCR_WIDTH) / f32(SCR_HEIGHT)),
		camera.near,
		camera.far,
	)

	shader_set_mat4(shaderProgram, "projection", projection)
	shader_set_mat4(shaderProgram, "view", view)

	gl.BindVertexArray(VAO)
	for position, i in cubePositions {
		model: glsl.mat4 = 1
		model *= glsl.mat4Translate(position)
		// angle := 20.0 * f32(i)
		// model *= glsl.mat4Rotate({1.0, 0.3, 0.5}, glsl.radians(angle))
		shader_set_mat4(shaderProgram, "model", model)

		gl.DrawArrays(gl.TRIANGLES, 0, 36)
	}
}

make_vertices :: proc() {
	d: Vec3 = {CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}
	uv_low: f32 = 0
	uv_high: f32 = 1

	create_cuboid(d, &vertices, 1, {true, true, true})
}

create_cuboid :: proc(
	d: Vec3,
	vertices: ^[CUBOID_VERTEX_COUNT]Vertex,
	texture_repeat: int,
	texture_faces: [3]bool,
) {
	uv_low: f32 = 0.0
	uv_high := f32(texture_repeat)
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
