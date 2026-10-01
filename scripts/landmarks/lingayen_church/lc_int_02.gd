extends ConferenceRoomInteraction

const HeaderUtilities = preload("res://scripts/landmarks/lingayen_church/lc_header_utilities.gd")
var _header_utilities: RefCounted
## Timeline-led historical interpretation. Animation presents, never owns, state.

signal close_requested
signal milestone_selected(milestone_id: StringName)

enum TimelineState { NONE, EARLY_MISSION, TRANSITION_1898, CATHEDRAL_1928, COLUMBAN_1933, WARTIME_1945, CO_CATHEDRAL_1954, ARCHDIOCESE_1963, LEADERSHIP_1981 }
enum HistoricalEra { NONE, MISSIONARY_FOUNDATIONS, CATHEDRAL_DEVELOPMENT, WAR_AND_CHANGE, CONTINUING_LEADERSHIP }
enum MediaMode { DOCUMENTARY_PHOTO, CONTEXTUAL_PORTRAIT, TRANSFORMATION_ONLY }

const ERA_IDS := [&"missionary_foundations", &"cathedral_development", &"war_and_change", &"continuing_leadership"]
const ERA_NAMES := ["MISSIONARY FOUNDATIONS", "CATHEDRAL DEVELOPMENT", "WAR & INSTITUTIONAL CHANGE", "CONTINUING LEADERSHIP"]
const SECONDARY := Color("c2bfab")
const GOLD := Color("dec787")

## Local host opt-out, not a new global accessibility setting.
@export var animate_reveals: bool = true

var selected_timeline_state: TimelineState = TimelineState.NONE
var _reveal: Tween
var _panel_tween: Tween
var _closing: bool = false
var _subtitle := Label.new()
var _pending := Label.new()
var _prompt := Label.new()
var _time_window := VBoxContainer.new()
var _stage := Control.new()
var _stage_background := Panel.new()
var _outgoing := TextureRect.new()
var _missing := Label.new()
var _diagram := VBoxContainer.new()
var _transform_labels: Array[Label] = []
var _connectors: Array[Control] = []
var _caption := Label.new()
var _credit := Label.new()
var _date := Label.new()
var _era := Label.new()
var _source_basis := Label.new()
var _note := VBoxContainer.new()
var _note_title := Label.new()
var _note_body := Label.new()
var _era_strip := HBoxContainer.new()
var _era_panels: Array[PanelContainer] = []
var _era_labels: Array[Label] = []
var _ribbon := Control.new()
var _ribbon_line := Line2D.new()
var _points_row := HBoxContainer.new()
var _points: Array[LCINT02TimelinePoint] = []


func _ready() -> void:
	super._ready()
	_build_header()
	_build_time_window()
	_build_interpretation()
	_build_chronology()
	_scroll.gui_input.connect(_reading_input.bind(_scroll))
	_source_scroll.gui_input.connect(_reading_input.bind(_source_scroll))
	_header_utilities = HeaderUtilities.new(self, _pending)
	add_to_group("lingayen_church_narration")
	resized.connect(_resize_layout)
	_stage.resized.connect(_layout_visual)
	_ribbon.resized.connect(_layout_ribbon)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_open_standalone.call_deferred()


func _style_label(label: Label, font_size: int, secondary: bool = false) -> void:
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("line_spacing", 0)
	if secondary:
		label.add_theme_color_override("font_color", SECONDARY)


func _build_header() -> void:
	var header := $Main/Margin/Layout/Header
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	header.move_child(titles, 0)
	_title.reparent(titles)
	_style_label(_title, 28)
	titles.add_child(_subtitle)
	_style_label(_subtitle, 18, true)
	var listen_group := VBoxContainer.new()
	header.add_child(listen_group)
	header.move_child(listen_group, 1)
	_speaker.reparent(listen_group)
	_speaker.custom_minimum_size = Vector2(136, 56)
	_pending.text = "Narration pending."
	_style_label(_pending, 16, true)
	_pending.autowrap_mode = TextServer.AUTOWRAP_OFF
	listen_group.add_child(_pending)
	_close.custom_minimum_size = Vector2(80, 56)
	_close.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	header.add_theme_constant_override("separation", 12)
	$Main/Margin/Layout/Controls.hide()
	_style_label(_prompt, 18, true)
	$Main/Margin/Layout.add_child(_prompt)
	$Main/Margin/Layout.move_child(_prompt, 1)


func _build_time_window() -> void:
	_time_window.name = "TimeWindow"
	_time_window.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_time_window.size_flags_stretch_ratio = 0.6
	_information.size_flags_stretch_ratio = 0.4
	%Columns.add_child(_time_window)
	%Columns.move_child(_time_window, 0)
	_stage.name = "VisualStage"
	_stage.clip_contents = true
	_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_time_window.add_child(_stage)
	_stage.add_child(_stage_background)
	_stage_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stage_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var stage_style := StyleBoxFlat.new()
	stage_style.bg_color = Color("12231e")
	stage_style.border_color = Color("645c42")
	stage_style.set_border_width_all(1)
	_stage_background.add_theme_stylebox_override("panel", stage_style)
	_image.reparent(_stage)
	_stage.add_child(_outgoing)
	for picture in [_image, _outgoing]:
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_missing)
	_style_label(_missing, 16, true)
	_missing.text = "DOCUMENTARY IMAGE\nSOURCE UNAVAILABLE"
	_missing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_missing.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_stage.add_child(_diagram)
	_diagram.alignment = BoxContainer.ALIGNMENT_CENTER
	_diagram.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in 3:
		if i > 0:
			var connector_space := Control.new()
			connector_space.custom_minimum_size.y = 20
			connector_space.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_diagram.add_child(connector_space)
			var connector := Control.new()
			connector.mouse_filter = Control.MOUSE_FILTER_IGNORE
			connector.draw.connect(_draw_connector.bind(connector, i - 1))
			connector.resized.connect(connector.queue_redraw)
			# Animate a child so the VBox cannot reset the drawing's reveal scale.
			connector_space.add_child(connector)
			connector.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			_connectors.append(connector)
		var label := Label.new()
		_style_label(label, 22)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", SECONDARY if i == 0 else GOLD)
		_diagram.add_child(label)
		_transform_labels.append(label)
	_time_window.add_child(_caption)
	_time_window.add_child(_credit)
	_style_label(_caption, 15, true)
	_style_label(_credit, 13, true)
	_outgoing.hide()


func _build_interpretation() -> void:
	var text := _body.get_parent()
	_heading.reparent(text)
	text.move_child(_heading, 0)
	var date_era := HBoxContainer.new()
	date_era.add_theme_constant_override("separation", 12)
	text.add_child(date_era)
	text.move_child(date_era, 0)
	date_era.add_child(_date)
	date_era.add_child(_era)
	_era.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_era.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	$Main/Margin/Layout/Columns/Information/Meta.hide()
	_style_label(_era, 15, true)
	_style_label(_date, 28)
	_date.autowrap_mode = TextServer.AUTOWRAP_OFF
	_date.add_theme_color_override("font_color", GOLD)
	_style_label(_heading, 23)
	_style_label(_body, 18)
	text.add_child(_source_basis)
	_style_label(_source_basis, 14, true)
	text.add_child(_note)
	_note.add_child(_note_title)
	_note.add_child(_note_body)
	_style_label(_note_title, 15, true)
	_style_label(_note_body, 16, true)
	_note.add_theme_constant_override("separation", 3)
	_scroll.accessibility_name = "Historical interpretation. Scroll to read details."
	_source_close.custom_minimum_size.y = 56


func _build_chronology() -> void:
	var old_sections := $Main/Margin/Layout/Sections
	old_sections.get_parent().remove_child(old_sections)
	old_sections.queue_free()
	_concepts.clear()
	_era_strip.name = "HistoricalEras"
	_era_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_era_strip.add_theme_constant_override("separation", 4)
	$Main/Margin/Layout.add_child(_era_strip)
	for era_name in ERA_NAMES:
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_era_strip.add_child(panel)
		var label := Label.new()
		_style_label(label, 14, true)
		label.text = era_name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		panel.add_child(label)
		_era_panels.append(panel)
		_era_labels.append(label)
	_ribbon.custom_minimum_size.y = 56
	_ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Main/Margin/Layout.add_child(_ribbon)
	_ribbon.add_child(_ribbon_line)
	_ribbon_line.width = 1
	_ribbon_line.default_color = Color("646a58")
	_ribbon.add_child(_points_row)
	_points_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_points_row.add_theme_constant_override("separation", 0)
	for i in 8:
		var point := LCINT02TimelinePoint.new()
		_points_row.add_child(point)
		_points.append(point)
		_concepts.append(point)
		point.pressed.connect(set_timeline_state.bind(i + 1))
		point.gui_input.connect(_point_input.bind(i))
	_takeaway.reparent($Main/Margin/Layout)
	_takeaway.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_label(_takeaway, 16, true)


func _entry() -> LCINT02MilestoneContent:
	if selected_timeline_state == TimelineState.NONE:
		return null
	return (content as LCINT02Content).milestones[selected_timeline_state - 1]


func get_active_era() -> HistoricalEra:
	return HistoricalEra.NONE if _entry() == null else (ERA_IDS.find(_entry().era_id) + 1) as HistoricalEra


func get_media_mode() -> MediaMode:
	if _entry() == null or _entry().media_mode == &"DOCUMENTARY_PHOTO":
		return MediaMode.DOCUMENTARY_PHOTO
	return MediaMode.CONTEXTUAL_PORTRAIT if _entry().media_mode == &"CONTEXTUAL_PORTRAIT" else MediaMode.TRANSFORMATION_ONLY


func _open_standalone() -> void:
	if get_tree().current_scene == self:
		open_hotspot()


func open_hotspot() -> bool:
	return open_interaction()


func open_interaction() -> bool:
	if not is_node_ready() or not content is LCINT02Content:
		return false
	var history := content as LCINT02Content
	if history.milestones.size() != 8 or history.milestones.has(null):
		return false
	if _open and not _closing:
		return true
	if not _open:
		var previous := get_viewport().gui_get_focus_owner()
		_return_focus = weakref(previous) if previous != null else null
	_open = true
	show()
	reset_hotspot()
	opened.emit()
	return true


func reset_hotspot() -> void:
	_cancel_panel_tween()
	_closing = false
	_sources.hide()
	stop_narration()
	set_timeline_state(TimelineState.NONE)
	cancel_active_reveal()
	if _open:
		_sync_focus()
		_points[0].grab_focus()


func set_timeline_state(state: TimelineState) -> void:
	if not is_node_ready() or not content is LCINT02Content or _closing or _sources.visible:
		return
	var history := content as LCINT02Content
	if history.milestones.size() != 8 or history.milestones.has(null):
		return
	cancel_active_reveal()
	var previous_texture := _image.texture
	var previous_rect := Rect2(_image.position, _image.size)
	selected_timeline_state = state if state >= TimelineState.NONE and state <= TimelineState.LEADERSHIP_1981 else TimelineState.NONE
	var entry := _entry()
	_title.text = history.title.to_upper()
	_subtitle.text = history.subtitle
	_prompt.text = history.prompt
	_takeaway.text = history.takeaway
	_era.text = entry.era_display if entry != null else ""
	_date.text = entry.date_display if entry != null else ""
	_heading.text = entry.title if entry != null else history.overview_heading
	_body.text = entry.explanation if entry != null else history.overview_body
	_source_basis.text = "Source: " + entry.source_basis if entry != null else ""
	_note.visible = entry != null and entry.show_historical_note
	_note_title.text = entry.historical_note_title if _note.visible else ""
	_note_body.text = entry.historical_note_body if _note.visible else ""
	for label in [_date, _era, _source_basis]:
		label.visible = not label.text.is_empty()
	_diagram.visible = entry != null
	for i in 3:
		_transform_labels[i].text = [entry.context_label, entry.change_label, entry.result_label][i] if entry != null else ""
		_transform_labels[i].visible = not _transform_labels[i].text.is_empty()
	_connectors[0].visible = entry != null
	_connectors[1].visible = entry != null and not entry.result_label.is_empty()
	for connector in _connectors:
		connector.get_parent().visible = connector.visible
		connector.queue_redraw()
	var media_mode := get_media_mode()
	_image.texture = history.overview_media if entry == null else (entry.media if media_mode != MediaMode.TRANSFORMATION_ONLY else null)
	_image.visible = media_mode != MediaMode.TRANSFORMATION_ONLY and _image.texture != null
	_image.accessibility_name = history.overview_heading if entry == null else entry.media_caption
	_missing.visible = media_mode != MediaMode.TRANSFORMATION_ONLY and _image.texture == null
	_caption.text = entry.media_caption if entry != null and media_mode != MediaMode.TRANSFORMATION_ONLY else ""
	_credit.text = history.overview_media_credit if entry == null else (entry.media_credit if media_mode != MediaMode.TRANSFORMATION_ONLY else "")
	_caption.visible = not _caption.text.is_empty()
	_credit.visible = not _credit.text.is_empty()
	for i in 8:
		_points[i].configure(history.milestones[i].year_short, history.milestones[i].title)
		_points[i].apply_selection(selected_timeline_state == i + 1)
	for i in 4:
		var active := get_active_era() == i + 1
		var style := StyleBoxFlat.new()
		style.bg_color = Color("303626") if active else Color("14211c")
		style.border_color = GOLD if active else Color("414b3e")
		style.set_border_width_all(1)
		style.content_margin_top = 3
		style.content_margin_bottom = 3
		_era_panels[i].add_theme_stylebox_override("panel", style)
		_era_labels[i].add_theme_color_override("font_color", GOLD if active else SECONDARY)
		_era_labels[i].accessibility_name = ERA_NAMES[i] + (", active era" if active else "")
	HeaderUtilities.bind_narration(self, content.narration_stream)
	_update_speaker()
	_scroll.scroll_vertical = 0
	_resize_layout()
	if _open:
		_sync_focus()
	if entry != null and _open and animate_reveals:
		# Only real incoming media can crossfade. Intentional text-only states clear it.
		if _image.visible and previous_texture != null and previous_texture != _image.texture:
			_outgoing.texture = previous_texture
			_outgoing.position = previous_rect.position
			_outgoing.size = previous_rect.size
			_outgoing.show()
		play_transformation_reveal()
	if entry != null:
		milestone_selected.emit(entry.milestone_id)


func play_transformation_reveal() -> void:
	# All text/visibility/state is already final. Only presentation values animate.
	_reveal = create_tween().set_parallel(true)
	var point := _points[selected_timeline_state - 1]
	point.dot.modulate.a = 0.65
	_reveal.tween_property(point.dot, "modulate:a", 1.0, 0.12)
	var era_panel := _era_panels[get_active_era() - 1]
	era_panel.modulate.a = 0.65
	_reveal.tween_property(era_panel, "modulate:a", 1.0, 0.15)
	_fade_in(_transform_labels[0], 0.0, 0.14)
	_reveal_connector(_connectors[0], 0.14, 0.30 if _entry().result_label.is_empty() else 0.20)
	_fade_in(_transform_labels[1], 0.44 if _entry().result_label.is_empty() else 0.34, 0.18)
	if not _entry().result_label.is_empty():
		_reveal_connector(_connectors[1], 0.52, 0.12)
		_fade_in(_transform_labels[2], 0.64, 0.18)
	if _image.visible:
		_fade_in(_image, 0.62 if get_media_mode() == MediaMode.CONTEXTUAL_PORTRAIT else 0.0, 0.20)
	if _outgoing.visible:
		_reveal.tween_property(_outgoing, "modulate:a", 0.0, 0.20)
	_fade_in(_body, 0.78, 0.16)
	_fade_in(_source_basis, 0.78, 0.16)
	if _note.visible:
		_fade_in(_note, 0.84, 0.16)
	_reveal.chain().tween_callback(_settle_reveal)


func _fade_in(control: Control, delay: float, duration: float) -> void:
	control.modulate.a = 0.0
	_reveal.tween_property(control, "modulate:a", 1.0, duration).set_delay(delay)


func _reveal_connector(connector: Control, delay: float, duration: float) -> void:
	connector.scale.y = 0.0
	_reveal.tween_property(connector, "scale:y", 1.0, duration).set_delay(delay)


func cancel_active_reveal() -> void:
	if _reveal != null and _reveal.is_valid():
		_reveal.kill()
	_reveal = null
	_settle_reveal()


func _settle_reveal() -> void:
	for control in _transform_labels + [_image, _body, _source_basis, _note]:
		control.modulate.a = 1.0
	for connector in _connectors:
		connector.scale = Vector2.ONE
	for point in _points:
		point.dot.modulate.a = 1.0
	for panel in _era_panels:
		panel.modulate.a = 1.0
	_outgoing.hide()
	_outgoing.texture = null
	_outgoing.modulate.a = 1.0


func _draw_connector(connector: Control, index: int) -> void:
	var kind := "down" if index == 0 or _entry() == null else _entry().result_connector
	if kind == "none":
		return
	var x := connector.size.x * 0.5
	var h := connector.size.y
	if kind == "plus":
		connector.draw_line(Vector2(x - 5, h * 0.5), Vector2(x + 5, h * 0.5), GOLD, 2)
		connector.draw_line(Vector2(x, h * 0.5 - 5), Vector2(x, h * 0.5 + 5), GOLD, 2)
	else:
		connector.draw_line(Vector2(x, 1), Vector2(x, h - 3), GOLD, 2)
		connector.draw_polyline(PackedVector2Array([Vector2(x - 5, h - 8), Vector2(x, h - 3), Vector2(x + 5, h - 8)]), GOLD, 2)


func _layout_visual() -> void:
	if not is_node_ready():
		return
	var padding := 8.0
	var inner := _stage.size - Vector2.ONE * padding * 2
	var mode := get_media_mode()
	_image.position = Vector2.ONE * padding
	_image.size = inner
	_diagram.position = Vector2.ONE * padding
	_diagram.size = inner
	if selected_timeline_state != TimelineState.NONE:
		if mode == MediaMode.CONTEXTUAL_PORTRAIT:
			_image.size.x = inner.x * 0.30
			_diagram.position.x = padding + inner.x * 0.34
			_diagram.size.x = inner.x * 0.66
		elif mode == MediaMode.DOCUMENTARY_PHOTO:
			_image.size.x = inner.x * 0.65
			_diagram.position.x = padding + inner.x * 0.69
			_diagram.size.x = inner.x * 0.31
	_missing.position = _image.position
	_missing.size = _image.size


func _layout_ribbon() -> void:
	var half_step := _ribbon.size.x / 16.0
	_ribbon_line.points = PackedVector2Array([Vector2(half_step, 13), Vector2(_ribbon.size.x - half_step, 13)])


func _resize_layout() -> void:
	if not is_node_ready():
		return
	var compact := size.x < 1000 or size.y < 550
	for side in ["left", "right", "top", "bottom"]:
		$Main/Margin.add_theme_constant_override("margin_" + side, 8 if compact else 16)
	$Main/Margin/Layout.add_theme_constant_override("separation", 4 if compact else 8)
	%Columns.add_theme_constant_override("separation", 12 if compact else 24)
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_prompt.add_theme_font_size_override("font_size", 16 if compact else 18)
	_date.add_theme_font_size_override("font_size", 22 if compact else 28)
	_heading.add_theme_font_size_override("font_size", 19 if compact else 23)
	_body.add_theme_font_size_override("font_size", 16 if compact else 18)
	_source_basis.add_theme_font_size_override("font_size", 12 if compact else 14)
	_era.add_theme_font_size_override("font_size", 13 if compact else 15)
	_note_body.add_theme_font_size_override("font_size", 14)
	_caption.add_theme_font_size_override("font_size", 12 if compact else 15)
	_credit.add_theme_font_size_override("font_size", 12 if compact else 13)
	_takeaway.add_theme_font_size_override("font_size", 14 if compact else 16)
	_source_text.add_theme_font_size_override("font_size", 17 if compact else 21)
	_body.get_parent().add_theme_constant_override("separation", 6)
	_time_window.add_theme_constant_override("separation", 3 if compact else 6)
	_diagram.add_theme_constant_override("separation", 2 if compact else 5)
	for i in _transform_labels.size():
		var label := _transform_labels[i]
		label.add_theme_font_size_override("font_size", 14 if compact else (18 if get_media_mode() == MediaMode.DOCUMENTARY_PHOTO else 22))
		if _entry() != null:
			var original: String = [_entry().context_label, _entry().change_label, _entry().result_label][i]
			# Compact diagrams wrap to available width rather than retaining print breaks.
			label.text = original.replace("\n", " ") if compact else original
	for connector in _connectors:
		connector.get_parent().custom_minimum_size.y = 12 if compact else 20
	for label in _era_labels:
		label.add_theme_font_size_override("font_size", 11 if compact else 14)
	_layout_visual()
	_layout_ribbon()
	if _header_utilities != null:
		_header_utilities.resize()


func _point_input(event: InputEvent, index: int) -> void:
	if _sources.visible or _closing:
		return
	var step := -1 if event.is_action_pressed(&"ui_left") else (1 if event.is_action_pressed(&"ui_right") else 0)
	if step != 0:
		get_viewport().set_input_as_handled()
		_points[clampi(index + step, 0, 7)].grab_focus()


func _reading_input(event: InputEvent, scroll: ScrollContainer) -> void:
	var movement := 0
	if event.is_action_pressed(&"ui_down"): movement = 40
	elif event.is_action_pressed(&"ui_up"): movement = -40
	elif event.is_action_pressed(&"ui_page_down"): movement = int(scroll.size.y * 0.85)
	elif event.is_action_pressed(&"ui_page_up"): movement = -int(scroll.size.y * 0.85)
	elif event.is_action_pressed(&"ui_home"): movement = -100000
	elif event.is_action_pressed(&"ui_end"): movement = 100000
	else: return
	get_viewport().set_input_as_handled()
	scroll.scroll_vertical += movement


func open_sources() -> void:
	if not _open or _closing or _sources.visible:
		return
	cancel_active_reveal()
	_source_title.text = "Sources"
	_source_text.text = (content as LCINT02Content).sources_text
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()


func _update_speaker() -> void:
	HeaderUtilities.update_speaker(self, _pending)


func toggle_narration() -> void:
	HeaderUtilities.toggle_narration(self)


func stop_narration() -> void:
	_audio.stream_paused = false
	super.stop_narration()


func close_interaction() -> void:
	if not _open or _closing:
		return
	cancel_active_reveal()
	_cancel_panel_tween()
	stop_narration()
	_closing = true
	_panel_tween = create_tween()
	_panel_tween.tween_property(self, "modulate:a", 0.0, 0.16)
	_panel_tween.tween_callback(_finish_close)


func _finish_close() -> void:
	_cancel_panel_tween()
	_closing = false
	super.close_interaction()
	close_requested.emit()


func _cancel_panel_tween() -> void:
	if _panel_tween != null and _panel_tween.is_valid():
		_panel_tween.kill()
	_panel_tween = null
	modulate.a = 1.0


func _visibility_changed() -> void:
	if _open and not is_visible_in_tree():
		cancel_active_reveal()
		_finish_close()


func _exit_tree() -> void:
	cancel_active_reveal()
	_cancel_panel_tween()
	super._exit_tree()

func _sync_focus() -> void:
	HeaderUtilities.sync_focus(self)
