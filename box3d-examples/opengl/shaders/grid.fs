#version 330 core

in vec2 uv_vert;

// Grid customization options
uniform vec4 grid_color = vec4(1.0, 1.0, 1.0, 1.0); // White grid lines
uniform vec4 bg_color = vec4(0.1, 0.1, 0.1, 1.0);    // Dark grey background
uniform float grid_scale = 10.0;                     // How many grid squares total
uniform float line_width_pixels = 1.0;                // Target line width in screen pixels

out vec4 color_frag;

void main()
{
    // 1. Scale up the UV coordinates to create repetitions
    vec2 scaled_uv = uv_vert * grid_scale;

    // 2. Find the distance from the center of the grid tile [0.0, 0.5]
    // fract(scaled_uv) creates a repeating [0.0, 1.0] space
    vec2 grid_space = abs(fract(scaled_uv - 0.5) - 0.5);

    // 3. Use fwidth to find the screen-space rate of change of the UVs.
    // This tells us exactly how much UV space is covered by a single screen pixel.
    vec2 derivative = fwidth(scaled_uv);

    // 4. Determine the target line thickness in UV coordinates
    vec2 target_width = derivative * line_width_pixels;

    // 5. Use smoothstep to calculate an anti-aliased edge for both X and Y lines.
    // If the pixel is inside the target width, alpha will approach 1.0.
    vec2 line_aa = smoothstep(target_width, vec2(0.0), grid_space);

    // 6. Combine X and Y lines together (taking the maximum intensity)
    float grid_intensity = max(line_aa.x, line_aa.y);

    // 7. Linearly blend between the background color and the grid color
    color_frag = mix(bg_color, grid_color, grid_intensity);
}
