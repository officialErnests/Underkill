extends CharacterBody2D

var walljumps = 3

#player variables
const SPEED = 200
const GRAVITY = 100
const JUMP_HEIGHT = 500
const GROUNDSLAM_SPEED = 1500
const GROUNDSLAM_RECOVERY = 0.2
const GROUNDSLAM_DISTANCE = 0.2
const DASH_SPEED = 750
const DASH_LENGHT = 0.2
const WALL_COYOTE = 0.2
const SLIDE_SPEED = 300


#env variables
const DAMPENING = Vector2(0.85, 0.97)

#states
var Sliding = false
var CanMove = true
var Airborne = false
var OnWall = false
var JumpStorage = false
var Invincible = false

@export var StageGui: Control

#betterStates
enum EnumPlayerStates {AIR,GROUND,WALL}
enum EnumPlrMovement {
	DASH, 
	SLIDE, 
	GROUND_SLAM, 
	GROUND_SLAM_RECOVERY,
	WALL_HUG,
	WALL_SLIDE,
	AIRBORNE, 
	GROUNDED,
	JUMP_STORAGE
}
#State
var CurentPlayersState = EnumPlayerStates.AIR
var PlrMovement = EnumPlrMovement.GROUNDED
#script used variables
var wallSlideSpeed = 0.1
var timeSinceLastGroundpund = 0
var groundVelocity = 0
var groundDistance = 0
var dashingTime = 0
var lastDirection = 1
var energy = 3
var wallCoyoti = 0
var wallNormal = Vector2(0,0)
var prevPrint = ""
var groundslamRecoveryTime = 0
var groundslamDistance = 0
var slideSpeed = 0


func Movement(delta) -> void:
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	if input_direction.x == 0:
		lastDirection = 1
	else:
		lastDirection = input_direction.x
	velocity.x += input_direction.x * SPEED * delta

func Gravity(delta) -> void:
	velocity.y += delta * GRAVITY

func WallGrav(delta) -> void:
	velocity.y += delta * GRAVITY * wallSlideSpeed
	wallSlideSpeed += delta * 0.1
	if get_wall_normal().x < 0:
		$Slide.process_material.emission_shape_offset = Vector3(5,-2.5,0)
		$Slide.process_material.direction = Vector3(-0.2,-1,0)
	else:
		$Slide.process_material.emission_shape_offset = Vector3(-5,-2.5,0)
		$Slide.process_material.direction = Vector3(0.2,-1,0)

func Dashing(delta) -> void:
	if dashingTime > 0:
		if lastDirection == 1:
			$Slide2.emitting = true
			$Slide2.process_material.emission_shape_offset = Vector3(5,0,0)
			$Slide2.process_material.direction = Vector3(-10,0,0)
		else:
			$Slide2.emitting = true
			$Slide2.process_material.emission_shape_offset = Vector3(-5,0,0)
			$Slide2.process_material.direction = Vector3(10,0,0)
		dashingTime -= delta/10
		velocity = Vector2(DASH_SPEED * lastDirection, 0)
	else:
		$Slide2.emitting = false
		PlrMovement = EnumPlrMovement.AIRBORNE
		dashingTime = 0

func ResetWallJumps() -> void:
	walljumps = 3
	wallSlideSpeed = 0.1

func DetGroundslam() -> void:
	if Input.is_action_just_pressed("Slide"):
		groundslamDistance = 0
		PlrMovement = EnumPlrMovement.GROUND_SLAM

func DetJump() -> void:
	if Input.is_action_just_pressed("Jump"):
		velocity.y -= JUMP_HEIGHT
		PlrMovement = EnumPlrMovement.AIRBORNE

func DetWallJump() -> void:
	if Input.is_action_just_pressed("Jump") and walljumps > 0:
		walljumps -= 1
		velocity.y = -JUMP_HEIGHT
		velocity.x = wallNormal.x * SPEED
		$Slide.emitting = false
		if PlrMovement == EnumPlrMovement.GROUND_SLAM or PlrMovement == EnumPlrMovement.JUMP_STORAGE:
			PlrMovement = EnumPlrMovement.JUMP_STORAGE
		else:
			PlrMovement = EnumPlrMovement.AIRBORNE

func DetDash() -> void:
	if Input.is_action_just_pressed("Dash") and energy >= 1:
		dashingTime = DASH_LENGHT
		energy -= 1
		PlrMovement = EnumPlrMovement.DASH

func DetDashJump() -> void:
	if CurentPlayersState == EnumPlayerStates.GROUND and Input.is_action_just_pressed("Jump") and energy >= 1:
		energy -= 2
		PlrMovement = EnumPlrMovement.AIRBORNE
		velocity = Vector2(DASH_SPEED * lastDirection * 2, -JUMP_HEIGHT)
		$Slide2.emitting = false
		PlrMovement = EnumPlrMovement.AIRBORNE
		dashingTime = 0

func CoyoteWall() -> void:
	wallCoyoti = WALL_COYOTE

func DetCoyoteWall(delta) -> void:
	if wallCoyoti > 0:
		DetWallJump()
		wallCoyoti -= delta/10

func GetWallDir() -> void:
	wallNormal = get_wall_normal()

func GroundSlam(delta) -> void:
	groundslamDistance += delta / 10.0
	velocity = Vector2(0,GROUNDSLAM_SPEED)
	$Slide2.emitting = true
	$Slide2.process_material.emission_shape_offset = Vector3(0,5,0)
	$Slide2.process_material.direction = Vector3(0,-5,0)

func GroundSlamRecoveryStart() -> void:
	groundslamRecoveryTime = GROUNDSLAM_RECOVERY

func GroundSlamRecovery(delta) -> void:
	groundslamRecoveryTime -= delta / 10.0
	DetGroundSlamJump()
	DetRecoverySlide()
	if groundslamRecoveryTime <= 0:
		groundslamRecoveryTime = 0
		PlrMovement = EnumPlrMovement.GROUNDED

func DetGroundSlamJump() -> void:
	if Input.is_action_just_pressed("Jump"):
		velocity.y = -min(groundslamDistance, GROUNDSLAM_DISTANCE) * GROUNDSLAM_SPEED / GROUNDSLAM_DISTANCE
		groundslamRecoveryTime = 0
		PlrMovement = EnumPlrMovement.AIRBORNE

func DetSlide() -> void:
	if Input.is_action_just_pressed("Slide"):
		slideSpeed = max(abs(velocity.x), 0)
		PlrMovement = EnumPlrMovement.SLIDE

func DetRecoverySlide() -> void:
	if Input.is_action_just_pressed("Slide"):
		slideSpeed = max(min(groundslamDistance, GROUNDSLAM_DISTANCE) * GROUNDSLAM_SPEED * 5.0,0)
		print(slideSpeed)
		PlrMovement = EnumPlrMovement.SLIDE

func Slide() -> void:
	slideSpeed *= 0.95
	velocity.x = (slideSpeed + SLIDE_SPEED) * lastDirection
	$Slide.process_material.emission_shape_offset = Vector3(0,5,0)
	$Slide.process_material.direction = Vector3(-lastDirection,-1,0)
	if velocity.x == 0:
		PlrMovement = EnumPlrMovement.GROUNDED
	if Input.is_action_just_released("Slide"):
		PlrMovement = EnumPlrMovement.GROUNDED

func get_input(delta) -> void:
	delta *= 10

	if energy < 3:
		energy += delta / 10 * 0.7
		StageGui.get_node("Dash3").color = Color(0.2,max(energy-2,0.4)/2,max(energy-2,0.4)/2)
		if energy < 2:
			StageGui.get_node("Dash2").color = Color(0.2,max(energy-1,0.4)/2,max(energy-1,0.4)/2)
		else:
			StageGui.get_node("Dash2").color = Color(0,1,1)
		if energy < 1:
			StageGui.get_node("Dash1").color = Color(0.2,max(energy-0,0.4)/2,max(energy-0,0.4)/2)
		else:
			StageGui.get_node("Dash1").color = Color(0,1,1)
	else:
		energy = 3
		StageGui.get_node("Dash1").color = Color(0,1,1)
		StageGui.get_node("Dash2").color = Color(0,1,1)
		StageGui.get_node("Dash3").color = Color(0,1,1)


	if is_on_floor():
		CurentPlayersState = EnumPlayerStates.GROUND
	elif is_on_wall():
		GetWallDir()
		CurentPlayersState = EnumPlayerStates.WALL
	else:
		CurentPlayersState = EnumPlayerStates.AIR

	if CurentPlayersState == EnumPlayerStates.GROUND:
		velocity *= DAMPENING
	elif PlrMovement == EnumPlrMovement.SLIDE:
		velocity.y *= DAMPENING.y
	else:
		velocity.x = velocity.x * DAMPENING.x / 2 + velocity.x /2
		velocity.y *= DAMPENING.y

	if PlrMovement == EnumPlrMovement.GROUNDED:
		ResetWallJumps()
		if CurentPlayersState == EnumPlayerStates.AIR:
			PlrMovement = EnumPlrMovement.AIRBORNE
		if CurentPlayersState == EnumPlayerStates.WALL:
			PlrMovement = EnumPlrMovement.WALL_HUG

	if PlrMovement == EnumPlrMovement.AIRBORNE and CurentPlayersState == EnumPlayerStates.GROUND:
		PlrMovement = EnumPlrMovement.GROUNDED
	
	if PlrMovement == EnumPlrMovement.AIRBORNE and CurentPlayersState == EnumPlayerStates.WALL:
		if velocity.y > 0:
			PlrMovement = EnumPlrMovement.WALL_SLIDE
		else: 
			PlrMovement = EnumPlrMovement.WALL_HUG
	
	if PlrMovement == EnumPlrMovement.WALL_HUG:
		if velocity.y > 0:
			PlrMovement = EnumPlrMovement.WALL_SLIDE


	if PlrMovement == EnumPlrMovement.WALL_SLIDE or PlrMovement == EnumPlrMovement.WALL_HUG:
		if CurentPlayersState == EnumPlayerStates.AIR:
			CoyoteWall()
			PlrMovement = EnumPlrMovement.AIRBORNE
		if CurentPlayersState == EnumPlayerStates.GROUND:
			CoyoteWall()
			PlrMovement = EnumPlrMovement.GROUNDED

	if prevPrint !=EnumPlayerStates.find_key(CurentPlayersState) + " " + EnumPlrMovement.find_key(PlrMovement):
		prevPrint = EnumPlayerStates.find_key(CurentPlayersState) + " " + EnumPlrMovement.find_key(PlrMovement)
		print(prevPrint)

	if PlrMovement == EnumPlrMovement.GROUNDED:
		Movement(delta)
		DetJump()
		DetSlide()

	if PlrMovement == EnumPlrMovement.AIRBORNE:
		DetCoyoteWall(delta)
		Movement(delta)
		Gravity(delta)
		DetGroundslam()

	if PlrMovement == EnumPlrMovement.WALL_HUG:
		Movement(delta)
		Gravity(delta)
		DetWallJump()
		DetGroundslam()

	if PlrMovement == EnumPlrMovement.WALL_SLIDE:
		Movement(delta)
		WallGrav(delta)
		DetWallJump()
		DetGroundslam()

	if PlrMovement != EnumPlrMovement.DASH:
		DetDash()

	if PlrMovement == EnumPlrMovement.DASH:
		Dashing(delta)
		DetDashJump()

	if PlrMovement == EnumPlrMovement.GROUND_SLAM:
		GroundSlam(delta)
		if CurentPlayersState == EnumPlayerStates.WALL:
			DetWallJump()
		if CurentPlayersState == EnumPlayerStates.GROUND:
			PlrMovement = EnumPlrMovement.GROUND_SLAM_RECOVERY
			GroundSlamRecoveryStart()
	
	if PlrMovement == EnumPlrMovement.GROUND_SLAM_RECOVERY:
		$Slide2.emitting = false
		Movement(delta)
		GroundSlamRecovery(delta)
	
	if PlrMovement == EnumPlrMovement.JUMP_STORAGE:
		Movement(delta)
		groundslamDistance = GROUNDSLAM_DISTANCE
		if CurentPlayersState == EnumPlayerStates.WALL:
			DetWallJump()
			if velocity.y > 0:
				WallGrav(delta)
			else: 
				Gravity(delta)
		else:
			$Slide.emitting = false
			Gravity(delta)
		if CurentPlayersState == EnumPlayerStates.GROUND:
			groundslamRecoveryTime = GROUNDSLAM_RECOVERY
			PlrMovement = EnumPlrMovement.GROUND_SLAM_RECOVERY

	if PlrMovement == EnumPlrMovement.SLIDE:
		scale = Vector2(1,0.5)
		Slide()
		Gravity(delta)
		DetJump()
	else:
		scale = Vector2(1,1)

	if PlrMovement == EnumPlrMovement.SLIDE or PlrMovement == EnumPlrMovement.WALL_SLIDE:
		$Slide.emitting = true
	else:
		$Slide.emitting = false

	if true:
		return

	if Input.is_action_pressed("Slide"):
		Sliding = true
	else:
		Sliding = false

	if Sliding:
		if Airborne:
			$Slide.emitting = true
			CanMove = false
			$CollisionPolygon2D.scale.y = 1
		else:
			$Slide.emitting = true
			CanMove = false
			$CollisionPolygon2D.scale.y = 1
	

	if Dashing:
		if dashingTime > 0:
			dashingTime -= delta/10
			$CollisionPolygon2D.scale.y = 1
			velocity = Vector2(DASH_SPEED * lastDirection,0)
			Invincible = true
	
	if GroundSlam:
		if Dashing:
			# GroundSlam = false
			JumpStorage = false
			groundDistance = 0

	if Airborne:
		pass
	else:
		wallSlideSpeed = 0.1
		$Slide.emitting = false
		walljumps = 3
		
		if Input.is_action_just_pressed("Jump"):
			velocity.y = -JUMP_HEIGHT
			#JumpStorage
			if Time.get_ticks_msec() - timeSinceLastGroundpund < 200:
				velocity.y -= groundDistance * 100

	if GroundSlam:
		if not JumpStorage:
			CanMove = false
			velocity.y = GROUNDSLAM_SPEED
		if JumpStorage:
			groundDistance = 4
		else:
			groundDistance += delta
			groundDistance = min(groundDistance, 4)

	#wallthingies
	if OnWall and Airborne:
		#walljump
			#JumpStorage
		if GroundSlam:
			JumpStorage = true
		else:
			#when going down a wall
			if velocity.y > 0:
				#GroundSlam for wall going down
				if GroundSlam and not JumpStorage:
					velocity.y = GROUNDSLAM_SPEED
			else:
				#wall GRAVITY if player moving up the wall
				$Slide.emitting = false
				#GroundSlam
				if GroundSlam and not JumpStorage:
					velocity.y = GROUNDSLAM_SPEED
	#Dashing

func _physics_process(delta):
	get_input(delta)
	move_and_slide()
