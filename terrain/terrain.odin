package terrain

import "core:math/linalg/glsl"
import "core:os"

import gl "vendor:OpenGL"
import "vendor:glfw"

main :: proc() {
	init_io()
	
// odinfmt: disable
	vertices := [?]f32 {
        -0.5, 0.0, -0.5,
         0.5, 0.0, -0.5,
         0.5, 0.0,  0.5,
        //  0.5, 0.0,  0.5,
        -0.5, 0.0,  0.5,
        // -0.5, 0.0, -0.5,
	}
// odinfmt: enable

	indices := [?]u32{0, 1, 2, 2, 3, 0}

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
	gl.GenBuffers(1, &VBO)
	gl.GenBuffers(1, &EBO)

	gl.BindVertexArray(VAO)

	gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), raw_data(&vertices), gl.STATIC_DRAW)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), raw_data(&indices), gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	gl.UseProgram(shaderProgram)

	for !glfw.WindowShouldClose(window) {
		currentFrame := f32(glfw.GetTime())
		deltaTime = currentFrame - lastFrame
		lastFrame = currentFrame

		processInput(window)

		gl.ClearColor(0.0, 0.0, 0.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		gl.UseProgram(shaderProgram)

		view: glsl.mat4 = 1
		view *= glsl.mat4LookAt(cameraPos, cameraPos + cameraFront, cameraUp)

		projection: glsl.mat4 = 1
		projection *= glsl.mat4Perspective(
			glsl.radians_f32(45),
			f32(f32(SCR_WIDTH) / f32(SCR_HEIGHT)),
			0.1,
			100,
		)

		shader_set_mat4(shaderProgram, "projection", projection)
		shader_set_mat4(shaderProgram, "view", view)

		gl.BindVertexArray(VAO)
		model: glsl.mat4 = 1
		shader_set_mat4(shaderProgram, "model", model)

		// gl.DrawArrays(gl.TRIANGLES, 0, 36)
		gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}

	gl.DeleteVertexArrays(1, &VAO)
	gl.DeleteBuffers(1, &VBO)
	gl.DeleteProgram(shaderProgram)

	glfw.Terminate()
}
