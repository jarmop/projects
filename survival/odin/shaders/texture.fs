#version 330 core

in vec2 v_uv;

uniform sampler2D texture_sampler;

out vec4 frag_color;

void main()
{
	frag_color = texture(texture_sampler, v_uv);
}