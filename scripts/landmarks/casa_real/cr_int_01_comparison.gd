@tool
extends Control
## Visibility comparison only: deliberately no completion percentage.
signal value_changed(value: float)
var value: float = 0.5:
	set(new_value):
		value = clampf(new_value, 0.0, 1.0)
		queue_redraw()
var dragging: bool = false
var _touch_index: int = -1

func _ready() -> void:
	custom_minimum_size = Vector2(56, 56)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_HSIZE
	resized.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)

func end_drag() -> void:
	dragging = false
	_touch_index = -1

func _choose(new_value: float) -> void:
	value = new_value
	accept_event()
	value_changed.emit(value)

func _at(position_x: float) -> void:
	_choose((position_x - 28.0) / maxf(size.x - 56.0, 1.0))

func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			dragging = true
			grab_focus()
			_at(event.position.x)
		elif event.index == _touch_index:
			end_drag()
			accept_event()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_at(event.position.x)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and _touch_index == -1:
		dragging = event.pressed
		accept_event()
		if dragging:
			grab_focus()
			_at(event.position.x)
	elif event is InputEventMouseMotion and dragging and _touch_index == -1:
		_at(event.position.x)
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT: _choose(value - 0.05)
			KEY_RIGHT: _choose(value + 0.05)
			KEY_HOME: _choose(0.0)
			KEY_END: _choose(1.0)

func _draw() -> void:
	var center := Vector2(lerpf(28.0, size.x - 28.0, value), size.y * 0.5)
	draw_line(Vector2(28, center.y), Vector2(size.x - 28, center.y), Color("9aa893"), 3.0, true)
	draw_circle(center, 22, Color("d8c58b"), true, -1, true)
	draw_line(center + Vector2(-10, 0), center + Vector2(10, 0), Color("17251f"), 2, true)
	for direction in [-1, 1]:
		var tip := center + Vector2(direction * 11, 0)
		draw_line(tip, tip + Vector2(-direction * 5, -5), Color("17251f"), 2, true)
		draw_line(tip, tip + Vector2(-direction * 5, 5), Color("17251f"), 2, true)
	if has_focus():
		draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), Color("fff299"), false, 3)
