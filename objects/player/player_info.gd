extends CenterContainer


@onready var info = $Container/Separator/Main/Player/Text
@onready var stats = $Container/Separator/Main/Stats
@onready var inventory = $Container/Separator/Inventory


func _ready():
	info.text %= [global.player.name, global.player.level]
	stats.text %= [global.player.attack, global.player.defense]
	
	for i in range(3):
		update_inventory(i)
	global.player.inventory_changed.connect(update_inventory)


func update_inventory(category: int):
	var list = inventory.get_child(category)
	list.clear()
	for item_name in [global.player.consumables, global.player.equipment, global.player.key_items][category]:
		var item = global.get_item(item_name)
		list.add_item(item.name, item.texture)
