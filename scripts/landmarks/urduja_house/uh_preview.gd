extends Control
## F6 only. The component uses its parent's rectangle in production.
var _old_canvas: Vector2i
var _configured: bool = false
func _ready() -> void:
	if get_tree().current_scene == self:
		_old_canvas = get_window().content_scale_size
		get_window().content_scale_size = Vector2i.ZERO
		_configured = true
	$Frame/Hotspot.open_interaction.call_deferred()
func _exit_tree() -> void:
	if _configured:
		get_window().content_scale_size = _old_canvas
