extends Resource


signal leveled_up

signal money_changed
signal item_added
signal health_changed
signal mana_changed

signal affected
signal died

@export var name: String = "Player"
@export_range(1, 100) var level: int = 1
@export var experience: int

@export_group("Inventory")
@export var equipped: Dictionary = {
	"head": "",
	"body": "",
	"charm": "",
	"weapon": "",
}
@export var money: int:
	set(value):
		money = value
		emit_signal("money_changed", money)
@export var consumables: PackedStringArray
@export var equipment: PackedStringArray
@export var key_items: PackedStringArray

@export_group("Location", "location_")
@export var location_name: String = "test"
@export var location_position: Vector2
@export var location_flags: Dictionary

@export_group("Battle")
@export var health: int = 100:
	set(value):
		health = value
		emit_signal("health_changed", health)
@export var max_health: int = 100:
	set(value):
		max_health = value
		emit_signal("health_changed", health)
@export var mana: int = 100:
	set(value):
		mana = value
		emit_signal("mana_changed", mana)
@export var max_mana: int = 100:
	set(value):
		max_mana = value
		emit_signal("mana_changed", mana)
@export var attack: int = 1
@export var defense: int = 0
@export_range(0, 1, 0.01) var accuracy: float = 0.9
@export_range(0, 1, 0.01) var evasion: float = 0
@export var max_modifiers: int = 1
@export var party: PackedStringArray

@export_group("Settings")
@export_range(0, 100) var master_volume: int = 100
@export_range(0, 100) var music_volume: int = 100
@export_range(0, 100) var sfx_volume: int = 100
@export var battle_timer: bool = true


func add_item(item_name: String):
	[consumables, equipment, key_items][global.get_item(item_name).type].append(item_name)
	print("Recieved item: ", item_name, ".")
	emit_signal("item_added", global.get_item(item_name).type)


func add_experience(value: int):
	experience += value
	if experience > sqrt(level^3) * 1000:
		level += 1
		emit_signal("leveled_up")


func mark_as_interacted(object: Vector2):
	if location_name not in location_flags:
		location_flags[location_name] = []
	location_flags[location_name].append(object)
	print("Marked ", object, " in ", location_name, " as interacted.")


func was_interacted(object: Vector2) -> bool:
	if location_name in location_flags and object in location_flags[location_name]:
		return true
	else:
		return false


func affect(action: Resource):
	match action.type:
		"attack":
			if randf() > evasion:
				action.value = max(action.value - defense, 1)
				health -= action.value
		"heal":
			health += action.value
	if !action.effect_type.is_empty():
		pass
	
	if health > 0:
		emit_signal("affected", action.type)
	else:
		emit_signal("died")
