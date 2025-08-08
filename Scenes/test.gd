extends CharacterBody2D
@export var SPEED := 300
@export var JUMP_VELOCITY := -300
@export var GRAVITY := 1000
@export var ANIMATED_SPRITE : AnimatedSprite2D
func _physics_process(delta: float) -> void:
    # Apply gravity
    if not is_on_floor():
        velocity.y += GRAVITY * delta
    else:
        # Reset vertical velocity when on floor
        velocity.y = 0
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
    var direction := Input.get_axis("move_left", "move_right")
    if direction != 0:
        velocity.x = direction*SPEED
        ANIMATED_SPRITE.play("running")
    else:
        velocity.x = move_toward(velocity.x,0,delta)
        ANIMATED_SPRITE.play("Default")
    move_and_slide()