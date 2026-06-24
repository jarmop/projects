package terrain

import "core:math/linalg/glsl"
import "core:os"

import gl "vendor:OpenGL"
import "vendor:glfw"

// vertices_per_side :: 257 // The height_map file has this size
vertices_per_side :: 256
// vertices_per_side :: 4
vertices: [vertices_per_side * vertices_per_side]Vertex
quads_per_side :: vertices_per_side - 1
quad_count :: quads_per_side * quads_per_side
indices_count :: quad_count * 6
indices: [indices_count]u32
scale :: 4

main :: proc() {
	init_io()

	// load_data()
	generate_data()

	// // odinfmt: disable
	// 	vertices := [?]f32 {
	//         0.0, 0.0, 0.0,
	//         1.0, 0.0, 0.0,
	//         1.0, 0.0, 1.0,
	//         0.0, 0.0, 1.0,
	// 	}
	// // odinfmt: enable
	// 	indices := [?]u32{0, 1, 2, 2, 3, 0}

	gl.Enable(gl.DEPTH_TEST)

	shaderProgram, loaded_ok := gl.load_shaders_file(
		"./shaders/terrain.vs",
		"./shaders/terrain.fs",
	)
	if !loaded_ok {
		os.exit(-1)
	}

	VBO, VAO, EBO: u32
	gl.GenVertexArrays(1, &VAO)
	gl.BindVertexArray(VAO)

	gl.GenBuffers(1, &VBO)
	gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), raw_data(&vertices), gl.STATIC_DRAW)

	gl.GenBuffers(1, &EBO)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), raw_data(&indices), gl.STATIC_DRAW)

	POS_LOC :: 0
	gl.VertexAttribPointer(POS_LOC, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), offset_of(Vertex, pos))
	gl.EnableVertexAttribArray(POS_LOC)

	TEX_LOC :: 1
	gl.VertexAttribPointer(TEX_LOC, 2, gl.FLOAT, gl.FALSE, size_of(Vertex), offset_of(Vertex, uv))
	gl.EnableVertexAttribArray(TEX_LOC)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	init_texture()

	gl.UseProgram(shaderProgram)
	shader_set_int(shaderProgram, "texture1", 0)

	// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	for !glfw.WindowShouldClose(window) {
		currentFrame := f32(glfw.GetTime())
		deltaTime = currentFrame - lastFrame
		lastFrame = currentFrame

		processInput(window)

		gl.ClearColor(0.0, 0.0, 0.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		gl.ActiveTexture(gl.TEXTURE0)
		gl.BindTexture(gl.TEXTURE_2D, texture1)

		view: glsl.mat4 = 1
		view *= glsl.mat4LookAt(cameraPos, cameraPos + cameraFront, cameraUp)

		projection: glsl.mat4 = 1
		projection *= glsl.mat4Perspective(
			glsl.radians_f32(45),
			f32(f32(SCR_WIDTH) / f32(SCR_HEIGHT)),
			near,
			far,
		)

		shader_set_mat4(shaderProgram, "projection", projection)
		shader_set_mat4(shaderProgram, "view", view)

		gl.BindVertexArray(VAO)
		model: glsl.mat4 = 1
		shader_set_mat4(shaderProgram, "model", model)

		gl.DrawElements(gl.TRIANGLES, indices_count, gl.UNSIGNED_INT, nil)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

	gl.DeleteVertexArrays(1, &VAO)
	gl.DeleteBuffers(1, &VBO)
	gl.DeleteProgram(shaderProgram)

	glfw.Terminate()
}
