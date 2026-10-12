package main

import "base:runtime"
import "core:fmt"
import l "core:math/linalg"
import "core:os"
import gl "vendor:OpenGL"
import b3 "vendor:box3d"
import "vendor:glfw"

WINDOW_WIDTH: i32 = 800
WINDOW_HEIGHT: i32 = 600

mouse_sensitivity :: 0.08

Camera :: struct {
	pos:   Vec3,
	front: Vec3,
	right: Vec3,
	up:    Vec3,
	yaw:   f32,
	pitch: f32,
	speed: f32,
	fov:   f32,
	near:  f32,
	far:   f32,
}

camera := Camera {
	pos   = {24, 28, 24},
	// pos   = {80, 50, 80},
	front = {0, 0, -1},
	right = {1, 0, 0},
	up    = {0, 1, 0},
	yaw   = -135,
	pitch = -25,
	speed = 10,
	fov   = 45,
	near  = 0.1,
	far   = 1000,
}

prev_cursor_x: f32 = 800 / 2
prev_cursor_y: f32 = 600 / 2

delta_time: f32 = 0
last_frame: f32 = 0

window: glfw.WindowHandle

mouse_right_pressed := false
first_cursor_pos := true

window_init :: proc() {
	glfw.Init()
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.SAMPLES, 4)

	window = glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "LearnOpenGL", nil, nil)
	if window == nil {
		fmt.println("Failed to create GLFW window")
		glfw.Terminate()
		os.exit(-1)
	}
	glfw.MakeContextCurrent(window)

	gl.load_up_to(3, 3, glfw.gl_set_proc_address)

	gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
	glfw.SetCursorPosCallback(window, cursor_pos_callback)
	glfw.SetMouseButtonCallback(window, mouse_button_callback)
	glfw.SetScrollCallback(window, scroll_callback)
	glfw.SetKeyCallback(window, key_callback)

	update_camera()
}

window_draw :: proc() {
	glfw.SwapBuffers(window)
	glfw.PollEvents()

	current_frame := f32(glfw.GetTime())
	delta_time = current_frame - last_frame
	last_frame = current_frame

	handle_camera_movement_keys()

	if is_dragging {
		ray := get_ray()
		mouse_world_target, success := get_drag_plane_intersection(
			camera.pos,
			ray,
			initial_grab_point,
			camera.front,
		)

		update_dragging(mouse_world_target)
	}
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mode: i32) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
	gl.Viewport(0, 0, width, height)
	WINDOW_WIDTH = width
	WINDOW_HEIGHT = height
}

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, xf64: f64, yf64: f64) {
	context = runtime.default_context()

	if mouse_right_pressed {
		x := f32(xf64)
		y := f32(yf64)

		if first_cursor_pos {
			prev_cursor_x = x
			prev_cursor_y = y
			first_cursor_pos = false
		}

		camera.yaw += f32((x - prev_cursor_x) * mouse_sensitivity)
		if (camera.yaw > 180) {
			camera.yaw -= 360
		} else if (camera.yaw < -180) {
			camera.yaw += 360
		}
		camera.pitch -= f32((y - prev_cursor_y) * mouse_sensitivity)
		prev_cursor_x = x
		prev_cursor_y = y

		if camera.pitch > 89.0 {
			camera.pitch = 89.0
		} else if camera.pitch < -89.0 {
			camera.pitch = -89.0
		}

		update_camera()
	}
	// else if is_dragging {
	// 	ray := get_ray()
	// 	mouse_world_target, success := get_drag_plane_intersection(
	// 		camera.pos,
	// 		ray,
	// 		initial_grab_point,
	// 		camera.front,
	// 	)

	// 	fmt.println(mouse_world_target)
	// 	update_dragging(mouse_world_target)
	// }
}

get_ray :: proc() -> Vec3 {
	cursor_x, cursor_y := glfw.GetCursorPos(window)
	window_width, window_height := glfw.GetWindowSize(window)

	// Turn cursor coordinates into OpenGL normalized device coordinates
	// by changing their range from [0,1] to [-1,1]), and flipping y:
	x := f32(cursor_x / f64(window_width) * 2 - 1)
	y := -f32(cursor_y / f64(window_height) * 2 - 1)

	ray_clip := [4]f32{x, y, -1.0, 1.0}
	proj := l.matrix4_perspective_f32(
		l.to_radians(camera.fov),
		f32(window_width) / f32(window_height),
		camera.near,
		camera.far,
	)
	invp := l.inverse(proj) * ray_clip
	ray_eye := [4]f32{invp[0], invp[1], -1, 0}
	view := l.matrix4_look_at_f32(camera.pos, camera.pos + camera.front, camera.up)
	ray_world := l.normalize((l.inverse(view) * ray_eye).xyz)

	return ray_world
}

mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()

	if button == glfw.MOUSE_BUTTON_RIGHT {
		if action == glfw.PRESS {
			mouse_right_pressed = true
			glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
		} else {
			mouse_right_pressed = false
			first_cursor_pos = true
			glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_NORMAL)
		}
	} else if button == glfw.MOUSE_BUTTON_LEFT {
		if action == glfw.PRESS {
			// fmt.println("left click")
			// b3.Body_ApplyForceToCenter(boxes[0], {0, 1000, 0}, true)

			ray := get_ray() * 100
			filter := b3.DefaultQueryFilter()
			ray_result := b3.World_CastRayClosest(world_id, camera.pos, ray, filter)
			if !ray_result.hit {
				return
			}
			body_id := b3.Shape_GetBody(ray_result.shapeId)
			start_dragging(world_id, body_id, ray_result.point)

			// b3.Body_ApplyForce(body_id, ray, ray_result.point, true)
		} else {
			stop_dragging()
		}
	}
}

is_dragging: bool
dragged_body_id: b3.BodyId
mouse_joint_id: b3.JointId
initial_grab_point: Vec3
original_angular_damping: f32

// start_dragging2 :: proc(world_id: b3.WorldId, hit_body: b3.BodyId, hit_point: b3.Vec3) {
// 	is_dragging = true
// 	dragged_body_id = hit_body
// 	initial_grab_point = hit_point

// 	// Get the static body ID (or create a dummy static body if you don't have one)
// 	// For this example, assuming 'ground_body_id' is a persistent static body in your world

// 	// Initialize a Motor Joint definition
// 	def := b3.DefaultMotorJointDef()
// 	def.bodyIdA = ground_id
// 	def.bodyIdB = hit_body

// 	// Compute local target transforms so the initial pull anchor aligns exactly with hit_point
// 	def.localFrameA.p = b3.Body_GetLocalPoint(ground_id, hit_point)
// 	def.localFrameA.q = b3.Quat_identity

// 	def.localFrameB.p = b3.Body_GetLocalPoint(hit_body, hit_point)
// 	def.localFrameB.q = b3.Quat_identity

// 	// Tune responsiveness (Make it snappy but soft)
// 	def.maxVelocityForce = 2000.0 // Tweak based on your object mass properties
// 	def.maxVelocityTorque = 2000.0

// 	// Position Spring configuration (Crucial for dragging!)
// 	def.linearHertz = 100.0 // Frequency/Stiffness of the mouse pull
// 	def.linearDampingRatio = 0.1 // Smoothness to prevent radical oscillation
// 	def.maxSpringForce = 4000.0 // The maximum force allowed to snap it back to position

// 	def.constraintHertz = 5.0 // Softness frequency
// 	def.constraintDampingRatio = 0.7

// 	// (Optional) Angular Spring configuration
// 	// If you want the object's orientation to smoothly match the original click rotation:
// 	// def.angularHertz = 4.0
// 	// def.angularDampingRatio = 0.7
// 	// def.maxSpringTorque = 4000.0

// 	// Create the joint
// 	mouse_joint_id = b3.CreateMotorJoint(world_id, def)

// 	// Wake the body up so physics immediately takes over
// 	b3.Body_SetAwake(hit_body, true)
// }

start_dragging :: proc(world_id: b3.WorldId, hit_body: b3.BodyId, hit_point: b3.Vec3) {
	is_dragging = true
	dragged_body_id = hit_body
	initial_grab_point = hit_point

	def := b3.DefaultSphericalJointDef()
	// fmt.println(def.constraintHertz)
	// fmt.println(def.constraintDampingRatio)
	// fmt.println(def.maxMotorTorque)
	def.bodyIdA = ground_id
	def.bodyIdB = hit_body

	// Lock the attachment anchors precisely at the intersection point
	def.localFrameA.p = b3.Body_GetLocalPoint(ground_id, hit_point)
	def.localFrameA.q = b3.Quat_identity

	def.localFrameB.p = b3.Body_GetLocalPoint(hit_body, hit_point)
	def.localFrameB.q = b3.Quat_identity

	// def.constraintHertz = 5
	// def.constraintDampingRatio = 0
	def.constraintHertz = 10
	def.constraintDampingRatio = 0
	def.collideConnected = true
	// def.maxMotorTorque = 20000
	// def.enableMotor = true

	mouse_joint_id = b3.CreateSphericalJoint(world_id, def)

	original_angular_damping = b3.Body_GetAngularDamping(hit_body)
	b3.Body_SetAngularDamping(hit_body, 8)

	// Wake the body up so physics immediately takes over
	b3.Body_SetAwake(hit_body, true)
}

stop_dragging :: proc() {
	if !is_dragging do return

	b3.DestroyJoint(mouse_joint_id, true)
	b3.Body_SetAngularDamping(dragged_body_id, original_angular_damping)

	is_dragging = false
	mouse_joint_id = b3.nullJointId
	dragged_body_id = b3.nullBodyId
}

get_drag_plane_intersection :: proc(
	ray_origin, ray_direction: [3]f32,
	initial_grab_point: [3]f32,
	camera_forward: [3]f32,
) -> (
	mouse_world_target: [3]f32,
	success: bool,
) {
	// The normal of the drag plane faces the camera
	plane_normal := camera_forward

	// Calculate distance denominator
	denominator := l.vector_dot(plane_normal, ray_direction)

	// Prevent division by zero if the ray runs parallel to the dragging plane
	if abs(denominator) < 0.0001 do return {}, false

	// Compute distance 't' along the ray to the intersection point
	p0_minus_l0 := initial_grab_point - ray_origin
	t := l.vector_dot(p0_minus_l0, plane_normal) / denominator

	if t < 0.0 do return {}, false // Plane is behind the camera

	// The exact 3D position to pass to Box3D's Joint update step
	mouse_world_target = ray_origin + (ray_direction * t)
	return mouse_world_target, true
}

update_dragging :: proc(mouse_world_target: b3.Vec3) {
	if !is_dragging do return

	// 1. Calculate the new local position on Body A (the static ground) matching the mouse
	local_pos_A := b3.Body_GetLocalPoint(ground_id, mouse_world_target)

	// 2. Build the updated target transform frame for the anchor body
	new_frame_A := b3.Transform {
		p = local_pos_A,
		q = b3.Quat_identity,
	}

	// 3. Update the joint target frame directly using the generic joint frame function
	b3.Joint_SetLocalFrameA(mouse_joint_id, new_frame_A)

	// Explicitly wake the body so the physics solver processes the new constraint target
	b3.Body_SetAwake(dragged_body_id, true)
}

// update_dragging :: proc(mouse_world_target: b3.Vec3) {
// 	if !is_dragging do return

// 	// Transform the mouse world target point relative to the static ground body
// 	local_pos_A := b3.Body_GetLocalPoint(ground_id, mouse_world_target)

// 	// Feed the updated local position to the solver
// 	b3.MotorJoint_SetLinearOffset(mouse_joint_id, local_pos_A)
// 	b3.motorjoint_set
// }

scroll_callback := proc "c" (window: glfw.WindowHandle, xoffset: f64, yoffset: f64) {
	camera.fov -= f32(yoffset)
	if camera.fov < 1 {
		camera.fov = 1
	}
	if camera.fov > 45 {
		camera.fov = 45
	}
}

handle_camera_movement_keys :: proc() {
	// camera_d := camera.speed * (time_now - time_prev_frame)
	camera_d := delta_time * camera.speed

	// WASD
	if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {
		camera.pos += camera.front * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS {
		camera.pos -= camera.front * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {
		camera.pos -= camera.right * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS {
		camera.pos += camera.right * camera_d
	}

	// Elevation
	if glfw.GetKey(window, glfw.KEY_E) == glfw.PRESS {
		camera.pos += camera.up * camera_d
	}
	if glfw.GetKey(window, glfw.KEY_C) == glfw.PRESS {
		camera.pos -= camera.up * camera_d
	}
}

update_camera :: proc() {
	camera.front[0] = l.cos(l.to_radians(camera.yaw)) * l.cos(l.to_radians(camera.pitch))
	camera.front[1] = l.sin(l.to_radians(camera.pitch))
	camera.front[2] = l.sin(l.to_radians(camera.yaw)) * l.cos(l.to_radians(camera.pitch))
	camera.front = l.normalize(camera.front)
	camera.right = l.cross(camera.front, camera.up)
	camera.right = l.normalize(camera.right)
}
