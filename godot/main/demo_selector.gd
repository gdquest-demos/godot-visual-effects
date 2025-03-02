extends Node

@onready var _demo_picker : DemoPickerUI = $DemoPickerUI
@onready var _demo_player : Node2D = $DemoPlayer
@onready var _button_go_back : Button = $CanvasLayer/ButtonGoBack


func _ready() -> void:
	_demo_picker.demo_requested.connect(load_and_show_demo)
	_button_go_back.pressed.connect(go_back_to_menu)
	_button_go_back.hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (not ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_interface"):
		_button_go_back.visible = not _button_go_back.visible
	elif event.is_action_pressed("go_back_to_menu") and _demo_player.is_loaded():
		go_back_to_menu()


func go_back_to_menu() -> void:
	_demo_player.unload()
	_button_go_back.hide()
	_demo_picker.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func load_and_show_demo() -> void:
	_demo_player.load_demo(_demo_picker.demo_path)
	_demo_picker.hide()
	_button_go_back.show()
