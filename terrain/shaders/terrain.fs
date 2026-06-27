#version 330 core

in vec4 vert_color;
in vec2 vert_uv;
in vec3 vert_normal;

out vec4 frag_color;

uniform sampler2D texture1;

void main()
{
	// if A is a unit vector, dot(A,A)=1
	vec3 reverse_light_dir = normalize(vec3(1.0, 1.0, 1.0));
	float diffuse = max(0.3, dot(vert_normal, reverse_light_dir));

	// frag_color = vert_color;
	frag_color = texture(texture1, vert_uv) * diffuse;

}

// vec3 ambient = vec3(0.5, 0.5, 0.5);
// //   vec3 ambient = vec3(0.0, 0.0, 0.0);

// vec3 light_direction = normalize(vec3(0.4, 1.0, 0.7));
// vec3 light_direction2 = normalize(vec3(-0.8, 1.0, -0.6));
// float diffuse_strength = max(dot(vert_normal, light_direction), 0.0);
// float diffuse_strength2 = max(dot(vert_normal, light_direction2), 0.0);
// vec3 diffuse = diffuse_strength * vec3(1.0, 1.0, 1.0);
// vec3 diffuse2 = diffuse_strength2 * vec3(0.1, 0.1, 0.1);

// // vec3 diffuse = diffuse_strength * vec3(0.5, 0.5, 0.5);
// // vec3 diffuse2 = diffuse_strength2 * vec3(0.3, 0.3, 0.3);

// // frag_color = vec4((ambient + diffuse + diffuse2) * vert_color, 1.0);
// // frag_color = texture(texture_sampler, vert_uv);
// // frag_color = texture(texture_sampler, vert_uv) * vec4(1.0, 1.0, 1.0, 1.0);
// frag_color = texture(texture_sampler, vert_uv) * vec4((ambient + diffuse + diffuse2) * vert_color, 1.0);
// // frag_color = vec4(1.0, 0.0, 1.0, 1.0);
// // frag_color = texture(texture_sampler, vert_uv) * vec4((ambient + diffuse + diffuse2) * vec3(1.0, 1.0, 1.0), 1.0);
