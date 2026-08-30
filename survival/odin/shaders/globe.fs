#version 330 core

in vec2 uv;

// uniform sampler2D texture_sampler;
uniform vec4 color;

out vec4 frag_color;

void main()
{
    // frag_color = vec4(uv.x, uv.y, 0.0, 1.0);
    frag_color = color;
    // frag_color = vec4(1.0, 1.0, 1.0, 1.0);
	// frag_color = texture(texture_sampler, uv);
}