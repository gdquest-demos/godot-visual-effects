extends Line2D

export (float, 1.0, 3.0) var spread_angle := 1.5
export (int, 1, 20) var segments := 12

var point_end := Vector2.ZERO

onready var sparks := $Sparks


func _ready() -> void:
	set_as_toplevel(true)


func create(start: Vector2, end: Vector2) -> void:
	point_end = end

	var _points := []
	var _start := start
	var _end := point_end
	var _segment_length := _start.distance_to(_end) / segments

	_points.append(_start)

	var _current := _start

	for segment in range(segments):
		# Face the end point and extend towards it
		# Rotate a random amount to get next point
		var _rotation := rand_range(-spread_angle / 2, spread_angle / 2)
		var _new := _current + (_current.direction_to(_end) * _segment_length).rotated(_rotation)
		_points.append(_new)
		_current = _new

	_points.append(_end)
	points = _points

	sparks.global_position = point_end
