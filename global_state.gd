extends Node

var unfrozen: bool = true
signal kill
signal victor
var score: int = 0
var current_level: int = 0
var last: int = 0
var songs: Array[Song]
var killy: float = 1.0
var first: bool = true
var start_time: float

var levels = [
	{
		"score": 100,
		"song": "Gatling"
	},
	{
		"score": 2000,
		"song": "Shotgun"
	},
	{
		"score": 10000,
		"song": "Laser"
	},
	{
		"score": 20000,
		"text": "You Win"
	}
]

func _init() -> void:
	songs = [load("res://song_Base.tres")]

func do_kill():
	unfrozen = false
	first = false
	kill.emit()

func reset():
	unfrozen = true
	score = 0


func victorize():
	unfrozen = false
	victor.emit()
