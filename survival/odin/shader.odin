package survival

import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

shader_set_vec3 :: proc(program_id: u32, name: cstring, value_param: glsl.vec3) {
	value := value_param
	gl.Uniform3fv(gl.GetUniformLocation(program_id, name), 1, raw_data(&value))
}
