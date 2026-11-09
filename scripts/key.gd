extends RigidBody3D

@export var key_id : String

var current_state: State = State.PICKUP # default to pickup
enum State {
	PICKUP,
	KEYRING,
	GRABBED,
	UNLOCKING
}

func _ready():
	# prevent rigidbody physics for pickup
	if current_state == State.PICKUP:
		freeze = true
		

func _process(delta: float) -> void:
	match current_state:
		State.PICKUP:
			# freeze = true
			pass
		_:
			# freeze = false
			pass

# ==============================================================================
# STATE: KEYRING 

@onready var camera : Camera3D = get_tree().get_first_node_in_group("camera") 
var IMPULSE_POWER = 1.0
var mouse_input = Vector3.ZERO

func _input(event: InputEvent) -> void:
	# Track mouse motion vector
	if event is InputEventMouseMotion:
		mouse_input = event.relative

# Jingle keys toward mouse motion
func _on_mouse_entered() -> void:
	if current_state == State.KEYRING:
		var force_vector = camera.global_basis * Vector3(mouse_input.x, mouse_input.y, 0)
		force_vector = force_vector.normalized() * IMPULSE_POWER
		apply_impulse(force_vector, Vector3(0, -0.05, 0))
	
func _on_pickup_area_interact() -> void:
	# add key to keychain
	var player = get_tree().get_first_node_in_group("player")
	var key_manager = player.get_node("KeyManager")
	key_manager.add_key(self)
	current_state = State.KEYRING
	freeze = false
