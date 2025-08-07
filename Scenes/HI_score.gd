extends Label

func _ready() -> void:
	text = "HI SCORE:"
	for i in Global.scores: text += "\n" + str(i)
