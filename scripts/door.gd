extends Node3D

var is_open = false
var is_unlocked = false

@onready var anim_player = $AnimationPlayer 
@onready var audio_player = $AudioStreamPlayer3D
@export var sounds: Dictionary[StringName, AudioStream]

	
func _on_knob_trigger_interact() -> void:
	if !is_unlocked:
		anim_player.play("door_locked")
		audio_player.stream = sounds["door_locked"]
		audio_player.play()
	
	elif is_open:
		anim_player.play("door_close")
		audio_player.stream = sounds["door_close"]
		audio_player.play()
	else:
		anim_player.play("door_open")
		audio_player.stream = sounds["door_open"]
		audio_player.play(0.5)
	is_open = !is_open
