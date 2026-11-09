extends Node3D

var is_open = false
@export var door_id : String
@export var is_unlocked = false

# animations and sounds
@onready var anim_player = $AnimationPlayer 
@onready var audio_player = $AudioStreamPlayer3D
@export var sounds: Dictionary[StringName, AudioStream]

# unlock minigame
@onready var camera_marker = $CameraMarker
@onready var keyring_marker = $KeyringMarker
@onready var knob_marker = $KnobMarker
@onready var key_marker = $KeyMarker

	
func _on_knob_trigger_interact() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var key_manager = player.get_node("KeyManager")
	var is_equipped = key_manager.is_equipped
	
	# Door locked, don't budge
	if !is_unlocked and !is_equipped:
		anim_player.play("door_locked")
		audio_player.stream = sounds["door_locked"]
		audio_player.play()
	# Door locked, start unlock minigame
	elif !is_unlocked and is_equipped:
		key_manager.start_minigame(camera_marker, keyring_marker, knob_marker)
	
	elif is_open:
		anim_player.play("door_close")
		audio_player.stream = sounds["door_close"]
		audio_player.play()
		is_open = false
	else:
		anim_player.play("door_open")
		audio_player.stream = sounds["door_open"]
		audio_player.play(0.5)
		is_open = true

# Unlock Logic
func _on_unlock_trigger_area_entered(area: Area3D) -> void:
	# is key entering the lock?
	if area.is_in_group("key") and !is_unlocked:
		
		var key = area.get_parent()
		var player = get_tree().get_first_node_in_group("player")
		var key_manager = player.get_node("KeyManager")
		
		# successful unlock
		if area.get_parent().key_id == door_id:
			# unlock door
			is_unlocked = true
			audio_player.stream = sounds["door_unlock"]
			audio_player.play()
		
			# play key unlock anim
			key_manager.unlock_anim(key, key_marker, true)
		
		# unsuccessful unlock
		else:
			# TODO: play unsuccessful unlock audio
			key_manager.unlock_anim(key, key_marker, false)
