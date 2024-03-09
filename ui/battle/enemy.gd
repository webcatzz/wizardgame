extends Control


signal selected

@export var data: Resource

@onready var name_label = $Origin/Name
@onready var sprite = $Origin/Sprite
@onready var health_bar = $Origin/Health
@onready var damage_label = $Origin/Damage
@onready var animator = $Animator


func _ready():
	sprite.texture = data.sprite
	
	name_label.modulate.a = 0
	name_label.text = data.name
	health_bar.modulate.a = 0
	health_bar.max_value = data.health
	health_bar.value = data.health
	
	var dist_from_origin = (0.5 * sprite.texture.get_size().y * sprite.scale.y) + 8
	name_label.position.y = -(dist_from_origin + name_label.size.y)
	health_bar.position.y = dist_from_origin
	
	$Origin.position.y = -(dist_from_origin + name_label.size.y - 20)


func affected(action_type: String):
	match action_type:
		"attack":
			damage_label.text = str(health_bar.value - data.health)
			var tween = get_tree().create_tween()
			tween.tween_property(health_bar, "value", data.health, 0.5)
			animator.play("attacked")
			await animator.animation_finished
		"healing":
			damage_label.text = str(data.health - health_bar.value)
			var tween = get_tree().create_tween()
			tween.tween_property(health_bar, "value", data.health, 0.5)
			animator.play("healed")
			await animator.animation_finished
		"buff":
			pass
		"debuff":
			global.play_sfx("debuff")


func died():
	damage_label.text = str(health_bar.value - data.health)
	var tween = get_tree().create_tween()
	tween.tween_property(health_bar, "value", data.health, 0.5)
	animator.play("died")


func on_focus():
	sprite.modulate = Color(1.1, 1.1, 1.1)
	name_label.modulate.a = 1
	health_bar.modulate.a = 1


func on_focus_exit():
	sprite.modulate = Color(1, 1, 1)
	name_label.modulate.a = 0
	health_bar.modulate.a = 0


func input(event: InputEvent):
	if event.is_action_pressed("ui_accept"): emit_signal("selected")
