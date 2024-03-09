extends PanelContainer


signal battle_ended

var action_template = load("res://ui/battle/action.tres")
var party: Dictionary = {
	global.player.name: global.player
}
var enemies: Dictionary = {}
var action_queue: Array[Resource] = []

@onready var enemy_display = $Enemies/Separator
@onready var health_bar = $Info/Separator/Health
@onready var mana_bar = $Info/Separator/Mana
@onready var controls = $Controls


func _ready():
	global.play_music(["strife", "times_up"].pick_random())
	
	# setting info
	$Info/Separator/Name.text = global.player.name
	health_bar.max_value = global.player.max_health
	health_bar.value = global.player.health
	global.player.health_changed.connect(set_bar.bind("health"))
	mana_bar.max_value = global.player.max_mana
	mana_bar.value = global.player.mana
	global.player.mana_changed.connect(set_bar.bind("mana"))
	
#	for member in global.player.party:
#		party.merge({member: global.get_battler(member)})
#		var member_sprite = $Controls/ActionSelect.get_child(-1).duplicate()
#		member_sprite.position += Vector2(8, 8)
	
	# intro animation
	$Border.border_width = max(get_viewport().size.x, get_viewport().size.y) / 8
	modulate = Color.BLACK
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($Border, "border_width", 32, 0.2)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)


func await_actions():
	for member in party:
		enemy_display.get_child(0).grab_focus()
		print("Awaiting action from ", member, "...")
		await controls.action_finished
	
	for enemy in enemies:
		action_queue.append(enemies[enemy].take_action(action_template.duplicate(), enemy))
	
	run_actions()


func run_actions():
	print("Running ", action_queue.size(), " actions...")
	for action in action_queue:
		if action.actor_name in get(action.actor_type):
			var target: Resource
			if action.target_name.is_empty():
				action.target_name = get(action.target_type).keys().pick_random()
			target = get(action.target_type)[action.target_name]
			
			target.affect(action)
			if target.health <= 0:
				get(action.target_type).erase(action.target_name)
			if action.target_type == "enemies":
				await enemy_display.get_node(action.target_name).animator.animation_finished
			else:
				await get_tree().create_timer(0.5).timeout
			
			print(" ".join([action.actor_name.capitalize(), action.type + "ed", action.target_name.capitalize(), "for", action.value]))
	
	for enemy in enemies:
		run_status_effects(enemy)
	for member in party:
		run_status_effects(member)
	
	await get_tree().process_frame
	if enemies.is_empty():
		emit_signal("battle_ended")
	else:
		action_queue.clear()
		await_actions()


func run_status_effects(battler: Resource):
	if battler.status_effect.is_empty(): return
	match battler.status_effect:
		"aflame":
			battler.health -= 1
		"frozen":
			pass
	if randf() > 0.25: battler.status_effect = ""


func add_enemies(list: PackedStringArray):
	var enemy_template: PackedScene = load("res://ui/battle/Enemy.tscn")
	for enemy_name in list:
		var enemy = global.get_battler(enemy_name).duplicate()
		var enemy_node: Node = enemy_template.instantiate()
		enemy_node.data = enemy
		
		if enemy_name not in enemies:
			enemies.merge({enemy_name: enemy})
			enemy_node.name = enemy_name
		else:
			var unique_enemy_name: String = enemy_name + "_2"
			var unique_enemy_index: int = 2
			while unique_enemy_name in enemies:
				unique_enemy_name = unique_enemy_name.replace(str(unique_enemy_index), str(unique_enemy_index + 1))
				unique_enemy_index += 1
			enemies.merge({unique_enemy_name: enemy})
			enemy_node.name = unique_enemy_name
		
		enemy_display.add_child(enemy_node)
		enemy_node.selected.connect(controls.select_action.bind(enemy_node.name))
		enemy.affected.connect(enemy_node.affected)
		enemy.died.connect(enemy_node.died)
	
	await_actions()


func set_bar(value: int, type: String):
	var bar = get(type + "_bar")
	var tween = get_tree().create_tween()
	tween.tween_property(bar, "value", value, 0.2)
