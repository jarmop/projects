package main

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

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

GROUND_SIZE: Vec3 : {100, 10, 100}
GROUND_RADIUS: Vec3 : {GROUND_SIZE.x / 2, GROUND_SIZE.y / 2, GROUND_SIZE.z / 2}
GROUND_CENTER_POSITION: Vec3 = {0, -GROUND_RADIUS.y, 0}

CUBE_SIZE: f32 : 1
CUBE_RADIUS :: CUBE_SIZE / 2

ground_vbo, ground_vao: u32
box_vbo, box_vao: u32

ground_vertices: [CUBOID_VERTEX_COUNT]TextureVertex
box_vertices: [CUBOID_VERTEX_COUNT]TextureVertex

cubePositions: []Vec3 = {{0, CUBE_RADIUS, 0}}

vertices_init :: proc() {
	init_ground_vertices()
	init_box_vertices()
}

init_ground_vertices :: proc() {
	make_cuboid(ground_vertices[:], GROUND_SIZE, {false, true, false}, int(GROUND_SIZE.x))

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
	make_cuboid(box_vertices[:], {CUBE_SIZE, CUBE_SIZE, CUBE_SIZE}, {true, true, true}, 1)

	gl.GenVertexArrays(1, &box_vao)
	gl.BindVertexArray(box_vao)

	vbo_init_uv(&box_vbo)

	gl.BufferData(gl.ARRAY_BUFFER, size_of(box_vertices), raw_data(&box_vertices), gl.STATIC_DRAW)
}

// bb_vertices: [CUBOID_VERTEX_COUNT]TextureVertex
// bb_vao, bb_vbo: u32
// init_bb_vertices :: proc(bb: BoundingBox) {
// 	d := bb.max - bb.min
// 	c := bb.min + d / 2
// 	make_cuboid(bb_vertices[:], d, {true, true, true}, 1, c)

// 	gl.GenVertexArrays(1, &bb_vao)
// 	gl.BindVertexArray(bb_vao)

// 	vbo_init_uv(&bb_vbo)

// 	gl.BufferData(gl.ARRAY_BUFFER, size_of(bb_vertices), raw_data(&bb_vertices), gl.STATIC_DRAW)
// }

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

make_cuboid :: proc(
	vertices: []TextureVertex,
	d: Vec3,
	texture_faces: [3]bool,
	texture_repeat: int,
	center: Vec3 = {0, 0, 0},
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

	// Put the center of the shape at the given center
	for &f in faces {
		for &p in f.pos {
			p = p - d / 2 + center
		}
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

vertices_draw :: proc() {

	// view: glsl.mat4 = 1
	// // view *= glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)
	// target := humanoid.position + Vec3{0, 1.5, 0}
	// // view *= glsl.mat4LookAt(camera.pos, humanoid.position + target, camera.up)
	// view *= glsl.mat4LookAt(camera.pos, target, camera.up)

	view := camera_get_view()

	projection: glsl.mat4 = 1
	projection *= glsl.mat4Perspective(
		glsl.radians_f32(camera.fov),
		f32(WINDOW_WIDTH) / f32(WINDOW_HEIGHT),
		camera.near,
		camera.far,
	)

	gl.UseProgram(shader_program_grid)
	shader_set_mat4(shader_program_grid, "projection", projection)
	shader_set_mat4(shader_program_grid, "view", view)

	// ------------------------------
	// Ground
	// ------------------------------

	model: glsl.mat4 = 1
	model *= glsl.mat4Translate(GROUND_CENTER_POSITION)
	shader_set_mat4(shader_program_grid, "model", model)
	c: f32 = .26
	shader_set_vec4(shader_program_grid, "bg_color", {c, c, c, 1})
	c = .24
	shader_set_vec4(shader_program_grid, "grid_color", {c, c, c, 1})
	gl.BindVertexArray(ground_vao)
	gl.DrawArrays(gl.TRIANGLES, 0, len(ground_vertices))
}
