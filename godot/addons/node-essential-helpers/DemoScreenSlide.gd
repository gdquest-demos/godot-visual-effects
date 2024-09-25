@tool
class_name DemoScreenSlide
extends DemoScreen


func _ready() -> void:
	var new_name := scene.resource_path.get_file()
	new_name = new_name.rsplit(".", false, 1)[0]
	name = new_name


func display_scene() -> void:
	super.display_scene()
	if not _scene_instance.has_node(str(_label.name)):
		_scene_instance.add_child(_label)


func load_scene() -> void:
	_scene_instance = scene.instantiate()


func clear_scene() -> void:
	if is_loaded():
		_scene_instance.remove_child(_label)
		_scene_instance.queue_free()
		_scene_instance = null


func reset() -> void:
	clear_scene()
	display_scene()
