package multithreading

import "core:fmt"
import "core:thread"
import "core:time"

data: string

ms: time.Duration = 1000000

main :: proc() {
	// thread.run(thread_proc)
	thread.run_with_data(&data, thread_with_data)

	// d: time.Duration
	fmt.println("After thread.run")

	fmt.println(time.now(), data)

	time.accurate_sleep(1000 * ms)

	fmt.println(time.now(), data)


	// for {}
}

thread_basic :: proc() {
	fmt.println("In a thread")

	for {}
}

thread_with_data :: proc(data: rawptr) {
	p := (^string)(data)
	// str := (cast(^string)data)^

	fmt.println("Set data in a thread")

	p^ = "Hello from thread"
}
