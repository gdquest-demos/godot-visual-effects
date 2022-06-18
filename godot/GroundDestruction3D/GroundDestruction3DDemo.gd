extends Spatial

const ray_length = 1000

export var effect : PackedScene
export var arrow_path : NodePath
var _start : Vector3
var _end : Vector3

onready var arrow : Spatial = get_node(arrow_path)


func _input(event):
	var camera = $Camera
	if event.is_action_pressed("click"):
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * ray_length
		
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [self])
		
		if result:
			_start = result.position
			arrow.visible = true
			arrow.global_transform.origin = Vector3(_start.x, 0.0, _start.z)
	
	if Input.is_action_pressed("click"):
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * ray_length
		
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [self])
		
		if result:
			_end = result.position
			var normal = (_end - _start)
			if normal.length() > 8.0:
				normal = normal.normalized() * 8.0
			normal.y = 0.0
			var right = Vector3.UP.cross(normal)
			arrow.global_transform.basis = Basis(normal, Vector3.UP, right)
	
	if event.is_action_released("click"):
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * ray_length
		
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [self])
		
		if result:
			_end = result.position
			arrow.visible = false
			var normal = (_end - _start).normalized()
			var vfx = effect.instance()
			var angle = Vector2.RIGHT.angle_to(Vector2(normal.x, normal.z))
			add_child(vfx)
			vfx.global_transform.origin = _start
			vfx.rotation = Vector3(0.0, -angle, 0.0)
