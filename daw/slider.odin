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
	pos:   Vec2,
	value: ^f32,
	max:   f32,
}

sliders: [2]Slider

bar_width: f32 = 100
bar_height: f32 = 2
handle_size: f32 = font_size

slider_init :: proc() {
	sliders = {
		{pos = {110, (handle_size + 2) / 2}, value = &frequency, max = max_frequency},
		{pos = {110, line_height + line_height / 2}, value = &amplitude, max = max_amplitude},
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

	for slider in sliders {
		shader_set_vec2(ui_program, "model", slider.pos)

		shader_set_vec4(ui_program, "color", {0.2, 0.2, 0.2, 1})
		gl.BindVertexArray(slider_bar_vao)
		gl.DrawArrays(gl.TRIANGLES, 0, i32(len(slider_bar_vertices)))

		// set handle model here
		handle_x := slider.value^ / slider.max * bar_width
		// - handle_size / 2
		// handle_y := (-handle_size + bar_height) / 2
		// handle_pos := slider.pos + {handle_x, handle_y}
		handle_pos := slider.pos + {handle_x, 0}

		shader_set_vec2(ui_program, "model", handle_pos)

		shader_set_vec4(ui_program, "color", {0, 0, 0, 1})
		gl.BindVertexArray(slider_handle_vao)
		gl.DrawArrays(gl.TRIANGLES, 0, i32(len(slider_handle_vertices)))
	}
}
