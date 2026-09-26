package daw

import gl "vendor:OpenGL"

waveform_vao: u32
waveform_vbo: u32
waveform_vertices: []Vertex

waveform_init :: proc() {
	gl.GenVertexArrays(1, &waveform_vao)
	gl.BindVertexArray(waveform_vao)

	gl.GenBuffers(1, &waveform_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, waveform_vbo)

	gl.VertexAttribPointer(
		0,
		size_of(Vertex) / size_of(f32),
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		0,
	)
	gl.EnableVertexAttribArray(0)

	update_waveform_vertices()
}

waveform_draw :: proc() {
	gl.UseProgram(0)

	gl.BindVertexArray(waveform_vao)
	gl.DrawArrays(gl.LINE_STRIP, 0, i32(len(waveform_vertices)))
}
