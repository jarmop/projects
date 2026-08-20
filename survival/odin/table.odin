package survival

import "core:fmt"
import "core:os"

import gl "vendor:OpenGL"

PosVertex :: struct {
	pos: [2]f32,
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

init_table :: proc(
	start: [2]f32,
	row_heights: []f32,
	col_widths: []f32,
	padding: [2]f32,
	font_size: f32,
	data: [][]string,
) {
	indices: [6]u32 = {0, 2, 1, 0, 2, 3}
	pos := start
	for row, i in data {
		height := row_heights[i]
		pos.x = start.x

		for text, j in row {
			width := col_widths[j]
			cell_top_left: [2]f32 = pos
			cell_top_right: [2]f32 = {pos.x + width, pos.y}
			cell_bottom_right: [2]f32 = {pos.x + width, pos.y + height}
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

			text_pos := pos + {padding.x, padding.y + font_size - 1}
			add_text_vertices(text, text_pos, font_size, width)

			pos.x = pos.x + width
		}
		pos.y = pos.y + height
	}

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

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(cell_vertices) * size_of(PosVertex),
		raw_data(cell_vertices),
		gl.DYNAMIC_DRAW,
	)

	gl.GenBuffers(1, &cell_ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, cell_ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(cell_indices) * size_of(u32),
		raw_data(cell_indices),
		gl.STATIC_DRAW,
	)

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

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(border_vertices) * size_of(PosVertex),
		raw_data(border_vertices),
		gl.DYNAMIC_DRAW,
	)

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

	// draw_text("Hello from stb_truetype", pos)
	// draw_text("Hello from stb_truetype", {100, 100})
	draw_text()
}
