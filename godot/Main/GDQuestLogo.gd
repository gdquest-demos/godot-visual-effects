extends TextureButton

const COLOR_PRESSED := Color(0.84611, 0.784345, 0.902344)

func _ready() -> void:
	pressed.connect(open_gdquest_website)
	button_down.connect(_toggle_shade.bind(true))
	button_up.connect(_toggle_shade.bind(false))


func open_gdquest_website() -> void:
	OS.shell_open("http://gdquest.com/")


func _toggle_shade(is_down: bool) -> void:
	modulate = COLOR_PRESSED if is_down else Color.WHITE
