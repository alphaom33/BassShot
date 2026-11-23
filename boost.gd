extends AudioStreamPlayer

var playifying: int = 0
var volumes = [0, -28, -24, -20]

func _process(_delta: float) -> void:
	if playifying > 0:
		volume_db = volumes[playifying]
		if not playing:
			play()
	else:
		stop()
