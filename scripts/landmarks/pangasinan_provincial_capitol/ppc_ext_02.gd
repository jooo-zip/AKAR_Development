@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/pangasinan_provincial_capitol/ppc_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview
## Parallel architectural modes. Historical interpretation lives in the Resource.

const ArchitectureCanvas = preload("res://scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_02_canvas.gd")
const VIEWS := [&"balance", &"entrance", &"climate"]
const FEATURES := [&"steps", &"portico", &"ionic_columns", &"doors"]
const LAYERS := [&"airflow", &"shade", &"rain"]
const DETAILS := [&"facade_rhythm", &"entrance_composition", &"pediment_relief", &"back_entrance_passage", &"interior_corridor"]

var architecture_view: StringName = &"overview"
var balance_reveal: float = 0.0
var entrance_feature: StringName = &"none"
var climate_layer: StringName = &"airflow"
var detail_view_open: bool = false
var detail_id: StringName = &"none"
var detail_origin_view: StringName = &"none"
var _detail_return: Button
var _canvas: ArchitectureCanvas
var _subtitle: Label
var _hint: Label
var _pending: Label
var _full: Button
var _bottom: Control
var _features: HBoxContainer
var _layers: HBoxContainer
var _details: VBoxContainer
var _feature_buttons: Array[Button] = []
var _layer_buttons: Array[Button] = []
var _detail_buttons: Dictionary[StringName, Button] = {}
var _detail: PanelContainer
var _detail_photo: TextureRect
var _detail_close: Button
var _detail_scroll: ScrollContainer
var _detail_heading: Label
var _detail_body: Label
var _detail_caption: Label
var _transition: Tween
var _zoom_tween: Tween
var _highlight_tween: Tween
var _detail_tween: Tween


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
	_canvas = ArchitectureCanvas.new()
	_subtitle = Label.new()
	_hint = Label.new()
	_pending = Label.new()
	_full = Button.new()
	_bottom = Control.new()
	_features = HBoxContainer.new()
	_layers = HBoxContainer.new()
	_details = VBoxContainer.new()
	_detail = PanelContainer.new()
	_detail_photo = TextureRect.new()
	_detail_close = Button.new()
	_detail_scroll = ScrollContainer.new()
	_detail_heading = Label.new()
	_detail_body = Label.new()
	_detail_caption = Label.new()
	_feature_buttons.clear()
	_layer_buttons.clear()
	_detail_buttons.clear()
	var layout := _presentation_root.get_node("Main/Margin/Layout")
	var header := _presentation_root.get_node("Main/Margin/Layout/Header")
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(titles)
	header.move_child(titles, 0)
	_title.reparent(titles)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titles.add_child(_subtitle)
	_subtitle.add_theme_font_size_override("font_size", 14)
	_sources_button.reparent(header)
	_speaker.reparent(header)
	_speaker.icon = preload("res://assets/ui/icons/speaker.svg")
	_speaker.text = "LISTEN"
	_close.text = "CLOSE"
	_sources_button.text = "SOURCES"
	header.move_child(_close, header.get_child_count() - 1)
	header.add_theme_constant_override("separation", 6)
	for button in [_sources_button, _speaker, _close, _source_close]:
		_prepare_button(button)
		button.size_flags_vertical = SIZE_SHRINK_BEGIN
	_presentation_root.get_node("Main/Margin/Layout/Controls").hide()
	_presentation_root.find_child("Columns", true, false).hide()
	_canvas.name = "ArchitectureCanvas"
	_canvas.texture_filter = TEXTURE_FILTER_LINEAR
	_canvas.size_flags_vertical = SIZE_EXPAND_FILL
	layout.add_child(_canvas)
	layout.move_child(_canvas, 1)
	if not Engine.is_editor_hint():
		_canvas.reveal_changed.connect(_reveal_changed)
	_canvas.add_child(_hint)
	_hint.mouse_filter = MOUSE_FILTER_IGNORE
	_hint.position = Vector2(12, 6)
	_hint.add_theme_font_size_override("font_size", 14)
	_hint.add_theme_color_override("font_color", Color("f0dfc3"))
	_hint.add_theme_color_override("font_shadow_color", Color.BLACK)
	_hint.add_theme_constant_override("shadow_offset_x", 1)
	_hint.add_theme_constant_override("shadow_offset_y", 1)
	_full.text = "FULL FAÇADE"
	_prepare_button(_full)
	if not Engine.is_editor_hint():
		_full.pressed.connect(select_architecture_view.bind(&"overview"))
	_presentation_root.get_node("Main/Margin/Layout/Sections").add_child(_full)
	_presentation_root.get_node("Main/Margin/Layout/Sections").move_child(_full, 0)
	for i in VIEWS.size():
		_prepare_button(_concepts[i])
		_concepts[i].text = ["BALANCE", "MONUMENTAL ENTRANCE", "Ventilation & Protection"][i]
	layout.add_child(_bottom)
	_information.reparent(_bottom)
	_information.size_flags_vertical = SIZE_EXPAND_FILL
	_heading.reparent(_body.get_parent())
	_body.get_parent().move_child(_heading, 0)
	_information.get_node("Meta").hide()
	_body.get_parent().add_theme_constant_override("separation", 4)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bottom.add_child(_features)
	_bottom.add_child(_layers)
	_bottom.add_child(_details)
	var detail_label := Label.new()
	detail_label.text = "ARCHITECTURAL DETAILS"
	detail_label.add_theme_font_size_override("font_size", 14)
	_details.add_child(detail_label)
	for id in FEATURES:
		var button := _make_button(entry(id).get_meta(&"label"), _features)
		button.toggle_mode = true
		if not Engine.is_editor_hint():
			button.pressed.connect(select_entrance_feature.bind(id))
		_feature_buttons.append(button)
	for id in LAYERS:
		var button := _make_button(entry(id).get_meta(&"label"), _layers)
		button.toggle_mode = true
		if not Engine.is_editor_hint():
			button.pressed.connect(select_climate_layer.bind(id))
		_layer_buttons.append(button)
	for id in DETAILS:
		var button := _make_button(entry(id).get_meta(&"label"), _details)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if not Engine.is_editor_hint():
			button.pressed.connect(open_architectural_detail.bind(id))
		_detail_buttons[id] = button
	_pending.text = "Narration pending."
	_pending.add_theme_font_size_override("font_size", 14)
	titles.add_child(_pending)
	_build_detail()
	# Text wrapping can change the scrollable focus target after container layout.
	if not Engine.is_editor_hint():
		_scroll.get_v_scroll_bar().changed.connect(_sync_focus.call_deferred)
	if not Engine.is_editor_hint():
		_detail_scroll.get_v_scroll_bar().changed.connect(_sync_focus.call_deferred)
	_bottom.resized.connect(_layout_bottom)


func _prepare_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(48, 48)
	button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	if not Engine.is_editor_hint():
		button.gui_input.connect(_button_input.bind(button))


func _make_button(label: String, parent: Node) -> Button:
	var button := Button.new()
	button.text = label
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	_prepare_button(button)
	parent.add_child(button)
	return button


func _button_input(event: InputEvent, button: Button) -> void:
	if Engine.is_editor_hint():
		return
	# BaseButton already handles touch. Do not also emit on its emulated mouse event.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
		button.accept_event()
		button.pressed.emit()


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
	_canvas.texture = content.illustration
	_canvas.accessibility_name = content.illustration_alt_text
	_audio.stream = content.narration_stream
	_speaker.disabled = _audio.stream == null
	_pending.visible = _speaker.disabled
	_open = true
	show()
	reset_hotspot()
	opened.emit()
	return true


func _blocked() -> bool:
	return not _open or _sources.visible or detail_view_open


func select_concept(index: int) -> void:
	if Engine.is_editor_hint():
		return
	if index >= 0 and index < VIEWS.size():
		select_architecture_view(VIEWS[index])


func select_architecture_view(view_id: StringName) -> void:
	if Engine.is_editor_hint():
		return
	if _blocked() or (view_id != &"overview" and not view_id in VIEWS):
		return
	architecture_view = view_id
	_canvas.cancel_drag()
	_kill(_transition)
	_kill(_zoom_tween)
	_kill(_highlight_tween)
	_canvas.highlight_alpha = 1.0
	_render()
	_information.modulate.a = 0.65
	_transition = create_tween()
	_transition.tween_property(_information, "modulate:a", 1.0, 0.2)
	_zoom_tween = create_tween()
	_zoom_tween.tween_property(_canvas, "zoom", 1.32 if view_id == &"entrance" else 1.0, 0.3)
	_scroll.scroll_vertical = 0
	_sync_focus()


func select_entrance_feature(feature_id: StringName) -> void:
	if Engine.is_editor_hint():
		return
	if _blocked() or architecture_view != &"entrance" or not feature_id in FEATURES:
		return
	entrance_feature = feature_id
	_render()
	_fade_highlight(0.18)


func select_climate_layer(layer_id: StringName) -> void:
	if Engine.is_editor_hint():
		return
	if _blocked() or architecture_view != &"climate" or not layer_id in LAYERS:
		return
	climate_layer = layer_id
	_render()
	_fade_highlight(0.2)
	_sync_focus()


func _fade_highlight(seconds: float) -> void:
	if Engine.is_editor_hint():
		return
	_kill(_highlight_tween)
	_canvas.highlight_alpha = 0.3
	_highlight_tween = create_tween()
	_highlight_tween.tween_property(_canvas, "highlight_alpha", 1.0, seconds)
	_scroll.scroll_vertical = 0


func _reveal_changed(value: float) -> void:
	if Engine.is_editor_hint():
		return
	if not _blocked() and architecture_view == &"balance":
		balance_reveal = value


func relevant_details() -> Array[StringName]:
	if architecture_view == &"balance":
		return [&"facade_rhythm"]
	if architecture_view == &"entrance":
		return [&"entrance_composition", &"pediment_relief"]
	if architecture_view == &"climate":
		if climate_layer == &"airflow":
			return [&"interior_corridor"]
		if climate_layer == &"shade":
			return [&"back_entrance_passage"]
	return []


func _render() -> void:
	var record_id := architecture_view
	if architecture_view == &"entrance" and entrance_feature != &"none":
		record_id = entrance_feature
	elif architecture_view == &"climate":
		record_id = climate_layer
	var record := entry(record_id)
	_heading.text = record.heading
	_body.text = record.body
	_takeaway.text = content.learning_takeaway if architecture_view == &"climate" else str(record.get_meta(&"note", ""))
	_takeaway.visible = not _takeaway.text.is_empty()
	_hint.text = "DRAG TO REVEAL THE BALANCE" if architecture_view == &"balance" else ("INTERPRETIVE VISUAL GUIDE" if architecture_view == &"climate" else ("READ THE FAÇADE" if architecture_view == &"overview" else ""))
	_features.visible = architecture_view == &"entrance"
	_layers.visible = architecture_view == &"climate"
	_full.visible = architecture_view != &"overview"
	var available := relevant_details()
	_details.visible = not available.is_empty()
	for id in DETAILS:
		_detail_buttons[id].visible = id in available
	for i in VIEWS.size():
		_concepts[i].set_pressed_no_signal(architecture_view == VIEWS[i])
	for i in FEATURES.size():
		_feature_buttons[i].set_pressed_no_signal(entrance_feature == FEATURES[i])
	for i in LAYERS.size():
		_layer_buttons[i].set_pressed_no_signal(climate_layer == LAYERS[i])
	_canvas.mode = architecture_view
	_canvas.feature = entrance_feature
	_canvas.layer = climate_layer
	_canvas.reveal = balance_reveal
	_canvas.accessibility_name = "Reveal architectural balance; use Left and Right arrows" if architecture_view == &"balance" else content.illustration_alt_text
	_canvas.mouse_default_cursor_shape = CURSOR_HSIZE if architecture_view == &"balance" else CURSOR_ARROW
	_canvas.queue_redraw()
	_layout_bottom()


func _build_detail() -> void:
	_detail.name = "ArchitecturalDetail"
	_detail.add_theme_stylebox_override("panel", _presentation_root.get_node("Main").get_theme_stylebox("panel"))
	_presentation_root.add_child(_detail)
	_detail.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	_detail.add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	var title := Label.new()
	title.text = "ARCHITECTURAL DETAIL"
	title.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(title)
	_detail_close.text = "CLOSE DETAIL"
	_prepare_button(_detail_close)
	header.add_child(_detail_close)
	if not Engine.is_editor_hint():
		_detail_close.pressed.connect(close_architectural_detail)
	box.add_child(_detail_photo)
	_detail_photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_detail_photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_detail_photo.texture_filter = TEXTURE_FILTER_LINEAR
	_detail_photo.size_flags_vertical = SIZE_EXPAND_FILL
	_detail_photo.mouse_filter = MOUSE_FILTER_IGNORE
	box.add_child(_detail_scroll)
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var text := VBoxContainer.new()
	text.size_flags_horizontal = SIZE_EXPAND_FILL
	_detail_scroll.add_child(text)
	for label in [_detail_heading, _detail_body, _detail_caption]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.add_child(label)
	_detail_caption.add_theme_color_override("font_color", Color("d6c5ab"))
	_detail.hide()


func open_architectural_detail(id: StringName) -> void:
	if Engine.is_editor_hint():
		return
	if _blocked() or not id in relevant_details():
		return
	var record := entry(id)
	_detail_return = _detail_buttons[id]
	detail_origin_view = architecture_view
	detail_id = id
	detail_view_open = true
	_canvas.cancel_drag()
	_detail_photo.texture = record.get_meta(&"image")
	_detail_photo.accessibility_name = record.get_meta(&"note")
	_detail_heading.text = record.heading
	_detail_body.text = record.body
	_detail_caption.text = str(record.get_meta(&"note")) + "\n" + str(content.get_meta(&"photo_credit"))
	_detail_scroll.scroll_vertical = 0
	_detail.show()
	_detail.modulate.a = 0.0
	_kill(_detail_tween)
	_detail_tween = create_tween()
	_detail_tween.tween_property(_detail, "modulate:a", 1.0, 0.2)
	_sync_focus()
	_detail_close.grab_focus()


func close_architectural_detail() -> void:
	if Engine.is_editor_hint():
		return
	if not detail_view_open:
		return
	# Keep the modal authoritative until its closing fade ends.
	_kill(_detail_tween)
	_detail_tween = create_tween()
	_detail_tween.tween_property(_detail, "modulate:a", 0.0, 0.2)
	_detail_tween.tween_callback(_finish_detail_close)


func _finish_detail_close() -> void:
	if Engine.is_editor_hint():
		return
	_detail_tween = null
	_clear_detail()
	_sync_focus()
	if _detail_return != null and _detail_return.is_visible_in_tree():
		_detail_return.grab_focus()
	_detail_return = null


func _clear_detail() -> void:
	if Engine.is_editor_hint():
		return
	detail_view_open = false
	detail_id = &"none"
	detail_origin_view = &"none"
	_detail.hide()
	_detail.modulate = Color.WHITE
	_detail_photo.texture = null
	_detail_scroll.scroll_vertical = 0


func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if _blocked():
		return
	_canvas.cancel_drag()
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


func _update_speaker() -> void:
	if Engine.is_editor_hint():
		return
	super._update_speaker()
	_speaker.text = "RESUME" if _audio.stream_paused else ("PAUSE" if _audio.playing else "LISTEN")


func _all_controls() -> Array[Control]:
	var controls: Array[Control] = [_canvas, _full, _scroll, _sources_button, _speaker, _close, _source_close, _source_scroll, _detail_close, _detail_scroll]
	controls.append_array(_concepts)
	controls.append_array(_feature_buttons)
	controls.append_array(_layer_buttons)
	for button in _detail_buttons.values():
		controls.append(button)
	return controls


func focus_order() -> Array[Control]:
	if detail_view_open:
		return [_detail_close, _detail_scroll] if _detail_scroll.get_v_scroll_bar().max_value > _detail_scroll.size.y else [_detail_close]
	if _sources.visible:
		return [_source_close, _source_scroll]
	var order: Array[Control] = []
	if architecture_view == &"balance":
		order.append(_canvas)
	elif architecture_view == &"entrance":
		order.append_array(_feature_buttons)
	elif architecture_view == &"climate":
		order.append_array(_layer_buttons)
	for id in relevant_details():
		order.append(_detail_buttons[id])
	if architecture_view != &"overview":
		order.append(_full)
	for i in VIEWS.size():
		if architecture_view != VIEWS[i]:
			order.append(_concepts[i])
	order.append_array([_sources_button, _speaker, _close])
	# Local text remains keyboard-scrollable without preceding main controls.
	if _scroll.get_v_scroll_bar().max_value > _scroll.size.y:
		order.append(_scroll)
	return order


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
	var compact := size.y < 570 or size.x < 1000
	for side in ["left", "top", "right", "bottom"]:
		_presentation_root.get_node("Main/Margin").add_theme_constant_override("margin_" + side, 8 if compact else 14)
	_presentation_root.get_node("Main/Margin/Layout").add_theme_constant_override("separation", 6 if compact else 10)
	_title.add_theme_font_size_override("font_size", 19 if compact else 25)
	for control in _all_controls():
		if control is Button:
			control.add_theme_font_size_override("font_size", 14 if compact else 17)
	_heading.add_theme_font_size_override("font_size", 19 if compact else 22)
	_body.add_theme_font_size_override("font_size", 17 if compact else 19)
	_takeaway.add_theme_font_size_override("font_size", 16 if compact else 18)
	_source_text.add_theme_font_size_override("font_size", 18)
	_detail_heading.add_theme_font_size_override("font_size", 19 if compact else 23)
	_detail_body.add_theme_font_size_override("font_size", 17 if compact else 20)
	_detail_caption.add_theme_font_size_override("font_size", 14 if compact else 16)
	_bottom.custom_minimum_size.y = 132 if compact else 152
	_detail_scroll.custom_minimum_size.y = (size.y - 64) * 0.28
	_layout_bottom()
	_sync_focus.call_deferred()


func _layout_bottom() -> void:
	if not is_node_ready():
		return
	var gap := 12.0
	var detail_width := _bottom.size.x * 0.30 if _details.visible else 0.0
	var info_width := maxf(0.0, _bottom.size.x - detail_width - (gap if detail_width > 0 else 0.0))
	var controls_height := 52.0 if _features.visible or _layers.visible else 0.0
	for controls in [_features, _layers]:
		controls.position = Vector2.ZERO
		controls.size = Vector2(info_width, 48)
	_information.position = Vector2(0, controls_height)
	_information.size = Vector2(info_width, maxf(0, _bottom.size.y - controls_height))
	_details.position = Vector2(info_width + gap, 0)
	_details.size = Vector2(detail_width, _bottom.size.y)


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
	elif detail_view_open:
		close_architectural_detail()
	elif architecture_view != &"overview":
		select_architecture_view(&"overview")
	else:
		close_interaction()


func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	for tween in [_transition, _zoom_tween, _highlight_tween, _detail_tween]:
		_kill(tween)
	_transition = null
	_zoom_tween = null
	_highlight_tween = null
	_detail_tween = null
	_cancel_fade()
	_clear_detail()
	_detail_return = null
	_sources.hide()
	_source_scroll.scroll_vertical = 0
	_scroll.scroll_vertical = 0
	architecture_view = &"overview"
	balance_reveal = 0.0
	entrance_feature = &"none"
	climate_layer = &"airflow"
	_canvas.zoom = 1.0
	_canvas.highlight_alpha = 1.0
	_canvas.cancel_drag()
	_information.modulate = Color.WHITE
	stop_narration()
	_render()
	_sync_focus()
	if _open:
		_concepts[0].grab_focus()


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
	for tween in [_transition, _zoom_tween, _highlight_tween, _detail_tween]:
		_kill(tween)
	super._exit_tree()


func close_sources() -> void:
	if not Engine.is_editor_hint():
		super.close_sources()


func stop_narration() -> void:
	if not Engine.is_editor_hint():
		super.stop_narration()


func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready() or content == null:
		return
	_presentation_root = EditorPresentation.begin(self)
	_build_presentation()
	_title.text = content.get("title")
	_subtitle.text = content.get("prompt")
	architecture_view = &"overview"
	balance_reveal = 0.0
	entrance_feature = &"none"
	climate_layer = &"airflow"
	_canvas.texture = content.get("illustration")
	_render()
	EditorPresentation.finish(self, _presentation_root)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
