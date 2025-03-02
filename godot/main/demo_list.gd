# Finds all the scenes in a given directory and presents them as a list of
# selectable items.
#
# This class can filter visible items by search queries and general categories
# (2D, 3D, etc.).
#
# Emits a signal when the player select an item or presses it so another node
# can handle the loading and scene navigation.
extends ScrollContainer
class_name DemoList

# Emitted when the player selects a demo to play.
signal demo_selected(scene_path)
# Emitted when the player double-clicks a demo
signal demo_requested
# Emitted after updating the visible items in the list, like when filtering them
# through a search.
signal display_updated(item_count)

const DemoItemScene = preload("demo_item.tscn")
const DemoItem = preload("demo_item.gd")

@export var metadata_file_path := "res://main/nodes_metadata.json" # (String, FILE)
# Directory to
@export var demos_dirpath := "res://demos/" # (String, FILE)
@export var icons_dirpath := demos_dirpath.path_join("icons") # (String, FILE)

# Maps demo names as displayed in the list to paths to scenes to load.
var demo_scenes := {}

# Category filter applied to list items. See `_on_FilterButton_pressed()` for more information.
var category_filter: String: set = set_category_filter

# Metadata loaded and cached from a JSON file.
var _nodes_metadata := _load_node_metadata()

var _items := []
var _selected_item: DemoItem = null
var _focused_item_index := 0
var _filter_buttons = []

@onready var _container := $VBoxContainer
@onready var _no_results := $VBoxContainer/NoResultsLabel


func _ready() -> void:
	_list_demos_in_directory(demos_dirpath)
	_no_results.hide()
	focus_entered.connect(_scroll_to_item.bind("select_first_item"))
	visibility_changed.connect(_on_visibility_changed)

	select_first_item()


# Connects to filter buttons to set the `category_filter` upon clicking them.
func setup(filter_buttons: Array) -> void:
	_filter_buttons = filter_buttons
	for button in _filter_buttons:
		button.pressed.connect(_on_FilterButton_pressed.bind(button.text.to_lower()))


# Updates visible demo items based on the search query and the `category_filter`.
func update_display(search_filter := "") -> void:
	var visible_count := 0
	search_filter = search_filter.to_lower()
	for item in _items:
		if item.focus_entered.is_connected(_scroll_to_item):
			item.focus_entered.disconnect(_scroll_to_item)
		# We need to check the search against every keyword corresponding to a node.
		# See nodes_metadata.json to add search terms for specific nodes.
		var search_terms := [item.demo_name]
		if _nodes_metadata.search_terms.has(item.demo_name):
			search_terms = _nodes_metadata.search_terms[item.demo_name]
			search_terms.append(item.demo_name)

		item.visible = true
		if search_filter:
			item.visible = false
			for term in search_terms:
				if search_filter.is_subsequence_of(term.to_lower()):
					item.visible = true
					break

		if not category_filter in ["", "all"]:
			item.visible = (
				item.visible
				and item.demo_name in _nodes_metadata["categories"][category_filter]
			)
		if item.visible:
			visible_count += 1
			item.focus_entered.connect(_scroll_to_item.bind(item, visible_count - 1))
	_no_results.visible = visible_count == 0
	display_updated.emit(visible_count)


func set_category_filter(value: String) -> void:
	category_filter = value
	update_filter_icons()
	update_display()

	# So we don't end up hiding a selected item.
	select_first_item()

func update_filter_icons():
	for filterButton in _filter_buttons:
		if filterButton.text.to_lower() == category_filter:
			filterButton.icon = load("res://demos/icons/node" + category_filter.to_upper() + "Selected.svg")
			continue
		else:
			filterButton.icon = load("res://demos/icons/node" + filterButton.text + ".svg")

func select_first_item() -> void:
	scroll_vertical = 0
	for item in _items:
		if not item.visible:
			continue
		_select_item(item)
		return


func _list_demos_in_directory(directory_path: String) -> void:
	var demo_scene_paths := _find_files(directory_path, ["*.tscn"], true)

	# Map demo names to file paths and sort them alphabetically
	var demo_name_and_paths := []
	for path in demo_scene_paths:
		var demo_name: String = path.rsplit("/", true, 1)[-1]
		demo_name = demo_name.replace(".tscn", "")
		demo_name_and_paths.append([demo_name, path])
	demo_name_and_paths.sort_custom(_sort_demos)

	# Create a list entry for each demo and store the mapping of demo names to
	# file paths as a dictionary.
	var index := 0
	for entry in demo_name_and_paths:
		var demo_name: String = entry[0]
		var path: String = entry[1]

		demo_scenes[demo_name] = path

		var item := DemoItemScene.instantiate()
		_container.add_child(item)
		item.demo_name = demo_name
		
		_items.append(item)
		item.pressed.connect(_select_item.bind(item))
		item.focus_entered.connect(_scroll_to_item.bind(item, index))
		item.demo_requested.connect(_request_demo.bind(item))
		index += 1

	_selected_item = _items[0]


func _request_demo(item: DemoItem) -> void:
	_select_item(item)
	demo_requested.emit()


func _select_item(item: DemoItem) -> void:
	_selected_item = item
	item.grab_focus()
	var demo_path: String = demo_scenes[item.demo_name]
	demo_selected.emit(demo_path)


func _scroll_to_item(item: DemoItem, index: int) -> void:
	var direction := index - _focused_item_index
	if direction == 0:
		return

	var half_rect_size_y: float = size.y / 2.0

	if direction < 0 and item.position.y < scroll_vertical:
		scroll_vertical = int(item.position.y)
	elif (
		direction > 0
		and item.position.y > half_rect_size_y + position.y + scroll_vertical
	):
		scroll_vertical = int(item.position.y - size.y + item.size.y)

	_focused_item_index = index


## Converts the demo name in PascalCase to a title to display.
func _pascal_case_to_title(demo_name: String) -> String:
	var regex := RegEx.new()
	regex.compile("[A-Z]")

	demo_name = demo_name.split(".", true, 1)[0]
	demo_name = regex.sub(demo_name, " $0", true)
	return demo_name


## Finds files that match a list of `patterns` in the directory `dirpath`.
## Each pattern is a string the function runs through Godot's `String.match()`: it supports wildcards and question marks.
func _find_files(
	dirpath := "", patterns := PackedStringArray(), is_recursive := false, do_skip_hidden := true
) -> PackedStringArray:
	var paths := PackedStringArray()
	var directory := DirAccess.open(dirpath)

	if not DirAccess.dir_exists_absolute(dirpath):
		printerr("The directory does not exist: %s" % dirpath)
		return paths
	if not directory:
		printerr("Could not open the following dirpath: %s" % dirpath)
		return paths

	directory.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var file_name := directory.get_next()
	while file_name != "":
		if directory.current_is_dir() and is_recursive:
			var subdirectory := dirpath.path_join(file_name)
			paths.append_array(_find_files(subdirectory, patterns, is_recursive))
		else:
			for pattern in patterns:
				if file_name.match(pattern):
					paths.append(dirpath.path_join(file_name))
		file_name = directory.get_next()

	directory.list_dir_end()
	return paths


## Used to sort the demos by name.
static func _sort_demos(a: Array, b: Array) -> bool:
	return a[0] < b[0]


# Loads the nodes metadata json file and returns the result
func _load_node_metadata() -> Dictionary:
	var metadata_file := FileAccess.open(metadata_file_path, FileAccess.ModeFlags.READ)
	var error := metadata_file.get_error()
	if error == ERR_CANT_OPEN:
		print_debug("Error opening file: " + metadata_file.get_path())
	var test_json_conv = JSON.new()
	test_json_conv.parse(metadata_file.get_as_text())
	return test_json_conv.get_data()


func _on_FilterButton_pressed(button_text: String) -> void:
	set_category_filter(button_text)


func _on_visibility_changed() -> void:
	if visible:
		_select_item(_selected_item)
