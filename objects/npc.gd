extends StaticBody2D


@export var sprite: Texture = load("res://assets/objects/npc.png")
@export_multiline var dialogue: String
@export var interacted: bool
@export_multiline var second_dialogue: String


func _ready():
	$Sprite.texture = sprite
	if dialogue.is_empty():
		$Interactor.queue_free()


func interact(player: Object):
	if second_dialogue.is_empty():
		player.dialogue.animate(dialogue)
	else:
		if interacted:
			player.dialogue.animate(second_dialogue)
		else:
			player.dialogue.animate(dialogue)
			interacted = true
