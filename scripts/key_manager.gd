extends Node3D
#  Manage keyring equip state and unlock minigame


var is_equipped = false
var in_minigame = false

# nodes
@export var keyring_rig : Node3D
@onready var camera : Camera3D = get_tree().get_first_node_in_group("player").get_node("Camera3D")
var _knob_marker : Node3D

# temp camera transform variables
var reset_cam_pos = Vector3(0, 0.5, 0)
var reset_cam_rotation = Vector3.ZERO

func _process(delta):
	# Toggle keyring equip
	if Input.is_action_just_pressed("toggle_keyring"):
		is_equipped = !is_equipped
		print("Is Equipped: " + str (is_equipped) + " " + Time.get_time_string_from_system())
		keyring_rig.play_equip_anim(is_equipped)
		
	# Drag key_grabbed to cursor position 
	if is_key_grabbed:
		drag_to_mouse(delta)

# Handle keyring equipment and mouse lock to window
func _input(event: InputEvent) -> void:
	# Leave unlock minigame
	if in_minigame and (Input.is_action_just_pressed("ui_cancel") || !is_equipped) :
		end_minigame()
	# Leave game window
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Lock mouse to window
	elif event.is_action_pressed("interact") and !in_minigame:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Try to grab key
	elif event.is_action_pressed("interact") and in_minigame:
		try_grab()
	# Stop grabbing key
	elif event.is_action_released("interact"):
		unequip_key()

# Minigame gets started by door interaction
func start_minigame(camera_marker : Marker3D, keyring_marker : Marker3D, knob_marker : Marker3D):
	in_minigame = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# move camera transform to marker transform
	reset_cam_rotation = camera.rotation
	var tween = create_tween()
	tween.set_parallel(true) 
	tween.tween_property(camera, "global_transform", camera_marker.global_transform, 0.5).set_trans(Tween.TRANS_CIRC)

	# align keyring with door knob  
	tween.tween_property(keyring_rig.get_node("Keyring"), "global_transform", keyring_marker.global_transform, 0.5).set_trans(Tween.TRANS_CIRC)
	
	# TODO: make keys interactable and jangle
	_knob_marker = knob_marker
	
	# TODO: disable movement 

# minigame is ended by input
func end_minigame():
	in_minigame = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# unequip keyring on quit
	if (is_equipped):
		is_equipped = false
		keyring_rig.play_equip_anim(is_equipped)
	
	# reset camera position
	var tween = create_tween()
	tween.set_parallel(true) 
	tween.tween_property(camera, "rotation", reset_cam_rotation, 0.5).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(camera, "position", reset_cam_pos, 0.5).set_trans(Tween.TRANS_CIRC)
	
# ==============================================================================
# Handle Item Pickups

func add_key():
	var keyring = keyring_rig.get_node("Keyring")
	var key_instance = preload("res://scenes/attached_key.tscn").instantiate() 
	keyring.add_child(key_instance)
	
# ==============================================================================
# Key Drag Functions

var is_key_grabbed = false
var key_grabbed : Node3D = null

# Grab key if mouse cursor is over key when iteract button is pressed 
func try_grab():
	# set grabbed key
	var result = camera.raycast_from_mouse(true)
	if result and result.collider.is_in_group("key"):
		is_key_grabbed = true
		key_grabbed = result.collider
		
func unequip_key():
	is_key_grabbed = false
	key_grabbed = null
		
func align_key_to_knob():
	# TODO: make align transition smoother
	key_grabbed.look_at(_knob_marker.global_position, Vector3.UP)
	key_grabbed.rotate_x(deg_to_rad(90))
	key_grabbed.rotate_z(deg_to_rad(-90))
	
func drag_to_mouse(delta):
	# find 3d position of mouse cursor
	var result = camera.raycast_from_mouse(false)
	if result:
		var cursor_position = result.position
		# move key to cursor position
		key_grabbed.global_position = key_grabbed.global_position.move_toward(cursor_position, delta * 3)
		align_key_to_knob()
		
func unlock_anim(key_marker: Marker3D):
	# TODO: prevent early unequip which causes crash
	var unlocking_key = key_grabbed
	unlocking_key.freeze = true
	unequip_key()
	var tween = create_tween()
	tween.tween_property(unlocking_key, "global_transform", key_marker.global_transform, 0.5).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(unlocking_key, "global_transform", key_marker.global_transform, 0.75)
	tween.tween_property(unlocking_key, "rotation:x", deg_to_rad(-90), 0.5).set_trans(Tween.TRANS_SPRING)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	unlocking_key.queue_free()
	end_minigame()


# grabbed function
# tween rotation to camera.basis * Vector3(0, 0, -90)
# move key position to mouse cursor (raycast on plane orthogonal to door and ground)
