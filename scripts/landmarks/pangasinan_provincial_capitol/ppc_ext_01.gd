@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/pangasinan_provincial_capitol/ppc_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview
## Three parallel orientation views. The host owns navigation outside this panel.

const ViewRecord = preload("res://scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_01_view.gd")
const VIEW_IDS: Array[StringName] = [&"capitol", &"civic_setting", &"government_today"]
const TRANSITION_SECONDS: float = 0.2

var current_view: StringName = &"capitol"
var _subtitle: Label
var _context: Label
var _caption: Label
var _pending: Label
var _media: VBoxContainer
var _photo_frame: Control
var _previous_image: TextureRect
var _transition: Tween
var _photo_button: Button
var _focus_frame: Panel
var _observations: HBoxContainer
var _observation_tags: Array[PanelContainer] = []
var _observation_labels: Array[Label] = []
var _explore: PanelContainer
var _explore_image: TextureRect
var _explore_caption: Label
var _explore_close: Button
var _explore_tween: Tween
var _explore_closing: bool = false


func is_explore_open() -> bool:
	# Visibility includes the closing fade: background input stays blocked.
	return _explore.visible


func _ready() -> void:
	if Engine.is_editor_hint():
		_refresh_editor_preview.call_deferred()
		return
	_presentation_root = self
	super._ready()
	_build_presentation()
	resized.connect(_resize_layout)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_open_standalone.call_deferred()


func _build_presentation() -> void:
	_subtitle = Label.new()
	_context = Label.new()
	_caption = Label.new()
	_pending = Label.new()
	_media = VBoxContainer.new()
	_photo_frame = Control.new()
	_previous_image = TextureRect.new()
	_photo_button = Button.new()
	_focus_frame = Panel.new()
	_observations = HBoxContainer.new()
	_explore = PanelContainer.new()
	_explore_image = TextureRect.new()
	_explore_caption = Label.new()
	_explore_close = Button.new()
	_observation_tags.clear()
	_observation_labels.clear()
	var header := _presentation_root.get_node("Main/Margin/Layout/Header")
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	header.move_child(titles, 0)
	_title.reparent(titles)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titles.add_child(_subtitle)
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sources_button.reparent(header)
	var listen_group := VBoxContainer.new()
	header.add_child(listen_group)
	_speaker.reparent(listen_group)
	listen_group.add_child(_pending)
	_pending.text = "Narration pending."
	_pending.add_theme_font_size_override("font_size", 14)
	header.move_child(_close, header.get_child_count() - 1)
	header.add_theme_constant_override("separation", 8)
	for button in [_sources_button, _speaker, _close]:
		button.custom_minimum_size = Vector2(100, 56)
		button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_sources_button.text = "SOURCES"
	_close.text = "CLOSE"
	_speaker.expand_icon = false
	_speaker.add_theme_constant_override("icon_max_width", 24)
	_presentation_root.get_node("Main/Margin/Layout/Controls").hide()
	_presentation_root.get_node("Main/Margin/Layout").move_child(_presentation_root.get_node("Main/Margin/Layout/Sections"), 1)
	for i in _concepts.size():
		_concepts[i].custom_minimum_size = Vector2(48, 56)
		if not Engine.is_editor_hint():
			_concepts[i].gui_input.connect(_selector_input.bind(i))
	_media.name = "DocumentaryMedia"
	_media.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_presentation_root.find_child("Columns", true, false).add_child(_media)
	_presentation_root.find_child("Columns", true, false).move_child(_media, 0)
	_photo_frame.name = "PhotoFrame"
	_photo_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_photo_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_media.add_child(_photo_frame)
	_image.reparent(_photo_frame)
	_photo_frame.add_child(_previous_image)
	for photo in [_image, _previous_image]:
		photo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		photo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_previous_image.hide()
	_build_photo_controls()
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var text := _body.get_parent()
	text.add_child(_context)
	text.move_child(_context, 0)
	_heading.reparent(text)
	text.move_child(_heading, 1)
	for label in [_context, _heading]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_context.add_theme_color_override("font_color", Color("d8c58b"))
	for label in [_subtitle, _caption]:
		label.add_theme_color_override("font_color", Color("c2bfae"))
	_presentation_root.get_node("Main/Margin/Layout/Columns/Information/Meta").hide()
	_source_close.custom_minimum_size.y = 56
	_build_explore_view()
	_photo_frame.resized.connect(_layout_focus_frame)


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
	if not is_node_ready() or content == null or content.concepts.size() != 3:
		return false
	for i in VIEW_IDS.size():
		if not content.concepts[i] is ViewRecord or content.concepts[i].view_id != VIEW_IDS[i]:
			return false
	if _open:
		return true
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_audio.stream = content.narration_stream
	_open = true
	show()
	reset_hotspot()
	opened.emit()
	return true


func select_concept(index: int) -> void:
	if Engine.is_editor_hint():
		return
	if index >= 0 and index < VIEW_IDS.size():
		select_view(VIEW_IDS[index])


func select_view(view_id: StringName, animate: bool = true) -> void:
	if Engine.is_editor_hint():
		return
	if not is_node_ready() or content == null or _sources.visible or is_explore_open() or not view_id in VIEW_IDS:
		return
	var old_texture := _image.texture
	var changed := current_view != view_id
	_cancel_transition()
	current_view = view_id
	_selected = VIEW_IDS.find(view_id)
	_render()
	if animate and changed and _open and old_texture != null:
		# The newest image is authoritative immediately. Only the outgoing layer
		# fades; interrupted transitions cannot write textures or content later.
		_previous_image.texture = old_texture
		_previous_image.modulate.a = 1.0
		_previous_image.show()
		_transition = create_tween()
		_transition.tween_property(_previous_image, "modulate:a", 0.0, TRANSITION_SECONDS)
		_transition.tween_callback(_clear_previous_image)
	concept_changed.emit(_selected)


func _render() -> void:
	var records: Array = content.get("concepts")
	var entry: Resource = records[_selected]
	_title.text = content.title
	_subtitle.text = content.prompt
	_context.text = entry.context_label
	_heading.text = entry.heading
	_body.text = entry.body
	_takeaway.text = entry.takeaway
	_image.texture = entry.image
	_image.accessibility_name = entry.caption
	_caption.text = entry.caption
	_render_observations(entry)
	for i in _concepts.size():
		_concepts[i].text = records[i].get("selector_label")
		_concepts[i].set_pressed_no_signal(i == _selected)
	_scroll.scroll_vertical = 0


func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or is_explore_open():
		return
	_cancel_transition()
	super.open_sources()
	_source_title.text = "SOURCES"
	_source_text.text = content.source_credit + "\n\nDOCUMENTARY MEDIA"
	for entry: ViewRecord in content.concepts:
		_source_text.text += "\n\n" + entry.image.resource_path.get_file().get_basename()
		_source_text.text += "\n" + entry.media_credit + "\nPermission/reuse status: " + entry.permission_status
	_source_text.text += "\n\n" + str(content.get_meta(&"audio_credit", ""))


func toggle_narration() -> void:
	if Engine.is_editor_hint():
		return
	if _sources.visible or is_explore_open():
		return
	super.toggle_narration()


func stop_narration() -> void:
	if Engine.is_editor_hint():
		return
	_audio.stream_paused = false
	super.stop_narration()


func _update_speaker() -> void:
	if Engine.is_editor_hint():
		return
	super._update_speaker()
	_speaker.show()
	_speaker.disabled = _audio.stream == null
	_speaker.text = "RESUME" if _audio.stream_paused else ("PAUSE" if _audio.playing else "LISTEN")
	_pending.visible = _audio.stream == null


func _selector_input(event: InputEvent, index: int) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or is_explore_open():
		return
	var step := 0
	if event.is_action_pressed(&"ui_left"):
		step = -1
	elif event.is_action_pressed(&"ui_right"):
		step = 1
	if step != 0:
		get_viewport().set_input_as_handled()
		var target := clampi(index + step, 0, VIEW_IDS.size() - 1)
		select_view(VIEW_IDS[target])
		_concepts[target].grab_focus()


func _sync_focus() -> void:
	if Engine.is_editor_hint():
		return
	var previous := get_viewport().gui_get_focus_owner()
	var main: Array[Control] = []
	main.append_array(_concepts)
	main.append_array([_photo_button, _sources_button, _speaker, _close, _scroll])
	var overlay: Array[Control] = [_source_close, _source_scroll]
	var active: Array[Control] = []
	for control in main + overlay + [_explore_close]:
		control.focus_mode = Control.FOCUS_NONE
	var candidates: Array[Control] = overlay if _sources.visible else main
	if is_explore_open():
		candidates = [_explore_close]
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


func _resize_layout() -> void:
	if not is_instance_valid(_presentation_root):
		return
	if Engine.is_editor_hint():
		EditorPresentation.resize(self, _presentation_root)
	if not is_node_ready():
		return
	var compact := size.x < 1000 or size.y < 550
	var margin := 10 if compact else 16
	for side in ["left", "right", "top", "bottom"]:
		_presentation_root.get_node("Main/Margin").add_theme_constant_override("margin_" + side, margin)
	_presentation_root.get_node("Main/Margin/Layout").add_theme_constant_override("separation", 8 if compact else 12)
	_presentation_root.find_child("Columns", true, false).add_theme_constant_override("separation", 14 if compact else 24)
	_media.size_flags_stretch_ratio = 0.55 if compact else 0.59
	_information.size_flags_stretch_ratio = 0.45 if compact else 0.41
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_subtitle.add_theme_font_size_override("font_size", 16)
	_heading.add_theme_font_size_override("font_size", 23 if compact else 24)
	_body.add_theme_font_size_override("font_size", 18 if compact else 20)
	_takeaway.add_theme_font_size_override("font_size", 18)
	_body.get_parent().add_theme_constant_override("separation", 8)
	_speaker.custom_minimum_size.x = 110 if compact else 120
	_caption.add_theme_font_size_override("font_size", 16)
	_context.add_theme_font_size_override("font_size", 14 if compact else 16)
	_source_text.add_theme_font_size_override("font_size", 18 if compact else 22)
	for button in _concepts + [_sources_button, _speaker, _close]:
		button.add_theme_font_size_override("font_size", 16 if compact else 18)
	_layout_focus_frame()


func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	_reset_explore()
	_cancel_transition()
	_cancel_fade()
	_sources.hide()
	_source_scroll.scroll_vertical = 0
	stop_narration()
	select_view(&"capitol", false)
	modulate = Color.WHITE
	scale = Vector2.ONE
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null and is_ancestor_of(focused):
		focused.release_focus()
	if _open and is_visible_in_tree():
		_sync_focus()
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


func _clear_previous_image() -> void:
	if Engine.is_editor_hint():
		return
	_previous_image.hide()
	_previous_image.texture = null
	_previous_image.modulate = Color.WHITE
	_transition = null


func _cancel_transition() -> void:
	if Engine.is_editor_hint():
		return
	if _transition != null and _transition.is_valid():
		_transition.kill()
	_clear_previous_image()


func _visibility_changed() -> void:
	if Engine.is_editor_hint():
		return
	if _open and not is_visible_in_tree():
		close_interaction()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_explore_tween()
	_cancel_transition()
	super._exit_tree()


func _build_photo_controls() -> void:
	# Reuse the shell's button/focus styling. The photo itself has no opaque fill.
	_photo_button.name = "PhotoButton"
	_photo_button.focus_mode = Control.FOCUS_ALL
	_photo_button.custom_minimum_size = Vector2(48, 56)
	_photo_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_photo_button.accessibility_name = "View larger documentary photograph"
	for state in ["normal", "pressed"]:
		_photo_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var hover_outline := StyleBoxFlat.new()
	hover_outline.draw_center = false
	hover_outline.set_border_width_all(1)
	hover_outline.border_color = Color(0.85, 0.78, 0.57, 0.65)
	_photo_button.add_theme_stylebox_override("hover", hover_outline)
	_photo_frame.add_child(_photo_button)
	_photo_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if not Engine.is_editor_hint():
		_photo_button.pressed.connect(open_explore_view)
	_focus_frame.name = "LandmarkFocusFrame"
	_focus_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var outline := StyleBoxFlat.new()
	outline.draw_center = false
	outline.set_border_width_all(1)
	outline.border_color = Color(0.85, 0.78, 0.57, 0.65)
	_focus_frame.add_theme_stylebox_override("panel", outline)
	_photo_frame.add_child(_focus_frame)
	# Place observations beside the photograph, never over documentary details.
	_observations.name = "ObservationLabels"
	_observations.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_observations.add_theme_constant_override("separation", 6)
	_media.add_child(_observations)
	for i in 3:
		var tag := PanelContainer.new()
		tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var style := StyleBoxFlat.new()
		style.draw_center = false
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 4
		style.content_margin_bottom = 4
		tag.add_theme_stylebox_override("panel", style)
		var label := Label.new()
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color("d8c58b"))
		tag.add_child(label)
		_observations.add_child(tag)
		_observation_tags.append(tag)
		_observation_labels.append(label)
	_caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_media.add_child(_caption)


func _render_observations(entry: Resource) -> void:
	var labels: PackedStringArray = entry.get("observation_labels")
	_observations.visible = not labels.is_empty()
	for i in _observation_tags.size():
		_observation_tags[i].visible = i < labels.size()
		_observation_labels[i].text = labels[i] if i < labels.size() else ""
	_layout_focus_frame()


func _layout_focus_frame() -> void:
	if not is_node_ready() or content == null or _image.texture == null:
		return
	var records: Array = content.get("concepts")
	var entry: Resource = records[_selected]
	_focus_frame.visible = entry.focus_region.has_area()
	if not _focus_frame.visible:
		return
	var texture_size := _image.texture.get_size()
	var ratio := minf(_photo_frame.size.x / texture_size.x, _photo_frame.size.y / texture_size.y)
	var fitted_size := texture_size * ratio
	var origin := (_photo_frame.size - fitted_size) * 0.5
	_focus_frame.position = origin + fitted_size * entry.focus_region.position
	_focus_frame.size = fitted_size * entry.focus_region.size


func _build_explore_view() -> void:
	_explore.name = "ExploreView"
	_presentation_root.add_child(_explore)
	_explore.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := StyleBoxFlat.new()
	backdrop.bg_color = Color(0.025, 0.045, 0.04, 0.98)
	backdrop.set_border_width_all(2)
	backdrop.border_color = Color(0.46, 0.40, 0.25, 1)
	backdrop.content_margin_left = 12
	backdrop.content_margin_right = 12
	backdrop.content_margin_top = 12
	backdrop.content_margin_bottom = 12
	_explore.add_theme_stylebox_override("panel", backdrop)
	var layout := VBoxContainer.new()
	_explore.add_child(layout)
	var header := HBoxContainer.new()
	layout.add_child(header)
	var title := Label.new()
	title.text = "EXPLORE VIEW"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	header.add_child(title)
	_explore_close.name = "CloseView"
	_explore_close.text = "CLOSE VIEW"
	_explore_close.custom_minimum_size = Vector2(152, 56)
	_explore_close.add_theme_font_size_override("font_size", 18)
	header.add_child(_explore_close)
	if not Engine.is_editor_hint():
		_explore_close.pressed.connect(close_explore_view)
	_explore_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_explore_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_explore_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_explore_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_explore_image.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(_explore_image)
	_explore_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_explore_caption.add_theme_font_size_override("font_size", 16)
	_explore_caption.add_theme_color_override("font_color", Color("c2bfae"))
	layout.add_child(_explore_caption)
	_explore.hide()


func open_explore_view() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or is_explore_open():
		return
	_cancel_transition()
	_cancel_explore_tween()
	_explore_image.texture = _image.texture
	_explore_image.accessibility_name = _caption.text
	_explore_caption.text = _caption.text
	_explore_closing = false
	_explore.modulate.a = 0.0
	_explore.show()
	_sync_focus()
	_explore_close.grab_focus()
	_explore_tween = create_tween()
	_explore_tween.tween_property(_explore, "modulate:a", 1.0, TRANSITION_SECONDS)
	_explore_tween.tween_callback(func() -> void: _explore_tween = null)


func close_explore_view() -> void:
	if Engine.is_editor_hint():
		return
	if not is_explore_open() or _explore_closing:
		return
	_cancel_explore_tween()
	_explore_closing = true
	_explore_tween = create_tween()
	_explore_tween.tween_property(_explore, "modulate:a", 0.0, TRANSITION_SECONDS)
	_explore_tween.tween_callback(_finish_explore_close)


func _finish_explore_close() -> void:
	if Engine.is_editor_hint():
		return
	_explore_tween = null
	_reset_explore()
	if _open and is_visible_in_tree():
		_sync_focus()
		_photo_button.grab_focus()


func _cancel_explore_tween() -> void:
	if Engine.is_editor_hint():
		return
	if _explore_tween != null and _explore_tween.is_valid():
		_explore_tween.kill()
	_explore_tween = null


func _reset_explore() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_explore_tween()
	_explore.hide()
	_explore.modulate = Color.WHITE
	_explore_image.texture = null
	_explore_caption.text = ""
	_explore_closing = false


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
	elif is_explore_open():
		close_explore_view()
	else:
		close_interaction()


func close_sources() -> void:
	if not Engine.is_editor_hint():
		super.close_sources()


func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready() or content == null:
		return
	_presentation_root = EditorPresentation.begin(self)
	_build_presentation()
	_title.text = content.get("title")
	_subtitle.text = content.get("prompt")
	current_view = &"capitol"
	_selected = 0
	_render()
	EditorPresentation.finish(self, _presentation_root)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
