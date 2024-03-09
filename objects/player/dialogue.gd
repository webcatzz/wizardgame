extends PanelContainer


signal OK

var portraits: PackedStringArray = ["PLAYER"]

@onready var left_sprite = $Sprites/Left
@onready var right_sprite = $Sprites/Right
@onready var speaker_name = $Box/Text/Speaker
@onready var text = $Box/Text/Text
@onready var animator = $Animator
@onready var player = get_parent().get_parent()


func animate(dialogue) -> void:
	player.can_move = false
	speaker_name.text = ""
	visible = true
	grab_focus()
	animator.play("open")
	await animator.animation_finished
	
	dialogue = dialogue.split("\n")
	for line in dialogue:
		if line.begins_with("("): # narration
			speaker_name.visible = false
			text.text = line
		else: # regular dialogue
			line = line.split(":")
			speaker_name.text = line[0].replace("PLAYER", global.player.name)
			speaker_name.visible = true
			text.text = line[1].strip_edges()
			
			left_sprite.modulate.v = 0.5
#			right_sprite.modulate.v = 0.5
			
			if line[0] in portraits:
				animate_portrait(line[0])
		animator.play("fade")
		await animator.animation_finished
		await OK
		animator.play_backwards("fade")
		await animator.animation_finished
	
	
	animator.play_backwards("open")
	await animator.animation_finished
	visible = false
	release_focus()
	player.can_move = true
	
	left_sprite.texture = null
	right_sprite.texture = null


func open_options():
	pass


func input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		emit_signal("OK")


func animate_portrait(sprite_name: String):
	var sprite_node: Node
	
	sprite_node = left_sprite
	left_sprite.modulate.v = 1
	
	if sprite_name.is_empty():
		sprite_node.texture = null
		return
	
	if ResourceLoader.exists("res://assets/portraits/" + sprite_name.to_snake_case() + ".png"):
		sprite_node.texture = load("res://assets/portraits/" + sprite_name.to_snake_case() + ".png")
	else:
		printerr("Portrait not found: ", sprite_name)
	
	sprite_node.custom_minimum_size = sprite_node.texture.get_size() * 1.5
