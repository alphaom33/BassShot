extends RigidBody2D

var fly_force = 3000
var drag = 0.9
var max_velocity = 1000
var rotation_speed = 5
var gravity = 1

@export var bullet_spot: Node2D
@export var audio_manager: AudioManager

@export var plane: Texture2D
@export var zoom: Texture2D
@export var super_zoom: Texture2D
@export var none: Texture2D
@export var left_fire: Sprite2D
@export var right_fire: Sprite2D

@export var death_animation: PackedScene
@export var blacker: Node2D

var min_stretch = 0.9
var max_stretch = 1.1

func _ready():
	GlobalState.kill.connect(kill)
	GlobalState.victor.connect(victor)
	audio_manager.song_changed.connect(reset_emitter)

func _process(_delta: float) -> void:
	if not GlobalState.unfrozen:
		return
	
	if Input.is_action_pressed("fly"):
		apply_force(Vector2.from_angle(rotation - PI / 2) * fly_force)
		gravity_scale = 0
	else:
		gravity_scale = gravity
		$PlaneSprite.texture = plane
		
	if Input.is_action_pressed("rotate_left"):
		angular_velocity = -rotation_speed
	elif Input.is_action_pressed("rotate_right"):
		angular_velocity = rotation_speed
	else:
		angular_velocity = 0
		
	if Input.is_action_just_pressed("shoot"):
		if audio_manager.on_beat():
			$BulletSpot.get_child(0).shoot()
		else:
			$Fail.play()
		
		
	if abs(linear_velocity.x) > max_velocity:
		linear_velocity.x = sign(linear_velocity.x) * max_velocity
	if abs(linear_velocity.y) > max_velocity:
		linear_velocity.y = sign(linear_velocity.y) * max_velocity
		
	if Input.is_action_pressed("fly"):
		if Input.is_action_pressed("rotate_left"):
			left_fire.texture = zoom
			right_fire.texture = super_zoom
			$Zoom.playifying = 3
		elif Input.is_action_pressed("rotate_right"):
			right_fire.texture = zoom
			left_fire.texture = super_zoom
			$Zoom.playifying = 3
		else:
			left_fire.texture = zoom
			right_fire.texture = zoom
			$Zoom.playifying = 2
	elif Input.is_action_pressed("rotate_left"):
		left_fire.texture = none
		right_fire.texture = zoom
		$Zoom.playifying = 1
	elif Input.is_action_pressed("rotate_right"):
		left_fire.texture = zoom
		right_fire.texture = none
		$Zoom.playifying = 1
	else:
		left_fire.texture = none
		right_fire.texture = none
		$Zoom.playifying = 0

func kill():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	gravity = 0
	queue_free()
	var anim = death_animation.instantiate()
	anim.position = position
	anim.rotation = rotation
	get_tree().root.add_child(anim)
	
func reset_emitter():
	$BulletSpot.get_child(0).queue_free()
	$BulletSpot.add_child(audio_manager.current_song.emitter.instantiate())

func victor():
	await get_tree().physics_frame
	await get_tree().process_frame
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	gravity = 0
	freeze = true
	
	await get_tree().create_timer(1.0).timeout

	var rot_dir = Vector2.UP.normalized().dot(Vector2.from_angle(rotation))
	var i = 0.0
	if rot_dir > 0:
		left_fire.texture = zoom
		right_fire.texture = none
		$Zoom.playifying = 1
	else:
		left_fire.texture = none
		right_fire.texture = zoom
		$Zoom.playifying = 1
		
	var initial_rot = rotation
	while i < 1.0:
		await get_tree().process_frame
		i += get_process_delta_time()
		rotation = lerp_angle(initial_rot, 0, i)
		
	left_fire.texture = none
	right_fire.texture = none
	$Zoom.playifying = 0
	
	await get_tree().create_timer(0.5).timeout
	
	var initial_y = position.y
	i = 0.0
	while i < 1.0:
		await get_tree().process_frame
		i += get_process_delta_time() * 2.0
		position.y = lerp(initial_y, initial_y + 100, easeInOutCubic(i))
		
	left_fire.texture = super_zoom
	right_fire.texture = super_zoom
	$Zoom.playifying = 2
	
	initial_y = position.y
	i = 0.0
	while i < 1.0:
		await get_tree().process_frame
		i += get_process_delta_time()
		position.y = lerp(initial_y, initial_y - 2000, easeInOutCubic(i))
		
	await get_tree().create_timer(1.0).timeout
	
	i = 0.0
	while i < 1.0:
		await get_tree().process_frame
		i += get_process_delta_time() * 0.5
		blacker.modulate.a = i
	
	await get_tree().create_timer(0.5).timeout
	
	get_tree().change_scene_to_file("res://credits.tscn")
	
func easeInOutCubic(x: float) -> float:
	return 4 * x * x * x if x < 0.5 else 1 - pow(-2 * x + 2, 3) / 2;
