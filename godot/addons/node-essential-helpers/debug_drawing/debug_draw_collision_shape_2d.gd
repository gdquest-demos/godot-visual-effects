@tool
@icon("res://addons/node-essential-helpers/debug_drawing/debug_draw_collision_shape.svg")
## This class is a simple debug shape to visualize Area2Ds.
##
## It isn't directly related to any demo functionality.
class_name DebugDrawCollisionShape2D
extends Node2D

var _halo_circle := preload("halo_circle.tscn").instantiate()

enum ShapeType { SQUARE, CIRCLE }

var shape_type: int: set = set_shape_type
var color := NodeEssentialsPalette.COLOR_INTERACT: set = set_color
var outline_thickness := 1.0: set = set_outline_thickness
var shape_size: Vector2: set = set_shape_size

var do_draw_fill := false


func _ready() -> void:
	_autodetect_shape()
	add_to_group("DebugDrawing")
	add_child(_halo_circle)
	_halo_circle.visible = false
	if not Engine.is_editor_hint() and _is_main_scene():
		visible = false


func _draw() -> void:
	if shape_type == ShapeType.CIRCLE:
		_halo_circle.visible = true
		_halo_circle.halo_color = color
		_halo_circle.size = shape_size.x * 2
		if do_draw_fill:
			draw_circle(Vector2.ZERO, shape_size.x, color)
	elif shape_type == ShapeType.SQUARE:
		var rect := Rect2(-shape_size, shape_size * 2)
		draw_rect(rect, color, do_draw_fill, outline_thickness)# true) TODOConverter3To4 Antialiasing argument is missing


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray([]) if has_valid_parent() else PackedStringArray(["Parent isn't a CollisionShape2D"])


func has_valid_parent() -> bool:
	var parent := get_parent()
	return parent is CollisionShape2D


func set_color(new_color: Color) -> void:
	color = new_color
	queue_redraw()


func set_outline_thickness(new_outline_thickness: float) -> void:
	outline_thickness = new_outline_thickness
	queue_redraw()


func set_shape_size(new_shape_size: Vector2) -> void:
	shape_size = new_shape_size
	queue_redraw()


func set_shape_type(new_shape_type: int) -> void:
	shape_type = new_shape_type
	queue_redraw()


func _autodetect_shape() -> void:
	var parent: CollisionShape2D = get_parent()
	assert(
		has_valid_parent(), "Parent at '%s' isn't a valid CollisionShape2D" % [parent.get_path()]
	)
	if parent.shape is CircleShape2D:
		shape_type = ShapeType.CIRCLE
		shape_size = Vector2(parent.shape.radius, parent.shape.radius)
	elif parent.shape is RectangleShape2D:
		shape_type = ShapeType.SQUARE
		shape_size = parent.shape.extents
	else:
		push_error("Shape2D '%s' at '%s' isn't a supported shape" % [parent.shape, parent.get_path()])


func _is_main_scene() -> bool:
	var current_scene := get_tree().current_scene.name
	var main_scene: String = ProjectSettings.get_setting('application/run/main_scene')
	return current_scene == main_scene
