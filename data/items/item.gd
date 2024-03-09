extends Resource


@export var name: String
@export var texture: Texture
@export_multiline var description: String:
	get:
		if type == 0:
			var additions: PackedStringArray
			if use_health > 0:
				additions.append("[color=red]+" + str(use_health) + " HP[/color].")
			if use_mana > 0:
				additions.append("[color=blue]+" + str(use_health) + " MP[/color].")
			for effect in use_effects:
				additions.append("[color=green]+" + effect + "[/color]")
			return description + " (" + ", ".join(additions) + ")"
		else:
			return description
@export_enum("Consumables", "Equipment", "Key Items") var type: int
@export var price: int

@export_group("On Use", "use_")
@export var use_health: int
@export var use_mana: int
@export var use_effects: Dictionary
@export var use_use: Resource = load("res://data/actions/default.tres")

@export_group("While Equipped", "equip_")
@export_enum("Head", "Body", "Hand", "Charm") var equip_type: String
@export var equip_health: int
@export var equip_mana: int
@export var equip_attack: int
@export var equip_defense: int
@export var equip_effects: PackedStringArray
