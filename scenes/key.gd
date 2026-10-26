extends RigidBody3D

@onready var camera : Camera3D = get_tree().get_first_node_in_group("camera") 

var IMPULSE_POWER = 1.0

var mouse_input = Vector3.ZERO

func _input(event: InputEvent) -> void:
	# Track mouse motion vector
	if event is InputEventMouseMotion:
		mouse_input = event.relative

func _on_mouse_entered() -> void:
	var force_vector = camera.global_basis * Vector3(mouse_input.x, mouse_input.y, 0)
	force_vector = force_vector.normalized() * IMPULSE_POWER
	apply_impulse(force_vector, Vector3(0, -0.1, 0))

# grabbed function
# tween rotation to camera.basis * Vector3(0, 0, -90)
# move key position to mouse cursor (raycast on plane orthogonal to door and ground)
