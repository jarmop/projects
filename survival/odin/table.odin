package survival

import "core:fmt"
import "core:os"

import gl "vendor:OpenGL"

PosVertex :: struct {
	pos: [2]f32,
}

Table :: struct {
	start:      [2]f32,
	col_widths: [dynamic]f32,
	padding:    [2]f32,
	data:       [dynamic][dynamic]string,
}

cell_program: u32
cell_vao: u32
cell_vbo: u32
cell_ebo: u32
border_program: u32
border_vao: u32
border_vbo: u32
screen_size_loc_table: i32

cell_vertices: [dynamic]PosVertex
cell_indices: [dynamic]u32
border_vertices: [dynamic]PosVertex
indices: [6]u32 = {0, 2, 1, 0, 2, 3}

table_init :: proc() {
	// -----------------------------------------
	// Init cells
	// -----------------------------------------

	shaders_ok: bool
	cell_program, shaders_ok = gl.load_shaders_file("./shaders/cell.vs", "./shaders/cell.fs")
	if !shaders_ok {
		fmt.println("Shaders not ok")
		os.exit(-1)
	}

	gl.GenVertexArrays(1, &cell_vao)
	gl.BindVertexArray(cell_vao)

	gl.GenBuffers(1, &cell_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, cell_vbo)

	gl.GenBuffers(1, &cell_ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, cell_ebo)

	gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, size_of(PosVertex), 0)
	gl.EnableVertexAttribArray(0)

	screen_size_loc_table = gl.GetUniformLocation(cell_program, "screen_size")

	// -----------------------------------------
	// Init borders
	// -----------------------------------------

	border_shaders_ok: bool
	border_program, border_shaders_ok = gl.load_shaders_file(
		"./shaders/border.vs",
		"./shaders/border.fs",
	)
	if !border_shaders_ok {
		fmt.println("Shaders not ok")
		os.exit(-1)
	}

	gl.GenVertexArrays(1, &border_vao)
	gl.BindVertexArray(border_vao)

	gl.GenBuffers(1, &border_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, border_vbo)

	gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, size_of(PosVertex), 0)
	gl.EnableVertexAttribArray(0)
}

table_clear_vertices :: proc() {
	clear(&text_vertices)
	clear(&cell_vertices)
	clear(&cell_indices)
	clear(&border_vertices)
	indices = {0, 2, 1, 0, 2, 3}
}

table_add_vertices :: proc(table: Table) -> f32 {
	start := table.start
	col_widths := table.col_widths
	padding := table.padding
	data := table.data

	pos := start
	table_height: f32 = 0
	for row, i in data {
		pos.x = start.x

		// Create text vertices first and set the row height based on the biggest number of lines
		max_text_height: f32 = 0
		for text, j in row {
			col_width := col_widths[j]
			text_width := col_widths[j] - 2 * padding.x
			text_pos := pos + {padding.x, padding.y + font_size * 0.8}
			current_text_height := text_add_vertices(text, text_pos, text_width)
			max_text_height = max(current_text_height, max_text_height)
			pos.x = pos.x + col_width
		}
		pos.x = start.x
		height := max_text_height + 2 * padding.y
		table_height += height

		for col_width, j in col_widths {
			cell_top_left: [2]f32 = pos
			cell_top_right: [2]f32 = {pos.x + col_width, pos.y}
			cell_bottom_right: [2]f32 = {pos.x + col_width, pos.y + height}
			cell_bottom_left: [2]f32 = {pos.x, pos.y + height}

			append(
				&cell_vertices,
				PosVertex{pos = cell_top_left},
				PosVertex{pos = cell_top_right},
				PosVertex{pos = cell_bottom_right},
				PosVertex{pos = cell_bottom_left},
			)

			append(&cell_indices, ..indices[:])
			indices = indices + 4

			append(
				&border_vertices,
				PosVertex{pos = cell_top_left},
				PosVertex{pos = cell_top_right},
				PosVertex{pos = cell_top_right},
				PosVertex{pos = cell_bottom_right},
				PosVertex{pos = cell_bottom_right},
				PosVertex{pos = cell_bottom_left},
				PosVertex{pos = cell_bottom_left},
				PosVertex{pos = cell_top_left},
			)

			pos.x = pos.x + col_width
		}
		pos.y = pos.y + height
	}

	return table_height
}

table_set_buffer_data :: proc() {
	gl.BindBuffer(gl.ARRAY_BUFFER, cell_vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(cell_vertices) * size_of(PosVertex),
		raw_data(cell_vertices),
		gl.DYNAMIC_DRAW,
	)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, cell_ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(cell_indices) * size_of(u32),
		raw_data(cell_indices),
		gl.STATIC_DRAW,
	)

	gl.BindBuffer(gl.ARRAY_BUFFER, border_vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(border_vertices) * size_of(PosVertex),
		raw_data(border_vertices),
		gl.DYNAMIC_DRAW,
	)

	text_set_buffer_data()
}

draw_table :: proc() {
	// draw cells
	gl.UseProgram(cell_program)
	gl.Uniform2f(screen_size_loc_table, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT))
	gl.BindVertexArray(cell_vao)
	// gl.DrawArrays(gl.TRIANGLES, 0, i32(len(cell_vertices)))
	gl.DrawElements(gl.TRIANGLES, i32(len(cell_indices)), gl.UNSIGNED_INT, nil)

	// draw borders
	gl.UseProgram(border_program)
	gl.Uniform2f(screen_size_loc_table, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT))
	gl.BindVertexArray(border_vao)
	// gl.LineWidth(1.0)
	gl.DrawArrays(gl.LINES, 0, i32(len(border_vertices)))

	text_draw()
}

table_make :: proc(table: ^Table, data: [][]string, col_widths: []f32) {
	for row in data {
		data_row: [dynamic]string
		append(&data_row, ..row[:])
		append(&table.data, data_row)
	}

	append(&table.col_widths, ..col_widths[:])
}
