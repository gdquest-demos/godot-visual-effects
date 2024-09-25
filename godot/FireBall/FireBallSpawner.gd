extends Marker2D

@export var fireball_spell_scene: PackedScene = preload("res://FireBall/FireBallSpell.tscn")
@export var throw_speed := 1000.0

var _fireball_reference: WeakRef


func spawn() -> void:
	var fireball : RigidBody2D
	fireball = fireball_spell_scene.instantiate()

	add_child(fireball)
	fireball.global_position = global_position
	_fireball_reference = weakref(fireball)

func throw() -> void:
	if not _fireball_reference.get_ref():
		return
	_fireball_reference.get_ref().set_as_top_level(true)
	_fireball_reference.get_ref().global_position = global_position
	_fireball_reference.get_ref().linear_velocity.x = throw_speed
