@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/lingayen_church/lc_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview


const HeaderUtilities = preload("res://scripts/landmarks/lingayen_church/lc_header_utilities.gd")
var _header_utilities: RefCounted
## Free story selection with a local wartime comparison inside the AKAR shell.

signal hotspot_closed
signal story_state_changed(state: int)
signal wartime_view_changed(view: int)

enum StoryState { OVERVIEW, HISTORIC_BELLS, WARTIME_1945, HERITAGE_TODAY }
enum WartimeView { POSTWAR_DAMAGE, PRESENT_DAY }
enum BellObservation { NONE, DISPLAY, SURFACE_DETAILS }

# Visual inspection coordinates only; they do not identify or date a bell.
const BELL_CROP := Rect2(0.24, 0.52, 0.76, 0.42)
const BELL_MARKERS := [Vector2(0.78, 0.34), Vector2(0.25, 0.62)]
const BELL_REGIONS := [Rect2(), Rect2(0.08, 0.03, 0.90, 0.91), Rect2(0.12, 0.40, 0.20, 0.51)]

const BellsContent = preload("res://scripts/landmarks/lingayen_church/lc_ext_03_content.gd")
const StoryPoint = preload("res://scripts/landmarks/lingayen_church/lc_ext_03_story_point.gd")
const SECONDARY := Color("d6c5ab")

var _wartime_view: WartimeView = WartimeView.POSTWAR_DAMAGE
var _subtitle: Label
var _pending: Label
var _media: VBoxContainer
var _media_frame: Control
var _incoming: VBoxContainer
var _outgoing: VBoxContainer
var _outgoing_image: TextureRect
var _caption: Label
var _credit: Label
var _outgoing_caption: Label
var _outgoing_credit: Label
var _comparison: HBoxContainer
var _comparison_buttons: Array[Button] = []
var _story_row: HBoxContainer
var _prompt: Label
var _key_label: Label
var _support: VBoxContainer
var _support_image: TextureRect
var _support_caption: Label
var _support_credit: Label
var _note: PanelContainer
var _note_text: Label
var _panel_tween: Tween
var _closing: bool = false
var _bell_observation: BellObservation = BellObservation.NONE
var _bell_crop: AtlasTexture
var _bell_overlay: Control
var _bell_focus: Panel
var _bell_buttons: Array[Button] = []
var _bell_badges: Array[Panel] = []
var _bell_symbols: Array[Label] = []
var _bell_legend: Label
var _story_dots: Array[Panel] = []
var _story_labels: Array[Label] = []
var _takeaway_row: HBoxContainer
var _support_card: PanelContainer
var _detail_button: Button
var _documentary: PanelContainer
var _documentary_image: TextureRect
var _documentary_caption: Label
var _documentary_credit: Label
var _documentary_close: Button


func _ready() -> void:
	if Engine.is_editor_hint():
		_refresh_editor_preview.call_deferred()
		return
	_presentation_root = self
	super._ready()
	closed.connect(func() -> void: hotspot_closed.emit())
	_build_presentation()
	_header_utilities = HeaderUtilities.new(self, _pending)
	add_to_group("lingayen_church_narration")
	resized.connect(_resize_layout)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_open_standalone.call_deferred()


func _style_label(label: Label, font_size: int, secondary: bool = false) -> void:
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	if secondary:
		label.add_theme_color_override("font_color", SECONDARY)


func _build_header() -> void:
	var header := _presentation_root.get_node("Main/Margin/Layout/Header")
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	header.move_child(titles, 0)
	_title.reparent(titles)
	_style_label(_title, 28)
	titles.add_child(_subtitle)
	_style_label(_subtitle, 18, true)
	var listen_group := VBoxContainer.new()
	listen_group.name = "ListenGroup"
	listen_group.add_theme_constant_override("separation", 4)
	header.add_child(listen_group)
	header.move_child(listen_group, 1)
	_speaker.reparent(listen_group)
	_speaker.custom_minimum_size = Vector2(136, 56)
	_pending.text = "Narration pending."
	_pending.add_theme_font_size_override("font_size", 16)
	_pending.add_theme_color_override("font_color", SECONDARY)
	_pending.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	listen_group.add_child(_pending)
	_close.custom_minimum_size = Vector2(80, 56)
	_close.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	header.add_theme_constant_override("separation", 12)
	_presentation_root.get_node("Main/Margin/Layout/Controls").hide()


func _build_media() -> void:
	_media.name = "StoryMedia"
	_media.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_media.size_flags_stretch_ratio = 0.58
	_information.size_flags_stretch_ratio = 0.42
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_child(_media)
	_presentation_root.get_node("Main/Margin/Layout/Columns").move_child(_media, 0)
	_media_frame.name = "MainMediaFrame"
	_media_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_media_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_media.add_child(_media_frame)
	for layer in [_incoming, _outgoing]:
		_media_frame.add_child(layer)
		layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_image.reparent(_incoming)
	_incoming.add_child(_caption)
	_incoming.add_child(_credit)
	_outgoing.add_child(_outgoing_image)
	_outgoing.add_child(_outgoing_caption)
	_outgoing.add_child(_outgoing_credit)
	for image in [_image, _outgoing_image]:
		image.size_flags_vertical = Control.SIZE_EXPAND_FILL
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for label in [_caption, _outgoing_caption]:
		_style_label(label, 16)
	for label in [_credit, _outgoing_credit]:
		_style_label(label, 14, true)
	_outgoing.hide()
	_comparison.name = "WartimeComparison"
	_media.add_child(_comparison)
	var compare_label := Label.new()
	compare_label.text = "COMPARE"
	_style_label(compare_label, 12, true)
	compare_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_comparison.add_child(compare_label)
	for i in 2:
		var button := Button.new()
		button.text = ["POSTWAR DAMAGE", "PRESENT DAY"][i]
		button.accessibility_name = button.text
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(56, 52)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 16)
		if not Engine.is_editor_hint():
			button.pressed.connect(set_wartime_view.bind(i))
		_comparison.add_child(button)
		_comparison_buttons.append(button)
	_comparison.hide()


func _build_interpretation() -> void:
	var text_column := _body.get_parent()
	_heading.reparent(text_column)
	text_column.move_child(_heading, 0)
	_style_label(_heading, 24)
	_information.get_node("Meta").hide()
	_style_label(_prompt, 18, true)
	text_column.add_child(_prompt)
	text_column.move_child(_prompt, 2)
	# Evidence is part of the reading flow: compact layouts keep primary media large.
	_support.name = "DocumentaryEvidence"
	text_column.add_child(_support)
	text_column.move_child(_support, 3)
	_support.add_child(_support_image)
	_support_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_support_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_support_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_support_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_support.add_child(_support_caption)
	_support.add_child(_support_credit)
	_style_label(_support_caption, 16)
	_style_label(_support_credit, 14, true)
	_note.name = "HistoricalNote"
	var note_style := StyleBoxFlat.new()
	note_style.bg_color = Color("101d19")
	note_style.border_width_left = 2
	note_style.border_color = Color("8e6c51")
	note_style.content_margin_left = 10
	note_style.content_margin_right = 10
	note_style.content_margin_top = 8
	note_style.content_margin_bottom = 8
	_note.add_theme_stylebox_override("panel", note_style)
	var note_column := VBoxContainer.new()
	_note.add_child(note_column)
	var note_label := Label.new()
	note_label.text = "HISTORICAL NOTE"
	_style_label(note_label, 14, true)
	note_column.add_child(note_label)
	_style_label(_note_text, 18, true)
	note_column.add_child(_note_text)
	text_column.add_child(_note)
	text_column.move_child(_note, 4)
	_key_label.text = "KEY TAKEAWAY"
	_style_label(_key_label, 14, true)
	text_column.add_child(_key_label)
	text_column.move_child(_key_label, 5)
	_style_label(_takeaway, 18, true)
	_sources_button.custom_minimum_size.y = 56
	_source_close.custom_minimum_size.y = 56
	if not Engine.is_editor_hint():
		_scroll.gui_input.connect(_reading_input.bind(_scroll))
		_source_scroll.gui_input.connect(_reading_input.bind(_source_scroll))


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
	if not is_node_ready() or not content is BellsContent or content.concepts.size() != 4:
		return false
	for entry in content.concepts:
		if not entry is StoryPoint or entry.main_image == null:
			return false
	if content.present_day_image == null:
		return false
	if not _open:
		var previous := get_viewport().gui_get_focus_owner()
		_return_focus = weakref(previous) if previous != null else null
	_title.text = content.title
	_subtitle.text = content.subtitle
	_audio.stream = content.narration_stream
	_open = true
	show()
	reset_hotspot()
	_resize_layout()
	modulate.a = 0.0
	_panel_tween = create_tween()
	_panel_tween.tween_property(self, "modulate:a", 1.0, 0.18)
	opened.emit()
	return true


func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	if not is_node_ready() or not content is BellsContent:
		return
	_cancel_panel_tween()
	_closing = false
	_sources.hide()
	_documentary.hide()
	stop_narration()
	_bell_observation = BellObservation.NONE
	_wartime_view = WartimeView.POSTWAR_DAMAGE
	set_story_state(StoryState.OVERVIEW, false)
	if _open:
		_concepts[0].grab_focus()


func get_story_state() -> StoryState:
	return _selected as StoryState


func get_wartime_view() -> WartimeView:
	return _wartime_view


func select_concept(index: int) -> void:
	if Engine.is_editor_hint():
		return
	set_story_state(index + 1)


func set_story_state(state: int, animate: bool = true) -> void:
	if Engine.is_editor_hint():
		return
	if not is_node_ready() or content == null or _sources.visible or _documentary.visible or _closing:
		return
	var previous := _capture_media()
	_cancel_transition()
	var target := state if state >= 0 and state <= 3 else StoryState.OVERVIEW
	if target != _selected or target == StoryState.OVERVIEW:
		_wartime_view = WartimeView.POSTWAR_DAMAGE
		_bell_observation = BellObservation.NONE
	# Reuse the inherited shell index; no second main-story state variable.
	_selected = target
	_render()
	if animate and _open:
		_transition_media(previous)
	story_state_changed.emit(_selected)


func set_wartime_view(view: int) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _closing or _sources.visible or _documentary.visible or _selected != StoryState.WARTIME_1945:
		return
	if view < WartimeView.POSTWAR_DAMAGE or view > WartimeView.PRESENT_DAY:
		return
	var previous := _capture_media()
	_cancel_transition()
	_wartime_view = view as WartimeView
	_render_main_media()
	_transition_media(previous)
	wartime_view_changed.emit(_wartime_view)


func _render() -> void:
	var entry := content.concepts[_selected] as StoryPoint
	_heading.text = entry.heading
	_body.text = entry.body
	_prompt.text = content.prompt
	_prompt.visible = _selected == StoryState.OVERVIEW
	_takeaway.text = content.learning_takeaway
	_takeaway.show()
	_support.visible = entry.support_image != null
	_support_image.texture = entry.support_image
	_support_image.accessibility_name = entry.support_caption
	_support_caption.text = entry.support_caption
	_support_credit.text = entry.support_credit
	_note.visible = not entry.historical_note.is_empty()
	_note_text.text = entry.historical_note
	_comparison.visible = _selected == StoryState.WARTIME_1945
	for i in _concepts.size():
		_concepts[i].set_pressed_no_signal(_selected == i + 1)
		_story_dots[i].add_theme_stylebox_override("panel", _point_style(_selected == i + 1))
		_story_labels[i].add_theme_color_override("font_color", Color("e8d5b4") if _selected == i + 1 else SECONDARY)
	_render_main_media()
	_bell_overlay.visible = _selected == StoryState.HISTORIC_BELLS
	_bell_legend.visible = _bell_overlay.visible
	_render_observation()
	_scroll.scroll_vertical = 0
	if _open:
		_sync_focus()


func _render_main_media() -> void:
	var entry := content.concepts[_selected] as StoryPoint
	var present := _selected == StoryState.WARTIME_1945 and _wartime_view == WartimeView.PRESENT_DAY
	_image.texture = content.present_day_image if present else entry.main_image
	if _selected == StoryState.HISTORIC_BELLS:
		_image.texture = _bell_crop
	_caption.text = content.present_day_caption if present else entry.main_caption
	_credit.text = content.present_day_credit if present else entry.main_credit
	_image.accessibility_name = _caption.text
	for i in 2:
		_comparison_buttons[i].set_pressed_no_signal(_wartime_view == i)
	_layout_observations.call_deferred()


func _capture_media() -> Dictionary:
	return {"image": _image.texture, "caption": _caption.text, "credit": _credit.text}


func _transition_media(previous: Dictionary) -> void:
	if Engine.is_editor_hint():
		return
	# Image, caption and credit fade together, retaining each image's provenance.
	_outgoing_image.texture = previous.image
	_outgoing_caption.text = previous.caption
	_outgoing_credit.text = previous.credit
	_outgoing.modulate.a = 1.0
	_outgoing.visible = previous.image != null
	_incoming.modulate.a = 0.0
	_fade = create_tween().set_parallel(true)
	_fade.tween_property(_incoming, "modulate:a", 1.0, 0.18)
	_fade.tween_property(_outgoing, "modulate:a", 0.0, 0.18)
	_fade.chain().tween_callback(_clear_outgoing)


func _clear_outgoing() -> void:
	_outgoing.hide()
	_outgoing_image.texture = null
	_outgoing_caption.text = ""
	_outgoing_credit.text = ""


func _cancel_transition() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_fade()
	_incoming.modulate.a = 1.0
	_clear_outgoing()


func _sync_focus() -> void:
	if Engine.is_editor_hint():
		return
	var previous := get_viewport().gui_get_focus_owner()
	var main: Array[Control] = []
	main.append_array(_concepts)
	main.append_array(_bell_buttons)
	main.append_array(_comparison_buttons)
	main.append_array([_scroll, _detail_button, _sources_button, _speaker, _close])
	var overlay: Array[Control] = [_source_scroll, _source_close]
	var active: Array[Control] = []
	for control in main + overlay + [_documentary_close]:
		control.focus_mode = Control.FOCUS_NONE
	var candidates: Array[Control] = []
	if _documentary.visible:
		candidates.append(_documentary_close)
	else:
		candidates = overlay if _sources.visible else main
	for control in candidates:
		if control.is_visible_in_tree() and not (control is BaseButton and control.disabled):
			control.focus_mode = Control.FOCUS_ALL
			active.append(control)
	for i in active.size():
		active[i].focus_next = active[i].get_path_to(active[(i + 1) % active.size()])
		active[i].focus_previous = active[i].get_path_to(active[posmod(i - 1, active.size())])
	if previous in active:
		previous.grab_focus()
	elif not active.is_empty():
		active[0].grab_focus()


func _story_input(event: InputEvent, index: int) -> void:
	if Engine.is_editor_hint():
		return
	if _sources.visible or _documentary.visible or _closing:
		return
	var step := 0
	if event.is_action_pressed(&"ui_left"):
		step = -1
	elif event.is_action_pressed(&"ui_right"):
		step = 1
	if step != 0:
		get_viewport().set_input_as_handled()
		_concepts[clampi(index + step, 0, 2)].grab_focus()


func _reading_input(event: InputEvent, scroll: ScrollContainer) -> void:
	if Engine.is_editor_hint():
		return
	if not event is InputEventKey or not event.pressed:
		return
	var target := scroll.scroll_vertical
	match event.keycode:
		KEY_DOWN:
			target += 40
		KEY_UP:
			target -= 40
		KEY_PAGEDOWN:
			target += int(scroll.size.y * 0.85)
		KEY_PAGEUP:
			target -= int(scroll.size.y * 0.85)
		KEY_HOME:
			target = 0
		KEY_END:
			target = int(scroll.get_v_scroll_bar().max_value)
		_:
			return
	get_viewport().set_input_as_handled()
	scroll.scroll_vertical = target


func _resize_layout() -> void:
	if not is_instance_valid(_presentation_root):
		return
	EditorPresentation.resize(self, _presentation_root)
	if not is_node_ready() or _story_row == null:
		return
	var compact := _presentation_root.size.x < 1000 or _presentation_root.size.y < 550
	var small := _presentation_root.size.y < 460
	for side in ["left", "top", "right", "bottom"]:
		_presentation_root.get_node("Main/Margin").add_theme_constant_override("margin_" + side, 8 if compact else 16)
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_theme_constant_override("separation", 12 if compact else 24)
	for container in [_presentation_root.get_node("Main/Margin/Layout"), _information, _media, _incoming, _outgoing, _comparison, _story_row]:
		container.add_theme_constant_override("separation", 4 if compact else 8)
	_body.get_parent().add_theme_constant_override("separation", 8 if compact else 12)
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_heading.add_theme_font_size_override("font_size", 20 if compact else 22)
	_body.add_theme_font_size_override("font_size", 18)
	_support_image.custom_minimum_size = Vector2(80, 120) if compact else Vector2(128, 156)
	var text_column := _body.get_parent()
	var support_parent: Node = text_column if compact else _information
	if _support.get_parent() != support_parent:
		_support.reparent(support_parent)
		support_parent.move_child(_support, 3 if compact else 2)
	var takeaway_parent: Node = text_column if compact else _takeaway_row
	if _takeaway.get_parent() != takeaway_parent:
		_key_label.reparent(takeaway_parent)
		_takeaway.reparent(takeaway_parent)
	_takeaway_row.visible = not compact
	_takeaway.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_key_label.custom_minimum_size.x = 0 if compact else 110
	_body.get_parent().add_theme_constant_override("separation", 8 if compact else 6)
	if not compact:
		_presentation_root.get_node("Main/Margin/Layout").add_theme_constant_override("separation", 6)
		_information.add_theme_constant_override("separation", 6)
	if content is BellsContent and content.concepts.size() == 4:
		for i in _concepts.size():
			var entry := content.concepts[i + 1] as StoryPoint
			_concepts[i].text = ""
			_story_labels[i].text = entry.compact_label if small else entry.label
			_concepts[i].accessibility_name = entry.label
			_concepts[i].add_theme_font_size_override("font_size", 18)
	_layout_observations.call_deferred()
	if Engine.is_editor_hint():
		HeaderUtilities.resize_presentation(self, _pending, _presentation_root.size.x)
	elif _header_utilities != null:
		_header_utilities.resize()


func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _closing or _sources.visible or _documentary.visible:
		return
	_cancel_transition()
	super.open_sources()


func _update_speaker() -> void:
	if Engine.is_editor_hint():
		return
	HeaderUtilities.update_speaker(self, _pending)


func toggle_narration() -> void:
	if Engine.is_editor_hint():
		return
	HeaderUtilities.toggle_narration(self)


func stop_narration() -> void:
	if Engine.is_editor_hint():
		return
	_audio.stream_paused = false
	super.stop_narration()


func close_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	close_interaction()


func close_interaction() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _closing:
		return
	_cancel_transition()
	_documentary.hide()
	_cancel_panel_tween()
	stop_narration()
	_closing = true
	_panel_tween = create_tween()
	_panel_tween.tween_property(self, "modulate:a", 0.0, 0.16)
	_panel_tween.tween_callback(_finish_close)


func _finish_close() -> void:
	if Engine.is_editor_hint():
		return
	_panel_tween = null
	_closing = false
	_documentary.hide()
	_documentary_image.texture = null
	modulate.a = 1.0
	super.close_interaction()


func _cancel_panel_tween() -> void:
	if Engine.is_editor_hint():
		return
	if _panel_tween != null and _panel_tween.is_valid():
		_panel_tween.kill()
	_panel_tween = null
	modulate.a = 1.0


func _visibility_changed() -> void:
	if Engine.is_editor_hint():
		return
	if _open and not is_visible_in_tree():
		_cancel_transition()
		_cancel_panel_tween()
		_finish_close()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_panel_tween()
	super._exit_tree()


func _point_style(selected: bool, radius: int = 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("e8d5b4") if selected else Color("9c4a25")
	style.border_color = Color("e8d5b4") if selected else Color("8e6c51")
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	return style


func _build_evidence_path() -> void:
	for i in _concepts.size():
		var button := _concepts[i]
		for state in ["normal", "pressed", "hover_pressed", "disabled"]:
			button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		var hover := StyleBoxFlat.new()
		hover.bg_color = Color(Color("6f3317"), 0.5)
		hover.set_corner_radius_all(24)
		button.add_theme_stylebox_override("hover", hover)
		var focus := StyleBoxFlat.new()
		focus.draw_center = false
		focus.set_corner_radius_all(28)
		focus.set_border_width_all(2)
		focus.border_color = Color("f9f5f0")
		button.add_theme_stylebox_override("focus", focus)
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 12)
		button.add_child(row)
		row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var dot := Panel.new()
		dot.custom_minimum_size = Vector2(24, 24)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dot.add_theme_stylebox_override("panel", _point_style(false))
		row.add_child(dot)
		_story_dots.append(dot)
		var label := Label.new()
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", 18)
		row.add_child(label)
		_story_labels.append(label)
		if i < 2:
			var connector := ColorRect.new()
			connector.name = "DecorativeConnector%d" % i
			connector.color = Color("8e6c51")
			connector.custom_minimum_size = Vector2(24, 1)
			connector.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			connector.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_story_row.add_child(connector)
			_story_row.move_child(connector, i * 2 + 1)
	_takeaway_row.name = "TakeawayFooter"
	_takeaway_row.add_theme_constant_override("separation", 12)
	var layout := _presentation_root.get_node("Main/Margin/Layout")
	layout.add_child(_takeaway_row)
	layout.move_child(_takeaway_row, _story_row.get_index())


func _build_observations() -> void:
	_bell_crop = AtlasTexture.new()
	_bell_crop.atlas = content.concepts[StoryState.HISTORIC_BELLS].main_image
	var native := _bell_crop.atlas.get_size()
	_bell_crop.region = Rect2(BELL_CROP.position * native, BELL_CROP.size * native)
	_bell_crop.filter_clip = true
	_bell_overlay.name = "BellObservations"
	_bell_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_image.add_child(_bell_overlay)
	_bell_overlay.add_child(_bell_focus)
	_bell_focus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame := _point_style(false, 0)
	frame.bg_color = Color(Color("e8d5b4"), 0.05)
	frame.border_color = Color("e8d5b4")
	_bell_focus.add_theme_stylebox_override("panel", frame)
	for i in 2:
		var button := Button.new()
		button.custom_minimum_size = Vector2(56, 56)
		button.size = Vector2(56, 56)
		button.toggle_mode = true
		button.accessibility_name = ["Bell Display", "Surface Details"][i]
		button.tooltip_text = button.accessibility_name
		for state in ["normal", "hover", "pressed", "hover_pressed"]:
			button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		_bell_overlay.add_child(button)
		var badge := Panel.new()
		badge.position = Vector2(12, 12)
		badge.size = Vector2(32, 32)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(badge)
		var symbol := Label.new()
		symbol.text = ["A", "B"][i]
		symbol.add_theme_font_size_override("font_size", 18)
		symbol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		symbol.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		symbol.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_child(symbol)
		symbol.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		if not Engine.is_editor_hint():
			button.pressed.connect(set_bell_observation.bind(i + 1))
			button.gui_input.connect(_observation_input.bind(i))
		_bell_buttons.append(button)
		_bell_badges.append(badge)
		_bell_symbols.append(symbol)
	_style_label(_bell_legend, 16, true)
	_bell_legend.text = "A  Bell Display     B  Surface Details"
	_incoming.add_child(_bell_legend)
	_incoming.move_child(_bell_legend, 1)
	_image.resized.connect(_layout_observations)
	_bell_overlay.hide()
	_bell_legend.hide()


func get_bell_observation() -> BellObservation:
	return _bell_observation


func set_bell_observation(observation: int) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _closing or _sources.visible or _documentary.visible or _selected != StoryState.HISTORIC_BELLS:
		return
	_cancel_transition()
	_bell_observation = clampi(observation, 0, 2) as BellObservation
	_render_observation()


func _render_observation() -> void:
	_bell_focus.visible = _selected == StoryState.HISTORIC_BELLS and _bell_observation != BellObservation.NONE
	for i in _bell_buttons.size():
		var selected := _bell_observation == i + 1
		_bell_buttons[i].set_pressed_no_signal(selected)
		_bell_badges[i].add_theme_stylebox_override("panel", _point_style(selected))
		_bell_symbols[i].add_theme_color_override("font_color", Color("101d19") if selected else Color("f9f5f0"))
	_layout_observations()


func _layout_observations() -> void:
	if _bell_crop == null or _bell_buttons.size() != 2:
		return
	var native := _bell_crop.get_size()
	var factor := minf(_image.size.x / native.x, _image.size.y / native.y)
	_bell_overlay.size = native * maxf(factor, 0.0)
	_bell_overlay.position = (_image.size - _bell_overlay.size) * 0.5
	for i in 2:
		_bell_buttons[i].position = BELL_MARKERS[i] * _bell_overlay.size - _bell_buttons[i].size * 0.5
	var region: Rect2 = BELL_REGIONS[_bell_observation]
	_bell_focus.position = region.position * _bell_overlay.size
	_bell_focus.size = region.size * _bell_overlay.size


func _observation_input(event: InputEvent, index: int) -> void:
	if Engine.is_editor_hint():
		return
	if _sources.visible or _documentary.visible or _closing:
		return
	var step := int(event.is_action_pressed(&"ui_right")) - int(event.is_action_pressed(&"ui_left"))
	if step != 0:
		get_viewport().set_input_as_handled()
		_bell_buttons[clampi(index + step, 0, 1)].grab_focus()


func _build_documentary_card() -> void:
	_support.add_child(_support_card)
	var style := _point_style(false, 4)
	style.set_content_margin_all(8)
	style.set_border_width_all(1)
	_support_card.add_theme_stylebox_override("panel", style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_support_card.add_child(row)
	_support_image.reparent(row)
	_support_image.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var metadata := VBoxContainer.new()
	metadata.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	metadata.alignment = BoxContainer.ALIGNMENT_CENTER
	metadata.add_theme_constant_override("separation", 6)
	row.add_child(metadata)
	_support_caption.reparent(metadata)
	_support_credit.reparent(metadata)
	_detail_button.text = "View Source Detail"
	_detail_button.custom_minimum_size.y = 52
	_detail_button.add_theme_font_size_override("font_size", 16)
	metadata.add_child(_detail_button)
	if not Engine.is_editor_hint():
		_detail_button.pressed.connect(open_documentary_detail)
		_detail_button.focus_entered.connect(func() -> void:
			if _scroll.is_ancestor_of(_detail_button):
				_scroll.ensure_control_visible(_detail_button))
	_documentary.name = "DocumentaryDetail"
	_presentation_root.add_child(_documentary)
	_documentary.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_documentary.add_theme_stylebox_override("panel", _sources.get_theme_stylebox("panel"))
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	_documentary.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var title := Label.new()
	title.text = "Documentary Evidence"
	_style_label(title, 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_documentary_close.text = "Close Detail"
	_documentary_close.custom_minimum_size = Vector2(140, 56)
	header.add_child(_documentary_close)
	if not Engine.is_editor_hint():
		_documentary_close.pressed.connect(close_documentary_detail)
	column.add_child(_documentary_image)
	_documentary_image.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_documentary_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_documentary_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_documentary_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_style_label(_documentary_caption, 16)
	_style_label(_documentary_credit, 14, true)
	column.add_child(_documentary_caption)
	column.add_child(_documentary_credit)
	_documentary.hide()


func open_documentary_detail() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _closing or _sources.visible or _documentary.visible or not _support.visible:
		return
	_cancel_transition()
	_documentary_image.texture = _support_image.texture
	_documentary_caption.text = _support_caption.text
	_documentary_credit.text = _support_credit.text
	_documentary_image.accessibility_name = _support_caption.text
	_documentary.show()
	_sync_focus()
	_documentary_close.grab_focus()


func close_documentary_detail() -> void:
	if Engine.is_editor_hint():
		return
	if not _documentary.visible:
		return
	_documentary.hide()
	_documentary_image.texture = null
	_sync_focus()
	_detail_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if _open and _documentary.visible and event.is_action_pressed(&"go_back"):
		var viewport := get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()
		if not event.is_echo():
			close_documentary_detail()
		return
	super._unhandled_input(event)


func _build_presentation() -> void:
	_subtitle = Label.new()
	_pending = Label.new()
	_media = VBoxContainer.new()
	_media_frame = Control.new()
	_incoming = VBoxContainer.new()
	_outgoing = VBoxContainer.new()
	_outgoing_image = TextureRect.new()
	_caption = Label.new()
	_credit = Label.new()
	_outgoing_caption = Label.new()
	_outgoing_credit = Label.new()
	_comparison = HBoxContainer.new()
	_prompt = Label.new()
	_key_label = Label.new()
	_support = VBoxContainer.new()
	_support_image = TextureRect.new()
	_support_caption = Label.new()
	_support_credit = Label.new()
	_note = PanelContainer.new()
	_note_text = Label.new()
	_bell_overlay = Control.new()
	_bell_focus = Panel.new()
	_bell_legend = Label.new()
	_takeaway_row = HBoxContainer.new()
	_support_card = PanelContainer.new()
	_detail_button = Button.new()
	_documentary = PanelContainer.new()
	_documentary_image = TextureRect.new()
	_documentary_caption = Label.new()
	_documentary_credit = Label.new()
	_documentary_close = Button.new()
	_comparison_buttons.clear()
	_bell_buttons.clear()
	_bell_badges.clear()
	_bell_symbols.clear()
	_story_dots.clear()
	_story_labels.clear()

	_build_header()
	_build_media()
	_build_interpretation()
	_story_row = _presentation_root.get_node("Main/Margin/Layout/Sections")
	_story_row.name = "StoryPoints"
	for i in _concepts.size():
		_concepts[i].custom_minimum_size = Vector2(56, 56)
		if not Engine.is_editor_hint():
			_concepts[i].gui_input.connect(_story_input.bind(i))
	_build_evidence_path()
	_build_observations()
	_build_documentary_card()


func close_sources() -> void:
	if not Engine.is_editor_hint():
		super.close_sources()


func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready() or content == null:
		return
	_presentation_root = EditorPresentation.begin(self)
	_build_presentation()
	_selected = StoryState.OVERVIEW
	_wartime_view = WartimeView.POSTWAR_DAMAGE
	_bell_observation = BellObservation.NONE
	_title.text = content.title
	_subtitle.text = content.subtitle
	_render()
	EditorPresentation.finish(self, _presentation_root, _pending, content.narration_stream)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
