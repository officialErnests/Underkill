extends CharacterBody2D

var walljumps = 3

#player variables
const SPEED = 400
const GRAVITY = 70
const JUMP_HEIGHT = 500
const GROUNDPOUND_SPEED = 800
const DASH_SPEED = 1000
const DASH_LENGHT = 100

#env variables
const DAMPENING = Vector2(0.85, 0.97)

#states
var Sliding = false
var CanMove = true
var Dashing = false
var Airborne = false
var OnWall = false
var GroundSlam = false
var JumpStorage = false
var Invincible = false

#script used variables
var slideSPEED = 0.1
var timeSinceLastGroundpund = 0
var groundVelocity = 0
var groundDistance = 0
var dashingTime = 0
var lastDirection = 1
var energy = 3


func get_input(delta) -> void:
	delta *= 10
	velocity *= DAMPENING

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
	
	if CanMove:
		var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
		if input_direction.x == 0:
			lastDirection = 1
		else:
			lastDirection = input_direction
		velocity.x += input_direction.x * SPEED * delta

	if Dashing:
		if dashingTime > 0:
			dashingTime -= delta/10
			$CollisionPolygon2D.scale.y = 1
			velocity = Vector2(DASH_SPEED * lastDirection,0)
			Invincible = true
		else:
			Dashing = false
			Invincible = false
	
	
	if GroundSlam:
		if Dashing:
			GroundSlam = false
			JumpStorage = false
			groundDistance = 0

	if not CanMove:
		if (not GroundSlam or JumpStorage ) and Sliding:
			CanMove = true

	if Airborne:
		if not Dashing and (not GroundSlam or JumpStorage):
			if OnWall:
				$Slide.emitting = true
				velocity.y += delta * GRAVITY * slideSPEED
				slideSPEED += delta * 0.1
				if get_wall_normal().x < 0:
					$Slide.process_material.emission_shape_offset = Vector3(5,-2.5,0)
					$Slide.process_material.direction = Vector3(-0.2,-1,0)
				else:
					$Slide.process_material.emission_shape_offset = Vector3(-5,-2.5,0)
					$Slide.process_material.direction = Vector3(0.2,-1,0)
			else:
				velocity.y += delta * GRAVITY
	else:
		slideSPEED = 0.1
		$Slide.emitting = false
		walljumps = 3
		
		if GroundSlam:
			timeSinceLastGroundpund = Time.get_ticks_msec()
			$Slide2.emitting = false
			GroundSlam = false
			JumpStorage = false
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
		if Input.is_action_just_pressed("Jump") and walljumps > 0:
			walljumps -= 1
			velocity.y = -JUMP_HEIGHT
			velocity.x = get_wall_normal().x * SPEED
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
	if Input.is_action_just_pressed("Dash"):
		dashingTime = DASH_LENGHT

func _physics_process(delta):
	get_input(delta)
	move_and_slide()
