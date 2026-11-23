extends Node2D

@export var song_image: PackedScene
var dst = 210

func _ready():
	for i in range(len(GlobalState.songs)):
		var new_song = song_image.instantiate()		
		new_song.position.y = i * dst
		new_song.id = i
		new_song.song = GlobalState.songs[i]
		add_child(new_song)
