extends Sprite2D

var id: int = 0
var keycodes = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]
var audio_manager: AudioManager
var song: Song

func _ready() -> void:
	audio_manager = get_node("/root/Node2D/CameraHolder/Camera2D/AudioManager")
	
	$Num.text = str(id + 1)
	$Name.text = song.resource_name
	$Image.texture = song.image

func _input(event: InputEvent) -> void:
	if audio_manager.current_song != song and event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == keycodes[id]:
			audio_manager.set_song(song)
