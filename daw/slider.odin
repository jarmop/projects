package daw

import "core:fmt"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"

ui_program: u32

slider_bar_vao: u32
slider_bar_vbo: u32
slider_bar_vertices: [6]Vertex

slider_handle_vao: u32
slider_handle_vbo: u32
slider_handle_vertices: [6]Vertex

Slider :: struct {
	pos:         Vec2,
	bar_width:   f32,
	bar_height:  f32,
	handle_size: f32,
}

slider: Slider

slider_init :: proc() {
	slider = {
		pos         = {100, 100},
		bar_width   = 100,
		bar_height  = 2,
		handle_size = 20,
	}

	// -----------------------------------------
	// Load shaders
	// -----------------------------------------
	shaders_ok: bool
	ui_program, shaders_ok = gl.load_shaders_file("./shaders/ui.vs", "./shaders/ui.fs")
	if !shaders_ok {
		fmt.println("Shaders not ok")
		os.exit(-1)
	}

	// --------------
	// Slider bar
	// --------------
	gl.GenVertexArrays(1, &slider_bar_vao)
	gl.BindVertexArray(slider_bar_vao)

	gl.GenBuffers(1, &slider_bar_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, slider_bar_vbo)

	gl.VertexAttribPointer(
		0,
		size_of(Vertex) / size_of(f32),
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		0,
	)
	gl.EnableVertexAttribArray(0)

	// --------------
	// Slider handle
	// --------------
	gl.GenVertexArrays(1, &slider_handle_vao)
	gl.BindVertexArray(slider_handle_vao)

	gl.GenBuffers(1, &slider_handle_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, slider_handle_vbo)

	gl.VertexAttribPointer(
		0,
		size_of(Vertex) / size_of(f32),
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		0,
	)
	gl.EnableVertexAttribArray(0)

	update_slider_vertices()
}

slider_draw :: proc() {
	gl.UseProgram(ui_program)

	gl.Uniform2f(screen_size_loc, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT))

	shader_set_vec2(ui_program, "model", slider.pos)

	shader_set_vec4(ui_program, "color", {0.2, 0.2, 0.2, 1})
	gl.BindVertexArray(slider_bar_vao)
	gl.DrawArrays(gl.TRIANGLES, 0, i32(len(slider_bar_vertices)))

	shader_set_vec4(ui_program, "color", {0, 0, 0, 1})
	gl.BindVertexArray(slider_handle_vao)
	gl.DrawArrays(gl.TRIANGLES, 0, i32(len(slider_handle_vertices)))
}
