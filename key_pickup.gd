extends Area3D

signal interact

# add key to keychain and delete in world object
func _on_interact() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var key_manager = player.get_node("KeyManager")
	key_manager.add_key()
	queue_free()
