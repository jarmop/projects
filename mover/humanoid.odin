package main

import "core:fmt"
import "core:math"
import "core:math/linalg"

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
	scale:          ^Vec3,
}

Humanoid :: struct {
	size:     Vec3,
	position: Vec3,
	parts:    [14]BodyPart,
}

humanoid: Humanoid = {
	size     = humanoid_size.whole,
	position = humanoid_position.whole,
}

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

	// Torso
	humanoid.parts[0] = {
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(20)),
		// rotation_angle = 0,
		position       = humanoid_position.torso,
		scale          = &humanoid_size.torso,
	}

	// Head
	humanoid.parts[13] = {
		parent         = &humanoid.parts[0],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(10)),
		position_joint = humanoid_position.head_joint,
		position       = humanoid_position.head,
		scale          = &humanoid_size.head,
	}

	// --------------------
	// Right arm
	// --------------------

	// Right bicep
	humanoid.parts[7] = {
		parent         = &humanoid.parts[0],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(80)),
		position_joint = humanoid_position.bicep_right_joint,
		position       = humanoid_position.bicep_right,
		scale          = &humanoid_size.bicep,
	}

	// Right forearm
	humanoid.parts[8] = {
		parent         = &humanoid.parts[7],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(-80)),
		position_joint = humanoid_position.forearm_right_joint,
		position       = humanoid_position.forearm_right,
		scale          = &humanoid_size.forearm,
	}

	// Right hand
	humanoid.parts[9] = {
		parent         = &humanoid.parts[8],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(-45)),
		position_joint = humanoid_position.hand_right_joint,
		position       = humanoid_position.hand_right,
		scale          = &humanoid_size.hand,
	}

	// --------------------
	// Left arm
	// --------------------

	// Left bicep
	humanoid.parts[10] = {
		parent         = &humanoid.parts[0],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(-30)),
		position_joint = humanoid_position.bicep_left_joint,
		position       = humanoid_position.bicep_left,
		scale          = &humanoid_size.bicep,
	}

	// Left forearm
	humanoid.parts[11] = {
		parent         = &humanoid.parts[10],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(-100)),
		position_joint = humanoid_position.forearm_left_joint,
		position       = humanoid_position.forearm_left,
		scale          = &humanoid_size.forearm,
	}

	// Left hand
	humanoid.parts[12] = {
		parent         = &humanoid.parts[11],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(-45)),
		position_joint = humanoid_position.hand_left_joint,
		position       = humanoid_position.hand_left,
		scale          = &humanoid_size.hand,
	}

	// --------------------
	// Right leg
	// --------------------

	// Right thigh
	humanoid.parts[1] = {
		parent         = &humanoid.parts[0],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(-80)),
		position_joint = humanoid_position.thigh_right_joint,
		position       = humanoid_position.thigh_right,
		scale          = &humanoid_size.thigh,
	}

	// Right calf
	humanoid.parts[2] = {
		parent         = &humanoid.parts[1],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(120)),
		position_joint = humanoid_position.calf_right_joint,
		position       = humanoid_position.calf_right,
		scale          = &humanoid_size.calf,
	}

	// Right foot
	humanoid.parts[3] = {
		parent         = &humanoid.parts[2],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(10)),
		position_joint = humanoid_position.foot_right_joint,
		position       = humanoid_position.foot_right,
		scale          = &humanoid_size.foot,
	}

	// --------------------
	// Left leg
	// --------------------

	// Left thigh
	humanoid.parts[4] = {
		parent         = &humanoid.parts[0],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(0)),
		position_joint = humanoid_position.thigh_left_joint,
		position       = humanoid_position.thigh_left,
		scale          = &humanoid_size.thigh,
	}

	// Left calf
	humanoid.parts[5] = {
		parent         = &humanoid.parts[4],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(10)),
		position_joint = humanoid_position.calf_left_joint,
		position       = humanoid_position.calf_left,
		scale          = &humanoid_size.calf,
	}

	// Left foot
	humanoid.parts[6] = {
		parent         = &humanoid.parts[5],
		rotation_axis  = {1, 0, 0},
		rotation_angle = linalg.to_radians(f32(-10)),
		position_joint = humanoid_position.foot_left_joint,
		position       = humanoid_position.foot_left,
		scale          = &humanoid_size.foot,
	}
}
