extends Control
## Identity rail, origin stages and image-bound observation lenses.
## All educational text and normalized interface placements live in Resources.
signal closed
signal selection_changed(index: int)
@export var content: Resource
var selected: int = 0
var active: bool = false
var picture: TextureRect
var heading: Label
var body: Label
var caption: Label
var track: Control
var handle: Label
var selectors: Array[Button] = []
var markers: Array[Button] = []
var text_scroll: ScrollContainer
var text_column: VBoxContainer
var columns: HBoxContainer
var image_area: Control
var image_rect: Rect2
var _fade: Tween
var _move: Tween
var _pointer: int = -2
var _dragging: bool = false

func _ready() -> void:
	var layout := VBoxContainer.new()
	add_child(layout)
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 8)
	columns = HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 16)
	layout.add_child(columns)
	image_area = Control.new()
	image_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	image_area.size_flags_stretch_ratio = 0.62
	columns.add_child(image_area)
	picture = TextureRect.new()
	picture.texture = content.image
	if content.hotspot_id == "UH-EXT-03":
		var crop := AtlasTexture.new()
		crop.atlas = content.image
		crop.region = Rect2(content.image.get_image().get_used_rect())
		crop.filter_clip = true
		picture.texture = crop
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if not content.positions.is_empty() else CanvasItem.TEXTURE_FILTER_LINEAR
	image_area.add_child(picture)
	picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text_scroll = ScrollContainer.new()
	text_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_scroll.size_flags_stretch_ratio = 0.38
	text_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columns.add_child(text_scroll)
	text_column = VBoxContainer.new()
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_column.add_theme_constant_override("separation", 14)
	text_scroll.add_child(text_column)
	heading = _label(text_column, 24)
	body = _label(text_column, 20)
	if not content.takeaway.is_empty():
		var takeaway := _label(text_column, 18)
		takeaway.text = content.takeaway
		takeaway.add_theme_color_override("font_color", Color("d8c58b"))
	caption = _label(layout, 16)
	caption.text = content.image_caption
	if content.hotspot_id == "UH-EXT-01":
		_build_rail(layout)
	else:
		var row := HBoxContainer.new()
		layout.add_child(row)
		for i in content.labels.size():
			var button := _button(row, i)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			selectors.append(button)
		if not content.positions.is_empty():
			for i in content.labels.size():
				var marker := _button(image_area, i)
				marker.text = str(i + 1)
				marker.custom_minimum_size = Vector2(52, 52)
				if content.icons.size() > i:
					marker.text = ""
					marker.icon = content.icons[i]
					marker.expand_icon = true
					marker.add_theme_constant_override("icon_max_width", 38)
				markers.append(marker)
	image_area.resized.connect(_layout_markers)
	hide()

func _label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.custom_minimum_size.x = 1
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label

func _button(parent: Node, index: int) -> Button:
	var button := Button.new()
	button.text = content.labels[index]
	button.accessibility_name = content.labels[index]
	button.tooltip_text = content.labels[index]
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(48, 52)
	button.add_theme_font_size_override("font_size", 16)
	button.pressed.connect(select_state.bind(index))
	button.gui_input.connect(_key_input.bind(index))
	parent.add_child(button)
	return button

func _build_rail(parent: Node) -> void:
	track = Control.new()
	track.custom_minimum_size.y = 66
	parent.add_child(track)
	track.gui_input.connect(_handle_input)
	track.draw.connect(func() -> void:
		track.draw_line(Vector2(_point(0), 8), Vector2(_point(2), 8), Color("867951"), 3))
	for i in 3:
		var stop := _button(track, i)
		stop.gui_input.connect(_handle_input)
		selectors.append(stop)
	handle = Label.new()
	handle.text = "◆"
	handle.accessibility_name = "Drag the identity selector; or select PLACE, 1953, TODAY"
	handle.custom_minimum_size = Vector2.ZERO
	handle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	handle.add_theme_font_size_override("font_size", 12)
	handle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	handle.focus_mode = Control.FOCUS_NONE
	track.add_child(handle)
	track.resized.connect(_layout_rail)

func _point(index: int) -> float:
	return lerpf(80, track.size.x - 80, float(index) / 2.0)

func _layout_rail() -> void:
	_cancel_move()
	_dragging = false
	for i in selectors.size():
		selectors[i].position = Vector2(_point(i) - 72, 14)
		selectors[i].size = Vector2(144, 52)
	handle.position = Vector2(_point(selected) - 12, -4)
	handle.size = Vector2(24, 24)
	track.queue_redraw()

func _layout_markers() -> void:
	if picture.texture == null:
		return
	var native := picture.texture.get_size()
	var fitted := native * minf(image_area.size.x / native.x, image_area.size.y / native.y)
	image_rect = Rect2((image_area.size - fitted) * 0.5, fitted)
	for i in markers.size():
		markers[i].size = Vector2(52, 52)
		var center: Vector2 = image_rect.position + image_rect.size * content.positions[i]
		markers[i].position = center.clamp(image_rect.position + Vector2(26, 26), image_rect.end - Vector2(26, 26)) - Vector2(26, 26)

func open_interaction() -> bool:
	active = true
	show()
	select_state(0)
	if track != null:
		_layout_rail.call_deferred()
	_layout_markers.call_deferred()
	return true

func select_state(index: int) -> void:
	select_identity(index)

func select_identity(index: int) -> void:
	if not active or index < 0 or index >= selectors.size() or not can_process():
		return
	selected = index
	_dragging = false
	_pointer = -2
	_cancel_move()
	if _fade != null:
		_fade.kill()
	heading.text = content.headings[index]
	body.text = content.bodies[index]
	body.visible = not body.text.is_empty()
	text_scroll.scroll_vertical = 0
	for i in selectors.size():
		selectors[i].set_pressed_no_signal(i == index)
		if markers.size() > i:
			markers[i].set_pressed_no_signal(i == index)
	text_column.modulate.a = 0.7
	_fade = create_tween()
	_fade.tween_property(text_column, "modulate:a", 1.0, 0.2)
	if handle != null:
		_move = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_move.tween_property(handle, "position:x", _point(index) - 12, 0.2)
	selection_changed.emit(index)

func _key_input(event: InputEvent, index: int) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode in [KEY_LEFT, KEY_RIGHT]:
			get_viewport().set_input_as_handled()
			select_state(clampi(index + (-1 if event.keycode == KEY_LEFT else 1), 0, selectors.size() - 1))
			selectors[selected].grab_focus()
		elif event.keycode == KEY_E:
			get_viewport().set_input_as_handled()
			select_state(index)

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_dragging = true
		_pointer = -1
	elif event is InputEventScreenTouch and event.pressed:
		_dragging = true
		_pointer = event.index
	if _dragging:
		_cancel_move()
		handle.accept_event()

func _input(event: InputEvent) -> void:
	if not _dragging or not active:
		return
	var position_event: bool = (_pointer == -1 and (event is InputEventMouseMotion or event is InputEventMouseButton)) or (event is InputEventScreenDrag and event.index == _pointer) or (event is InputEventScreenTouch and event.index == _pointer)
	if not position_event:
		return
	var local: Vector2 = track.get_global_transform_with_canvas().affine_inverse() * event.position
	handle.position.x = clampf(local.x, _point(0), _point(2)) - 12
	get_viewport().set_input_as_handled()
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and not event.pressed:
		select_identity(roundi((handle.position.x + 12 - _point(0)) / maxf(1, _point(2) - _point(0)) * 2))

func _cancel_move() -> void:
	if _move != null:
		_move.kill()
	_move = null

func close_interaction() -> void:
	active = false
	_dragging = false
	_cancel_move()
	if _fade != null:
		_fade.kill()
	text_column.modulate.a = 1
	selected = 0
	hide()
	closed.emit()
