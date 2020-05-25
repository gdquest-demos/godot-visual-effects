extends Position2D

export var fireball_spell_scene: PackedScene = preload("res://FireBall/FireBallSpell.tscn")
export var explosion_container_path: NodePath
export var throw_speed := 1000.0

var _fireball: RigidBody2D

onready var explosion_container := get_node(explosion_container_path)


func spawn() -> void:
	_fireball = fireball_spell_scene.instance()

	add_child(_fireball)
	_fireball.explosion_container = explosion_container
	_fireball.global_position = global_position


func throw() -> void:
	if not _fireball:
		return
	_fireball.set_as_toplevel(true)
	_fireball.global_position = global_position
	_fireball.linear_velocity.x = throw_speed
