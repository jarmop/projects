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

Table :: struct {
	start:       [2]f32,
	row_heights: [dynamic]f32,
	col_widths:  [dynamic]f32,
	padding:     [2]f32,
	font_size:   f32,
	data:        [dynamic][dynamic]string,
	row_count:   int,
	col_count:   int,
}

Dashboard :: struct {
	table: Table,
}

dashboard: Dashboard

init_dashboard :: proc() {
	padding: [2]f32 = {4, 6}
	font_size: f32 = 10
	row_heights: []f32 = {font_size + 2 * padding.y}
	col_widths: []f32 = {60, 20}
	table_width: f32 = col_widths[0] + col_widths[1]
	table_height := row_heights[0]
	table_pos := [2]f32{f32(WINDOW_WIDTH) - table_width, f32(WINDOW_HEIGHT) - table_height}
	year_button_area.start = table_pos + {col_widths[0], 0}
	year_button_area.end = year_button_area.start + {col_widths[1], row_heights[0]}

	dashboard.table = {
		start     = table_pos,
		row_count = 1,
		col_count = 2,
		padding   = padding,
		font_size = font_size,
	}

	data: [][]string = {{fmt.tprintf("%d", year), "+"}}
	for row in data {
		data_row: [dynamic]string
		append(&data_row, ..row[:])
		append(&dashboard.table.data, data_row)
	}

	append(&dashboard.table.row_heights, ..row_heights[:])
	append(&dashboard.table.col_widths, ..col_widths[:])

	init_text(font_size)

	init_text(font_size)
	init_table()
}

update_dashboard :: proc() {
	update_table()
}

draw_dashboard :: proc() {
	draw_table()
}

dashboard_mouse_button_callback :: proc(window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()

	if button == glfw.MOUSE_BUTTON_LEFT && action == glfw.PRESS {
		x64, y64 := glfw.GetCursorPos(window)
		x, y := f32(x64), f32(y64)

		if within(year_button_area, x, y) {
			year += 1
			dashboard.table.data[0][0] = fmt.tprintf("%d", year)
			update_dashboard()
		}
	}
}

within :: proc(a: Area, x, y: f32) -> bool {
	return x > a.start.x && x < a.end.x && y > a.start.y && y < a.end.y
}
