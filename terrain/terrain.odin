package terrain

import "core:fmt"
import "core:math/linalg/glsl"
import "core:os"
import "core:slice"

import gl "vendor:OpenGL"
import "vendor:glfw"

main :: proc() {
	init_io()

	load_data()

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

	// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	for !glfw.WindowShouldClose(window) {
		currentFrame := f32(glfw.GetTime())
		deltaTime = currentFrame - lastFrame
		lastFrame = currentFrame

		processInput(window)

		gl.ClearColor(0.0, 0.0, 0.0, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		view: glsl.mat4 = 1
		view *= glsl.mat4LookAt(cameraPos, cameraPos + cameraFront, cameraUp)

		projection: glsl.mat4 = 1
		projection *= glsl.mat4Perspective(
			glsl.radians_f32(45),
			f32(f32(SCR_WIDTH) / f32(SCR_HEIGHT)),
			0.1,
			1000,
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

height_map_filename := "data/heightmap.save"

vertices_per_side :: 257
vertices: [vertices_per_side * vertices_per_side * 3]f32
quads_per_side :: vertices_per_side - 1
quad_count :: quads_per_side * quads_per_side
indices_count :: quad_count * 6
indices: [indices_count]u32
scale :: 4

load_data :: proc() {
	data, read_err := os.read_entire_file(height_map_filename, context.allocator)
	if (read_err != nil) {
		fmt.println(read_err)
	}
	defer delete(data)

	// terrain_size := math.sqrt(f32(len(data)) / size_of(f32))
	// fmt.println(terrain_size)

	// Fill vertices
	index := 0
	for z := 0; z < vertices_per_side; z += 1 {
		for x := 0; x < vertices_per_side; x += 1 {
			i := z * vertices_per_side * size_of(f32) + x * size_of(f32)
			f := slice.to_type(data[i:(i + size_of(f32))], f32)
			vertices[index] = f32(x)
			vertices[index + 1] = f / scale
			// vertices[index + 1] = 0.0
			vertices[index + 2] = f32(z)

			index += 3
		}
	}

	// Fill indices
	index = 0
	for z: u32 = 0; z < quads_per_side; z += 1 {
		for x: u32 = 0; x < quads_per_side; x += 1 {
			top_left := z * vertices_per_side + x
			top_right := z * vertices_per_side + x + 1
			bottom_left := (z + 1) * vertices_per_side + x
			bottom_right := (z + 1) * vertices_per_side + x + 1

			indices[index] = top_left
			indices[index + 1] = top_right
			indices[index + 2] = bottom_right
			indices[index + 3] = bottom_right
			indices[index + 4] = bottom_left
			indices[index + 5] = top_left

			index += 6
		}
	}
}
