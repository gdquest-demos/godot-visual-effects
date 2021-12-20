## DemoScreen represents one screen in the demo.
##
## It has utilities for displaying a label, and creating physical walls so
## physics bodies can't walk out the screen.
##
## It serves as a container for the various demos and isn't directly related to
## any demo functionality.
##
## You can create a node of this type directly to add a screen to any demo, it
## instantiates the nodes it needs in code.
tool
class_name DemoScreen2D
extends DemoScreen

const PHYSICS_LAYER_WALLS := 4
const BOUNDS_THICKNESS = 40.0

var _visibility_notifier := VisibilityNotifier2D.new()

var _bounds := StaticBody2D.new()
var _collisions := {
	"left": CollisionShape2D.new(),
	"top": CollisionShape2D.new(),
	"right": CollisionShape2D.new(),
	"bottom": CollisionShape2D.new(),
	"label": CollisionShape2D.new()
}

var _screen_size := Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
)


func _init() -> void:
	_initialize_bounds()
	_visibility_notifier.rect = Rect2(Vector2.ZERO, _screen_size).grow(-120.0)
	add_child(_visibility_notifier)
	_visibility_notifier.connect("screen_exited", self, "deactivate")


func load_scene() -> void:
	assert(scene != null, "Missing scene to instantiate.")
	_scene_instance = scene.instance()
	if Engine.editor_hint:
		add_child(_scene_instance)
	name = _scene_instance.name

	# We need to wait for the instanced scene to be in the tree to add the label in front.
	yield(_scene_instance, "ready")
	add_child(_label)
	add_child(_bounds)
	_ready_bounds()
	_label.follow_viewport_enable = true
	_label.transform = transform


func deactivate() -> void:
	if _scene_instance and has_node(_scene_instance.name):
		call_deferred("remove_child", _scene_instance)


func reset() -> void:
	_scene_instance.queue_free()
	_scene_instance = scene.instance()
	add_child(_scene_instance)


func _initialize_bounds() -> void:
	_bounds.layers = PHYSICS_LAYER_WALLS
	for collision_name in _collisions:
		var collision_shape: CollisionShape2D = _collisions[collision_name]
		collision_shape.shape = RectangleShape2D.new()
		_bounds.add_child(collision_shape)
	_bounds.visible = false


func _ready_bounds() -> void:
	var size := get_viewport().get_size_override() / 2
	var offset := BOUNDS_THICKNESS / 2

	_collisions.left.position.y = size.y
	_collisions.left.position.x = -offset
	_collisions.left.shape.extents = Vector2(BOUNDS_THICKNESS, size.y)

	_collisions.top.position.x = size.x
	_collisions.top.position.y = -offset
	_collisions.top.shape.extents = Vector2(size.x, BOUNDS_THICKNESS)

	_collisions.right.position.x = size.x * 2 + offset
	_collisions.right.position.y = size.y
	_collisions.right.shape.extents = Vector2(BOUNDS_THICKNESS, size.y)

	_collisions.bottom.position.y = size.y * 2 + offset
	_collisions.bottom.position.x = size.x
	_collisions.bottom.shape.extents = Vector2(size.x, BOUNDS_THICKNESS)

	var collision_label_size := _label.get_size() / 2
	_collisions.label.position.x = collision_label_size.x
	_collisions.label.position.y = collision_label_size.y
	_collisions.label.shape.extents = collision_label_size + Vector2(10, 10)
