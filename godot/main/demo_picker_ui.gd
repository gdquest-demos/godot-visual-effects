class_name DemoPickerUI
extends Control

# warning-ignore:unused_signal
signal demo_requested

var demo_path: String: set = set_demo_path

@onready var _list : DemoList = find_child("DemoList")

@onready var _load_button : Button = find_child("LoadButton")
@onready var _quit_button : Button = find_child("QuitButton")
@onready var _help_button : Button = find_child("HelpButton")

@onready var _search_bar : LineEdit = find_child("SearchBar")
@onready var _search_label : Label = find_child("SearchLabel")

@onready var _help_window : ColorRect = find_child("HelpWindow")

@onready var _filter_button_container : VBoxContainer = find_child("FilterButtons")


func _ready() -> void:
	_load_button.pressed.connect(demo_requested.emit)
	_list.demo_selected.connect(set_demo_path)
	_list.demo_requested.connect(demo_requested.emit)
	_list.display_updated.connect(_on_DemoList_display_updated)
	#_search_bar.text_submitted.connect(_on_LineEdit_text_entered)
	_quit_button.pressed.connect(quit_game)
	_help_button.pressed.connect(_help_window.show)
	_help_window.gui_input.connect(_on_HelpWindow_gui_input)
	
	_list.setup(_filter_button_container.get_children())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("search"):
		_search_bar.grab_focus()
	elif event.is_action_pressed("ui_cancel"):
		if _help_window.visible:
			_help_window.hide()
		else:
			_search_bar.clear()


func set_demo_path(value: String) -> void:
	demo_path = value
	_load_button.disabled = demo_path == ""


func quit_game() -> void:
	get_tree().quit()


func _on_LineEdit_text_changed(new_text: String) -> void:
	_search_label.visible = new_text == ""
	_list.update_display(new_text)


func _on_DemoList_display_updated(item_count: int):
	_load_button.disabled = item_count == 0


func _on_HelpWindow_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		_help_window.hide()
