package main

import "core:fmt"
import "core:math/linalg"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

Animation :: struct {
	poses:         [8]Humanoid,
	time_per_pose: f32,
}

HumanoidJointAngles :: struct {
	torso:           f32,
	head:            f32,
	right_upper_arm: f32,
	right_forearm:   f32,
	right_hand:      f32,
	left_upper_arm:  f32,
	left_forearm:    f32,
	left_hand:       f32,
	right_thigh:     f32,
	right_shin:      f32,
	right_foot:      f32,
	left_thigh:      f32,
	left_shin:       f32,
	left_foot:       f32,
}

animation: Animation

current_pose := 0

playing := false

animation_init :: proc() {
	animation.time_per_pose = 0.1

	humanoid_init()

	angles := load()

	make_pose(&animation.poses[0], angles[0])
	// make_pose(&animation.poses[1], angles[1])
	// // make_pose(&animation.poses[1], angles[0])
	// make_pose(&animation.poses[2], angles[2])
	// // make_pose(&animation.poses[2], angles[1])
	// make_pose(&animation.poses[3], angles[3])
	// // make_pose(&animation.poses[3], angles[2])
	// make_pose(&animation.poses[4], mirror_humanoid(angles[0]))
	// make_pose(&animation.poses[5], mirror_humanoid(angles[1]))
	// make_pose(&animation.poses[6], mirror_humanoid(angles[2]))
	// make_pose(&animation.poses[7], mirror_humanoid(angles[3]))


	humanoid = &animation.poses[current_pose]
}

mirror_humanoid :: proc(angles: HumanoidJointAngles) -> HumanoidJointAngles {
	return {
		torso = angles.torso,
		head = angles.head,
		right_upper_arm = angles.left_upper_arm,
		right_forearm = angles.left_forearm,
		right_hand = angles.left_hand,
		left_upper_arm = angles.right_upper_arm,
		left_forearm = angles.right_forearm,
		left_hand = angles.right_hand,
		right_thigh = angles.left_thigh,
		right_shin = angles.left_shin,
		right_foot = angles.left_foot,
		left_thigh = angles.right_thigh,
		left_shin = angles.right_shin,
		left_foot = angles.right_foot,
	}
}

animation_draw :: proc() {
	// ------------------------------
	// Humanoid
	// ------------------------------

	shader_set_vec4(shader_program_grid, "bg_color", {0, .4, .8, 1})
	shader_set_vec4(shader_program_grid, "grid_color", {0, .3, .6, 1})

	// Take humanoid.front into account here some how
	base_model := glsl.mat4Translate(humanoid.position)
	// Get angle from the humanoid front
	// base_model *= glsl.mat4Rotate({0, 1, 0}, linalg.to_radians(f32(45)))
	// base_model *= glsl.mat4Rotate({0, 1, 0}, linalg.to_radians(90 - humanoid.yaw))
	// base_model *= glsl.mat4Rotate({0, 1, 0}, linalg.to_radians(humanoid.yaw))
	for &bp, i in humanoid.parts {
		shader_set_vec4(
			shader_program_grid,
			"bg_color",
			i == selected_body_part ? {.7, .8, .4, 1} : {0, .4, .8, 1},
		)

		model := base_model
		model *= translate_and_rotate_recursive(&bp)
		model *= glsl.mat4Scale(bp.size^)
		shader_set_mat4(shader_program_grid, "model", model)

		gl.BindVertexArray(box_vao)
		gl.DrawArrays(gl.TRIANGLES, 0, len(box_vertices))
	}

	if playing {
		swap_pose()
	}

	// // draw bb
	// shader_set_vec4(shader_program_grid, "bg_color", {0, 1, 0, 1})
	// model = 1
	// shader_set_mat4(shader_program_grid, "model", model)
	// gl.BindVertexArray(bb_vao)
	// gl.DrawArrays(gl.TRIANGLES, 0, len(bb_vertices))
}

translate_and_rotate_recursive :: proc(bp: ^BodyPart) -> glsl.mat4 {
	if bp == nil {
		return 1
	}
	model := translate_and_rotate_recursive(bp.parent)
	model *= glsl.mat4Translate(bp.position_joint)
	model *= glsl.mat4Rotate(bp.rotation_axis, bp.rotation_angle)
	model *= glsl.mat4Translate(bp.position)
	return model
}

swap_timer: f32 = 0

swap_pose :: proc() {
	if swap_timer < animation.time_per_pose {
		swap_timer += time_delta
		return
	}
	swap_timer = 0
	current_pose = current_pose < len(animation.poses) - 1 ? current_pose + 1 : 0
	humanoid = &animation.poses[current_pose]
}
