# Spawns copies of the sprite that fade out
extends Sprite

var FadingSprite: PackedScene = preload("res://GhostTrail/FadingSprite.tscn")

# Rate at which ghosts spawn in number per second
export var spawn_rate := 0.1 setget set_spawn_rate
# If `true`, ghosts spawn at a rate of `spawn_rate`
export var is_emitting := false setget set_is_emitting

onready var _timer := $GhostSpawnTimer


func set_is_emitting(value: bool) -> void:
	is_emitting = value
	if not is_inside_tree():
		yield(self, "ready")

	if is_emitting:
		_spawn_ghost()
		_timer.start()
	else:
		_timer.stop()


func set_spawn_rate(value: float) -> void:
	spawn_rate = value
	if not _timer:
		yield(self, "ready")

	_timer.wait_time = 1.0 / spawn_rate


func _spawn_ghost() -> void:
	var ghost := FadingSprite.instance()
	ghost.offset = offset
	ghost.texture = texture
	ghost.flip_h = flip_h
	ghost.flip_v = flip_v
	add_child(ghost)
	ghost.set_as_toplevel(true)
	ghost.global_position = global_position


func _on_Timer_timeout() -> void:
	_spawn_ghost()
