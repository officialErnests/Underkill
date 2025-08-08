extends Node

var player_max_health = 100
var player_health = player_max_health
var score = 0
var fun_mode : bool = false

var equiped = [
	"Punch",
	"Piercer",
	"Shotgun"
]

var all_items = [
	"Punch",
	"Piercer",
	"Shotgun",
	"Nail_gun",
	"Rocket"
]

var scores = []
signal save_score

func _ready() -> void:
	load_game()
	save_score.connect(save_func)

func save_func():
	scores.append(score)
	scores.sort()
	if scores.size() > 10: scores.pop_front()
	scores.reverse()
	save_game({"Scores":scores})


func save_game(save_data):
	# print("Saved to" + OS.get_data_dir())
	var save_file = FileAccess.open("user://underkill.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_data)
	save_file.store_line(json_string)

func load_game():
	if not FileAccess.file_exists("user://underkill.save"):
		return # Error! We don't have a save to load.
	var save_file = FileAccess.open("user://underkill.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		json.parse(json_string)
		scores = json.data["Scores"]
