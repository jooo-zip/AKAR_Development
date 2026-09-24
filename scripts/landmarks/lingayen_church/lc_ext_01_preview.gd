extends Control
## F6-only sizing aid. Embedded instances retain their host's canvas policy.

var _window: Window
var _previous_canvas: Vector2i
var _configured: bool = false

func _ready() -> void:
	_configure_standalone.call_deferred()

func _configure_standalone() -> void:
	if get_tree().current_scene != self:
		return
	_window = get_window()
	_previous_canvas = _window.content_scale_size
	_window.content_scale_size = Vector2i.ZERO
	_configured = true

func _exit_tree() -> void:
	if _configured and is_instance_valid(_window):
		_window.content_scale_size = _previous_canvas
