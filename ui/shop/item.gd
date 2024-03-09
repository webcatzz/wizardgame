extends PanelContainer


signal focused
signal selected

var data: Resource
var hover = load("res://assets/ui/item_hover.tres")


func _ready():
	$Separator/Icon.texture = data.texture
	$Separator/Name.text = data.name
	$Separator/Price.text = str(data.price)


func on_focus():
	set("theme_override_styles/panel", hover)
	emit_signal("focused", self)


func on_focus_exit():
	set("theme_override_styles/panel", null)


func input(event: InputEvent):
	if event.is_action_released("ui_accept"):
		emit_signal("selected", self)
