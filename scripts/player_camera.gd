extends Camera3D

@export var camera_sensitivity := 10
var mouse_input : Vector2 = Vector2.ZERO


# This script moves the player's camera based on the mouse input. Mouse input is
# only tracked when the mouse is locked to the window, aka "Input.MOUSE_MODE_CAPTURED". 
# You should not have to edit any part of this script other than camera_sensitivity.


# Called when the node enters the scene tree for the first time.
func _ready():
	# Lock mouse to window on ready
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func _physics_process(delta: float) -> void:
	# Camera rotates only when mouse is focused
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		handle_camera(delta)
		
# Override _input function to keep track of MouseMotion
# event is a variable that records all InputEvents
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = event.relative
	
# handle camera rotation with input event (Mouse)
func handle_camera(delta):
	var look_input = (-1) * mouse_input
	look_input = look_input  * camera_sensitivity * delta
	# Rotate camera based on look_input vector
	rotation_degrees.x += look_input.y
	rotation_degrees.x = clampf(rotation_degrees.x, -90, 90)
	rotation_degrees.y = fmod(rotation_degrees.y + look_input.x, 360.0)
	# Reset mouse_input (necessary or else your mouse will feel like it's sliding)
	mouse_input = Vector2.ZERO
	
func raycast_from_mouse(collide_with_bodies = true):
	var ray_length = 1000
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	# calculate ray start and end positions
	var from = project_ray_origin(mouse_position)
	var to = from + project_ray_normal(mouse_position) * ray_length
	# build raycast and interact with physics world
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	# set custom raycast information
	query.collide_with_areas = !collide_with_bodies
	query.collide_with_bodies = collide_with_bodies
	
	# only raycast with door knob plane
	if query.collide_with_areas:
		query.collision_mask = 4
	
	# extract result from raycast
	var result = space_state.intersect_ray(query)
	return result
