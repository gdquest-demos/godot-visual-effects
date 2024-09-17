extends Sprite2D

@export var lifetime := 0.5


func _ready() -> void:
	fade()


func fade(duration := lifetime) -> void:
	var transparent := self_modulate
	transparent.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "self_modulate", transparent, duration).from_current()
	await tween.finished
	queue_free()
