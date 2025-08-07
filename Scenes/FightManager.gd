extends Node2D

var enemies_json_path = "res://Assets//Charecters//Enemies//Enemies.json"
var enemi_folder_path = "res://Assets//Charecters//Enemies//"
var enemies_json: Dictionary = {}
var enemySpawnNode

var player_effect_path = "res://Assets//Charecters//Player//Effects//"
var players_json_path = "res://Assets//Charecters//Player//diologue.json"
var players_json: Dictionary = {}

var dmgNumb = preload("res://Assets//Others//damage.tscn")
var mainControl : Control
var label : Label
var cage : Node2D
var player : CharacterBody2D
var health : Label
var bullets : Node2D

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
var attackStage = 7
var attackAnim = 0
var attackDmg = 0
var loadEffectString = ""
var loadedEffect = []
var allKilled = []
var fightRewards = 0
var attackRange = 0
var dmgNumbers = []
var skipAttack = false
var optOptionsLast = 0
var advOptionsLast = 0
var playersPrevHp = Global.player_health
# 0-enemy 1-attack
var attacks = []
var attackCage = "CAGE_SMALL"
var nomercyColldown = 0
const random_numbers = [-1,1]
var LoadedWepons = []
var WeponRecharge = []
enum StageSets {
	ENEMY_ATTACK,
	PLAYER_MENU,
	ADVANCED_OPTIONS,
	OPTION_TEXT,
	PLAYER_ATTACK,
	VICTORY
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
		Vector2(400,140)],
	"DIOLOGUE_CAGE" = [
		Vector2(0,50),
		Vector2(300,170)],
	"CAGE_EXSMALL" = [
		Vector2(0,0),
		Vector2(250,20)
	],
	"CAGE_SMALL" = [
		Vector2(0,0),
		Vector2(250,150)
	],
	"CAGE_MED" = [
		Vector2(0,0),
		Vector2(400,250)
	],
	"CAGE_BIG" = [
		Vector2(0,0),
		Vector2(600,290)
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

var enemies = [
	["Filfth",1],
	["Stray",2]
]
var attackEnemies = []
var allEnemies = []

var ENEMY_INTRO = 1.0
var enemyIntro = 0
var enemyAttack = 0
var ENEMY_ATTACK_TIME = 1 #TODO 10
var PlayerSel = PlayerPos.Kill
var attackDebounce = []

func _ready() -> void:
	UnJsonify()

	mainControl = $Camera2D/Control
	cage = $Cage
	label = $Camera2D/Text
	health = $Camera2D/Health
	player = $CharacterBody2D
	enemySpawnNode = $Enemies
	bullets = $Bullets

	# label.Text = ""
	Restart()



func Restart():
	StageSet = StageSets.PLAYER_MENU
	optionSize = 1
	time = 0
	LastStage = StageSets.ENEMY_ATTACK
	first = false
	higlightEnemy = false
	offsety = 0
	textReaveal = 0
	prevText = ""
	diolString = ""
	attackStage = 7
	attackAnim = 0
	attackDmg = 0
	loadEffectString = ""
	loadedEffect = []
	# allKilled = []
	# fightRewards = 0
	attackRange = 0
	# dmgNumbers = []
	skipAttack = false
	optOptionsLast = 0
	advOptionsLast = 0
	advOptions = 0
	optOptions = 0
	attackEnemies = []
	ENEMY_INTRO = 1.0
	enemyIntro = 0
	enemyAttack = 0
	ENEMY_ATTACK_TIME = 10
	PlayerSel = PlayerPos.Kill
	attackDebounce = []
	LoadedWepons = []
	WeponRecharge = []
	# playersHealth = 100
	var difficulty = fightRewards / 10.0 + 3
	for i in range(7):
		var randomEnemy = enemies.pick_random()
		attackEnemies.append(randomEnemy[0])
		difficulty -= randomEnemy[1]
		if difficulty <= 0: break
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
				"PosOffset" = 0,
				"Points" = enemies_json[enemy]["Points"],
				"Offset" = offseter,
				"DmgAudio" = enemies_json[enemy]["DmgAudio"],
				"DeathAudio" = enemies_json[enemy]["DeathAudio"],
				"Attacks" = enemies_json[enemy]["Attacks"]
			}
			offseter += 0.3
			enemySpawnNode.add_child(TempEnemy["Body"])
			TempEnemy["Body"].position = Vector2(0,0)
			totalWidth -= TempEnemy["Width"]/2
			allEnemies.append(TempEnemy)

	for enemy in allEnemies:
		totalWidth += enemy["Width"]
		enemy["Body"].position = Vector2(totalWidth - enemy["Width"]/2,0)
		enemy["PosOffset"] = Vector2(totalWidth - enemy["Width"]/2,0)
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
		StageSets.VICTORY:
			InputVictory()


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
					if WeponRecharge[weponMap[optOptions]] <= 0:
						StageSet = StageSets.PLAYER_ATTACK
					else:
						$Cage/Audio/Cant.play()
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
					if WeponRecharge[weponMap[optOptions]] <= 0:
						StageSet = StageSets.PLAYER_ATTACK
					else:
						$Cage/Audio/Cant.play()
			if Input.is_action_just_pressed("Dash"):
				StageSet = StageSets.ADVANCED_OPTIONS
		PlayerPos.Nomercy:
			optionSize = 1
			attackRange = 1
			if GetStageChange():
				higlightEnemy = true
				if nomercyColldown > 0:
					DisplayDiologue(["[" + "#".repeat(nomercyColldown) + "]" + "RAILCANNON"])
				else:
					DisplayDiologue(["RAILCANNON"])
			else:
				if Input.is_action_just_pressed("Jump"):
					if nomercyColldown <= 0:
						StageSet = StageSets.PLAYER_ATTACK
					else:
						$Cage/Audio/Cant.play()
			if Input.is_action_just_pressed("Dash"):
				StageSet = StageSets.ADVANCED_OPTIONS
		_:
			if Input.is_action_just_pressed("Dash"):
				PlayerSel = PlayerPos.Kill


func InputPlayerAttack() -> void:
	match PlayerSel:
			PlayerPos.Kill:
				if GetStageChange():
					if WeponRecharge[weponMap[optOptions]] > 0:
						skipAttack = true
						DisplayDiologue(["As you tried that",
										"you relised you had cooldown",
										"You must feel stupid :skull:"])
					else:
						skipAttack = false
						allEnemies[advOptions]["Body"].get_child(2).visible = true
						if LoadedWepons[weponMap[optOptions]]["KILL"]["Chance"] >= randf_range(0,100):
							DisplayDiologue(LoadedWepons[weponMap[optOptions]]["KILL"]["Succes"]["Messages"].pick_random())
							WeponRecharge[weponMap[optOptions]] = LoadedWepons[weponMap[optOptions]]["KILL"]["Succes"]["Cooldown"]
							attack(LoadedWepons[weponMap[optOptions]]["KILL"]["Succes"]["Damage"], 0, LoadedWepons[weponMap[optOptions]]["KILL"]["Succes"]["Effect"])
						else:
							DisplayDiologue(LoadedWepons[weponMap[optOptions]]["KILL"]["Fail"]["Messages"].pick_random())
							WeponRecharge[weponMap[optOptions]] = LoadedWepons[weponMap[optOptions]]["KILL"]["Fail"]["Cooldown"]
							attack(LoadedWepons[weponMap[optOptions]]["KILL"]["Fail"]["Damage"], 0, LoadedWepons[weponMap[optOptions]]["KILL"]["Fail"]["Effect"])
				else:
					if skipAttack:
						if Input.is_action_just_pressed("Jump"): #I am god at commenting my code B)
								StageSet = StageSets.ENEMY_ATTACK
								enemyIntro = ENEMY_INTRO

			PlayerPos.Bep:
				if not GetStageChange(): #debounces jump input
					if Input.is_action_just_pressed("Jump"): #I am god at commenting my code B)
							StageSet = StageSets.ENEMY_ATTACK
							enemyIntro = ENEMY_INTRO
				else:
					DisplayDiologue(allEnemies[advOptions]["Interactions"][allEnemies[advOptions]["Interactions"].keys()[optOptions]].pick_random())
			PlayerPos.SSStyle:
				if not GetStageChange(): #debounces jump input
					# if Input.is_action_just_pressed("Jump"): #I am god at commenting my code B)
					# 		StageSet = StageSets.ENEMY_ATTACK
					# 		enemyIntro = ENEMY_INTRO
					pass
				else:
					if WeponRecharge[weponMap[optOptions]] > 0:
						DisplayDiologue(["As you tried that", 
										"you relised you had cooldown",
										"No styling onthem ig :<"])
					else:
						if LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Chance"] >= randf_range(0,100):
							DisplayDiologue(LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Succes"]["Messages"].pick_random())
							WeponRecharge[weponMap[optOptions]] = LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Succes"]["Cooldown"]
							attack(LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Succes"]["Damage"], 0, LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Succes"]["Effect"])
							Global.player_health += min(LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Succes"]["Heal"], Global.player_max_health - Global.player_health)
						else:
							DisplayDiologue(LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Fail"]["Messages"].pick_random())
							WeponRecharge[weponMap[optOptions]] = LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Fail"]["Cooldown"]
							attack(LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Fail"]["Damage"], 0, LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Fail"]["Effect"])
							Global.player_health += min(LoadedWepons[weponMap[optOptions]]["SSSTYLE"]["Fail"]["Heal"], Global.player_max_health - Global.player_health)
			PlayerPos.Nomercy:
				if GetStageChange():
					attack(8, 1, "Shot")
					nomercyColldown = 10
					DisplayDiologue(["YOU USED THE RAILCANON",
									"ENEMIES ARE TOTALY VAPORIZED",
									"you can say they got...",
									"railed",
									"I'm so funny ;u;"])

func InputVictory():
	if not GetStageChange():
		if Input.is_action_just_pressed("Jump"):
			Restart()

func attack(dmg, attRange, effectName) -> void:
	attackDmg = dmg
	attackRange = attRange
	loadEffectString = effectName
	attackAnim = 0
	attackStage = 0
	higlightEnemy = true

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
	health.position = cage.CagePosition - cage.CageSize / 2 * Vector2(-1,-1) + Vector2(-10 - 640,5)

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
	var indx = 0
	for enemy in allEnemies: #updates all enemies
		var offset = enemy["Offset"]
		if higlightEnemy and abs(indx - advOptions) <= attackRange:
			enemy["Body"].get_child(0).modulate += (Color(1,0,0) - enemy["Body"].get_child(0).modulate) * delta
			enemy["Body"].get_child(1).modulate += (Color(1,0,0) - enemy["Body"].get_child(1).modulate) * delta
			enemy["Body"].scale += (size + Vector2(0.3,0.3) - enemy["Body"].scale) * delta
			enemy["Body"].position += (position2 - enemy["Body"].position + enemy["PosOffset"] + Vector2(0,10)) * delta
			enemy["Body"].get_child(2).get_child(0).get_child(1).anchor_right += (enemy["Health"] / enemy["MaxHp"] - enemy["Body"].get_child(2).get_child(0).get_child(1).anchor_right) * delta
		else:
			enemy["Body"].get_child(0).modulate += (color - enemy["Body"].get_child(0).modulate) * delta
			enemy["Body"].get_child(1).modulate += (color - enemy["Body"].get_child(1).modulate) * delta
			enemy["Body"].scale += (Vector2.ONE - enemy["Body"].scale) * delta
			enemy["Body"].position += (position2 - enemy["Body"].position + enemy["PosOffset"]) * delta
		enemy["Body"].get_child(0).position =  Vector2(cos(time*2+offset) * 3 + cos(time*2+offset) * 10, cos(time*3+offset) * 3 + sin(time+offset) * 10)
		enemy["Body"].get_child(1).position = Vector2(cos(time*2+offset) * 10, sin(time+offset) * 10)
		indx += 1
	
	indx = 0
	var higindex = 0
	var nextTunr = 0
	var removeIndex = []
	var zIndex = 0
	for enemy in allEnemies:
		if not higlightEnemy or abs(indx - advOptions) > attackRange: 
			indx += 1
			continue
		var offset = enemy["Offset"]
		var ofsseter = 0
		if attackStage == 0:#Show health
			enemy["Body"].get_child(2).modulate = Color(1,1,1,attackAnim/0.3)
			attackDebounce.append(true)
			enemy["Body"].get_child(2).z_index = zIndex
			zIndex += 5
			if attackAnim > 0.3:
				attackStage += 1
		if attackStage == 1: #Anticipation
			if attackAnim > 0.5:
				attackStage += 1
		if attackStage == 2:#slash
			if loadedEffect.size() > higindex:
				loadedEffect[higindex].visible = true
				loadedEffect[higindex].get_child(0).play()
				loadedEffect[higindex].position = enemy["Body"].position + enemy["Body"].get_child(0).position + enemy["Body"].get_child(0).get_child(0).position
			else:
				loadedEffect.append(load(player_effect_path + loadEffectString + ".tscn").instantiate())
				loadedEffect[higindex].scale = Vector2.ONE * 5
				loadedEffect[higindex].visible = false
				add_child(loadedEffect[higindex])
			if attackAnim > 1.5:
				attackStage += 1
		if attackStage == 3:#dmg
			if attackDebounce[higindex]:
				enemy["Health"] -= attackDmg
				enemy["Body"].get_child(3).get_node(enemy["DmgAudio"]).play()
				attackDebounce[higindex] = false
				var tempDmgNumber = dmgNumb.instantiate()
				add_child(tempDmgNumber)
				tempDmgNumber.text = str(attackDmg)
				tempDmgNumber.position = enemy["Body"].position + enemy["Body"].get_child(0).position + enemy["Body"].get_child(0).get_child(0).position
				dmgNumbers.append([tempDmgNumber, Vector2(randf_range(-200,200),-200),3])
			ofsseter = pow(((2.6-attackAnim)*2),2) * 10
			if attackAnim > 2.5:
				if attackDebounce.size() > 0:
					for nothing in range(attackDebounce.size()): attackDebounce.pop_front()
				attackStage += 1
		if attackStage == 4:#check if enemy died and play animation
			if enemy["Health"] < 0:
				enemy["Body"].get_child(3).get_node(enemy["DeathAudio"]).play()
				fightRewards += enemy["Points"]
				var random1 = randf_range(-00,100)
				allKilled.append([enemy["Body"],[Vector2(random1,randf_range(-400,-200)),random1/100],[Vector2(-random1,randf_range(-400,-200)),-random1/100]])
				removeIndex.append(indx)
				enemyIntro = ENEMY_INTRO
				if nextTunr == 0: nextTunr = 1
				enemy["Body"].get_child(2).modulate = Color(1,1,1,0)
			else:
				nextTunr = 2
			if attackAnim > 3.5:
				attackStage += 1
		if attackStage == 5:#hides health
			enemy["Body"].get_child(2).modulate = Color(1,1,1,(3.7-attackAnim)/0.2)
			if attackAnim > 3.7:
				attackStage += 1
		if attackStage == 6:
			attackStage += 1
			nextTunr = 1
			enemyIntro = ENEMY_INTRO
		indx += 1
		higindex += 1
		enemy["Body"].get_child(0).position = Vector2(cos(time*2+offset+ofsseter/2.0) * 3 + cos(time*2+offset+ofsseter/2.0) * 10, cos(time*3+offset+ofsseter) * 3 + sin(time+offset+ofsseter) * 10)
		enemy["Body"].get_child(1).position = Vector2(cos(time*2+offset+ofsseter) * 10, sin(time+offset+ofsseter/2.0) * 10)
	removeIndex.reverse()
	if attackStage >= 3:
		if loadedEffect.size() > 0:
			for i in range(loadedEffect.size()):
				loadedEffect[0].queue_free()
				loadedEffect.pop_front()

	var redoEnemies = false
	for indexs in removeIndex:
		redoEnemies = true
		allEnemies.remove_at(indexs)
	if redoEnemies:
		var totalWidth = 0
		var offseter = 0
		for enemyIter1 in allEnemies:
			totalWidth -= enemyIter1["Width"]/2
			enemyIter1["Offset"] = offseter
			offseter += 0.3
		for enemyIter2 in allEnemies:
			totalWidth += enemyIter2["Width"]
			enemyIter2["Body"].position = Vector2(totalWidth - enemyIter2["Width"]/2,0)
			enemyIter2["PosOffset"] = Vector2(totalWidth - enemyIter2["Width"]/2,0)
	if nextTunr == 1: 
		StageSet = StageSets.ENEMY_ATTACK
		attackStage = 7
	if allEnemies.size() <= 0:
		StageSet = StageSets.VICTORY

func RecenterPlayer() -> void:
	player.PlayerDoge = true
	player.MenuPos = cage.CagePosition
	player.position = cage.CagePosition

func PlayerMenuMove() -> void:
	player.MenuPos = mainControl.position + OFFSETS[PlayerSel as int]
	mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1, 0)
	if Input.is_action_just_pressed("Left"):
		playSwitch()
		mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
		PlayerSel = PlayerSel - 1 as PlayerPos
		if PlayerSel < 0:
			PlayerSel = 3 as PlayerPos
	if Input.is_action_just_pressed("Right"):
		playSwitch()
		mainControl.get_child(1).get_child(PlayerSel as int).modulate = Color(1,1,1)
		PlayerSel = PlayerSel + 1 as PlayerPos
		if PlayerSel > 3:
			PlayerSel = 0 as PlayerPos

func playSwitch() -> void:
	$Cage/Audio/Switch.play()

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

func UpdateDeadEnemies(delta) -> void:
	var index = 0
	for killed in allKilled:
		killed[0].get_child(0).position += killed[1][0] * delta
		killed[0].get_child(0).rotation += killed[1][1] * delta
		killed[1][0] += Vector2(0,98) * delta * 4
		killed[0].get_child(1).position += killed[2][0] * delta
		killed[0].get_child(1).rotation += killed[2][1] * delta
		killed[2][0] += Vector2(0,98) * delta * 4
		killed[0].modulate += (Color(0,0,0,0) - killed[0].modulate) * delta * 0.1
		if killed[0].modulate.a < 0.2:
			killed[0].queue_free()
			allKilled.remove_at(index)
			print("del")
			return
		index += 1

func updateDmgNumbers(delta) -> void:
	var indexToDel = []
	var index = -1
	for dmgNumber in dmgNumbers:
		index += 1
		if dmgNumber[2] <= 0 :
			indexToDel.append(index)
		else:
			dmgNumber[0].position += dmgNumber[1] * delta
			dmgNumber[1] += Vector2(0,98) * delta * 10
			if dmgNumber[0].position.y >= 160:
				dmgNumber[0].position.y = 160
				dmgNumber[1].x *= 0.8
				dmgNumber[1].y *= -0.8
			dmgNumber[2] -= delta
			dmgNumber[0].modulate = Color(1,1,1,min(1,dmgNumber[2]))
	indexToDel.reverse()
	for indx in indexToDel:
		dmgNumbers[indx][0].queue_free()
		dmgNumbers.remove_at(indx)

func GetStageChange() -> bool:
	return LastStage != StageSet

func playAudio() -> void:
	if advOptions != advOptionsLast:
		$Cage/Audio/Switch.play()
		advOptionsLast = advOptions
	if optOptions != optOptions:
		$Cage/Audio/Switch.play()
		optOptionsLast = optOptions
	if GetStageChange():
		if LastStage == StageSets.ENEMY_ATTACK:
			$Cage/Audio/Start.play()
		if LastStage == StageSets.PLAYER_MENU:
			$Cage/Audio/Pick.play()
		if LastStage == StageSets.ADVANCED_OPTIONS:
			if StageSet == StageSets.PLAYER_MENU:
				$Cage/Audio/Back.play()
			if StageSet == StageSets.OPTION_TEXT:
				$Cage/Audio/Pick.play()
		if LastStage == StageSets.OPTION_TEXT:
			if StageSet == StageSets.ADVANCED_OPTIONS:
				$Cage/Audio/Back.play()
			if StageSet == StageSets.PLAYER_ATTACK:
				$Cage/Audio/Pick.play()
		if LastStage == StageSets.PLAYER_ATTACK:
			if StageSet == StageSets.VICTORY:
				$Camera2D/Health.visible = false
				$Cage/Audio/CrowdApplause.play()
				$Cage/Audio/CrowdCheerLong.play()
			else:
				$Cage/Audio/Exit.play()
		if StageSet != StageSets.VICTORY:
			$Camera2D/Health.visible = true
func attackInit() -> void:
	attackCage = ["CAGE_SMALL"].pick_random()
	#then add attack randomizer
	#add so other enemies try to attack aswell (3 enemies at max maybe)
	for indx in range(min(3, allEnemies.size())):
		var pickedEnemy = allEnemies.pick_random()
		#idk how but somehow the bullet is loaded in Realy 0 clue
		var pickedAttack = pickedEnemy["Attacks"][attackCage].pick_random()
		var transfer = {
			"Projectile" = load(enemi_folder_path + pickedAttack["Projectile"] + ".tscn"),
			"Damage" = pickedAttack["Damage"],
			"AttackPatern" = pickedAttack["AttackPatern"],
			"AttackPaternsParams" = pickedAttack["AttackPaternsParams"],
			"ProjectileSize" = Vector2.ZERO,
			"AttackPluses" = []
		}
		transfer["ProjectileSize"] = transfer["Projectile"].instantiate().get_meta("BulletSize")
		transfer["AttackPluses"] = attackPlusesInit(pickedAttack)
		attacks.append([pickedEnemy, transfer])

func attackPlusesInit(pickedAttack):
	var pickedAttackTemp = {}
	match pickedAttack["AttackPatern"]:
		"Bounce":
			pickedAttackTemp = {
				"TimeToSpawn" = 0,
				"SpawnedObj" = 0,
				"SpawnedProj" = [{
					"ProjNode" = null,
					"Veloc" = Vector2.ZERO,
					"SpawnTimer" = 0
				}]
			}
			pickedAttackTemp["SpawnedProj"] = []
		"Trogh":
			pickedAttackTemp = {
				"TimeToSpawn" = 0,
				"SpawnedObj" = 0,
				"SpawnedProj" = [{
					"ProjNode" = null,
					"Veloc" = Vector2.ZERO,
					"SpawnTimer" = 0
				}]
			}
			pickedAttackTemp["SpawnedProj"] = []
	return pickedAttackTemp
		
func atacksUpdater(delta) -> void:
	for iterEnemy in attacks:
		var iterAttack = iterEnemy[1]
		match iterAttack["AttackPatern"]:
			"Bounce":
				if enemyIntro <= 0:
					if iterAttack["AttackPluses"]["TimeToSpawn"] <= 0:
						iterAttack["AttackPluses"]["TimeToSpawn"] = iterAttack["AttackPaternsParams"][2]
						iterAttack["AttackPluses"]["SpawnedObj"] += 1
						if iterAttack["AttackPluses"]["SpawnedObj"] <= iterAttack["AttackPaternsParams"][1]:
							match iterAttack["AttackPaternsParams"][0]:
								"OutsideL":
									var tempVel = iterAttack["AttackPaternsParams"][4].pick_random()
									iterAttack["AttackPluses"]["SpawnedProj"].append({
										"ProjNode" = iterAttack["Projectile"].instantiate(),
										"Veloc" = Vector2(tempVel[0], tempVel[1]),
										"SpawnTimer" = iterAttack["AttackPaternsParams"][5]
									})
									var tempBullet = iterAttack["AttackPluses"]["SpawnedProj"][iterAttack["AttackPluses"]["SpawnedProj"].size()-1]["ProjNode"]
									tempBullet.modulate = Color(1,1,1,0)
									tempBullet.damage = iterAttack["Damage"]
									bullets.add_child(tempBullet)
									var position_posabilities = [
										cage.CagePosition.x + (cage.CageSize.x / 2 + iterAttack["ProjectileSize"].x) * random_numbers.pick_random(),
										cage.CagePosition.y + (cage.CageSize.y / 2 + iterAttack["ProjectileSize"].y) * random_numbers.pick_random(),
										randf_range(cage.CagePosition.y - cage.CageSize.y / 2, cage.CagePosition.y + cage.CageSize.y / 2),
										randf_range(cage.CagePosition.x - cage.CageSize.x / 2, cage.CagePosition.x + cage.CageSize.x / 2)
									]
									var random_direction = randi_range(0,1)
									if random_direction == 0:
										tempBullet.position = Vector2(position_posabilities[random_direction], position_posabilities[random_direction + 2])
									else:
										tempBullet.position = Vector2(position_posabilities[random_direction + 2], position_posabilities[random_direction])
									# tempBullet.position = Vector2.ZERO
					else:
						iterAttack["AttackPluses"]["TimeToSpawn"] -= delta
					for projectile_iter in iterAttack["AttackPluses"]["SpawnedProj"]:
						if projectile_iter["SpawnTimer"] >= 0:
							projectile_iter["SpawnTimer"] -= delta
							projectile_iter["ProjNode"].modulate = Color(1,1,1,1 - projectile_iter["SpawnTimer"] / iterAttack["AttackPaternsParams"][5])
							if projectile_iter["SpawnTimer"] <= 0:
								projectile_iter["ProjNode"].modulate = Color(1,1,1,1)
						else:
							projectile_iter["ProjNode"].position += projectile_iter["Veloc"] * iterAttack["AttackPaternsParams"][3]
							if projectile_iter["ProjNode"].position.y + iterAttack["ProjectileSize"].y > cage.position.y + cage.CageSize.y / 2 and projectile_iter["Veloc"].y > 0:
								projectile_iter["Veloc"].y *= -1
							if projectile_iter["ProjNode"].position.y - iterAttack["ProjectileSize"].y < cage.position.y - cage.CageSize.y / 2 and projectile_iter["Veloc"].y < 0:
								projectile_iter["Veloc"].y *= -1
							if projectile_iter["ProjNode"].position.x + iterAttack["ProjectileSize"].x > cage.position.x + cage.CageSize.x / 2 and projectile_iter["Veloc"].x > 0:
								projectile_iter["Veloc"].x *= -1
							if projectile_iter["ProjNode"].position.x - iterAttack["ProjectileSize"].x < cage.position.x - cage.CageSize.x / 2 and projectile_iter["Veloc"].x < 0:
								projectile_iter["Veloc"].x *= -1
				elif StageSet == StageSets.ENEMY_ATTACK:
					pass
				else:
					pass
			"Trogh":
				if enemyIntro <= 0:
					if iterAttack["AttackPluses"]["TimeToSpawn"] <= 0:
						iterAttack["AttackPluses"]["TimeToSpawn"] = iterAttack["AttackPaternsParams"][2]
						iterAttack["AttackPluses"]["SpawnedObj"] += 1
						if iterAttack["AttackPluses"]["SpawnedObj"] <= iterAttack["AttackPaternsParams"][1]:
							match iterAttack["AttackPaternsParams"][0]:
								"Sides":
									iterAttack["AttackPluses"]["SpawnedProj"].append({
										"ProjNode" = iterAttack["Projectile"].instantiate(),
										"Veloc" = Vector2(0,0),
										"SpawnTimer" = iterAttack["AttackPaternsParams"][5]
									})
									var tempBullet = iterAttack["AttackPluses"]["SpawnedProj"][iterAttack["AttackPluses"]["SpawnedProj"].size()-1]["ProjNode"]
									tempBullet.modulate = Color(1,1,1,0)
									tempBullet.damage = iterAttack["Damage"]
									bullets.add_child(tempBullet)
									var position_posabilities = [
										cage.CagePosition.x + (cage.CageSize.x / 2 + iterAttack["ProjectileSize"].x) * random_numbers.pick_random(),
										randf_range(cage.CagePosition.y - cage.CageSize.y / 2, cage.CagePosition.y + cage.CageSize.y / 2),
									]
									tempBullet.position = Vector2(position_posabilities[0], position_posabilities[1])
									var tempVel = iterAttack["AttackPaternsParams"][4][0 if tempBullet.position.x < 0 else 1]
									iterAttack["AttackPluses"]["SpawnedProj"][iterAttack["AttackPluses"]["SpawnedProj"].size()-1]["Veloc"] = Vector2(tempVel[0],tempVel[1])
									# tempBullet.position = Vector2.ZERO
					else:
						iterAttack["AttackPluses"]["TimeToSpawn"] -= delta
					for projectile_iter in iterAttack["AttackPluses"]["SpawnedProj"]:
						if projectile_iter["SpawnTimer"] >= 0:
							projectile_iter["SpawnTimer"] -= delta
							projectile_iter["ProjNode"].modulate = Color(1,1,1,1 - projectile_iter["SpawnTimer"] / iterAttack["AttackPaternsParams"][5])
							if projectile_iter["SpawnTimer"] <= 0:
								projectile_iter["ProjNode"].modulate = Color(1,1,1,1)
						else:
							projectile_iter["ProjNode"].position += projectile_iter["Veloc"] * iterAttack["AttackPaternsParams"][3]
				elif StageSet == StageSets.ENEMY_ATTACK:
					pass
				else:
					pass

func attacks_delete_em() -> void:
	for iterEnemy in attacks:
		var iterAttack = iterEnemy[1]
		match iterAttack["AttackPatern"]:
			"Bounce":
				for projectile_iter in iterAttack["AttackPluses"]["SpawnedProj"]:
					projectile_iter["ProjNode"].queue_free()
			"Trogh":
				for projectile_iter in iterAttack["AttackPluses"]["SpawnedProj"]:
					projectile_iter["ProjNode"].queue_free()
	attacks.clear()
		

func UpdatePlayersHp(delta):
	playersPrevHp += (Global.player_health-playersPrevHp) * delta
	health.text = str(floori(playersPrevHp)) + "/" + str(Global.player_max_health)

func _physics_process(delta):
	updateDmgNumbers(delta)
	UpdtDiologue(delta)
	UpdateDeadEnemies(delta)
	UpdatePlayersHp(delta)
	playAudio()
	attackAnim += delta
	time += delta
	if first:
		print(StageSets.find_key(StageSet))
		LastStage = StageSet
	first = LastStage != StageSet

	if StageSet == StageSets.PLAYER_MENU:
		get_input(delta)
		UpdateEnemi(delta, Color(1,1,1), Vector2(0.7,0.7), Vector2(0,-50))
		UpdateCage(delta, "DEFAULT_CAGE", 2)
		player.PlayerDoge = false
		if GetStageChange():
			attacks_delete_em()
			SwitchGui(GuiStages.OPTIONS)
			var randEn = allEnemies.pick_random()
			if LastStage != StageSets.PLAYER_MENU:
				randEn["Body"].get_child(3).get_node(randEn["DmgAudio"]).play()
				DisplayDiologue(randEn["Intro"].pick_random())
	elif StageSet == StageSets.ADVANCED_OPTIONS:
		get_input(delta)
		UpdateCage(delta, "DEFAULT_CAGE", 2)
		UpdateEnemi(delta, Color(1,1,1), Vector2(0.8,0.8), Vector2(0,-50))
		NavigateAdvOptions()
	elif StageSet == StageSets.OPTION_TEXT:
		get_input(delta)
		UpdateCage(delta, "DEFAULT_CAGE", 2)
		UpdateEnemi(delta, Color(1,1,1), Vector2(0.9,0.9), Vector2(0,-40))
		NavigateOptions()
	elif StageSet == StageSets.PLAYER_ATTACK:
		player.MenuPos = Vector2(400,0)
		UpdateEnemi(delta, Color(1,1,1), Vector2(1,1), Vector2(0,0))
		get_input(delta)
		UpdateCage(delta, "DIOLOGUE_CAGE", 2)
		SwitchGui(GuiStages.TEXT)
	elif StageSet == StageSets.ENEMY_ATTACK:
		higlightEnemy = false
		UpdateEnemi(delta, Color(0.4,0.4,0.4), Vector2(0.5,0.5), Vector2(400,-70))
		if enemyIntro > 0 or GetStageChange():
			if GetStageChange():
				SwitchGui(GuiStages.BATTLE)
				RecenterPlayer()
				higlightEnemy = false
				attackInit()
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
		atacksUpdater(delta)
	elif  StageSet == StageSets.VICTORY:
		UpdateCage(delta, "DIOLOGUE_CAGE", 2)
		SwitchGui(GuiStages.TEXT)
		player.MenuPos = Vector2(400,0)
		if GetStageChange():
			DisplayDiologue(["CONGRATS",
			"YOU DEFEATED ALL MONSTERS",
			"YOU HAVE EARNED - " + str(fightRewards as int) + "P"])
		else:
			get_input(delta)
	if Global.player_health <= 0:
		Global.score = fightRewards
		get_tree().change_scene_to_file("res://Scenes/death.tscn")
