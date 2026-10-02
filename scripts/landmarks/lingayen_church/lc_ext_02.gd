@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/lingayen_church/lc_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview


const HeaderUtilities = preload("res://scripts/landmarks/lingayen_church/lc_header_utilities.gd")
var _header_utilities: RefCounted
## Image-relative observations inside the existing AKAR Sources/audio/focus shell.

signal hotspot_closed
signal observation_changed(observation: int)

enum Observation { OVERVIEW, OVERALL_FORM, TIERED_SILHOUETTE, TOWER_AND_CHURCH }

const TowerContent = preload("res://scripts/landmarks/lingayen_church/lc_ext_02_content.gd")
const ObservationEntry = preload("res://scripts/landmarks/lingayen_church/lc_ext_02_observation.gd")
const SECONDARY := Color(0.76, 0.75, 0.67, 1)

var _media: VBoxContainer
var _viewer_area: Control
var _viewer: Control
var _focus_overlay: Panel
var _caption: Label
var _legend: HBoxContainer
var _subtitle: Label
var _pending: Label
var _credit: Label
var _prompt: Label
var _key_label: Label
var _detail_holder: Control
var _detail: TextureRect
var _outgoing_detail: TextureRect
var _badges: Array[Panel] = []
var _marker_numbers: Array[Label] = []
var _marker_normal: StyleBox
var _marker_selected: StyleBox
var _focus_region := Rect2()
var _panel_tween: Tween
var _closing: bool = false


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
	_viewer_area.resized.connect(_layout_viewer)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_open_standalone.call_deferred()


func _build_header() -> void:
	var header := _presentation_root.get_node("Main/Margin/Layout/Header")
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	header.move_child(titles, 0)
	_title.reparent(titles)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titles.add_child(_subtitle)
	_subtitle.add_theme_font_size_override("font_size", 18)
	_subtitle.add_theme_color_override("font_color", SECONDARY)
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


func _build_viewer() -> void:
	_media.name = "TowerMedia"
	_media.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_media.size_flags_stretch_ratio = 0.6
	_information.size_flags_stretch_ratio = 0.4
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_child(_media)
	_presentation_root.get_node("Main/Margin/Layout/Columns").move_child(_media, 0)
	_viewer_area.name = "ViewerArea"
	_viewer_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_viewer_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_media.add_child(_viewer_area)
	_viewer.name = "TowerViewer"
	_viewer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_viewer_area.add_child(_viewer)
	_image.reparent(_viewer)
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_focus_overlay.name = "FocusRegion"
	_focus_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var focus_style := StyleBoxFlat.new()
	focus_style.bg_color = Color(0.88, 0.8, 0.55, 0.06)
	focus_style.set_border_width_all(2)
	focus_style.border_color = Color(0.88, 0.8, 0.55, 0.85)
	_focus_overlay.add_theme_stylebox_override("panel", focus_style)
	_viewer.add_child(_focus_overlay)
	_focus_overlay.hide()
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.add_theme_font_size_override("font_size", 16)
	_media.add_child(_caption)
	_legend.name = "MarkerLegend"
	_legend.add_theme_constant_override("separation", 8)
	_media.add_child(_legend)
	_marker_normal = get_theme_stylebox("normal", "Button")
	_marker_selected = get_theme_stylebox("pressed", "Button")
	for i in 3:
		var entry := content.concepts[i + 1] as ObservationEntry
		var marker := Button.new()
		marker.name = "Marker%d" % (i + 1)
		marker.custom_minimum_size = Vector2(56, 56)
		marker.size = Vector2(56, 56)
		marker.toggle_mode = true
		marker.accessibility_name = entry.label
		marker.tooltip_text = entry.label
		# Small symbol, generous hit area; inherited focus outline covers all 56 px.
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			marker.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		_viewer.add_child(marker)
		var badge := Panel.new()
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.position = Vector2(11, 11)
		badge.size = Vector2(34, 34)
		badge.add_theme_stylebox_override("panel", _marker_normal)
		marker.add_child(badge)
		var number := Label.new()
		number.text = str(i + 1)
		number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		number.mouse_filter = Control.MOUSE_FILTER_IGNORE
		number.add_theme_font_size_override("font_size", 18)
		badge.add_child(number)
		number.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var label := Label.new()
		label.text = "%d  %s" % [i + 1, entry.label]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", SECONDARY)
		_legend.add_child(label)
		if not Engine.is_editor_hint():
			marker.pressed.connect(set_observation.bind(i + 1))
			marker.gui_input.connect(_marker_input.bind(i))
		_concepts.append(marker)
		_badges.append(badge)
		_marker_numbers.append(number)


func _build_information() -> void:
	_detail_holder.name = "DetailViewer"
	_detail_holder.custom_minimum_size.y = 164
	_detail_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_information.add_child(_detail_holder)
	_information.move_child(_detail_holder, 0)
	for rect in [_detail, _outgoing_detail]:
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_detail_holder.add_child(rect)
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_outgoing_detail.hide()
	var text_column := _body.get_parent()
	_heading.reparent(text_column)
	text_column.move_child(_heading, 0)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_information.get_node("Meta").hide()
	_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_prompt.add_theme_font_size_override("font_size", 18)
	_prompt.add_theme_color_override("font_color", Color("d8c58b"))
	text_column.add_child(_prompt)
	text_column.move_child(_prompt, 2)
	_key_label.text = "KEY TAKEAWAY"
	_key_label.add_theme_font_size_override("font_size", 14)
	_key_label.add_theme_color_override("font_color", Color("d8c58b"))
	text_column.add_child(_key_label)
	text_column.move_child(_key_label, 3)
	_takeaway.add_theme_font_size_override("font_size", 18)
	_takeaway.add_theme_color_override("font_color", SECONDARY)
	_sources_button.custom_minimum_size.y = 56
	_source_close.custom_minimum_size.y = 56
	_credit.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_credit.add_theme_font_size_override("font_size", 14)
	_credit.add_theme_color_override("font_color", SECONDARY)
	_information.add_child(_credit)


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
	if not is_node_ready() or not content is TowerContent or content.concepts.size() != 4 or content.illustration == null:
		return false
	for entry in content.concepts:
		if not entry is ObservationEntry:
			return false
	if not _open:
		var previous := get_viewport().gui_get_focus_owner()
		_return_focus = weakref(previous) if previous != null else null
	_title.text = content.title
	_subtitle.text = content.subtitle
	_image.texture = content.illustration
	_image.accessibility_name = content.illustration_alt_text
	_caption.text = content.image_caption
	_credit.text = content.image_credit
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
	if not is_node_ready():
		return
	_cancel_panel_tween()
	_closing = false
	_sources.hide()
	stop_narration()
	set_observation(Observation.OVERVIEW, false)
	if _open:
		_sync_focus()
		_concepts[0].grab_focus()


func get_observation() -> Observation:
	return _selected as Observation


func select_concept(index: int) -> void:
	if Engine.is_editor_hint():
		return
	set_observation(index)


func set_observation(observation: int, animate: bool = true) -> void:
	if Engine.is_editor_hint():
		return
	if not is_node_ready() or _sources.visible or _closing:
		return
	var previous_texture := _detail.texture
	var previous_region := _focus_region
	_cancel_observation_transition()
	# Reuse the shell's index as the single authoritative observation state.
	_selected = observation if observation >= 0 and observation <= 3 else Observation.OVERVIEW
	_render()
	if animate and _open:
		var text_column := _body.get_parent() as Control
		text_column.modulate.a = 0.65
		_fade = create_tween().set_parallel(true)
		_fade.tween_property(text_column, "modulate:a", 1.0, 0.16)
		if _selected != Observation.OVERVIEW:
			_detail.modulate.a = 0.0
			_fade.tween_property(_detail, "modulate:a", 1.0, 0.16)
			if previous_texture != null:
				_outgoing_detail.texture = previous_texture
				_outgoing_detail.modulate.a = 1.0
				_outgoing_detail.show()
				_fade.tween_property(_outgoing_detail, "modulate:a", 0.0, 0.16)
			var target_region := _focus_region
			if previous_region.has_area():
				_set_focus_region(previous_region)
				_fade.tween_method(_set_focus_region, previous_region, target_region, 0.16)
		_fade.chain().tween_callback(_outgoing_detail.hide)
	observation_changed.emit(_selected)


func _render() -> void:
	var entry := content.concepts[_selected] as ObservationEntry
	_heading.text = entry.heading
	_body.text = entry.body
	_takeaway.text = content.learning_takeaway
	_takeaway.show()
	_prompt.text = content.prompt
	_prompt.visible = _selected == Observation.OVERVIEW
	_detail_holder.visible = _selected != Observation.OVERVIEW
	_detail.texture = entry.detail_image
	if entry.detail_crop.has_area():
		var crop := AtlasTexture.new()
		crop.atlas = content.illustration
		var native := content.illustration.get_size()
		crop.region = Rect2(entry.detail_crop.position * native, entry.detail_crop.size * native)
		crop.filter_clip = true
		_detail.texture = crop
	_detail.accessibility_name = entry.label + " — present-day detail photograph"
	_focus_overlay.visible = _selected != Observation.OVERVIEW
	_set_focus_region(entry.focus_rect)
	for i in _concepts.size():
		var selected := _selected == i + 1
		_concepts[i].set_pressed_no_signal(selected)
		_badges[i].add_theme_stylebox_override("panel", _marker_selected if selected else _marker_normal)
		_marker_numbers[i].add_theme_color_override("font_color", Color(0.06, 0.09, 0.07) if selected else Color(0.97, 0.96, 0.92))
	_scroll.scroll_vertical = 0


func _set_focus_region(region: Rect2) -> void:
	_focus_region = region
	_focus_overlay.position = region.position * _viewer.size
	_focus_overlay.size = region.size * _viewer.size


func _layout_viewer() -> void:
	if not is_node_ready() or _image.texture == null:
		return
	var native := _image.texture.get_size()
	var factor := minf(_viewer_area.size.x / native.x, _viewer_area.size.y / native.y)
	_viewer.size = native * maxf(factor, 0.0)
	_viewer.position = (_viewer_area.size - _viewer.size) * 0.5
	for i in _concepts.size():
		var entry := content.concepts[i + 1] as ObservationEntry
		_concepts[i].position = entry.marker_position * _viewer.size - _concepts[i].size * 0.5
	_set_focus_region(_focus_region)


func _resize_layout() -> void:
	if not is_instance_valid(_presentation_root):
		return
	EditorPresentation.resize(self, _presentation_root)
	if not is_node_ready():
		return
	var compact := _presentation_root.size.x < 1000 or _presentation_root.size.y < 550
	var small := _presentation_root.size.y < 460
	for side in ["left", "top", "right", "bottom"]:
		_presentation_root.get_node("Main/Margin").add_theme_constant_override("margin_" + side, 8 if compact else 16)
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_theme_constant_override("separation", 12 if compact else 24)
	_presentation_root.get_node("Main/Margin/Layout").add_theme_constant_override("separation", 4 if compact else 8)
	_information.add_theme_constant_override("separation", 4 if compact else 8)
	_media.add_theme_constant_override("separation", 4 if compact else 8)
	_body.get_parent().add_theme_constant_override("separation", 8 if compact else 12)
	_title.add_theme_font_size_override("font_size", 22 if compact else 30)
	_heading.add_theme_font_size_override("font_size", 20 if compact else 24)
	_body.add_theme_font_size_override("font_size", 18 if compact else 20)
	_detail_holder.custom_minimum_size.y = 72 if small else (100 if compact else 164)
	_layout_viewer.call_deferred()
	if Engine.is_editor_hint():
		HeaderUtilities.resize_presentation(self, _pending, _presentation_root.size.x)
	elif _header_utilities != null:
		_header_utilities.resize()


func _marker_input(event: InputEvent, index: int) -> void:
	if Engine.is_editor_hint():
		return
	if _sources.visible or _closing:
		return
	var step := 0
	if event.is_action_pressed(&"ui_left") or event.is_action_pressed(&"ui_up"):
		step = -1
	elif event.is_action_pressed(&"ui_right") or event.is_action_pressed(&"ui_down"):
		step = 1
	if step != 0:
		get_viewport().set_input_as_handled()
		_concepts[clampi(index + step, 0, 2)].grab_focus()


func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _closing or _sources.visible:
		return
	_cancel_observation_transition()
	_set_focus_region((content.concepts[_selected] as ObservationEntry).focus_rect)
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


func _cancel_observation_transition() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_fade()
	_body.get_parent().modulate.a = 1.0
	_detail.modulate.a = 1.0
	_outgoing_detail.hide()
	_outgoing_detail.texture = null


func close_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	close_interaction()


func close_interaction() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _closing:
		return
	_cancel_observation_transition()
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
		_cancel_observation_transition()
		_cancel_panel_tween()
		_finish_close()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_panel_tween()
	super._exit_tree()

func _sync_focus() -> void:
	if Engine.is_editor_hint():
		return
	HeaderUtilities.sync_focus(self)


func _build_presentation() -> void:
	_media = VBoxContainer.new()
	_viewer_area = Control.new()
	_viewer = Control.new()
	_focus_overlay = Panel.new()
	_caption = Label.new()
	_legend = HBoxContainer.new()
	_subtitle = Label.new()
	_pending = Label.new()
	_credit = Label.new()
	_prompt = Label.new()
	_key_label = Label.new()
	_detail_holder = Control.new()
	_detail = TextureRect.new()
	_outgoing_detail = TextureRect.new()
	_badges.clear()
	_marker_numbers.clear()

	_build_header()
	# The original shared three-concept selectors are not this interaction's UI.
	var old_sections := _presentation_root.get_node("Main/Margin/Layout/Sections")
	old_sections.get_parent().remove_child(old_sections)
	old_sections.queue_free()
	_concepts.clear()
	_build_viewer()
	_build_information()


func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		super._unhandled_input(event)


func close_sources() -> void:
	if not Engine.is_editor_hint():
		super.close_sources()


func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready() or content == null:
		return
	_presentation_root = EditorPresentation.begin(self)
	_build_presentation()
	_selected = Observation.OVERVIEW
	_title.text = content.title
	_subtitle.text = content.subtitle
	_image.texture = content.illustration
	_image.accessibility_name = content.illustration_alt_text
	_caption.text = content.image_caption
	_credit.text = content.image_credit
	_render()
	_viewer_area.resized.connect(_layout_viewer)
	EditorPresentation.finish(self, _presentation_root, _pending, content.narration_stream)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
