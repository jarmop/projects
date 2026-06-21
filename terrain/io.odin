package terrain

import "base:runtime"

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import "core:os"

import gl "vendor:OpenGL"
import "vendor:glfw"

window: glfw.WindowHandle

init_io :: proc() {
	glfw.Init()
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	window = glfw.CreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", nil, nil)
	if window == nil {
		fmt.println("Failed to create GLFW window")
		glfw.Terminate()
		os.exit(-1)
	}
	glfw.MakeContextCurrent(window)

	gl.load_up_to(3, 3, glfw.gl_set_proc_address)

	gl.Viewport(0, 0, SCR_WIDTH, SCR_HEIGHT)

	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
	glfw.SetCursorPosCallback(window, mouse_callback)
	glfw.SetScrollCallback(window, scroll_callback)

	glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)

	update_camera()
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width: i32, height: i32) {
	gl.Viewport(0, 0, width, height)
}

processInput :: proc "c" (window: glfw.WindowHandle) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}

	camera_movement := deltaTime * camera_speed

	// WASD
	if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {
		cameraPos += camera_movement * cameraFront
	}
	if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS {
		cameraPos -= camera_movement * cameraFront
	}
	if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {
		cameraPos -= glsl.normalize(glsl.cross(cameraFront, cameraUp)) * camera_movement
	}
	if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS {
		cameraPos += glsl.normalize(glsl.cross(cameraFront, cameraUp)) * camera_movement
	}

	// Elevation
	if glfw.GetKey(window, glfw.KEY_E) == glfw.PRESS {
		cameraPos += cameraUp * camera_movement
	}
	if glfw.GetKey(window, glfw.KEY_C) == glfw.PRESS {
		cameraPos -= cameraUp * camera_movement
	}
}

update_camera :: proc() {
	front := glsl.vec3 {
		math.cos(glsl.radians(yaw)) * math.cos(glsl.radians(pitch)),
		math.sin(glsl.radians(pitch)),
		math.sin(glsl.radians(yaw)) * glsl.cos(glsl.radians(pitch)),
	}
	cameraFront = glsl.normalize(front)
}

mouse_callback :: proc "c" (window: glfw.WindowHandle, xposIn: f64, yposIn: f64) {
	context = runtime.default_context()

	xpos := f32(xposIn)
	ypos := f32(yposIn)

	if firstMouse {
		lastX = xpos
		lastY = ypos
		firstMouse = false
	}

	xoffset := xpos - lastX
	yoffset := lastY - ypos
	lastX = xpos
	lastY = ypos

	sensitivity: f32 = 0.1
	xoffset *= sensitivity
	yoffset *= sensitivity

	yaw += xoffset
	pitch += yoffset

	if pitch > 89 {
		pitch = 89
	}
	if pitch < -89 {
		pitch = -89
	}

	update_camera()
}

scroll_callback := proc "c" (window: glfw.WindowHandle, xoffset: f64, yoffset: f64) {
	fov -= f32(yoffset)
	if fov < 1 {
		fov = 1
	}
	if fov > 45 {
		fov = 45
	}
}

SCR_WIDTH :: 800
SCR_HEIGHT :: 600

cameraPos := glsl.vec3{128, 250, 350}
cameraFront := glsl.vec3{0, 0, -1}
cameraUp := glsl.vec3{0, 1, 0}

firstMouse := true
yaw: f32 = -90
pitch: f32 = -45
lastX: f32 = 800 / 2
lastY: f32 = 600 / 2
fov: f32 = 45

deltaTime: f32 = 0
lastFrame: f32 = 0

camera_speed: f32 = 100
