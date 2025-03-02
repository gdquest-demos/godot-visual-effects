extends Line2D

@export var spread_angle := PI/4.0 # (float, 0.5, 3.0)
@export var segments := 12 # (int, 1, 36)

@onready var sparks := $Sparks
@onready var ray_cast := $RayCast2D


func _ready() -> void:
	set_as_top_level(true)


func create(start: Vector2, end: Vector2) -> void:
	
	ray_cast.global_position = start

	ray_cast.target_position = end - start
	ray_cast.force_raycast_update()

	if ray_cast.is_colliding():
		end = ray_cast.get_collision_point()
	
	var _points := []
	var _current := start
	var _segment_length := start.distance_to(end) / segments

	_points.append(start)
	
	for segment in range(segments):
		# Face the end point and extend towards it
		# Rotate a random amount to get next point
		var _rotation := randf_range(-spread_angle / 2, spread_angle / 2)
		var _new := _current + (_current.direction_to(end) * _segment_length).rotated(_rotation)
		_points.append(_new)
		_current = _new

	_points.append(end)
	points = _points

	sparks.global_position = end
