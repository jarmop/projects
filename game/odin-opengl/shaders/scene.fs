#version 330 core

in vec4 model_color;

out vec4 frag_color;

void main()
{
    frag_color = model_color;
}