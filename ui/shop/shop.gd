extends VBoxContainer


signal shop_closed

var shop: Resource
var selected_item: Node

@onready var dialogue = $Shopkeeper/Dialogue
@onready var money_label = $Shop/Options/List/Money/Label
@onready var display = $Shop/Display
@onready var shop_inventory = $Shop/Display/ShopInventory
@onready var player_inventory = $Shop/Display/PlayerInventory
@onready var dialogue_picker = $Shop/Display/Dialogue
@onready var purchase_confirm = $PurchaseConfirm
@onready var purchase_fail = $PurchaseFail
@onready var sell_confirm = $SellConfirm


func load_shop(shop_name):
	if ResourceLoader.exists("res://data/shops/" + shop_name + ".tres"):
		shop = load("res://data/shops/" + shop_name + ".tres")
	else:
		printerr("Shop not found!")
		shop = load("res://data/shops/default.tres")
	
	$Shopkeeper/Sprite.texture = shop.shopkeeper_texture
	money_label.text = str(global.player.money)
	global.player.money_changed.connect(set_money)
	dialogue.text = shop.snippets.default
	
	var item_template: PackedScene = load("res://ui/shop/item.tscn")
	for item in shop.inventory:
		var listing = item_template.instantiate()
		listing.data = global.get_item(item)
		listing.selected.connect(item_selected)
		shop_inventory.add_child(listing)
	for item in global.player.equipment:
		var listing = item_template.instantiate()
		listing.data = global.get_item(item)
		listing.selected.connect(item_selected.bind(true))
		player_inventory.add_child(listing)
	for item in global.player.consumables:
		var listing = item_template.instantiate()
		listing.data = global.get_item(item)
		listing.selected.connect(item_selected.bind(true))
		player_inventory.add_child(listing)
	for option in shop.dialogue:
		dialogue_picker.add_item(option)


func item_selected(item: Node, selling: bool = false):
	selected_item = item
	if !selling:
		if global.player.money > selected_item.data.price:
			purchase_confirm.popup_centered()
			display_dialogue(3)
		else:
			purchase_fail.popup_centered()
	else:
		sell_confirm.popup_centered()
		display_dialogue(3)


func item_purchased():
	selected_item.queue_free()
	global.player.money -= selected_item.data.price
	display_dialogue(4)


func item_sold():
	selected_item.queue_free()
	global.player.money += selected_item.data.price
	display_dialogue(5)


func display_dialogue(index: int = display.current_tab):
	match index:
		0: # switching to buy menu
			dialogue.text = shop.snippets.default
		1: # switching to sell menu
			dialogue.text = shop.snippets.while_selling
		2: # switching to talk menu
			dialogue.text = shop.snippets.while_talking
		3: # selecting an item
			dialogue.text = shop.snippets.on_select
		4: # buying an item
			dialogue.text = shop.snippets.on_purchase
		5: # selling an item
			dialogue.text = shop.snippets.on_sell
		6: # leaving
			dialogue.text = shop.snippets.on_leave


func set_money(value: int):
	money_label.text = str(value)


func on_leave():
	emit_signal("shop_closed")
