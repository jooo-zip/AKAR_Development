@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/pangasinan_provincial_capitol/ppc_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview
## Direct-access chronology with truthful, independently fitted historical images.

const HistoryCanvas = preload("res://scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01_canvas.gd")
const PERIODS := [&"damage_1945", &"reconstruction_1946_1949", &"recognition_2003", &"refurbishment_2008", &"protection_2018"]
const MEDIA_PERIODS := [&"damage_1945", &"recognition_2003", &"protection_2018"]

var selected_period: StringName = &"overview"
var comparison_amount: float = 0.5
var media_view_open: bool = false
var media_id: StringName = &"none"
var media_origin_period: StringName = &"none"
var _canvas: HistoryCanvas
var _workspace: Control
var _visual: VBoxContainer
var _comparison_labels: HBoxContainer
var _left_label: Label
var _right_label: Label
var _caption: Label
var _hint: Label
var _subtitle: Label
var _pending: Label
var _actions: VBoxContainer
var _overview: Button
var _enlarge: Button
var _rail: ScrollContainer
var _dates: HBoxContainer
var _period_buttons: Array[Button] = []
var _media: PanelContainer
var _media_close: Button
var _media_zoom: Button
var _media_scroll: ScrollContainer
var _media_image: TextureRect
var _media_heading: Label
var _media_caption: Label
var _media_credit: Label
var _media_text_scroll: ScrollContainer
var _media_scale: float = 1.0
var _transition: Tween
var _media_tween: Tween
var _scroll_touch_index: int = -1
var _touch_scroll: ScrollContainer
var _scroll_start: Vector2
var _scroll_origin: Vector2i
var _scroll_dragging: bool = false


func entry(id: StringName) -> ConferenceRoomConceptEntry:
	for record: Resource in content.get("concepts"):
		if record.get_meta(&"id", &"") == id:
			return record
	return null


func _ready() -> void:
	if Engine.is_editor_hint():
		_refresh_editor_preview.call_deferred()
		return
	_presentation_root = self
	super._ready()
	_build_presentation()
	resized.connect(_resize_layout)
	visibility_changed.connect(func() -> void:
		if _open and not is_visible_in_tree():
			close_interaction()
	)
	_resize_layout()
	_open_standalone.call_deferred()


func _build_presentation() -> void:
	_canvas = HistoryCanvas.new()
	_workspace = Control.new()
	_visual = VBoxContainer.new()
	_comparison_labels = HBoxContainer.new()
	_left_label = Label.new()
	_right_label = Label.new()
	_caption = Label.new()
	_hint = Label.new()
	_subtitle = Label.new()
	_pending = Label.new()
	_actions = VBoxContainer.new()
	_overview = Button.new()
	_enlarge = Button.new()
	_rail = ScrollContainer.new()
	_dates = HBoxContainer.new()
	_media = PanelContainer.new()
	_media_close = Button.new()
	_media_zoom = Button.new()
	_media_scroll = ScrollContainer.new()
	_media_image = TextureRect.new()
	_media_heading = Label.new()
	_media_caption = Label.new()
	_media_credit = Label.new()
	_media_text_scroll = ScrollContainer.new()
	_period_buttons.clear()
	var layout := _presentation_root.get_node("Main/Margin/Layout")
	var header := _presentation_root.get_node("Main/Margin/Layout/Header")
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(titles)
	header.move_child(titles, 0)
	_title.reparent(titles)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titles.add_child(_subtitle)
	titles.add_child(_pending)
	_pending.text = "Narration pending."
	_pending.add_theme_font_size_override("font_size", 14)
	_sources_button.reparent(header)
	_speaker.reparent(header)
	_speaker.icon = preload("res://assets/ui/icons/speaker.svg")
	_sources_button.text = "SOURCES"
	_close.text = "CLOSE"
	header.move_child(_close, header.get_child_count() - 1)
	header.add_theme_constant_override("separation", 6)
	for button in [_sources_button, _speaker, _close, _source_close]:
		_prepare_button(button)
		button.size_flags_vertical = SIZE_SHRINK_BEGIN
	_presentation_root.find_child("Columns", true, false).hide()
	_presentation_root.get_node("Main/Margin/Layout/Controls").hide()
	_presentation_root.get_node("Main/Margin/Layout/Sections").hide()
	_workspace.name = "HistoricalWorkspace"
	_workspace.size_flags_vertical = SIZE_EXPAND_FILL
	layout.add_child(_workspace)
	_workspace.add_child(_visual)
	_visual.add_child(_comparison_labels)
	for label in [_left_label, _right_label]:
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_color_override("font_color", Color("e8d5b4"))
		_comparison_labels.add_child(label)
	_right_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_visual.add_child(_canvas)
	_canvas.name = "HistoricalCanvas"
	_canvas.size_flags_vertical = SIZE_EXPAND_FILL
	if not Engine.is_editor_hint():
		_canvas.comparison_changed.connect(set_comparison_amount)
	_visual.add_child(_hint)
	_hint.text = "DRAG TO COMPARE"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_visual.add_child(_caption)
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.add_theme_color_override("font_color", Color("d6c5ab"))
	_information.reparent(_workspace)
	_heading.reparent(_body.get_parent())
	_body.get_parent().move_child(_heading, 0)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_information.get_node("Meta").hide()
	_body.get_parent().add_theme_constant_override("separation", 8)
	_workspace.add_child(_actions)
	_overview.text = "OVERVIEW"
	_enlarge.text = "VIEW IMAGE"
	for button in [_overview, _enlarge]:
		_prepare_button(button)
		_actions.add_child(button)
	if not Engine.is_editor_hint():
		_overview.pressed.connect(select_history_period.bind(&"overview"))
	if not Engine.is_editor_hint():
		_enlarge.pressed.connect(func() -> void: open_historical_media(selected_period))
	var line := ColorRect.new()
	line.custom_minimum_size.y = 1
	line.color = Color("8e6c51")
	line.mouse_filter = MOUSE_FILTER_IGNORE
	layout.add_child(line)
	_rail.name = "DateRail"
	_rail.custom_minimum_size.y = 84
	_rail.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rail.follow_focus = true
	_rail.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	layout.add_child(_rail)
	_dates.size_flags_horizontal = SIZE_EXPAND_FILL
	_dates.add_theme_constant_override("separation", 8)
	_rail.add_child(_dates)
	for id in PERIODS:
		var button := Button.new()
		button.name = String(id)
		button.text = entry(id).get_meta(&"label")
		button.toggle_mode = true
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		_prepare_button(button)
		button.custom_minimum_size = Vector2(188, 64)
		# Let native touch gestures reach the surrounding ScrollContainer.
		button.mouse_filter = MOUSE_FILTER_PASS
		if not Engine.is_editor_hint():
			button.pressed.connect(select_history_period.bind(id))
		_dates.add_child(button)
		_period_buttons.append(button)
	_build_media()
	for scroller in [_rail, _scroll, _source_scroll, _media_scroll, _media_text_scroll]:
		if not Engine.is_editor_hint():
			scroller.gui_input.connect(_scroll_input.bind(scroller))
	if not Engine.is_editor_hint():
		_scroll.get_v_scroll_bar().changed.connect(_sync_focus.call_deferred)
	if not Engine.is_editor_hint():
		_media_text_scroll.get_v_scroll_bar().changed.connect(_sync_focus.call_deferred)
	_workspace.resized.connect(_layout_workspace)
	_visual.minimum_size_changed.connect(_layout_workspace.call_deferred)
	_visual.resized.connect(_layout_workspace.call_deferred)
	_media_scroll.resized.connect(_layout_media_image)


func _prepare_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(56, 48)
	button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	if not Engine.is_editor_hint():
		button.gui_input.connect(_button_input.bind(button))


func _button_input(event: InputEvent, button: Button) -> void:
	if Engine.is_editor_hint():
		return
	# Native BaseButton handles touch; explicit keyboard parity includes Enter.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
		button.accept_event()
		button.pressed.emit()


func _scroll_input(event: InputEvent, scroller: ScrollContainer) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or ((scroller == _rail or scroller == _scroll) and _blocked()):
		return
	# Native touch drag also works on desktop/web hosts without touchscreen flags.
	if event is InputEventScreenTouch:
		if event.pressed and _scroll_touch_index == -1:
			_scroll_touch_index = event.index
			_touch_scroll = scroller
			_scroll_start = event.position
			_scroll_origin = Vector2i(scroller.scroll_horizontal, scroller.scroll_vertical)
		elif event.index == _scroll_touch_index and _touch_scroll == scroller:
			_end_scroll_drag()
		scroller.accept_event()
	elif event is InputEventScreenDrag and event.index == _scroll_touch_index and _touch_scroll == scroller:
		var displacement: Vector2 = event.position - _scroll_start
		if scroller.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED:
			displacement.x = 0
		if scroller.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED:
			displacement.y = 0
		if displacement.length() > 8 or _scroll_dragging:
			if not _scroll_dragging:
				_scroll_dragging = true
				# Cancel any pending button press before scrolling it away.
				scroller.propagate_notification(NOTIFICATION_SCROLL_BEGIN)
			scroller.scroll_horizontal = _scroll_origin.x - int(displacement.x)
			scroller.scroll_vertical = _scroll_origin.y - int(displacement.y)
		scroller.accept_event()


func _end_scroll_drag() -> void:
	if Engine.is_editor_hint():
		return
	if _scroll_dragging and is_instance_valid(_touch_scroll):
		_touch_scroll.propagate_notification(NOTIFICATION_SCROLL_END)
	_scroll_dragging = false
	_scroll_touch_index = -1
	_touch_scroll = null


func _open_standalone() -> void:
	if Engine.is_editor_hint():
		return
	if get_tree().current_scene == self:
		open_hotspot()


func open_hotspot() -> bool:
	if Engine.is_editor_hint():
		return false
	return open_interaction()


func open_interaction() -> bool:
	if Engine.is_editor_hint():
		return false
	if not is_node_ready() or content == null:
		return false
	if _open:
		return true
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_title.text = content.title
	_subtitle.text = content.prompt
	_audio.stream = content.narration_stream
	_canvas.damage_image = entry(&"damage_1945").get_meta(&"image")
	_left_label.text = content.get_meta(&"comparison_left")
	_right_label.text = content.get_meta(&"comparison_right")
	_open = true
	show()
	reset_hotspot()
	opened.emit()
	return true


func _blocked() -> bool:
	return not _open or _sources.visible or media_view_open


func select_history_period(period_id: StringName) -> void:
	if Engine.is_editor_hint():
		return
	if _blocked() or (period_id != &"overview" and not period_id in PERIODS):
		return
	if period_id == selected_period:
		return
	_cancel_transition()
	_canvas.previous_image = _canvas.image
	_canvas.previous_comparing = _canvas.comparing
	_canvas.previous_amount = comparison_amount
	_canvas.end_drag()
	selected_period = period_id
	_end_scroll_drag()
	_render()
	_scroll.scroll_vertical = 0
	_canvas.transition_alpha = 0.0
	_information.modulate.a = 0.65
	_transition = create_tween().set_parallel(true)
	_transition.tween_property(_canvas, "transition_alpha", 1.0, 0.22)
	_transition.tween_property(_information, "modulate:a", 1.0, 0.2)
	_transition.chain().tween_callback(_finish_transition)
	_sync_focus()


func set_comparison_amount(value: float) -> void:
	if Engine.is_editor_hint():
		return
	if _blocked() or selected_period != &"refurbishment_2008":
		return
	# Direct manipulation ends any period crossfade immediately.
	_cancel_transition()
	comparison_amount = clampf(value, 0, 1)
	_canvas.amount = comparison_amount
	_canvas.queue_redraw()


func _render() -> void:
	var record := entry(selected_period)
	_heading.text = record.heading
	_body.text = record.body
	_takeaway.text = record.get_meta(&"note")
	_takeaway.visible = not _takeaway.text.is_empty()
	_canvas.image = record.get_meta(&"image")
	_canvas.comparing = selected_period == &"refurbishment_2008"
	_canvas.amount = comparison_amount
	_canvas.mouse_default_cursor_shape = CURSOR_HSIZE if _canvas.comparing else CURSOR_ARROW
	_canvas.accessibility_name = "Compare the two historical photographs; Left and Right adjust the divider" if _canvas.comparing else str(record.get_meta(&"caption"))
	_comparison_labels.visible = _canvas.comparing
	_hint.visible = _canvas.comparing
	_caption.text = "" if _canvas.comparing else str(record.get_meta(&"caption"))
	_caption.visible = not _canvas.comparing
	_overview.visible = selected_period != &"overview"
	_enlarge.visible = selected_period in MEDIA_PERIODS
	_enlarge.text = "VIEW DOCUMENT" if selected_period == &"protection_2018" else ("VIEW SOURCE" if selected_period == &"recognition_2003" else "VIEW IMAGE")
	_actions.visible = _overview.visible or _enlarge.visible
	for i in PERIODS.size():
		_period_buttons[i].set_pressed_no_signal(selected_period == PERIODS[i])
	_canvas.queue_redraw()
	_layout_workspace()


func _finish_transition() -> void:
	if Engine.is_editor_hint():
		return
	_transition = null
	_canvas.previous_image = null
	_canvas.transition_alpha = 1.0
	_information.modulate = Color.WHITE


func _cancel_transition() -> void:
	if Engine.is_editor_hint():
		return
	_kill(_transition)
	_finish_transition()


func _build_media() -> void:
	_media.name = "HistoricalSource"
	_media.add_theme_stylebox_override("panel", _presentation_root.get_node("Main").get_theme_stylebox("panel"))
	_presentation_root.add_child(_media)
	_media.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_media.add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	var title := Label.new()
	title.text = "HISTORICAL SOURCE"
	title.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(title)
	_media_zoom.text = "ENLARGE"
	_media_close.text = "CLOSE"
	for button in [_media_zoom, _media_close]:
		_prepare_button(button)
		header.add_child(button)
	if not Engine.is_editor_hint():
		_media_close.pressed.connect(close_historical_media)
	if not Engine.is_editor_hint():
		_media_zoom.pressed.connect(_toggle_media_zoom)
	_media_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	box.add_child(_media_scroll)
	_media_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_media_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_media_image.texture_filter = TEXTURE_FILTER_LINEAR
	_media_image.size_flags_horizontal = SIZE_EXPAND_FILL
	_media_image.size_flags_vertical = SIZE_EXPAND_FILL
	_media_image.mouse_filter = MOUSE_FILTER_PASS
	_media_scroll.add_child(_media_image)
	_media_text_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(_media_text_scroll)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = SIZE_EXPAND_FILL
	_media_text_scroll.add_child(text)
	for label in [_media_heading, _media_caption, _media_credit]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.add_child(label)
	_media_credit.add_theme_color_override("font_color", Color("d6c5ab"))
	_media.hide()


func open_historical_media(id: StringName) -> void:
	if Engine.is_editor_hint():
		return
	if _blocked() or id != selected_period or not id in MEDIA_PERIODS:
		return
	_canvas.end_drag()
	_end_scroll_drag()
	media_view_open = true
	media_id = id
	media_origin_period = selected_period
	var record := entry(id)
	_media_image.texture = record.get_meta(&"image")
	_media_image.accessibility_name = record.get_meta(&"caption")
	_media_heading.text = record.heading
	_media_caption.text = record.get_meta(&"caption")
	_media_credit.text = record.get_meta(&"credit")
	_media_scale = 1.0
	_media_zoom.text = "ENLARGE"
	_media_scroll.scroll_horizontal = 0
	_media_scroll.scroll_vertical = 0
	_media_text_scroll.scroll_vertical = 0
	_media.show()
	_layout_media_image()
	_kill(_media_tween)
	_media.modulate.a = 0
	_media_tween = create_tween()
	_media_tween.tween_property(_media, "modulate:a", 1.0, 0.2)
	_sync_focus()
	_media_close.grab_focus()


func _toggle_media_zoom() -> void:
	if Engine.is_editor_hint():
		return
	if not media_view_open:
		return
	_end_scroll_drag()
	_media_scale = 2.0 if _media_scale == 1.0 else 1.0
	_media_zoom.text = "FIT" if _media_scale > 1.0 else "ENLARGE"
	_media_scroll.scroll_horizontal = 0
	_media_scroll.scroll_vertical = 0
	_layout_media_image()


func _layout_media_image() -> void:
	if _media_image.texture == null:
		return
	# Enlarge preserves the complete source; visitors can scroll both axes.
	var available := (_media_scroll.size - Vector2(16, 16)).max(Vector2.ONE)
	var image_size := _media_image.texture.get_size()
	var factor := minf(available.x / image_size.x, available.y / image_size.y)
	if _media_scale > 1:
		factor = maxf(factor * _media_scale, minf(1.0, available.x / image_size.x))
	_media_image.custom_minimum_size = image_size * factor
	_media_image.size = _media_image.custom_minimum_size
	_sync_focus.call_deferred()


func close_historical_media() -> void:
	if Engine.is_editor_hint():
		return
	if not media_view_open:
		return
	_kill(_media_tween)
	_media_tween = create_tween()
	_media_tween.tween_property(_media, "modulate:a", 0.0, 0.2)
	_media_tween.tween_callback(_finish_media_close)


func _finish_media_close() -> void:
	if Engine.is_editor_hint():
		return
	_media_tween = null
	_clear_media()
	_sync_focus()
	if _open and _enlarge.is_visible_in_tree():
		_enlarge.grab_focus()


func _clear_media() -> void:
	if Engine.is_editor_hint():
		return
	_end_scroll_drag()
	media_view_open = false
	media_id = &"none"
	media_origin_period = &"none"
	_media.hide()
	_media.modulate = Color.WHITE
	_media_image.texture = null
	_media_scale = 1
	_media_scroll.scroll_horizontal = 0
	_media_scroll.scroll_vertical = 0
	_media_text_scroll.scroll_vertical = 0


func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if _blocked():
		return
	_canvas.end_drag()
	_end_scroll_drag()
	_source_title.text = "SOURCES"
	_source_text.text = content.source_credit
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()


func toggle_narration() -> void:
	if Engine.is_editor_hint():
		return
	if not _blocked():
		super.toggle_narration()


func close_sources() -> void:
	if Engine.is_editor_hint():
		return
	if _sources.visible:
		_end_scroll_drag()
	super.close_sources()


func _update_speaker() -> void:
	if Engine.is_editor_hint():
		return
	super._update_speaker()
	_speaker.text = "RESUME" if _audio.stream_paused else ("PAUSE" if _audio.playing else "LISTEN")
	_speaker.show()
	_speaker.disabled = _audio.stream == null
	_pending.visible = _speaker.disabled


func _all_controls() -> Array[Control]:
	var result: Array[Control] = [_canvas, _overview, _enlarge, _scroll, _sources_button, _speaker, _close, _source_close, _source_scroll, _media_close, _media_zoom, _media_scroll, _media_text_scroll]
	result.append_array(_period_buttons)
	return result


func focus_order() -> Array[Control]:
	if _sources.visible:
		return [_source_close, _source_scroll]
	if media_view_open:
		var modal: Array[Control] = [_media_close, _media_zoom, _media_scroll]
		if _media_text_scroll.get_v_scroll_bar().max_value > _media_text_scroll.size.y:
			modal.append(_media_text_scroll)
		return modal
	var main: Array[Control] = []
	main.append_array(_period_buttons)
	if _canvas.comparing:
		main.append(_canvas)
	if _enlarge.visible:
		main.append(_enlarge)
	if _overview.visible:
		main.append(_overview)
	main.append_array([_sources_button, _speaker, _close])
	if _scroll.get_v_scroll_bar().max_value > _scroll.size.y:
		main.append(_scroll)
	return main


func _sync_focus() -> void:
	if Engine.is_editor_hint():
		return
	var previous := get_viewport().gui_get_focus_owner()
	for control in _all_controls():
		control.focus_mode = FOCUS_NONE
	var active: Array[Control] = []
	for control in focus_order():
		if control.is_visible_in_tree() and not (control is BaseButton and control.disabled):
			control.focus_mode = FOCUS_ALL
			active.append(control)
	_canvas.enabled = not _blocked()
	for i in active.size():
		active[i].focus_next = active[i].get_path_to(active[(i + 1) % active.size()])
		active[i].focus_previous = active[i].get_path_to(active[posmod(i - 1, active.size())])
	if previous in active:
		previous.grab_focus()
	elif not active.is_empty():
		active[0].grab_focus()


func _resize_layout() -> void:
	if not is_instance_valid(_presentation_root):
		return
	if Engine.is_editor_hint():
		EditorPresentation.resize(self, _presentation_root)
	if not is_node_ready():
		return
	var compact := size.x < 1000 or size.y < 570
	for side in ["left", "top", "right", "bottom"]:
		_presentation_root.get_node("Main/Margin").add_theme_constant_override("margin_" + side, 8 if compact else 14)
	_presentation_root.get_node("Main/Margin/Layout").add_theme_constant_override("separation", 6 if compact else 10)
	_title.add_theme_font_size_override("font_size", 18 if compact else 24)
	_subtitle.add_theme_font_size_override("font_size", 14)
	_heading.add_theme_font_size_override("font_size", 19 if compact else 23)
	_body.add_theme_font_size_override("font_size", 17 if compact else 20)
	_takeaway.add_theme_font_size_override("font_size", 16 if compact else 18)
	for label in [_left_label, _right_label, _hint, _caption]:
		label.add_theme_font_size_override("font_size", 13 if compact else 16)
	for control in _all_controls():
		if control is Button:
			control.add_theme_font_size_override("font_size", 14 if compact else 16)
	_source_text.add_theme_font_size_override("font_size", 18)
	_media_heading.add_theme_font_size_override("font_size", 19 if compact else 22)
	_media_caption.add_theme_font_size_override("font_size", 16)
	_media_credit.add_theme_font_size_override("font_size", 14)
	_media_text_scroll.custom_minimum_size.y = 100 if compact else 120
	_layout_workspace()
	_layout_media_image()
	_sync_focus.call_deferred()


func _layout_workspace() -> void:
	if not is_node_ready():
		return
	var space := _workspace.size
	var narrow := size.x < 900
	if narrow:
		var drawer := 106.0
		_visual.position = Vector2.ZERO
		_visual.size = Vector2(space.x, maxf(1, space.y - drawer - 6))
		var actions_width := 142.0 if _actions.visible else 0.0
		_information.position = Vector2(0, _visual.size.y + 6)
		_information.size = Vector2(space.x - actions_width - (8 if actions_width else 0), drawer)
		_actions.position = Vector2(space.x - actions_width, _information.position.y)
		_actions.size = Vector2(actions_width, drawer)
	else:
		var media_width := space.x * 0.67
		_visual.position = Vector2.ZERO
		_visual.size = Vector2(media_width, space.y)
		_information.position = Vector2(media_width + 14, 0)
		_information.size = Vector2(maxf(1, space.x - media_width - 14), maxf(1, space.y - (108 if _actions.visible else 0)))
		_actions.position = Vector2(_information.position.x, space.y - 102)
		_actions.size = Vector2(_information.size.x, 102)


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or not event.is_action_pressed(&"go_back"):
		return
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
	if event.is_echo():
		return
	if _sources.visible:
		close_sources()
	elif media_view_open:
		close_historical_media()
	elif selected_period != &"overview":
		select_history_period(&"overview")
	else:
		close_interaction()


func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_transition()
	_cancel_fade()
	_kill(_media_tween)
	_media_tween = null
	_clear_media()
	_sources.hide()
	_source_scroll.scroll_vertical = 0
	_scroll.scroll_vertical = 0
	selected_period = &"overview"
	comparison_amount = 0.5
	_canvas.end_drag()
	stop_narration()
	_end_scroll_drag()
	_render()
	_sync_focus()
	if _open:
		_period_buttons[0].grab_focus()
	_rail.scroll_horizontal = 0
	_reset_rail.call_deferred()


func _reset_rail() -> void:
	if Engine.is_editor_hint():
		return
	if selected_period == &"overview":
		_rail.scroll_horizontal = 0


func close_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	close_interaction()


func close_interaction() -> void:
	if Engine.is_editor_hint():
		return
	if not _open:
		return
	reset_hotspot()
	super.close_interaction()


func _kill(tween: Tween) -> void:
	if Engine.is_editor_hint():
		return
	if tween != null and tween.is_valid():
		tween.kill()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_kill(_transition)
	_kill(_media_tween)
	super._exit_tree()


func stop_narration() -> void:
	if not Engine.is_editor_hint():
		super.stop_narration()


func select_concept(index: int) -> void:
	if not Engine.is_editor_hint():
		super.select_concept(index)


func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready() or content == null:
		return
	_presentation_root = EditorPresentation.begin(self)
	_build_presentation()
	_title.text = content.get("title")
	_subtitle.text = content.get("prompt")
	selected_period = &"overview"
	comparison_amount = 0.5
	_render()
	EditorPresentation.finish(self, _presentation_root)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
