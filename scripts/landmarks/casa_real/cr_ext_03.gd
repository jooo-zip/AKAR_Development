@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/casa_real/cr_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview

## Three historical chapters. The inherited legacy _selected field is unused.
enum RoleState { OVERVIEW, GOVERNMENT_CENTER, PUBLIC_SERVICE, HERITAGE_MUSEUM }
const RoleEntry = preload("res://scripts/landmarks/casa_real/cr_ext_03_role.gd")
const RoleContent = preload("res://scripts/landmarks/casa_real/cr_ext_03_content.gd")

var current_role: RoleState = RoleState.OVERVIEW
var current_photo_index: int = 0
var active_role_transition: Tween
var active_photo_transition: Tween
var _reveal: Tween
var _subtitle: Label
var _period: Label
var _tagline: Label
var _caption: Label
var _hint: Label
var _counter: Label
var _read_hint: Label
var _overview: Button
var _viewer: VBoxContainer
var _photo_frame: Button
var _photo_visual: VBoxContainer
var _photo_details: VBoxContainer
var _interpretation: VBoxContainer
var _milestones: HBoxContainer
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
	_tagline = Label.new()
	_caption = Label.new()
	_hint = Label.new()
	_counter = Label.new()
	_read_hint = Label.new()
	_overview = Button.new()
	_viewer = VBoxContainer.new()
	_photo_frame = Button.new()
	_photo_visual = VBoxContainer.new()
	_photo_details = VBoxContainer.new()
	_interpretation = VBoxContainer.new()
	_milestones = HBoxContainer.new()
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
	# Keep only the interpretation scrollable; the image and controls stay visible.
	var old_text := _scroll.get_child(0)
	_scroll.remove_child(old_text)
	_scroll.add_child(_interpretation)
	_interpretation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_interpretation.add_child(_period)
	_heading.reparent(_interpretation)
	_interpretation.add_child(_tagline)
	_body.reparent(_interpretation)
	old_text.queue_free()
	if not Engine.is_editor_hint():
		_scroll.gui_input.connect(_reading_input.bind(_scroll))
	if not Engine.is_editor_hint():
		_source_scroll.gui_input.connect(_reading_input.bind(_source_scroll))
	_scroll.add_theme_stylebox_override("focus", _close.get_theme_stylebox("focus"))
	_scroll.get_v_scroll_bar().changed.connect(_update_read_hint)
	_information.add_child(_read_hint)
	_read_hint.text = "SCROLL TO READ"
	_overview.text = "OVERVIEW"
	_overview.flat = true
	_overview.custom_minimum_size = Vector2(120, 56)
	_overview.add_theme_font_size_override("font_size", 16)
	if not Engine.is_editor_hint():
		_overview.pressed.connect(select_role.bind(RoleState.OVERVIEW))
	_viewer.name = "DocumentaryViewer"
	_viewer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_viewer.size_flags_stretch_ratio = 0.64
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_child(_viewer)
	_presentation_root.get_node("Main/Margin/Layout/Columns").move_child(_viewer, 0)
	_information.size_flags_stretch_ratio = 0.36
	_viewer.add_child(_photo_frame)
	_photo_frame.name = "PhotoFrame"
	_photo_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if not Engine.is_editor_hint():
		_photo_frame.pressed.connect(show_next_photo)
	if not Engine.is_editor_hint():
		_photo_frame.gui_input.connect(_photo_input)
	_photo_frame.add_child(_photo_visual)
	_photo_visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_photo_visual.offset_left = 8
	_photo_visual.offset_top = 8
	_photo_visual.offset_right = -8
	_photo_visual.offset_bottom = -8
	_image.reparent(_photo_visual)
	_image.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var photo_footer := HBoxContainer.new()
	_viewer.add_child(photo_footer)
	photo_footer.add_child(_photo_details)
	_photo_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_photo_details.add_child(_caption)
	photo_footer.add_child(_overview)
	var footer := HBoxContainer.new()
	_photo_details.add_child(footer)
	footer.add_child(_hint)
	_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(_counter)
	for control in [_photo_visual, footer, _image, _caption, _hint, _counter]:
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(_milestones)
	layout.add_child(_ribbon)
	for i in _concepts.size():
		_concepts[i].reparent(_ribbon)
		if not Engine.is_editor_hint():
			_concepts[i].gui_input.connect(_selector_input.bind(i))
	for label in [_title, _subtitle, _heading, _tagline, _caption]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for label in [_period, _tagline, _counter]:
		label.add_theme_color_override("font_color", Color("d37148"))
	for label in [_subtitle, _caption, _hint, _read_hint]:
		label.add_theme_color_override("font_color", Color("d6c5ab"))
	_source_close.custom_minimum_size.y = 56
	_source_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

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
	if not is_node_ready() or not content is RoleContent or content.concepts.size() != 3:
		return false
	for entry in [content.overview] + content.concepts:
		if not entry is RoleEntry or entry.photos.is_empty() or entry.milestone_dates.size() != entry.milestone_labels.size():
			return false
		for photo in entry.photos:
			if photo == null or photo.texture == null:
				return false
	if _open:
		return true
	current_role = RoleState.OVERVIEW
	current_photo_index = 0
	if not super.open_interaction():
		return false
	reset_hotspot()
	modulate.a = 0.0
	_viewer.modulate.a = 0.0
	_reveal = create_tween().set_parallel(true)
	_reveal.tween_property(self, "modulate:a", 1.0, 0.22)
	_reveal.tween_property(_viewer, "modulate:a", 1.0, 0.30).set_delay(0.15)
	_reveal.chain().tween_callback(func() -> void: _reveal = null)
	return true


func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_animations()
	_sources.hide()
	_source_scroll.scroll_vertical = 0
	stop_narration()
	current_role = RoleState.OVERVIEW
	current_photo_index = 0
	_render()
	if _open:
		_concepts[0].grab_focus()


func select_concept(index: int) -> void:
	if Engine.is_editor_hint():
		return
	if index >= 0 and index < 3:
		select_role((index + 1) as RoleState)


func get_selected_concept() -> int:
	return current_role


func select_role(new_role: RoleState) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or new_role < 0 or new_role > RoleState.HERITAGE_MUSEUM:
		return
	_cancel_transitions()
	current_role = new_role
	current_photo_index = 0
	_update_selection()
	active_role_transition = create_tween().set_parallel(true)
	for control in [_interpretation, _photo_visual, _photo_details, _milestones]:
		active_role_transition.tween_property(control, "modulate:a", 0.0, 0.14)
	active_role_transition.chain().tween_callback(_render)
	active_role_transition.chain().tween_property(_interpretation, "modulate:a", 1.0, 0.21)
	active_role_transition.parallel().tween_property(_photo_visual, "modulate:a", 1.0, 0.21)
	active_role_transition.parallel().tween_property(_photo_details, "modulate:a", 1.0, 0.21)
	active_role_transition.parallel().tween_property(_milestones, "modulate:a", 1.0, 0.21)
	active_role_transition.chain().tween_callback(func() -> void: active_role_transition = null)
	concept_changed.emit(current_role)


func _entry() -> RoleEntry:
	return content.overview if current_role == RoleState.OVERVIEW else content.concepts[current_role - 1] as RoleEntry


func _update_selection() -> void:
	for i in _concepts.size():
		var entry := content.concepts[i] as RoleEntry
		_concepts[i].set_pressed_no_signal(current_role == i + 1)
		_concepts[i].text = entry.compact_label if size.x < 900 else entry.selector_label
		_concepts[i].accessibility_name = entry.selector_label.replace("\n", " ")


func _render() -> void:
	var entry := _entry()
	_title.text = content.title
	_subtitle.text = content.prompt
	_period.text = entry.period
	_period.visible = not entry.period.is_empty()
	_heading.text = entry.heading
	_tagline.text = entry.tagline
	_body.text = entry.body
	_scroll.scroll_vertical = 0
	_update_selection()
	_render_milestones()
	_render_photo()
	_update_read_hint.call_deferred()


func _render_milestones() -> void:
	for child in _milestones.get_children():
		_milestones.remove_child(child)
		child.queue_free()
	var entry := _entry()
	# Read packed arrays through Resource properties; safe for editor placeholders too.
	var dates: PackedStringArray = entry.get("milestone_dates")
	var labels: PackedStringArray = entry.get("milestone_labels")
	_milestones.visible = not dates.is_empty()
	for i in dates.size():
		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = dates[i]
		if size.x >= 1100:
			label.text += "\n" + labels[i]
		label.accessibility_name = dates[i] + ": " + labels[i]
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color("d37148"))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_milestones.add_child(label)


func show_photo(index: int) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or _entry().photos.size() <= 1:
		return
	# A photo tap can arrive during a role fade; settle that role before cycling.
	var role_pending := active_role_transition != null
	_cancel_transitions()
	if role_pending:
		_render()
	current_photo_index = posmod(index, _entry().photos.size())
	active_photo_transition = create_tween()
	active_photo_transition.tween_property(_photo_visual, "modulate:a", 0.0, 0.12)
	active_photo_transition.parallel().tween_property(_photo_details, "modulate:a", 0.0, 0.12)
	active_photo_transition.tween_callback(_render_photo)
	active_photo_transition.tween_property(_photo_visual, "modulate:a", 1.0, 0.16)
	active_photo_transition.parallel().tween_property(_photo_details, "modulate:a", 1.0, 0.16)
	active_photo_transition.tween_callback(func() -> void: active_photo_transition = null)


func show_next_photo() -> void:
	if Engine.is_editor_hint():
		return
	show_photo(current_photo_index + 1)


func show_previous_photo() -> void:
	if Engine.is_editor_hint():
		return
	show_photo(current_photo_index - 1)


func _render_photo() -> void:
	var entry := _entry()
	var photo = entry.photos[current_photo_index]
	_image.texture = photo.texture
	_image.accessibility_name = photo.caption
	_caption.text = photo.caption
	_counter.text = "%d / %d" % [current_photo_index + 1, entry.photos.size()]
	_counter.visible = entry.photos.size() > 1
	_hint.text = "TAP FOR NEXT PHOTO" if size.x < 900 else "CLICK OR TAP PHOTO TO VIEW NEXT"
	_hint.visible = entry.photos.size() > 1
	_photo_frame.accessibility_name = photo.caption + (". Next photo" if entry.photos.size() > 1 else "")
	_photo_frame.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if entry.photos.size() > 1 else Control.CURSOR_ARROW
	_sync_focus()


func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible:
		return
	var role_pending := active_role_transition != null
	_cancel_transitions()
	if role_pending:
		_render()
	else:
		_render_photo()
	var photo = _entry().photos[current_photo_index]
	_source_title.text = "Sources"
	_source_text.text = content.title + "\n\n" + content.source_credit + "\n\nCURRENT DOCUMENTARY PHOTO\n" + photo.caption + "\n" + photo.source_label + "\nPermission / license: " + photo.permission
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
	main.append(_overview)
	if _entry().photos.size() > 1:
		main.append(_photo_frame)
	main.append_array([_scroll, _sources_button, _speaker, _close])
	var overlay: Array[Control] = [_source_scroll, _source_close]
	for control in main + overlay + [_photo_frame]:
		control.focus_mode = Control.FOCUS_NONE
	var active: Array[Control] = overlay if _sources.visible else main
	for i in active.size():
		active[i].focus_mode = Control.FOCUS_ALL
		active[i].focus_next = active[i].get_path_to(active[(i + 1) % active.size()])
		active[i].focus_previous = active[i].get_path_to(active[posmod(i - 1, active.size())])
	if previous in active:
		previous.grab_focus()


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


func _photo_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or not event is InputEventKey or not event.pressed:
		return
	if event.keycode in [KEY_LEFT, KEY_RIGHT, KEY_ENTER, KEY_SPACE]:
		get_viewport().set_input_as_handled()
		if not event.echo:
			show_photo(current_photo_index + (-1 if event.keycode == KEY_LEFT else 1))


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
	_update_speaker()


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
	_milestones.add_theme_constant_override("separation", 10)
	_title.add_theme_font_size_override("font_size", 20 if compact else 26)
	_subtitle.add_theme_font_size_override("font_size", 18)
	_heading.add_theme_font_size_override("font_size", 21 if compact else 26)
	_body.add_theme_font_size_override("font_size", 18 if compact else 20)
	for label in [_period, _tagline, _caption]:
		label.add_theme_font_size_override("font_size", 16 if compact else 18)
	for label in [_hint, _counter, _read_hint]:
		label.add_theme_font_size_override("font_size", 14 if compact else 16)
	_source_text.add_theme_font_size_override("font_size", 18 if compact else 22)
	for button in _concepts:
		button.custom_minimum_size.y = 56 if compact else 64
		button.add_theme_font_size_override("font_size", 18 if compact else 20)
	if content is RoleContent:
		_update_selection()
		_render_milestones()
		_render_photo()


func _cancel_transitions() -> void:
	if Engine.is_editor_hint():
		return
	for tween in [active_role_transition, active_photo_transition]:
		if tween != null and tween.is_valid():
			tween.kill()
	active_role_transition = null
	active_photo_transition = null
	for control in [_interpretation, _photo_visual, _photo_details, _milestones]:
		control.modulate.a = 1.0


func _cancel_animations() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_transitions()
	_cancel_fade()
	if _reveal != null and _reveal.is_valid():
		_reveal.kill()
	_reveal = null
	modulate.a = 1.0
	_viewer.modulate.a = 1.0
	if is_instance_valid(_image):
		_image.modulate.a = 1.0
		_image.scale = Vector2.ONE


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
	current_role = RoleState.OVERVIEW
	current_photo_index = 0
	_render()
	EditorPresentation.finish(self, _presentation_root)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
