extends Node

const DIRECTIONS := [
	Vector3.DOWN, Vector3.UP, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK
]

var TILES_TO_IGNORE := []

onready var gridmap: GridMap = $GridMap


class BoxExtents:
	var start := Vector3.ZERO
	var end := Vector3.ZERO
	var size := Vector3.ZERO

	func _init(p_start: Vector3, p_end: Vector3) -> void:
		start = p_start
		end = p_end
		size = (end - start).abs()


func _ready() -> void:
	# We use a dictionary for constant time access and erase operations when
	# flood filling.
	var cells_dict := {}
	for cell in gridmap.get_used_cells():
		if cell in TILES_TO_IGNORE:
			continue
		cells_dict[cell] = null

	var shapes := find_contiguous_shapes(cells_dict)
	var boxes_extents := []
	for shape in shapes:
		var boxes := calculate_collision_boxes(shape)
		for box in boxes:
			boxes_extents.append(box)

	for extents in boxes_extents:
		make_box_collider(extents.start, extents.end)


func find_contiguous_shapes(cells: Dictionary) -> Dictionary:
	var index := 0
	var shapes := {}
	while not cells.empty():
		shapes[index] = _flood_fill(cells.keys()[0], cells)
		index += 1
	return shapes


func _flood_fill(cell: Vector3, cells: Dictionary) -> Dictionary:
	assert(cells.has(cell))

	var filled_cells := {}
	var stack := [cell]

	while not stack.empty():
		var current = stack.pop_back()
		if current in filled_cells:
			continue

		filled_cells[current] = null
		cells.erase(current)

		for direction in DIRECTIONS:
			var neighbor: Vector3 = current + direction
			if not cells.has(neighbor):
				continue
			if neighbor in filled_cells:
				continue

			stack.append(neighbor)

	return filled_cells


func calculate_collision_boxes(shape: Dictionary) -> Dictionary:
	var boxes := {}
	var extents := calculate_extents(shape)
	# Start at the min end, and go X+, Z+, Y+
	while not shape.empty():
		var start := _find_start(shape, extents)
		var max_size := (extents.end - start).abs()
		var row := _find_first_row(shape, start, max_size)

		# find columns matching row
		var rect := []
		for cell in row:
			rect.append(row)
			shape.erase(cell)

		for z in max_size.z - 1:
			var column := []
			for cell in row:
				var offset_cell: Vector3 = cell + Vector3.BACK * (z + 1)
				if not offset_cell in shape:
					break
				column.append(offset_cell)

			for cell in column:
				rect.append(cell)
				shape.erase(cell)

	# Convert to a rect slice?
	# Return only rect slices for now

	return boxes


func _find_start(shape: Dictionary, extents: BoxExtents) -> Vector3:
	if extents.start in shape:
		return extents.start

	var start := extents.start
	for z in extents.size.z:
		start.z = extents.start + z
		for y in extents.size.y:
			start.y = extents.start + y
			for x in extents.size.x:
				start.x = extents.start + x
				if start in shape:
					return start
	return Vector3.INF


func _find_first_row(shape: Dictionary, start: Vector3, max_size: Vector3) -> Array:
	var cell := start
	var row := []
	for x in max_size.x - 1:
		cell.x = start.x + x
		if cell in shape:
			row.append(cell)
	return row


func calculate_extents(cells: Dictionary) -> BoxExtents:
	var min_cell := Vector3.INF
	var max_cell := Vector3.ZERO

	for cell in cells:
		if cell.x < min_cell.x:
			min_cell.x = cell.x
		if cell.y < min_cell.y:
			min_cell.y = cell.y
		if cell.z < min_cell.z:
			min_cell.z = cell.z

		if cell.x > max_cell.x:
			max_cell.x = cell.x
		if cell.y > min_cell.y:
			max_cell.y = cell.y
		if cell.z > max_cell.z:
			max_cell.z = cell.z

	return BoxExtents.new(min_cell, max_cell)


func make_box_collider(start: Vector3, end: Vector3) -> void:
	var size: Vector3 = (end - start + Vector3.ONE).abs() * gridmap.cell_size
	var position: Vector3 = (end + start + Vector3.ONE) / 2
	var extents := size / 2

	var collision_shape := CollisionShape.new()
	collision_shape.shape = BoxShape.new()
	collision_shape.shape.extents = extents
	$StaticBody.add_child(collision_shape)
	collision_shape.global_transform.origin = position * gridmap.cell_size
