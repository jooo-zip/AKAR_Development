extends Control
## Standalone F6 sizing and reopen harness for the real production component.
var _window: Window
var _previous_canvas: Vector2i
var _configured: bool = false
@onready var panel = $CR_INT_02

func _ready() -> void:
	$Reopen.pressed.connect(func() -> void:
		$Reopen.hide()
		panel.open_hotspot())
	panel.closed.connect(func() -> void:
		$Reopen.show()
		$Reopen.grab_focus())
	_configure.call_deferred()

func _configure() -> void:
	if get_tree().current_scene != self: return
	_window = get_window()
	_previous_canvas = _window.content_scale_size
	_window.content_scale_size = Vector2i.ZERO
	_configured = true
	panel.open_hotspot()

func _exit_tree() -> void:
	if _configured and is_instance_valid(_window):
		_window.content_scale_size = _previous_canvas
