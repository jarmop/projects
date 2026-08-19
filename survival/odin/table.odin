package survival

import "core:fmt"
import "core:os"

import gl "vendor:OpenGL"

PosVertex :: struct {
	pos: [3]f32,
}

cell_program: u32
cell_vao: u32
cell_vbo: u32
border_program: u32
border_vao: u32
border_vbo: u32

cell_vertices: []PosVertex
border_vertices: []PosVertex

cell_top_left: [3]f32 = {0, 0.5, 0}
cell_top_right: [3]f32 = {0.5, 0.5, 0}
cell_bottom_right: [3]f32 = {0.5, 0, 0}
cell_bottom_left: [3]f32 = {0, 0, 0}

init_table :: proc() {

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

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(PosVertex), 0)
	gl.EnableVertexAttribArray(0)

	cell_vertices = {
		{pos = cell_top_left},
		{pos = cell_bottom_right},
		{pos = cell_top_right},
		{pos = cell_top_left},
		{pos = cell_bottom_right},
		{pos = cell_bottom_left},
	}

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(cell_vertices) * size_of(PosVertex),
		raw_data(cell_vertices),
		gl.DYNAMIC_DRAW,
	)

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

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(PosVertex), 0)
	gl.EnableVertexAttribArray(0)

	border_vertices = {
		{pos = cell_top_left},
		{pos = cell_top_right},
		{pos = cell_bottom_right},
		{pos = cell_bottom_left},
	}

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
	gl.BindVertexArray(cell_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, cell_vbo)
	gl.DrawArrays(gl.TRIANGLES, 0, i32(len(cell_vertices)))

	// draw borders
	gl.UseProgram(border_program)
	gl.BindVertexArray(border_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, border_vbo)
	gl.DrawArrays(gl.LINE_LOOP, 0, i32(len(border_vertices)))
}
