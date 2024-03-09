extends Resource


@export var shopkeeper_name: String
@export var shopkeeper_texture: Texture
@export var inventory: PackedStringArray
@export_multiline var snippets: Dictionary = {
	"default": "",
	"on_select": "",
	"on_purchase": "",
	"while_selling": "",
	"on_sell": "",
	"while_talking": "",
	"on_leave": "",
}
@export_multiline var dialogue: Dictionary
