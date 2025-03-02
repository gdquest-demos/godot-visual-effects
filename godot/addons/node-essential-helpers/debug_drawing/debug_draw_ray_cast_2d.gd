@tool
@icon("res://addons/node-essential-helpers/debug_drawing/debug_draw_collision_shape.svg")
## Keeps track of a parent RayCast2D node and draws a line based on it.
##
## The color changes when the parent is colliding.
class_name DebugDrawRayCast2D
extends Node2D

const BASE_COLOR := NodeEssentialsPalette.COLOR_INTERACT
const WALL_COLLISION_COLOR := NodeEssentialsPalette.COLOR_WALL_COLLISION
const PLAYER_COLLISION_COLOR := NodeEssentialsPalette.COLOR_HITBOX
const DISABLED_COLOR := NodeEssentialsPalette.COLOR_DISABLED

@export var line_thickness := 4.0: set = set_line_thickness
@export var circle_radius := 12.0

var _color := Color(0, 0, 0)
var _line := Vector2.ZERO
var _collision_point := Vector2.ZERO

@onready var _parent := get_parent() as RayCast2D


func _ready() -> void:
	add_to_group("DebugDrawing")
	set_physics_process(_parent != null)
	if Engine.is_editor_hint():
		set_physics_process(false)


func _draw() -> void:
	var vector := _line if _collision_point == Vector2.ZERO else _collision_point
	draw_line(Vector2.ZERO, vector, _color, line_thickness)
	draw_circle(vector, circle_radius, Color.WHITE_SMOKE)


func _physics_process(delta: float) -> void:
	if not _parent.enabled:
		_color = DISABLED_COLOR
		queue_redraw()
		return

	_line = _parent.target_position
	if _parent.is_colliding():
		_color = (
			PLAYER_COLLISION_COLOR
			if _parent.get_collider().is_in_group("player")
			else WALL_COLLISION_COLOR
		)
		_collision_point = _parent.get_collision_point() - _parent.global_position
		_collision_point = _collision_point.rotated(-_parent.global_rotation)
	else:
		_color = BASE_COLOR
		_collision_point = Vector2.ZERO
	queue_redraw()


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray([]) if _parent != null else PackedStringArray(["Parent must be a RayCast2D"])


func set_line_thickness(value: float) -> void:
	line_thickness = value
	queue_redraw()
