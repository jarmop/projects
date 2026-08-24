package survival

import "base:runtime"
import "core:fmt"
import "vendor:glfw"

Area :: struct {
	start: [2]f32,
	end:   [2]f32,
}

year_button_area: Area

year := 0

Dashboard :: struct {
	year: Table,
}

dashboard: Dashboard

dashboard_init :: proc() {

	text_init()
	table_init()

	padding: [2]f32 = {4, 6}
	col_widths: []f32 = {60, 20}
	table_width: f32 = col_widths[0] + col_widths[1]
	table_height := font_size + 2 * padding.y
	table_pos := [2]f32{f32(WINDOW_WIDTH) - table_width, f32(WINDOW_HEIGHT) - table_height}
	year_button_area.start = table_pos + {col_widths[0], 0}
	year_button_area.end = year_button_area.start + {col_widths[1], table_height}

	dashboard.year = {
		start   = table_pos,
		padding = padding,
	}

	data: [][]string = {{fmt.tprintf("%d", year), "+"}}

	for row in data {
		data_row: [dynamic]string
		append(&data_row, ..row[:])
		append(&dashboard.year.data, data_row)
	}

	append(&dashboard.year.col_widths, ..col_widths[:])

	table_add_vertices(dashboard.year)

	table_set_buffer_data()
}

dashboard_update :: proc() {
	table_clear_vertices()
	table_add_vertices(dashboard.year)
	table_set_buffer_data()
}

dashboard_draw :: proc() {
	draw_table()
}

dashboard_mouse_button_callback :: proc(window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()

	if button == glfw.MOUSE_BUTTON_LEFT && action == glfw.PRESS {
		x64, y64 := glfw.GetCursorPos(window)
		x, y := f32(x64), f32(y64)

		if within(year_button_area, x, y) {
			year += 1
			dashboard.year.data[0][0] = fmt.tprintf("%d", year)
			dashboard_update()
		}
	}
}

within :: proc(a: Area, x, y: f32) -> bool {
	return x > a.start.x && x < a.end.x && y > a.start.y && y < a.end.y
}
