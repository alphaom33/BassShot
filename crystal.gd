extends Enemy

var charge_time = 2
var charge_wait = 1.0
var recover_time = 0.3
var locked = false
var player_pos: Vector2
var speed = 10000
var rotation_speed = 0.1


func _init():
	killy = false
	health = 2.0
	flash_speed = 5.0
	score = 300


func _ready():
	GlobalState.kill.connect(kill)
	player = get_node("/root/Node2D/Plane")
	near_water = get_node("/root/Node2D/NearWater")
	
	while freeze:
		await get_tree().process_frame
	
	while true:
		await get_tree().create_timer(charge_time).timeout
		if not GlobalState.unfrozen:
			return
			
		locked = true
		$Indicator.visible = true
		player_pos = player.position
		await get_tree().create_timer(charge_wait).timeout
		if not GlobalState.unfrozen:
			return
			
		$Indicator.visible = false
		var initial_dot = sign(player_pos.dot(player_pos - position))
		linear_velocity = Vector2.from_angle(rotation - PI / 2) * speed
		while sign(player_pos.dot(player_pos - position)) == initial_dot:
			await get_tree().process_frame
		while linear_velocity.length() > 0.1:
			linear_velocity *= 0.6
			await get_tree().physics_frame
		linear_velocity = Vector2.ZERO
		await get_tree().create_timer(recover_time).timeout
		locked = false

func _process(_delta: float) -> void:
	for body in $HurtArea.get_overlapping_bodies():
		if body.is_in_group("Player") and killy:
			GlobalState.do_kill()

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if not GlobalState.unfrozen or locked:
		return
	
	var target_position = Vector2(player.position.x, min(player.position.y, near_water.position.y))
	var dst = target_position - position
	var rot_dir = dst.normalized().dot(Vector2.from_angle(rotation))
	rotation += sign(rot_dir) * rotation_speed
	
	angular_velocity = 0

func kill():
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	linear_velocity = Vector2.ZERO
	angular_velocity = 0

func unfreeze():
	freeze = false
	await get_tree().create_timer(GlobalState.killy).timeout
	killy = true
