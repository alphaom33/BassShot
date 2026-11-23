extends Enemy

@export var venom: PackedScene

var bullet_time = 4.0

func _init():
	force = 20000
	max_velocity = 100
	score = 200
	killy = false
	health = 1.0

func _ready():
	GlobalState.kill.connect(kill)
	player = get_node("/root/Node2D/Plane")
	near_water = get_node("/root/Node2D/NearWater")
	
	while true:
		await get_tree().create_timer(bullet_time + randf() - 0.5).timeout
		if not GlobalState.unfrozen:
			return
		elif freeze:
			continue
			
		var new_venom: Node2D = venom.instantiate()
		new_venom.position = $ShootSpot.global_position
		new_venom.rotation = rotation
		get_tree().root.add_child(new_venom)

func _process(_delta: float) -> void:
	if GlobalState.unfrozen:
		apply_force(Vector2.from_angle(rotation - PI / 2) * force)
		
	for body in $HurtArea.get_overlapping_bodies():
		if body.is_in_group("Player") and killy:
			GlobalState.do_kill()

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if not GlobalState.unfrozen:
		return
	
	var target_position = Vector2(player.position.x, min(player.position.y, near_water.position.y))
	var dst = target_position - position
	var target = atan2(dst.y, dst.x)
	var target_rotation = target + PI / 2
	rotation = target_rotation

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
