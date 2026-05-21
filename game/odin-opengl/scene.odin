package game

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"

scene_shader_program: u32

scene_vbo, scene_vao: u32

init_scene :: proc() {
	vertices := [?]f32{0.5, -0.5, 0.0, -0.5, -0.5, 0.0, 0.0, 0.5, 0.0}

	shader_ok: bool
	scene_shader_program, shader_ok = gl.load_shaders_file(
		"./shaders/scene.vs",
		"./shaders/scene.fs",
	)
	if !shader_ok {
		fmt.println("Shader not ok")
		os.exit(-1)
	}

	gl.GenVertexArrays(1, &scene_vao)
	gl.GenBuffers(1, &scene_vbo)

	gl.BindVertexArray(scene_vao)

	gl.BindBuffer(gl.ARRAY_BUFFER, scene_vbo)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), raw_data(&vertices), gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)
}

draw_scene :: proc() {
	gl.UseProgram(scene_shader_program)
	gl.BindVertexArray(scene_vao)
	gl.DrawArrays(gl.TRIANGLES, 0, 3)
}
