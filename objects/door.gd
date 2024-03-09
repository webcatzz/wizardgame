extends Area2D


signal used
signal use_failed

@export var enabled: bool = true
@export var destination: String
@export var pair_path: String
@export_enum("Up", "Down", "Left", "Right") var exit_facing: int = 1
@export_enum("On Interact", "On Enter") var mode: int
@export var sfx: String
@export var size: Vector2i = Vector2i(16, 16)


func _ready():
	monitoring = bool(mode)
	monitorable = !bool(mode)
	$Shape.shape.size = size


func interact(_player: Object):
	if !destination.is_empty() and enabled:
		emit_signal("used")
		if !sfx.is_empty():
			global.play_sfx(sfx)
		global.switch_location(destination, pair_path)
	else:
		emit_signal("use_failed")


func position_player(player: Object):
	player.position = global_position + [Vector2(0, -16), Vector2(0, 16), Vector2(-16, 0), Vector2(16, 0)][exit_facing]
	player.animator.play(["idle_up", "idle_down", "idle_left", "idle_right"][exit_facing])
