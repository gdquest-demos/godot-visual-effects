class_name DebugDrawPath
extends CSGPolygon3D

const UnshadedMaterial := preload("res://addons/node-essential-helpers/unshaded_color.gdshader")
const Pointer := preload("res://addons/node-essential-helpers/debug_drawing/cylindermesh.tres")

const POINTERS := 6

@export var polygon_scale := 0.1 # (float, 0.05, 1)

var _pointer := MultiMeshInstance3D.new()

@onready var _parent: Path3D = get_parent()


func _ready() -> void:
	_parent.connect("curve_changed", Callable(self, "_on_Path_curve_changed"))

	_pointer.multimesh = MultiMesh.new()
	_pointer.multimesh.mesh = Pointer
	_pointer.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_pointer.multimesh.instance_count = POINTERS
	add_child(_pointer)

	var transform := Transform2D(0, -0.5 * Vector2.ONE).scaled(polygon_scale * Vector2.ONE)
	polygon = transform * (polygon)
	flip_faces = true
	mode = MODE_PATH
	path_node = _parent.get_path()

	material = ShaderMaterial.new()
	material.gdshader = UnshadedMaterial
	material.set_shader_parameter("color", NodeEssentialsPalette.COLOR_INTERACT)

	add_to_group("DebugDrawing")
	_on_Path_curve_changed()


func _on_Path_curve_changed() -> void:
	var points := _parent.curve.get_baked_points()
	if points.is_empty():
		return

	var path_follow := PathFollow3D.new()
	path_follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	_parent.add_child(path_follow)

	for i in range(1, POINTERS + 1):
		path_follow.progress_ratio = float(i) / (POINTERS + 1)
		var transform := path_follow.transform
		transform.basis = transform.basis.rotated(transform.basis.x.normalized(), PI / 2.0)
		_pointer.multimesh.set_instance_transform(i - 1, transform)
	path_follow.queue_free()


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray([]) if _parent != null else PackedStringArray(["Parent must be a Path3D"])
