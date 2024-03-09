extends StaticBody2D


@export var mimic: bool = false
var loot: Array[String] = [
	"Soda"
]


func _ready():
	if global.player.was_interacted(position):
		$Sprite.texture = load("res://assets/objects/trashcan_open.png")
		$Sprite.offset = Vector2(randi_range(-1, 1), randi_range(-2, 2))
		if randf() > 0.5: $Sprite.flip_h = true


func interact(player: Object):
	if !global.player.was_interacted(position):
		global.player.mark_as_interacted(position)
		global.play_sfx("trash")
		
		$Sprite.texture = load("res://assets/objects/trashcan_open.png")
		$Sprite.offset = Vector2(randi_range(-1, 1), randi_range(-2, 2))
		if randf() > 0.5: $Sprite.flip_h = true
		
		if mimic:
			$Sprite.texture = load("res://assets/objects/trashcan_demon.png")
			global.stop_music()
			player.can_move = false
			await get_tree().create_timer(1.5).timeout
			
			if randf() > 0.5:
				if randf() > 0.75: global.start_battle(["trash_bag", "trash_demon", "trash_bag"])
				else: global.start_battle(["trash_bag", "trash_demon"])
			else: global.start_battle(["trash_demon"])
		else:
			player.recieve_item(loot.pick_random())
