class_name Enemy extends RigidBody2D

@export var player: RigidBody2D
@export var near_water: Node2D
@export var force = 20000
@export var max_velocity = 100
@export var score = 100
var killy = false
var health = 1.0
var flash_speed = 10.0

func _ready():
	GlobalState.kill.connect(kill)
	player = get_node("/root/Node2D/Plane")
	near_water = get_node("/root/Node2D/NearWater")

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
	
func damage(amount: float):
	health -= amount
	if health <= 0:
		queue_free()
		GlobalState.score += score
		var sound = load("res://sound.tscn").instantiate()
		sound.stream = load("res://kill.wav")
		get_tree().root.add_child(sound)
	else:
		var sound = load("res://sound.tscn").instantiate()
		sound.stream = load("res://hurt.wav")
		get_tree().root.add_child(sound)
		var i = 0.0
		while i < 1.0:
			await get_tree().process_frame
			i += get_process_delta_time() * flash_speed
			$Sprite2D.modulate.g = 1 - i
			$Sprite2D.modulate.b = 1 - i
		i = 0.0
		while i < 1.0:
			await get_tree().process_frame
			i += get_process_delta_time() * flash_speed
			$Sprite2D.modulate.g = i
			$Sprite2D.modulate.b = i
		$Sprite2D.modulate.g = 1.0
		$Sprite2D.modulate.b = 1.0
	
func unfreeze():
	freeze = false
	await get_tree().create_timer(GlobalState.killy).timeout
	killy = true
