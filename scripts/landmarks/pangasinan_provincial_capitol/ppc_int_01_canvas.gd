extends Control
## Different viewpoints remain intact in independently fitted documentary frames.
signal comparison_changed(value: float)

var image: Texture2D
var damage_image: Texture2D
var comparing: bool = false
var amount: float = 0.5
var previous_image: Texture2D
var previous_comparing: bool = false
var previous_amount: float = 0.5
var transition_alpha: float = 1.0:
	set(value):
		transition_alpha = value
		queue_redraw()
var enabled: bool = true
var dragging: bool = false
var touch_index: int = -1


func _ready() -> void:
	clip_contents = true
	texture_filter = TEXTURE_FILTER_LINEAR
	resized.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


func fitted_rect(texture: Texture2D, frame: Rect2) -> Rect2:
	if texture == null or frame.size.x <= 0 or frame.size.y <= 0:
		return Rect2(frame.position, Vector2.ZERO)
	var original := texture.get_size()
	var fitted := original * minf(frame.size.x / original.x, frame.size.y / original.y)
	return Rect2(frame.get_center() - fitted * 0.5, fitted)


func comparison_frames(value: float = -1.0) -> Array[Rect2]:
	if value < 0:
		value = amount
	var divider := size.x * clampf(value, 0, 1)
	return [Rect2(0, 0, divider, size.y), Rect2(divider, 0, size.x - divider, size.y)]


func divider_hit_rect() -> Rect2:
	return Rect2(clampf(size.x * amount - 28, 0, maxf(0, size.x - 56)), 0, 56, size.y)


func _photo(texture: Texture2D, frame: Rect2, alpha: float) -> void:
	var rect := fitted_rect(texture, frame)
	if rect.has_area():
		draw_texture_rect(texture, rect, false, Color(1, 1, 1, alpha))


func _visual(texture: Texture2D, dual: bool, value: float, alpha: float) -> void:
	if dual:
		var frames := comparison_frames(value)
		_photo(damage_image, frames[0], alpha)
		_photo(texture, frames[1], alpha)
	else:
		_photo(texture, Rect2(Vector2.ZERO, size), alpha)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("080f0d"))
	if previous_image != null and transition_alpha < 1:
		_visual(previous_image, previous_comparing, previous_amount, 1 - transition_alpha)
	_visual(image, comparing, amount, transition_alpha)
	if comparing:
		var x := clampf(size.x * amount, 1, maxf(1, size.x - 1))
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color("dec985"), 2)
		var center := Vector2(clampf(x, 22, maxf(22, size.x - 22)), size.y * 0.5)
		draw_rect(Rect2(center - Vector2(20, 24), Vector2(40, 48)), Color("dec985"))
		for direction in [-1, 1]:
			var tip := center + Vector2(direction * 12, 0)
			draw_polyline(PackedVector2Array([tip + Vector2(-direction * 5, -6), tip, tip + Vector2(-direction * 5, 6)]), Color("15251f"), 2)
	if has_focus():
		draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), Color("fff299"), false, 3)


func _choose(value: float) -> void:
	amount = clampf(value, 0, 1)
	accept_event()
	queue_redraw()
	comparison_changed.emit(amount)


func _at(x: float) -> void:
	_choose(x / maxf(1, size.x))


func _gui_input(event: InputEvent) -> void:
	if not enabled or not comparing:
		return
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			dragging = true
			grab_focus()
			_at(event.position.x)
		elif event.index == touch_index:
			end_drag()
			accept_event()
	elif event is InputEventScreenDrag and event.index == touch_index:
		_at(event.position.x)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and touch_index == -1:
		dragging = event.pressed
		accept_event()
		if dragging:
			grab_focus()
			_at(event.position.x)
	elif event is InputEventMouseMotion and dragging and touch_index == -1:
		_at(event.position.x)
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT: _choose(amount - 0.1)
			KEY_RIGHT: _choose(amount + 0.1)
			KEY_HOME: _choose(0)
			KEY_END: _choose(1)


func end_drag() -> void:
	dragging = false
	touch_index = -1
