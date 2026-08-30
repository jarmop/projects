package survival

import "core:fmt"
import "core:math"
import l "core:math/linalg"
import "core:math/linalg/glsl"

raycast :: proc(
	cursor_x, cursor_y: f32,
	window_width, window_height: int,
	projection, view, model: Mat4,
	radius: f32,
	segments, rings: int,
) -> (
	is_hit: bool,
	uv: Vec2,
	ring: int,
	segment: int,
	position: Vec3,
) {
	// Turn cursor coordinates into OpenGL normalized device coordinates
	// by changing their range from [0,1] to [-1,1]), and flipping y:
	// cursor_x, cursor_y := glfw.GetCursorPos(window)
	// window_width, window_height := glfw.GetWindowSize(window)
	ndc_x := cursor_x / f32(window_width) * 2 - 1
	ndc_y := -(cursor_y / f32(window_height) * 2 - 1)

	// view := get_view()
	// projection := get_projection()
	inv_view_projection := l.inverse(projection * view)

	near_clip := glsl.vec4{ndc_x, ndc_y, -1.0, 1.0}
	far_clip := glsl.vec4{ndc_x, ndc_y, 1.0, 1.0}

	near_world := inv_view_projection * near_clip
	far_world := inv_view_projection * far_clip

	near_world.xyz /= near_world.w
	far_world.xyz /= far_world.w

	ray_origin_world := near_world.xyz
	ray_direction_world := l.normalize(far_world.xyz - near_world.xyz)

	// inverse_model := l.inverse(get_model())
	inverse_model := l.inverse(model)
	origin4 :=
		inverse_model * [4]f32{ray_origin_world.x, ray_origin_world.y, ray_origin_world.z, 1.0}
	direction4 :=
		inverse_model *
		[4]f32{ray_direction_world.x, ray_direction_world.y, ray_direction_world.z, 0.0}

	ray_origin := origin4.xyz
	ray_direction := l.normalize(direction4.xyz)

	a := l.dot(ray_direction, ray_direction)
	b := 2.0 * l.dot(ray_origin, ray_direction)
	c := l.dot(ray_origin, ray_origin) - globe_radius * globe_radius
	discriminant := b * b - 4.0 * a * c

	if discriminant < 0 {
		return false, {}, 0, 0, {}
	}

	sqrt_d := math.sqrt(discriminant)
	t0 := (-b - sqrt_d) / (2.0 * a)
	t1 := (-b + sqrt_d) / (2.0 * a)
	t := min(t0, t1)
	hit := ray_origin + ray_direction * t

	return true, {}, 0, 0, hit
}

pick_globe :: proc(
	mouse_x, mouse_y: f32,
	screen_width, screen_height: int,
	projection, view, model: Mat4,
	radius: f32,
	segments, rings: int,
) -> (
	hit: bool,
	uv: Vec2,
	ring: int,
	segment: int,
	position: Vec3,
) {
	// 1. Screen → NDC
	ndc_x := 2.0 * mouse_x / f32(screen_width) - 1.0
	ndc_y := 1.0 - 2.0 * mouse_y / f32(screen_height)

	// 2. NDC → world ray
	inverse_vp := l.inverse(projection * view)

	near_clip := Vec4{ndc_x, ndc_y, -1.0, 1.0}
	far_clip := Vec4{ndc_x, ndc_y, 1.0, 1.0}

	near_world := inverse_vp * near_clip
	far_world := inverse_vp * far_clip

	near_world.xyz /= near_world.w
	far_world.xyz /= far_world.w

	ray_origin_world := near_world.xyz
	ray_direction_world := l.normalize(far_world.xyz - near_world.xyz)

	// 3. World ray → globe-local ray
	inverse_model := l.inverse(model)

	origin4 :=
		inverse_model * Vec4{ray_origin_world.x, ray_origin_world.y, ray_origin_world.z, 1.0}

	direction4 :=
		inverse_model *
		Vec4{ray_direction_world.x, ray_direction_world.y, ray_direction_world.z, 0.0}

	ray_origin := origin4.xyz
	ray_direction := l.normalize(direction4.xyz)

	// 4. Ray-sphere intersection
	a := l.dot(ray_direction, ray_direction)
	b := 2.0 * l.dot(ray_origin, ray_direction)
	c := l.dot(ray_origin, ray_origin) - radius * radius

	discriminant := b * b - 4.0 * a * c

	if discriminant < 0 {
		return false, {}, 0, 0, {}
	}

	sqrt_d := math.sqrt(discriminant)

	t0 := (-b - sqrt_d) / (2.0 * a)
	t1 := (-b + sqrt_d) / (2.0 * a)

	t := t0

	if t < 0 {
		t = t1
	}

	if t < 0 {
		return false, {}, 0, 0, {}
	}

	hit_position := ray_origin + ray_direction * t

	// 5. Local position → UV
	phi := math.atan2(f64(hit_position.z), f64(-hit_position.x))

	if phi < 0 {
		phi += 2.0 * math.PI
	}

	u := f32(phi / (2.0 * math.PI))
	v := f32(math.acos(f64(-hit_position.y / radius)) / math.PI)

	// 6. UV → grid cell
	segment = min(int(u * f32(segments)), segments - 1)

	ring = min(int(v * f32(rings)), rings - 1)

	return true, Vec2{u, v}, ring, segment, hit_position
}
