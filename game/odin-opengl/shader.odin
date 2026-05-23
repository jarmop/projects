package game

import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

shader_set_int :: proc(program_id: u32, name: cstring, value: i32) {
	gl.Uniform1i(gl.GetUniformLocation(program_id, name), value)
}

shader_set_vec3 :: proc(program_id: u32, name: cstring, value_param: glsl.vec3) {
	value := value_param
	gl.Uniform3fv(gl.GetUniformLocation(program_id, name), 1, raw_data(&value))
}

shader_set_mat4 :: proc(program_id: u32, name: cstring, value_param: glsl.mat4) {
	value := value_param
	gl.UniformMatrix4fv(gl.GetUniformLocation(program_id, name), 1, gl.FALSE, raw_data(&value))
}

use_texture_shader :: proc(view: glsl.mat4, projection: glsl.mat4) {
	gl.UseProgram(texture_shader_program)
	shader_set_mat4(texture_shader_program, "view", view)
	shader_set_mat4(texture_shader_program, "projection", projection)
}

use_color_shader :: proc(view: glsl.mat4, projection: glsl.mat4) {
	gl.UseProgram(color_shader_program)
	shader_set_mat4(color_shader_program, "view", view)
	shader_set_mat4(color_shader_program, "projection", projection)
}
