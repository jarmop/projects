package game

import "core:fmt"
import "core:math/linalg/glsl"
import "core:math/rand"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"
import stbi "vendor:stb/image"

texture_shader_program: u32
color_shader_program: u32
path_shader_program: u32
bullet_shader_program: u32
line_shader_program: u32

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
	bullet_shader_program, shader_ok = gl.load_shaders_file(
		"./shaders/bullet.vs",
		"./shaders/bullet.fs",
	)
	if !shader_ok {
		fmt.println("Bullet shader not ok")
		os.exit(-1)
	}
	line_shader_program, shader_ok = gl.load_shaders_file(
		"./shaders/bullet.vs",
		"./shaders/bullet.fs",
	)
	if !shader_ok {
		fmt.println("Bullet shader not ok")
		os.exit(-1)
	}

	// GROUND
	// for row in height_map {
	// 	for y in row {
	// 		if y > GROUND_BB.max.y {
	// 			GROUND_BB.max.y = y
	// 		}
	// 	}
	// }

	// ground_vbo: u32
	create_grid(ground_vertices[:])
	init_vertices(&ground_vbo, &ground_vao, raw_data(&ground_vertices), size_of(ground_vertices))

	// for v& in ground_vertices_cell {
	// 	fmt.println(v)
	// }

	ground_vbo_grid: u32
	// for &v, x in ground_vertices_cell {
	// 	ground_vertices_cell[x] = ground_vertices[x * VERTICES_PER_TRIANGLE]
	// 	fmt.println(ground_vertices_cell[x].pos)
	// }
	// init_vertices(
	// 	&ground_vbo_cell,
	// 	&ground_vao_cell,
	// 	raw_data(&ground_vertices_cell),
	// 	size_of(ground_vertices),
	// )

	// for X := 0; X < GRID_SIZE * 2; X += 2 {
	// for x := 0; x < GRID_SIZE - 1; x += 1 {
	// 	ground_vertices_grid[x * 2] = {
	// 		pos = {f32(x + 1), 0, 0},
	// 	}
	// 	ground_vertices_grid[x * 2 + 1] = {
	// 		pos = {f32(x + 1), 0, CELL_SIZE},
	// 	}
	// 	// fmt.println(ground_vertices_grid[x].pos)
	// }

	v_i := 0
	for z in 0 ..< GRID_SIZE {
		for x in 0 ..< GRID_SIZE {
			// lines along the X axis
			ground_vertices_grid[v_i] = {
				pos = {f32(x), height_map[z][x], f32(z)},
			}
			v_i += 1
			ground_vertices_grid[v_i] = {
				pos = {f32(x + 1), height_map[z][x + 1], f32(z)},
			}
			v_i += 1

			// lines along the Z axis
			ground_vertices_grid[v_i] = {
				pos = {f32(x), height_map[z][x], f32(z)},
			}
			v_i += 1
			ground_vertices_grid[v_i] = {
				pos = {f32(x), height_map[z + 1][x], f32(z + 1)},
			}
			v_i += 1
		}
	}

	init_vertices(
		&ground_vbo_grid,
		&ground_vao_grid,
		raw_data(&ground_vertices_grid),
		size_of(ground_vertices),
	)

	init_path()

	// WALL
	wall_x_vbo: u32
	wall_x_vertices: [CUBOID_VERTEX_COUNT]Vertex
	create_cuboid(WALL_X_DIMENSIONS, &wall_x_vertices, 1, {false, true, false})
	init_vertices(&wall_x_vbo, &wall_x_vao, raw_data(&wall_x_vertices), size_of(wall_x_vertices))
	for &w in walls_x {
		w.bb = BoundingBox {
			min = w.pos,
			max = w.pos + WALL_X_DIMENSIONS,
		}
	}
	wall_z_vbo: u32
	wall_z_vertices: [CUBOID_VERTEX_COUNT]Vertex
	create_cuboid(WALL_Z_DIMENSIONS, &wall_z_vertices, 1, {false, true, false})
	init_vertices(&wall_z_vbo, &wall_z_vao, raw_data(&wall_z_vertices), size_of(wall_z_vertices))
	for &w in walls_z {
		w.bb = BoundingBox {
			min = w.pos,
			max = w.pos + WALL_Z_DIMENSIONS,
		}
	}

	// CREATURE
	creature_vbo: u32
	creature_vertices: [CUBOID_VERTEX_COUNT]Vertex
	create_cuboid(CREATURE_DIMENSIONS, &creature_vertices, 1, {false, true, false})
	init_vertices(
		&creature_vbo,
		&creature_vao,
		raw_data(&creature_vertices),
		size_of(creature_vertices),
	)
	for &s in soldiers {
		s.target = s.pos
	}
	for X := 0; X < ENEMY_COUNT_INITIAL; X += 1 {
		spawn_enemy()
	}

	// CORPSE
	corpse_vbo: u32
	corpse_vertices: [CUBOID_VERTEX_COUNT]Vertex
	create_cuboid(CORPSE_DIMENSIONS, &corpse_vertices, 1, {true, false, false})
	init_vertices(&corpse_vbo, &corpse_vao, raw_data(&corpse_vertices), size_of(corpse_vertices))

	// BULLET
	gl.GenVertexArrays(1, &bullet_path_vao)
	gl.BindVertexArray(bullet_path_vao)
	gl.GenBuffers(1, &bullet_path_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, bullet_path_vbo)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(BulletVertex), 0)
	gl.EnableVertexAttribArray(0)

	// PATH
	path_vertices: []Vertex
	init_vertices(&path_vbo, &path_vao, raw_data(path_vertices), size_of(path_vertices))

	// HEIGHT MAP
	height_map_vbo: u32
	gl.GenVertexArrays(1, &height_map_vao)
	gl.BindVertexArray(height_map_vao)
	gl.GenBuffers(1, &height_map_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, height_map_vbo)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(LineVertex), 0)
	gl.EnableVertexAttribArray(0)
	height_map_vertices: []LineVertex = {
		{pos = {-0.5, 0, 0}},
		{pos = {0.5, 0, 0}},
		{pos = {0, 0, -0.5}},
		{pos = {0, 0, 0.5}},
	}
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(height_map_vertices) * size_of(LineVertex),
		raw_data(height_map_vertices),
		gl.STATIC_DRAW,
	)

	// TEXTURE
	stbi.set_flip_vertically_on_load(1)
	width, height, nrChannels: i32
	// data := stbi.load("./assets/rubber.jpg", &width, &height, &nrChannels, 0)
	data := stbi.load("./assets/grass.jpg", &width, &height, &nrChannels, 0)
	// data := stbi.load("./assets/grid.jpg", &width, &height, &nrChannels, 0)
	// data := stbi.load("./assets/grid_thick.jpg", &width, &height, &nrChannels, 0)
	// data := stbi.load("./assets/grid_3_px.jpg", &width, &height, &nrChannels, 0)
	// data := stbi.load("./assets/tiles.jpg", &width, &height, &nrChannels, 0)
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

spawn_enemy :: proc() {
	pos: [3]f32 = {
		rand.float32() * (GROUND_SIZE - CREATURE_CENTER.x),
		0,
		rand.float32() * (GROUND_SIZE - CREATURE_CENTER.z),
	}
	append(&enemies, Creature{pos = pos, target = pos})
	enemy_spawn_prev_time = game_time
}

draw_scene :: proc() {
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

	// GROUND
	gl.BindVertexArray(ground_vao)
	model: glsl.mat4 = 1
	model *= glsl.mat4Translate(GROUND_POSITION)

	w_bg: f32 = 1.0
	w_line: f32 = 0.0

	if (SHOW_GROUND_WIREFRAME) {
		// BACKGROUND FOR THE WIREFRAME
		use_color_shader(view, projection)
		shader_set_mat4(color_shader_program, "model", model)
		// shader_set_vec3(color_shader_program, "color", {w_bg, w_bg, w_bg})
		// shader_set_vec3(color_shader_program, "color", {0.8, 0.6, 0.4})
		// shader_set_vec3(color_shader_program, "color", {2.0, 1.2, 0.4})
		// shader_set_vec3(color_shader_program, "color", {0.8, 0.5, 0.15})
		shader_set_vec3(color_shader_program, "color", {1.0, 0.75, 0.5})
		// shader_set_vec3(color_shader_program, "color", {1.6, 1.2, 0.8})
		gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
		gl.DrawArrays(gl.TRIANGLES, 0, GRID_SIZE * GRID_SIZE * 12)

		// tHE WIREFRAME
		// Lift grid up from the texture to make sure it's fully visible
		// // gl.BindVertexArray(ground_vao_grid)
		// model *= glsl.mat4Translate({0, 0.001, 0})
		// shader_set_mat4(color_shader_program, "model", model)
		// shader_set_vec3(color_shader_program, "color", {w_line, w_line, w_line})
		// // shader_set_vec3(color_shader_program, "color", {0.0, 0.0, 0.0})
		// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
		// gl.LineWidth(2.0)
		// gl.DrawArrays(gl.TRIANGLES, 0, GRID_SIZE * GRID_SIZE * 12)
		// // gl.DrawArrays(gl.LINES, 0, GRID_SIZE * GRID_SIZE * 12)
		// // gl.DrawArrays(gl.LINE_STRIP, 0, GRID_SIZE * GRID_SIZE * 12)
		// // gl.DrawArrays(gl.LINE_STRIP_ADJACENCY, 0, GRID_SIZE * GRID_SIZE * 12)
		// gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
	} else {
		use_texture_shader(view, projection)
		gl.BindTexture(gl.TEXTURE_2D, scene_texture)
		shader_set_mat4(texture_shader_program, "model", model)
		shader_set_vec3(texture_shader_program, "color", {1.0, 1.0, 1.0})
		gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
		gl.DrawArrays(gl.TRIANGLES, 0, GRID_SIZE * GRID_SIZE * 12)
	}

	// WALL
	use_color_shader(view, projection)
	shader_set_vec3(color_shader_program, "color", {1.0, 1.0, 1.0})
	// Walls along the X axis
	gl.BindVertexArray(wall_x_vao)
	for w in walls_x {
		model: glsl.mat4 = 1
		model *= glsl.mat4Translate(w.pos)
		shader_set_mat4(color_shader_program, "model", model)
		gl.DrawArrays(gl.TRIANGLES, 0, CUBOID_VERTEX_COUNT)
	}
	// Walls along the Z axis
	gl.BindVertexArray(wall_z_vao)
	for w in walls_z {
		model: glsl.mat4 = 1
		model *= glsl.mat4Translate(w.pos)
		shader_set_mat4(color_shader_program, "model", model)
		gl.DrawArrays(gl.TRIANGLES, 0, CUBOID_VERTEX_COUNT)
	}

	// SOLDIER
	// use_texture_shader(view, projection, creature_texture)
	use_color_shader(view, projection)
	for c, X in soldiers {
		draw_object(
			c.pos,
			get_soldier_color(X),
			// {1.0, 1.0, 1.0},
			&creature_vao,
			color_shader_program,
		)
	}

	// ENEMY
	// use_texture_shader(view, projection, creature_texture)
	use_color_shader(view, projection)
	for c, X in enemies {
		draw_object(c.pos, {0.0, 1.0, 0.0}, &creature_vao, color_shader_program)
	}

	// CORPSE
	use_color_shader(view, projection)
	for pos, X in corpses {
		draw_object(pos, {0.5, 0.0, 0.0}, &corpse_vao, color_shader_program)
	}

	// BULLET
	gl.UseProgram(bullet_shader_program)
	shader_set_mat4(bullet_shader_program, "view", view)
	shader_set_mat4(bullet_shader_program, "projection", projection)
	shader_set_mat4(bullet_shader_program, "model", 1)
	shader_set_vec3(bullet_shader_program, "color", BULLET_PATH_COLOR)
	gl.BindVertexArray(bullet_path_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, bullet_path_vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		bullet_path_vertex_next * size_of(BulletVertex),
		raw_data(&bullet_path_vertices),
		gl.STATIC_DRAW,
	)
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	gl.LineWidth(BULLET_PATH_WIDTH)
	gl.DrawArrays(gl.LINES, 0, i32(bullet_path_vertex_next))

	// PATH
	for s, X in soldiers {
		if s.path_len > 0 {
			gl.UseProgram(path_shader_program)
			shader_set_mat4(path_shader_program, "view", view)
			shader_set_mat4(path_shader_program, "projection", projection)
			shader_set_mat4(path_shader_program, "model", 1)
			shader_set_vec3(path_shader_program, "color", PATH_COLOR)
			gl.BindVertexArray(path_vao)
			gl.BindBuffer(gl.ARRAY_BUFFER, path_vbo)
			path_vertices: [PATH_MAX_LENGTH + 1]Vertex
			path_vertices[0] = {
				pos = s.pos,
			}
			vi := 1
			for X := s.path_i; X < s.path_len; X += 1 {
				path_vertices[vi] = {
					pos = s.path[X],
				}
				vi += 1
			}
			gl.BufferData(
				gl.ARRAY_BUFFER,
				len(path_vertices) * size_of(Vertex),
				// raw_data(path_vertices[0:4]),
				raw_data(path_vertices[0:s.path_len]),
				gl.STATIC_DRAW,
			)
			gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
			gl.LineWidth(PATH_WIDTH)
			gl.DrawArrays(gl.LINE_STRIP, 0, i32(s.path_len + 1 - s.path_i))
		}
	}

	// HEIGHT_MAP
	gl.UseProgram(line_shader_program)
	shader_set_mat4(line_shader_program, "view", view)
	shader_set_mat4(line_shader_program, "projection", projection)
	model = 1
	model *= glsl.mat4Translate(height_map_pos)
	shader_set_mat4(line_shader_program, "model", model)
	shader_set_vec3(line_shader_program, "color", {1.0, 0.0, 0.0})
	gl.BindVertexArray(height_map_vao)
	// gl.BindBuffer(gl.ARRAY_BUFFER, bullet_path_vbo)
	// gl.BufferData(
	// 	gl.ARRAY_BUFFER,
	// 	bullet_path_vertex_next * size_of(BulletVertex),
	// 	raw_data(&bullet_path_vertices),
	// 	gl.STATIC_DRAW,
	// )
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	gl.LineWidth(3.0)
	gl.DrawArrays(gl.LINES, 0, 4)
}

get_soldier_color :: proc(X: int) -> glsl.vec3 {
	if soldier_selected == X {
		return CREATURE_COLOR_SELECTED
	} else {
		return CREATURE_COLOR
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
	game_time_delta = game_time_speed * time_delta
	game_time += game_time_delta

	// meters per second
	creature_movement := CREATURE_SPEED * game_time_delta

	// UPDATE SOLDIERS
	for &s, X in soldiers {
		if s.path_len > 0 {
			d := s.target - s.pos
			if (glsl.length(d) <= creature_movement) {
				s.pos = s.target
				if s.path_i < s.path_len - 1 {
					// Target the next waypoint in the path
					s.path_i += 1
					s.target = s.path[s.path_i]
				} else {
					// Path is finished
					s.path_len = 0
					s.path_i = 0
				}
			} else {
				s.pos += creature_movement * glsl.normalize(d)
			}
		}
		s.bb = {
			min = s.pos,
			max = s.pos + CREATURE_DIMENSIONS,
		}
	}

	// UPDATE ENEMIES
	if game_time - enemy_spawn_prev_time > ENEMY_SPAWN_RATE && len(enemies) < ENEMY_COUNT_MAX {
		spawn_enemy()
	}
	for &e, X in enemies {
		// POSITION
		if e.pos != e.target {
			d := e.target - e.pos
			if (glsl.length(d) <= creature_movement) {
				e.pos = e.target
			} else {
				e.pos += creature_movement * glsl.normalize(d)
			}
		}
		e.bb = {
			min = e.pos,
			max = e.pos + CREATURE_DIMENSIONS,
		}
		// VISION
		nearest_soldier_d: f32 = 0
		enemy: ^Creature
		soldier: ^Creature
		for &s in soldiers {
			s_direction := glsl.normalize(s.pos - e.pos)
			s_d := glsl.length(s.pos - e.pos)

			if wall_blocks_ray(e.pos + CREATURE_CENTER, s_direction, s_d) {
				continue
			}

			if nearest_soldier_d == 0 || s_d < nearest_soldier_d {
				nearest_soldier_d = s_d
				soldier = &s
			}
		}
		if nearest_soldier_d > 0 {
			biting_distance: f32 = 0.3
			if (nearest_soldier_d < biting_distance) {
				fmt.println("Game over")
				soldier_dead = true
				playing = false
			}
			if enemy_attack {
				e.target = soldier.pos
			}
		}
	}

	// SHOOT
	if (soldier_fire_at_will && time_now - time_prev_shot > MIN_TIME_BETWEEN_SHOTS) {
		for s in soldiers {
			// VISION
			nearest_enemy_d: f32 = 0
			enemy: ^Creature
			for &e in enemies {
				enemy_direction := glsl.normalize(e.pos - s.pos)
				enemy_sight_d := glsl.length(e.pos - s.pos)

				if wall_blocks_ray(s.pos + CREATURE_CENTER, enemy_direction, enemy_sight_d) {
					continue
				}

				if nearest_enemy_d == 0 || enemy_sight_d < nearest_enemy_d {
					nearest_enemy_d = enemy_sight_d
					enemy = &e
				}
			}

			if nearest_enemy_d > 0 {
				shot_pos := s.pos + CREATURE_CENTER
				shot_target := enemy.pos + CREATURE_CENTER
				bullet := Bullet {
					pos            = shot_pos,
					pos_prev_check = shot_pos,
					direction      = glsl.normalize(shot_target - shot_pos),
					time_shot      = game_time,
				}
				bul_fill[bul_fill_next^] = bullet
				bul_fill_next^ += 1
			}
		}
		time_prev_shot = time_now
	}

	update_bullets()
}

update_bullets :: proc() {
	distance_travelled := BULLET_SPEED * game_time_delta

	bullet_path_vertex_next = 0
	for X := 0; X < bul_check_next^; X += 1 {
		bullet := bul_check[X]
		bullet.pos += distance_travelled * bullet.direction

		d: f32 = 0
		for w in walls_x {
			wall_d := hit_distance(w.bb, bullet.pos_prev_check, bullet.direction)
			if wall_d > 0 && (d == 0 || wall_d < d) {
				d = wall_d
			}
		}
		for w in walls_z {
			wall_d := hit_distance(w.bb, bullet.pos_prev_check, bullet.direction)
			if wall_d > 0 && (d == 0 || wall_d < d) {
				d = wall_d
			}
		}

		enemy_hit_index := -1
		for e, X in enemies {
			bb_d := hit_distance(e.bb, bullet.pos_prev_check, bullet.direction)
			if bb_d > 0 && (d == 0 || bb_d < d) {
				d = bb_d
				enemy_hit_index = X
			}
		}

		if d > 0 && d < distance_travelled {
			bullet_path_vertices[bullet_path_vertex_next] = {
				pos = bullet.pos_prev_check,
			}
			bullet_path_vertices[bullet_path_vertex_next + 1] = {
				pos = bullet.pos_prev_check + d * bullet.direction,
			}
			bullet_path_vertex_next += 2
			if (enemy_hit_index > -1) {
				append(
					&corpses,
					enemies[enemy_hit_index].pos + CREATURE_CENTER_XZ - CORPSE_CENTER_XZ,
				)
				unordered_remove(&enemies, enemy_hit_index)
			}
			// Bullet is discarded by not adding it to the fill buffer
		} else {
			bullet_path_vertices[bullet_path_vertex_next] = {
				pos = bullet.pos_prev_check,
			}
			bullet_path_vertices[bullet_path_vertex_next + 1] = {
				pos = bullet.pos,
			}
			bullet_path_vertex_next += 2

			bullet.pos_prev_check = bullet.pos
			bullet.travel_d += distance_travelled
			if (bullet.travel_d > BULLET_RANGE) {
				fmt.println("bullet shot at", bullet.time_shot, "exceeds range")
			} else {
				// bullet is checked on the next round
				bul_fill[bul_fill_next^] = bullet
				bul_fill_next^ += 1
			}

		}
	}

	bullet_buffer_index = (bullet_buffer_index + 1) % BULLET_BUFFERS_MAX
	bul_fill = &bullet_buffers[bullet_buffer_index]
	bul_fill_next = &bullet_nexts[bullet_buffer_index]
	bul_check = &bullet_buffers[(bullet_buffer_index + 1) % BULLET_BUFFERS_MAX]
	bul_check_next = &bullet_nexts[(bullet_buffer_index + 1) % BULLET_BUFFERS_MAX]
	bul_fill_next^ = 0
	// }
}
