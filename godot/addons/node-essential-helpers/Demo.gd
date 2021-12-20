## Base class for nodes that help navigate demo screens.
##
## Displays a label at the top of the screen.
##
## Expects the demo UI to be available in the scene.
extends Node2D

## Emitted when the active screen changed.
signal screen_changed

const UIDemo := preload("UIDemo.tscn")
const Background := preload("res://common/Background.tscn")

var areas_visible := true setget set_areas_visible
var do_show_label := true setget set_do_show_label

var _active_screen: DemoScreen = null
var _background: Background = null
var _current_screen_index: int setget _set_current_screen_index
## Scenes to cycle through in the slideshow.
var _screens := []
var _mouse_mode_toggle := Input.MOUSE_MODE_CONFINED

onready var _ui := UIDemo.instance()


func _ready() -> void:
	connect("screen_changed", self, "_on_screen_changed")
	add_child(_ui)
	_ui.button_previous.connect("pressed", self, "go_to_previous_screen")
	_ui.button_next.connect("pressed", self, "go_to_next_screen")
	_ui.button_visible_shapes.connect("toggled", self, "set_areas_visible")
	_ui.button_reset.connect("pressed", self, "reset_current_screen")

	_background = Background.instance()
	add_child(_background)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and Input.get_mouse_mode() != _mouse_mode_toggle:
		Input.set_mouse_mode(_mouse_mode_toggle)
	elif event.is_action_pressed("toggle_mouse_confined"):
		Input.set_mouse_mode(
			(
				Input.MOUSE_MODE_VISIBLE
				if Input.get_mouse_mode() == _mouse_mode_toggle
				else _mouse_mode_toggle
			)
		)
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("go_to_next_screen"):
		go_to_next_screen()
	elif event.is_action_pressed("go_to_previous_screen"):
		go_to_previous_screen()
	elif event.is_action_pressed("reset_screen"):
		reset_current_screen()
	elif event.is_action_pressed("toggle_interface"):
		set_do_show_label(not do_show_label)


func set_areas_visible(are_visible: bool) -> void:
	areas_visible = are_visible
	for debug_shape in get_tree().get_nodes_in_group("DebugDrawing"):
		debug_shape.visible = are_visible


func set_do_show_label(value: bool) -> void:
	do_show_label = value
	_active_screen.set_label_visible(do_show_label)


# Updates the mouse mode after changing demo.
#
# In 3D scenes, with the free camera, we want to capture the cursor so it's not
# visible, while in 2D scenes we want to see the mouse cursor and use the
# confined mode instead.
func _update_mouse_mode(use_captured_mode: bool) -> void:
	_mouse_mode_toggle = Input.MOUSE_MODE_CAPTURED if use_captured_mode else Input.MOUSE_MODE_CONFINED
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(_mouse_mode_toggle)


func _on_screen_changed() -> void:
	var is_screen_3d := _active_screen.get_child(0) is Spatial
	_update_mouse_mode(is_screen_3d and not _active_screen.force_confined_mouse_mode)
	_background.visible = not is_screen_3d
	_update_controls_display()
	_create_debug_drawing_nodes()
	_active_screen.set_label_visible(do_show_label)
	var debug_node_count := get_tree().get_nodes_in_group("Draw").size()
	_ui.button_visible_shapes.visible = debug_node_count > 0


func _update_controls_display() -> void:
	_ui.populate_controls(_active_screen.controls, _active_screen.movement_scheme)


func _create_debug_drawing_nodes() -> void:
	for node in get_tree().get_nodes_in_group("Draw"):
		# There are cases we manually added or need to manually add debug
		# drawing nodes rather than generate them.
		if has_debug_draw_child(node):
			continue

		var instance = null
		var is_collision_shape := false

		if node is CollisionShape2D:
			instance = DebugDrawCollisionShape2D.new()
			is_collision_shape = true
		elif node is CollisionShape:
			instance = DebugDrawCollisionShape.new()
			is_collision_shape = true
		elif node is RayCast:
			instance = DebugDrawRayCast.new()
		elif node is RayCast2D:
			instance = DebugDrawRayCast2D.new()
		elif node is Path:
			instance = DebugDrawPath.new()
		elif node is Path2D:
			instance = DebugDrawPath2D.new()
		else:
			print_debug("Can't draw debug collision for %s." % [node.get_class()])
			continue

		if is_collision_shape:
			for group in node.get_groups():
				if group in NodeEssentialsPalette.DEBUG_DRAWING_GROUPS:
					instance.color = NodeEssentialsPalette.COLORS_MAP[group]
					break

		node.add_child(instance)
		instance.visible = areas_visible


func has_debug_draw_child(node: Node) -> bool:
	for child in node.get_children():
		if get_class().begins_with("DebugDraw"):
			return true
	return false


func go_to_next_screen() -> void:
	_set_current_screen_index(_current_screen_index + 1)


func go_to_previous_screen() -> void:
	_set_current_screen_index(_current_screen_index - 1)


func reset_current_screen() -> void:
	_screens[_current_screen_index].reset()
	_create_debug_drawing_nodes()


# Virtual method. Override in child classes.
func _set_current_screen_index(value: int) -> void:
	_current_screen_index = value
