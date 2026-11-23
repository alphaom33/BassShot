extends Sprite2D

var dst: float
var start_pos: float
var time: float

func _ready() -> void:
	start_pos = get_parent().get_node("BarStart").position.x
	dst = -start_pos
	dst /= get_parent().seconds_ahead
	global_scale = Vector2.ONE * 7.0

func _process(delta: float) -> void:
	if GlobalState.unfrozen:
		position.x += dst * delta
		if position.x > -start_pos:
			position.x = get_parent().place_bar(time)
