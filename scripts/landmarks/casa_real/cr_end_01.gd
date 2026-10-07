@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/casa_real/cr_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview

## Optional summary and reflection; no dependency on earlier hotspot visits.
signal close_requested
signal summary_theme_changed(theme_id: StringName)
enum ViewState { SUMMARY, REFLECTION }
const SummaryContent = preload("res://scripts/landmarks/casa_real/cr_end_01_content.gd")
const THEME_IDS: Array[StringName] = [&"government", &"architecture", &"history", &"preservation", &"museum"]
var current_view: ViewState = ViewState.SUMMARY
var selected_theme: StringName = &"government"
var _transition: Tween
var _subtitle: Label
var _audio_status: Label
var _summary: VBoxContainer
var _mosaic: GridContainer
var _theme_cards: Array[Button] = []
var _columns: HBoxContainer
var _visual: Control
var _previous_image: TextureRect
var _caption: Label
var _detail_scroll: ScrollContainer
var _detail_copy: VBoxContainer
var _anchor_label: Label
var _why: Label
var _reflect: Button
var _reflection: Control
var _background: TextureRect
var _shade: ColorRect
var _reflection_margin: MarginContainer
var _reflection_layout: VBoxContainer
var _reflection_scroll: ScrollContainer
var _reflection_copy: VBoxContainer
var _eyebrow: Label
var _reflection_heading: Label
var _question: Label
var _prompt: Label
var _reflection_takeaway: Label
var _back: Button
var _touch_index: int = -1
var _touch_target: Button
var _touch_scroll: ScrollContainer
var _touch_origin := Vector2.ZERO
var _touch_last := Vector2.ZERO
var _touch_dragged: bool = false

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
	_subtitle = Label.new()
	_audio_status = Label.new()
	_summary = VBoxContainer.new()
	_mosaic = GridContainer.new()
	_columns = HBoxContainer.new()
	_visual = Control.new()
	_previous_image = TextureRect.new()
	_caption = Label.new()
	_detail_scroll = ScrollContainer.new()
	_detail_copy = VBoxContainer.new()
	_anchor_label = Label.new()
	_why = Label.new()
	_reflect = Button.new()
	_reflection = Control.new()
	_background = TextureRect.new()
	_shade = ColorRect.new()
	_reflection_margin = MarginContainer.new()
	_reflection_layout = VBoxContainer.new()
	_reflection_scroll = ScrollContainer.new()
	_reflection_copy = VBoxContainer.new()
	_eyebrow = Label.new()
	_reflection_heading = Label.new()
	_question = Label.new()
	_prompt = Label.new()
	_reflection_takeaway = Label.new()
	_back = Button.new()
	_theme_cards.clear()
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
	for old in [_presentation_root.get_node("Main/Margin/Layout/Controls"), _presentation_root.get_node("Main/Margin/Layout/Sections"), _presentation_root.get_node("Main/Margin/Layout/Columns")]: old.hide()
	layout.add_child(_subtitle)
	_subtitle.text = content.subtitle
	layout.add_child(_audio_status)
	_audio_status.text = "Narration pending."
	_audio_status.hide()
	layout.add_child(_summary)
	layout.add_child(_reflection)
	for page in [_summary, _reflection]: page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_summary.add_theme_constant_override("separation", 12)
	_summary.add_child(_mosaic)
	_mosaic.add_theme_constant_override("h_separation", 8)
	_mosaic.add_theme_constant_override("v_separation", 8)
	for entry in content.themes:
		var card := Button.new()
		card.toggle_mode = true
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size.y = 64
		card.accessibility_name = entry.card_label.replace("\n", " ")
		if not Engine.is_editor_hint():
			card.pressed.connect(select_theme.bind(entry.id))
		_mosaic.add_child(card)
		_theme_cards.append(card)
	_summary.add_child(_columns)
	_columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_columns.add_theme_constant_override("separation", 20)
	_columns.add_child(_visual)
	_columns.add_child(_detail_scroll)
	_visual.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_visual.size_flags_stretch_ratio = 0.42
	_detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_scroll.size_flags_stretch_ratio = 0.58
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_visual.add_child(_previous_image)
	_image.reparent(_visual)
	_visual.add_child(_caption)
	for picture in [_previous_image, _image]:
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.add_theme_color_override("font_color", Color("d6c5ab"))
	_detail_scroll.add_child(_detail_copy)
	_detail_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_copy.add_theme_constant_override("separation", 10)
	_detail_copy.add_child(_anchor_label)
	_heading.reparent(_detail_copy)
	_body.reparent(_detail_copy)
	_detail_copy.add_child(_why)
	_takeaway.reparent(_detail_copy)
	_why.text = content.interpretation_label
	for label in [_anchor_label, _why]: label.add_theme_color_override("font_color", Color("d37148"))
	_summary.add_child(_reflect)
	_reflect.text = content.reflect_label
	_reflect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if not Engine.is_editor_hint():
		_reflect.pressed.connect(open_reflection)
	_build_reflection()
	for label in [_subtitle, _audio_status, _caption, _anchor_label, _heading, _body, _why, _takeaway, _eyebrow, _reflection_heading, _question, _prompt, _reflection_takeaway]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for button in _buttons():
		if button not in _theme_cards: button.custom_minimum_size.y = 52
		if not Engine.is_editor_hint():
			button.gui_input.connect(_button_key.bind(button))
	for scroller in [_detail_scroll, _reflection_scroll, _source_scroll]:
		if not Engine.is_editor_hint():
			scroller.gui_input.connect(_reading_key.bind(scroller))
		scroller.add_theme_stylebox_override("focus", _close.get_theme_stylebox("focus"))
	_visual.resized.connect(_layout_image)

func _build_reflection() -> void:
	_reflection.add_child(_background)
	_background.texture = content.reflection_background
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_reflection.add_child(_shade)
	_shade.color = Color(Color("101d19"), 0.86)
	_reflection.add_child(_reflection_margin)
	for layer in [_background, _shade, _reflection_margin]: layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reflection_margin.add_child(_reflection_layout)
	_reflection_layout.add_theme_constant_override("separation", 12)
	_reflection_layout.add_child(_reflection_scroll)
	_reflection_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_reflection_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_reflection_scroll.add_child(_reflection_copy)
	_reflection_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reflection_copy.add_theme_constant_override("separation", 18)
	for label in [_eyebrow, _reflection_heading, _question, _prompt, _reflection_takeaway]:
		_reflection_copy.add_child(label)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_eyebrow.text = content.reflection_eyebrow
	_eyebrow.add_theme_color_override("font_color", Color("d37148"))
	_reflection_heading.text = content.reflection_heading
	_question.text = content.reflection_question
	_prompt.text = content.reflection_prompt
	_reflection_takeaway.text = content.learning_takeaway
	_reflection_takeaway.add_theme_color_override("font_color", Color("d6c5ab"))
	_reflection_layout.add_child(_back)
	_back.text = content.back_label
	_back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if not Engine.is_editor_hint():
		_back.pressed.connect(back_to_summary)

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
	if not is_node_ready() or not content is SummaryContent or content.themes.size() != 5: return false
	for i in 5:
		if content.themes[i] == null or content.themes[i].id != THEME_IDS[i] or content.themes[i].image == null: return false
	if content.reflection_background == null: return false
	if _open: return true
	_return_focus = null
	var previous := get_viewport().gui_get_focus_owner()
	if previous != null: _return_focus = weakref(previous)
	_audio.stream = null
	if ResourceLoader.exists(content.narration_path, "AudioStream"):
		var recording := load(content.narration_path) as AudioStream
		if recording != null and recording.get_length() > 0: _audio.stream = recording
	_speaker.disabled = _audio.stream == null
	_speaker.show()
	_audio_status.visible = _audio.stream == null
	_open = true
	show()
	reset_hotspot()
	_sources_button.grab_focus()
	opened.emit()
	return true

func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_transition()
	_clear_touch()
	stop_narration()
	_sources.hide()
	_source_scroll.scroll_vertical = 0
	_detail_scroll.scroll_vertical = 0
	_reflection_scroll.scroll_vertical = 0
	current_view = ViewState.SUMMARY
	selected_theme = &"government"
	_render()

func select_theme(theme_id: StringName) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or current_view != ViewState.SUMMARY or theme_id not in THEME_IDS: return
	_cancel_transition()
	var prior: Texture2D = _image.texture
	selected_theme = theme_id
	_detail_scroll.scroll_vertical = 0
	_render()
	_previous_image.texture = prior
	_previous_image.show()
	_previous_image.modulate.a = 1.0
	_image.modulate.a = 0.0
	_detail_copy.modulate.a = 0.65
	_transition = create_tween().set_parallel(true)
	_transition.tween_property(_previous_image, "modulate:a", 0.0, 0.2)
	_transition.tween_property(_image, "modulate:a", 1.0, 0.2)
	_transition.tween_property(_detail_copy, "modulate:a", 1.0, 0.2)
	_transition.chain().tween_callback(func() -> void:
		_previous_image.texture = null
		_previous_image.hide())
	summary_theme_changed.emit(theme_id)

func _render() -> void:
	var entry = content.themes[THEME_IDS.find(selected_theme)]
	for i in _theme_cards.size(): _theme_cards[i].set_pressed_no_signal(content.themes[i].id == selected_theme)
	_anchor_label.text = entry.anchor_label
	_anchor_label.visible = not entry.anchor_label.is_empty()
	_heading.text = entry.heading
	_body.text = entry.body
	_takeaway.text = entry.interpretation
	_takeaway.show()
	_image.texture = entry.image
	_image.accessibility_name = entry.caption
	_caption.text = entry.caption
	_summary.visible = current_view == ViewState.SUMMARY
	_reflection.visible = current_view == ViewState.REFLECTION
	_layout_image.call_deferred()
	_sync_focus()

func open_reflection() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or current_view != ViewState.SUMMARY: return
	_cancel_transition()
	_clear_touch()
	current_view = ViewState.REFLECTION
	_reflection_scroll.scroll_vertical = 0
	_render()
	_back.grab_focus()

func back_to_summary() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or current_view != ViewState.REFLECTION: return
	_cancel_transition()
	current_view = ViewState.SUMMARY
	_render()
	_reflect.grab_focus()

func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible: return
	_cancel_transition()
	_clear_touch()
	_source_title.text = "Sources"
	_source_text.text = content.source_credit
	for entry in content.themes: _source_text.text += "\n\n" + entry.historical_basis
	_source_text.text += "\n\nMEDIA CREDITS"
	for entry in content.themes:
		_source_text.text += "\n\n" + entry.card_label.replace("\n", " ") + "\n" + entry.caption + "\n" + entry.media_credit
	_source_text.text += "\n\nAUDIO\nCR-END-01 narration — AKAR Research Team"
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()

func toggle_narration() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or _audio.stream == null: return
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
	_speaker.tooltip_text = "Narration pending." if _audio.stream == null else _speaker.accessibility_name

func stop_narration() -> void:
	if Engine.is_editor_hint():
		return
	_audio.stream_paused = false
	super.stop_narration()

func _resize_layout() -> void:
	if Engine.is_editor_hint():
		EditorPresentation.resize(self, _presentation_root)
	if not is_node_ready(): return
	var compact := size.x < 1100
	var small := size.x < 900
	var inset := 0.02 if compact else 0.05
	_presentation_root.get_node("Main").set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_presentation_root.get_node("Main").anchor_left = inset
	_presentation_root.get_node("Main").anchor_top = inset
	_presentation_root.get_node("Main").anchor_right = 1.0 - inset
	_presentation_root.get_node("Main").anchor_bottom = 1.0 - inset
	for side in ["left", "right", "top", "bottom"]: _presentation_root.get_node("Main/Margin").add_theme_constant_override("margin_" + side, 8 if compact else 16)
	_presentation_root.get_node("Main/Margin/Layout").add_theme_constant_override("separation", 6 if compact else 10)
	_summary.add_theme_constant_override("separation", 8 if compact else 12)
	_mosaic.columns = 3 if small else 5
	for i in _theme_cards.size(): _theme_cards[i].text = content.themes[i].compact_label if small else content.themes[i].card_label
	for button in _buttons(): button.add_theme_font_size_override("font_size", 16 if compact else 18)
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_subtitle.add_theme_font_size_override("font_size", 16 if compact else 20)
	_audio_status.add_theme_font_size_override("font_size", 16)
	for label in [_body, _takeaway, _prompt, _reflection_takeaway]: label.add_theme_font_size_override("font_size", 18 if compact else 20)
	for label in [_heading, _reflection_heading]: label.add_theme_font_size_override("font_size", 22 if compact else 24)
	_question.add_theme_font_size_override("font_size", 22 if compact else 26)
	for label in [_anchor_label, _why, _eyebrow]: label.add_theme_font_size_override("font_size", 16 if compact else 18)
	_caption.add_theme_font_size_override("font_size", 16)
	_source_text.add_theme_font_size_override("font_size", 18 if compact else 22)
	_detail_copy.add_theme_constant_override("separation", 6 if compact else 10)
	_reflection_copy.add_theme_constant_override("separation", 12 if compact else 18)
	for side in ["left", "right", "top", "bottom"]: _reflection_margin.add_theme_constant_override("margin_" + side, 16 if compact else 32)
	_layout_image.call_deferred()

func _layout_image() -> void:
	if not is_node_ready(): return
	var caption_height := 52.0
	for picture in [_image, _previous_image]:
		picture.position = Vector2.ZERO
		picture.size = Vector2(_visual.size.x, maxf(0, _visual.size.y - caption_height))
	_caption.position = Vector2(0, _visual.size.y - caption_height)
	_caption.size = Vector2(_visual.size.x, caption_height)

func _buttons() -> Array[Button]:
	var result: Array[Button] = [_sources_button, _speaker, _close]
	result.append_array(_theme_cards)
	result.append_array([_reflect, _back, _source_close])
	return result

func _sync_focus() -> void:
	if Engine.is_editor_hint():
		return
	var previous := get_viewport().gui_get_focus_owner()
	var all: Array[Control] = [_detail_scroll, _reflection_scroll, _source_scroll]
	all.append_array(_buttons())
	for control in all: control.focus_mode = Control.FOCUS_NONE
	var active: Array[Control] = []
	if _sources.visible: active = [_source_scroll, _source_close]
	else:
		active = [_sources_button, _speaker, _close]
		if current_view == ViewState.SUMMARY:
			active.append_array(_theme_cards)
			active.append_array([_reflect, _detail_scroll])
		else: active.append_array([_back, _reflection_scroll])
	var enabled: Array[Control] = []
	for control in active:
		if control is BaseButton and control.disabled: continue
		if control.is_visible_in_tree(): enabled.append(control)
	for i in enabled.size():
		enabled[i].focus_mode = Control.FOCUS_ALL
		enabled[i].focus_next = enabled[i].get_path_to(enabled[(i + 1) % enabled.size()])
		enabled[i].focus_previous = enabled[i].get_path_to(enabled[posmod(i - 1, enabled.size())])
	if previous in enabled: previous.grab_focus()

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
	if event.keycode not in [KEY_UP, KEY_DOWN, KEY_PAGEUP, KEY_PAGEDOWN, KEY_HOME, KEY_END]: return
	scroller.accept_event()
	match event.keycode:
		KEY_HOME: scroller.scroll_vertical = 0
		KEY_END: scroller.scroll_vertical = int(scroller.get_v_scroll_bar().max_value)
		_: scroller.scroll_vertical += -80 if event.keycode in [KEY_UP, KEY_PAGEUP] else 80

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not _open: return
	# Native touch owns activation; suppress its synthetic mouse duplicate.
	if event is InputEventMouse and event.device == -1:
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_index >= 0: return
			_touch_index = event.index
			_touch_origin = event.position
			_touch_last = event.position
			_touch_dragged = false
			for button in _buttons():
				if _sources.visible and button != _source_close: continue
				if button.is_visible_in_tree() and not button.disabled and button.get_global_rect().has_point(event.position): _touch_target = button
			for scroller in [_detail_scroll, _reflection_scroll, _source_scroll]:
				if _sources.visible and scroller != _source_scroll: continue
				if scroller.is_visible_in_tree() and scroller.get_global_rect().has_point(event.position): _touch_scroll = scroller
		elif event.index == _touch_index:
			var target := _touch_target
			var activate: bool = not event.canceled and not _touch_dragged and target != null and target.get_global_rect().has_point(event.position)
			get_viewport().set_input_as_handled()
			_clear_touch()
			if activate:
				target.grab_focus()
				target.pressed.emit()
			return
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		get_viewport().set_input_as_handled()
		if event.position.distance_to(_touch_origin) > 12: _touch_dragged = true
		if _touch_dragged and _touch_scroll != null: _touch_scroll.scroll_vertical -= int(event.position.y - _touch_last.y)
		_touch_last = event.position

func _clear_touch() -> void:
	if Engine.is_editor_hint():
		return
	_touch_index = -1
	_touch_target = null
	_touch_scroll = null
	_touch_dragged = false

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or not event.is_action_pressed(&"go_back"): return
	get_viewport().set_input_as_handled()
	if event.is_echo(): return
	if _sources.visible: close_sources()
	elif current_view == ViewState.REFLECTION: back_to_summary()
	else: close_interaction()

func _cancel_transition() -> void:
	if Engine.is_editor_hint():
		return
	if _transition != null and _transition.is_valid(): _transition.kill()
	_transition = null
	_previous_image.texture = null
	_previous_image.hide()
	_previous_image.modulate.a = 0.0
	_image.modulate.a = 1.0
	_detail_copy.modulate.a = 1.0

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
	current_view = ViewState.SUMMARY
	selected_theme = &"government"
	_audio_status.visible = not ResourceLoader.exists(content.narration_path, "AudioStream")
	_render()
	EditorPresentation.finish(self, _presentation_root)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
