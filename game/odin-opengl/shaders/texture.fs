#version 330 core

in vec3 vert_color;
in vec3 vert_normal;
in vec2 vert_uv;

out vec4 frag_color;

uniform sampler2D texture_sampler;

void main()
{
    vec3 ambient = vec3(0.5, 0.5, 0.5);

    vec3 light_direction = normalize(vec3(0.4, 1.0, 0.7));
    vec3 light_direction2 = normalize(vec3(-0.8, 1.0, -0.6));
    float diffuse_strength = max(dot(vert_normal, light_direction), 0.0);
    float diffuse_strength2 = max(dot(vert_normal, light_direction2), 0.0);
    vec3 diffuse = diffuse_strength * vec3(0.2, 0.2, 0.2);
    vec3 diffuse2 = diffuse_strength2 * vec3(0.1, 0.1, 0.1);

    // frag_color = vec4((ambient + diffuse + diffuse2) * vert_color, 1.0);
    // frag_color = texture(texture_sampler, vert_uv);
    // frag_color = texture(texture_sampler, vert_uv) * vec4(1.0, 1.0, 1.0, 1.0);
    frag_color = texture(texture_sampler, vert_uv) * vec4((ambient + diffuse + diffuse2) * vert_color, 1.0);
    // frag_color = vec4(1.0, 0.0, 1.0, 1.0);
    // frag_color = texture(texture_sampler, vert_uv) * vec4((ambient + diffuse + diffuse2) * vec3(1.0, 1.0, 1.0), 1.0);
}