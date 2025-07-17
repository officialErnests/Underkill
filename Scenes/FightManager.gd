extends Node2D

var enemies_json_path = "res://Assets//Charecters//Enemies//Enemies.json"
var enemi_folder_path = "res://Assets//Charecters//Enemies//"
var enemies_json: Dictionary = {}
var enemySpawnNode

var mainControl : Control
var label : Label
var cage : Node2D
var player : CharacterBody2D

var disableNoMercy = false
var StageSet = StageSets.PLAYER_MENU
var LockedIn = false


enum StageSets {
	ENEMY_ATTACK,
	PLAYER_ATTACK,
	PLAYER_MENU,
	ADVANCED_OPTIONS
}
enum PlayerPos {
	Kill,
	Bep,
	SSStyle,
	Nomercy
}

var CageSizes = {
	"DEFAULT_CAGE" = [
		Vector2(0,70),
		Vector2(287,140)],
	"DIOLOGUE_CAGE" = [
		Vector2(0,90),
		Vector2(300,170)],
	"CAGE_SMALL" = [
		Vector2(0,0),
		Vector2(200,200)
	]
}

var OFFSETS = {
	"Kill" = Vector2(63,20),
	"Bep" = Vector2(132,20),
	"SSStyle" = Vector2(200,20),
	"NOMERCY" = Vector2(224,20)
}

var ADVANCED_OFFSET = Vector2(5,5)
var advOptions = 0

var attackEnemies = [
	"Filfth",
	"Filfth",
	"Filfth"
]
var allEnemies = []

var ENEMY_INTRO = 1.0
var enemyIntro = 0
var StageChanged = true
var enemyAttack = 0
var ENEMY_ATTACK_TIME = 10
var PlayerSel = PlayerPos.Kill

func _ready() -> void:
	UnJsonify()
	print(enemies_json["Filfth"]["Health"])

	mainControl = $Camera2D/Control
	cage = $Cage
	label = $Camera2D/Text
	player = $CharacterBody2D
	enemySpawnNode = $Enemies

	# label.Text = ""


	var totalWidth = 0
	for enemy in attackEnemies:
		if enemies_json[enemy]:
			var TempEnemy = {
				"Name" = enemy,
				"Health" = enemies_json[enemy]["Health"],
				"Damage" = enemies_json[enemy]["Damage"],
				"Body" = load(enemi_folder_path + enemies_json[enemy]["Body"] + ".tscn").instantiate(),
				"Width" = enemies_json[enemy]["Width"],
				"Intro" = enemies_json[enemy]["Intro"],
				"Interactions" = enemies_json[enemy]["Interactions"]
			}
			enemySpawnNode.add_child(TempEnemy["Body"])
			TempEnemy["Body"].position = Vector2(0,0)
			totalWidth += TempEnemy["Width"]/2
			allEnemies.append(TempEnemy)

	for enemy in allEnemies:
		totalWidth -= enemy["Width"]
		enemy["Body"].position = Vector2(totalWidth + enemy["Width"]/2,0)

			

func UnJsonify() -> Dictionary: 
	var file = FileAccess.open(enemies_json_path, FileAccess.READ)
	var json = file.get_as_text()
	var jsonObj = JSON.new()
	jsonObj.parse(json)
	enemies_json = jsonObj.data
	return enemies_json

func get_input(_delta) -> void:
	if StageSet == StageSets.PLAYER_ATTACK:#Litraly has to be before "if StageSet == StageSets.PLAYER_MENU:" or shit breaks XD
		if not StageChanged:
			if Input.is_action_just_pressed("Jump"): #I am god at commenting my code B)
				StageSet = StageSets.ENEMY_ATTACK
				enemyIntro = ENEMY_INTRO
				StageChanged = true
		else:
			StageChanged = false
	if StageSet == StageSets.PLAYER_MENU:
		if not LockedIn:
			match PlayerSel:
				PlayerPos.Kill:
					player.MenuPos = mainControl.position + OFFSETS["Kill"]
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1, 0)
					if Input.is_action_just_pressed("Left"):
						mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
						if disableNoMercy:
							PlayerSel = 2 as PlayerPos
						else:
							PlayerSel = 3 as PlayerPos
					if Input.is_action_just_pressed("Right"):
						mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
						PlayerSel = PlayerSel + 1 as PlayerPos
				PlayerPos.Bep:
					player.MenuPos = mainControl.position + OFFSETS["Bep"]
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1, 0)
					if Input.is_action_just_pressed("Left"):
						mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
						PlayerSel = PlayerSel - 1 as PlayerPos
					if Input.is_action_just_pressed("Right"):
						mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
						PlayerSel = PlayerSel + 1 as PlayerPos
				PlayerPos.SSStyle:
					player.MenuPos = mainControl.position + OFFSETS["SSStyle"]
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1, 0)
					if Input.is_action_just_pressed("Left"):
						mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
						PlayerSel = PlayerSel - 1 as PlayerPos
					if Input.is_action_just_pressed("Right"):
						mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
						if disableNoMercy:
							PlayerSel = 0 as PlayerPos
						else:
							PlayerSel = PlayerSel + 1 as PlayerPos
				PlayerPos.Nomercy:
					player.MenuPos = mainControl.position + OFFSETS["NOMERCY"]
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1, 0)
					if Input.is_action_just_pressed("Left"):
						mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
						PlayerSel = PlayerSel - 1 as PlayerPos
					if Input.is_action_just_pressed("Right"):
						mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
						PlayerSel = PlayerSel + 1 as PlayerPos
				_:
					PlayerSel = PlayerPos.Kill
		if not LockedIn:
			if Input.is_action_just_pressed("Up"):
				LockedIn = true
				player.MenuPos += Vector2(0,-10)
				mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,0,1)
				if PlayerSel == PlayerPos.Kill:
					StageChanged = true
					StageSet = StageSets.ADVANCED_OPTIONS
				if PlayerSel == PlayerPos.Bep:
					StageChanged = true
					StageSet = StageSets.ADVANCED_OPTIONS
				if PlayerSel == PlayerPos.SSStyle:
					StageChanged = true
					StageSet = StageSets.ADVANCED_OPTIONS
				if PlayerSel == PlayerPos.Nomercy:
					LockedIn = false
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(0.1,0.1,1.1)
					disableNoMercy = true
					PlayerSel = PlayerPos.Kill
					StageChanged = true
					StageSet = StageSets.ADVANCED_OPTIONS
	if StageSet == StageSets.ADVANCED_OPTIONS:
		match PlayerSel:
			PlayerPos.Kill:
				if StageChanged:
					StageChanged = false
					DisplayDiologue(["Punch", "Kick", "Shoot"])
				advOptions = min(max(advOptions,0),2)
				if Input.is_action_just_pressed("Dash"):
					StageSet = StageSets.PLAYER_MENU
					LockedIn = false
					StageChanged = true
				if Input.is_action_just_pressed("Jump"):
					StageSet = StageSets.PLAYER_ATTACK
					StageChanged = true
			PlayerPos.Bep:
				if StageChanged:
					StageChanged = false
					var namesOfEnemies = []
					for enemie in allEnemies:
						namesOfEnemies.append(enemie["Name"])
					DisplayDiologue(namesOfEnemies)
				advOptions = min(max(advOptions,0),allEnemies.size()-1)
				if Input.is_action_just_pressed("back"):
					PlayerSel = PlayerPos.Kill
			PlayerPos.SSStyle:
				if StageChanged:
					StageChanged = false
					DisplayDiologue(["Well...", "Game broke XD"])
				advOptions = min(max(advOptions,0),1)
				if Input.is_action_just_pressed("back"):
					PlayerSel = PlayerPos.Kill
			PlayerPos.Nomercy:
				if StageChanged:
					StageChanged = false
					DisplayDiologue(["Well...", "Game broke XD"])
				advOptions = min(max(advOptions,0),1)
				if Input.is_action_just_pressed("back"):
					PlayerSel = PlayerPos.Kill
			_:
				if StageChanged:
					StageChanged = false
					DisplayDiologue(["Well...", "Game broke XD"])
				if Input.is_action_just_pressed("back"):
					PlayerSel = PlayerPos.Kill


func UpdateCage(delta, cageSet, speed) -> void:
	cage.CagePosition += (CageSizes[cageSet][0] - cage.CagePosition) * delta * speed
	cage.CageSize += (CageSizes[cageSet][1] - cage.CageSize) * delta * speed
	UpdateGuiPos()

func SetCageSize(cageSet) -> void:
	cage.CagePosition = CageSizes[cageSet][0]
	cage.CageSize = CageSizes[cageSet][1]
	UpdateGuiPos()

func UpdateGuiPos() -> void:
	mainControl.position = cage.CagePosition - cage.CageSize / 2 * Vector2(1,-1)
	label.position = cage.CagePosition - cage.CageSize / 2 + Vector2(10,5)

func DisplayDiologue(diol) -> void:
	var finalStr = ""
	for line in diol:
		finalStr += "* " + line + "\n"
	label.text = finalStr

func _physics_process(delta):
	if StageSet == StageSets.ADVANCED_OPTIONS:
		get_input(delta)
		UpdateCage(delta, "DEFAULT_CAGE", 2)
		player.MenuPos = cage.CagePosition - cage.CageSize / 2 + Vector2(10,5) + Vector2(3,8) + Vector2(0,19) * advOptions
		if Input.is_action_just_pressed("Up"):
			advOptions -= 1
		if Input.is_action_just_pressed("Down"):
			advOptions += 1
	if StageSet == StageSets.PLAYER_MENU:
		enemySpawnNode.scale += (Vector2(1,1) - enemySpawnNode.scale) * delta
		enemySpawnNode.modulate += (Color(1,1,1) - enemySpawnNode.modulate) * delta
		get_input(delta)
		UpdateCage(delta, "DEFAULT_CAGE", 2)
		mainControl.get_child(0).visible = false
		mainControl.get_child(1).visible = true
		player.PlayerDoge = false
		label.visible = true
		if StageChanged:
			DisplayDiologue(allEnemies.pick_random()["Intro"].pick_random())
			StageChanged = false
	if StageSet == StageSets.PLAYER_ATTACK:
		player.MenuPos = Vector2(400,0)
		get_input(delta)
		UpdateCage(delta, "DIOLOGUE_CAGE", 2)
		mainControl.get_child(1).visible = false
		DisplayDiologue(["You used railcanon","It missed","You realised your aim sucks"])
	if StageSet == StageSets.ENEMY_ATTACK:
		mainControl.get_child(0).visible = true
		label.visible = false
		enemySpawnNode.modulate += (Color(0.2,0.2,0.2) - enemySpawnNode.modulate) * delta
		enemySpawnNode.scale += (Vector2(0.7,0.7) - enemySpawnNode.scale) * delta
		if enemyIntro > 0:
			enemyIntro -= delta
			UpdateCage(delta, "CAGE_SMALL", 5)
			if StageChanged:
				player.PlayerDoge = true
				player.MenuPos = cage.CagePosition
				player.position = cage.CagePosition
				StageChanged = false
		else:
			enemyAttack += delta
			SetCageSize("CAGE_SMALL")
			if ENEMY_ATTACK_TIME < enemyAttack:
				StageChanged = true
				StageSet = StageSets.PLAYER_MENU

			
