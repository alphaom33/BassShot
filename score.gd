extends Label

@export var pretext = "SCORE: "

func _process(_delta: float) -> void:
	text = pretext + str(GlobalState.score).pad_zeros(6)
