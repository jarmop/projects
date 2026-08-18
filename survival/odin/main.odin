package main

import "core:fmt"
import "core:os"

import gl "vendor:OpenGL"
import glfw "vendor:glfw"

import stbtt "vendor:stb/truetype"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720

FONT_BITMAP_W :: 512
FONT_BITMAP_H :: 512

Glyph :: struct {
	x0, y0:   f32,
	x1, y1:   f32,
	s0, t0:   f32,
	s1, t1:   f32,
	xadvance: f32,
}

main :: proc() {
	// -----------------------------------------
	// GLFW init
	// -----------------------------------------

	if !glfw.Init() {
		panic("Failed to init GLFW")
	}
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	window := glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Odin OpenGL Text", nil, nil)

	if window == nil {
		panic("Failed to create window")
	}

	// window.MakeContextCurrent()
	glfw.MakeContextCurrent(window)

	// Load OpenGL functions
	// if !gl.load(glfw.GetProcAddress) {
	// 	panic("Failed to load OpenGL")
	// }
	gl.load_up_to(3, 3, glfw.gl_set_proc_address)

	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

	// -----------------------------------------
	// Compile shaders
	// -----------------------------------------

	vertex_shader_source := `#version 330 core

layout(location = 0) in vec2 in_pos;
layout(location = 1) in vec2 in_uv;

out vec2 frag_uv;

uniform vec2 screen_size;

void main() {
	vec2 p = in_pos / screen_size * 2.0 - 1.0;

	// Flip Y
	p.y = -p.y;

	gl_Position = vec4(p, 0.0, 1.0);
	frag_uv = in_uv;
}
`

	fragment_shader_source := `#version 330 core

in vec2 frag_uv;
out vec4 out_color;

uniform sampler2D tex;

void main() {
	float a = texture(tex, frag_uv).r;
	out_color = vec4(1.0, 1.0, 1.0, a);
}
`

	program := create_shader_program(vertex_shader_source, fragment_shader_source)

	// -----------------------------------------
	// Load font
	// -----------------------------------------

	font_data, err := os.read_entire_file_from_path(
		"/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
		context.allocator,
	)
	assert(err == nil)

	bitmap := make([]u8, FONT_BITMAP_W * FONT_BITMAP_H)

	Glyph_Count :: 96
	// baked_chars := make([96]stbtt.bakedchar)
	baked_chars: [Glyph_Count]stbtt.bakedchar

	stbtt.BakeFontBitmap(
		raw_data(font_data),
		0,
		32.0,
		raw_data(bitmap),
		FONT_BITMAP_W,
		FONT_BITMAP_H,
		32,
		Glyph_Count,
		&baked_chars[0],
	)

	// -----------------------------------------
	// Upload texture
	// -----------------------------------------

	texture: u32

	gl.GenTextures(1, &texture)
	gl.BindTexture(gl.TEXTURE_2D, texture)

	// gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)

	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RED,
		FONT_BITMAP_W,
		FONT_BITMAP_H,
		0,
		gl.RED,
		gl.UNSIGNED_BYTE,
		raw_data(bitmap),
	)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	// -----------------------------------------
	// Vertex setup
	// -----------------------------------------

	vao: u32
	vbo: u32

	gl.GenVertexArrays(1, &vao)
	gl.GenBuffers(1, &vbo)

	gl.BindVertexArray(vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 2, gl.FLOAT, false, 4 * size_of(f32), uintptr(0))

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(1, 2, gl.FLOAT, false, 4 * size_of(f32), uintptr(2 * size_of(f32)))

	screen_size_loc := gl.GetUniformLocation(program, "screen_size")

	// -----------------------------------------
	// Main loop
	// -----------------------------------------

	// for !window.ShouldClose() {
	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()

		gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

		gl.ClearColor(0.1, 0.1, 0.1, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		gl.UseProgram(program)

		gl.Uniform2f(screen_size_loc, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT))

		gl.ActiveTexture(gl.TEXTURE0)
		gl.BindTexture(gl.TEXTURE_2D, texture)

		draw_text(program, vao, vbo, baked_chars[:], "Hello from stb_truetype", 50, 100)

		glfw.SwapBuffers(window)
	}
}

draw_text :: proc(
	program: u32,
	vao: u32,
	vbo: u32,
	chars: []stbtt.bakedchar,
	text: string,
	start_x, start_y: f32,
) {
	x := start_x
	y := start_y

	vertices := make([dynamic]f32)
	defer delete(vertices)

	for c in text {
		if c < 32 || c >= 128 {
			continue
		}

		q: stbtt.aligned_quad

		stbtt.GetBakedQuad(&chars[0], FONT_BITMAP_W, FONT_BITMAP_H, i32(c - 32), &x, &y, &q, true)

		append(
			&vertices,
			q.x0,
			q.y0,
			q.s0,
			q.t0,
			q.x1,
			q.y0,
			q.s1,
			q.t0,
			q.x1,
			q.y1,
			q.s1,
			q.t1,
			q.x0,
			q.y0,
			q.s0,
			q.t0,
			q.x1,
			q.y1,
			q.s1,
			q.t1,
			q.x0,
			q.y1,
			q.s0,
			q.t1,
		)
	}

	gl.BindVertexArray(vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(f32),
		raw_data(vertices),
		gl.DYNAMIC_DRAW,
	)

	gl.DrawArrays(gl.TRIANGLES, 0, i32(len(vertices) / 4))
}

create_shader_program :: proc(vs_source, fs_source: string) -> u32 {
	vs := compile_shader(vs_source, gl.VERTEX_SHADER)
	fs := compile_shader(fs_source, gl.FRAGMENT_SHADER)

	program := gl.CreateProgram()

	gl.AttachShader(program, vs)
	gl.AttachShader(program, fs)

	gl.LinkProgram(program)

	success: i32
	gl.GetProgramiv(program, gl.LINK_STATUS, &success)

	if success == 0 {
		log: [1024]u8
		gl.GetProgramInfoLog(program, 1024, nil, &log[0])

		fmt.println(cstring(&log[0]))
		panic("Shader link failed")
	}

	gl.DeleteShader(vs)
	gl.DeleteShader(fs)

	return program
}

compile_shader :: proc(source: string, shader_type: u32) -> u32 {
	shader := gl.CreateShader(shader_type)

	src := source
	ptr := cstring(raw_data(src))

	gl.ShaderSource(shader, 1, &ptr, nil)
	gl.CompileShader(shader)

	success: i32
	gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success)

	if success == 0 {
		log: [1024]u8
		gl.GetShaderInfoLog(shader, 1024, nil, &log[0])

		fmt.println(cstring(&log[0]))
		panic("Shader compile failed")
	}

	return shader
}
