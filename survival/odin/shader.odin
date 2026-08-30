package survival

import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

shader_set_vec3 :: proc(program_id: u32, name: cstring, value_param: glsl.vec3) {
	value := value_param
	gl.Uniform3fv(gl.GetUniformLocation(program_id, name), 1, raw_data(&value))
}

shader_set_vec4 :: proc(program_id: u32, name: cstring, value_param: glsl.vec4) {
	value := value_param
	gl.Uniform4fv(gl.GetUniformLocation(program_id, name), 1, raw_data(&value))
}

shader_set_int :: proc(id: u32, name: cstring, value: i32) {
	gl.Uniform1i(gl.GetUniformLocation(id, name), value)
}

shader_set_mat4 :: proc(program_id: u32, name: cstring, value_param: glsl.mat4) {
	value := value_param
	gl.UniformMatrix4fv(gl.GetUniformLocation(program_id, name), 1, gl.FALSE, raw_data(&value))
}
