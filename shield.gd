extends Enemy

var rotation_speed = .01

func _init():
	force = 500000
	max_velocity = 100
	score = 500
	killy = false
	health = 0.5

func _ready():
	GlobalState.kill.connect(kill)
	player = get_node("/root/Node2D/Plane")
	near_water = get_node("/root/Node2D/NearWater")

func _process(_delta: float) -> void:
	if not GlobalState.unfrozen:
		return
	
	var target_position = Vector2(player.position.x, min(player.position.y, near_water.position.y))
	var dst = target_position - position
	var dot = dst.normalized().dot(Vector2.from_angle(rotation - PI / 2))
	if dot > 0.6:
		linear_velocity = Vector2.from_angle(rotation - PI / 2) * force
	else:
		linear_velocity = Vector2.ZERO
		
	for body in $HurtArea.get_overlapping_bodies():
		if body.is_in_group("Player") and killy:
			GlobalState.do_kill()

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if not GlobalState.unfrozen:
		return
	
	var target_position = Vector2(player.position.x, min(player.position.y, near_water.position.y))
	var dst = target_position - position
	var rot_dir = dst.normalized().dot(Vector2.from_angle(rotation))
	rotation += sign(rot_dir) * rotation_speed

	if abs(linear_velocity.x) > max_velocity:
		linear_velocity.x = sign(linear_velocity.x) * max_velocity
	if abs(linear_velocity.y) > max_velocity:
		linear_velocity.y = sign(linear_velocity.y) * max_velocity
	
	angular_velocity = 0

func kill():
	await get_tree().physics_frame
	await get_tree().physics_frame
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
func unfreeze():
	freeze = false
	await get_tree().create_timer(GlobalState.killy).timeout
	killy = true
