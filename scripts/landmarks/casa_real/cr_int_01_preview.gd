extends Control
## F6 sizing only: production always follows its host's canvas policy.
var _window: Window
var _previous_canvas: Vector2i
var _configured: bool = false

func _ready() -> void:
	_configure.call_deferred()

func _configure() -> void:
	if get_tree().current_scene != self:
		return
	_window = get_window()
	_previous_canvas = _window.content_scale_size
	_window.content_scale_size = Vector2i.ZERO
	_configured = true
	$CR_INT_01.open_hotspot()

func _exit_tree() -> void:
	if _configured and is_instance_valid(_window):
		_window.content_scale_size = _previous_canvas
