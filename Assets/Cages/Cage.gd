extends Node2D

@export var CagePosition = Vector2(0,0)
@export var CageSize = Vector2(200,200)
var screenSize = DisplayServer.screen_get_size()
const lineSize = 1

func _ready() -> void:
	SizeChange()

func _process(_delta: float) -> void:
	SizeChange()

func SizeChange() -> void:
	$Line2D.points[0] = Vector2(CagePosition.x - CageSize.x/2 - lineSize, CagePosition.y - CageSize.y/2 - lineSize)
	$Line2D.points[1] = Vector2(CagePosition.x + CageSize.x/2 + lineSize, CagePosition.y - CageSize.y/2 - lineSize)
	$Line2D.points[2] = Vector2(CagePosition.x + CageSize.x/2 + lineSize, CagePosition.y + CageSize.y/2 + lineSize)
	$Line2D.points[3] = Vector2(CagePosition.x - CageSize.x/2 - lineSize, CagePosition.y + CageSize.y/2 + lineSize)
	$Right.position = Vector2(CagePosition.x + CageSize.x/2, CagePosition.y - CageSize.y/2)
	$Left.position = Vector2(CagePosition.x - CageSize.x/2, CagePosition.y - CageSize.y/2)
	$Top.position = Vector2(CagePosition.x - CageSize.x/2, CagePosition.y - CageSize.y/2)
	$Bottom.position = Vector2(CagePosition.x - CageSize.x/2, CagePosition.y + CageSize.y/2)
	$Right/CS.shape.b = Vector2(0, CageSize.y)
	$Left/CS.shape.b = Vector2(0, CageSize.y)
	$Top/CS.shape.b = Vector2(CageSize.x, 0)
	$Bottom/CS.shape.b = Vector2(CageSize.x, 0)