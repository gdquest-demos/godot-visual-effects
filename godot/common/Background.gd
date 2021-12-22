class_name Background
extends CanvasLayer

export var visible := true setget set_visible

onready var _texture := $TextureRect


func set_visible(value: bool) -> void:
	visible = value
	if not is_inside_tree():
		yield(self, "ready")
	_texture.visible = visible
