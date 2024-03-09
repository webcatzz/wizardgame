extends Resource


signal damaged
signal healed
signal buffed
signal debuffed
signal dodged
signal missed

signal died

@export var name: String
@export var sprite: Texture
@export_multiline var description: String

@export_enum("physical", "magic", "heal", "buff", "debuff") var type: String = "physical"
@export var actions: PackedStringArray

@export_group("Stats")
@export var health: int = 1:
	set(value):
		if value < health: emit_signal("damaged")
		elif value > health: emit_signal("healed")
		health = value
@export var stamina: int = 1
@export var attack: int = 1
@export var s_attack: int = 1
@export var defense: int = 0
@export var s_defense: int = 0
@export_range(0, 1, 0.01) var accuracy: float = 0.95
@export_range(0, 1, 0.01) var evasion: float = 0

@export_group("Affinities")
@export_enum("Weak:200", "Neutral:100", "Strong:50") var fire: int = 100
@export_enum("Weak:200", "Neutral:100", "Strong:50") var ice: int = 100
@export_enum("Weak:200", "Neutral:100", "Strong:50") var wind: int = 100
@export_enum("Weak:200", "Neutral:100", "Strong:50") var physical: int = 100
@export_enum("Weak:200", "Neutral:100", "Strong:50") var holy: int = 100
@export_enum("Weak:200", "Neutral:100", "Strong:50") var dark: int = 100
@export var deathblow: String

@export_group("In Battle")
@export var attack_mult: float = 1
@export var s_attack_mult: float = 1
@export var defense_mult: float = 1
@export var s_defense_mult: float = 1
@export var accuracy_mult: float = 1
@export var evasion_mult: float = 1
@export_enum("aflame", "frozen") var status_effect: String


func affect(action: Resource):
	if randf() > action.accuracy:
		match action.type:
			"physical":
				if randf() > evasion:
					action.effect_health = max((action.effect_health - defense) * get_affinity(action.affinity), 1)
					if action.name == deathblow: action.effect_health *= 10
					health -= action.effect_health
				else: emit_signal("dodged")
			"magic":
				if randf() > evasion:
					action.effect_health = max((action.effect_health - s_defense) * get_affinity(action.affinity), 1)
					if action.name == deathblow: action.effect_health *= 10
					health -= action.effect_health
				else: emit_signal("dodged")
			"heal":
				health += action.effect_health
		
		for effect in ["attack", "s_attack", "defense", "s_defense", "accuracy", "evasion", "burn"]:
			if action.get("effect_" + effect) != 1:
				set(effect + "_mult", action.get("effect_" + effect))
				set(effect + "_mult_length", action.effect_length)
				if action.get("effect_" + effect) > 1:
					emit_signal("buffed", effect)
				else:
					emit_signal("debuffed", effect)
	
	if health <= 0:
		emit_signal("died")


func take_action(action: Resource, unique_name: String) -> Resource:
	action.value = attack
	action.actor_type = "enemies"
	action.actor_name = unique_name
	action.target_name = ""
	
	action.type = type
	if type in ["heal", "buff"]:
		action.target_type = "enemies"
	else:
		action.target_type = "party"
	
	return action


func get_affinity(type: String) -> float:
	var value = get(type)
	
	if status_effect == "frozen" and type == "physical": value *= 2
	
	if value == null:
		printerr("Failed to fetch affinity: ", type)
		return 1.0
	else:
		return float(value) / 100
