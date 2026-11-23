extends Node2D

var worm = load("res://enemy.tscn")
var snake = load("res://snake.tscn")
var shield = load("res://shield.tscn")
var crystal = load("res://crystal.tscn")
var fworm = load("res://fwenemy.tscn")

@export var high_pos: Node2D
@export var low_pos: Node2D
@export var end_start: Node2D
@export var blinker: Sprite2D
@export var pointer: Node2D

var blink_length = 0.25
var blink_count = 7

var max_y: float = 300
var min_y: float = 160
var avg_y: float = min_y + (max_y - min_y) / 2
var avg_x: float = 200

var waves = [
	{
		"enemies": [
			worm,
		],
		"num": 0
	},
	{
		"enemies": [
			worm,
			worm,
			worm,
		],
		"num": 0
	},
	{
		"enemies": [
			worm,
			worm,
			worm,
			fworm
		],
		"num": 0
	},
	{
		"enemies": [
			worm,
			worm,
			snake
		],
		"num": 0
	},
	{
		"enemies": [
			worm,
			worm,
			worm,
			snake
		],
		"num": 0
	},
	{
		"enemies": [
			worm,
			worm,
			snake,
			snake
		],
		"num": 0
	},
	{
		"enemies": [
			fworm,
			snake,
			snake,
			snake
		],
		"num": 0
	},
	{
		"enemies": [
			shield
		],
		"num": 0
	},
	{
		"enemies": [
			snake,
			snake,
			snake,
			shield,
			shield,
			fworm
		],
		"num": 2
	},
	{
		"enemies": [
			fworm,
			shield,
			snake,
		],
		"num": 2
	},
	{
		"enemies": [
			shield,
			shield,
			snake,
			snake,
			snake
		],
		"num": 2
	},
	{
		"enemies": [
			crystal,
			crystal
		],
		"num": 0
	},
	{
		"enemies": [
			crystal,
			crystal,
			worm,
			fworm,
			fworm
		],
		"num": 0
	},
	{
		"enemies": [
			crystal,
			crystal,
			fworm,
			fworm,
			snake
		],
		"num": 0
	},
	{
		"enemies": [
			crystal,
			crystal,
			fworm,
			fworm,
			snake,
			snake,
			snake,
			shield
		],
		"num": 0
	},
	{
		"enemies": [
			snake,
			snake,
			snake,
			fworm,
			shield,
			shield,
			crystal,
			crystal
		],
		"num": 0
	},
	{
		"enemies": [
			snake,
			snake,
			snake,
			fworm,
			worm,
			fworm,
			shield,
			shield,
			crystal,
			crystal
		],
		"num": 0
	}
]

var current_wave = 0
var timer: SceneTreeTimer
var waved: bool = false

func _ready() -> void:
	if GlobalState.current_level > 0:
		current_wave = randi_range(1, 4)
	await get_tree().create_timer(0.0 if GlobalState.first else 2.0).timeout
	if GlobalState.unfrozen:
		new_wave()

func _process(_delta: float) -> void:
	if not GlobalState.unfrozen or not waved:
		pointer.visible = false
		return
	
	if ("num" in waves[current_wave] and get_child_count() <= waves[current_wave]["num"] 
	or  "time" in waves[current_wave] and timer.is_stopped()):
		current_wave += 1
		if current_wave < len(waves):
			new_wave()
		else:
			victor()
		return
	
	var player_pos = get_node("/root/Node2D/CameraHolder").position
	var min_dst = [INF, null]
	for enemy in get_children():
		var dst = (enemy.position - player_pos).length()
		if dst < min_dst[0]:
			min_dst = [dst, enemy]
	
	if min_dst[0] > 1500:
		var diff: Vector2 = min_dst[1].position - player_pos
		pointer.visible = true
		pointer.rotation = diff.angle()
		pointer.get_child(0).scale.y = -7.0 if diff.x < 0 else 7.0
	else:
		pointer.visible = false
	
func new_wave():
	waved = false
	var wave = waves[current_wave]
	var new_enemies = []
	for to_instantiate in wave["enemies"]:
		var new_enemy = to_instantiate.instantiate()
		add_child(new_enemy)
		new_enemies.append(new_enemy)
	if "time" in wave:
		timer = get_tree().create_timer(wave["time"])
	
	var start_x = -high_pos.position.x * sign(get_node("/root/Node2D/Plane").position.x)
	
	var y_range = high_pos.position.y - low_pos.position.y
	var initial_point = Vector2(start_x, low_pos.position.y + randf() * y_range)
	var point = initial_point
	point.y -= avg_y * (len(new_enemies) + 1)
	point.y = clamp(point.y, low_pos.position.y, high_pos.position.y)
	
	var points = []
	for enemy in new_enemies:
		enemy.freeze = true
		enemy.rotation = -sign(start_x) * PI / 2
		
		var y_add = min_y + randf() * (max_y - min_y)
		var new_point = Vector2(
			-sign(start_x) * (end_start.position.x + randf() * avg_x * 2),
		 	point.y + y_add)
		points.append(new_point.x)
		enemy.position = Vector2(start_x, new_point.y)
		point.y += y_add
	
	var i = 0.0
	var count = 0
	blinker.position.x = 1062 * sign(start_x)
	blinker.scale.x = 7.0 * -sign(start_x)
	blinker.visible = true
	blinker.stick_pos = initial_point.y
	while count < blink_count:
		await get_tree().process_frame
		i += get_process_delta_time()
		if i > blink_length:
			i = 0.0
			blinker.visible = !blinker.visible
			count += 1
			if blinker.visible:
				blinker.get_node("Blink").play()
	
	i = 0.0
	while i < 1.0:
		await get_tree().process_frame
		i += get_process_delta_time()
		for j in range(len(new_enemies)):
			new_enemies[j].position.x = lerp(start_x, points[j], i)
	
	for enemy in new_enemies:
		enemy.unfreeze()
	waved = true


func victor():
	GlobalState.victorize()
