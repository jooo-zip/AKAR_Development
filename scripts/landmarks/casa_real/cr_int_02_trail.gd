@tool
extends Control
## Bounded directory gestures. A drag selects; only a deliberate tap opens.
signal selection_requested(index: int, open_preview: bool)
signal dragging_changed(active: bool)
var entries: Array = []
var selected: int = 0
var position_index: float = 0.0:
	set(value):
		position_index = value
		_layout_plaques()
var tween: Tween
var plaques: Array[PanelContainer] = []
var _held: bool = false
var _touch_id: int = -1
var _start := Vector2.ZERO
var _motion := Vector2.ZERO
var _drag_offset: float = 0.0

func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	resized.connect(_layout_plaques)
	if Engine.is_editor_hint():
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		focus_mode = Control.FOCUS_NONE
		return
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	visibility_changed.connect(func() -> void:
		if not is_visible_in_tree(): end_drag())

func configure(galleries: Array) -> void:
	entries = galleries
	for plaque in plaques:
		plaque.queue_free()
	plaques.clear()
	for entry in entries:
		var plaque := PanelContainer.new()
		plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(plaque)
		var text := VBoxContainer.new()
		text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		text.add_theme_constant_override("separation", 16)
		plaque.add_child(text)
		for value in [entry.display_number.to_upper(), entry.official_title, _group_text(entry.principal_group)]:
			var label := Label.new()
			label.text = value
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.size_flags_vertical = Control.SIZE_EXPAND_FILL
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			text.add_child(label)
		plaques.append(plaque)
	center_on(0, false)

func _group_text(group: int) -> String:
	if group == 5: return "GALLERY 5 · 5A + 5B"
	if group == 6: return "GALLERY 6 · 6A + 6B"
	return "BANÁAN GALLERY DIRECTORY"

func center_on(index: int, animate: bool = true) -> void:
	if Engine.is_editor_hint(): animate = false
	cancel_tween()
	end_drag()
	selected = index
	accessibility_name = entries[index].display_number + ": " + entries[index].official_title + ". Left and Right to browse; Enter to preview."
	if animate:
		tween = create_tween()
		tween.tween_property(self, "position_index", float(index), 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func() -> void: tween = null)
	else:
		position_index = float(index)
	_layout_plaques()

func _layout_plaques() -> void:
	var width := 300.0 if size.x > 1000 else (290.0 if size.x > 850 else 330.0)
	var compact := size.y < 220
	var height := minf(260.0, maxf(128.0, size.y - 12.0))
	for i in plaques.size():
		var plaque := plaques[i]
		plaque.size = Vector2(width, height)
		plaque.position = Vector2((size.x - width) / 2 + (i - position_index) * (width + 20) + _drag_offset, (size.y - height) / 2)
		plaque.pivot_offset = plaque.size / 2
		plaque.scale = Vector2.ONE * (1.0 if i == selected else 0.94)
		var style := StyleBoxFlat.new()
		style.bg_color = Color("dfcd92") if i == selected else Color("203129")
		style.border_color = Color("f2e7bd") if i == selected else Color("8c998b")
		style.set_border_width_all(2 if i == selected else 1)
		style.set_content_margin_all(8 if compact else 16)
		plaque.add_theme_stylebox_override("panel", style)
		var labels := plaque.get_child(0).get_children()
		plaque.get_child(0).add_theme_constant_override("separation", 6 if compact else 16)
		for j in labels.size():
			labels[j].add_theme_color_override("font_color", Color("14201b") if i == selected else Color("eee8d6"))
			labels[j].add_theme_font_size_override("font_size", (12 if compact else 14) if j == 2 else (18 if compact else 21))
	queue_redraw()

func _draw() -> void:
	if has_focus():
		draw_rect(Rect2(Vector2(3, 3), size - Vector2(6, 6)), Color("fff299"), false, 3)

func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event is InputEventKey and event.pressed:
		var index := selected
		match event.keycode:
			KEY_LEFT: index -= 1
			KEY_RIGHT: index += 1
			KEY_HOME: index = 0
			KEY_END: index = entries.size() - 1
			KEY_ENTER, KEY_SPACE:
				accept_event()
				if not event.echo: selection_requested.emit(selected, true)
				return
			_: return
		accept_event()
		selection_requested.emit(index, false)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_begin(event.position, -1)
		accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		_begin(event.position, event.index)
		accept_event()

func _begin(at: Vector2, touch_id: int) -> void:
	if _held: return
	cancel_tween()
	position_index = float(selected)
	grab_focus()
	_held = true
	_touch_id = touch_id
	_start = at
	_motion = Vector2.ZERO
	dragging_changed.emit(true)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if not _held: return
	var released := false
	var at := _start + _motion
	if _touch_id == -1 and event is InputEventMouseMotion:
		at = get_global_transform_with_canvas().affine_inverse() * event.position
	elif _touch_id == -1 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		at = get_global_transform_with_canvas().affine_inverse() * event.position
		released = true
	elif event is InputEventScreenDrag and event.index == _touch_id:
		at = get_global_transform_with_canvas().affine_inverse() * event.position
	elif event is InputEventScreenTouch and event.index == _touch_id and not event.pressed:
		at = get_global_transform_with_canvas().affine_inverse() * event.position
		released = true
	else: return
	get_viewport().set_input_as_handled()
	_motion = at - _start
	_drag_offset = clampf(_motion.x, -130, 130) if absf(_motion.x) > absf(_motion.y) else 0.0
	_layout_plaques()
	if not released: return
	var movement := _motion
	end_drag()
	if absf(movement.x) >= 44 and absf(movement.x) > absf(movement.y) * 1.25:
		selection_requested.emit(selected + (-1 if movement.x > 0 else 1), false)
	elif movement.length() < 14:
		for i in plaques.size():
			if plaques[i].get_rect().has_point(at):
				selection_requested.emit(i, true)
				break
	else:
		center_on(selected)

func end_drag() -> void:
	_held = false
	_touch_id = -1
	_drag_offset = 0
	if not Engine.is_editor_hint(): dragging_changed.emit(false)
	_layout_plaques()

func cancel_tween() -> void:
	if tween != null and tween.is_valid(): tween.kill()
	tween = null

func _exit_tree() -> void:
	cancel_tween()
