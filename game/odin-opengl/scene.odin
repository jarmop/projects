package game

import "core:fmt"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"

MAP_SIZE :: 20.0
MAP_CENTER :: [3]f32{MAP_SIZE / 2, 0.0, MAP_SIZE / 2}
GROUND_SIZE :: [3]f32{MAP_SIZE, 0.5, MAP_SIZE}
CREATURE_SIZE :: [3]f32{0.5, 0.5, 0.5}

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
	// gl.UseProgram(scene_shader_program)

	// GROUND
	ground_vbo: u32
	gl.GenVertexArrays(1, &ground_vao)
	gl.GenBuffers(1, &ground_vbo)
	gl.BindVertexArray(ground_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, ground_vbo)

	ground_vertices: [CUBOID_VERTEX_COUNT]Vertex
	create_cuboid(GROUND_SIZE, &ground_vertices)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		size_of(ground_vertices),
		raw_data(&ground_vertices),
		gl.STATIC_DRAW,
	)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)


	// CREATURES
	creature_vbo: u32
	gl.GenVertexArrays(1, &creature_vao)
	gl.GenBuffers(1, &creature_vbo)
	gl.BindVertexArray(creature_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, creature_vbo)

	creature_vertices: [CUBOID_VERTEX_COUNT]Vertex
	create_cuboid(CREATURE_SIZE, &creature_vertices)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		size_of(ground_vertices),
		raw_data(&creature_vertices),
		gl.STATIC_DRAW,
	)
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
	ground_model: glsl.mat4 = 1
	ground_model *= glsl.mat4Translate({0.0, -GROUND_SIZE.y, 0.0})
	shader_set_mat4(scene_shader_program, "model", ground_model)
	GROUND_COLOR :: glsl.vec3{0.0, 0.5, 0.0}
	shader_set_vec3(scene_shader_program, "color", GROUND_COLOR)
	gl.BindVertexArray(ground_vao)
	gl.DrawArrays(gl.TRIANGLES, 0, CUBOID_VERTEX_COUNT)

	// CREATURE
	for pos in creature_positions {
		creature_model: glsl.mat4 = 1
		creature_model *= glsl.mat4Translate(pos)
		shader_set_mat4(scene_shader_program, "model", creature_model)
		CREATURE_COLOR :: glsl.vec3{1.0, 0.6, 0.2}
		shader_set_vec3(scene_shader_program, "color", CREATURE_COLOR)
		gl.BindVertexArray(creature_vao)
		gl.DrawArrays(gl.TRIANGLES, 0, CUBOID_VERTEX_COUNT)
	}
}
