tool
extends MeshInstance

enum ShapeType { BOX, SPHERE, CAPSULE }

export (ShapeType) var shape_type: int = ShapeType.BOX setget set_shape_type
export var size := Vector3.ONE setget set_size
export var halo_color := Color.white setget set_halo_color


func set_shape_type(value) -> void:
	match value:
		ShapeType.BOX:
			mesh = CubeMesh.new()
		ShapeType.SPHERE:
			mesh = SphereMesh.new()
		ShapeType.CAPSULE:
			mesh = CapsuleMesh.new()
	shape_type = value


func set_size(value: Vector3) -> void:
	size = value
	if shape_type == ShapeType.CAPSULE:
		scale = Vector3.ONE
		mesh.radius = value.x
		mesh.mid_height = value.y
	else:
		scale = size


func set_halo_color(value: Color) -> void:
	halo_color = value
	material_override.set_shader_param("halo_color", halo_color)
