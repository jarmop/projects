package main

import "core:fmt"
import "core:math/linalg/glsl"
import b3 "vendor:box3d"

box_count :: 25
boxes: [box_count]b3.BodyId
world_id: b3.WorldId
time_step: f32 = 1. / 60
sub_step_count: i32 = 4

GROUND_SIZE: Vec3 : {100, 10, 100}
GROUND_RADIUS: Vec3 : {GROUND_SIZE.x / 2, GROUND_SIZE.y / 2, GROUND_SIZE.z / 2}
GROUND_CENTER_POSITION: Vec3 = {0, -GROUND_RADIUS.y, 0}

CUBE_SIZE: f32 : 1
CUBE_RADIUS :: CUBE_SIZE / 2

ground_id: b3.BodyId

physics_init :: proc() {
	world_def := b3.DefaultWorldDef()
	world_def.gravity = {0, -10, 0}
	world_id = b3.CreateWorld(world_def)

	// fmt.println(b3.World_GetContactRecycleDistance(world_id))
	// b3.World_SetContactRecycleDistance(world_id, 0.0)

	ground_body_def := b3.DefaultBodyDef()
	ground_body_def.position = {0, -GROUND_RADIUS.y, 0}
	ground_id = b3.CreateBody(world_id, ground_body_def)

	ground_box := b3.MakeBoxHull(GROUND_RADIUS.x, GROUND_RADIUS.y, GROUND_RADIUS.z)
	ground_shape_def := b3.DefaultShapeDef()
	_ = b3.CreateHullShape(ground_id, ground_shape_def, &ground_box.base)
	// b3.CreateHeightField

	for i in 0 ..< len(boxes) {
		body_def := b3.DefaultBodyDef()
		body_def.type = .dynamicBody
		// body_def.enableContactRecycling = false

		offset_x := f32((i % 2 == 0) ? .05 : -.05)
		body_def.position = {offset_x, 2. + f32(i) * (CUBE_SIZE + .5), 0}
		boxes[i] = b3.CreateBody(world_id, body_def)

		hull := b3.MakeCubeHull(CUBE_RADIUS)
		shape_def := b3.DefaultShapeDef()
		shape_def.density = 1
		shape_def.baseMaterial.friction = .3

		_ = b3.CreateHullShape(boxes[i], shape_def, &hull.base)
	}
}

physics_step :: proc() {
	b3.World_Step(world_id, time_step, sub_step_count)
}

physics_get_model :: proc(i: int) -> mat4 {
	box := boxes[i]

	model: mat4 = 1
	model *= glsl.mat4Translate(b3.Body_GetPosition(box))
	model *= mat4(b3.MakeMatrixFromQuat(b3.Body_GetRotation(box)))

	return model
}

physics_destroy :: proc() {
	b3.DestroyWorld(world_id)
}
