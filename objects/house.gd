extends StaticBody2D


@export var inside: String:
	set(value):
		inside = value
		$Door.destination = inside
