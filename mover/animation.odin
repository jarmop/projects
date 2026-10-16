package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

Animation :: struct {
	poses:         [4]Humanoid,
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
	animation.time_per_pose = 1

	humanoid_init()

	angles := load()

	// fmt.println(angles)

	// angles: HumanoidJointAngles
	// angles2: HumanoidJointAngles = {
	// 	torso           = 20,
	// 	head            = 10,
	// 	right_upper_arm = 80,
	// 	right_forearm   = -80,
	// 	right_hand      = -45,
	// 	left_upper_arm  = -30,
	// 	left_forearm    = -100,
	// 	left_hand       = -45,
	// 	right_thigh     = -80,
	// 	right_shin      = 120,
	// 	right_foot      = 10,
	// 	left_thigh      = 0,
	// 	left_shin       = 10,
	// 	left_foot       = -10,
	// }

	make_pose(&animation.poses[0], angles[0])
	make_pose(&animation.poses[1], angles[1])
	make_pose(&animation.poses[2], mirror_humanoid(angles[0]))
	make_pose(&animation.poses[3], mirror_humanoid(angles[1]))

	// save({angles, angles2})

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

	base_model := glsl.mat4Translate(humanoid.position)
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
