#version 330 core

layout(location = 0) in vec2 in_pos;

uniform vec2 world_pos;
uniform vec2 screen_size;
uniform vec3 color;

out vec3 vert_color;

void main() {
	vec2 pos = (in_pos + world_pos) / screen_size * 2.0 - 1.0;

	// Flip Y
	pos.y = -pos.y;

	gl_Position = vec4(pos, 0.0, 1.0);
    vert_color = color; 
}