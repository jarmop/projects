package daw

import "core:fmt"
import "core:math"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

Vec3 :: [3]f32

Vertex :: struct {
	pos: Vec3,
}

vao: u32

vertices: []Vertex

ui :: proc() {
	window_init()

	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	vbo: u32
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), 0)
	gl.EnableVertexAttribArray(0)

	update_vertices()

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.BindVertexArray(vao)

		gl.DrawArrays(gl.LINE_STRIP, 0, i32(len(vertices)))

		glfw.SwapBuffers(window)
	}
}

update_vertices :: proc() {
	samples_count := 400
	vertices = make([]Vertex, samples_count)
	for i in 0 ..< samples_count {
		phase := f32(i) / f32(samples_count - 1)
		x := phase * 2 - 1
		s := get_sine_sample(phase)
		// s := get_square_sample(phase)
		// s := get_triangle_sample(phase)
		// s := get_sawtooth_sample(phase)

		margin: f32 = 0.2

		vertices[i] = {
			pos = ({x, s, 0} * (1 - margin)),
		}
	}

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(Vertex),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)
}
