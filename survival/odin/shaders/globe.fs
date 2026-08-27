#version 330 core

in vec2 uv;

// uniform sampler2D texture_sampler;

out vec4 color;

void main()
{
    color = vec4(uv.x, uv.y, 0.0, 1.0);
    // color = vec4(1.0, 1.0, 1.0, 1.0);
	// color = texture(texture_sampler, uv);
}