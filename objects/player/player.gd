extends CharacterBody2D


const SPEED: int = 75

var speed_modifier: float = 1
var can_move: bool = true

@onready var sprite = $Sprite
@onready var interactor = $Interactor
@onready var animator = $Animator
@onready var dialogue = $UI/Dialogue
@onready var info = $UI/Info


func _physics_process(_delta):
	var input_vector: Vector2
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	if input_vector != Vector2.ZERO and can_move:
		input_vector = input_vector.normalized()
		if input_vector.x > 0:
			animator.play("move_right")
			interactor.rotation_degrees = -90
		elif input_vector.x < 0:
			animator.play("move_left")
			interactor.rotation_degrees = 90
		elif input_vector.y > 0:
			animator.play("move_down")
			interactor.rotation_degrees = 0
		elif input_vector.y < 0:
			animator.play("move_up")
			interactor.rotation_degrees = 180
		velocity = input_vector * SPEED * speed_modifier
	else:
		match animator.current_animation:
			"move_right":
				animator.play("idle_right")
			"move_left":
				animator.play("idle_left")
			"move_down":
				animator.play("idle_down")
			"move_up":
				animator.play("idle_up")
		velocity = Vector2.ZERO
	
	move_and_slide()


func _input(event: InputEvent):
	if event.is_action_released("interact"):
		if interactor.is_colliding():
			var target = interactor.get_collider()
			if target.monitorable:
				if target.script == null:
					target.get_parent().interact(self)
				else:
					target.interact(self)
	elif event.is_action_released("stats") and !dialogue.visible:
		info.visible = !info.visible
		can_move = !info.visible
	elif event.is_action_pressed("modify"):
		speed_modifier *= 0.5
		animator.speed_scale *= 0.5
	elif event.is_action_released("modify"):
		speed_modifier /= 0.5
		animator.speed_scale /= 0.5
	elif event.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func recieve_item(item: String):
	global.player.add_item(item)
	var item_res = global.get_item(item)
	dialogue.animate("(Recieved [img]" + item_res.texture.resource_path + "[/img]" + item_res.name + ".)")
