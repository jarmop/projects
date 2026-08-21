package survival

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"

WorldVertex :: struct {
	pos: [2]f32,
}

world_program: u32

world_vao: u32
world_vbo: u32
world_ebo: u32

world_pos := [2]f32{0, 0}
world_width :: 8
world_height :: 8
tile_size :: 40
vertices_per_tile :: 4
indices_per_tile :: 6
world_stride :: vertices_per_tile * world_width
world_vertices: [world_height * world_stride]WorldVertex
world_indices: [world_width * world_height * indices_per_tile]u32

gridlines_vao: u32
gridlines_vbo: u32
gridlines_vertices: [2 * (world_width + world_height + 2)]WorldVertex

screen_size_loc_world: i32

init_world :: proc() {
	shaders_ok: bool
	world_program, shaders_ok = gl.load_shaders_file("./shaders/world.vs", "./shaders/world.fs")
	if !shaders_ok {
		fmt.println("Shaders not ok")
		os.exit(-1)
	}

	// -----------------------------------------
	// Init tiles
	// -----------------------------------------

	pos := world_pos
	i := 0
	idx := 0
	indices: [indices_per_tile]u32 = {0, 2, 1, 0, 2, 3}
	for row in 0 ..< world_height {
		pos.x = world_pos.x
		for col in 0 ..< world_width {
			// fmt.println(col, i)
			cell_top_left: [2]f32 = pos
			cell_top_right: [2]f32 = {pos.x + tile_size, pos.y}
			cell_bottom_right: [2]f32 = {pos.x + tile_size, pos.y + tile_size}
			cell_bottom_left: [2]f32 = {pos.x, pos.y + tile_size}
			world_vertices[i] = {
				pos = cell_top_left,
			}
			i = i + 1
			// world_vertices[i] = {
			// 	pos = cell_bottom_right,
			// }
			// i = i + 1
			world_vertices[i] = {
				pos = cell_top_right,
			}
			i = i + 1
			// world_vertices[i] = {
			// 	pos = cell_top_left,
			// }
			// i = i + 1
			world_vertices[i] = {
				pos = cell_bottom_right,
			}
			i = i + 1
			world_vertices[i] = {
				pos = cell_bottom_left,
			}
			i = i + 1

			for j in indices {
				world_indices[idx] =
					j + u32(row) * world_width * vertices_per_tile + u32(col) * vertices_per_tile
				idx = idx + 1
			}

			pos.x = pos.x + tile_size
		}
		pos.y = pos.y + tile_size
	}

	gl.GenVertexArrays(1, &world_vao)
	gl.BindVertexArray(world_vao)

	gl.GenBuffers(1, &world_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, world_vbo)

	gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, size_of(WorldVertex), 0)
	gl.EnableVertexAttribArray(0)

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(world_vertices) * size_of(WorldVertex),
		raw_data(&world_vertices),
		gl.DYNAMIC_DRAW,
	)

	gl.GenBuffers(1, &world_ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, world_ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(world_indices) * size_of(u32),
		raw_data(&world_indices),
		gl.STATIC_DRAW,
	)

	gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, size_of(WorldVertex), 0)
	gl.EnableVertexAttribArray(0)

	// -----------------------------------------
	// Init grid lines
	// -----------------------------------------

	// Horizontal gridlines
	pos = world_pos
	i = 0
	for row in 0 ..= world_height {
		start := pos
		gridlines_vertices[i] = {
			pos = start,
		}
		i = i + 1
		end := pos + {world_width * tile_size, 0}
		gridlines_vertices[i] = {
			pos = end,
		}
		i = i + 1
		pos.y = pos.y + tile_size
	}
	// Vertical gridlines
	pos = world_pos
	for col in 0 ..= world_width {
		start := pos
		gridlines_vertices[i] = {
			pos = start,
		}
		i = i + 1
		end := pos + {0, world_height * tile_size}
		gridlines_vertices[i] = {
			pos = end,
		}
		i = i + 1
		pos.x = pos.x + tile_size
	}

	gl.GenVertexArrays(1, &gridlines_vao)
	gl.BindVertexArray(gridlines_vao)

	gl.GenBuffers(1, &gridlines_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, gridlines_vbo)

	gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, size_of(WorldVertex), 0)
	gl.EnableVertexAttribArray(0)

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(gridlines_vertices) * size_of(WorldVertex),
		raw_data(&gridlines_vertices),
		gl.DYNAMIC_DRAW,
	)

	screen_size_loc_world = gl.GetUniformLocation(world_program, "screen_size")
}

draw_world :: proc() {
	gl.UseProgram(world_program)
	gl.Uniform2f(screen_size_loc_world, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT))
	gl.Uniform2f(gl.GetUniformLocation(world_program, "world_pos"), world_pos.x, world_pos.y)

	// Draw tiles
	shader_set_vec3(world_program, "color", {1.0, 1.0, 1.0})
	gl.BindVertexArray(world_vao)
	// gl.DrawArrays(gl.TRIANGLES, 0, i32(len(world_vertices)))
	gl.DrawElements(gl.TRIANGLES, i32(len(world_indices)), gl.UNSIGNED_INT, nil)

	// Draw grid lines
	shader_set_vec3(world_program, "color", {1.0, 0.0, 0.0})
	gl.BindVertexArray(gridlines_vao)
	// gl.LineWidth(1.0)
	gl.DrawArrays(gl.LINES, 0, i32(len(gridlines_vertices)))
}
