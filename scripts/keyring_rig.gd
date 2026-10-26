extends Node3D

# Play keyring equip / unequip animation when called by KeyManager 

@onready var anim_player : AnimationPlayer = $AnimationPlayer 
@onready var audio_player : AudioStreamPlayer3D = $KeyringEquipSFX

func play_equip_anim(is_equipped):
	if is_equipped:
		anim_player.play("equip_keyring")
		audio_player.pitch_scale = 1.0
		audio_player.play()
	else:
		anim_player.play("unequip_keyring")
		audio_player.pitch_scale = 0.5
		audio_player.play(0.5)
