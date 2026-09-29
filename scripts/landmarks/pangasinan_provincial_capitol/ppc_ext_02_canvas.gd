extends Control
## All annotation geometry shares the fitted photograph's transform.

signal reveal_changed(value: float)

const GOLD := Color("e2c87e")
const REGIONS := {
	&"steps": Rect2(0.26, 0.78, 0.48, 0.095),
	&"portico": Rect2(0.404, 0.49, 0.184, 0.30),
	&"ionic_columns": Rect2(0.418, 0.535, 0.15, 0.245),
	&"doors": Rect2(0.482, 0.695, 0.032, 0.086),
}
var texture: Texture2D
var mode: StringName = &"overview"
var feature: StringName = &"none"
var layer: StringName = &"airflow"
var reveal: float = 0.0
var enabled: bool = true
var dragging: bool = false
var touch_index: int = -1
var zoom: float = 1.0:
	set(value):
		zoom = value
		queue_redraw()
var highlight_alpha: float = 1.0:
	set(value):
		highlight_alpha = value
		queue_redraw()


func _ready() -> void:
	clip_contents = true
	resized.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


func photo_rect() -> Rect2:
	if texture == null or size.x <= 0 or size.y <= 0:
		return Rect2()
	var original := texture.get_size()
	var available := size
	var fitted := original * minf(available.x / original.x, available.y / original.y)
	var displayed := fitted * zoom
	# Zoom toward the entrance, retaining the original photo coordinate system.
	var center := Vector2(0.5, lerpf(0.5, 0.62, clampf((zoom - 1.0) / 0.32, 0.0, 1.0)))
	return Rect2(available * 0.5 - displayed * center, displayed)


func image_point(point: Vector2) -> Vector2:
	var rect := photo_rect()
	return rect.position + rect.size * point


func image_region(rect: Rect2) -> Rect2:
	return Rect2(image_point(rect.position), photo_rect().size * rect.size)


func _region(rect: Rect2, tint: Color = GOLD) -> void:
	var displayed := image_region(rect)
	draw_rect(displayed, Color(tint, 0.15 * highlight_alpha))
	# Corner brackets leave documentary detail unobscured.
	var length := minf(14.0, minf(displayed.size.x, displayed.size.y) * 0.35)
	for corner in [Vector2.ZERO, Vector2(1, 0), Vector2(0, 1), Vector2.ONE]:
		var p: Vector2 = displayed.position + displayed.size * corner
		draw_line(p, p + Vector2(length * (1 - 2 * corner.x), 0), Color(tint, highlight_alpha), 2)
		draw_line(p, p + Vector2(0, length * (1 - 2 * corner.y)), Color(tint, highlight_alpha), 2)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("0b1311"))
	if texture == null:
		return
	draw_texture_rect(texture, photo_rect(), false)
	if mode == &"balance":
		# The generous drag strip uses sky, leaving the façade and steps clear.
		var rail := Rect2(24, 38, maxf(1, size.x - 48), 4)
		draw_rect(Rect2(0, 0, size.x, 52), Color(0.03, 0.06, 0.05, 0.8))
		draw_rect(rail, Color("7c8779"))
		draw_rect(Rect2(rail.position, Vector2(rail.size.x * reveal, 4)), GOLD)
		draw_rect(Rect2(rail.position + Vector2(rail.size.x * reveal - 7, -10), Vector2(14, 24)), GOLD)
		draw_line(image_point(Vector2(0.495, 0.28)), image_point(Vector2(0.495, 0.88)), GOLD, 2)
		if reveal > 0.0:
			_region(Rect2(0.495 - 0.38 * reveal, 0.46, 0.38 * reveal, 0.32))
			_region(Rect2(0.495, 0.46, 0.38 * reveal, 0.32))
	elif mode == &"entrance" and REGIONS.has(feature):
		_region(REGIONS[feature])
	elif mode == &"climate":
		for rect in [Rect2(0.31, 0.545, 0.075, 0.20), Rect2(0.60, 0.545, 0.225, 0.20)]:
			if layer == &"airflow":
				_region(rect, Color("a8d2c6"))
				var p := image_point(rect.get_center())
				var end := p + Vector2(0, -28)
				draw_line(p, end, Color("a8d2c6"), 2)
				draw_polyline(PackedVector2Array([end + Vector2(-5, 7), end, end + Vector2(5, 7)]), Color("a8d2c6"), 2)
			elif layer == &"shade":
				_region(Rect2(rect.position.x, 0.53, rect.size.x, 0.25))
				draw_rect(image_region(Rect2(rect.position.x, 0.53, rect.size.x, 0.25)), Color(0.03, 0.12, 0.1, 0.27 * highlight_alpha))
			else:
				_region(Rect2(rect.position.x, 0.475, rect.size.x, 0.055))
				for n in 4:
					var p := image_point(Vector2(rect.position.x + rect.size.x * (n + 0.5) / 4.0, 0.40))
					draw_line(p, p + Vector2(0, 12), Color("a8d2c6"), 2)
	if has_focus():
		draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), Color("fff29a"), false, 3)


func set_reveal(value: float) -> void:
	reveal = clampf(value, 0.0, 1.0)
	queue_redraw()
	reveal_changed.emit(reveal)


func _gui_input(event: InputEvent) -> void:
	if not enabled or mode != &"balance":
		return
	if event is InputEventKey and event.pressed and event.keycode in [KEY_LEFT, KEY_RIGHT]:
		accept_event()
		set_reveal(reveal + (0.1 if event.keycode == KEY_RIGHT else -0.1))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		dragging = event.pressed
		if dragging:
			grab_focus()
			set_reveal((event.position.x - 24) / maxf(1, size.x - 48))
	elif event is InputEventMouseMotion and dragging:
		accept_event()
		set_reveal((event.position.x - 24) / maxf(1, size.x - 48))
	elif event is InputEventScreenTouch:
		accept_event()
		if event.pressed and touch_index == -1:
			touch_index = event.index
			grab_focus()
			set_reveal((event.position.x - 24) / maxf(1, size.x - 48))
		elif event.index == touch_index:
			touch_index = -1
	elif event is InputEventScreenDrag and event.index == touch_index:
		accept_event()
		set_reveal((event.position.x - 24) / maxf(1, size.x - 48))


func cancel_drag() -> void:
	dragging = false
	touch_index = -1
