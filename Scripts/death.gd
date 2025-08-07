extends Control

func _ready() -> void:
	$VBoxContainer/Health.text = "YOU DIED \nFINAL SCORE: " + str(Global.score) + " p"
	Global.save_score.emit()
	$VBoxContainer/Respawn.grab_focus()

func _on_button_button_up() -> void:
	Global.player_health = Global.player_max_health
	Global.score = 0
	get_tree().change_scene_to_file("res://Scenes/FIGHT.tscn")

func _on_give_up_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
