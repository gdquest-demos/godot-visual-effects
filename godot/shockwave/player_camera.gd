# The main camera that follows the location of the player. It manages
# zooming out when the map button is pressed, and manages the creation
# of a duplicate itself that will live in the minimap viewport, and will follow
# the original's position in the world using a `RemoteTransform2D`.
#
# The camera supports zooming and camera shake.
@tool
extends Camera2D

const SHAKE_EXPONENT := 1.8

@export var decay_rate := 1.0
@export var shake_offset_multiplier := Vector2(100.0, 100.0)

@export var shake_amount := 0.0: set = set_shake_amount
var noise_y := 0

@onready var noise := FastNoiseLite.new()


func _ready() -> void:
	set_physics_process(false)

	randomize()
	noise.seed = randi()
	noise.frequency = 4
	noise.fractal_octaves = 2


func _physics_process(delta):
	self.shake_amount -= decay_rate * delta
	noise_y += delta
	shake()


func shake():
	var amount := pow(shake_amount, SHAKE_EXPONENT)

	if amount == 0:
		return

	offset = Vector2(
		shake_offset_multiplier.x * amount * noise.get_noise_2d(noise_y, amount),
		shake_offset_multiplier.y * amount * noise.get_noise_2d(amount, noise_y)
	)


func set_shake_amount(value):
	if not is_inside_tree():
		await self.ready
	shake_amount = clamp(value, 0.0, 1.0)
	set_physics_process(shake_amount != 0.0)
