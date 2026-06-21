#version 330 core

layout (location = 0) in vec3 position;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec4 Color;

void main()
{
	gl_Position = projection * view * model * vec4(position, 1.0f);

	// Max y = 200
	Color = vec4(position.y / 200.0);
}