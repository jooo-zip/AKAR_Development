extends ConferenceRoomInteraction
const SourcesOverlay = preload("res://scripts/landmarks/limahong_channel/lch_sources_overlay.gd")
const HeaderUtilities = preload("res://scripts/landmarks/limahong_channel/lch_header_utilities.gd")
var _header_utilities: HeaderUtilities
## Three self-paced views within the shared interior shell.
signal close_requested
signal stage_changed(stage_index: int)

enum HeritageStage { MILESTONE_2019, PRESERVATION, DEVELOPMENT }
const HeritageContent = preload("res://scripts/landmarks/limahong_channel/lch_int_03_content.gd")
const StageContent = preload("res://scripts/landmarks/limahong_channel/lch_int_03_stage.gd")
const GOLD := Color(0.88, 0.80, 0.55)

var current_stage: HeritageStage = HeritageStage.MILESTONE_2019
var contributor_expanded: bool = false
var _data: HeritageContent
var _board := Control.new()
var _views: Array[Control] = []
var _photos: Array[TextureRect] = []
var _fallbacks: Array[Label] = []
var _documentary: Label
var _present_caption: Label
var _contributor := Button.new()
var _contributor_heading: Label
var _contributor_details := VBoxContainer.new()
var _contributor_role: Label
var _contributor_body: Label
var _story_nodes: Array[PanelContainer] = []
var _story_labels: Array[Label] = []
var _story_lines: Array[Line2D] = []
var _story_ends: Array[Vector2] = []
var _story_progress: float = 1.0
var _plan_heading: Label
var _facility_scroll := ScrollContainer.new()
var _facility_grid := GridContainer.new()
var _facility_cards: Array[PanelContainer] = []
var _facility_names: Array[Label] = []
var _facility_statuses: Array[Label] = []
var _prompt: Label
var _why: Label
var _notice := VBoxContainer.new()
var _pending: Label
var _transition: Tween
var _story_tween: Tween
var _compact: bool = false
var _drag_scroll: ScrollContainer
var _drag_index: int = -1
var _drag_origin: Vector2
var _drag_value: int

func _ready() -> void:
	super._ready()
	_data = content as HeritageContent
	_build_shell()
	_build_milestone()
	_build_preservation()
	_build_development()
	_build_information()
	for scroll in [_facility_scroll, _scroll, _source_scroll]:
		scroll.gui_input.connect(_scroll_input.bind(scroll))
	_board.resized.connect(_layout_story)
	resized.connect(_resize_layout)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_header_utilities = HeaderUtilities.new(self, _pending, _pending.get_parent())
	add_child(SourcesOverlay.new(self))

func _build_shell() -> void:
	var header := $Main/Margin/Layout/Header
	_speaker.reparent(header)
	_sources_button.reparent(header)
	header.move_child(_close, -1)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_speaker.text = "LISTEN"
	_speaker.custom_minimum_size = Vector2(112, 48)
	_speaker.expand_icon = true
	_speaker.add_theme_constant_override("icon_max_width", 24)
	var subtitle := HBoxContainer.new()
	$Main/Margin/Layout.add_child(subtitle)
	$Main/Margin/Layout.move_child(subtitle, 1)
	var code := _label(subtitle, content.hotspot_id, 13, GOLD)
	code.autowrap_mode = TextServer.AUTOWRAP_OFF
	code.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pending = _label(subtitle, "Narration pending", 13)
	_pending.autowrap_mode = TextServer.AUTOWRAP_OFF
	var bar := $Main/Margin/Layout/Sections
	$Main/Margin/Layout.move_child(bar, 2)
	for i in 3:
		_concepts[i].custom_minimum_size.y = 56
		_concepts[i].gui_input.connect(_stage_input.bind(i))
	_image.hide()
	_image.reparent($Main/Margin/Layout/Controls)
	$Main/Margin/Layout/Controls.hide()
	_board.name = "VisualBoard"
	_board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	%Columns.add_child(_board)
	%Columns.move_child(_board, 0)
	for i in 3:
		var view: Control = Control.new() if i == 1 else VBoxContainer.new()
		view.name = ["MilestoneView", "PreservationView", "DevelopmentView"][i]
		view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_board.add_child(view)
		view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		if view is VBoxContainer:
			view.add_theme_constant_override("separation", 6)
		_views.append(view)

func _label(parent: Node, value: String, font_size: int, color: Color = Color(0.97, 0.96, 0.92)) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("line_spacing", 0)
	parent.add_child(label)
	return label

func _photo(parent: Node) -> TextureRect:
	var photo := TextureRect.new()
	photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	photo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(photo)
	var fallback := _label(photo, "DOCUMENTARY IMAGE\nUNAVAILABLE", 13)
	fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_photos.append(photo)
	_fallbacks.append(fallback)
	return photo

func _build_milestone() -> void:
	var photo := _photo(_views[0])
	photo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_documentary = _label(_views[0], _data.documentary_label, 14, GOLD)
	_documentary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_contributor.name = "ContributorCard"
	_contributor.toggle_mode = true
	_contributor.pressed.connect(toggle_contributor)
	_views[0].add_child(_contributor)
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_contributor.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 6)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)
	_photo(row)
	_fallbacks[1].text = "PHOTO\nN/A"
	_fallbacks[1].autowrap_mode = TextServer.AUTOWRAP_OFF
	_fallbacks[1].add_theme_font_size_override("font_size", 10)
	_contributor_heading = _label(row, "", 15, GOLD)
	_contributor_heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_contributor_heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_views[0].add_child(_contributor_details)
	_contributor_details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_contributor_role = _label(_contributor_details, _data.contributor_role, 15, GOLD)
	_contributor_body = _label(_contributor_details, _data.contributor_body, 16)
	_update_contributor()

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.15, 0.125)
	style.border_color = Color(0.55, 0.58, 0.47)
	style.set_border_width_all(1)
	style.set_content_margin_all(8)
	return style

func _build_preservation() -> void:
	for i in 2:
		var line := Line2D.new()
		line.width = 2.5
		line.default_color = GOLD
		line.antialiased = true
		_views[1].add_child(line)
		_story_lines.append(line)
	for caption in _data.preservation_nodes:
		var node := PanelContainer.new()
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.add_theme_stylebox_override("panel", _panel_style())
		_views[1].add_child(node)
		var label := _label(node, caption, 20, GOLD)
		# Explicit two-line captions avoid zero-width wrapping in the hidden view.
		label.text = caption.replace(" ", "\n")
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_story_nodes.append(node)
		_story_labels.append(label)

func _build_development() -> void:
	_photo(_views[2])
	_present_caption = _label(_views[2], _data.present_site_label, 13)
	_present_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_plan_heading = _label(_views[2], _data.plan_heading, 18, GOLD)
	_facility_scroll.name = "FacilityScroll"
	_facility_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_facility_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_views[2].add_child(_facility_scroll)
	_facility_grid.name = "FacilityGrid"
	_facility_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_facility_grid.add_theme_constant_override("h_separation", 8)
	_facility_grid.add_theme_constant_override("v_separation", 8)
	_facility_scroll.add_child(_facility_grid)
	for facility in _data.facilities:
		var card := PanelContainer.new()
		card.name = facility.facility_id
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", _panel_style())
		_facility_grid.add_child(card)
		var column := VBoxContainer.new()
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(column)
		var label := _label(column, facility.display_name, 16)
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_facility_names.append(label)
		_facility_statuses.append(_label(column, facility.status_label(), 12, GOLD))
		_facility_cards.append(card)

func _build_information() -> void:
	_prompt = _label(_information, content.prompt, 15, GOLD)
	_information.move_child(_prompt, 0)
	_heading.reparent(_information)
	_information.move_child(_heading, 1)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_information.get_node("Meta").hide()
	_why = _label(_body.get_parent(), "WHY IT MATTERS", 16, GOLD)
	_body.get_parent().move_child(_why, 1)
	_information.add_child(_notice)
	_notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scroll.follow_focus = true

func _stage(index: int) -> StageContent:
	return content.concepts[index] as StageContent

func open_interaction() -> bool:
	_data = content as HeritageContent
	if not is_node_ready() or _data == null or content.concepts.size() != 3:
		return false
	for entry in content.concepts:
		if not entry is StageContent:
			return false
	if _open:
		return true
	_cancel_animations()
	current_stage = _data.default_stage as HeritageStage
	contributor_expanded = false
	_facility_scroll.scroll_vertical = 0
	for i in 3:
		var media = [_data.groundbreaking, _data.contributor_image, _data.present_site][i]
		_photos[i].texture = media.resolve_image() if media != null else null
		_fallbacks[i].visible = _photos[i].texture == null
	return super.open_interaction()

func select_concept(index: int) -> void:
	select_stage(index)

func select_stage(stage: int, animate: bool = true) -> void:
	if not _open or _sources.visible or stage < 0 or stage > 2:
		return
	_cancel_animations()
	if stage == current_stage:
		return
	var outgoing := current_stage
	current_stage = stage as HeritageStage
	contributor_expanded = false
	_render()
	_sync_focus()
	if animate:
		_views[outgoing].show() # Inert outgoing visual for the 200 ms crossfade.
		_views[stage].modulate.a = 0.0
		_transition = create_tween().set_parallel(true)
		_transition.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_transition.tween_property(_views[outgoing], "modulate:a", 0.0, 0.2)
		_transition.tween_property(_views[stage], "modulate:a", 1.0, 0.2)
		_transition.finished.connect(_finish_transition)
		if stage == HeritageStage.PRESERVATION:
			_animate_story()
	stage_changed.emit(stage)
	concept_changed.emit(stage)

func _render() -> void:
	_selected = current_stage
	super._render()
	var development := current_stage == HeritageStage.DEVELOPMENT
	var text_column := _body.get_parent()
	# Seed the hidden notice's width before its wrapped text enters layout.
	_notice.size.x = _information.size.x
	for label in [_why, _takeaway]:
		var destination := _notice if development else text_column
		if label.get_parent() != destination:
			label.reparent(destination, false)
	_why.show()
	_takeaway.show()
	_takeaway.text = _data.qualification if development else _stage(current_stage).takeaway
	_notice.visible = development
	# The short Development body takes only its content height; the qualification
	# follows directly below it instead of being pushed to the panel bottom.
	_scroll.size_flags_vertical = Control.SIZE_FILL if development else Control.SIZE_EXPAND_FILL
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED if development else ScrollContainer.SCROLL_MODE_AUTO
	_update_contributor()
	_resize_layout()
	_normalize_views()

func toggle_contributor() -> void:
	if not _open or _sources.visible or current_stage != HeritageStage.MILESTONE_2019:
		return
	contributor_expanded = not contributor_expanded
	_update_contributor()

func _update_contributor() -> void:
	_contributor.set_pressed_no_signal(contributor_expanded)
	_contributor_heading.text = "MODERN CONTRIBUTOR\n" + _data.contributor_name + "\n" + ("HIDE ROLE" if contributor_expanded else "VIEW ROLE")
	if _compact and contributor_expanded:
		_contributor_heading.text = "MODERN CONTRIBUTOR\n" + _data.contributor_name
	_contributor_heading.add_theme_color_override("font_color", Color(0.06, 0.09, 0.07) if contributor_expanded else GOLD)
	_fallbacks[1].add_theme_color_override("font_color", Color(0.06, 0.09, 0.07) if contributor_expanded else GOLD)
	_contributor.custom_minimum_size.y = (60 if contributor_expanded else 72) if _compact else (72 if size.x < 1050 else 92)
	_contributor.accessibility_name = _contributor_heading.text
	_contributor_details.visible = contributor_expanded

func _normalize_views() -> void:
	for i in _views.size():
		_views[i].visible = i == current_stage
		_views[i].modulate.a = 1.0
		_views[i].scale = Vector2.ONE
		_concepts[i].set_pressed_no_signal(i == current_stage)
	_contributor.disabled = current_stage != HeritageStage.MILESTONE_2019 or _sources.visible
	_facility_scroll.mouse_filter = Control.MOUSE_FILTER_STOP if current_stage == HeritageStage.DEVELOPMENT and not _sources.visible else Control.MOUSE_FILTER_IGNORE
	_facility_scroll.get_v_scroll_bar().mouse_filter = _facility_scroll.mouse_filter

func _finish_transition() -> void:
	_transition = null
	_normalize_views()

func _animate_story() -> void:
	for node in _story_nodes:
		node.modulate.a = 0.0
	_set_story_progress(0.0)
	_story_tween = create_tween()
	_story_tween.tween_property(_story_nodes[0], "modulate:a", 1.0, 0.15)
	_story_tween.tween_method(_set_story_progress, 0.0, 1.0, 0.25)
	_story_tween.tween_property(_story_nodes[1], "modulate:a", 1.0, 0.2)
	_story_tween.parallel().tween_property(_story_nodes[2], "modulate:a", 1.0, 0.2)
	_story_tween.finished.connect(func(): _story_tween = null)

func _cancel_animations() -> void:
	_drag_scroll = null
	_drag_index = -1
	for tween in [_transition, _story_tween]:
		if tween != null and tween.is_valid():
			tween.kill()
	_transition = null
	_story_tween = null
	for node in _story_nodes:
		node.modulate.a = 1.0
	_set_story_progress(1.0)
	if _views.size() == 3:
		_normalize_views()

func _resize_layout() -> void:
	if _data == null or _facility_cards.size() != 9:
		return
	_cancel_animations()
	var small := size.x < 1050
	_compact = size.x < 820
	_board.size_flags_stretch_ratio = 1.32 if _compact else 1.78
	%Columns.add_theme_constant_override("separation", 12 if small else 20)
	for side in ["left", "top", "right", "bottom"]:
		$Main/Margin.add_theme_constant_override("margin_" + side, 10 if small else 16)
	_title.add_theme_font_size_override("font_size", 18 if small else 26)
	_prompt.add_theme_font_size_override("font_size", 12 if small else 15)
	_heading.add_theme_font_size_override("font_size", 20 if small else 24)
	_body.add_theme_font_size_override("font_size", 16 if small else 20)
	_takeaway.add_theme_font_size_override("font_size", (14 if small else 18) if current_stage == HeritageStage.DEVELOPMENT else (16 if small else 20))
	_why.add_theme_font_size_override("font_size", 14 if small else 16)
	_information.add_theme_constant_override("separation", 6 if small else 10)
	for i in 3:
		_concepts[i].text = _stage(i).compact_label if _compact else _stage(i).short_label
		_concepts[i].add_theme_font_size_override("font_size", 14 if small else 17)
		_concepts[i].custom_minimum_size.y = 52 if small else 56
	_photos[1].custom_minimum_size = Vector2(38, 48) if _compact else (Vector2(44, 55) if small else Vector2(64, 80))
	_views[0].add_theme_constant_override("separation", 4 if _compact else 6)
	_contributor_details.add_theme_constant_override("separation", 2 if _compact else 4)
	_update_contributor()
	_contributor_heading.add_theme_font_size_override("font_size", 12 if small else 15)
	_contributor_role.add_theme_font_size_override("font_size", 13 if small else 15)
	_contributor_body.add_theme_font_size_override("font_size", 14 if small else 16)
	_documentary.add_theme_font_size_override("font_size", 12 if small else 14)
	_photos[2].custom_minimum_size.y = 100 if _compact else (112 if small else 180)
	_present_caption.add_theme_font_size_override("font_size", 11 if small else 13)
	_plan_heading.add_theme_font_size_override("font_size", 16 if small else 18)
	_facility_grid.columns = 2 if _compact else 3
	for i in _facility_cards.size():
		_facility_cards[i].custom_minimum_size.y = 72 if small else 80
		_facility_names[i].add_theme_font_size_override("font_size", 14 if small else 16)
		_facility_statuses[i].add_theme_font_size_override("font_size", 11 if small else 12)
	_layout_story()

func _layout_story() -> void:
	if _story_nodes.size() != 3:
		return
	var dimensions := _board.size
	var small := size.x < 1050
	var top_size := Vector2(minf(280, dimensions.x - 16), 76 if small else 100)
	var lower_size := Vector2(minf(220, (dimensions.x - 24) * 0.5), 80 if small else 100)
	_story_nodes[0].size = top_size
	_story_nodes[0].position = Vector2((dimensions.x - top_size.x) * 0.5, dimensions.y * 0.10)
	for i in 2:
		_story_nodes[i + 1].size = lower_size
		_story_nodes[i + 1].position = Vector2(0 if i == 0 else dimensions.x - lower_size.x, dimensions.y - lower_size.y - dimensions.y * 0.10)
	for label in _story_labels:
		label.add_theme_font_size_override("font_size", 16 if small else 20)
	_story_ends.clear()
	var origin := _story_nodes[0].position + Vector2(top_size.x * 0.5, top_size.y)
	for i in 2:
		var target := _story_nodes[i + 1].position + Vector2(lower_size.x * 0.5, 0)
		_story_ends.append(target)
		_story_lines[i].points = PackedVector2Array([origin, origin.lerp(target, _story_progress)])

func _set_story_progress(value: float) -> void:
	_story_progress = value
	for i in _story_ends.size():
		var origin := _story_lines[i].points[0]
		_story_lines[i].points = PackedVector2Array([origin, origin.lerp(_story_ends[i], value)])

func _stage_input(event: InputEvent, index: int) -> void:
	if not _open or _sources.visible or not event is InputEventKey or not event.pressed:
		return
	if event.keycode not in [KEY_LEFT, KEY_RIGHT]:
		return
	_concepts[index].accept_event()
	var target := clampi(index + (-1 if event.keycode == KEY_LEFT else 1), 0, 2)
	select_stage(target)
	_concepts[target].grab_focus()

func _scroll_input(event: InputEvent, scroll: ScrollContainer) -> void:
	if not _open or not event is InputEventKey or not event.pressed:
		return
	var delta := 0
	match event.keycode:
		KEY_UP: delta = -32
		KEY_DOWN: delta = 32
		KEY_PAGEUP: delta = -int(scroll.size.y * 0.8)
		KEY_PAGEDOWN: delta = int(scroll.size.y * 0.8)
		KEY_HOME: delta = -int(scroll.get_v_scroll_bar().max_value)
		KEY_END: delta = int(scroll.get_v_scroll_bar().max_value)
		_: return
	scroll.accept_event()
	scroll.scroll_vertical += delta

func _input(event: InputEvent) -> void:
	if not _open:
		return
	# Explicit touch dragging also works with synthetic input on desktop previews.
	# These scroll areas contain passive text/cards, so no child action is consumed.
	if event is InputEventScreenTouch:
		if event.pressed and _drag_scroll == null:
			var candidates: Array[ScrollContainer] = []
			candidates.append(_source_scroll if _sources.visible else _scroll)
			if not _sources.visible and current_stage == HeritageStage.DEVELOPMENT:
				candidates.append(_facility_scroll)
			for scroll in candidates:
				var bar := scroll.get_v_scroll_bar()
				if scroll.is_visible_in_tree() and scroll.get_global_rect().has_point(event.position) and bar.max_value > bar.page:
					_drag_scroll = scroll
					_drag_index = event.index
					_drag_origin = event.position
					_drag_value = scroll.scroll_vertical
					get_viewport().set_input_as_handled()
					return
		elif not event.pressed and event.index == _drag_index:
			get_viewport().set_input_as_handled()
			_drag_scroll = null
			_drag_index = -1
	elif event is InputEventScreenDrag and _drag_scroll != null and event.index == _drag_index:
		get_viewport().set_input_as_handled()
		_drag_scroll.scroll_vertical = _drag_value + int(_drag_origin.y - event.position.y)

func _sync_focus() -> void:
	var controls: Array[Control] = []
	_contributor.focus_mode = Control.FOCUS_NONE
	_facility_scroll.focus_mode = Control.FOCUS_NONE
	controls.append_array(_concepts)
	if current_stage == HeritageStage.MILESTONE_2019: controls.append(_contributor)
	if current_stage == HeritageStage.DEVELOPMENT: controls.append(_facility_scroll)
	controls.append(_scroll)
	HeaderUtilities.sync_focus(self, controls)

func open_sources() -> void:
	if not _open or _sources.visible:
		return
	_cancel_animations()
	super.open_sources()
	_normalize_views()
	for pair in [["2019 GROUNDBREAKING", _data.groundbreaking], ["LEOPOLDO N. BATAOIL", _data.contributor_image], ["PRESENT-SITE PHOTO", _data.present_site]]:
		if pair[1] != null:
			_source_text.text += "\n\n" + pair[0] + "\n" + pair[1].source_text()

func close_sources() -> void:
	_drag_scroll = null
	_drag_index = -1
	super.close_sources()
	_normalize_views()
	_sync_focus()

func _update_speaker() -> void:
	super._update_speaker()
	_speaker.show()
	_speaker.disabled = _audio.stream == null
	_pending.visible = _audio.stream == null
	if _header_utilities != null: _header_utilities.refresh()

func close_interaction() -> void:
	if not _open:
		return
	_cancel_animations()
	super.close_interaction()
	contributor_expanded = false
	_facility_scroll.scroll_vertical = 0
	_update_contributor()
	close_requested.emit()

func _visibility_changed() -> void:
	if _open and not is_visible_in_tree():
		close_interaction()

func _exit_tree() -> void:
	for tween in [_transition, _story_tween]:
		if tween != null and tween.is_valid():
			tween.kill()
	super._exit_tree()
