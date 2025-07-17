extends Node2D

var enemies_json_path = "res://Assets//Charecters//Enemies//Enemies.json"

var enemies_json: Dictionary = {}

var mainControl : Control
var label : Label
var cage : Node2D
var player : CharacterBody2D

enum StageSets {
	ENEMY_ATTACK,
	PLAYER_ATTACK,
	PLAYER_MENU
}

var DEFAULT_CAGE = [Vector2(0,70),Vector2(287,140)]
var StageSet = StageSets.PLAYER_MENU
var LockedIn = false

var OFFSETS = {
	"Kill" = Vector2(63,20),
	"Bep" = Vector2(132,20),
	"SSStyle" = Vector2(200,20),
	"NOMERCY" = Vector2(224,20)
}

enum PlayerPos {
	Kill,
	Bep,
	SSStyle,
	Nomercy
}

var PlayerSel = PlayerPos.Kill

func _ready() -> void:
	UnJsonify()
	print(enemies_json["Filfth"]["Health"])

	mainControl = $Camera2D/Control
	cage = $Cage
	label = $Camera2D/Text
	player = $CharacterBody2D

	# label.Text = ""

	cage.CagePosition = DEFAULT_CAGE[0]
	cage.CageSize = DEFAULT_CAGE[1]

func UnJsonify() -> Dictionary: 
	var file = FileAccess.open(enemies_json_path, FileAccess.READ)
	var json = file.get_as_text()
	var jsonObj = JSON.new()
	jsonObj.parse(json)
	enemies_json = jsonObj.data
	return enemies_json

func get_input(_delta) -> void:
	if not LockedIn:
		match PlayerSel:
			PlayerPos.Kill:
				player.MenuPos = mainControl.position + OFFSETS["Kill"]
				mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,0,1)
				if Input.is_action_just_pressed("Left"):
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,0)
					PlayerSel = 3 as PlayerPos
				if Input.is_action_just_pressed("Right"):
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,0)
					PlayerSel = PlayerSel + 1 as PlayerPos
			PlayerPos.Bep:
				player.MenuPos = mainControl.position + OFFSETS["Bep"]
				mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,0,1)
				if Input.is_action_just_pressed("Left"):
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,0)
					PlayerSel = PlayerSel - 1 as PlayerPos
				if Input.is_action_just_pressed("Right"):
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,0)
					PlayerSel = PlayerSel + 1 as PlayerPos
			PlayerPos.SSStyle:
				player.MenuPos = mainControl.position + OFFSETS["SSStyle"]
				mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,0,1)
				if Input.is_action_just_pressed("Left"):
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,0)
					PlayerSel = PlayerSel - 1 as PlayerPos
				if Input.is_action_just_pressed("Right"):
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,0)
					PlayerSel = PlayerSel + 1 as PlayerPos
			PlayerPos.Nomercy:
				player.MenuPos = mainControl.position + OFFSETS["NOMERCY"]
				mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,0,1)
				if Input.is_action_just_pressed("Left"):
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,0)
					PlayerSel = PlayerSel - 1 as PlayerPos
				if Input.is_action_just_pressed("Right"):
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,0)
					PlayerSel = PlayerSel + 1 as PlayerPos
			_:
				PlayerSel = PlayerPos.Kill
	if not LockedIn:
		if Input.is_action_just_pressed("Up"):
			LockedIn = true
			player.MenuPos += Vector2(0,-10)
			mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(0,0,1)
	if LockedIn and Input.is_action_just_pressed("Down"):
		LockedIn = false

func _physics_process(delta):
	if StageSet == StageSets.PLAYER_MENU:
		get_input(delta)
	mainControl.position = cage.CagePosition - cage.CageSize / 2 * Vector2(1,-1)
	label.position = cage.CagePosition - cage.CageSize / 2 + Vector2(10,5)
