class_name AudioManager extends AudioStreamPlayer

@export var songs: Array[Song]

var current_song: Song
var last_hit: float = INF
var forgiveness: float = 0.2
var start_time: float

signal loop()
signal song_changed()

func set_song(song: Song):
	current_song = song
	stream = song.stream
	play(fmod(Time.get_unix_time_from_system() - start_time, song.loop_end))
	song_changed.emit()

func _ready() -> void:
	songs = GlobalState.songs
	start_time = Time.get_unix_time_from_system()
	set_song(songs[0])
	GlobalState.kill.connect(stop)
	
func _process(_delta: float) -> void:
	if get_playback_position() > current_song.loop_end:
		play()
		loop.emit()

func dst_circle(dst: float, maximum: float) -> float:
	if dst > maximum / 2:
		return abs(maximum - dst)
	else:
		return dst
	
func on_beat() -> bool:
	if abs(get_playback_position() - last_hit) < forgiveness:
		last_hit = get_playback_position()
		return false
	last_hit = get_playback_position()
	
	var time = fmod(get_playback_position(), current_song.measure_length)
	
	var high_beat = 0
	var low_beat = 0
	for i in range(0, len(current_song.beats)):
		if current_song.beats[i] > time:
			high_beat = i
			low_beat = i - 1
			break

	
	if high_beat == low_beat:
		high_beat = 0
		low_beat = len(current_song.beats) - 1

	var high_dst = dst_circle(abs(time - current_song.beats[high_beat]), current_song.measure_length)
	var low_dst = dst_circle(abs(time - current_song.beats[low_beat]), current_song.measure_length)
		
	return min(high_dst, low_dst) < forgiveness
