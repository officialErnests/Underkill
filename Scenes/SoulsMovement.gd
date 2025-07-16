extends CharacterBody2D

var walljumps = 3

#player variables
const SPEED = 400
const GRAVITY = 70
const JUMP_HEIGHT = 500
const GROUNDPOUND_SPEED = 800
const DASH_SPEED = 1000
const DASH_LENGHT = 0.1
const WALL_COYOTE = 0.1


#env variables
const DAMPENING = Vector2(0.85, 0.97)

#states
var Sliding = false
var CanMove = true
var Airborne = false
var OnWall = false
var GroundSlam = false
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
	GROUNDED
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
	$Slide.emitting = true
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

func DisableWallGrav():
	$Slide.emitting = false

func ResetWallJumps() -> void:
	walljumps = 3
	wallSlideSpeed = 0.1


func DetJump() -> void:
	if Input.is_action_just_pressed("Jump"):
		velocity.y -= JUMP_HEIGHT

func DetWallJump() -> void:
	if Input.is_action_just_pressed("Jump") and walljumps > 0:
		walljumps -= 1
		velocity.y = -JUMP_HEIGHT
		velocity.x = wallNormal.x * SPEED

func DetDash() -> void:
	if Input.is_action_just_pressed("Dash") and energy >= 1:
		dashingTime = DASH_LENGHT
		energy -= 1
		PlrMovement = EnumPlrMovement.DASH

func CoyoteWall() -> void:
	wallCoyoti = WALL_COYOTE

func DetCoyoteWall(delta) -> void:
	if wallCoyoti > 0:
		DetWallJump()
		wallCoyoti -= delta/10
	

func GetWallDir() -> void:
	wallNormal = get_wall_normal()

func get_input(delta) -> void:
	delta *= 10
	velocity *= DAMPENING

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
			DisableWallGrav()
			PlrMovement = EnumPlrMovement.AIRBORNE
		if CurentPlayersState == EnumPlayerStates.GROUND:
			CoyoteWall()
			DisableWallGrav()
			PlrMovement = EnumPlrMovement.GROUNDED

	print(EnumPlayerStates.find_key(CurentPlayersState) + " " + EnumPlrMovement.find_key(PlrMovement))

	if PlrMovement == EnumPlrMovement.GROUNDED:
		Movement(delta)
		DetJump()

	if PlrMovement == EnumPlrMovement.AIRBORNE:
		DetCoyoteWall(delta)
		Movement(delta)
		Gravity(delta)
			
	if PlrMovement == EnumPlrMovement.WALL_HUG:
		Movement(delta)
		Gravity(delta)
		DetWallJump()

	if PlrMovement == EnumPlrMovement.WALL_SLIDE:
		Movement(delta)
		WallGrav(delta)
		DetWallJump()

	if PlrMovement != EnumPlrMovement.DASH:
		DetDash()

	if PlrMovement == EnumPlrMovement.DASH:
		Dashing(delta)


	if true:
		return
	
	if is_on_floor():
		Airborne = false
	else:
		Airborne = true
	
	if is_on_wall():
		OnWall = true
	else:
		OnWall = false

	if Airborne:
		if not GroundSlam and Input.is_action_just_pressed("Slide"):
			groundDistance = 0
			velocity.x = 0
			JumpStorage = false
			GroundSlam = true
			$Slide2.emitting = true
			groundDistance = 0
	else:
		if GroundSlam:
			timeSinceLastGroundpund = Time.get_ticks_msec()
			$Slide2.emitting = false
			GroundSlam = false
			JumpStorage = false
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
			GroundSlam = false
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
			velocity.y = GROUNDPOUND_SPEED
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
					velocity.y = GROUNDPOUND_SPEED
			else:
				#wall GRAVITY if player moving up the wall
				$Slide.emitting = false
				#GroundSlam
				if GroundSlam and not JumpStorage:
					velocity.y = GROUNDPOUND_SPEED
	#Dashing

func _physics_process(delta):
	get_input(delta)
	move_and_slide()
