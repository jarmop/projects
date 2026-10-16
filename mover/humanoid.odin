package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"

HumanoidSize :: struct {
	whole:   Vec3,
	torso:   Vec3,
	head:    Vec3,
	bicep:   Vec3,
	forearm: Vec3,
	hand:    Vec3,
	thigh:   Vec3,
	calf:    Vec3,
	foot:    Vec3,
}

HumanoidPosition :: struct {
	whole:               Vec3,
	torso:               Vec3,
	head:                Vec3,
	head_joint:          Vec3,
	bicep_right:         Vec3,
	bicep_right_joint:   Vec3,
	bicep_left:          Vec3,
	bicep_left_joint:    Vec3,
	forearm_right:       Vec3,
	forearm_right_joint: Vec3,
	forearm_left:        Vec3,
	forearm_left_joint:  Vec3,
	hand_right:          Vec3,
	hand_right_joint:    Vec3,
	hand_left:           Vec3,
	hand_left_joint:     Vec3,
	thigh_right:         Vec3,
	thigh_right_joint:   Vec3,
	thigh_left:          Vec3,
	thigh_left_joint:    Vec3,
	calf_right:          Vec3,
	calf_right_joint:    Vec3,
	calf_left:           Vec3,
	calf_left_joint:     Vec3,
	foot_right:          Vec3,
	foot_right_joint:    Vec3,
	foot_left:           Vec3,
	foot_left_joint:     Vec3,
}

humanoid_size: HumanoidSize = {
	whole   = {0.8, 2, 0.3},
	head    = {0.25, 0.3, 0.25},
	torso   = {0.5, 0.7, 0.3},
	bicep   = {0.15, 0.35, 0.15},
	forearm = {0.1, 0.35, 0.1},
	hand    = {0.15, 0.15, 0.15},
	thigh   = {0.2, 0.5, 0.2},
	calf    = {0.15, 0.4, 0.15},
	foot    = {0.15, 0.1, 0.3},
}

humanoid_position: HumanoidPosition = {
	whole = {2, humanoid_size.whole.y / 2, 0},
}

BodyPart :: struct {
	parent:         ^BodyPart,
	rotation_axis:  Vec3,
	rotation_angle: f32,
	position_joint: Vec3,
	position:       Vec3,
	size:           ^Vec3,
}

Humanoid :: struct {
	size:     Vec3,
	position: Vec3,
	parts:    [14]BodyPart,
	bbs:      [14]BoundingBox,
}

humanoid: ^Humanoid

selected_body_part := -1

// humanoid_front: Vec3 = {-1, 0, 0}

humanoid_init :: proc() {
	humanoid_position.torso = {0, humanoid_size.torso.y / 2, 0}

	humanoid_position.head_joint = {0, humanoid_size.torso.y / 2, 0}
	humanoid_position.head = {0, humanoid_size.head.y / 2, 0}

	// --------------------
	// Right arm
	// --------------------

	humanoid_position.bicep_right_joint = {
		-humanoid_size.torso.x / 2 - humanoid_size.bicep.x / 2,
		humanoid_size.torso.y / 2 - humanoid_size.bicep.x / 2,
		0,
	}
	humanoid_position.bicep_right = {0, -humanoid_size.bicep.y / 2, 0}

	humanoid_position.forearm_right_joint = {0, -humanoid_size.bicep.y / 2, 0}
	humanoid_position.forearm_right = {0, -humanoid_size.forearm.y / 2, 0}

	humanoid_position.hand_right_joint = {0, -humanoid_size.forearm.y / 2, 0}
	humanoid_position.hand_right = {0, -humanoid_size.hand.y / 2, 0}

	// --------------------
	// Left arm
	// --------------------

	humanoid_position.bicep_left_joint = {
		humanoid_size.torso.x / 2 + humanoid_size.bicep.x / 2,
		humanoid_size.torso.y / 2 - humanoid_size.bicep.x / 2,
		0,
	}
	humanoid_position.bicep_left = {0, -humanoid_size.bicep.y / 2, 0}

	humanoid_position.forearm_left_joint = {0, -humanoid_size.bicep.y / 2, 0}
	humanoid_position.forearm_left = {0, -humanoid_size.forearm.y / 2, 0}

	humanoid_position.hand_left_joint = {0, -humanoid_size.forearm.y / 2, 0}
	humanoid_position.hand_left = {0, -humanoid_size.hand.y / 2, 0}

	// --------------------
	// Right leg
	// --------------------

	humanoid_position.thigh_right_joint = {
		-humanoid_size.torso.x / 2 + humanoid_size.thigh.x / 2,
		-humanoid_size.torso.y / 2,
		0,
	}
	humanoid_position.thigh_right = {0, -humanoid_size.thigh.y / 2, 0}

	humanoid_position.calf_right_joint = {0, -humanoid_size.thigh.y / 2, 0}
	humanoid_position.calf_right = {0, -humanoid_size.calf.y / 2, 0}

	humanoid_position.foot_right_joint = {0, -humanoid_size.calf.y / 2, 0}
	humanoid_position.foot_right = {
		0,
		-humanoid_size.foot.y / 2,
		humanoid_size.foot.z / 2 - humanoid_size.calf.z / 2,
	}

	// --------------------
	// Left leg
	// --------------------

	humanoid_position.thigh_left_joint = {
		humanoid_size.torso.x / 2 - humanoid_size.thigh.x / 2,
		-humanoid_size.torso.y / 2,
		0,
	}
	humanoid_position.thigh_left = {0, -humanoid_size.thigh.y / 2, 0}

	humanoid_position.calf_left_joint = {0, -humanoid_size.thigh.y / 2, 0}
	humanoid_position.calf_left = {0, -humanoid_size.calf.y / 2, 0}

	humanoid_position.foot_left_joint = {0, -humanoid_size.calf.y / 2, 0}
	humanoid_position.foot_left = {
		0,
		-humanoid_size.foot.y / 2,
		humanoid_size.foot.z / 2 - humanoid_size.calf.z / 2,
	}
}

make_pose :: proc(humanoid: ^Humanoid, angles: HumanoidJointAngles) {
	humanoid.size = humanoid_size.whole
	humanoid.position = humanoid_position.whole

	// Torso
	humanoid.parts[0] = {
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.torso),
		position       = humanoid_position.torso,
		size           = &humanoid_size.torso,
	}

	// Head
	humanoid.parts[13] = {
		parent         = &humanoid.parts[0],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.head),
		position_joint = humanoid_position.head_joint,
		position       = humanoid_position.head,
		size           = &humanoid_size.head,
	}

	// --------------------
	// Right arm
	// --------------------

	// Right bicep
	humanoid.parts[7] = {
		parent         = &humanoid.parts[0],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.right_upper_arm),
		position_joint = humanoid_position.bicep_right_joint,
		position       = humanoid_position.bicep_right,
		size           = &humanoid_size.bicep,
	}

	// Right forearm
	humanoid.parts[8] = {
		parent         = &humanoid.parts[7],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.right_forearm),
		position_joint = humanoid_position.forearm_right_joint,
		position       = humanoid_position.forearm_right,
		size           = &humanoid_size.forearm,
	}

	// Right hand
	humanoid.parts[9] = {
		parent         = &humanoid.parts[8],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.right_hand),
		position_joint = humanoid_position.hand_right_joint,
		position       = humanoid_position.hand_right,
		size           = &humanoid_size.hand,
	}

	// --------------------
	// Left arm
	// --------------------

	// Left bicep
	humanoid.parts[10] = {
		parent         = &humanoid.parts[0],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.left_upper_arm),
		position_joint = humanoid_position.bicep_left_joint,
		position       = humanoid_position.bicep_left,
		size           = &humanoid_size.bicep,
	}

	// Left forearm
	humanoid.parts[11] = {
		parent         = &humanoid.parts[10],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.left_forearm),
		position_joint = humanoid_position.forearm_left_joint,
		position       = humanoid_position.forearm_left,
		size           = &humanoid_size.forearm,
	}

	// Left hand
	humanoid.parts[12] = {
		parent         = &humanoid.parts[11],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.left_hand),
		position_joint = humanoid_position.hand_left_joint,
		position       = humanoid_position.hand_left,
		size           = &humanoid_size.hand,
	}

	// --------------------
	// Right leg
	// --------------------

	// Right thigh
	humanoid.parts[1] = {
		parent         = &humanoid.parts[0],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.right_thigh),
		position_joint = humanoid_position.thigh_right_joint,
		position       = humanoid_position.thigh_right,
		size           = &humanoid_size.thigh,
	}

	// Right calf
	humanoid.parts[2] = {
		parent         = &humanoid.parts[1],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.right_shin),
		position_joint = humanoid_position.calf_right_joint,
		position       = humanoid_position.calf_right,
		size           = &humanoid_size.calf,
	}

	// Right foot
	humanoid.parts[3] = {
		parent         = &humanoid.parts[2],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.right_foot),
		position_joint = humanoid_position.foot_right_joint,
		position       = humanoid_position.foot_right,
		size           = &humanoid_size.foot,
	}

	// --------------------
	// Left leg
	// --------------------

	// Left thigh
	humanoid.parts[4] = {
		parent         = &humanoid.parts[0],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.left_thigh),
		position_joint = humanoid_position.thigh_left_joint,
		position       = humanoid_position.thigh_left,
		size           = &humanoid_size.thigh,
	}

	// Left calf
	humanoid.parts[5] = {
		parent         = &humanoid.parts[4],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.left_shin),
		position_joint = humanoid_position.calf_left_joint,
		position       = humanoid_position.calf_left,
		size           = &humanoid_size.calf,
	}

	// Left foot
	humanoid.parts[6] = {
		parent         = &humanoid.parts[5],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(angles.left_foot),
		position_joint = humanoid_position.foot_left_joint,
		position       = humanoid_position.foot_left,
		size           = &humanoid_size.foot,
	}

	for &bp, i in humanoid.parts {
		humanoid.bbs[i] = get_bb(humanoid, &bp)
	}

	// init_bb_vertices(humanoid.bbs[0])
}

get_bp_model :: proc(bp: ^BodyPart) -> mat4 {
	model: mat4 = 1
	model *= glsl.mat4Translate(humanoid.position)
	model *= translate_and_rotate_recursive(bp)
	model *= glsl.mat4Scale(bp.size^)

	return model
}

get_bb :: proc(humanoid: ^Humanoid, bp: ^BodyPart) -> BoundingBox {
	model: mat4 = 1
	model *= glsl.mat4Translate(humanoid.position)
	model *= translate_and_rotate_recursive(bp)
	model *= glsl.mat4Scale(bp.size^)

	s: Vec3 = 1
	c: Vec3 = {0, 0, 0} - s / 2
	bottom_corners: [4]Vec3 = {
		c, // back left
		c + {s.x, 0, 0}, // back right
		c + {s.x, 0, s.z}, // front right
		c + {0, 0, s.z}, // front left
	}

	c = c + {0, s.y, 0}
	top_corners: [4]Vec3 = {
		c, // back left
		c + {s.x, 0, 0}, // back right
		c + {s.x, 0, s.z}, // front right
		c + {0, 0, s.z}, // front left
	}

	foo: [8]Vec3
	mi: Vec3 = math.F32_MAX
	ma: Vec3 = math.F32_MIN
	for c, i in bottom_corners {
		foo[i] = (model * Vec4{c.x, c.y, c.z, 1}).xyz
	}

	for c, i in top_corners {
		foo[4 + i] = (model * Vec4{c.x, c.y, c.z, 1}).xyz
	}

	for c, i in foo {
		mi.x = min(mi.x, c.x)
		mi.y = min(mi.y, c.y)
		mi.z = min(mi.z, c.z)

		ma.x = max(ma.x, c.x)
		ma.y = max(ma.y, c.y)
		ma.z = max(ma.z, c.z)
	}

	return {min = mi, max = ma}
}
