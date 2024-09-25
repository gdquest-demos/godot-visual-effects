@icon("res://addons/node-essential-helpers/DemoScreen.svg")
## This class is is an overarching navigator to move between demo screens
##
## It isn't directly related to any demo functionality.
class_name DemoScreenNavigator
extends "Demo.gd"

signal screen_index_changed

const ROW_SIZE := 3
const DemoScreen := preload("DemoScreen.gd")

## If `true`, load every screen upon opening the demo.
@export var do_preload_screens := false

var _camera := Camera2D.new()

var _screen_size := Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)


func _init():
	_initialize_camera()


func _initialize_camera() -> void:
	_camera.current = true
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 5.0
	_camera.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
	add_child(_camera)


func _ready() -> void:
	super()
	_ready_screens()
	if not Engine.is_editor_hint():
		var start_screen_index := int(get_javascript_parameter('screen', '0'))
		_set_current_screen_index(0)


func _ready_screens():
	var index := 0
	for child in get_children():
		var screen := child as DemoScreen
		if not screen:
			continue

		_screens.append(screen)
		screen.position = _screen_size * Vector2(index % ROW_SIZE, index / ROW_SIZE)
		index += 1
		var translation_key: String = name.to_lower() + "_" + screen.name.to_lower()
		screen.text = tr(translation_key)
		if screen.text == translation_key:
			print_debug(
				"Missing position key {} for demo {} -> {}".format(
					[translation_key, name, screen.name], "{}"
				)
			)
		if do_preload_screens:
			screen.load_scene()

	assert(_screens.size() > 0, "No demo screen instances found as children.")


func _get_configuration_warnings() -> PackedStringArray:
	for child in get_children():
		if child is DemoScreenSlide:
			return PackedStringArray([
				"DemoScreenNavigator is incompatible with DemoScreenSlide. All children must be of type DemoScreen2D.\n"
				+ "If your demo screens use a camera or canvas layer, you need to change this node to SceneSlideshow."
			])
	return PackedStringArray()


func _set_current_screen_index(new_index: int) -> void:
	super(new_index)
	_current_screen_index = wrapi(new_index, 0, _screens.size())
	screen_index_changed.emit()

	_active_screen = _screens[_current_screen_index]
	_active_screen.display_scene()
	snap_camera_to_current_screen()
	set_areas_visible(_ui.button_visible_shapes.button_pressed)
	screen_changed.emit()


func get_javascript_parameter(parameter: String, default):
	#TODO
	#https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html#calling-javascript-from-script
	if OS.has_feature('JavaScript'):#will always return false in Godot 4
			#Javascript is no longer in the feature tags
			#https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
		var js_str := "new URL(window.location.href).searchParams.get('%s');" % [parameter]
		var response = JavaScriptBridge.eval(js_str)
		if response != null:
			return response
	return default


func snap_camera_to_current_screen() -> void:
	var grid_size: Vector2 = get_viewport().get_size_2d_override()
	var ratio: Vector2 = _active_screen.global_position / grid_size
	_camera.position = ratio.floor() * grid_size + grid_size / 2
