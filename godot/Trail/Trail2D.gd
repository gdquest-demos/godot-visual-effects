# Draws a 2D trail using Godot's `Line2D`.
#
# Instantiate `Trail2D` as a child of a moving node to use it. To control the color, width curve,
# texture, or trail width, use parameters from the `Line2D` class.
tool

class_name Trail2D
extends Line2D

export var is_emitting := false setget set_emitting

# Distance in pixels between vertices. A higher resolution leads to more details.
export var resolution := 5.0
# Life of each point in seconds before it is deleted.
export var lifetime := 0.5
# Maximum number of points allowed on the curve.
export var max_points := 100

# Optional path to the target node to follow. If not set, the instance follows its parent.
export var target_path: NodePath

var _points_creation_time := []
var _last_point := Vector2.ZERO
var _clock := 0.0
var _offset := 0.0

onready var target: Node2D = get_node_or_null(target_path)


func _ready() -> void:
	if not target:
		target = get_parent() as Node2D
	
	if Engine.editor_hint:
		set_process(false)
		return

	_offset = position.length()
	set_as_toplevel(true)
	clear_points()
	position = Vector2.ZERO
	_last_point = to_local(target.global_position) + calculate_offset()


func _get_configuration_warning() -> String:
	var warning := "Missing Target node: assign a Node that extends Node2D in the Target Path or make the Trail a child of a parent that extends Node2D"
	if target:
		warning = ""
	return warning


func _process(delta: float) -> void:
	_clock += delta
	remove_older()

	if not is_emitting:
		return

	# Adding new points if necessary.
	var desired_point := to_local(target.global_position)
	var distance: float = _last_point.distance_to(desired_point)
	if distance > resolution:
		add_timed_point(desired_point, _clock)


# Creates a new point and stores its creation time.
func add_timed_point(point: Vector2, time: float) -> void:
	add_point(point + calculate_offset())
	_points_creation_time.append(time)
	_last_point = point
	if get_point_count() > max_points:
		remove_first_point()


# Calculates the offset of the trail from its target.
func calculate_offset() -> Vector2:
	return - 1.0 * polar2cartesian(1.0, target.rotation).rotated(- PI / 2) * _offset


# Removes the first point in the line and the corresponding time.
func remove_first_point() -> void:
	if get_point_count() > 1:
		remove_point(0)
	_points_creation_time.pop_front()


# Remove points older than `lifetime`.
func remove_older() -> void:
	for creation_time in _points_creation_time:
		var delta = _clock - creation_time
		if delta > lifetime:
			remove_first_point()
		# Points in `_points_creation_time` are ordered from oldest to newest so as soon as a point
		# isn't older than `lifetime`, we know all remaining points should stay as well.
		else:
			break


func set_emitting(emitting: bool) -> void:
	is_emitting = emitting
	if Engine.editor_hint:
		return
	
	if not is_inside_tree():
		yield(self, "ready")
	
	if is_emitting:
		clear_points()
		_points_creation_time.clear()
		_last_point = to_local(target.global_position) + calculate_offset()
