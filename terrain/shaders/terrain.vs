#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 uv;
layout (location = 2) in vec3 normal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec4 vert_color;
out vec2 vert_uv;
out vec3 vert_normal;

void main()
{
	gl_Position = projection * view * model * vec4(position, 1.0f);

	// Max y = 250
	float c = position.y / 250.0;
	// float c = 1.0;
	vert_color = vec4(c, c, c, 1.0);
	vert_uv = vec2(uv.x, uv.y);
	vert_normal = normal;
}
