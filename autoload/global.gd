extends Node


var player: Resource = load("res://data/Player.tres")
var dialogue_indices: Dictionary = {}
var prev_focused: Control

@onready var music = $Music
@onready var sfx = $SFX
@onready var animator = $Animator
@onready var pause_screen = $PauseScreen


func _ready():
#	parse_dialogue()
	
	$PauseScreen/Container/Separator/Separator/Volume/MasterSlider.value = player.master_volume
	$PauseScreen/Container/Separator/Separator/Volume/MusicSlider.value = player.music_volume
	$PauseScreen/Container/Separator/Separator/Volume/SfxSlider.value = player.sfx_volume
	$PauseScreen/Container/Separator/Separator/BattleTimer.button_pressed = player.battle_timer


# DATA MANAGEMENT

func save():
	player.location_position = get_node("/root/Root/Player").position
	ResourceSaver.save(player, "res://data/player.tres")
	print("Saved game.")


func load_save():
	animator.play("fade_out")
	await animator.animation_finished
	
	get_tree().change_scene_to_file("res://worlds/" + player.location_name + ".tscn")
	await get_tree().process_frame
	get_node("/root/Root/Player").position = player.location_position
	if get_node("/root/Root").has_meta("music"):
		play_music(get_node("/root/Root").get_meta("music"))
	
	animator.play_backwards("fade_out")


func quit():
	save()
	get_tree().change_scene_to_file("res://ui/title/title.tscn")


func parse_dialogue():
	var time_started = Time.get_ticks_msec()
	
	# fetching from file
	var file = FileAccess.open("res://data/dialogue.txt", FileAccess.READ)
	var content: String = file.get_as_text()
	file = null
	
	var dialogue_index: int = 0
	var search_index: int = -1
	for i in range(content.count("# ")):
		search_index = content.find("# ", search_index + 1)
		var dialogue_name = content.substr(search_index + 2, content.find("\n", search_index) - search_index - 2)
		dialogue_indices[dialogue_name] = dialogue_index
		dialogue_index += 1
	
	print("Dialogue parsed in ", Time.get_ticks_msec() - time_started, "ms.")
	print(dialogue_indices)


func fetch_dialogue(dialogue_name: String) -> String:
	var time_started = Time.get_ticks_msec()

	var file = FileAccess.open("res://data/dialogue.txt", FileAccess.READ)
	var content = file.get_as_text()
	file = null

	var dialogue: String = content.get_substr()
	print("Fetched dialogue in ", Time.get_ticks_msec() - time_started, "ms.")
	return dialogue


func get_item(item_name: String) -> Resource:
	var path = "res://data/items/" + item_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path)
	else:
		printerr("Item not found: ", item_name)
		return load("res://data/items/default.tres")


func get_battler(battler_name: String) -> Resource:
	var path = "res://data/battlers/" + battler_name + ".tres"
	if ResourceLoader.exists(path):
		return load(path)
	else:
		printerr("Battler not found: ", battler_name)
		return load("res://data/battlers/default.tres")


# SWITCHING SCENES

func switch_location(location_name: String, door_path: String = ""):
	print("Switched from ", player.location_name, " to ", location_name, " at ", door_path, ".")
	animator.play("fade_out")
	await animator.animation_finished
	
	player.location_name = location_name
	get_tree().change_scene_to_file("res://worlds/" + location_name + ".tscn")
	await get_tree().process_frame
	var scene_root = get_node("/root/Root")
	if !door_path.is_empty():
		await get_node_or_null("/root/Root/" + door_path).position_player(get_node("/root/Root/Player"))
	if scene_root.has_meta("music"):
		play_music(scene_root.get_meta("music"))
	
	animator.play_backwards("fade_out")
	await animator.animation_finished


func start_battle(enemies: PackedStringArray):
	player.location_position = get_node("/root/Root/Player").position
	var music_stream = music.stream
	
	get_tree().change_scene_to_file("res://ui/battle/battle.tscn")
	await get_tree().process_frame
	print("Battle started!")
	get_node("/root/Root").add_enemies(enemies)
	
	await get_node("/root/Root").battle_ended
	print("Battle ended.")
	animator.play("fade_out")
	await animator.animation_finished
	
	get_tree().change_scene_to_file("res://worlds/" + player.location_name + ".tscn")
	await get_tree().process_frame
	get_node("/root/Root/Player").position = player.location_position
	music.stream = music_stream
	music.play()
	animator.play_backwards("fade_out")


func open_shop(shop_name: String):
	player.location_position = get_node("/root/Root/Player").position
	var music_stream = music.stream
	
	animator.play("fade_out")
	await animator.animation_finished
	get_tree().change_scene_to_file("res://ui/shop/shop.tscn")
	await get_tree().process_frame
	print("Opened shop: ", shop_name)
	get_node("/root/Root").load_shop(shop_name)
	animator.play_backwards("fade_out")
	
	await get_node("/root/Root").shop_closed
	print("Shop closed.")
	animator.play("fade_out")
	await animator.animation_finished
	
	get_tree().change_scene_to_file("res://worlds/" + player.location_name + ".tscn")
	await get_tree().process_frame
	get_node("/root/Root/Player").position = player.location_position
	music.stream = music_stream
	music.play()
	animator.play_backwards("fade_out")


# AUDIO SYSTEMS

func play_music(music_name: String):
	if ResourceLoader.exists("res://assets/music/" + music_name + ".mp3"):
		print("Now playing: ", music_name)
		music.stream = load("res://assets/music/" + music_name + ".mp3")
		music.play()
	else:
		printerr("Music not found: ", music_name)


func play_sfx(sfx_name: String):
	if ResourceLoader.exists("res://assets/sfx/" + sfx_name + ".mp3"):
		sfx.stream = load("res://assets/sfx/" + sfx_name + ".mp3")
		sfx.play()
	else:
		printerr("SFX not found: ", sfx_name)


func stop_music():
	music.stop()


func toggle_music():
	music.stream_paused = !music.stream_paused


func set_volume(value: int, type: int = 0):
	var db: float = linear_to_db(float(value) / 100)
	match type:
		0: # master
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
			player.master_volume = value
		1: # music
			music.volume_db = db
			player.music_volume = value
		2: # sfx
			sfx.volume_db = db
			player.sfx_volume = value


# MISC.

func _unhandled_key_input(event: InputEvent):
	if event.is_action_released("ui_cancel"):
		toggle_pause()


func toggle_pause():
	if pause_screen.visible:
		get_tree().paused = false
		animator.play_backwards("pause")
		await animator.animation_finished
		pause_screen.visible = false
		if prev_focused != null:
			prev_focused.grab_focus()
	else:
		get_tree().paused = true
		pause_screen.visible = true
		animator.play("pause")
		prev_focused = get_viewport().gui_get_focus_owner()
		$PauseScreen/Container/Separator/Separator/Resume.grab_focus()


func set_battle_timer(value):
	player.battle_timer = value
