@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/casa_real/cr_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview

## Standalone portrait network; one authoritative selection drives every view.
signal close_requested
enum ViewState { OVERVIEW, PERSON_FOCUS }
enum VisualMode { PORTRAIT, CASA_REAL_CONTEXT }
const PeopleContent = preload("res://scripts/landmarks/casa_real/cr_int_03_content.gd")
const ConnectionLayer = preload("res://scripts/landmarks/casa_real/cr_int_03_connection_layer.gd")
var current_view: ViewState = ViewState.OVERVIEW
var visual_mode: VisualMode = VisualMode.PORTRAIT
var selected_person_index: int = -1
var selected_period_id: StringName = &""
var _transition: Tween
var _network: Control
var _connections: ConnectionLayer
var _intro: Label
var _intro_body: Label
var _anchor: Label
var _helper: Label
var _periods: Array[Button] = []
var _portraits: Array[Button] = []
var _photos: Array[TextureRect] = []
var _names: Array[Label] = []
var _dates: Array[Label] = []
var _rail: ScrollContainer
var _rail_contents: Control
var _focus_view: HBoxContainer
var _visual: Control
var _old_image: TextureRect
var _caption: Label
var _details: VBoxContainer
var _reading: ScrollContainer
var _copy: VBoxContainer
var _metadata: HBoxContainer
var _date: Label
var _period_label: Label
var _person_name: Label
var _role: Label
var _contribution: Label
var _actions: MarginContainer
var _context: Button
var _view_all: Button
var _gesture_target: Control
var _gesture_origin := Vector2.ZERO
var _gesture_last := Vector2.ZERO
var _gesture_scroll: ScrollContainer
var _dragging: bool = false
var _touch_index: int = -1

func _ready() -> void:
	if Engine.is_editor_hint():
		_refresh_editor_preview.call_deferred()
		return
	_presentation_root = self
	super._ready()
	_build_presentation()
	resized.connect(_resize_layout)
	visibility_changed.connect(func() -> void:
		if _open and not is_visible_in_tree(): close_interaction())
	_resize_layout()
	_open_standalone.call_deferred()

func _build_presentation() -> void:
	_network = Control.new()
	_connections = ConnectionLayer.new()
	_intro = Label.new()
	_intro_body = Label.new()
	_anchor = Label.new()
	_helper = Label.new()
	_rail = ScrollContainer.new()
	_rail_contents = Control.new()
	_focus_view = HBoxContainer.new()
	_visual = Control.new()
	_old_image = TextureRect.new()
	_caption = Label.new()
	_details = VBoxContainer.new()
	_reading = ScrollContainer.new()
	_copy = VBoxContainer.new()
	_metadata = HBoxContainer.new()
	_date = Label.new()
	_period_label = Label.new()
	_person_name = Label.new()
	_role = Label.new()
	_contribution = Label.new()
	_actions = MarginContainer.new()
	_context = Button.new()
	_view_all = Button.new()
	_periods.clear()
	_portraits.clear()
	_photos.clear()
	_names.clear()
	_dates.clear()
	var layout := _presentation_root.get_node("Main/Margin/Layout")
	var header := _presentation_root.get_node("Main/Margin/Layout/Header")
	_sources_button.reparent(header)
	_speaker.reparent(header)
	header.move_child(_close, header.get_child_count() - 1)
	_title.text = content.title
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sources_button.text = "SOURCES"
	_close.text = "CLOSE"
	_speaker.expand_icon = false
	_speaker.add_theme_constant_override("icon_max_width", 22)
	for old in [_presentation_root.get_node("Main/Margin/Layout/Columns"), _presentation_root.get_node("Main/Margin/Layout/Controls"), _presentation_root.get_node("Main/Margin/Layout/Sections")]: old.hide()
	layout.add_child(_network)
	_network.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_network.add_child(_connections)
	for label in [_intro, _intro_body, _anchor, _helper]:
		_network.add_child(label)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro.text = content.overview_heading
	_intro_body.text = content.overview_body
	_anchor.text = content.anchor_title + "\n" + content.anchor_location
	_anchor.add_theme_color_override("font_color", Color("d8c58b"))
	for i in content.period_ids.size():
		var button := Button.new()
		_network.add_child(button)
		button.toggle_mode = true
		button.accessibility_name = content.period_labels[i]
		button.tooltip_text = content.period_labels[i]
		if not Engine.is_editor_hint():
			button.pressed.connect(select_period.bind(content.period_ids[i]))
		_periods.append(button)
	_network.add_child(_focus_view)
	_focus_view.add_theme_constant_override("separation", 20)
	_focus_view.add_child(_visual)
	_focus_view.add_child(_details)
	_visual.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_visual.add_child(_old_image)
	_image.reparent(_visual)
	_visual.add_child(_caption)
	for picture in [_image, _old_image]:
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.add_theme_color_override("font_color", Color("d8c58b"))
	_details.add_child(_reading)
	_reading.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_reading.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_reading.add_child(_copy)
	_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_copy.add_theme_constant_override("separation", 4)
	for label in [_person_name, _role]:
		_copy.add_child(label)
	_copy.add_child(_metadata)
	_metadata.add_child(_date)
	_metadata.add_child(_period_label)
	_period_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_metadata.add_theme_constant_override("separation", 12)
	_copy.add_child(_contribution)
	for label in [_date, _period_label, _person_name, _role, _contribution]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_date.autowrap_mode = TextServer.AUTOWRAP_OFF
	_date.add_theme_color_override("font_color", Color("d8c58b"))
	_period_label.add_theme_color_override("font_color", Color("c2bfae"))
	_details.add_child(_actions)
	_actions.add_child(_context)
	_context.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not Engine.is_editor_hint():
		_context.pressed.connect(toggle_context)
	_network.add_child(_view_all)
	_view_all.text = "VIEW ALL CONNECTIONS"
	if not Engine.is_editor_hint():
		_view_all.pressed.connect(view_all_connections)
	var secondary_style := _view_all.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	secondary_style.bg_color = Color("14201b")
	secondary_style.border_color = Color("647363")
	secondary_style.content_margin_left = 10.0
	secondary_style.content_margin_right = 10.0
	_view_all.add_theme_stylebox_override("normal", secondary_style)
	_view_all.add_theme_color_override("font_color", Color("d2d0bf"))
	_network.add_child(_rail)
	_rail.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_rail.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rail.add_child(_rail_contents)
	for i in content.people.size():
		var entry = content.people[i]
		var button := Button.new()
		_rail_contents.add_child(button)
		button.toggle_mode = true
		button.accessibility_name = entry.display_name + ", " + entry.date_label
		if not Engine.is_editor_hint():
			button.pressed.connect(select_person.bind(i))
		if not Engine.is_editor_hint():
			button.gui_input.connect(_portrait_key.bind(i))
		if not Engine.is_editor_hint():
			button.focus_entered.connect(_reveal_portrait.bind(i))
		var mount := StyleBoxFlat.new()
		mount.bg_color = Color("192b25")
		mount.border_color = Color("77806a")
		mount.set_border_width_all(1)
		button.add_theme_stylebox_override("normal", mount)
		var selected := mount.duplicate() as StyleBoxFlat
		selected.bg_color = Color("3b3e2e")
		selected.border_color = Color("d8c58b")
		selected.set_border_width_all(2)
		button.add_theme_stylebox_override("pressed", selected)
		button.add_theme_stylebox_override("hover_pressed", selected)
		_portraits.append(button)
		var photo := TextureRect.new()
		photo.texture = entry.portrait
		photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		photo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(photo)
		_photos.append(photo)
		var name_label := Label.new()
		var date_label := Label.new()
		name_label.text = entry.short_name
		date_label.text = entry.compact_date
		for label in [name_label, date_label]:
			button.add_child(label)
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		date_label.add_theme_color_override("font_color", Color("d8c58b"))
		_names.append(name_label)
		_dates.append(date_label)
	for button in _buttons():
		button.custom_minimum_size.y = 52
		if not Engine.is_editor_hint():
			button.gui_input.connect(_button_key.bind(button))
	for scroll in [_reading, _source_scroll]:
		if not Engine.is_editor_hint():
			scroll.gui_input.connect(_reading_key.bind(scroll))
		scroll.add_theme_stylebox_override("focus", _close.get_theme_stylebox("focus"))
	_network.resized.connect(_layout_network)
	_visual.resized.connect(_layout_image)
	if not Engine.is_editor_hint():
		_rail.get_h_scroll_bar().value_changed.connect(func(_value: float) -> void: _update_connections())

func _open_standalone() -> void:
	if Engine.is_editor_hint():
		return
	if get_tree().current_scene == self: open_hotspot()

func open_hotspot() -> bool:
	if Engine.is_editor_hint():
		return false
	return open_interaction()

func open_interaction() -> bool:
	if Engine.is_editor_hint():
		return false
	if not is_node_ready() or not content is PeopleContent: return false
	if content.people.size() != 5 or content.period_ids.size() != 3 or content.narration_stream == null: return false
	for entry in content.people:
		if entry == null or entry.portrait == null or entry.context_image == null or entry.period_id not in content.period_ids: return false
	if _open: return true
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = null
	if previous != null: _return_focus = weakref(previous)
	_open = true
	_audio.stream = content.narration_stream
	show()
	reset_hotspot()
	_periods[0].grab_focus()
	opened.emit()
	return true

func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_transition()
	_end_gesture()
	stop_narration()
	_sources.hide()
	_source_scroll.scroll_vertical = 0
	_clear_selection()
	_render()

func _clear_selection() -> void:
	if Engine.is_editor_hint():
		return
	current_view = ViewState.OVERVIEW
	visual_mode = VisualMode.PORTRAIT
	selected_person_index = -1
	selected_period_id = &""
	_image.texture = null
	_old_image.texture = null
	_rail.scroll_horizontal = 0
	_reading.scroll_vertical = 0

func select_person(index: int) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or index < 0 or index >= content.people.size(): return
	_cancel_transition()
	selected_person_index = index
	selected_period_id = content.people[index].period_id
	current_view = ViewState.PERSON_FOCUS
	visual_mode = VisualMode.PORTRAIT
	_reading.scroll_vertical = 0
	_render()
	_focus_view.modulate.a = 0.65
	_transition = create_tween()
	_transition.tween_property(_focus_view, "modulate:a", 1.0, 0.2)
	_reveal_portrait.call_deferred(index)

func select_period(period_id: StringName) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or period_id not in content.period_ids: return
	_cancel_transition()
	_clear_selection()
	selected_period_id = period_id
	_render()

func view_all_connections() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible: return
	_cancel_transition()
	_clear_selection()
	_render()
	_periods[0].grab_focus()

func toggle_context() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or current_view != ViewState.PERSON_FOCUS: return
	_cancel_transition()
	var previous: Texture2D = _image.texture
	visual_mode = VisualMode.CASA_REAL_CONTEXT if visual_mode == VisualMode.PORTRAIT else VisualMode.PORTRAIT
	_render()
	_old_image.texture = previous
	_old_image.show()
	_old_image.modulate.a = 1.0
	_image.modulate.a = 0.0
	_transition = create_tween().set_parallel(true)
	_transition.tween_property(_image, "modulate:a", 1.0, 0.2)
	_transition.tween_property(_old_image, "modulate:a", 0.0, 0.2)
	_transition.chain().tween_callback(func() -> void:
		_old_image.hide()
		_old_image.texture = null)

func _render() -> void:
	var overview := current_view == ViewState.OVERVIEW
	_intro.visible = overview
	_intro_body.visible = overview
	_helper.visible = overview
	_view_all.visible = not overview
	_focus_view.visible = not overview
	_helper.text = content.overview_helper if selected_period_id == &"" else content.period_helper
	for i in _periods.size(): _periods[i].set_pressed_no_signal(content.period_ids[i] == selected_period_id)
	for i in _portraits.size():
		_portraits[i].set_pressed_no_signal(i == selected_person_index)
		_portraits[i].modulate.a = 1.0 if selected_period_id == &"" or content.people[i].period_id == selected_period_id else 0.65
	if not overview:
		var entry = content.people[selected_person_index]
		_date.text = entry.date_label
		_period_label.text = entry.period_label
		_person_name.text = entry.display_name
		_role.text = entry.role_label
		_contribution.text = entry.contribution
		_image.texture = entry.portrait if visual_mode == VisualMode.PORTRAIT else entry.context_image
		_image.accessibility_name = entry.display_name if visual_mode == VisualMode.PORTRAIT else entry.context_label
		_caption.text = entry.context_label
		_caption.visible = visual_mode == VisualMode.CASA_REAL_CONTEXT
		_context.text = "VIEW CASA REAL CONNECTION" if visual_mode == VisualMode.PORTRAIT else "RETURN TO PORTRAIT"
	_layout_network()
	_sync_focus()

func _resize_layout() -> void:
	if Engine.is_editor_hint():
		EditorPresentation.resize(self, _presentation_root)
	if not is_node_ready(): return
	var compact := size.x < 1100
	var inset := 0.02 if compact else 0.05
	_presentation_root.get_node("Main").set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_presentation_root.get_node("Main").anchor_left = inset
	_presentation_root.get_node("Main").anchor_top = inset
	_presentation_root.get_node("Main").anchor_right = 1.0 - inset
	_presentation_root.get_node("Main").anchor_bottom = 1.0 - inset
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	for button in _buttons(): button.add_theme_font_size_override("font_size", 16 if compact else 18)
	_view_all.add_theme_font_size_override("font_size", 16)
	_view_all.custom_minimum_size.y = 48
	# Preserve the existing context-button width while centering the single action.
	# Integer margins differ by one pixel because the preserved free space is odd.
	var action_margin := 45 if compact else 49
	_actions.add_theme_constant_override("margin_left", action_margin)
	_actions.add_theme_constant_override("margin_right", action_margin + 1)
	for label in [_intro, _intro_body, _anchor, _helper, _date, _period_label, _role, _contribution]:
		label.add_theme_font_size_override("font_size", 18 if compact else 20)
	_person_name.add_theme_font_size_override("font_size", 22 if compact else 26)
	_anchor.add_theme_font_size_override("font_size", 16)
	_intro_body.add_theme_font_size_override("font_size", 18)
	for label in [_date, _period_label]: label.add_theme_font_size_override("font_size", 16 if compact else 18)
	_caption.add_theme_font_size_override("font_size", 16 if compact else 18)
	_source_text.add_theme_font_size_override("font_size", 18 if compact else 22)
	for i in _periods.size():
		_periods[i].text = content.compact_period_labels[i] if size.x < 900 else content.period_labels[i]
	_visual.size_flags_stretch_ratio = 0.34 if compact else 0.38
	_details.size_flags_stretch_ratio = 0.66 if compact else 0.62
	_layout_network.call_deferred()

func _place(control: Control, at: Vector2, extent: Vector2) -> void:
	control.position = at
	control.size = extent

func _layout_network() -> void:
	if not is_node_ready() or _network.size.x <= 0: return
	var width := _network.size.x
	var height := _network.size.y
	var overview := current_view == ViewState.OVERVIEW
	var compact := size.x < 1100
	_connections.size = _network.size
	var anchor_y := 94.0 if overview else 0.0
	var period_y := anchor_y + 66.0
	var period_width := (width - 32.0) / 3.0
	_place(_intro, Vector2.ZERO, Vector2(width, 28))
	_place(_intro_body, Vector2(0, 30), Vector2(width, 44))
	_place(_anchor, Vector2(width * 0.5 - 155, anchor_y), Vector2(310, 48))
	_place(_view_all, Vector2.ZERO, Vector2(_view_all.get_combined_minimum_size().x, 48))
	for i in _periods.size(): _place(_periods[i], Vector2(i * (period_width + 16), period_y), Vector2(period_width, 52))
	var rail_y: float
	var rail_height: float
	if overview:
		rail_y = period_y + 78
		rail_height = maxf(90, height - rail_y - 30)
		_place(_helper, Vector2(0, height - 26), Vector2(width, 26))
	else:
		rail_height = 76.0 if compact else 96.0
		rail_y = height - rail_height
		_place(_focus_view, Vector2(18, period_y + 64), Vector2(width - 36, maxf(80, rail_y - period_y - 80)))
	var card_width := (width - 48) / 5.0
	if not overview and compact: card_width = (width - 24) / 3.15
	_rail_contents.custom_minimum_size = Vector2(5 * card_width + 48, rail_height)
	_rail_contents.size = _rail_contents.custom_minimum_size
	_place(_rail, Vector2(0, rail_y), Vector2(width, rail_height))
	for i in _portraits.size():
		_place(_portraits[i], Vector2(i * (card_width + 12), 0), Vector2(card_width, rail_height))
		if overview:
			_place(_photos[i], Vector2(8, 8), Vector2(card_width - 16, rail_height - 55))
			_place(_names[i], Vector2(2, rail_height - 44), Vector2(card_width - 4, 22))
			_place(_dates[i], Vector2(2, rail_height - 23), Vector2(card_width - 4, 22))
		else:
			_place(_photos[i], Vector2(6, 6), Vector2(card_width * 0.34, rail_height - 12))
			_place(_names[i], Vector2(card_width * 0.36, rail_height * 0.5 - 22), Vector2(card_width * 0.64 - 4, 22))
			_place(_dates[i], Vector2(card_width * 0.36, rail_height * 0.5), Vector2(card_width * 0.64 - 4, 22))
		_names[i].add_theme_font_size_override("font_size", 16 if compact else 18)
		_dates[i].add_theme_font_size_override("font_size", 14 if compact else 16)
	_layout_image()
	_update_connections.call_deferred()
	if selected_person_index >= 0 and not _dragging:
		_reveal_portrait.call_deferred(selected_person_index)

func _layout_image() -> void:
	var caption_height := 42.0 if _caption.visible else 0.0
	for picture in [_image, _old_image]: _place(picture, Vector2.ZERO, Vector2(_visual.size.x, maxf(0, _visual.size.y - caption_height)))
	_place(_caption, Vector2(0, _visual.size.y - caption_height), Vector2(_visual.size.x, caption_height))

func _update_connections() -> void:
	if not is_node_ready(): return
	_connections.paths.clear()
	_connections.highlighted.clear()
	var connection_anchor_bottom := _anchor.position + Vector2(_anchor.size.x * 0.5, _anchor.size.y)
	for i in _periods.size():
		var end := _periods[i].position + Vector2(_periods[i].size.x * 0.5, 0)
		_add_connection([connection_anchor_bottom, Vector2(connection_anchor_bottom.x, end.y - 12), Vector2(end.x, end.y - 12), end], content.period_ids[i] == selected_period_id)
	for i in _portraits.size():
		if current_view == ViewState.PERSON_FOCUS and i != selected_person_index: continue
		var period_index: int = content.period_ids.find(content.people[i].period_id)
		var start := _periods[period_index].position + Vector2(_periods[period_index].size.x * 0.5, 52)
		var end := _portraits[i].global_position - _network.global_position + Vector2(_portraits[i].size.x * 0.5, 0)
		# Clamp the rail endpoint when the selected portrait is temporarily offscreen during a swipe.
		end.x = clampf(end.x, 4, _network.size.x - 4)
		var active: bool = selected_person_index == i or (current_view == ViewState.OVERVIEW and selected_period_id == content.people[i].period_id)
		if current_view == ViewState.OVERVIEW:
			_add_connection([start, Vector2(start.x, end.y - 12), Vector2(end.x, end.y - 12), end], active)
		else:
			_add_connection([start, Vector2(start.x, start.y + 10), Vector2(6, start.y + 10), Vector2(6, end.y - 12), Vector2(end.x, end.y - 12), end], active)
	_connections.queue_redraw()

func _add_connection(points: PackedVector2Array, active: bool) -> void:
	_connections.paths.append(points)
	_connections.highlighted.append(active)

func _reveal_portrait(index: int) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or current_view == ViewState.OVERVIEW: return
	var card := _portraits[index]
	if card.position.x < _rail.scroll_horizontal: _rail.scroll_horizontal = int(card.position.x)
	elif card.position.x + card.size.x > _rail.scroll_horizontal + _rail.size.x:
		_rail.scroll_horizontal = ceili(card.position.x + card.size.x - _rail.size.x)
	_update_connections()

func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible: return
	_cancel_transition()
	_end_gesture()
	_source_title.text = "Sources"
	_source_text.text = content.source_credit
	var order: Array[int] = []
	if selected_person_index >= 0: order.append(selected_person_index)
	for i in content.people.size():
		if i != selected_person_index: order.append(i)
	for i in order:
		var entry = content.people[i]
		_source_text.text += "\n\n" + entry.display_name + "\nPORTRAIT\n" + entry.portrait_source_name + "\n" + entry.portrait_source_reference + "\n\nCASA REAL CONTEXT IMAGE\n" + entry.context_source
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()

func toggle_narration() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible: return
	if _audio.stream_paused: _audio.stream_paused = false
	elif _audio.playing: _audio.stream_paused = true
	else:
		_audio.play()
		narration_started.emit()
	_update_speaker()

func _update_speaker() -> void:
	if Engine.is_editor_hint():
		return
	_speaker.text = "LISTEN"
	if _audio.playing: _speaker.text = "PAUSE"
	if _audio.stream_paused: _speaker.text = "RESUME"
	_speaker.set_pressed_no_signal(_audio.playing and not _audio.stream_paused)
	_speaker.accessibility_name = _speaker.text.capitalize() + " narration"

func stop_narration() -> void:
	if Engine.is_editor_hint():
		return
	_audio.stream_paused = false
	super.stop_narration()

func _buttons() -> Array[Button]:
	var result: Array[Button] = [_sources_button, _speaker, _close, _source_close, _context, _view_all]
	result.append_array(_periods)
	result.append_array(_portraits)
	return result

func _sync_focus() -> void:
	if Engine.is_editor_hint():
		return
	var previous := get_viewport().gui_get_focus_owner()
	var all: Array[Control] = [_reading, _source_scroll]
	all.append_array(_buttons())
	if current_view == ViewState.PERSON_FOCUS:
		all = [_context]
		all.append_array(_portraits)
		all.append_array([_view_all, _reading, _source_scroll])
		all.append_array(_periods)
		all.append_array([_sources_button, _speaker, _close, _source_close])
	var active: Array[Control] = []
	for control in all:
		control.focus_mode = Control.FOCUS_NONE
		var modal_control := control == _source_scroll or control == _source_close
		if control.is_visible_in_tree() and modal_control == _sources.visible: active.append(control)
	for i in active.size():
		active[i].focus_mode = Control.FOCUS_ALL
		active[i].focus_next = active[i].get_path_to(active[(i + 1) % active.size()])
		active[i].focus_previous = active[i].get_path_to(active[posmod(i - 1, active.size())])
	if previous in active: previous.grab_focus()

func _portrait_key(event: InputEvent, index: int) -> void:
	if Engine.is_editor_hint():
		return
	if _sources.visible or not event is InputEventKey or not event.pressed: return
	if event.keycode in [KEY_LEFT, KEY_RIGHT]:
		_portraits[index].accept_event()
		var next := clampi(index + (1 if event.keycode == KEY_RIGHT else -1), 0, 4)
		_portraits[next].grab_focus()
		_reveal_portrait(next)

func _button_key(event: InputEvent, button: Button) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_SPACE]:
		button.accept_event()
		if not event.echo: button.pressed.emit()

func _reading_key(event: InputEvent, scroller: ScrollContainer) -> void:
	if Engine.is_editor_hint():
		return
	if not event is InputEventKey or not event.pressed: return
	var direction := 0
	if event.keycode in [KEY_DOWN, KEY_PAGEDOWN]: direction = 1
	if event.keycode in [KEY_UP, KEY_PAGEUP]: direction = -1
	if direction:
		scroller.accept_event()
		scroller.scroll_vertical += direction * (120 if event.keycode in [KEY_PAGEUP, KEY_PAGEDOWN] else 36)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not _open: return
	# Native touch is handled below; suppress its synthetic mouse duplicate (device -1).
	if event is InputEventMouse and event.device == -1:
		get_viewport().set_input_as_handled()
		return
	# Touch uses the same button signals as mouse/keyboard. Drags never activate a portrait.
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_index >= 0: return
			_touch_index = event.index
			_begin_gesture(event.position)
		elif event.index == _touch_index:
			get_viewport().set_input_as_handled()
			_finish_gesture(event.position)
			return
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		get_viewport().set_input_as_handled()
		_move_gesture(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not _sources.visible and _rail.get_global_rect().has_point(event.position):
			get_viewport().set_input_as_handled()
			_begin_gesture(event.position)
		elif not event.pressed and _gesture_scroll == _rail:
			get_viewport().set_input_as_handled()
			_finish_gesture(event.position)
	elif event is InputEventMouseMotion and _gesture_scroll == _rail and _touch_index < 0:
		get_viewport().set_input_as_handled()
		_move_gesture(event.position)

func _begin_gesture(at: Vector2) -> void:
	if Engine.is_editor_hint():
		return
	_gesture_origin = at
	_gesture_last = at
	_dragging = false
	_gesture_target = null
	_gesture_scroll = null
	for button in _buttons():
		if button.is_visible_in_tree() and button.get_global_rect().has_point(at):
			if _sources.visible and button != _source_close: continue
			_gesture_target = button
	for scroll in [_rail, _reading, _source_scroll]:
		if scroll.is_visible_in_tree() and scroll.get_global_rect().has_point(at):
			if _sources.visible and scroll != _source_scroll: continue
			_gesture_scroll = scroll

func _move_gesture(at: Vector2) -> void:
	if Engine.is_editor_hint():
		return
	if at.distance_to(_gesture_origin) > 12: _dragging = true
	if _dragging and _gesture_scroll != null:
		var delta := at - _gesture_last
		if _gesture_scroll == _rail: _rail.scroll_horizontal -= int(delta.x)
		else: _gesture_scroll.scroll_vertical -= int(delta.y)
	_gesture_last = at

func _finish_gesture(at: Vector2) -> void:
	if Engine.is_editor_hint():
		return
	var target := _gesture_target
	var activate := not _dragging and target != null and target.get_global_rect().has_point(at)
	_end_gesture()
	if activate:
		target.grab_focus()
		(target as Button).pressed.emit()

func _end_gesture() -> void:
	if Engine.is_editor_hint():
		return
	_gesture_target = null
	_gesture_scroll = null
	_dragging = false
	_touch_index = -1

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or not event.is_action_pressed(&"go_back"): return
	get_viewport().set_input_as_handled()
	if event.is_echo(): return
	if _sources.visible: close_sources()
	elif current_view == ViewState.PERSON_FOCUS: view_all_connections()
	else: close_interaction()

func _cancel_transition() -> void:
	if Engine.is_editor_hint():
		return
	if _transition != null and _transition.is_valid(): _transition.kill()
	_transition = null
	_focus_view.modulate.a = 1.0
	_image.modulate.a = 1.0
	_old_image.modulate.a = 0.0
	_old_image.texture = null
	_old_image.hide()

func close_interaction() -> void:
	if Engine.is_editor_hint():
		return
	if not _open: return
	reset_hotspot()
	super.close_interaction()
	close_requested.emit()

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_transition()
	super._exit_tree()

func close_sources() -> void:
	if not Engine.is_editor_hint():
		super.close_sources()

func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready() or content == null:
		return
	_presentation_root = EditorPresentation.begin(self)
	_build_presentation()
	current_view = ViewState.OVERVIEW
	visual_mode = VisualMode.PORTRAIT
	selected_person_index = -1
	selected_period_id = &""
	_render()
	EditorPresentation.finish(self, _presentation_root)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
