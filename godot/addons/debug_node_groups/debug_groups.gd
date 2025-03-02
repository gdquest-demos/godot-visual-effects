@tool
extends Control

signal group_selected(group)

var groups := NodeEssentialsPalette.DEBUG_DRAWING_GROUPS

@onready var _collision_shape_container : BoxContainer = find_child("CollisionShapeOptions")
@onready var _toggle_draw_button : Button = find_child("ToggleDrawButton")
@onready var _instructions_label : Label  = find_child("InstructionsLabel")


func _ready() -> void:
	for group in groups:
		var button := Button.new()
		button.text = group
		button.pressed.connect(group_selected.emit.bind(group))
		_collision_shape_container.add_child(button)
	_toggle_draw_button.pressed.connect(group_selected.emit.bind(""))


func show_toggle_draw_option() -> void:
	_hide_all()
	_toggle_draw_button.show()


func show_collision_shape_options() -> void:
	_hide_all()
	_collision_shape_container.show()


func show_instructions() -> void:
	_hide_all()
	_instructions_label.show()


func _hide_all() -> void:
	for node in [_collision_shape_container, _toggle_draw_button, _instructions_label]:
		node.hide()
