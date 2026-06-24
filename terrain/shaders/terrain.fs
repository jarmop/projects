#version 330 core

in vec4 vert_color;
in vec2 vert_uv;

out vec4 frag_color;

uniform sampler2D texture1;

void main()
{
	// frag_color = vert_color;
	frag_color = texture(texture1, vert_uv);
}

// #version 330 core
// out vec4 FragColor;

// in vec3 ourColor;
// in vec2 TexCoord;

// // texture samplers
// uniform sampler2D texture1;
// uniform sampler2D texture2;

// void main()
// {
// 	// linearly interpolate between both textures (80% container, 20% awesomeface)
// 	FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.2);
// }