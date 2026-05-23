#version 330 core

in vec3 vert_color;
in vec3 vert_normal;
in vec2 vert_uv;

out vec4 frag_color;

uniform sampler2D texture_sampler;

void main()
{
    frag_color = vec4(vert_color, 1.0);
}