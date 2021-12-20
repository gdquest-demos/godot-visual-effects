tool
extends Sprite

export var size := 100.0 setget set_size
export var radius := 12.0 setget set_radius
export var halo_color := Color.white setget set_halo_color


func set_size(value: float) -> void:
	size = value
	scale = Vector2.ONE / texture.get_size() * size
	material.set_shader_param("bounds_half_length", size / 2.0)


func set_radius(value: float) -> void:
	radius = value
	material.set_shader_param("halo_radius", radius)


func set_halo_color(value: Color) -> void:
	halo_color = value
	material.set_shader_param("halo_color", halo_color)
