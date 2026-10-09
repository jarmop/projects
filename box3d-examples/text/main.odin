package main

import "core:fmt"
import b3 "vendor:box3d"

NUM_BOXES :: 2

main :: proc() {
	world_def := b3.DefaultWorldDef()
	world_def.gravity = {0, -10, 0}
	world_id := b3.CreateWorld(world_def)

	ground_body_def := b3.DefaultBodyDef()
	ground_body_def.position = {0, -10, 0}
	ground_id := b3.CreateBody(world_id, ground_body_def)

	ground_box := b3.MakeBoxHull(50, 10, 50)
	ground_shape_def := b3.DefaultShapeDef()
	_ = b3.CreateHullShape(ground_id, ground_shape_def, &ground_box.base)

	boxes: [NUM_BOXES]b3.BodyId
	for i in 0 ..< len(boxes) {
		body_def := b3.DefaultBodyDef()
		body_def.type = .dynamicBody

		offset_x := f32((i % 2 == 0) ? .05 : -.05)
		body_def.position = {offset_x, 2. + f32(i) * 2.5, 0}
		boxes[i] = b3.CreateBody(world_id, body_def)

		dynamic_box := b3.MakeCubeHull(1)
		shape_def := b3.DefaultShapeDef()
		shape_def.density = 1
		shape_def.baseMaterial.friction = .3

		_ = b3.CreateHullShape(boxes[i], shape_def, &dynamic_box.base)
	}

	time_step: f32 = 1. / 60.
	sub_step_count: i32 = 4

	for box, i in boxes {
		fmt.printfln("box %d center: %g", i, b3.Body_GetPosition(box))
	}

	for i in 0 ..< 4 * 60 {
		b3.World_Step(world_id, time_step, sub_step_count)
	}

	for box, i in boxes {
		fmt.printfln("box %d center: %g", i, b3.Body_GetPosition(box))
	}

	b3.DestroyWorld(world_id)
}
