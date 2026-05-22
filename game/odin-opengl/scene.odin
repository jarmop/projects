package game

import "core:fmt"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"

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
	create_cuboid(GROUND_DIMENSIONS, &ground_vertices)
	init_vertices(&ground_vbo, &ground_vao, raw_data(&ground_vertices), size_of(ground_vertices))

	// CREATURES
	for &c in creatures {
		c.target = c.pos
	}
	creature_vbo: u32
	creature_vertices: [CUBOID_VERTEX_COUNT]Vertex
	create_cuboid(CREATURE_DIMENSIONS, &creature_vertices)
	init_vertices(
		&creature_vbo,
		&creature_vao,
		raw_data(&creature_vertices),
		size_of(creature_vertices),
	)

	// PATH
	path_vertices := []Vertex {
		{pos = {0.0, 0.0, 0.0}, normal = camera.up},
		{pos = {5.0, 5.0, 5.0}, normal = camera.up},
	}
	init_vertices(&path_vbo, &path_vao, raw_data(path_vertices), size_of(path_vertices))
}

init_vertices :: proc(vbo: ^u32, vao: ^u32, vertices: rawptr, size: int) {
	gl.GenVertexArrays(1, vao)
	gl.BindVertexArray(vao^)

	gl.GenBuffers(1, vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo^)
	gl.BufferData(gl.ARRAY_BUFFER, size, vertices, gl.STATIC_DRAW)

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
			// c.pos - CREATURE_CENTER_XZ,
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
				{pos = c.pos + CREATURE_CENTER_XZ, normal = camera.up},
				{pos = c.target + CREATURE_CENTER_XZ, normal = camera.up},
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

update_scene :: proc() {
	creature_speed :: 1.0
	movement := creature_speed * game_time_delta
	for &c, i in creatures {
		if playing && c.pos != c.target {
			d := c.target - c.pos
			if (glsl.length(d) <= movement) {
				c.pos = c.target
			} else {
				c.pos += movement * glsl.normalize(d)
			}
		}
	}
}
