class_name TopLabel
extends Node

@export var text: String: set = set_text

var visible := true: set = set_visible

@onready var _label := $Background/Label
@onready var _background := $Background


func set_text(new_text: String) -> void:
	text = new_text
	if not is_inside_tree():
		await self.ready
	_label.text = new_text


func get_size() -> Vector2:
	return _label.size


func set_visible(value: bool) -> void:
	visible = value
	if not is_inside_tree():
		await self.ready
	_background.visible = visible
