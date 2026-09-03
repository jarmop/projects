package survival

import "base:runtime"
import "core:fmt"
import "vendor:glfw"

DashboardArea :: struct {
	start: [2]f32,
	end:   [2]f32,
}

year_button_area: DashboardArea

Dashboard :: struct {
	year:       Table,
	population: Table,
}

dashboard: Dashboard

dashboard_init :: proc() {

	text_init()
	table_init()

	dashboard_init_year()
	table_add_vertices(dashboard.year)

	dashboard_init_population()
	table_add_vertices(dashboard.population)

	table_set_buffer_data()
}

dashboard_init_year :: proc() {
	padding: [2]f32 = {4, 4}
	col_widths: []f32 = {60, 20}
	table_width: f32 = col_widths[0] + col_widths[1]
	// table_height := font_size + 2 * padding.y
	// start := [2]f32{f32(WINDOW_WIDTH) - table_width, f32(WINDOW_HEIGHT) - table_height}
	start := [2]f32{f32(WINDOW_WIDTH) - table_width, 0}

	dashboard.year = {
		start   = start,
		padding = padding,
	}

	table_make(
		table = &dashboard.year,
		data = {{fmt.tprintf("%d", game.year), "+"}},
		col_widths = col_widths,
	)

	table_height := table_add_vertices(dashboard.year)


	// For detecting mouse clicks
	year_button_area.start = start + {col_widths[0], 0}
	// table_height := font_size + 2 * padding.y
	year_button_area.end = year_button_area.start + {col_widths[1], table_height}
	// year_button_area.end = year_button_area.start + {col_widths[1], 0}
}

dashboard_init_population :: proc() {
	dashboard.population = {
		start   = {0, 0},
		padding = {4, 4},
	}
	settlement := settlement

	table_make(
		table = &dashboard.population,
		data = {
			{"Population:", fmt.tprintf("%d", settlement.population)},
			{"Food demand:", fmt.tprintf("%d", settlement.food_demand)},
			{"Food production:", fmt.tprintf("%d", settlement.food_production)},
		},
		col_widths = {140, 40},
	)
}

dashboard_update :: proc() {
	table_clear_vertices()

	clear(&dashboard.year.col_widths)
	clear(&dashboard.year.data)
	dashboard_init_year()

	clear(&dashboard.population.col_widths)
	clear(&dashboard.population.data)
	dashboard_init_population()

	table_add_vertices(dashboard.population)
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
			game_increment_year()
			dashboard_update()
		}
	}
}

within :: proc(a: DashboardArea, x, y: f32) -> bool {
	return x > a.start.x && x < a.end.x && y > a.start.y && y < a.end.y
}
