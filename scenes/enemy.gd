extends CharacterBody3D


const SPEED = 3.0
const TURN_SPEED = 8.0
const REPATH_INTERVAL = 0.2 # seconds between path recalculations

@onready var player : Node3D = get_tree().get_first_node_in_group("player")
@onready var nav : NavigationAgent3D = $NavigationAgent3D

var _repath_timer := 0.0


func _ready() -> void:
	# The navigation map isn't synced on the first physics frame,
	# so querying a path immediately returns nothing.
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Recalculate the path periodically instead of every frame.
	_repath_timer -= delta
	if _repath_timer <= 0.0 and player:
		_repath_timer = REPATH_INTERVAL
		nav.target_position = player.global_position

	var horizontal := Vector3.ZERO
	if not nav.is_navigation_finished():
		var next_pos := nav.get_next_path_position()
		var direction := next_pos - global_position
		direction.y = 0.0 # only steer on the ground plane; gravity handles Y
		if direction.length_squared() > 0.0001:
			horizontal = direction.normalized() * SPEED
			_face(direction, delta)

	# Write the movement into the body's own velocity (keep gravity's Y).
	velocity.x = horizontal.x
	velocity.z = horizontal.z

	move_and_slide()


func _face(direction: Vector3, delta: float) -> void:
	var target_yaw := atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, TURN_SPEED * delta)
