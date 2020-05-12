# Draws a 2D trail using Godot's `Line2D`.
#
# Instantiate `Trail2D` as a child of a moving node to use it. To control the color, width curve,
# texture, or trail width, use parameters from the `Line2D` class.
class_name Trail2D
extends Line2D

export var is_emitting := false setget set_emitting

# Distance in pixels between vertices. A higher point_distance_threshold leads to more details.
export var point_distance_threshold := 5.0
# Life of each point in seconds before it is deleted.
export var lifetime := 0.5
# Maximum number of points allowed on the curve.
export var max_points := 100

# Optional path to the target node to follow. If not set, the instance follows its parent.
export var target_path: NodePath

var _points_creation_time := []
var _last_point := Vector2.ZERO
var _clock: float = 0.0
var _offset := 0.0

onready var _target: Node2D = get_node(target_path)


func _ready() -> void:
	if not _target:
		_target = get_parent() as Node2D

	# Avoid making the node toplevel in the editor so it rotates and moves with its parent.
	if Engine.editor_hint:
		set_process(false)
		return

	_offset = position.length()
	set_as_toplevel(true)
	clear_points()
	position = Vector2.ZERO
	_last_point = to_local(_target.global_position) + calculate_offset()


func _get_configuration_warning() -> String:
	return (
		"Missing Target node: assign a node to Target Path or give this node a parent that extends Node2D."
		if not _target
		else ""
	)


func _process(delta: float) -> void:
	# Remove points older than `lifetime`.
	_clock += delta
	for creation_time in _points_creation_time:
		var time_diff = _clock - creation_time
		if time_diff > lifetime:
			remove_first_point()
		# Points in `_points_creation_time` are ordered from oldest to newest so as soon as a point
		# isn't older than `lifetime`, we know all remaining points should stay as well.
		else:
			break

	if not is_emitting:
		return

	# Adding new points if necessary.
	var distance: float = _last_point.distance_to(_target.position)
	if distance > point_distance_threshold:
		add_timed_point(to_local(_target.global_position), _clock)


# Creates a new point and stores its creation time.
func add_timed_point(point_position: Vector2, time: float) -> void:
	add_point(point_position + calculate_offset())
	_points_creation_time.append(time)
	_last_point = point_position
	if get_point_count() > max_points:
		remove_first_point()


# Removes the first point in the line and the corresponding time.
func remove_first_point() -> void:
	if get_point_count() > 1:
		remove_point(0)
	_points_creation_time.pop_front()


# Calculates the offset of the trail from its target.
func calculate_offset() -> Vector2:
	return -polar2cartesian(1.0, _target.rotation - PI / 2) * _offset


func set_emitting(emitting: bool) -> void:
	is_emitting = emitting
	if not is_inside_tree():
		yield(self, "ready")
	if is_emitting:
		clear_points()
		_points_creation_time.clear()
		_last_point = position
