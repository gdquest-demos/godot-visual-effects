@tool
@icon("res://addons/node-essential-helpers/DemoScreen.svg")
## Base class for DemoScreen2D and DemoScreenSlide
extends Node2D
class_name DemoScreen


const TopLabel := preload("TopLabel.tscn")

enum MovementSchemes { NONE, TOPDOWN_2D, PLATFORMER_2D, PLATFORMER_3D }

const WARNING_MISSING_SCENE := "This node needs a valid scene to function. Please set the Scene property."

@export var scene: PackedScene
@export var controls := [] # (Array, String)
@export var movement_scheme := MovementSchemes.NONE
@export var force_confined_mouse_mode := false

var text: String: set = set_text

var _label: TopLabel = TopLabel.instantiate()

var _scene_instance: Node = null


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray([WARNING_MISSING_SCENE]) if scene == null else PackedStringArray([])


func is_loaded() -> bool:
	return _scene_instance != null


func set_text(new_text: String) -> void:
	text = new_text
	if not is_inside_tree():
		await self.ready
	_label.text = new_text


func set_label_visible(is_visible: bool) -> void:
	if not is_inside_tree():
		await self.ready
	_label.visible = is_visible


func display_scene() -> void:
	if not is_loaded():
		load_scene()
	add_child(_scene_instance)


func load_scene():
	print_debug("You need to override method load_scene() from DemoScreenBase in %s" % get_class())
