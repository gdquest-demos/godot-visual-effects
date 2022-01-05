class_name DebugDrawRayCast
extends MeshInstance

const BASE_COLOR := NodeEssentialsPalette.COLOR_INTERACT
const WALL_COLLISION_COLOR := NodeEssentialsPalette.COLOR_WALL_COLLISION
const PLAYER_COLLISION_COLOR := NodeEssentialsPalette.COLOR_HITBOX
const DISABLED_COLOR := NodeEssentialsPalette.COLOR_DISABLED

export var radius := 0.01 setget set_radius
export var collision_sphere_radius := 0.08

var _color := BASE_COLOR setget _set_color
var _collision_point := Vector3.ZERO
var _sphere := MeshInstance.new()

onready var _parent := get_parent() as RayCast


func _init() -> void:
	mesh = preload("raycast_cylinder_mesh.tres").duplicate(true)
	_sphere.mesh = preload("raycast_sphere_mesh.tres")
	add_to_group("DebugDrawing")


func _ready() -> void:
	add_child(_sphere)
	transform.basis = _parent.cast_to.normalized()

	# Make Y axis look at the cast_to vector
	transform.basis.y = _parent.cast_to.normalized()
	transform.basis.z = Vector3.UP * -1.0
	transform.basis.x = transform.basis.z.cross(transform.basis.y).normalized()

	transform.basis.z = transform.basis.y.cross(transform.basis.x).normalized()
	transform.basis.x = transform.basis.x * -1
	transform.basis = transform.basis.orthonormalized()


func _physics_process(delta: float) -> void:
	if not _parent.enabled:
		_set_color(DISABLED_COLOR)
		_sphere.visible = false
		return

	if _parent.is_colliding():
		_set_color(
			(
				PLAYER_COLLISION_COLOR
				if _parent.get_collider().is_in_group("player")
				else WALL_COLLISION_COLOR
			)
		)
		_collision_point = _parent.get_collision_point() - _parent.global_transform.origin
	else:
		_set_color(BASE_COLOR)
		_collision_point = Vector3.ZERO
	scale.y = (
		_parent.cast_to.length()
		if _collision_point == Vector3.ZERO
		else _collision_point.length()
	)
	_sphere.scale.y = 1.0 / scale.y
	_sphere.visible = _collision_point != Vector3.ZERO
	transform.origin = transform.basis.y * mesh.height / 2.0
	_sphere.transform.origin = Vector3.UP * mesh.height / 2.0
	mesh.material.set_shader_param("color", _color)


func _get_configuration_warning() -> String:
	return "" if _parent != null else "Parent must be a RayCast"


func _set_color(value: Color) -> void:
	_color = value
	mesh.material.set_shader_param("color", _color)


func set_radius(value: float) -> void:
	radius = value
	mesh.top_radius = radius
	mesh.bottom_radius = radius
