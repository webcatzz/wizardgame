extends TabContainer


var progress: int = 0


func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		progress += 1
