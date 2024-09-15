@tool
@icon("res://addons/node-essential-helpers/debug_drawing/DebugDrawCollisionShape.svg")
class_name DebugDrawCollisionShape
extends Node3D

enum ShapeType { BOX, SPHERE, CAPSULE }

var color := NodeEssentialsPalette.COLOR_INTERACT: set = set_color
var shape_type: int
var shape_size: Vector3

var _halo_mesh := preload("./HaloMesh.tscn").instantiate()


func _ready() -> void:
	add_to_group("DebugDrawing")
	add_child(_halo_mesh)
	_autodetect_shape()
	_update_mesh()
	if not Engine.is_editor_hint() and _is_main_scene():
		visible = false


func _is_main_scene() -> bool:
	var current_scene := get_tree().current_scene.name
	var main_scene: String = ProjectSettings.get_setting('application/run/main_scene')
	return current_scene == main_scene


func _update_mesh() -> void:
	_halo_mesh.set_shape_type(shape_type)
	_halo_mesh.set_size(shape_size)
	_halo_mesh.set_halo_color(color)


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray([]) if has_valid_parent() else PackedStringArray(["Parent isn't a CollisionShape3D"])


func _autodetect_shape() -> void:
	var parent := get_parent() as CollisionShape3D
	assert(has_valid_parent(), "Parent at '%s' isn't a valid CollisionShape3D" % [parent.get_path()])
	if parent.shape is SphereShape3D:
		shape_type = ShapeType.SPHERE
		shape_size = Vector3(parent.shape.radius, parent.shape.radius, parent.shape.radius)
	elif parent.shape is BoxShape3D:
		shape_type = ShapeType.BOX
		shape_size = parent.shape.extents
	elif parent.shape is CapsuleShape3D:
		shape_type = ShapeType.CAPSULE
		shape_size = Vector3(parent.shape.radius, parent.shape.height, parent.shape.radius)
	else:
		push_error("Shape3D '%s' at '%s' isn't a supported shape" % [parent.shape, parent.get_path()])


func has_valid_parent() -> bool:
	return get_parent() is CollisionShape3D


func set_color(new_color: Color) -> void:
	color = new_color
	_update_mesh()
