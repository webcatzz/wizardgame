extends PanelContainer


@onready var name_label = $Separator/Player/Panel/Margins/Separator/Basic/Info/Name
@onready var healthbar = $Separator/Player/Panel/Margins/Separator/Basic/Info/HealthBar
@onready var healthbar_label = $Separator/Player/Panel/Margins/Separator/Basic/Info/HealthBar/Value
@onready var manabar = $Separator/Player/Panel/Margins/Separator/Basic/Info/ManaBar
@onready var manabar_label = $Separator/Player/Panel/Margins/Separator/Basic/Info/ManaBar/Value
@onready var stats = $Separator/Player/Panel/Margins/Separator/Stats
@onready var inventory = $Separator/Inventory/Inventory
@onready var description = $Separator/Inventory/Description


func _ready():
	update_stats()
	update_bars()
	for i in range(3):
		update_inventory(i)


func update_stats():
	name_label.text = global.player.name + " (LV. " + str(global.player.level) + ")"
	stats.text = "ATK: " + str(global.player.attack) + "\nDEF: " + str(global.player.defense) + "\nMax. Modifiers: " + str(global.player.max_modifiers)


func update_bars():
	healthbar.max_value = global.player.max_health
	healthbar.value = global.player.health
	healthbar_label.text = str(global.player.health) + "/" + str(global.player.max_health)
	
	manabar.max_value = global.player.max_mana
	manabar.value = global.player.mana
	manabar_label.text = str(global.player.mana) + "/" + str(global.player.max_mana)


func update_inventory(category: int):
	var list = inventory.get_child(category)
	list.clear()
	for i in global.player.get(["consumables", "equipment", "key_items"][category]):
		var item = global.get_item(i)
		list.add_item(item.name, item.texture)


func display_description(item: int):
	if item == -1:
		description.text = "[color=gray]Select an item.[/color]"
		return
	var item_res: Resource
	match inventory.current_tab:
		0:
			item_res = global.get_item(global.player.consumables[item])
		1:
			item_res = global.get_item(global.player.equipment[item])
		2:
			item_res = global.get_item(global.player.key_items[item])
	description.text = "	[color=gray]" + item_res.name + "[/color]\n" + item_res.description
