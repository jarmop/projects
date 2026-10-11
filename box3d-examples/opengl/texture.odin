package main

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

texture_sampler: u32

texture_init :: proc() {
	gl.GenTextures(1, &texture_sampler)
	gl.BindTexture(gl.TEXTURE_2D, texture_sampler)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	width, height, nrChannels: i32
	stbi.set_flip_vertically_on_load(1)
	data := stbi.load("./assets/container.jpg", &width, &height, &nrChannels, 0)
	if data == nil {
		fmt.println("Failed to load texture")
		os.exit(-1)
	}
	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
	stbi.image_free(data)

	gl.GenerateMipmap(gl.TEXTURE_2D)

	gl.UseProgram(shader_program_texture)
	shader_set_int(shader_program_texture, "texture_sampler", 0)
}

// texture_draw :: proc() {
// 	gl.ActiveTexture(gl.TEXTURE0)
// 	gl.BindTexture(gl.TEXTURE_2D, texture_sampler)
// }
