package game

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"
import stbtt "vendor:stb/truetype"

FONT_BITMAP_W :: 512
FONT_BITMAP_H :: 512
GLYPH_COUNT :: 96
FONT_SIZE_PX :: 16
FIRST_PRINTABLE_ASCII :: 32
LAST_PRINTABLE_ASCII :: 127

ui_texture: u32

baked_chars: [GLYPH_COUNT]stbtt.bakedchar

font_bitmap: [FONT_BITMAP_W * FONT_BITMAP_H]u8

ui_uloc_screen_size: i32

ui_shader_program: u32

ui_vao: u32
ui_vbo: u32

init_ui :: proc() {
	shader_ok: bool
	ui_shader_program, shader_ok = gl.load_shaders_file("./shaders/ui.vs", "./shaders/ui.fs")
	if !shader_ok {
		fmt.println("Shader not ok")
		os.exit(-1)
	}

	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

	gl.GenVertexArrays(1, &ui_vao)
	gl.GenBuffers(1, &ui_vbo)

	gl.BindVertexArray(ui_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, ui_vbo)

	// in_pos
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 2, gl.FLOAT, false, 4 * size_of(f32), uintptr(0))

	// in_uv
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(1, 2, gl.FLOAT, false, 4 * size_of(f32), uintptr(2 * size_of(f32)))

	ui_uloc_screen_size = gl.GetUniformLocation(ui_shader_program, "screen_size")

	font_data, err := os.read_entire_file_from_path(
		"/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
		context.allocator,
	)
	assert(err == nil)

	stbtt.BakeFontBitmap(
		raw_data(font_data),
		0,
		FONT_SIZE_PX,
		raw_data(&font_bitmap),
		FONT_BITMAP_W,
		FONT_BITMAP_H,
		FIRST_PRINTABLE_ASCII,
		GLYPH_COUNT,
		raw_data(&baked_chars),
	)

	gl.GenTextures(1, &ui_texture)
	gl.BindTexture(gl.TEXTURE_2D, ui_texture)

	gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RED,
		FONT_BITMAP_W,
		FONT_BITMAP_H,
		0,
		gl.RED,
		gl.UNSIGNED_BYTE,
		raw_data(&font_bitmap),
	)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
}

draw_ui :: proc() {
	PADDING :: 10
	// Apparently need to multiply FONT_SIZE with a magic number 0.7 to get the correct glyph height
	GLYPH_HEIGHT_PX :: 0.7 * FONT_SIZE_PX

	draw_text(fmt.tprintf("Game time: %.2f", game_time), PADDING, PADDING + GLYPH_HEIGHT_PX)
	draw_text(fmt.tprintf("Frame rate: %d", frame_rate), PADDING, PADDING + GLYPH_HEIGHT_PX + 20)
	draw_text(
		fmt.tprintf("Bullet buffer size: %d", bul_check_next^),
		PADDING,
		PADDING + GLYPH_HEIGHT_PX + 40,
	)
	draw_text(
		fmt.tprintf("Camera.pos: %.1f, %.1f, %.1f", camera.pos.x, camera.pos.y, camera.pos.z),
		PADDING,
		PADDING + GLYPH_HEIGHT_PX + 60,
	)
	draw_text(fmt.tprintf("Camera.yaw: %.1f", camera.yaw), PADDING, PADDING + GLYPH_HEIGHT_PX + 80)
	draw_text(
		fmt.tprintf("Camera.pitch: %.1f", camera.pitch),
		PADDING,
		PADDING + GLYPH_HEIGHT_PX + 100,
	)

}

draw_text :: proc(text: string, x_param: f32, y_param: f32) {
	text_x := x_param
	text_y := y_param

	gl.UseProgram(ui_shader_program)

	window_width, window_height := glfw.GetWindowSize(window)
	gl.Uniform2f(ui_uloc_screen_size, f32(window_width), f32(window_height))

	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D, ui_texture)

	vertices := make([dynamic]f32)
	defer delete(vertices)

	for c in text {
		if c < FIRST_PRINTABLE_ASCII || c > LAST_PRINTABLE_ASCII {
			continue
		}

		q: stbtt.aligned_quad

		stbtt.GetBakedQuad(
			&baked_chars[0],
			FONT_BITMAP_W,
			FONT_BITMAP_H,
			i32(c - FIRST_PRINTABLE_ASCII),
			&text_x,
			&text_y,
			&q,
			true,
		)

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

	gl.BindVertexArray(ui_vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, ui_vbo)

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(f32),
		raw_data(vertices),
		gl.DYNAMIC_DRAW,
	)

	gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)

	gl.DrawArrays(gl.TRIANGLES, 0, i32(len(vertices) / 4))
}
