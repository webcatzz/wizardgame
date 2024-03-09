extends TabContainer


signal action_finished

var action_template = load("res://ui/battle/action.tres")
var action: Resource
var spell_text: String

@onready var buttons = $ActionSelect/Buttons
@onready var animator = get_node("../Animator")
@onready var root = get_node("/root/Root")
@onready var timer = get_node("../Timer")
@onready var particles = $SpellEnterer/Text/Particles


func _ready():
	action = action_template.duplicate()
	
	for i in global.player.consumables:
		var item: Resource = global.get_item(i)
		$Inventory/List.add_item(item.name, item.texture)


func select_action(enemy_name: String):
	action.actor_name = global.player.name
	action.target_name = enemy_name
	
	buttons.visible = true
	buttons.get_child(0).grab_focus()
	if timer.enabled:
		timer.visible = true
	timer.count_down(2)


func open_inventory():
	timer.stop()
	current_tab = 1


func item_chosen(index: int):
	var item: Resource = global.get_item(global.player.consumables[index])
	global.player.consumables.remove_at(index)
	
	if item.use_health > 0 or item.use_stamina > 0:
		action.type = "heal"
		action.target_type = "party"
		action.effect_health = item.use_health
		action.effect_stamina = item.use_stamina
	
	end_action()


func enter_spell():
	timer.stop()
	action.type = "magic"
	
	animator.play("enter_spell")
	await animator.animation_finished
	buttons.visible = false
	timer.count_down(3)


func spell_entered(text: String):
	spell_text = text
	process_spell()
	end_action()


func end_action():
	timer.stop()
	timer.visible = false
	animator.play("RESET")
	
	root.action_queue.append(action)
	
	$SpellEnterer/Text.clear()
	action = action_template.duplicate()
	
	emit_signal("action_finished")


func process_spell():
	if spell_text.is_empty(): return
	var spell = spell_text.to_lower().split(" ", false)
	action.value = global.player.attack
	match spell[-1]: # types go here
		"heal", "<3":
			action.type = "healing"
		_:
			action.type = "attack"
	if spell.size() > 1:
		spell.remove_at(spell.size() - 1)
		for modifier in spell:
			match modifier: # modifiers go here
				"wind", "physical", "holy", "dark":
					action.affinity = modifier
				"fire", "fiery", "flame", "flaming", "scorch", "scorching", "blaze", "blazing", "burn", "ember":
					action.affinity = "fire"
				"ice", "frost", "freeze":
					action.affinity = "ice"
