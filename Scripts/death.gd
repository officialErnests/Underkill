extends Control

func _ready() -> void:
    $Health.text = "YOU DIED \nFINAL SCORE: " + str(Global.score) + " p"

func _on_button_button_up() -> void:
    Global.player_health = Global.player_max_health
    Global.score = 0
    get_tree().change_scene_to_file("res://Scenes/FIGHT.tscn")
