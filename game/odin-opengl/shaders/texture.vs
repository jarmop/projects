#version 330 core

layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec3 in_normal;
layout (location = 2) in vec2 in_uv;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 color;
  
out vec3 vert_color;
out vec3 vert_normal;
out vec2 vert_uv;

void main()
{
    gl_Position = projection * view * model * vec4(in_pos, 1.0);
    vert_color = color;
    vert_normal = in_normal;
    // vert_uv = in_uv;
    vert_uv = vec2(in_uv.x, 1.0 - in_uv.y);
} 