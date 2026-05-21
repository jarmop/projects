package game

import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

shader_set_mat4 :: proc(program_id: u32, name: cstring, value_param: glsl.mat4) {
	value := value_param
	gl.UniformMatrix4fv(gl.GetUniformLocation(program_id, name), 1, gl.FALSE, raw_data(&value))
}
