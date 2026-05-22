package game

import "core:fmt"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"

Creature :: struct {
	pos:    [3]f32,
	target: [3]f32,
}

MAP_SIZE :: 20.0
MAP_CENTER :: [3]f32{MAP_SIZE / 2, 0.0, MAP_SIZE / 2}
GROUND_SIZE :: [3]f32{MAP_SIZE, 0.5, MAP_SIZE}
GROUND_POSITION :: [3]f32{0.0, -GROUND_SIZE.y, 0.0}
CREATURE_SIZE :: [3]f32{0.5, 0.5, 0.5}
CREATURE_COLOR :: [3]f32{1.0, 0.6, 0.2}
CREATURE_COLOR_SELECTED :: [3]f32{0.0, 0.0, 1.0}

scene_shader_program: u32

ground_vao: u32

creature_vao: u32
creatures := []Creature{{pos = MAP_CENTER - {5.0, 0.0, 0.0}}, {pos = MAP_CENTER + {5.0, 0.0, 0.0}}}

path_vao: u32
path_vbo: u32
PATH_COLOR :: [3]f32{1.0, 1.0, 1.0}
PATH_WIDTH :: 3.0
PATH_VERTEX_COUNT :: 2

init_scene :: proc() {
	gl.Enable(gl.DEPTH_TEST)

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
	for &c in creatures {
		c.target = c.pos
	}
	creature_vbo: u32
	creature_vertices: [CUBOID_VERTEX_COUNT]Vertex
	init_vertices(&creature_vbo, &creature_vao, &creature_vertices, CREATURE_SIZE)

	// PATH
	gl.GenVertexArrays(1, &path_vao)
	gl.GenBuffers(1, &path_vbo)
	gl.BindVertexArray(path_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, path_vbo)

	path_vertices := []Vertex {
		{pos = {0.0, 0.0, 0.0}, normal = camera.up},
		{pos = {5.0, 5.0, 5.0}, normal = camera.up},
	}
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(path_vertices) * size_of(Vertex),
		raw_data(path_vertices),
		gl.STATIC_DRAW,
	)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), 0)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), offset_of(Vertex, normal))
	gl.EnableVertexAttribArray(1)
}

init_vertices :: proc(vbo: ^u32, vao: ^u32, vertices: ^[CUBOID_VERTEX_COUNT]Vertex, size: [3]f32) {
	gl.GenVertexArrays(1, vao)
	gl.GenBuffers(1, vbo)
	gl.BindVertexArray(vao^)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo^)

	create_cuboid(size, vertices)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices^), raw_data(vertices), gl.STATIC_DRAW)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), 0)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), offset_of(Vertex, normal))
	gl.EnableVertexAttribArray(1)
}

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

	gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)

	// GROUND
	draw_object(GROUND_POSITION, {0.0, 0.5, 0.0}, &ground_vao)

	// CREATURES
	for c, i in creatures {
		draw_object(
			c.pos,
			CREATURE_COLOR_SELECTED if selected_creature == i else CREATURE_COLOR,
			&creature_vao,
		)
	}

	// PATHS
	for c, i in creatures {
		if c.pos != c.target {
			shader_set_mat4(scene_shader_program, "model", 1)
			shader_set_vec3(scene_shader_program, "color", PATH_COLOR)
			gl.BindVertexArray(path_vao)
			gl.BindBuffer(gl.ARRAY_BUFFER, path_vbo)
			path_vertices := []Vertex {
				{pos = c.pos, normal = camera.up},
				{pos = c.target, normal = camera.up},
			}
			gl.BufferData(
				gl.ARRAY_BUFFER,
				len(path_vertices) * size_of(Vertex),
				raw_data(path_vertices),
				gl.STATIC_DRAW,
			)
			gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
			gl.LineWidth(PATH_WIDTH)
			gl.DrawArrays(gl.LINE_STRIP, 0, PATH_VERTEX_COUNT)
		}
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
