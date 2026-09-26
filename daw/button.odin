package daw

import "core:fmt"
import gl "vendor:OpenGL"

button_vao: u32
button_vertices: [4]Vertex
button_triangle_indices: [6]u32

Button :: struct {
	pos:      Vec2,
	on_click: proc(),
}

buttons: [1]Button

// button_width :: 60
button_padding_x :: padding * 2
// button_width :: 28 + 2 * button_padding_x
button_width :: 50
button_height :: 28
// button_height :: 2 * padding + line_height

button_init :: proc() {
	button_vertices = make_quad_outline(button_width, button_height)
	vertices_init(&button_vao, button_vertices[:])

	button_triangle_indices = {0, 1, 3, 3, 2, 1}

	// gl.GenVertexArrays(1, &button_vao)
	// gl.BindVertexArray(button_vao)

	ebo: u32
	gl.GenBuffers(1, &ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(button_triangle_indices) * size_of(u32),
		// raw_data(button_triangle_indices),
		&button_triangle_indices,
		gl.STATIC_DRAW,
	)
}

vertices_init :: proc(vao: ^u32, vertices: []Vertex) {
	vbo: u32

	gl.GenVertexArrays(1, vao)
	gl.BindVertexArray(vao^)

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	gl.VertexAttribPointer(
		0,
		size_of(Vertex) / size_of(f32),
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		0,
	)
	gl.EnableVertexAttribArray(0)

	// update_buffer(&vbo, vertices)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(Vertex),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)

	// ebo: u32
	// gl.GenBuffers(1, &ebo)
	// gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	// gl.BufferData(
	// 	gl.ELEMENT_ARRAY_BUFFER,
	// 	len(button_triangle_indices) * size_of(u32),
	// 	// raw_data(button_triangle_indices),
	// 	&button_triangle_indices,
	// 	gl.STATIC_DRAW,
	// )
}

button_draw :: proc() {
	gl.UseProgram(ui_program)

	gl.Uniform2f(screen_size_loc, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT))

	for button in buttons {
		shader_set_vec2(ui_program, "model", button.pos)
		shader_set_vec4(ui_program, "color", {1.0, 1.0, 1.0, 1})
		gl.BindVertexArray(button_vao)
		// gl.PolygonMode(gl.FRONT, gl.LINE)
		// gl.DrawArrays(gl.TRIANGLES, 0, i32(len(button_vertices)))

		// Background
		gl.DrawElements(gl.TRIANGLES, i32(len(button_triangle_indices)), gl.UNSIGNED_INT, nil)

		shader_set_vec4(ui_program, "color", {0.2, 0.2, 0.2, 1})

		// Border
		gl.LineWidth(2.0)
		gl.DrawArrays(gl.LINE_LOOP, 0, i32(len(button_vertices)))
		gl.LineWidth(1.0)

		// // Border corners
		// gl.PointSize(2.0)
		// gl.DrawArrays(gl.POINTS, 0, i32(len(button_vertices)))
		// gl.PointSize(1.0)
	}
}
