extends CanvasLayer
class_name UIDemo

const UIControlsList := preload("res://main/ui_controls_list.tscn")

@onready var button_previous : TextureButton = $UI/HBoxContainer2/PreviousButton
@onready var button_next : TextureButton = $UI/HBoxContainer2/NextButton
@onready var button_visible_shapes : Button = $UI/HBoxContainer/ShowDebugButton
@onready var button_reset : Button = $UI/HBoxContainer/ResetButton

@onready var _ui := $UI

var _controls_list: Control = null

var _are_controls_visible := true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_controls_visible"):
		_are_controls_visible = not _are_controls_visible
	elif event.is_action_pressed("toggle_interface"):
		_ui.visible = not _ui.visible
		if _controls_list:
			_controls_list.visible = _ui.visible


func populate_controls(input_actions: Array, movement_scheme: int = Constants.MovementSchemes.NONE) -> void:
	if _controls_list:
		_controls_list.queue_free()

	_controls_list = UIControlsList.instantiate()
	add_child(_controls_list)
	_controls_list.setup(input_actions, movement_scheme)
	_controls_list.visible = _ui.visible
	if not _are_controls_visible:
		_controls_list.toggle_panel(false)
