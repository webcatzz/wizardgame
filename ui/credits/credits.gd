extends PanelContainer


@onready var credits = $Separator/Credits
@onready var thanks = $Separator/Thanks
@onready var from = $Separator/From


func _ready():
	credits.max_lines_visible = 0
	await get_tree().create_timer(1).timeout
	for i in range(credits.get_line_count()):
		credits.max_lines_visible += 1
		await get_tree().create_timer(2).timeout
	await get_tree().create_timer(0.5).timeout
	thanks.visible = true
	await get_tree().create_timer(3.5).timeout
	from.visible = true
	from.max_lines_visible = 1
	await get_tree().create_timer(5).timeout
	from.max_lines_visible = 2
	modulate = Color.BLACK
