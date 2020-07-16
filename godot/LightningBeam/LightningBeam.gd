extends RayCast2D

export var lightning_container_path: NodePath
export var flashes := 3
export var lightning_jolt: PackedScene = preload("res://LightningBeam/LightningJolt.tscn")

onready var lightning_container: Node = self


func _physics_process(delta):
	cast_to = get_local_mouse_position()


func shoot() -> void:
	var target_point := get_global_mouse_position()

	force_raycast_update()

	if is_colliding():
		target_point = get_collision_point()

	for flash in range(flashes):
		var _new_jolt = lightning_jolt.instance()

		lightning_container.add_child(_new_jolt)
		_new_jolt.create(global_position, target_point)

		yield(get_tree().create_timer(0.1), "timeout")
