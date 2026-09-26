package daw

import "core:fmt"
import "core:math"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

Vec2 :: [2]f32

Vertex :: struct {
	pos: Vec2,
}

padding :: 4

ui_run :: proc() {
	window_init()
	waveform_init()
	slider_init()
	button_init()

	buttons = {{pos = {padding, 52}, on_click = handle_button_click}}

	text_init()

	gl.ClearColor(0.5, 0.5, 0.5, 1)

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.Clear(gl.COLOR_BUFFER_BIT)

		waveform_draw()

		slider_draw()

		button_draw()

		text_draw()

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

	x :: padding
	y: f32 = font_size
	text_add_vertices(fmt.tprintf("Frequency: %d", int(frequency)), {x, y}, width)
	y += line_height
	text_add_vertices(fmt.tprintf("Amplitude: %.2f", amplitude), {x, y}, width)
	y += line_height
	text_add_vertices(fmt.tprintf("Waveform: %s", selected_waveform), {x, y}, width)

	play_button_text := playing ? "Stop" : "Play"
	play_button_text_max_width: f32 = button_width - 2 * button_padding_x

	text_width, text_height := get_text_dimensions(play_button_text, play_button_text_max_width)
	// fmt.println(text_width, text_height)

	button_padding :: padding
	play_button := buttons[0]
	play_button_text_x_offset := (button_width - text_width) / 2
	play_button_text_pos :=
		play_button.pos + {play_button_text_x_offset, button_padding + font_size}
	text_add_vertices(play_button_text, play_button_text_pos, play_button_text_max_width)

	text_set_buffer_data()
}

update_slider_vertices :: proc() {
	slider_bar_vertices = make_quad(bar_width, bar_height)
	update_buffer(&slider_bar_vbo, slider_bar_vertices[:])

	// x2: f32 = frequency / max_frequency * bar_width - handle_size / 2
	x2: f32 = -handle_size / 2
	y2: f32 = (-handle_size + bar_height) / 2
	slider_handle_vertices = make_quad(handle_size, handle_size, x2, y2)
	update_buffer(&slider_handle_vbo, slider_handle_vertices[:])
}

make_quad :: proc(w, h: f32, x: f32 = 0, y: f32 = 0) -> [6]Vertex {
	bottom_left: Vec2 = {x, y}
	bottom_right: Vec2 = {x + w, y}
	top_left: Vec2 = {x, y + h}
	top_right: Vec2 = {x + w, y + h}

	// triangles
	return {
		{pos = bottom_left},
		{pos = bottom_right},
		{pos = top_left},
		{pos = top_left},
		{pos = top_right},
		{pos = bottom_right},
	}
}

make_quad_outline :: proc(w, h: f32, x: f32 = 0, y: f32 = 0) -> [4]Vertex {
	bottom_left: Vec2 = {x, y}
	bottom_right: Vec2 = {x + w, y}
	top_left: Vec2 = {x, y + h}
	top_right: Vec2 = {x + w, y + h}

	// outline
	return {{pos = bottom_left}, {pos = bottom_right}, {pos = top_right}, {pos = top_left}}
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

handle_button_click :: proc() {
	toggle_playback()
	update_text_vertices()
}
