#version 330 core

uniform sampler2D texture_sampler;

in vec2 uv_vert;

out vec4 color_frag;

void main()
{
	color_frag = texture(texture_sampler, uv_vert);
}