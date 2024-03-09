extends Area2D


signal used

@export var shop: String
@export var size: Vector2i = Vector2i(16, 16)


func _ready():
	$Shape.shape.size = size


func interact(_player: Object):
	global.open_shop(shop)
