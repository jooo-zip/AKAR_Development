@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/casa_real/cr_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview

## Transformation stages share only the established Casa Real shell/lifecycle.
## The inherited legacy _selected field is unused.
enum StageState { OVERVIEW, DAMAGE, RESTORATION, MUSEUM_REBIRTH }
const StageEntry = preload("res://scripts/landmarks/casa_real/cr_int_01_stage.gd")
const TransformationContent = preload("res://scripts/landmarks/casa_real/cr_int_01_content.gd")
const ComparisonControl = preload("res://scripts/landmarks/casa_real/cr_int_01_comparison.gd")
const StormVisual = preload("res://scripts/landmarks/casa_real/cr_int_01_storm_visual.gd")

var current_stage: StageState = StageState.OVERVIEW
var comparison_position: float = 0.5
var museum_photo_index: int = 0
var storm_active: bool = false
var active_stage_transition: Tween
var active_storm_tween: Tween
var _reveal: Tween
var _subtitle: Label
var _period: Label
var _prompt: Label
var _identity: Label
var _caption: Label
var _hint: Label
var _read_hint: Label
var _overview: Button
var _viewer: VBoxContainer
var _visual: Button
var _after: TextureRect
var _storm: StormVisual
var _storm_audio: AudioStreamPlayer
var _comparison: ComparisonControl
var _comparison_row: HBoxContainer
var _comparison_labels: HBoxContainer
var _footer: HBoxContainer
var _before_label: Label
var _after_label: Label
var _details: VBoxContainer
var _interpretation: VBoxContainer
var _ribbon: HBoxContainer
var _titles: VBoxContainer


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
	_period = Label.new()
	_prompt = Label.new()
	_identity = Label.new()
	_caption = Label.new()
	_hint = Label.new()
	_read_hint = Label.new()
	_overview = Button.new()
	_viewer = VBoxContainer.new()
	_visual = Button.new()
	_after = TextureRect.new()
	_storm = StormVisual.new()
	_storm_audio = AudioStreamPlayer.new()
	_comparison = ComparisonControl.new()
	_comparison_row = HBoxContainer.new()
	_comparison_labels = HBoxContainer.new()
	_footer = HBoxContainer.new()
	_before_label = Label.new()
	_after_label = Label.new()
	_details = VBoxContainer.new()
	_interpretation = VBoxContainer.new()
	_ribbon = HBoxContainer.new()
	_titles = VBoxContainer.new()
	var header := _presentation_root.get_node("Main/Margin/Layout/Header")
	var layout := _presentation_root.get_node("Main/Margin/Layout")
	header.add_child(_titles)
	header.move_child(_titles, 0)
	_titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.reparent(_titles)
	_titles.add_child(_subtitle)
	_sources_button.reparent(header)
	_speaker.reparent(header)
	header.move_child(_close, header.get_child_count() - 1)
	for button in [_sources_button, _speaker, _close]:
		button.custom_minimum_size = Vector2(108, 56)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_sources_button.text = "SOURCES"
	_close.text = "CLOSE"
	_speaker.expand_icon = false
	_speaker.add_theme_constant_override("icon_max_width", 24)
	_presentation_root.get_node("Main/Margin/Layout/Controls").hide()
	_presentation_root.get_node("Main/Margin/Layout/Sections").hide()
	_presentation_root.get_node("Main/Margin/Layout/Columns/Information/Meta").hide()
	_takeaway.hide()
	var old_text := _scroll.get_child(0)
	_scroll.remove_child(old_text)
	_scroll.add_child(_interpretation)
	_interpretation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_interpretation.add_child(_period)
	_heading.reparent(_interpretation)
	_interpretation.add_child(_prompt)
	_body.reparent(_interpretation)
	_interpretation.add_child(_identity)
	old_text.queue_free()
	if not Engine.is_editor_hint():
		_scroll.gui_input.connect(_reading_input.bind(_scroll))
	if not Engine.is_editor_hint():
		_source_scroll.gui_input.connect(_reading_input.bind(_source_scroll))
	_scroll.add_theme_stylebox_override("focus", _close.get_theme_stylebox("focus"))
	_scroll.get_v_scroll_bar().changed.connect(_update_read_hint)
	_information.add_child(_read_hint)
	_read_hint.text = "SCROLL TO READ"
	_viewer.name = "TransformationViewer"
	_viewer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_viewer.size_flags_stretch_ratio = 0.65
	_information.size_flags_stretch_ratio = 0.35
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_child(_viewer)
	_presentation_root.get_node("Main/Margin/Layout/Columns").move_child(_viewer, 0)
	_viewer.add_child(_visual)
	_visual.name = "ActiveVisual"
	_visual.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_visual.clip_contents = true
	if not Engine.is_editor_hint():
		_visual.pressed.connect(_activate_visual)
	if not Engine.is_editor_hint():
		_visual.gui_input.connect(_visual_input)
	_image.reparent(_visual)
	_visual.add_child(_after)
	_visual.add_child(_storm)
	for control in [_image, _after, _storm]:
		control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		control.offset_left = 8
		control.offset_top = 8
		control.offset_right = -8
		control.offset_bottom = -8
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for picture in [_image, _after]:
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_viewer.add_child(_comparison_labels)
	_comparison_labels.add_child(_before_label)
	_comparison_labels.add_child(_after_label)
	_before_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_after_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_viewer.add_child(_comparison_row)
	_comparison_row.add_child(_comparison)
	_comparison.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not Engine.is_editor_hint():
		_comparison.value_changed.connect(set_comparison_position)
	_viewer.add_child(_footer)
	_footer.add_child(_details)
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details.add_child(_caption)
	_details.add_child(_hint)
	_footer.add_child(_overview)
	_overview.text = "OVERVIEW"
	_overview.flat = true
	_overview.custom_minimum_size = Vector2(112, 56)
	_overview.add_theme_font_size_override("font_size", 16)
	if not Engine.is_editor_hint():
		_overview.pressed.connect(select_stage.bind(StageState.OVERVIEW))
	layout.add_child(_ribbon)
	for i in _concepts.size():
		_concepts[i].reparent(_ribbon)
		if not Engine.is_editor_hint():
			_concepts[i].gui_input.connect(_selector_input.bind(i))
	for label in [_title, _subtitle, _heading, _prompt, _identity, _caption, _hint]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for label in [_period, _prompt, _identity, _before_label, _after_label]:
		label.add_theme_color_override("font_color", Color("d8c58b"))
	for label in [_subtitle, _caption, _hint, _read_hint]:
		label.add_theme_color_override("font_color", Color("c2bfae"))
	_source_close.custom_minimum_size.y = 56
	_source_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_presentation_root.add_child(_storm_audio)
	_storm_audio.name = "StormAmbience"
	_storm_audio.volume_db = -18.0

func open_interaction() -> bool:
	if Engine.is_editor_hint():
		return false
	if not is_node_ready() or not content is TransformationContent or content.concepts.size() != 3:
		return false
	for entry in [content.overview] + content.concepts:
		if not entry is StageEntry or entry.primary_texture == null:
			return false
		if entry.interaction in [StageEntry.Interaction.COMPARISON, StageEntry.Interaction.PHOTO_TOGGLE] and entry.secondary_texture == null:
			return false
	if content.narration_stream == null or content.storm_stream == null:
		return false
	if _open:
		return true
	current_stage = StageState.OVERVIEW
	comparison_position = 0.5
	museum_photo_index = 0
	# Duplicate only the stream Resource to enforce non-looping ambience locally.
	_storm_audio.stream = content.storm_stream.duplicate()
	if _storm_audio.stream is AudioStreamOggVorbis:
		_storm_audio.stream.loop = false
	if not super.open_interaction():
		return false
	reset_hotspot()
	modulate.a = 0.0
	_reveal = create_tween()
	_reveal.tween_property(self, "modulate:a", 1.0, 0.3)
	_reveal.tween_callback(func() -> void: _reveal = null)
	return true


func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_animations()
	_sources.hide()
	_source_scroll.scroll_vertical = 0
	stop_narration()
	current_stage = StageState.OVERVIEW
	comparison_position = 0.5
	museum_photo_index = 0
	_comparison.value = 0.5
	_render()
	if _open:
		_concepts[0].grab_focus()


func select_concept(index: int) -> void:
	if Engine.is_editor_hint():
		return
	if index >= 0 and index < 3:
		select_stage((index + 1) as StageState)


func get_selected_concept() -> int:
	return current_stage


func _entry() -> StageEntry:
	return content.overview if current_stage == StageState.OVERVIEW else content.concepts[current_stage - 1] as StageEntry


func select_stage(new_stage: StageState) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or new_stage < 0 or new_stage > StageState.MUSEUM_REBIRTH:
		return
	_cancel_stage_transition()
	_cancel_storm()
	_comparison.end_drag()
	current_stage = new_stage
	_update_selection()
	if current_stage == StageState.DAMAGE:
		_render()
		_start_storm()
		return
	active_stage_transition = create_tween().set_parallel(true)
	for control in [_visual, _interpretation, _details]:
		active_stage_transition.tween_property(control, "modulate:a", 0.0, 0.13)
	active_stage_transition.chain().tween_callback(_render)
	active_stage_transition.chain().tween_property(_visual, "modulate:a", 1.0, 0.20)
	active_stage_transition.parallel().tween_property(_interpretation, "modulate:a", 1.0, 0.20)
	active_stage_transition.parallel().tween_property(_details, "modulate:a", 1.0, 0.20)
	active_stage_transition.chain().tween_callback(func() -> void: active_stage_transition = null)
	concept_changed.emit(current_stage)


func _update_selection() -> void:
	for i in 3:
		var entry := content.concepts[i] as StageEntry
		_concepts[i].set_pressed_no_signal(current_stage == i + 1)
		_concepts[i].text = entry.compact_label if size.x < 900 else entry.selector_label
		_concepts[i].accessibility_name = entry.selector_label.replace("\n", " ")


func _render() -> void:
	var entry := _entry()
	_title.text = content.title
	_subtitle.text = content.prompt
	_period.text = entry.year
	_period.visible = not entry.year.is_empty()
	_heading.text = entry.heading
	_prompt.text = entry.prompt
	_prompt.visible = not entry.prompt.is_empty()
	_body.text = entry.body
	_body.visible = not storm_active
	_identity.text = entry.identity_label
	_identity.visible = not entry.identity_label.is_empty()
	_scroll.scroll_vertical = 0
	_update_selection()
	_apply_visual()
	_update_read_hint.call_deferred()


func _apply_visual() -> void:
	var entry := _entry()
	var comparing := entry.interaction == StageEntry.Interaction.COMPARISON
	_comparison.visible = comparing
	_comparison_row.visible = comparing
	_comparison_labels.visible = comparing
	_footer.visible = not comparing
	# Share the drag row with Overview so compact comparison keeps a large photo.
	var overview_parent: Node
	if comparing:
		overview_parent = _comparison_row
	else:
		overview_parent = _footer
	var hint_parent: Node
	if comparing:
		hint_parent = _comparison_labels
	else:
		hint_parent = _details
	if _overview.get_parent() != overview_parent:
		_overview.reparent(overview_parent)
	if _hint.get_parent() != hint_parent:
		_hint.reparent(hint_parent)
		if comparing:
			_comparison_labels.move_child(_hint, 1)
	_hint.custom_minimum_size.x = 128 if comparing else 0
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if comparing else HORIZONTAL_ALIGNMENT_LEFT
	_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL if comparing else Control.SIZE_FILL
	_comparison.value = comparison_position
	_comparison.accessibility_name = "Before and after restoration comparison. Left and Right adjust; Home shows Before; End shows After."
	_before_label.text = content.before_label
	_after_label.text = content.after_label
	_image.texture = entry.primary_texture
	_image.show()
	_after.texture = entry.secondary_texture if comparing else null
	_after.visible = comparing
	# Uniform contain framing; crossfade avoids implying precise façade alignment.
	_image.modulate.a = 1.0 - comparison_position if comparing else 1.0
	_after.modulate.a = comparison_position if comparing else 1.0
	_caption.text = entry.primary_caption
	_hint.text = entry.helper_text
	if current_stage == StageState.MUSEUM_REBIRTH and museum_photo_index == 1:
		_image.texture = entry.secondary_texture
		_caption.text = entry.secondary_caption
		_hint.text = entry.secondary_helper
	if storm_active:
		_image.hide()
		_caption.text = content.atmosphere_label
		_hint.text = content.storm_helper
	_caption.visible = not comparing and not _caption.text.is_empty()
	_hint.visible = not _hint.text.is_empty()
	_image.accessibility_name = _caption.text
	_visual.accessibility_name = content.storm_helper if storm_active else _caption.text
	_visual.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if storm_active or current_stage == StageState.MUSEUM_REBIRTH else Control.CURSOR_ARROW
	_sync_focus()


func _start_storm() -> void:
	if Engine.is_editor_hint():
		return
	storm_active = true
	_storm.start()
	_body.hide()
	_apply_visual()
	# Narration has priority. Suppressed ambience never starts halfway through.
	if not _audio.playing or _audio.stream_paused:
		_storm_audio.play(0.0)
	active_storm_tween = create_tween()
	active_storm_tween.tween_property(_storm, "darkness", 0.25, 0.4)
	active_storm_tween.tween_property(_storm, "intensity", 0.65, 0.7)
	active_storm_tween.tween_property(_storm, "flash", 0.12, 0.12)
	active_storm_tween.tween_property(_storm, "flash", 0.0, 0.22)
	active_storm_tween.tween_property(_storm, "intensity", 0.9, 0.66)
	active_storm_tween.tween_property(_storm, "intensity", 0.0, 0.6)
	active_storm_tween.parallel().tween_property(_storm, "darkness", 0.0, 0.6)
	active_storm_tween.tween_interval(0.3)
	active_storm_tween.tween_callback(_finish_storm)
	concept_changed.emit(current_stage)


func _cancel_storm() -> void:
	if Engine.is_editor_hint():
		return
	if active_storm_tween != null and active_storm_tween.is_valid():
		active_storm_tween.kill()
	active_storm_tween = null
	storm_active = false
	_storm.stop()
	_storm_audio.stop()
	_storm_audio.stream_paused = false


func _finish_storm() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_storm()
	if _open and current_stage == StageState.DAMAGE:
		_body.show()
		_apply_visual()


func _activate_visual() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible:
		return
	if storm_active:
		_finish_storm()
	elif current_stage == StageState.MUSEUM_REBIRTH:
		var pending := active_stage_transition != null
		_cancel_stage_transition()
		if pending:
			_render()
		museum_photo_index = 1 - museum_photo_index
		_apply_visual()
		_visual.modulate.a = 0.6
		active_stage_transition = create_tween()
		active_stage_transition.tween_property(_visual, "modulate:a", 1.0, 0.18)
		active_stage_transition.tween_callback(func() -> void: active_stage_transition = null)


func set_comparison_position(value: float) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or current_stage != StageState.RESTORATION:
		return
	if active_stage_transition != null:
		_cancel_stage_transition()
		_render()
	comparison_position = clampf(value, 0.0, 1.0)
	_comparison.value = comparison_position
	_image.modulate.a = 1.0 - comparison_position
	_after.modulate.a = comparison_position


func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible:
		return
	_cancel_stage_transition()
	_comparison.end_drag()
	_finish_storm()
	_render()
	_source_title.text = "Sources"
	_source_text.text = content.title + "\n\n" + content.source_credit + "\n\nCURRENT STAGE MEDIA\n" + _entry().media_credit
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()


func _sync_focus() -> void:
	if Engine.is_editor_hint():
		return
	var previous := get_viewport().gui_get_focus_owner()
	var main: Array[Control] = []
	main.append_array(_concepts)
	if current_stage == StageState.RESTORATION:
		main.append(_comparison)
	elif storm_active or current_stage == StageState.MUSEUM_REBIRTH:
		main.append(_visual)
	main.append_array([_overview, _scroll, _sources_button, _speaker, _close])
	var overlay: Array[Control] = [_source_scroll, _source_close]
	for control in main + overlay + [_visual, _comparison]:
		control.focus_mode = Control.FOCUS_NONE
	var active: Array[Control] = overlay if _sources.visible else main
	for i in active.size():
		active[i].focus_mode = Control.FOCUS_ALL
		active[i].focus_next = active[i].get_path_to(active[(i + 1) % active.size()])
		active[i].focus_previous = active[i].get_path_to(active[posmod(i - 1, active.size())])
	if previous in active:
		previous.grab_focus()
	elif not _sources.visible and (previous == _visual or previous == _comparison):
		_overview.grab_focus()


func _visual_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_SPACE]:
		get_viewport().set_input_as_handled()
		if not event.echo:
			_activate_visual()


func toggle_narration() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or _audio.stream == null:
		return
	if _audio.stream_paused:
		_audio.stream_paused = false
	elif _audio.playing:
		_audio.stream_paused = true
	else:
		_audio.play(0.0)
		narration_started.emit()
	if _audio.playing and not _audio.stream_paused:
		_storm_audio.stop()
	_update_speaker()


func _resize_layout() -> void:
	if Engine.is_editor_hint():
		EditorPresentation.resize(self, _presentation_root)
	if not is_node_ready():
		return
	var compact := size.x < 1100
	var inset := 0.02 if compact else 0.05
	var main: PanelContainer = _presentation_root.get_node("Main")
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		main.set_anchor(side, inset if side in [SIDE_LEFT, SIDE_TOP] else 1.0 - inset, true)
		main.set_offset(side, 0.0)
	var layout := _presentation_root.get_node("Main/Margin/Layout")
	var subtitle_parent: Node = layout if compact else _titles
	if _subtitle.get_parent() != subtitle_parent:
		_subtitle.reparent(subtitle_parent)
		if compact:
			layout.move_child(_subtitle, 1)
	for side in ["left", "top", "right", "bottom"]:
		_presentation_root.get_node("Main/Margin").add_theme_constant_override("margin_" + side, 8 if compact else 16)
	layout.add_theme_constant_override("separation", 8 if compact else 12)
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_theme_constant_override("separation", 16 if compact else 24)
	_interpretation.add_theme_constant_override("separation", 10 if compact else 14)
	_ribbon.add_theme_constant_override("separation", 8)
	_title.add_theme_font_size_override("font_size", 20 if compact else 26)
	_subtitle.add_theme_font_size_override("font_size", 18)
	_heading.add_theme_font_size_override("font_size", 21 if compact else 26)
	_body.add_theme_font_size_override("font_size", 18 if compact else 20)
	for label in [_period, _prompt, _identity, _caption]:
		label.add_theme_font_size_override("font_size", 16 if compact else 18)
	for label in [_hint, _before_label, _after_label, _read_hint]:
		label.add_theme_font_size_override("font_size", 14 if compact else 16)
	_source_text.add_theme_font_size_override("font_size", 18 if compact else 22)
	for button in _concepts:
		button.custom_minimum_size.y = 56 if compact else 64
		button.add_theme_font_size_override("font_size", 18 if compact else 20)
	if content is TransformationContent:
		_update_selection()
		_apply_visual()


func _cancel_stage_transition() -> void:
	if Engine.is_editor_hint():
		return
	if active_stage_transition != null and active_stage_transition.is_valid():
		active_stage_transition.kill()
	active_stage_transition = null
	for control in [_visual, _interpretation, _details]:
		control.modulate.a = 1.0


func _cancel_animations() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_stage_transition()
	_cancel_storm()
	_comparison.end_drag()
	_cancel_fade()
	if _reveal != null and _reveal.is_valid():
		_reveal.kill()
	_reveal = null
	modulate.a = 1.0
	_viewer.modulate.a = 1.0
	if is_instance_valid(_image):
		_image.scale = Vector2.ONE
		_image.modulate.a = 1.0
	_after.modulate.a = 1.0
	_after.hide()


func _open_standalone() -> void:
	if Engine.is_editor_hint():
		return
	if get_tree().current_scene == self:
		open_hotspot()


func open_hotspot() -> bool:
	if Engine.is_editor_hint():
		return false
	return open_interaction()


func _selector_input(event: InputEvent, index: int) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or not event is InputEventKey or not event.pressed:
		return
	if event.keycode in [KEY_LEFT, KEY_RIGHT]:
		get_viewport().set_input_as_handled()
		_concepts[posmod(index + (-1 if event.keycode == KEY_LEFT else 1), 3)].grab_focus()
	elif event.keycode in [KEY_ENTER, KEY_SPACE]:
		get_viewport().set_input_as_handled()
		if not event.echo:
			select_concept(index)


func _reading_input(event: InputEvent, scroller: ScrollContainer) -> void:
	if Engine.is_editor_hint():
		return
	# Handle native touch drags independently of desktop mouse emulation.
	# Accepting the event prevents the container from applying the motion twice.
	if event is InputEventScreenDrag:
		scroller.scroll_vertical -= int(event.relative.y)
		scroller.accept_event()
		return
	if event is InputEventKey and event.pressed and event.keycode in [KEY_UP, KEY_DOWN, KEY_PAGEUP, KEY_PAGEDOWN, KEY_HOME, KEY_END]:
		get_viewport().set_input_as_handled()
		match event.keycode:
			KEY_HOME: scroller.scroll_vertical = 0
			KEY_END: scroller.scroll_vertical = int(scroller.get_v_scroll_bar().max_value)
			_: scroller.scroll_vertical += (-1 if event.keycode in [KEY_UP, KEY_PAGEUP] else 1) * (40 if event.keycode in [KEY_UP, KEY_DOWN] else int(scroller.size.y))


func _update_read_hint() -> void:
	var bar := _scroll.get_v_scroll_bar()
	_read_hint.visible = bar.max_value > bar.page + 1


func _update_speaker() -> void:
	if Engine.is_editor_hint():
		return
	super._update_speaker()
	_speaker.text = "RESUME" if _audio.stream_paused else ("PAUSE" if _audio.playing else "LISTEN")
	_speaker.set_pressed_no_signal(_audio.playing and not _audio.stream_paused)
	_speaker.accessibility_name = _speaker.text.capitalize() + " narration"
	_speaker.tooltip_text = _speaker.accessibility_name


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
	_cancel_animations()
	# Shared lifecycle stops audio, hides Sources, restores focus, then emits closed.
	super.close_interaction()


func _visibility_changed() -> void:
	if Engine.is_editor_hint():
		return
	if _open and not is_visible_in_tree():
		close_interaction()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_animations()
	super._exit_tree()

func close_sources() -> void:
	if not Engine.is_editor_hint():
		super.close_sources()

func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		super._unhandled_input(event)

func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready() or content == null:
		return
	_presentation_root = EditorPresentation.begin(self)
	_build_presentation()
	current_stage = StageState.OVERVIEW
	comparison_position = 0.5
	museum_photo_index = 0
	storm_active = false
	_storm.hide()
	_render()
	EditorPresentation.finish(self, _presentation_root)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
