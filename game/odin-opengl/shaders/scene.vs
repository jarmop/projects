#version 330 core

layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec3 in_normal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 color;
  
out vec3 vertex_color;
out vec3 vertex_normal;

void main()
{
    gl_Position = projection * view * model * vec4(in_pos, 1.0);
    vertex_color = color;
    vertex_normal = in_normal;
} 