extends PanelContainer


@onready var buttons = $Separator/Buttons


func _ready():
	$Separator/Buttons/Default/Start.grab_focus()


func on_start_pressed():
	global.load_save()


func on_settings_pressed():
	buttons.current_tab = 1


func on_quit_pressed():
	get_tree().quit()


func on_master_volume_changed(value: int):
	global.set_volume(value)


func on_music_volume_changed(value: int):
	global.set_volume(value, 1)


func on_sfx_volume_changed(value: int):
	global.set_volume(value, 2)


func on_back_pressed():
	buttons.current_tab = 0
