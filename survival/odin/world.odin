package survival

import gl "vendor:OpenGL"

WorldVertex :: struct {
	pos: [3]f32,
}

world_vao: u32
world_vbo: u32

init_world :: proc() {

	gl.GenVertexArrays(1, &world_vao)
	gl.BindVertexArray(world_vao)

	gl.GenBuffers(1, &world_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, world_vbo)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(WorldVertex), 0)
	gl.EnableVertexAttribArray(0)
}

draw_world :: proc() {
	gl.UseProgram(0)

	gl.BindVertexArray(world_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, world_vbo)

	world_vertices: []WorldVertex = {{pos = {0, 0, 0}}, {pos = {0.5, 0, 0}}, {pos = {0.5, 0.5, 0}}}

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(world_vertices) * size_of(WorldVertex),
		raw_data(world_vertices),
		gl.DYNAMIC_DRAW,
	)

	gl.DrawArrays(gl.TRIANGLES, 0, 3)
}
