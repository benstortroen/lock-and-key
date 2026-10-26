extends Node3D

signal interact


func _on_interact() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var key_manager = player.get_node("KeyManager")
	key_manager.add_keyring()
	get_parent().queue_free()
