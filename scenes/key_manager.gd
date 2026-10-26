extends Node3D

#  Manage keyring equip state and unlock minigame

var is_equipped = false
var in_minigame = false
@export var keyring_rig : Node3D
@onready var camera : Camera3D = get_tree().get_first_node_in_group("player").get_node("Camera3D")
var reset_cam_pos = Vector3(0, 0.5, 0)
var reset_cam_rotation = Vector3.ZERO
var mouse_input = Vector3.ZERO

func _process(delta):
	# Toggle keyring equip
	if Input.is_action_just_pressed("toggle_keyring"):
		is_equipped = !is_equipped
		print("Is Equipped: " + str (is_equipped) + " " + Time.get_time_string_from_system())
		keyring_rig.play_equip_anim(is_equipped)

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

# minigame gets started by door interaction
func start_minigame(camera_marker : Marker3D, keyring_marker : Marker3D):
	in_minigame = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# move camera transform to marker transform
	reset_cam_rotation = camera.rotation
	var tween = create_tween()
	tween.set_parallel(true) 
	tween.tween_property(camera, "global_transform", camera_marker.global_transform, 0.5).set_trans(Tween.TRANS_CIRC)
	
	
	# TODO: align keyring with door knob  
	tween.tween_property(keyring_rig.get_node("Keyring"), "global_transform", keyring_marker.global_transform, 0.5).set_trans(Tween.TRANS_CIRC)
	
	# TODO: make keys interactable and jangle
	
	# TODO: disable movement 

# minigame is ended by input
func end_minigame():
	in_minigame = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# reset camera position
	var tween = create_tween()
	tween.set_parallel(true) 
	tween.tween_property(camera, "rotation", reset_cam_rotation, 0.5).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(camera, "position", reset_cam_pos, 0.5).set_trans(Tween.TRANS_CIRC)
	
	
	
	pass
