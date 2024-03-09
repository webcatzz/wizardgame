extends Resource


@export var name: String
@export_enum("physical", "magic", "heal", "buff", "debuff") var type: String = "physical"
@export_enum("fire", "ice", "holy", "dark") var affinity: String = "physical"
@export var stamina_cost: int
@export_range(0, 1, 0.01) var accuracy: float = 1

@export_group("Actor", "actor_")
@export_enum("party", "enemies") var actor_type: String
@export var actor_name: String

@export_group("Target", "target_")
@export_enum("party", "enemies") var target_type: String
@export var target_name: String


@export_group("Effects", "effect_")
@export var effect_health: int
@export var effect_stamina: int
@export var effect_attack: int
@export var effect_s_attack: int
@export var effect_defense: int
@export var effect_s_defense: int
@export var effect_accuracy: int
@export var effect_evasion: int
@export var effect_burn: int
@export var effect_length: int
