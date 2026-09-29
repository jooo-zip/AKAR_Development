extends ConferenceRoomInteraction
## Always-available synthesis with optional, local interpretive reflection.
const MeaningCanvas = preload("res://scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01_canvas.gd")
const THEMES := [&"origins", &"architecture", &"resilience", &"public_service", &"heritage"]
const CHOICES := [&"history", &"architecture", &"public_role", &"preservation"]

var selected_theme: StringName = &"overview"
var reflection_view_open: bool = false
var reflection_choice: StringName = &""
var reflection_origin_theme: StringName = &"overview"
var _workspace := Control.new()
var _visual := VBoxContainer.new()
var _canvas := MeaningCanvas.new()
var _caption := Label.new()
var _cue := Label.new()
var _subtitle := Label.new()
var _pending := Label.new()
var _rail := ScrollContainer.new()
var _themes := HBoxContainer.new()
var _theme_buttons: Array[Button] = []
var _reflect := Button.new()
var _reflection := Control.new()
var _reflection_background := MeaningCanvas.new()
var _reflection_margin := MarginContainer.new()
var _reflection_layout := VBoxContainer.new()
var _reflection_heading := Label.new()
var _question := Label.new()
var _choice_grid := GridContainer.new()
var _choice_buttons: Array[Button] = []
var _response_scroll := ScrollContainer.new()
var _response_copy := VBoxContainer.new()
var _response := Label.new()
var _closing_synthesis := Label.new()
var _back := Button.new()
var _transition: Tween
var _reflection_tween: Tween
var _response_tween: Tween
var _reflection_closing: bool = false
var _scroll_touch_index: int = -1
var _touch_scroll: ScrollContainer
var _scroll_start: Vector2
var _scroll_origin: Vector2i
var _scroll_dragging: bool = false


func entry(id: StringName) -> ConferenceRoomConceptEntry:
	for record in content.concepts:
		if record.get_meta(&"id", &"") == id:
			return record
	return null


func _ready() -> void:
	super._ready()
	var header := $Main/Margin/Layout/Header
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(titles)
	header.move_child(titles, 0)
	_title.reparent(titles)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titles.add_child(_subtitle)
	titles.add_child(_pending)
	_pending.text = "Narration pending."
	_sources_button.reparent(header)
	_speaker.reparent(header)
	_speaker.icon = null
	_sources_button.text = "SOURCES"
	_close.text = "CLOSE"
	header.move_child(_close, header.get_child_count() - 1)
	for button in [_sources_button, _speaker, _close, _source_close]:
		_prepare_button(button)
		button.size_flags_vertical = SIZE_SHRINK_BEGIN
	%Columns.hide()
	$Main/Margin/Layout/Controls.hide()
	$Main/Margin/Layout/Sections.hide()
	_workspace.size_flags_vertical = SIZE_EXPAND_FILL
	$Main/Margin/Layout.add_child(_workspace)
	_workspace.add_child(_visual)
	_visual.add_theme_constant_override("separation", 6)
	_visual.add_child(_canvas)
	_canvas.size_flags_vertical = SIZE_EXPAND_FILL
	_visual.add_child(_caption)
	_visual.add_child(_cue)
	_information.reparent(_workspace)
	_information.get_node("Meta").hide()
	_heading.reparent(_body.get_parent())
	_body.get_parent().move_child(_heading, 0)
	_body.get_parent().add_theme_constant_override("separation", 12)
	for label in [_heading, _body, _takeaway, _caption, _cue]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.mouse_filter = MOUSE_FILTER_IGNORE
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.add_theme_color_override("font_color", Color("c9c4b1"))
	_cue.add_theme_color_override("font_color", Color("dfcf9e"))
	_takeaway.add_theme_color_override("font_color", Color("dfcf9e"))
	_rail.custom_minimum_size.y = 64
	_rail.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rail.follow_focus = true
	$Main/Margin/Layout.add_child(_rail)
	_themes.size_flags_horizontal = SIZE_EXPAND_FILL
	_themes.add_theme_constant_override("separation", 8)
	_rail.add_child(_themes)
	for id in THEMES:
		var button := Button.new()
		button.text = entry(id).get_meta(&"label")
		button.toggle_mode = true
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		_prepare_button(button)
		button.custom_minimum_size.x = 168
		button.mouse_filter = MOUSE_FILTER_PASS
		button.pressed.connect(select_meaning_theme.bind(id))
		_themes.add_child(button)
		_theme_buttons.append(button)
	_reflect.text = "YOUR REFLECTION"
	_prepare_button(_reflect)
	_reflect.custom_minimum_size.x = 250
	_reflect.size_flags_horizontal = SIZE_SHRINK_CENTER
	_reflect.pressed.connect(open_reflection)
	$Main/Margin/Layout.add_child(_reflect)
	_build_reflection()
	for scroller in [_rail, _scroll, _source_scroll, _response_scroll]:
		scroller.gui_input.connect(_scroll_input.bind(scroller))
		scroller.get_v_scroll_bar().changed.connect(_sync_focus.call_deferred)
		scroller.add_theme_stylebox_override("focus", _close.get_theme_stylebox("focus"))
	_workspace.resized.connect(_layout_workspace)
	_visual.minimum_size_changed.connect(_layout_workspace.call_deferred)
	_visual.resized.connect(_layout_workspace.call_deferred)
	resized.connect(_resize_layout)
	visibility_changed.connect(func() -> void:
		if _open and not is_visible_in_tree():
			close_interaction()
	)
	_resize_layout()
	_open_standalone.call_deferred()


func _build_reflection() -> void:
	_reflection.name = "Reflection"
	_workspace.add_child(_reflection)
	_reflection.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_reflection.add_child(_reflection_background)
	_reflection_background.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.035, 0.06, 0.048, 0.92)
	shade.mouse_filter = MOUSE_FILTER_IGNORE
	_reflection.add_child(shade)
	shade.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_reflection.add_child(_reflection_margin)
	_reflection_margin.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_reflection_margin.add_child(_reflection_layout)
	_reflection_layout.add_theme_constant_override("separation", 10)
	_reflection_layout.add_child(_reflection_heading)
	_reflection_layout.add_child(_question)
	_reflection_heading.text = entry(&"reflection").heading
	_question.text = entry(&"reflection").body
	_reflection_layout.add_child(_choice_grid)
	_choice_grid.columns = 2
	_choice_grid.add_theme_constant_override("h_separation", 10)
	_choice_grid.add_theme_constant_override("v_separation", 8)
	for id in CHOICES:
		var button := Button.new()
		button.text = entry(StringName("reflection_" + id)).heading
		button.toggle_mode = true
		_prepare_button(button)
		button.custom_minimum_size.y = 52
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.pressed.connect(select_reflection.bind(id))
		_choice_grid.add_child(button)
		_choice_buttons.append(button)
	_response_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	_response_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_reflection_layout.add_child(_response_scroll)
	_response_copy.size_flags_horizontal = SIZE_EXPAND_FILL
	_response_copy.add_theme_constant_override("separation", 16)
	_response_scroll.add_child(_response_copy)
	_response_copy.add_child(_response)
	_response_copy.add_child(_closing_synthesis)
	_closing_synthesis.text = content.learning_takeaway
	_closing_synthesis.add_theme_color_override("font_color", Color("dfcf9e"))
	for label in [_reflection_heading, _question, _response, _closing_synthesis]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = MOUSE_FILTER_IGNORE
	_back.text = "BACK TO SUMMARY"
	_prepare_button(_back)
	_back.custom_minimum_size.x = 250
	_back.size_flags_horizontal = SIZE_SHRINK_CENTER
	_back.pressed.connect(close_reflection)
	_reflection_layout.add_child(_back)
	_reflection.hide()


func _open_standalone() -> void:
	if get_tree().current_scene == self:
		open_hotspot()


func open_hotspot() -> bool:
	return open_interaction()


func open_interaction() -> bool:
	if not is_node_ready() or content == null:
		return false
	if _open:
		return true
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_title.text = content.title
	_subtitle.text = content.prompt
	_audio.stream = content.narration_stream
	_open = true
	show()
	reset_hotspot()
	opened.emit()
	return true


func _blocked() -> bool:
	return not _open or _sources.visible


func select_meaning_theme(id: StringName) -> void:
	if _blocked() or reflection_view_open or (id != &"overview" and id not in THEMES):
		return
	_cancel_theme_transition()
	_end_scroll_drag()
	var previous: Texture2D = _canvas.primary
	var previous_second: Texture2D = _canvas.secondary
	selected_theme = id
	_render_summary()
	_scroll.scroll_vertical = 0
	_canvas.previous_primary = previous
	_canvas.previous_secondary = previous_second
	_canvas.blend = 0
	_information.modulate.a = 0.6
	_transition = create_tween().set_parallel(true)
	_transition.tween_property(_canvas, "blend", 1.0, 0.2)
	_transition.tween_property(_information, "modulate:a", 1.0, 0.18)
	_transition.finished.connect(func() -> void:
		_transition = null
		_canvas.clear_transition()
	)
	_sync_focus()
	if id == &"overview":
		_rail.scroll_horizontal = 0


func _render_summary() -> void:
	var record := entry(selected_theme)
	_heading.text = record.heading
	_body.text = record.body
	_takeaway.text = record.get_meta(&"takeaway")
	_takeaway.show()
	_canvas.configure(record)
	_caption.text = record.get_meta(&"caption")
	_cue.text = record.get_meta(&"cue", "")
	if size.x < 900:
		_cue.text = _cue.text.replace("\n", " · ")
	_cue.visible = not _cue.text.is_empty()
	for i in THEMES.size():
		_theme_buttons[i].set_pressed_no_signal(THEMES[i] == selected_theme)
	_layout_workspace()


func open_reflection() -> void:
	if _blocked() or reflection_view_open:
		return
	_cancel_theme_transition()
	_end_scroll_drag()
	reflection_origin_theme = selected_theme
	reflection_view_open = true
	_reflection_closing = false
	_reflection_background.configure(entry(selected_theme))
	_visual.hide()
	_information.hide()
	_rail.hide()
	_reflect.hide()
	_render_reflection()
	_response_scroll.scroll_vertical = 0
	_reflection.show()
	_reflection.modulate.a = 0
	_kill(_reflection_tween)
	_reflection_tween = create_tween()
	_reflection_tween.tween_property(_reflection, "modulate:a", 1.0, 0.22)
	_sync_focus()
	_choice_buttons[0].grab_focus()


func select_reflection(id: StringName) -> void:
	if _blocked() or not reflection_view_open or _reflection_closing or id not in CHOICES:
		return
	_kill(_response_tween)
	reflection_choice = id
	_render_reflection()
	_response_copy.modulate.a = 0.6
	_response_tween = create_tween()
	_response_tween.tween_property(_response_copy, "modulate:a", 1.0, 0.17)
	_response_scroll.scroll_vertical = 0
	_sync_focus.call_deferred()


func _render_reflection() -> void:
	_response.visible = reflection_choice != &""
	_closing_synthesis.visible = _response.visible
	_response.text = entry(StringName("reflection_" + reflection_choice)).body if _response.visible else ""
	for i in CHOICES.size():
		_choice_buttons[i].set_pressed_no_signal(CHOICES[i] == reflection_choice)


func close_reflection() -> void:
	if _blocked() or not reflection_view_open:
		return
	_end_scroll_drag()
	_reflection_closing = true
	_kill(_reflection_tween)
	_reflection_tween = create_tween()
	_reflection_tween.tween_property(_reflection, "modulate:a", 0.0, 0.22)
	_reflection_tween.tween_callback(_finish_reflection_close)


func _finish_reflection_close() -> void:
	_reflection_tween = null
	_kill(_response_tween)
	_response_tween = null
	reflection_view_open = false
	_reflection_closing = false
	selected_theme = reflection_origin_theme
	_reflection.hide()
	_reflection.modulate = Color.WHITE
	_response_copy.modulate = Color.WHITE
	_visual.show()
	_information.show()
	_rail.show()
	_reflect.show()
	_render_summary()
	_sync_focus()
	if _open:
		_reflect.grab_focus()


func open_sources() -> void:
	if _blocked():
		return
	_cancel_theme_transition()
	_end_scroll_drag()
	# New Sources input supersedes an unfinished reflection close, preserving it.
	_kill(_reflection_tween)
	_reflection_tween = null
	_reflection_closing = false
	_reflection.modulate = Color.WHITE
	_source_title.text = "SOURCES"
	_source_text.text = content.source_credit
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()


func close_sources() -> void:
	_end_scroll_drag()
	super.close_sources()


func toggle_narration() -> void:
	if not _blocked():
		super.toggle_narration()


func _update_speaker() -> void:
	super._update_speaker()
	_speaker.text = "STOP" if _audio.playing else "LISTEN"
	_speaker.disabled = _audio.stream == null
	_pending.visible = _speaker.disabled


func _all_controls() -> Array[Control]:
	var controls: Array[Control] = [_reflect, _back, _sources_button, _speaker, _close, _scroll, _source_close, _source_scroll, _response_scroll]
	controls.append_array(_theme_buttons)
	controls.append_array(_choice_buttons)
	return controls


func focus_order() -> Array[Control]:
	if _sources.visible:
		return [_source_close, _source_scroll]
	var controls: Array[Control] = []
	if reflection_view_open:
		controls.append_array(_choice_buttons)
		controls.append(_back)
	else:
		controls.append_array(_theme_buttons)
		controls.append(_reflect)
	controls.append_array([_sources_button, _speaker, _close])
	var reading := _response_scroll if reflection_view_open else _scroll
	if reading.get_v_scroll_bar().max_value > reading.size.y:
		controls.append(reading)
	return controls


func _sync_focus() -> void:
	if not is_node_ready() or not _open:
		return
	var previous := get_viewport().gui_get_focus_owner()
	for control in _all_controls():
		control.focus_mode = FOCUS_NONE
	var active: Array[Control] = []
	for control in focus_order():
		if control.is_visible_in_tree() and not (control is BaseButton and control.disabled):
			control.focus_mode = FOCUS_ALL
			active.append(control)
	for i in active.size():
		active[i].focus_next = active[i].get_path_to(active[(i + 1) % active.size()])
		active[i].focus_previous = active[i].get_path_to(active[posmod(i - 1, active.size())])
	if previous in active:
		previous.grab_focus()
	elif not active.is_empty():
		active[0].grab_focus()


func _resize_layout() -> void:
	if not is_node_ready():
		return
	var compact := size.x < 1000
	for side in ["left", "top", "right", "bottom"]:
		$Main/Margin.add_theme_constant_override("margin_" + side, 8 if compact else 16)
		_reflection_margin.add_theme_constant_override("margin_" + side, 8 if compact else 24)
	$Main/Margin/Layout.add_theme_constant_override("separation", 6 if compact else 10)
	_title.add_theme_font_size_override("font_size", 18 if size.x < 900 else (20 if compact else 25))
	_subtitle.add_theme_font_size_override("font_size", 14)
	_pending.add_theme_font_size_override("font_size", 14)
	_heading.add_theme_font_size_override("font_size", 20 if compact else 25)
	_reflection_heading.add_theme_font_size_override("font_size", 22 if compact else 28)
	for label in [_body, _takeaway, _question, _response, _closing_synthesis, _source_text]:
		label.add_theme_font_size_override("font_size", 18 if compact else 20)
	for label in [_caption, _cue]:
		label.add_theme_font_size_override("font_size", 14 if compact else 16)
	for control in _all_controls():
		if control is Button:
			control.add_theme_font_size_override("font_size", 14 if compact else 16)
	for button in _choice_buttons:
		button.add_theme_font_size_override("font_size", 16)
	_reflection_layout.add_theme_constant_override("separation", 6 if compact else 10)
	_response_copy.add_theme_constant_override("separation", 10 if compact else 16)
	if content != null:
		var cue_text: String = entry(selected_theme).get_meta(&"cue", "")
		_cue.text = cue_text.replace("\n", " · ") if size.x < 900 else cue_text
	_layout_workspace()
	_sync_focus.call_deferred()


func _layout_workspace() -> void:
	if not is_node_ready():
		return
	var area := _workspace.size
	_visual.position = Vector2.ZERO
	if size.x < 900:
		_visual.size = Vector2(area.x, maxf(1, area.y - 100))
		_information.position = Vector2(0, _visual.size.y + 6)
		_information.size = Vector2(area.x, 94)
	else:
		_visual.size = Vector2(area.x * 0.62, area.y)
		_information.position = Vector2(_visual.size.x + 20, 0)
		_information.size = Vector2(maxf(1, area.x - _visual.size.x - 20), area.y)


func _unhandled_input(event: InputEvent) -> void:
	if not _open or not event.is_action_pressed(&"go_back"):
		return
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
	if event.is_echo():
		return
	if _sources.visible:
		close_sources()
	elif reflection_view_open:
		close_reflection()
	elif selected_theme != &"overview":
		select_meaning_theme(&"overview")
	else:
		close_interaction()


func _cancel_theme_transition() -> void:
	_kill(_transition)
	_transition = null
	_canvas.clear_transition()
	_information.modulate = Color.WHITE


func reset_hotspot() -> void:
	_cancel_theme_transition()
	_cancel_fade()
	_kill(_reflection_tween)
	_kill(_response_tween)
	_reflection_tween = null
	_response_tween = null
	_end_scroll_drag()
	selected_theme = &"overview"
	reflection_view_open = false
	reflection_choice = &""
	reflection_origin_theme = &"overview"
	_reflection_closing = false
	_reflection.hide()
	_reflection.modulate = Color.WHITE
	_response_copy.modulate = Color.WHITE
	_sources.hide()
	_visual.show()
	_information.show()
	_rail.show()
	_reflect.show()
	for scroller in [_scroll, _source_scroll, _response_scroll]:
		scroller.scroll_vertical = 0
	stop_narration()
	_render_summary()
	_render_reflection()
	_sync_focus()
	if _open:
		_theme_buttons[0].grab_focus()
	_rail.scroll_horizontal = 0


func close_hotspot() -> void:
	close_interaction()


func close_interaction() -> void:
	if not _open:
		return
	reset_hotspot()
	super.close_interaction()


func _kill(tween: Tween) -> void:
	if tween != null and tween.is_valid():
		tween.kill()


func _exit_tree() -> void:
	_kill(_transition)
	_kill(_reflection_tween)
	_kill(_response_tween)
	super._exit_tree()


func _prepare_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(56, 48)
	button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	button.gui_input.connect(_button_input.bind(button))


func _button_input(event: InputEvent, button: Button) -> void:
	# Native BaseButton handles touch; explicit keyboard parity includes Enter.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
		button.accept_event()
		button.pressed.emit()


func _scroll_input(event: InputEvent, scroller: ScrollContainer) -> void:
	if not _open or (scroller != _source_scroll and _sources.visible) or ((scroller == _rail or scroller == _scroll) and reflection_view_open):
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
	if _scroll_dragging and is_instance_valid(_touch_scroll):
		_touch_scroll.propagate_notification(NOTIFICATION_SCROLL_END)
	_scroll_dragging = false
	_scroll_touch_index = -1
	_touch_scroll = null
