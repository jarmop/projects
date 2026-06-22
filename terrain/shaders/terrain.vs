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
	float c = position.y / 300.0;
	// float c = 1.0;
	Color = vec4(c, c, c, 1.0);
}