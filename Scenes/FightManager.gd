extends Node2D

var enemies_json_path = "res://Assets//Charecters//Enemies//Enemies.json"
var enemi_folder_path = "res://Assets//Charecters//Enemies//"
var enemies_json: Dictionary = {}
var enemySpawnNode

var players_json_path = "res://Assets//Charecters//Player//diologue.json"
var players_json: Dictionary = {}

var mainControl : Control
var label : Label
var cage : Node2D
var player : CharacterBody2D

var disableNoMercy = false
var StageSet = StageSets.PLAYER_MENU
var optionSize = 0
var time = 0

enum StageSets {
	ENEMY_ATTACK,
	PLAYER_ATTACK,
	PLAYER_MENU,
	ADVANCED_OPTIONS,
	OPTION_TEXT
}
enum PlayerPos {
	Kill,
	Bep,
	SSStyle,
	Nomercy
}
enum GuiStages {
	OPTIONS,
	TEXT,
	BATTLE
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

var OFFSETS = [
	Vector2(63,20),
	Vector2(132,20),
	Vector2(200,20),
	Vector2(224,20)
]

var ADVANCED_OFFSET = Vector2(5,5)
var advOptions = 0

var attackEnemies = [
	"Filfth",
	"Filfth",
	"Filfth",
	"Filfth",
	"Filfth",
	"Filfth",
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
	var offseter = 0
	for enemy in attackEnemies:
		if enemies_json[enemy]:
			var TempEnemy = {
				"Name" = enemy,
				"Health" = enemies_json[enemy]["Health"],
				"Damage" = enemies_json[enemy]["Damage"],
				"Body" = load(enemi_folder_path + enemies_json[enemy]["Body"] + ".tscn").instantiate(),
				"Width" = enemies_json[enemy]["Width"],
				"Intro" = enemies_json[enemy]["Intro"],
				"Interactions" = enemies_json[enemy]["Interactions"],
				"Offset" = offseter
			}
			offseter += 0.3
			enemySpawnNode.add_child(TempEnemy["Body"])
			TempEnemy["Body"].position = Vector2(0,0)
			totalWidth += TempEnemy["Width"]/2
			allEnemies.append(TempEnemy)

	for enemy in allEnemies:
		totalWidth -= enemy["Width"]
		enemy["Body"].position = Vector2(totalWidth + enemy["Width"]/2,0)

			

func UnJsonify() -> void: 
	var file = FileAccess.open(enemies_json_path, FileAccess.READ)
	var json = file.get_as_text()
	var jsonObj = JSON.new()
	jsonObj.parse(json)
	enemies_json = jsonObj.data

	var file2 = FileAccess.open(players_json_path, FileAccess.READ)
	var json2 = file2.get_as_text()
	var jsonObj2 = JSON.new()
	jsonObj2.parse(json2)
	players_json = jsonObj2.data

func get_input(_delta) -> void:
	if StageSet == StageSets.PLAYER_ATTACK:#Litraly has to be before "if StageSet == StageSets.PLAYER_MENU:" or shit breaks XD
		InputPlayerAttack()
	if StageSet == StageSets.PLAYER_MENU:
		InputPlayerMenu()
	if StageSet == StageSets.ADVANCED_OPTIONS:
		InputAdvancedOptions()
	if StageSet == StageSets.OPTION_TEXT:
		InputOptionText()

func InputPlayerAttack() -> void:
	if not StageChanged: #debounces jump input
		if Input.is_action_just_pressed("Jump"): #I am god at commenting my code B)
				StageSet = StageSets.ENEMY_ATTACK
				enemyIntro = ENEMY_INTRO
				StageChanged = true
	else:
		StageChanged = false

func InputPlayerMenu() -> void:
	PlayerMenuMove()
	if Input.is_action_just_pressed("Jump"):
		mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,0,1)
		StageSet = StageSets.ADVANCED_OPTIONS
		StageChanged = true
		if PlayerSel == PlayerPos.Nomercy:
			mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(0.1,0.1,1.1)
			disableNoMercy = true
			PlayerSel = PlayerPos.Nomercy

func InputAdvancedOptions() -> void:
	match PlayerSel:
			PlayerPos.Kill:
				optionSize = 3
				if Input.is_action_just_pressed("Dash"):
					StageSet = StageSets.PLAYER_MENU
					StageChanged = true
				if StageChanged:
					StageChanged = false
					DisplayDiologue(["Punch", "Kick", "Shoot"])
				else:
					if Input.is_action_just_pressed("Jump"):
						StageSet = StageSets.OPTION_TEXT
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

func InputOptionText() -> void:
	match PlayerSel:
		PlayerPos.Kill:
			if StageChanged:
				optionSize = 1
				DisplayDiologue(["AGHGHGH"])
				StageChanged = false
			else:
				if Input.is_action_just_pressed("Jump"):
					StageChanged = true
					enemyIntro = ENEMY_INTRO
					StageSet = StageSets.ENEMY_ATTACK
		PlayerPos.Bep:
			if Input.is_action_just_pressed("back"):
				PlayerSel = PlayerPos.Kill
			if StageChanged:
				StageChanged = false
				var namesOfEnemies = []
				for enemie in allEnemies:
					namesOfEnemies.append(enemie["Name"])
				DisplayDiologue(namesOfEnemies)
				optionSize = allEnemies.size()
		PlayerPos.SSStyle:
			optionSize = 2
			if Input.is_action_just_pressed("back"):
				PlayerSel = PlayerPos.Kill
			if StageChanged:
				StageChanged = false
				DisplayDiologue(["Well...", "Game broke XD"])
		PlayerPos.Nomercy:
			optionSize = 2
			if Input.is_action_just_pressed("back"):
				PlayerSel = PlayerPos.Kill
			if StageChanged:
				StageChanged = false
				DisplayDiologue(["Well...", "Game broke XD"])
		_:
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

func NavigateOptions() -> void:
	if Input.is_action_just_pressed("Up"):
		advOptions -= 1
	if Input.is_action_just_pressed("Down"):
		advOptions += 1
	advOptions = (advOptions + optionSize)% optionSize
	player.MenuPos = cage.CagePosition - cage.CageSize / 2 + Vector2(10,5) + Vector2(3,8) + Vector2(0,19) * advOptions

func UpdateEnemi(delta, color, size) -> void:
	enemySpawnNode.scale += (size - enemySpawnNode.scale) * delta
	enemySpawnNode.modulate += (color - enemySpawnNode.modulate) * delta
	for enemy in allEnemies:
		var offset = enemy["Offset"]
		enemy["Body"].get_child(0).position = Vector2(cos(time*2+offset) * 3 + cos(time*2+offset) * 10, cos(time*3+offset) * 3 + sin(time+offset) * 10)
		enemy["Body"].get_child(1).position = Vector2(cos(time*2+offset) * 10, sin(time+offset) * 10)

func RecenterPlayer() -> void:
	player.PlayerDoge = true
	player.MenuPos = cage.CagePosition
	player.position = cage.CagePosition

func PlayerMenuMove() -> void:
	player.MenuPos = mainControl.position + OFFSETS[PlayerSel as int]
	mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1, 0)
	if Input.is_action_just_pressed("Left"):
		mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
		PlayerSel = PlayerSel - 1 as PlayerPos
		if PlayerSel < 0:
			if disableNoMercy:
				PlayerSel = 2 as PlayerPos
			else:
				PlayerSel = 3 as PlayerPos
	if Input.is_action_just_pressed("Right"):
		mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
		PlayerSel = PlayerSel + 1 as PlayerPos
		if disableNoMercy and PlayerSel > 4:
			PlayerSel = 0 as PlayerPos
		elif not disableNoMercy and PlayerSel > 3:
			PlayerSel = 0 as PlayerPos

func SwitchGui(Battle) -> void:
	match Battle:
		GuiStages.OPTIONS:
			mainControl.get_child(0).visible = false
			mainControl.get_child(1).visible = true
			label.visible = true
		GuiStages.TEXT:
			mainControl.get_child(0).visible = false
			mainControl.get_child(1).visible = false
			label.visible = true
		GuiStages.BATTLE:
			mainControl.get_child(0).visible = true
			mainControl.get_child(1).visible = false
			label.visible = false
		_:
			mainControl.get_child(0).visible = false
			mainControl.get_child(1).visible = true
			label.visible = true


func _physics_process(delta):
	time += delta
	
	if StageSet == StageSets.PLAYER_MENU:
		if StageChanged:
			SwitchGui(GuiStages.OPTIONS)
			DisplayDiologue(allEnemies.pick_random()["Intro"].pick_random())
			StageChanged = false
		get_input(delta)
		UpdateEnemi(delta, Color(1,1,1), Vector2(1,1))
		UpdateCage(delta, "DEFAULT_CAGE", 2)
		player.PlayerDoge = false
	elif StageSet == StageSets.ADVANCED_OPTIONS:
		if StageChanged:
			StageChanged = false
		get_input(delta)
		UpdateCage(delta, "DEFAULT_CAGE", 2)
		UpdateEnemi(delta, Color(1,1,1), Vector2(1.1,1.1))
		NavigateOptions()
	elif StageSet == StageSets.OPTION_TEXT:
		if StageChanged:
			StageChanged = false
		get_input(delta)
		UpdateCage(delta, "DEFAULT_CAGE", 2)
		UpdateEnemi(delta, Color(1,1,1), Vector2(1.2,1.2))
		NavigateOptions()
	elif StageSet == StageSets.PLAYER_ATTACK:
		if StageChanged:
			StageChanged = false
		player.MenuPos = Vector2(400,0)
		get_input(delta)
		UpdateCage(delta, "DIOLOGUE_CAGE", 2)
		SwitchGui(GuiStages.TEXT)
		DisplayDiologue(["You used railcanon","It missed","You realised your aim sucks"])
	elif StageSet == StageSets.ENEMY_ATTACK:
		UpdateEnemi(delta, Color(0.2,0.2,0.2), Vector2(0.7,0.7))
		if enemyIntro > 0 or StageChanged:
			if StageChanged:
				SwitchGui(GuiStages.BATTLE)
				RecenterPlayer()
				StageChanged = false
			UpdateCage(delta, "CAGE_SMALL", 5)
			enemyIntro -= delta
		else:
			if ENEMY_ATTACK_TIME < enemyAttack:
				StageChanged = true
				StageSet = StageSets.PLAYER_MENU
			enemyAttack += delta
			SetCageSize("CAGE_SMALL")

			
