extends Position2D

export var fireball_spell_scene: PackedScene = preload("res://FireBall/FireBallSpell.tscn")
export var explosion_container_path: NodePath
export var throw_speed := 1000.0

var _fireball_reference: WeakRef

onready var explosion_container := get_node(explosion_container_path)


func spawn() -> void:
	var fireball : RigidBody2D
	fireball = fireball_spell_scene.instance()

	add_child(fireball)
	fireball.explosion_container = explosion_container
	fireball.global_position = global_position
	_fireball_reference = weakref(fireball)

func throw() -> void:
	if not _fireball_reference.get_ref():
		return
	_fireball_reference.get_ref().set_as_toplevel(true)
	_fireball_reference.get_ref().global_position = global_position
	_fireball_reference.get_ref().linear_velocity.x = throw_speed
