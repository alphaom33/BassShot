extends Node2D

@export var level_bar: Node2D
@export var reward: Label

var bar_start = -251.857
var bar_end = -5.0
var background_start = 1846.0

var can_restart = false

func _ready():
	GlobalState.kill.connect(end)
	position.y = background_start
	visible = false

func _process(_delta: float) -> void:
	if can_restart and Input.is_anything_pressed():
		while Input.is_anything_pressed():
			await get_tree().process_frame
		GlobalState.reset()
		if get_tree():
			get_tree().reload_current_scene()

func score_to_i(score: int) -> float:
	if score == 0:
		return 0
	else:
		return min(float(score) / GlobalState.levels[GlobalState.current_level]["score"], 1.0)

func i_to_score(i: float) -> int:
	return GlobalState.levels[GlobalState.current_level]["score"] * i

func end():
	reward.text = ""
	level_bar.position.x = lerp(bar_start, bar_end, score_to_i(GlobalState.last))
	if GlobalState.current_level >= len(GlobalState.levels):
		level_bar.position.x = bar_end
		reward.text = "Max Level"
	
	await get_tree().create_timer(1.0).timeout
	visible = true
	position.y = background_start
	var i: float = 0
	while i < 1:
		await get_tree().process_frame
		i += get_process_delta_time()
		position.y = lerp(background_start, bar_end, i)
	
	if GlobalState.current_level >= len(GlobalState.levels):
		level_bar.position.x = bar_end
		reward.text = "Max Level"
		can_restart = true
		GlobalState.score = 0
		return
	
	var initial_score = GlobalState.score + GlobalState.last
		
	while GlobalState.score + GlobalState.last >= GlobalState.levels[GlobalState.current_level]["score"]:
		i = score_to_i(GlobalState.last)
		level_bar.position.x = lerp(bar_start, bar_end, score_to_i(GlobalState.last))
		while i < 1:
			await get_tree().process_frame
			$Score.play()
			i += get_process_delta_time()
			GlobalState.score = initial_score - GlobalState.levels[GlobalState.current_level]["score"] * i
			level_bar.position.x = lerp(bar_start, bar_end, i)
		GlobalState.score = initial_score - GlobalState.levels[GlobalState.current_level]["score"]
		GlobalState.last = 0
		$Reward.play()
		if "song" in GlobalState.levels[GlobalState.current_level]:
			var new_song = GlobalState.levels[GlobalState.current_level]["song"]
			reward.text = "New Song: " + new_song
			GlobalState.songs.append(load("res://song_" + new_song + ".tres"))
		GlobalState.current_level += 1
		if GlobalState.current_level >= len(GlobalState.levels):
			GlobalState.score = 0
			can_restart = true
			return
		initial_score = GlobalState.score
	
	i = score_to_i(GlobalState.last)
	print(initial_score)
	while i < score_to_i(initial_score):
		await get_tree().process_frame
		i += get_process_delta_time()
		$Score.play()
		GlobalState.score = initial_score - GlobalState.levels[GlobalState.current_level]["score"] * i
		level_bar.position.x = lerp(bar_start, bar_end, i)
	GlobalState.score = 0
	GlobalState.last = initial_score
	can_restart = true
