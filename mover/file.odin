package main

import "core:encoding/json"
import "core:fmt"
import "core:os"

// filename := "data/animation.json"
filename := "data/walking.json"
// filename := "data/running.json"

save :: proc(angles: []HumanoidJointAngles) {
	data, json_err := json.marshal(angles)
	defer delete(data)
	if (json_err != nil) {
		fmt.println(json_err)
	}

	write_err := os.write_entire_file(filename, data)
	if (write_err != nil) {
		fmt.println("Save failed:", write_err)
	} else {
		fmt.printfln("saved %d postures (%d bytes)", len(angles), len(data))
	}
}

load :: proc() -> []HumanoidJointAngles {
	data, read_err := os.read_entire_file(filename, context.allocator)
	defer delete(data)
	if (read_err != nil) {
		fmt.println("Load failed", read_err)
		return make([]HumanoidJointAngles, 8)
	}

	angles: []HumanoidJointAngles
	json_err := json.unmarshal(data, &angles)
	if (json_err != nil) {
		fmt.println(json_err)
		return make([]HumanoidJointAngles, 8)
	}

	return angles
}
