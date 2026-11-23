extends RigidBody2D

@export var plane: RigidBody2D

func _ready():
	GlobalState.kill.connect(kill)
	GlobalState.victor.connect(victor)
	position = plane.position

func _physics_process(_delta: float) -> void:
	if is_instance_valid(plane) and GlobalState.unfrozen:
		linear_velocity = (plane.position - position) * 6

func kill():
	await get_tree().physics_frame
	await get_tree().physics_frame
	linear_velocity = Vector2.ZERO
	
func victor():
	await get_tree().physics_frame
	await get_tree().physics_frame
	linear_velocity = Vector2.ZERO
