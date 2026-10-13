package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

HumanoidSize :: struct {
	whole:   Vec3,
	torso:   Vec3,
	bicep:   Vec3,
	forearm: Vec3,
	hand:    Vec3,
	thigh:   Vec3,
	calf:    Vec3,
	foot:    Vec3,
}

HumanoidPosition :: struct {
	whole:       Vec3,
	torso:       Vec3,
	thigh_right: Vec3,
	thigh_left:  Vec3,
	calf_right:  Vec3,
	calf_left:   Vec3,
	foot_right:  Vec3,
	foot_left:   Vec3,
}

humanoid_size: HumanoidSize = {
	whole = {0.8, 2, 0.3},
	torso = {0.5, 0.7, 0.3},
	thigh = {0.2, 0.5, 0.2},
	calf  = {0.15, 0.4, 0.15},
	foot  = {0.1, 0.05, 0.2},
}

humanoid_position: HumanoidPosition = {
	whole = {2, humanoid_size.whole.y / 2, 0},
}

BodyPart :: struct {
	position: Vec3,
	scale:    ^Vec3,
}

humanoid: [6]BodyPart

humanoid_init :: proc() {
	humanoid_position.torso = {0, humanoid_size.torso.y / 2, 0}
	humanoid_position.thigh_right = {
		-humanoid_size.torso.x / 2 + humanoid_size.thigh.x / 2,
		-humanoid_size.thigh.y / 2,
		0,
	}
	humanoid_position.thigh_left = {
		humanoid_size.torso.x / 2 - humanoid_size.thigh.x / 2,
		-humanoid_size.thigh.y / 2,
		0,
	}
	humanoid_position.calf_right = {
		-humanoid_size.torso.x / 2 + humanoid_size.thigh.x / 2,
		-humanoid_size.thigh.y - humanoid_size.calf.y / 2,
		0,
	}
	humanoid_position.calf_left = {
		humanoid_size.torso.x / 2 - humanoid_size.thigh.x / 2,
		-humanoid_size.thigh.y - humanoid_size.calf.y / 2,
		0,
	}
	humanoid_position.foot_right = {
		-humanoid_size.torso.x / 2 + humanoid_size.thigh.x / 2,
		-humanoid_size.thigh.y - humanoid_size.calf.y - humanoid_size.foot.y / 2,
		-humanoid_size.calf.z / 2 + humanoid_size.foot.z / 2,
		// humanoid_size.foot.z / 2 - humanoid_size.foot.x / 2,
	}

	// Torso
	humanoid[0] = {
		position = humanoid_position.torso,
		scale    = &humanoid_size.torso,
	}

	// Right thigh
	humanoid[1] = {
		position = humanoid_position.thigh_right,
		scale    = &humanoid_size.thigh,
	}

	// Left thigh
	humanoid[2] = {
		position = humanoid_position.thigh_left,
		scale    = &humanoid_size.thigh,
	}

	// Right calf
	humanoid[3] = {
		position = humanoid_position.calf_right,
		scale    = &humanoid_size.calf,
	}

	// Left calf
	humanoid[4] = {
		position = humanoid_position.calf_left,
		scale    = &humanoid_size.calf,
	}

	// Left foot
	humanoid[5] = {
		position = humanoid_position.foot_right,
		scale    = &humanoid_size.foot,
	}
}
