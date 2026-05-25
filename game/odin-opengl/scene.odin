package game

import "core:fmt"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"
import stbi "vendor:stb/image"

texture_shader_program: u32
color_shader_program: u32
path_shader_program: u32

scene_texture: u32
creature_texture: u32

init_scene :: proc() {
	gl.Enable(gl.DEPTH_TEST)

	shader_ok: bool
	texture_shader_program, shader_ok = gl.load_shaders_file(
		"./shaders/texture.vs",
		"./shaders/texture.fs",
	)
	if !shader_ok {
		fmt.println("Object shader not ok")
		os.exit(-1)
	}
	color_shader_program, shader_ok = gl.load_shaders_file(
		"./shaders/color.vs",
		"./shaders/color.fs",
	)
	if !shader_ok {
		fmt.println("Object shader not ok")
		os.exit(-1)
	}
	path_shader_program, shader_ok = gl.load_shaders_file("./shaders/path.vs", "./shaders/path.fs")
	if !shader_ok {
		fmt.println("Path shader not ok")
		os.exit(-1)
	}

	// GROUND
	ground_vbo: u32
	ground_vertices: [CUBOID_VERTEX_COUNT]Vertex
	create_cuboid(GROUND_DIMENSIONS, &ground_vertices, 10, {true, false, false})
	init_vertices(&ground_vbo, &ground_vao, raw_data(&ground_vertices), size_of(ground_vertices))

	// CREATURES
	for &c in creatures {
		c.target = c.pos
	}
	creature_vbo: u32
	creature_vertices: [CUBOID_VERTEX_COUNT]Vertex
	create_cuboid(CREATURE_DIMENSIONS, &creature_vertices, 1, {false, true, false})
	init_vertices(
		&creature_vbo,
		&creature_vao,
		raw_data(&creature_vertices),
		size_of(creature_vertices),
	)

	// Bullets
	bullet_vbo: u32
	bullet_vertices: [CUBOID_VERTEX_COUNT]Vertex
	create_cuboid(BULLET_DIMENSIONS, &bullet_vertices, 0, {false, false, false})
	init_vertices(&bullet_vbo, &bullet_vao, raw_data(&bullet_vertices), size_of(bullet_vertices))

	// PATH
	path_vertices: []Vertex
	init_vertices(&path_vbo, &path_vao, raw_data(path_vertices), size_of(path_vertices))

	// TEXTURE
	stbi.set_flip_vertically_on_load(1)
	width, height, nrChannels: i32
	data := stbi.load("./assets/rubber.jpg", &width, &height, &nrChannels, 0)
	if data == nil {
		fmt.println("Failed to load texture")
		os.exit(-1)
	}

	gl.GenTextures(1, &scene_texture)
	gl.BindTexture(gl.TEXTURE_2D, scene_texture)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	// Cropping an image can lead to alignment of something other than the
	// OpenGL default (UNPACK_ALIGNMENT=4) which causes segfault in TexImage2D.
	// Setting UNPACK_ALIGNMENT to 1 supports all alignments.
	gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
	gl.GenerateMipmap(gl.TEXTURE_2D)
	stbi.image_free(data)

	// TEXTURE 2
	stbi.set_flip_vertically_on_load(1)
	width2, height2, nrChannels2: i32
	data2 := stbi.load("./assets/human_front.jpg", &width2, &height2, &nrChannels2, 0)
	if data2 == nil {
		fmt.println("Failed to load texture")
		os.exit(-1)
	}

	gl.GenTextures(1, &creature_texture)
	gl.BindTexture(gl.TEXTURE_2D, creature_texture)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	// Cropping an image can lead to alignment of something other than the
	// OpenGL default (UNPACK_ALIGNMENT=4) which causes segfault in TexImage2D.
	// Setting UNPACK_ALIGNMENT to 1 supports all alignments.
	gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width2, height2, 0, gl.RGB, gl.UNSIGNED_BYTE, data2)
	gl.GenerateMipmap(gl.TEXTURE_2D)
	stbi.image_free(data2)

	// gl.UseProgram(texture_shader_program)
	// shader_set_int(texture_shader_program, "texture_sampler", 0)
}

init_vertices :: proc(vbo: ^u32, vao: ^u32, vertices: rawptr, size: int) {
	gl.GenVertexArrays(1, vao)
	gl.BindVertexArray(vao^)

	gl.GenBuffers(1, vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo^)
	gl.BufferData(gl.ARRAY_BUFFER, size, vertices, gl.STATIC_DRAW)

	// position
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), 0)
	gl.EnableVertexAttribArray(0)
	// normal
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), offset_of(Vertex, normal))
	gl.EnableVertexAttribArray(1)
	// texture
	gl.VertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, size_of(Vertex), offset_of(Vertex, texture))
	gl.EnableVertexAttribArray(2)
}

draw_scene :: proc() {
	// gl.ActiveTexture(gl.TEXTURE0)


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

	gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)

	// GROUND
	use_texture_shader(view, projection)
	gl.BindTexture(gl.TEXTURE_2D, scene_texture)
	draw_object(GROUND_POSITION, {1.0, 1.0, 1.0}, &ground_vao, texture_shader_program)

	// CREATURES
	// use_texture_shader(view, projection, creature_texture)
	use_color_shader(view, projection)
	for c, i in creatures {
		draw_object(
			c.pos,
			get_creature_color(i),
			// {1.0, 1.0, 1.0},
			&creature_vao,
			color_shader_program,
		)
	}

	for b in bullets {
		draw_object(b.pos, {1, 1, 1}, &bullet_vao, color_shader_program)
	}

	// PATHS
	for c, i in creatures {
		if c.pos != c.target {
			gl.UseProgram(path_shader_program)
			shader_set_mat4(path_shader_program, "view", view)
			shader_set_mat4(path_shader_program, "projection", projection)
			shader_set_mat4(path_shader_program, "model", 1)
			shader_set_vec3(path_shader_program, "color", PATH_COLOR)
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

get_creature_color :: proc(i: int) -> glsl.vec3 {
	if creature_selected == i {
		return CREATURE_COLOR_SHOOTING if creature_shooting == i else CREATURE_COLOR_SELECTED
	} else {
		return CREATURE_COLOR_TARGET if creature_target == i else CREATURE_COLOR
	}
}

draw_object :: proc(pos: glsl.vec3, color: glsl.vec3, vao: ^u32, shader_program: u32) {
	model: glsl.mat4 = 1
	model *= glsl.mat4Translate(pos)
	shader_set_mat4(shader_program, "model", model)
	shader_set_vec3(shader_program, "color", color)
	gl.BindVertexArray(vao^)
	gl.DrawArrays(gl.TRIANGLES, 0, CUBOID_VERTEX_COUNT)
}

time_prev_shot: f32 = 0

update_scene :: proc() {
	if !playing {
		return
	}
	game_time_delta = game_time_speed * (time_now - time_prev_frame)
	if playing {
		game_time += game_time_delta
	}

	creature_speed :: 1.0
	creature_movement := creature_speed * game_time_delta

	bullet_speed :: 10.0
	// Minimum time between shots
	min_time_between_shots :: 1.0
	bullet_movement := bullet_speed * game_time_delta

	for &c, i in creatures {
		if c.pos != c.target {
			d := c.target - c.pos
			if (glsl.length(d) <= creature_movement) {
				c.pos = c.target
			} else {
				c.pos += creature_movement * glsl.normalize(d)
			}
		}
		if i == creature_shooting {
			// - Raycast periodically from previous bullet position to the next.
			//   Or is it better to just check if the bullet overlaps with some
			//   creature?
			// - Maybe bullets don't need to be rendered at all. Just update
			//   bullet positions and do the collision detection
			if (time_now - time_prev_shot > min_time_between_shots) {
				time_prev_shot = time_now
				shot_pos := creatures[creature_shooting].pos + {0, 1, 0}
				shot_target := creatures[creature_target].pos + {0, 1, 0}
				append(
					&bullets,
					Bullet {
						pos       = shot_pos,
						// direction = {1, 0, 0},
						direction = glsl.normalize(shot_target - shot_pos),
					},
				)
			}
		}
	}
	for &b in bullets {
		b.pos += bullet_movement * b.direction
	}
}
