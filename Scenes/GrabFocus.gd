extends Button

@export var FIRST : bool
@export var SWITCH_SCENE : PackedScene

func _ready() -> void:
    if FIRST: grab_focus()
    button_up.connect(func_button_up)

func func_button_up() -> void:
    if not SWITCH_SCENE: 
        get_tree().quit()
        return
    get_tree().change_scene_to_packed(SWITCH_SCENE)

