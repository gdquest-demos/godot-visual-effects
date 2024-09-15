@tool
@icon("res://addons/node-essential-helpers/DemoScreen.svg")
## SceneSlideshow takes its children and allows you to cycle through them.
##
## To use with scenes that require a custom camera, for nodes like Camera2D,
## CanvasLayer, etc.
##
## It has utilities for displaying a label, and creating physical walls so
## physics bodies can't walk out the screen.
##
## It serves as a container for the various demos and isn't directly related to
## any demo functionality.
##
## You can create a node of this type directly to add a screen to any demo, it
## instantiates the nodes it needs in code.
class_name SceneSlideshow
extends "Demo.gd"

## If `true`, load every screen upon opening the demo.
@export var do_load_on_open := false


func _ready() -> void:
	super()
	for child in get_children():
		var screen_loader := child as DemoScreenSlide
		if screen_loader == null:
			continue

		_screens.append(screen_loader)
		var translation_key: String = name.to_lower() + "_" + screen_loader.name.to_lower()
		screen_loader.text = tr(translation_key)
		if screen_loader.text == translation_key:
			print_debug(
				"Missing position key {} for demo {} -> {}".format(
					[translation_key, name, screen_loader.name], "{}"
				)
			)
		if do_load_on_open:
			screen_loader.load_scene()

	assert(
		_screens.size() != 0,
		get_class() + " needs SlideshowSceneLoader instances as children, none found."
	)
	if not Engine.is_editor_hint():
		_set_current_screen_index(_current_screen_index)


func _get_configuration_warnings() -> PackedStringArray:
	for child in get_children():
		if child is DemoScreen2D:
			return PackedStringArray(["SceneSlideshow is not compatible with DemoScreen2D nodes.\n"
				+ "Please convert those to DemoScreenSlide instead."])
	return PackedStringArray([])


func _set_current_screen_index(value: int) -> void:
	super(value)
	_current_screen_index = wrapi(value, 0, _screens.size())

	if _active_screen and has_node(str(_active_screen.name)):
		remove_child(_active_screen)
	_active_screen = _screens[_current_screen_index]
	if not has_node(str(_active_screen.name)):
		add_child(_active_screen)
	_active_screen.display_scene()

	#TODO re-enable this somehow
	#set_areas_visible(_ui.button_visible_shapes.pressed)
	screen_changed.emit()
