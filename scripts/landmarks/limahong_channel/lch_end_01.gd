extends ConferenceRoomInteraction
const SourcesOverlay = preload("res://scripts/landmarks/limahong_channel/lch_sources_overlay.gd")
const HeaderUtilities = preload("res://scripts/landmarks/limahong_channel/lch_header_utilities.gd")
var _header_utilities: HeaderUtilities
## Standalone optional summary: reading alone is valid; NONE is a real state.
signal close_requested
signal topic_changed(topic_index: int)

enum SummaryTopic { NONE = -1, RETREAT, BLOCKADE, ESCAPE, TRADITION, HERITAGE }
const SummaryContent = preload("res://scripts/landmarks/limahong_channel/lch_end_01_content.gd")
const GOLD := Color(0.88, 0.80, 0.55)
const NEUTRAL := Color(0.40, 0.48, 0.42)
var current_topic: SummaryTopic = SummaryTopic.NONE
var _data: SummaryContent
var _board := Control.new()
var _intro := HBoxContainer.new()
var _intro_heading: Label
var _intro_body: Label
var _reflection := VBoxContainer.new()
var _reflection_heading: Label
var _reflection_body: Label
var _takeaway_heading: Label
var _pending: Label
var _card_titles: Array[Label] = []
var _card_bodies: Array[Label] = []
var _card_qualifiers: Array[Label] = []
var _card_numbers: Array[Label] = []
var _card_margins: Array[MarginContainer] = []
var _symbols: Array[Control] = []
var _selected_styles: Array[StyleBoxFlat] = []
var _emphasis: Array[float] = [0, 0, 0, 0, 0]
var _compact: bool = false
var _entrance: Tween
var _selection: Tween

func _ready() -> void:
	super._ready()
	_data = content as SummaryContent
	_build_shell()
	_build_cards()
	_build_lower()
	_board.draw.connect(_draw_storyline)
	_board.resized.connect(_layout_cards)
	resized.connect(_resize_layout)
	visibility_changed.connect(func():
		if _open and not is_visible_in_tree(): close_interaction())
	_resize_layout()
	_header_utilities = HeaderUtilities.new(self, _pending)
	add_child(SourcesOverlay.new(self))

func _label(parent: Node, value: String, font: int, color: Color = Color(0.97, 0.96, 0.92)) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("line_spacing", 0)
	parent.add_child(label)
	return label

func _build_shell() -> void:
	var header := $Main/Margin/Layout/Header
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.add_theme_constant_override("separation", 0)
	header.add_child(titles)
	header.move_child(titles, 0)
	var code_row := HBoxContainer.new()
	titles.add_child(code_row)
	var code := _label(code_row, content.hotspot_id, 12, GOLD)
	code.autowrap_mode = TextServer.AUTOWRAP_OFF
	code.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pending = _label(code_row, "Narration pending", 12)
	_pending.autowrap_mode = TextServer.AUTOWRAP_OFF
	_title.reparent(titles)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_speaker.reparent(header)
	_sources_button.reparent(header)
	header.move_child(_close, -1)
	_speaker.text = "LISTEN"
	_speaker.custom_minimum_size = Vector2(108, 48)
	_speaker.expand_icon = true
	_speaker.add_theme_constant_override("icon_max_width", 22)
	var layout := $Main/Margin/Layout
	layout.add_child(_intro)
	layout.move_child(_intro, 1)
	_intro.add_theme_constant_override("separation", 12)
	_intro_heading = _label(_intro, _data.intro_heading, 15, GOLD)
	_intro_heading.autowrap_mode = TextServer.AUTOWRAP_OFF
	_intro_body = _label(_intro, _data.intro_body, 18)
	_intro_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board.name = "SummaryStoryline"
	_board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(_board)
	layout.move_child(_board, 2)
	_image.hide()
	_image.reparent($Main/Margin/Layout/Controls)
	$Main/Margin/Layout/Controls.hide()
	$Main/Margin/Layout/Sections.hide()

func _build_cards() -> void:
	for i in 5:
		var card: Button
		if i < 3:
			card = _concepts[i]
			card.reparent(_board)
		else:
			card = Button.new()
			_board.add_child(card)
			_concepts.append(card)
			card.pressed.connect(select_concept.bind(i))
		card.name = _data.topics[i].compact_label.capitalize() + "Card"
		card.text = ""
		card.toggle_mode = true
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.accessibility_name = _data.topics[i].full_title + ". " + _data.topics[i].short_body
		card.gui_input.connect(_card_input.bind(i))
		var selected: StyleBoxFlat = card.get_theme_stylebox("normal").duplicate()
		selected.set_border_width_all(2)
		selected.bg_color = Color(0.13, 0.20, 0.16)
		card.add_theme_stylebox_override("pressed", selected)
		card.add_theme_stylebox_override("hover_pressed", selected)
		_selected_styles.append(selected)
		var margin := MarginContainer.new()
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(margin)
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_card_margins.append(margin)
		var column := VBoxContainer.new()
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_theme_constant_override("separation", 3)
		margin.add_child(column)
		var top := HBoxContainer.new()
		top.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top.add_theme_constant_override("separation", 4)
		column.add_child(top)
		var number := _label(top, _data.topics[i].card_number, 14, GOLD)
		number.autowrap_mode = TextServer.AUTOWRAP_OFF
		_card_numbers.append(number)
		var symbol := Control.new()
		symbol.custom_minimum_size = Vector2(20, 20)
		symbol.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top.add_child(symbol)
		symbol.draw.connect(_draw_symbol.bind(i))
		_symbols.append(symbol)
		var title := _label(top, _data.topics[i].full_title, 15, GOLD)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_card_titles.append(title)
		_card_bodies.append(_label(column, _data.topics[i].short_body, 15))
		var qualifier := _label(column, _data.topics[i].qualifier_label, 12, GOLD)
		qualifier.visible = not qualifier.text.is_empty()
		_card_qualifiers.append(qualifier)

func _build_lower() -> void:
	_heading.reparent(_information)
	_information.move_child(_heading, 0)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_information.get_node("Meta").hide()
	%Columns.add_child(_reflection)
	_reflection.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reflection_heading = _label(_reflection, _data.reflection_heading, 16, GOLD)
	_reflection_body = _label(_reflection, _data.reflection_prompt, 18)
	_takeaway_heading = _label(_reflection, _data.takeaway_heading, 16, GOLD)
	_takeaway.reparent(_reflection)
	_takeaway.text = content.learning_takeaway
	_scroll.gui_input.connect(_scroll_key.bind(_scroll))
	_source_scroll.gui_input.connect(_scroll_key.bind(_source_scroll))

func open_interaction() -> bool:
	if not is_node_ready() or _data == null or _data.topics.size() != 5:
		return false
	for i in 5:
		if _data.topics[i] == null or _data.topics[i].topic_id != i: return false
	if _open: return true
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_cancel_animation()
	current_topic = SummaryTopic.NONE
	_title.text = content.title
	_audio.stream = content.narration_stream
	_audio.stop()
	_sources.hide()
	_open = true
	show()
	_update_speaker()
	_render()
	_resize_layout()
	_sync_focus()
	# Keep the default card appearance neutral while retaining visible keyboard focus.
	_sources_button.grab_focus()
	_board.modulate.a = 0.0
	_entrance = create_tween()
	_entrance.tween_property(_board, "modulate:a", 1.0, 0.4)
	_entrance.finished.connect(func(): _entrance = null)
	opened.emit()
	return true

func select_concept(index: int) -> void:
	select_topic(index)

func select_topic(topic: int, animate: bool = true) -> void:
	if not _open or _sources.visible or topic < -1 or topic > 4: return
	_cancel_animation()
	current_topic = (SummaryTopic.NONE if topic == current_topic else topic) as SummaryTopic
	_render()
	if animate:
		_information.modulate.a = 0.65
		_fade = create_tween()
		_fade.tween_property(_information, "modulate:a", 1.0, 0.18)
		_fade.finished.connect(func(): _fade = null)
		if current_topic != SummaryTopic.NONE:
			_set_emphasis(0.0, current_topic)
			_selection = create_tween()
			_selection.tween_method(_set_emphasis.bind(current_topic), 0.0, 1.0, 0.2)
			_selection.finished.connect(func(): _selection = null)
	topic_changed.emit(current_topic)

func _render() -> void:
	_selected = current_topic
	_heading.text = _data.default_detail_heading if current_topic == SummaryTopic.NONE else _data.topics[current_topic].full_title
	_body.text = _data.default_detail_body if current_topic == SummaryTopic.NONE else _data.topics[current_topic].detail_body
	_scroll.scroll_vertical = 0
	_takeaway.show()
	for i in 5:
		_concepts[i].set_pressed_no_signal(i == current_topic)
		_concepts[i].modulate = Color.WHITE
		_concepts[i].scale = Vector2.ONE
		_set_emphasis(1.0 if i == current_topic else 0.0, i)

func _set_emphasis(value: float, index: int) -> void:
	_emphasis[index] = value
	_selected_styles[index].border_color = NEUTRAL.lerp(GOLD, value)
	_board.queue_redraw()

func _cancel_animation() -> void:
	for tween in [_entrance, _selection]:
		if tween != null and tween.is_valid(): tween.kill()
	_entrance = null
	_selection = null
	_cancel_fade()
	_board.modulate = Color.WHITE
	if _selected_styles.size() == 5: _render()

func _resize_layout() -> void:
	if _card_titles.size() != 5: return
	_cancel_animation()
	var small := size.x < 1050
	_compact = size.x < 820
	for side in ["left", "top", "right", "bottom"]:
		$Main/Margin.add_theme_constant_override("margin_" + side, 8 if small else 16)
	# Reclaim shell spacing for the utility status row at the smallest viewport.
	if _compact:
		$Main/Margin.add_theme_constant_override("margin_top", 4)
		$Main/Margin.add_theme_constant_override("margin_bottom", 4)
	$Main/Margin/Layout.add_theme_constant_override("separation", 1 if _compact else (6 if small else 12))
	_title.add_theme_font_size_override("font_size", 18 if small else 26)
	_intro_heading.add_theme_font_size_override("font_size", 12 if small else 15)
	_intro_body.add_theme_font_size_override("font_size", 13 if small else 18)
	_board.custom_minimum_size.y = 180 if _compact else (158 if small else 180)
	%Columns.add_theme_constant_override("separation", 12 if small else 24)
	_information.add_theme_constant_override("separation", 3 if small else 8)
	_reflection.add_theme_constant_override("separation", 3 if small else 8)
	_information.size_flags_stretch_ratio = 0.8 if _compact else 1.0
	_heading.add_theme_font_size_override("font_size", 15 if small else 24)
	_body.add_theme_font_size_override("font_size", 13 if small else 20)
	for label in [_reflection_heading, _takeaway_heading]:
		label.add_theme_font_size_override("font_size", 12 if small else 16)
	for label in [_reflection_body, _takeaway]:
		label.add_theme_font_size_override("font_size", 12 if _compact else (14 if small else 18))
		label.add_theme_constant_override("line_spacing", -2 if _compact else 0)
	for i in 5:
		_card_titles[i].text = _data.topics[i].compact_label if _compact else _data.topics[i].full_title
		_card_titles[i].add_theme_font_size_override("font_size", 12 if small else 15)
		_card_bodies[i].add_theme_font_size_override("font_size", 12 if small else 15)
		_card_qualifiers[i].add_theme_font_size_override("font_size", 10 if small else 12)
		_card_numbers[i].add_theme_font_size_override("font_size", 12 if small else 14)
		for side in ["left", "top", "right", "bottom"]:
			_card_margins[i].add_theme_constant_override("margin_" + side, 4 if small else 8)
	_layout_cards()

func _layout_cards() -> void:
	if _concepts.size() != 5: return
	var gap := 8.0 if _compact else 12.0
	var columns := 3 if _compact else 5
	var width := (_board.size.x - gap * (columns - 1)) / columns
	for i in 5:
		var lower := _compact and i >= 3
		var x := (i - 3) * (width + gap) + (width + gap) * 0.5 if lower else i * (width + gap)
		_concepts[i].position = Vector2(x, 96 if lower else 12)
		_concepts[i].size = Vector2(width, 84.0 if lower else (76.0 if _compact else _board.size.y - 12.0))
	_board.queue_redraw()

func _draw_storyline() -> void:
	if _concepts.size() != 5: return
	var centers: Array[Vector2] = []
	for card in _concepts: centers.append(Vector2(card.get_rect().get_center().x, card.position.y - 6))
	for i in 4:
		if _compact and i == 2:
			var from := Vector2(centers[i].x, _concepts[i].get_rect().end.y)
			_board.draw_polyline(PackedVector2Array([from, Vector2(from.x, centers[i + 1].y), centers[i + 1]]), NEUTRAL, 1.0, true)
		else:
			_board.draw_line(centers[i], centers[i + 1], NEUTRAL, 1.0, true)
	for i in 5:
		_board.draw_line(centers[i] - Vector2(12, 0), centers[i] + Vector2(12, 0), NEUTRAL.lerp(GOLD, _emphasis[i]), 2.0, true)
		_board.draw_line(centers[i], centers[i] + Vector2(0, 6), NEUTRAL, 1.0)

func _draw_symbol(index: int) -> void:
	var canvas := _symbols[index]
	match _data.topics[index].icon_type:
		"path":
			canvas.draw_polyline(PackedVector2Array([Vector2(2, 15), Vector2(8, 15), Vector2(8, 6), Vector2(18, 6), Vector2(14, 2)]), GOLD, 1.5, true)
			canvas.draw_line(Vector2(18, 6), Vector2(14, 10), GOLD, 1.5, true)
		"arc": canvas.draw_arc(Vector2(10, 10), 7, 0.4, TAU - 0.4, 24, GOLD, 1.5, true)
		"water":
			for row in 2:
				var points := PackedVector2Array()
				for x in 19: points.append(Vector2(x + 1, 6 + row * 7 + sin(x * 0.3) * 2))
				canvas.draw_polyline(points, GOLD, 1.5, true)
		"document":
			canvas.draw_rect(Rect2(4, 2, 12, 16), GOLD, false, 1.5)
			for y in [6, 10, 14]: canvas.draw_line(Vector2(7, y), Vector2(13, y), GOLD, 1.0)
		"book":
			canvas.draw_polyline(PackedVector2Array([Vector2(2, 3), Vector2(10, 5), Vector2(18, 3), Vector2(18, 16), Vector2(10, 18), Vector2(2, 16), Vector2(2, 3)]), GOLD, 1.5, true)
			canvas.draw_line(Vector2(10, 5), Vector2(10, 18), GOLD, 1.0)

func _card_input(event: InputEvent, index: int) -> void:
	if not _open or _sources.visible or not event is InputEventKey or not event.pressed: return
	if event.keycode in [KEY_LEFT, KEY_RIGHT]:
		_concepts[index].accept_event()
		_concepts[clampi(index + (-1 if event.keycode == KEY_LEFT else 1), 0, 4)].grab_focus()

func _scroll_key(event: InputEvent, scroll: ScrollContainer) -> void:
	if not event is InputEventKey or not event.pressed: return
	var delta := 0
	match event.keycode:
		KEY_UP: delta = -32
		KEY_DOWN: delta = 32
		KEY_PAGEUP: delta = -int(scroll.size.y * 0.8)
		KEY_PAGEDOWN: delta = int(scroll.size.y * 0.8)
		KEY_HOME: delta = -int(scroll.get_v_scroll_bar().max_value)
		KEY_END: delta = int(scroll.get_v_scroll_bar().max_value)
		_: return
	scroll.accept_event()
	scroll.scroll_vertical += delta

func _sync_focus() -> void:
	var controls: Array[Control] = []
	controls.append_array(_concepts)
	controls.append(_scroll)
	HeaderUtilities.sync_focus(self, controls)

func open_sources() -> void:
	if not _open or _sources.visible: return
	_cancel_animation()
	_source_title.text = "Sources"
	_source_text.text = content.title + "\n\n" + content.source_credit
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()

func _update_speaker() -> void:
	super._update_speaker()
	_speaker.show()
	_speaker.disabled = _audio.stream == null
	_pending.visible = _audio.stream == null
	if _header_utilities != null: _header_utilities.refresh()

func close_interaction() -> void:
	if not _open: return
	_cancel_animation()
	super.close_interaction()
	current_topic = SummaryTopic.NONE
	_render()
	close_requested.emit()

func _exit_tree() -> void:
	for tween in [_entrance, _selection]:
		if tween != null and tween.is_valid(): tween.kill()
	super._exit_tree()
