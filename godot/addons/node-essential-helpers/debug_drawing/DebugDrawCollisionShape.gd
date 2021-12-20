tool
class_name DebugDrawCollisionShape, "DebugDrawCollisionShape.svg"
extends Spatial

enum ShapeType { BOX, SPHERE, CAPSULE }

var color := NodeEssentialsPalette.COLOR_INTERACT setget set_color
var shape_type: int
var shape_size: Vector3

var _halo_mesh := preload("./HaloMesh.tscn").instance()


func _ready() -> void:
	add_to_group("DebugDrawing")
	add_child(_halo_mesh)
	_autodetect_shape()
	_update_mesh()
	if not Engine.is_editor_hint() and _is_main_scene():
		visible = false


func _is_main_scene() -> bool:
	var current_scene := get_tree().current_scene.filename
	var main_scene: String = ProjectSettings.get_setting('application/run/main_scene')
	return current_scene == main_scene


func _update_mesh() -> void:
	_halo_mesh.set_shape_type(shape_type)
	_halo_mesh.set_size(shape_size)
	_halo_mesh.set_halo_color(color)


func _get_configuration_warning() -> String:
	return "" if has_valid_parent() else "Parent isn't a CollisionShape"


func _autodetect_shape() -> void:
	var parent := get_parent() as CollisionShape
	assert(has_valid_parent(), "Parent at '%s' isn't a valid CollisionShape" % [parent.get_path()])
	if parent.shape is SphereShape:
		shape_type = ShapeType.SPHERE
		shape_size = Vector3(parent.shape.radius, parent.shape.radius, parent.shape.radius)
	elif parent.shape is BoxShape:
		shape_type = ShapeType.BOX
		shape_size = parent.shape.extents
	elif parent.shape is CapsuleShape:
		shape_type = ShapeType.CAPSULE
		shape_size = Vector3(parent.shape.radius, parent.shape.height, parent.shape.radius)
	else:
		push_error("Shape '%s' at '%s' isn't a supported shape" % [parent.shape, parent.get_path()])


func has_valid_parent() -> bool:
	return get_parent() is CollisionShape


func set_color(new_color: Color) -> void:
	color = new_color
	_update_mesh()
