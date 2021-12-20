tool
extends EditorPlugin

const SUPPORTED_TYPES := [
	"CollisionShape",
	"CollisionShape2D",
	"RayCast",
	"RayCast2D",
	"CollisionPolygon",
	"CollisionPolygon2D",
	"Path",
	"Path2D",
]

var dock: Control = preload("DebugGroups.tscn").instance()
var editor_selection := get_editor_interface().get_selection()


func _enter_tree():
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	dock.connect("group_selected", self, "assign_group_to_selection")
	editor_selection.connect("selection_changed", self, "update_dock_display")
	update_dock_display()


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()


func assign_group_to_selection(group: String) -> void:
	for node in editor_selection.get_selected_nodes():
		if not node.get_class() in SUPPORTED_TYPES:
			continue

		if node is RayCast or node is RayCast2D or node is Path or node is Path2D:
			if node.is_in_group("Draw"):
				node.remove_from_group("Draw")
			else:
				node.add_to_group("Draw", true)
			continue

		if node.is_in_group(group):
			node.remove_from_group(group)
			node.remove_from_group("Draw")
		else:
			# We remove all other possible debug groups to avoid getting
			# the wrong color
			for debug_group in NodeEssentialsPalette.DEBUG_DRAWING_GROUPS:
				if node.is_in_group(debug_group):
					node.remove_from_group(debug_group)

			node.add_to_group("Draw", true)
			node.add_to_group(group, true)


func update_dock_display() -> void:
	var selection := editor_selection.get_selected_nodes()

	var has_supported_node := false
	for node in selection:
		if node.get_class() in SUPPORTED_TYPES:
			has_supported_node = true
			break

	if has_supported_node:
		var active_node = selection[0]
		if active_node is RayCast or active_node is RayCast2D or active_node is Path2D:
			dock.show_toggle_draw_option()
		else:
			dock.show_collision_shape_options()
	else:
		dock.show_instructions()
