extends Node2D

var player = null
var damage = 0
var damage_reaction = "vanish"
var damaged_amount = 0

func _process(delta: float) -> void:
	match damage_reaction:
		"vanish":
			if player and damaged_amount == 0:
				if player.damage(damage):
					damaged_amount += 1
					scale *= 2
					$Audio.play()
			if damaged_amount > 0:
				modulate += (Color(1,1,1,0) - modulate) * delta * 5
				scale += (Vector2.ZERO - scale) * delta * 3

func _on_collision_body_exited(body:Node2D) -> void:
	if body.is_in_group("Player"):
		player = null

func _on_collision_body_entered(body:Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
