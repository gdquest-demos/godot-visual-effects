extends Sprite

export var ghost_spawn_time := 0.1
export var is_emitting := false setget set_is_emitting

var _fading_sprite_scene: PackedScene = preload("res://GhostTrail/FadingSprite.tscn")

onready var _timer := $GhostSpawnTimer

func set_is_emitting(emit: bool) -> void:
	is_emitting = emit
	if not is_inside_tree():
		yield(self, "ready")
	if is_emitting:
		_spawn_ghost()
		_timer.start()
	else:
		_timer.stop()


func _spawn_ghost() -> void:
	var ghost := _fading_sprite_scene.instance()
	ghost.offset = offset
	ghost.texture = texture
	ghost.flip_h = flip_h
	ghost.flip_v = flip_v
	add_child(ghost)
	ghost.set_as_toplevel(true)
	ghost.global_position = global_position


func _on_Timer_timeout() -> void:
	_spawn_ghost()
