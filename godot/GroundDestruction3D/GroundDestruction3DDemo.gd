extends Spatial

const ray_length = 1000

export var effect: PackedScene
export var arrow_path: NodePath

var _start := Vector3.ZERO
var _end := Vector3.ZERO

onready var camera := $Camera as Camera
onready var arrow := get_node(arrow_path) as Spatial


func _input(event):
	if not (event.is_action("click") or event is InputEventMouseMotion):
		return

	var result := project_ray_from_camera(event.position)
	if not result:
		return

	if event.is_action_pressed("click"):
		_start = result.position
		arrow.visible = true
		arrow.global_transform.origin = Vector3(_start.x, 0.0, _start.z)

	if Input.is_action_pressed("click"):
		_end = result.position
		var normal := _end - _start
		if normal.length() > 8.0:
			normal = normal.normalized() * 8.0
		normal.y = 0.0
		var right := Vector3.UP.cross(normal)
		arrow.global_transform.basis = Basis(normal, Vector3.UP, right)

	if event.is_action_released("click"):
		_end = result.position
		arrow.visible = false
		var normal := (_end - _start).normalized()
		var vfx := effect.instance()
		var angle := Vector2.RIGHT.angle_to(Vector2(normal.x, normal.z))
		add_child(vfx)
		vfx.global_transform.origin = _start
		vfx.rotation = Vector3(0.0, -angle, 0.0)


func project_ray_from_camera(screen_position: Vector2) -> Dictionary:
	var from := camera.project_ray_origin(screen_position)
	var to := from + camera.project_ray_normal(screen_position) * ray_length
	var space_state := get_world().direct_space_state
	return space_state.intersect_ray(from, to, [self])
