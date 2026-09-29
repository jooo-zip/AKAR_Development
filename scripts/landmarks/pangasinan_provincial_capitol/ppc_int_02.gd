extends ConferenceRoomInteraction
## Parallel civic exploration. All interpretation and media provenance live in the Resource.
const CivicCanvas = preload("res://scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02_canvas.gd")
const VIEWS := [&"overview", &"lobby", &"executive", &"legislative", &"comparison"]
const EXECUTIVE := [&"executive_role", &"coordination", &"public_service"]
const LEGISLATIVE := [&"ordinances", &"resolutions", &"provincial_policies"]
const MEDIA := {&"lobby": &"lobby", &"governor_office": &"executive", &"session_hall": &"legislative"}

var civic_view: StringName = &"overview"
var executive_topic: StringName = &"executive_role"
var legislative_topic: StringName = &"ordinances"
var space_view_open: bool = false
var space_media_id: StringName = &"none"
var space_origin_view: StringName = &"none"
var _canvas := CivicCanvas.new()
var _workspace := Control.new()
var _subtitle := Label.new()
var _context := Label.new()
var _topic_heading := Label.new()
var _topic_body := Label.new()
var _caption := Label.new()
var _rail := ScrollContainer.new()
var _controls := HBoxContainer.new()
var _view_buttons: Array[Button] = []
var _topic_buttons: Array[Button] = []
var _view_space := Button.new()
var _public_spaces := Button.new()
var _media := PanelContainer.new()
var _media_close := Button.new()
var _media_image := TextureRect.new()
var _media_caption := Label.new()
var _media_credit := Label.new()
var _media_text_scroll := ScrollContainer.new()
var _transition: Tween
var _media_tween: Tween
var _branch_tween: Tween
var _topic_tween: Tween
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
	_workspace.add_child(_canvas)
	_canvas.branch_selected.connect(_branch_selected)
	for button in _canvas.branches + _canvas.compare_actions:
		_prepare_button(button)
	_information.reparent(_workspace)
	_information.get_node("Meta").hide()
	_takeaway.hide()
	var text := _body.get_parent()
	_heading.reparent(text)
	text.move_child(_heading, 0)
	text.add_child(_context)
	text.move_child(_context, 0)
	for label in [_topic_heading, _topic_body, _caption]:
		text.add_child(label)
	for label in [_heading, _context, _topic_heading, _topic_body, _caption]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.mouse_filter = MOUSE_FILTER_IGNORE
	_context.add_theme_color_override("font_color", Color("dfcf9e"))
	_topic_heading.add_theme_color_override("font_color", Color("dfcf9e"))
	_caption.add_theme_color_override("font_color", Color("c9c4b1"))
	_rail.custom_minimum_size.y = 68
	_rail.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rail.follow_focus = true
	$Main/Margin/Layout.add_child(_rail)
	_controls.add_theme_constant_override("separation", 8)
	_controls.size_flags_horizontal = SIZE_EXPAND_FILL
	_rail.add_child(_controls)
	for i in 4:
		var button := Button.new()
		button.text = ["PUBLIC LOBBY", "EXECUTIVE FUNCTION", "LEGISLATIVE FUNCTION", "COMPARE FUNCTIONS"][i]
		button.pressed.connect(select_civic_view.bind(VIEWS[i + 1]))
		_add_control(button)
		_view_buttons.append(button)
	for i in 3:
		var button := Button.new()
		button.toggle_mode = true
		button.pressed.connect(_select_topic_index.bind(i))
		_add_control(button)
		_topic_buttons.append(button)
	_view_space.text = "VIEW SPACE"
	_view_space.pressed.connect(func() -> void: open_space_view(_current_media()))
	_public_spaces.text = "← PUBLIC SPACES"
	_public_spaces.pressed.connect(select_civic_view.bind(&"overview"))
	_add_control(_view_space)
	_add_control(_public_spaces)
	_build_media()
	for scroller in [_rail, _scroll, _source_scroll, _media_text_scroll]:
		scroller.gui_input.connect(_scroll_input.bind(scroller))
		scroller.get_v_scroll_bar().changed.connect(_sync_focus.call_deferred)
	_workspace.resized.connect(_layout_workspace)
	_information.minimum_size_changed.connect(_layout_workspace.call_deferred)
	resized.connect(_resize_layout)
	visibility_changed.connect(func() -> void:
		if _open and not is_visible_in_tree():
			close_interaction()
	)
	_resize_layout()
	_open_standalone.call_deferred()


func _add_control(button: Button) -> void:
	_prepare_button(button)
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.custom_minimum_size.x = 126
	button.mouse_filter = MOUSE_FILTER_PASS
	_controls.add_child(button)


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
	return not _open or _sources.visible or space_view_open


func select_civic_view(id: StringName) -> void:
	if _blocked() or id not in VIEWS:
		return
	_cancel_transitions()
	_end_scroll_drag()
	civic_view = id
	_render()
	_scroll.scroll_vertical = 0
	_sync_focus()
	_rail.scroll_horizontal = 0
	_canvas.modulate.a = 0.55
	_information.modulate.a = 0.65
	_transition = create_tween().set_parallel(true)
	var duration := 0.22 if id == &"comparison" else 0.2
	_transition.tween_property(_canvas, "modulate:a", 1.0, duration)
	_transition.tween_property(_information, "modulate:a", 1.0, duration)
	if _canvas.previous_photo.texture != null and _canvas.photo.texture != null:
		_canvas.photo.modulate.a = 0
		_transition.tween_property(_canvas.photo, "modulate:a", 1.0, 0.2)
		_transition.tween_property(_canvas.previous_photo, "modulate:a", 0.0, 0.2)
	_transition.finished.connect(func() -> void:
		_canvas.previous_photo.texture = null
		_transition = null
	)


func _branch_selected(id: StringName) -> void:
	if _blocked():
		return
	if civic_view != &"lobby":
		select_civic_view(id)
		return
	# A single cancellable branch highlight; any newer selection supersedes it.
	_kill(_branch_tween)
	_canvas.highlighted = id
	_canvas.highlight_strength = 1.0
	_branch_tween = create_tween()
	_branch_tween.tween_property(_canvas, "highlight_strength", 0.3, 0.18)
	_branch_tween.tween_callback(select_civic_view.bind(id))


func _select_topic_index(index: int) -> void:
	if civic_view == &"executive":
		select_executive_topic(EXECUTIVE[index])
	elif civic_view == &"legislative":
		select_legislative_topic(LEGISLATIVE[index])


func select_executive_topic(id: StringName) -> void:
	if _blocked() or civic_view != &"executive" or id not in EXECUTIVE:
		return
	executive_topic = id
	_animate_topic()


func select_legislative_topic(id: StringName) -> void:
	if _blocked() or civic_view != &"legislative" or id not in LEGISLATIVE:
		return
	legislative_topic = id
	_animate_topic()


func _animate_topic() -> void:
	_kill(_topic_tween)
	_render_topic()
	_topic_body.modulate.a = 0.5
	_topic_tween = create_tween()
	_topic_tween.tween_property(_topic_body, "modulate:a", 1.0, 0.17)
	_scroll.scroll_vertical = 0


func _render_topic() -> void:
	var active := civic_view in [&"executive", &"legislative"]
	_topic_heading.visible = active
	_topic_body.visible = active
	for i in 3:
		_topic_buttons[i].visible = active
		if active:
			var ids: Array = EXECUTIVE if civic_view == &"executive" else LEGISLATIVE
			var selected := executive_topic if civic_view == &"executive" else legislative_topic
			_topic_buttons[i].text = entry(ids[i]).get_meta(&"label")
			_topic_buttons[i].set_pressed_no_signal(selected == ids[i])
	if active:
		var topic := entry(executive_topic if civic_view == &"executive" else legislative_topic)
		_topic_heading.text = topic.heading
		_topic_body.text = topic.body


func _render() -> void:
	var record := entry(civic_view)
	_context.text = record.get_meta(&"context")
	_context.visible = civic_view != &"comparison"
	_heading.text = record.heading
	_body.text = record.body
	_body.visible = not record.body.is_empty()
	_caption.text = content.get_meta(&"instruction") if civic_view == &"overview" else record.get_meta(&"caption", "")
	_caption.visible = not _caption.text.is_empty()
	_canvas.configure(civic_view, record, entry(&"executive"), entry(&"legislative"), content.get_meta(&"schematic"))
	for button in _view_buttons:
		button.visible = civic_view == &"overview"
	_view_space.visible = civic_view in [&"lobby", &"executive", &"legislative"]
	_view_space.text = "VIEW LOBBY" if civic_view == &"lobby" else "VIEW SPACE"
	_public_spaces.visible = civic_view != &"overview"
	_render_topic()
	_layout_workspace()


func _current_media() -> StringName:
	for id in MEDIA:
		if MEDIA[id] == civic_view:
			return id
	return &"none"


func _build_media() -> void:
	_media.name = "DocumentaryView"
	_media.add_theme_stylebox_override("panel", $Main.get_theme_stylebox("panel"))
	add_child(_media)
	_media.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	_media.add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	var title := Label.new()
	title.text = "DOCUMENTARY VIEW"
	title.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(title)
	_media_close.text = "CLOSE"
	_prepare_button(_media_close)
	header.add_child(_media_close)
	_media_close.pressed.connect(close_space_view)
	_media_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_media_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_media_image.texture_filter = TEXTURE_FILTER_LINEAR
	_media_image.size_flags_vertical = SIZE_EXPAND_FILL
	box.add_child(_media_image)
	_media_text_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_media_text_scroll.custom_minimum_size.y = 80
	box.add_child(_media_text_scroll)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = SIZE_EXPAND_FILL
	_media_text_scroll.add_child(text)
	for label in [_media_caption, _media_credit]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.add_child(label)
	_media.hide()


func open_space_view(id: StringName) -> void:
	if _blocked() or not MEDIA.has(id) or MEDIA[id] != civic_view:
		return
	_cancel_transitions()
	_end_scroll_drag()
	space_view_open = true
	space_media_id = id
	space_origin_view = civic_view
	var record := entry(MEDIA[id])
	_media_image.texture = record.get_meta(&"image")
	_media_image.accessibility_name = record.get_meta(&"caption")
	_media_caption.text = record.get_meta(&"caption")
	_media_credit.text = record.get_meta(&"credit")
	_media_text_scroll.scroll_vertical = 0
	_media.show()
	_kill(_media_tween)
	_media.modulate.a = 0
	_media_tween = create_tween()
	_media_tween.tween_property(_media, "modulate:a", 1.0, 0.2)
	_sync_focus()
	_media_close.grab_focus()


func close_space_view() -> void:
	if not space_view_open:
		return
	_kill(_media_tween)
	_media_tween = create_tween()
	_media_tween.tween_property(_media, "modulate:a", 0.0, 0.2)
	_media_tween.tween_callback(_finish_media_close)


func _finish_media_close() -> void:
	_media_tween = null
	_clear_media()
	_sync_focus()
	if _open:
		_view_space.grab_focus()


func _clear_media() -> void:
	_end_scroll_drag()
	space_view_open = false
	space_media_id = &"none"
	space_origin_view = &"none"
	_media.hide()
	_media.modulate = Color.WHITE
	_media_image.texture = null
	_media_text_scroll.scroll_vertical = 0


func open_sources() -> void:
	if _blocked():
		return
	_cancel_transitions()
	_end_scroll_drag()
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


func _all_controls() -> Array[Control]:
	var result: Array[Control] = [_view_space, _public_spaces, _sources_button, _speaker, _close, _scroll, _source_close, _source_scroll, _media_close, _media_text_scroll]
	result.append_array(_view_buttons)
	result.append_array(_topic_buttons)
	result.append_array(_canvas.branches)
	result.append_array(_canvas.compare_actions)
	return result


func focus_order() -> Array[Control]:
	if _sources.visible:
		return [_source_close, _source_scroll]
	if space_view_open:
		var modal: Array[Control] = [_media_close]
		if _media_text_scroll.get_v_scroll_bar().max_value > _media_text_scroll.size.y:
			modal.append(_media_text_scroll)
		return modal
	var result: Array[Control] = []
	match civic_view:
		&"overview": result.append_array(_view_buttons)
		&"lobby": result.append_array(_canvas.branches)
		&"executive", &"legislative": result.append_array(_topic_buttons)
		&"comparison": result.append_array(_canvas.compare_actions)
	if _view_space.visible:
		result.append(_view_space)
	if _public_spaces.visible:
		result.append(_public_spaces)
	result.append_array([_sources_button, _speaker, _close])
	if _scroll.get_v_scroll_bar().max_value > _scroll.size.y:
		result.append(_scroll)
	return result


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
		$Main/Margin.add_theme_constant_override("margin_" + side, 8 if compact else 14)
	_title.add_theme_font_size_override("font_size", 19 if compact else 26)
	_subtitle.add_theme_font_size_override("font_size", 14)
	_heading.add_theme_font_size_override("font_size", 20 if compact else 25)
	for label in [_body, _topic_body, _topic_heading, _source_text]:
		label.add_theme_font_size_override("font_size", 18 if compact else 20)
	for label in [_context, _caption, _media_caption, _media_credit]:
		label.add_theme_font_size_override("font_size", 16)
	for control in _all_controls():
		if control is Button:
			control.add_theme_font_size_override("font_size", 14 if compact else 17)
	for label in _canvas.branch_labels:
		label.add_theme_font_size_override("font_size", 17 if compact else 20)
	for card in _canvas.comparison_cards:
		for child in card.get_children():
			if child is Label:
				child.add_theme_font_size_override("font_size", 16 if compact else 20)
	for label in _canvas.compare_summaries:
		label.add_theme_font_size_override("font_size", 16 if compact else 17)
		label.custom_minimum_size.y = 70 if compact else 80
	_layout_workspace()
	_sync_focus.call_deferred()


func _layout_workspace() -> void:
	if not is_node_ready():
		return
	var area := _workspace.size
	var comparison := civic_view == &"comparison"
	# On compact screens the selected interpretation is immediately visible;
	# the unchanged space introduction follows in the same local text scroller.
	var text := _body.get_parent()
	var compact_topic := size.x < 900 and civic_view in [&"executive", &"legislative"]
	var labels := [_topic_heading, _topic_body, _context, _heading, _body, _takeaway, _caption] if compact_topic else [_context, _heading, _body, _takeaway, _topic_heading, _topic_body, _caption]
	for i in labels.size():
		text.move_child(labels[i], i)
	if comparison:
		_information.position = Vector2.ZERO
		_information.size = Vector2(area.x, 36)
		_canvas.position = Vector2(0, 44)
		_canvas.size = Vector2(area.x, maxf(1, area.y - 44))
	elif size.x < 900:
		_canvas.position = Vector2.ZERO
		_canvas.size = Vector2(area.x, maxf(1, area.y - 140))
		_information.position = Vector2(0, _canvas.size.y + 8)
		_information.size = Vector2(area.x, 132)
	else:
		_canvas.position = Vector2.ZERO
		_canvas.size = Vector2(area.x * 0.64, area.y)
		_information.position = Vector2(_canvas.size.x + 18, 0)
		_information.size = Vector2(maxf(1, area.x - _canvas.size.x - 18), area.y)
	_canvas.arrange()


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
	elif space_view_open:
		close_space_view()
	elif civic_view != &"overview":
		select_civic_view(&"overview")
	else:
		close_interaction()


func _cancel_transitions() -> void:
	for tween in [_transition, _branch_tween, _topic_tween]:
		_kill(tween)
	_transition = null
	_branch_tween = null
	_topic_tween = null
	_canvas.highlighted = &"none"
	_canvas.highlight_strength = 0
	_canvas.modulate = Color.WHITE
	_canvas.photo.modulate = Color.WHITE
	_canvas.previous_photo.modulate = Color.WHITE
	_canvas.previous_photo.texture = null
	_information.modulate = Color.WHITE
	_topic_body.modulate = Color.WHITE


func reset_hotspot() -> void:
	_cancel_transitions()
	_cancel_fade()
	_kill(_media_tween)
	_media_tween = null
	_clear_media()
	_sources.hide()
	_source_scroll.scroll_vertical = 0
	_scroll.scroll_vertical = 0
	civic_view = &"overview"
	executive_topic = &"executive_role"
	legislative_topic = &"ordinances"
	stop_narration()
	_render()
	_canvas.previous_photo.texture = null
	_sync_focus()
	if _open:
		_view_buttons[0].grab_focus()
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
	_cancel_transitions()
	_kill(_media_tween)
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
	if _scroll_dragging and is_instance_valid(_touch_scroll):
		_touch_scroll.propagate_notification(NOTIFICATION_SCROLL_END)
	_scroll_dragging = false
	_scroll_touch_index = -1
	_touch_scroll = null
