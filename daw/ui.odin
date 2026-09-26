package daw

import "core:fmt"
import "core:math"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

Vec2 :: [2]f32

Vertex :: struct {
	pos: Vec2,
}

ui_run :: proc() {
	window_init()
	waveform_init()
	text_init()
	slider_init()

	gl.ClearColor(0.5, 0.5, 0.5, 1)

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.Clear(gl.COLOR_BUFFER_BIT)

		waveform_draw()

		text_draw()

		slider_draw()

		glfw.SwapBuffers(window)
	}
}

update_waveform_vertices :: proc() {
	samples_count := 400
	waveform_vertices = make([]Vertex, samples_count)
	for i in 0 ..< samples_count {
		phase := f32(i) / f32(samples_count - 1)
		x := phase * 2 - 1
		s := waveform_function_map[selected_waveform](phase)

		margin: f32 = 0.2

		waveform_vertices[i] = {
			pos = ({x, s} * (1 - margin)),
		}
	}

	update_buffer(&waveform_vbo, waveform_vertices[:])
}

update_text_vertices :: proc() {
	clear(&text_vertices)

	width: f32 = 120

	text_add_vertices(fmt.tprintf("Frequency: %d", int(frequency)), {4, 14}, width)
	text_add_vertices(fmt.tprintf("Amplitude: %.1f", amplitude), {4, 14 + 2 + 14}, width)
	text_add_vertices(
		fmt.tprintf("Waveform: %s", selected_waveform),
		{4, 14 + 2 + 14 + 2 + 14},
		width,
	)

	text_set_buffer_data()
}

h1: f32 = 2

update_slider_vertices :: proc() {
	w1: f32 = slider.width
	slider_bar_vertices = make_quad(w1, h1)
	update_buffer(&slider_bar_vbo, slider_bar_vertices[:])

	x2: f32 = frequency / max_frequency * slider.width - slider.handle_size / 2
	y2: f32 = (-slider.handle_size + h1) / 2
	slider_handle_vertices = make_quad(slider.handle_size, slider.handle_size, x2, y2)
	update_buffer(&slider_handle_vbo, slider_handle_vertices[:])
}

make_quad :: proc(w, h: f32, x: f32 = 0, y: f32 = 0) -> [6]Vertex {
	return {
		{pos = {x, y}},
		{pos = {x + w, y}},
		{pos = {x, y + h}},
		{pos = {x, y + h}},
		{pos = {x + w, y + h}},
		{pos = {x + w, y}},
	}
}

update_buffer :: proc(vbo: ^u32, vertices: []Vertex) {
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo^)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(Vertex),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)
}
