extends Resource


@export_enum("attack", "heal", "buff", "debuff", "item") var type: String = "attack"
@export_enum("fire", "ice", "wind", "physical", "holy", "dark") var affinity: String = "physical"
@export var value: int = 0

@export_group("Actors")
@export_enum("party", "enemies") var actor_type: String = "party"
@export var actor_name: String
@export_enum("party", "enemies") var target_type: String = "enemies"
@export var target_name: String

@export_group("Effects", "effect_")
@export_enum("attack", "defense", "burn", "freeze", "poison") var effect_type: String
@export var effect_multiplier: float = 0
@export var effect_length: int = 0
