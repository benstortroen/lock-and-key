extends CharacterBody3D

# Variables
var SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var camera : Camera3D = $Camera3D


# this function runs on every physics tick (usually 60 ticks per second)
func _physics_process(delta: float) -> void:		
	# Call movement function
	handle_movement(delta)


# Custom function I wrote to contain all movement logic. If your game involved 
# more complex movement, consider using a "state machine" to avoid a tangled 
# mess of if / else statements. 
func handle_movement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Find movement direction relative to the camera
	var direction := camera.global_basis * Vector3(input_dir.x, 0, input_dir.y)
	direction.y = 0 
	direction = direction.normalized() 
	
	# Sprint: Increase walking velocity 
	var sprint_speed = 1
	if (Input.is_action_pressed("sprint")):
		sprint_speed = 1.5
	
	# Set velocity if player has a direction to move in. Otherwise decelerate 
	# by using the move_toward command to gradually set velocity to 0.
	if direction:
		velocity.x = direction.x * SPEED * sprint_speed
		velocity.z = direction.z * SPEED * sprint_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	# This function moves the player based on its velocity and handles all 
	# collisions that occur with the player's CharacterBody3D.
	move_and_slide()
