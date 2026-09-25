package daw

import "core:fmt"
import "core:math"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

Vec3 :: [3]f32

Vertex :: struct {
	pos: Vec3,
}

waveform_vao: u32
waveform_vbo: u32

waveform_vertices: []Vertex

ui_init :: proc() {
	window_init()
	waveform_init()

	text_init()
	update_text_vertices()

	gl.ClearColor(0.5, 0.5, 0.5, 1)

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.Clear(gl.COLOR_BUFFER_BIT)

		waveform_draw()

		text_draw()

		glfw.SwapBuffers(window)
	}
}

waveform_init :: proc() {
	gl.GenVertexArrays(1, &waveform_vao)
	gl.BindVertexArray(waveform_vao)

	gl.GenBuffers(1, &waveform_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, waveform_vbo)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), 0)
	gl.EnableVertexAttribArray(0)

	update_waveform_vertices()
}

waveform_draw :: proc() {
	gl.UseProgram(0)

	gl.BindVertexArray(waveform_vao)
	gl.DrawArrays(gl.LINE_STRIP, 0, i32(len(waveform_vertices)))
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
			pos = ({x, s, 0} * (1 - margin)),
		}
	}

	gl.BindBuffer(gl.ARRAY_BUFFER, waveform_vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(waveform_vertices) * size_of(Vertex),
		raw_data(waveform_vertices),
		gl.STATIC_DRAW,
	)
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
