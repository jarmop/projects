package game

import "core:fmt"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"

MAP_SIZE :: 20.0
MAP_CENTER :: [3]f32{MAP_SIZE / 2, 0.0, MAP_SIZE / 2}
GROUND_SIZE :: [3]f32{MAP_SIZE, 0.5, MAP_SIZE}

scene_shader_program: u32

ground_vao: u32

creature_vao: u32

init_scene :: proc() {
	// gl.Enable(gl.DEPTH_TEST)

	shader_ok: bool
	scene_shader_program, shader_ok = gl.load_shaders_file(
		"./shaders/scene.vs",
		"./shaders/scene.fs",
	)
	if !shader_ok {
		fmt.println("Shader not ok")
		os.exit(-1)
	}

	// GROUND
	ground_vbo: u32
	ground_vertices: [CUBOID_VERTEX_COUNT]Vertex
	init_vertices(&ground_vbo, &ground_vao, &ground_vertices, GROUND_SIZE)

	// CREATURES
	creature_vbo: u32
	creature_vertices: [CUBOID_VERTEX_COUNT]Vertex
	CREATURE_SIZE :: [3]f32{0.5, 0.5, 0.5}
	init_vertices(&creature_vbo, &creature_vao, &creature_vertices, CREATURE_SIZE)
}

init_vertices :: proc(vbo: ^u32, vao: ^u32, vertices: ^[CUBOID_VERTEX_COUNT]Vertex, size: [3]f32) {
	gl.GenVertexArrays(1, vao)
	gl.GenBuffers(1, vbo)
	gl.BindVertexArray(vao^)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo^)

	create_cuboid(size, vertices)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices^), raw_data(vertices), gl.STATIC_DRAW)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)
}

creature_positions := []glsl.vec3{MAP_CENTER - {5.0, 0.0, 0.0}, MAP_CENTER + {5.0, 0.0, 0.0}}

draw_scene :: proc() {
	gl.UseProgram(scene_shader_program)

	view: glsl.mat4 = 1
	view *= glsl.mat4LookAt(camera.pos, camera.pos + camera.front, camera.up)
	shader_set_mat4(scene_shader_program, "view", view)

	window_width, window_height := glfw.GetWindowSize(window)
	projection: glsl.mat4 = 1
	projection *= glsl.mat4Perspective(
		glsl.radians_f32(camera.fov),
		f32(window_width) / f32(window_height),
		camera.near,
		camera.far,
	)
	shader_set_mat4(scene_shader_program, "projection", projection)

	// GROUND
	draw_object({0.0, -GROUND_SIZE.y, 0.0}, {0.0, 0.5, 0.0}, &ground_vao)

	// CREATURES
	for pos in creature_positions {
		draw_object(pos, {1.0, 0.6, 0.2}, &creature_vao)
	}
}

draw_object :: proc(pos: glsl.vec3, color: glsl.vec3, vao: ^u32) {
	model: glsl.mat4 = 1
	model *= glsl.mat4Translate(pos)
	shader_set_mat4(scene_shader_program, "model", model)
	shader_set_vec3(scene_shader_program, "color", color)
	gl.BindVertexArray(vao^)
	gl.DrawArrays(gl.TRIANGLES, 0, CUBOID_VERTEX_COUNT)
}
