extends Node2D

@export var current_hit: int = 0
@export var audio_manager: AudioManager
@export var bar: PackedScene
@export var bar_start: Node2D

var bars: Array[Node2D]

var seconds_ahead = 1

func _ready():
	audio_manager.song_changed.connect(kill_bars)
	kill_bars()
	
func place_bar(bar_time: float) -> float:
	var start_x = bar_start.position.x
	var measure_length = audio_manager.current_song.measure_length
	
	var ahead_time = fmod(bar_time + seconds_ahead + audio_manager.get_playback_position(), measure_length)
	var measure_pos = ahead_time / measure_length
	return start_x + (start_x * -2.0) * measure_pos

func create_bars():
	var measure_length = audio_manager.current_song.measure_length
	seconds_ahead = measure_length / 2.0
	for bar_time in audio_manager.current_song.beats:
		bar_time = measure_length - bar_time
		var new_bar: Node2D = bar.instantiate()
		new_bar.position.x = place_bar(bar_time)
		new_bar.time = bar_time
		
		bars.append(new_bar)
		add_child(new_bar)

func _on_audio_manager_loop() -> void:
	current_hit = 0
	
func kill_bars():
	$Static.visible = true
	$Static/Static.play()
	for bar_child in bars:
		bar_child.queue_free()
	current_hit = 0
	bars = []
	create_bars()
	await get_tree().create_timer(0.2).timeout
	$Static.visible = false
	$Static/Static.stop()
