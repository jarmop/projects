#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 uv;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec4 vert_color;
out vec2 vert_uv;

void main()
{
	gl_Position = projection * view * model * vec4(position, 1.0f);

	// Max y = 250
	float c = position.y / 250.0;
	// float c = 1.0;
	vert_color = vec4(c, c, c, 1.0);
	vert_uv = vec2(uv.x, uv.y);
}

// #version 330 core
// layout (location = 0) in vec3 aPos;
// layout (location = 1) in vec3 aColor;
// layout (location = 2) in vec2 aTexCoord;

// out vec3 ourColor;
// out vec2 TexCoord;

// void main()
// {
// 	gl_Position = vec4(aPos, 1.0);
// 	ourColor = aColor;
// 	TexCoord = vec2(aTexCoord.x, aTexCoord.y);
// }