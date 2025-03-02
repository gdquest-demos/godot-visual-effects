class_name DebugDrawPath2D
extends Node2D

const CURVE_THICKNESS := 8.0
const CIRCLE_RADIUS := 10.0
const TRIANGLES := 6
var TRIANGLE_VERTICES := PackedVector2Array([
	12 * Vector2.UP, 12 * Vector2.DOWN, 20 * Vector2.RIGHT
])

@export var curve_color := Color.WHITE
@export var circle_color := NodeEssentialsPalette.COLOR_INTERACT

@onready var _parent := get_parent() as Path2D


func _ready() -> void:
	add_to_group("DebugDrawing")
	_parent.curve.changed.connect(queue_redraw)
	z_index = -1


func _draw() -> void:
	if not _parent:
		return

	var points := _parent.curve.get_baked_points()
	if points.is_empty():
		return

	draw_polyline(points, curve_color, CURVE_THICKNESS)
	draw_circle(points[0], CIRCLE_RADIUS, circle_color)
	draw_circle(points[-1], CIRCLE_RADIUS, circle_color)

	var length := _parent.curve.get_baked_length()
	var unit := length / (TRIANGLES + 1)
	for i in range(1, TRIANGLES):
		var t := i * unit
		var offset : Vector2 = _parent.curve.interpolate_baked(t)
		var direction : Vector2 = (offset - _parent.curve.interpolate_baked(t - 1))
		var transform := Transform2D(direction.angle(), offset)
		draw_primitive(transform * (TRIANGLE_VERTICES), [circle_color], [])
