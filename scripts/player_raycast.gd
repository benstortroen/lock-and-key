extends RayCast3D

@export var CrosshairTexture : TextureRect
@export var crosshair_default : CompressedTexture2D
@export var crosshair_grab : CompressedTexture2D


func _process(delta: float) -> void:
	var collision = get_collider()
	
	# Check if object can be interacted with
	if is_colliding() and collision.is_in_group("interactable"):
		
		# Set cross hair to grab
		CrosshairTexture.texture = crosshair_grab
		
		# Interact with object
		if Input.is_action_just_pressed("interact"):
			if collision.has_signal("interact"):
				collision.emit_signal("interact")
			else:
				print("No interact method on interactable object")
		
	# reset to default cross hair	
	else:
		CrosshairTexture.texture = crosshair_default
		
