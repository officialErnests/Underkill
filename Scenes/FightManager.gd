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
var optionSize = 1
var time = 0
var LastStage = StageSets.ENEMY_ATTACK
var first = false
var higlightEnemy = false
var offsety = 0
var textReaveal = 0
var prevText = ""
var diolString = ""

var LoadedWepons = []
var WeponRecharge = []
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

var weponMap = []

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
var optOptions = 0

var attackEnemies = [
	"Filfth",
	"Filfth",
	"Filfth",
	"Filfth"
]
var allEnemies = []

var ENEMY_INTRO = 1.0
var enemyIntro = 0
var enemyAttack = 0
var ENEMY_ATTACK_TIME = 5
var PlayerSel = PlayerPos.Kill


func _ready() -> void:
	UnJsonify()

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
				"MaxHp" = enemies_json[enemy]["Health"],
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
	for weponName in players_json["Equiped"]:
		LoadedWepons.append(players_json["Items"][weponName])
		WeponRecharge.append(0)

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
	match StageSet:
		StageSets.PLAYER_ATTACK:#Litraly has to be before "if StageSet == StageSets.PLAYER_MENU:" or shit breaks XD
			InputPlayerAttack()
		StageSets.PLAYER_MENU:
			InputPlayerMenu()
		StageSets.ADVANCED_OPTIONS:
			InputAdvancedOptions()
		StageSets.OPTION_TEXT:
			InputOptionText()


func InputPlayerMenu() -> void:
	PlayerMenuMove()
	if Input.is_action_just_pressed("Jump") and not GetStageChange():
		mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,0,1)
		StageSet = StageSets.ADVANCED_OPTIONS


func InputAdvancedOptions() -> void:
	match PlayerSel:
			PlayerPos.Kill:
				if GetStageChange():
					higlightEnemy = false
					var namesOfEnemies = []
					for enemie in allEnemies:
						namesOfEnemies.append(enemie["Name"])
					DisplayDiologue(namesOfEnemies)
					optionSize = allEnemies.size()
				elif Input.is_action_just_pressed("Jump"):
						StageSet = StageSets.OPTION_TEXT
				if Input.is_action_just_pressed("Dash"):
					StageSet = StageSets.PLAYER_MENU
			PlayerPos.Bep:
				if GetStageChange():
					higlightEnemy = false
					var namesOfEnemies = []
					for enemie in allEnemies:
						namesOfEnemies.append(enemie["Name"])
					DisplayDiologue(namesOfEnemies)
					optionSize = allEnemies.size()
				elif Input.is_action_just_pressed("Jump"):
					StageSet = StageSets.OPTION_TEXT
				if Input.is_action_just_pressed("Dash"):
					StageSet = StageSets.PLAYER_MENU
			PlayerPos.SSStyle:
				if GetStageChange():
					higlightEnemy = false
					var namesOfEnemies = []
					for enemie in allEnemies:
						namesOfEnemies.append(enemie["Name"])
					DisplayDiologue(namesOfEnemies)
					optionSize = allEnemies.size()
				elif Input.is_action_just_pressed("Jump"):
						StageSet = StageSets.OPTION_TEXT
				if Input.is_action_just_pressed("Dash"):
					StageSet = StageSets.PLAYER_MENU
			PlayerPos.Nomercy:
				if GetStageChange():
					DisplayDiologue(["You sure u want to use railcannon?"])
					optionSize = 1
				else:
					if Input.is_action_just_pressed("Jump"):
						StageSet = StageSets.OPTION_TEXT
				if Input.is_action_just_pressed("Dash"):
					StageSet = StageSets.PLAYER_MENU
			_:
				if GetStageChange():
					DisplayDiologue(["Well...", "Game broke XD"])
					optionSize = 2
				if Input.is_action_just_pressed("Dash"):
					PlayerSel = PlayerPos.Nomercy


func InputOptionText() -> void:
	match PlayerSel:
		PlayerPos.Kill:
			if GetStageChange():
				higlightEnemy = true
				optionSize = 1
				var finalStr = []
				var num = 0
				for wepon in LoadedWepons:
					if wepon["KILL"]:
						weponMap.append(num)
						if WeponRecharge[num] > 0:
							finalStr.append("[" + "#".repeat(WeponRecharge[num]) + "]" + wepon["KILL"]["Name"])
						else:
							finalStr.append(wepon["KILL"]["Name"])
					num += 1
				DisplayDiologue(finalStr)
			else:
				if Input.is_action_just_pressed("Jump"):
					StageSet = StageSets.PLAYER_ATTACK
			if Input.is_action_just_pressed("Dash"):
				StageSet = StageSets.ADVANCED_OPTIONS
		PlayerPos.Bep:
			if GetStageChange():
				higlightEnemy = true
				DisplayDiologue(allEnemies[advOptions]["Interactions"])
				optionSize = allEnemies[advOptions]["Interactions"].size()
			else:
				if Input.is_action_just_pressed("Jump"):
					StageSet = StageSets.PLAYER_ATTACK
			if Input.is_action_just_pressed("Dash"):
				StageSet = StageSets.ADVANCED_OPTIONS
		PlayerPos.SSStyle:
			if GetStageChange():
				higlightEnemy = true
				optionSize = 1
				var finalStr = []
				var num = 0
				for wepon in LoadedWepons:
					if wepon["SSSTYLE"]:
						weponMap.append(num)
						if WeponRecharge[num] > 0:
							finalStr.append("[" + "#".repeat(WeponRecharge[num]) + "]" + wepon["SSSTYLE"]["Name"])
						else:
							finalStr.append(wepon["SSSTYLE"]["Name"])
					num += 1
				DisplayDiologue(finalStr)
			else:
				if Input.is_action_just_pressed("Jump"):
					StageSet = StageSets.PLAYER_ATTACK
			if Input.is_action_just_pressed("Dash"):
				StageSet = StageSets.ADVANCED_OPTIONS
		PlayerPos.Nomercy:
			optionSize = 1
			if GetStageChange():
				DisplayDiologue(["You are really sure?"])
			else:
				if Input.is_action_just_pressed("Jump"):
					StageSet = StageSets.PLAYER_ATTACK
			if Input.is_action_just_pressed("Dash"):
				StageSet = StageSets.ADVANCED_OPTIONS
		_:
			if Input.is_action_just_pressed("Dash"):
				PlayerSel = PlayerPos.Kill


func InputPlayerAttack() -> void:
	if not GetStageChange(): #debounces jump input
		if Input.is_action_just_pressed("Jump"): #I am god at commenting my code B)
				StageSet = StageSets.ENEMY_ATTACK
				enemyIntro = ENEMY_INTRO
	else:
		match PlayerSel:
				PlayerPos.Kill:
					if WeponRecharge[weponMap[optOptions]] > 0:
						DisplayDiologue(["As you tried that",
										"you relised you had cooldown",
										"You must feel stupid :skull:"])
					else:
						if LoadedWepons[weponMap[optOptions]]["KILL"]["Chance"] >= randf_range(0,100):
							DisplayDiologue(LoadedWepons[weponMap[optOptions]]["KILL"]["Succes"]["Messages"].pick_random())
							WeponRecharge[weponMap[optOptions]] = LoadedWepons[weponMap[optOptions]]["KILL"]["Succes"]["Cooldown"]
						else:
							DisplayDiologue(LoadedWepons[weponMap[optOptions]]["KILL"]["Fail"]["Messages"].pick_random())
							WeponRecharge[weponMap[optOptions]] = LoadedWepons[weponMap[optOptions]]["KILL"]["Fail"]["Cooldown"]
				PlayerPos.Bep:
					DisplayDiologue(allEnemies[advOptions]["Interactions"][allEnemies[advOptions]["Interactions"].keys()[optOptions]].pick_random())
				PlayerPos.SSStyle:
					if WeponRecharge[weponMap[optOptions]] > 0:
						DisplayDiologue(["As you tried that", 
										"you relised you had cooldown",
										"No styling onthem ig :<"])
					else:
						if LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Chance"] >= randf_range(0,100):
							DisplayDiologue(LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Succes"]["Messages"].pick_random())
							WeponRecharge[weponMap[optOptions]] = LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Succes"]["Cooldown"]
						else:
							DisplayDiologue(LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Fail"]["Messages"].pick_random())
							WeponRecharge[weponMap[optOptions]] = LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Fail"]["Cooldown"]
				PlayerPos.Nomercy:
					mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(0.1,0.1,1.1)
					disableNoMercy = true
					DisplayDiologue(["YOU USED THE RAILCANON",
									"ENEMIES ARE TOTALY VAPORIZED",
									"you can say they got...",
									"railed",
									"I'm so funny ;u;"])


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
	diolString = ""
	for line in diol:
		diolString += "* " + line + "\n"
	if prevText != diolString:
		textReaveal = 0

func UpdtDiologue(delta) -> void:
	textReaveal += delta * 100
	label.text = diolString.substr(0,min(floor(textReaveal),diolString.length()))

func NavigateAdvOptions() -> void:
	if Input.is_action_just_pressed("Up"):
		advOptions -= 1
	if Input.is_action_just_pressed("Down"):
		advOptions += 1
	advOptions = (advOptions + optionSize)% optionSize
	player.MenuPos = cage.CagePosition - cage.CageSize / 2 + Vector2(10,5) + Vector2(3,8) + Vector2(0,19) * advOptions

func NavigateOptions() -> void:
	if Input.is_action_just_pressed("Up"):
		optOptions -= 1
	if Input.is_action_just_pressed("Down"):
		optOptions += 1
	optOptions = (optOptions + optionSize)% optionSize
	player.MenuPos = cage.CagePosition - cage.CageSize / 2 + Vector2(10,5) + Vector2(3,8) + Vector2(0,19) * optOptions

func UpdateEnemi(delta, color, size, position2) -> void:
	enemySpawnNode.scale += (size - enemySpawnNode.scale) * delta
	enemySpawnNode.modulate += (color - enemySpawnNode.modulate) * delta
	enemySpawnNode.position += (position2 - enemySpawnNode.position) * delta
	var indx = 0
	for enemy in allEnemies:
		var offset = enemy["Offset"]
		if higlightEnemy and indx == advOptions:
			enemy["Body"].modulate += (Color(1,0.0,0.0) - enemy["Body"].modulate) * delta * 10
		else:
			enemy["Body"].modulate += (Color(1,1,1) - enemy["Body"].modulate) * delta * 10
		enemy["Body"].get_child(0).position = Vector2(cos(time*2+offset) * 3 + cos(time*2+offset) * 10, cos(time*3+offset) * 3 + sin(time+offset) * 10)
		enemy["Body"].get_child(1).position = Vector2(cos(time*2+offset) * 10, sin(time+offset) * 10)
		indx += 1

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

func GetStageChange() -> bool:
	return LastStage != StageSet

func _physics_process(delta):
	UpdtDiologue(delta)
	time += delta
	if first:
		print(StageSets.find_key(StageSet))
		LastStage = StageSet
	first = LastStage != StageSet

	if StageSet == StageSets.PLAYER_MENU:
		get_input(delta)
		UpdateEnemi(delta, Color(1,1,1), Vector2(1,1), Vector2(0,-10))
		UpdateCage(delta, "DEFAULT_CAGE", 2)
		player.PlayerDoge = false
		if GetStageChange():
			SwitchGui(GuiStages.OPTIONS)
			DisplayDiologue(allEnemies.pick_random()["Intro"].pick_random())
	elif StageSet == StageSets.ADVANCED_OPTIONS:
		get_input(delta)
		UpdateCage(delta, "DEFAULT_CAGE", 2)
		UpdateEnemi(delta, Color(1,1,1), Vector2(1.1,1.2), Vector2(0,0))
		NavigateAdvOptions()
	elif StageSet == StageSets.OPTION_TEXT:
		get_input(delta)
		UpdateCage(delta, "DEFAULT_CAGE", 2)
		UpdateEnemi(delta, Color(1,1,1), Vector2(1.5,1.5), Vector2(0,50))
		NavigateOptions()
	elif StageSet == StageSets.PLAYER_ATTACK:
		player.MenuPos = Vector2(400,0)
		UpdateEnemi(delta, Color(1,1,1), Vector2(1.6,1.6), Vector2(0,70))
		get_input(delta)
		UpdateCage(delta, "DIOLOGUE_CAGE", 2)
		SwitchGui(GuiStages.TEXT)
	elif StageSet == StageSets.ENEMY_ATTACK:
		UpdateEnemi(delta, Color(0.2,0.2,0.2), Vector2(0.7,0.7), Vector2(0,-70))
		if enemyIntro > 0 or GetStageChange():
			if GetStageChange():
				SwitchGui(GuiStages.BATTLE)
				RecenterPlayer()
				higlightEnemy = false
			UpdateCage(delta, "CAGE_SMALL", 5)
			enemyIntro -= delta
			enemyAttack = 0
		else:
			if ENEMY_ATTACK_TIME < enemyAttack:
				StageSet = StageSets.PLAYER_MENU
				#Now lets comment the most understandable part of the code (i wish this was a joke [this dosn't imply i will comment my code tho XD])
				for wep in range(WeponRecharge.size()):
					if WeponRecharge[wep] > 0:
						WeponRecharge[wep] -= 1
			enemyAttack += delta
			SetCageSize("CAGE_SMALL")

			
