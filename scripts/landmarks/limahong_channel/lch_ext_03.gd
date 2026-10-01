extends ConferenceRoomInteraction
const SourcesOverlay = preload("res://scripts/landmarks/limahong_channel/lch_sources_overlay.gd")
const HeaderUtilities = preload("res://scripts/landmarks/limahong_channel/lch_header_utilities.gd")
var _header_utilities: HeaderUtilities
## Four cumulative historical layers within the existing embedded panel shell.
const SiegeContent = preload("res://scripts/landmarks/limahong_channel/lch_ext_03_content.gd")
enum HistoricalStage { SETTLEMENT, BLOCKADE, PASSAGE, ESCAPE }

signal stage_changed(stage_index: int)

var current_stage: HistoricalStage = HistoricalStage.SETTLEMENT
var passage_progress: float = 0.0
var escape_progress: float = 0.0
var _data: SiegeContent
var _stage_tween: Tween
var _map_area := Control.new()
var _settlement := Node2D.new()
var _settlement_image := Sprite2D.new()
var _settlement_label := Label.new()
var _blockade := Node2D.new()
var _blockade_markers: Array[Node2D] = []
var _blockade_images: Array[Sprite2D] = []
var _passage := Line2D.new()
var _path := Path2D.new()
var _follower := PathFollow2D.new()
var _vessel := Sprite2D.new()
var _timeline := VBoxContainer.new()
var _stage_number := Label.new()
var _date := Label.new()
var _notice := Label.new()
var _disclaimer := Label.new()
var _pending := Label.new()
var _placeholder := Label.new()
var _fitted := Rect2()


func _ready() -> void:
	# The shared shell wires all buttons in _concepts, including our fourth stage.
	var escape_button := Button.new()
	escape_button.name = "EscapeStage"
	escape_button.toggle_mode = true
	escape_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$Main/Margin/Layout/Sections.add_child(escape_button)
	_concepts.append(escape_button)
	super._ready()
	_data = content as SiegeContent
	_map_area.name = "HistoricalMap"
	_map_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map_area.size_flags_stretch_ratio = 1.85
	%Columns.add_child(_map_area)
	%Columns.move_child(_map_area, 0)
	_image.reparent(_map_area)
	_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_map_area.add_child(_passage)
	_passage.name = "PassageLine"
	_passage.width = 2.0
	_passage.default_color = Color("eee0b1")
	_passage.antialiased = false
	_map_area.add_child(_settlement)
	_settlement.name = "SettlementLayer"
	_settlement.add_child(_settlement_image)
	_map_area.add_child(_settlement_label)
	_settlement_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settlement_label.add_theme_font_size_override("font_size", 16)
	_settlement_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	_settlement_label.add_theme_constant_override("shadow_offset_x", 2)
	_settlement_label.add_theme_constant_override("shadow_offset_y", 2)
	_map_area.add_child(_blockade)
	_blockade.name = "BlockadeLayer"
	for i in 4:
		var marker := Node2D.new()
		marker.name = "BlockadeMarker%02d" % (i + 1)
		var sprite := Sprite2D.new()
		_blockade.add_child(marker)
		marker.add_child(sprite)
		_blockade_markers.append(marker)
		_blockade_images.append(sprite)
	_map_area.add_child(_path)
	_path.name = "EscapePath"
	_path.add_child(_follower)
	_follower.name = "EscapeFollower"
	_follower.loop = false
	_follower.rotates = false
	_follower.cubic_interp = false
	_follower.add_child(_vessel)
	_vessel.name = "EscapeVessel"
	_placeholder.text = "DEVELOPMENT FALLBACK\nTactical map unavailable"
	_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_placeholder.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_map_area.add_child(_placeholder)
	_placeholder.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_information.add_child(_date)
	_information.move_child(_date, 0)
	_information.add_child(_stage_number)
	_information.move_child(_stage_number, 0)
	_stage_number.add_theme_font_size_override("font_size", 16)
	_stage_number.add_theme_color_override("font_color", Color("d8c58b"))
	_information.add_child(_timeline)
	_timeline.add_theme_constant_override("separation", 4)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_heading.reparent(_body.get_parent())
	_body.get_parent().move_child(_heading, 0)
	$Main/Margin/Layout/Columns/Information/Meta.hide()
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var header := $Main/Margin/Layout/Header
	_speaker.reparent(header)
	header.move_child(_speaker, 1)
	_sources_button.reparent(header)
	header.move_child(_sources_button, 2)
	_sources_button.add_theme_font_size_override("font_size", 16)
	$Main/Margin/Layout/Controls.hide()
	var layout := $Main/Margin/Layout
	layout.add_child(_pending)
	layout.move_child(_pending, 1)
	_pending.add_theme_font_size_override("font_size", 16)
	layout.add_child(_notice)
	layout.add_child(_disclaimer)
	for label in [_notice, _disclaimer]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 16)
	_notice.add_theme_color_override("font_color", Color("eee0b1"))
	for button in [_close, _speaker, _sources_button]:
		button.custom_minimum_size.y = 48
	_map_area.resized.connect(_layout_map)
	resized.connect(_resize_layout)
	_resize_layout()
	_header_utilities = HeaderUtilities.new(self, _pending)
	add_child(SourcesOverlay.new(self))

func open_interaction() -> bool:
	# The shared opener validates exactly three concepts. Keep its lifecycle here
	# for four stages without changing existing hotspot or shared component files.
	_data = content as SiegeContent
	if not is_node_ready() or _data == null or _data.concepts.size() != 4:
		return false
	if _data.stage_labels.size() != 4 or _data.date_labels.size() != 4 or _data.stage_notices.size() != 4 or _data.blockade_anchors.size() != 4:
		return false
	for entry in _data.concepts:
		if entry == null:
			return false
	if _open:
		return true
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_title.text = _data.title
	_image.texture = _data.illustration
	_image.accessibility_name = _data.illustration_alt_text
	_settlement_label.text = _data.settlement_label
	_configure_sprite(_settlement_image, _data.fortified_settlement)
	_configure_sprite(_vessel, _data.escape_vessel)
	for sprite in _blockade_images:
		_configure_sprite(sprite, _data.blockade_marker)
	_audio.stream = _data.narration_stream
	_audio.stop()
	_speaker.disabled = _audio.stream == null
	_update_speaker()
	_sources.hide()
	_open = true
	show()
	show_stage(HistoricalStage.SETTLEMENT)
	_resize_layout()
	_concepts[0].grab_focus()
	opened.emit()
	return true


func select_concept(index: int) -> void:
	show_stage(index as HistoricalStage)


func show_stage(stage: HistoricalStage, animate: bool = true) -> void:
	if not _open or _sources.visible or stage < 0 or stage > HistoricalStage.ESCAPE:
		return
	_cancel_animation()
	_cancel_fade()
	current_stage = stage
	_selected = stage
	_apply_layers()
	_render()
	if animate:
		_animate_stage()
	_sync_focus()
	concept_changed.emit(stage)
	stage_changed.emit(stage)


func _apply_layers() -> void:
	_settlement.show()
	_settlement_label.show()
	_blockade.visible = current_stage >= HistoricalStage.BLOCKADE
	_vessel.visible = current_stage == HistoricalStage.ESCAPE
	_layout_map()
	_set_passage_progress(1.0 if current_stage >= HistoricalStage.PASSAGE else 0.0)
	_set_escape_progress(1.0 if current_stage == HistoricalStage.ESCAPE else 0.0)


func _render() -> void:
	super._render()
	_stage_number.text = "STAGE %02d / 04" % (current_stage + 1)
	_date.text = _data.date_labels[current_stage]
	_notice.text = _data.stage_notices[current_stage]
	# Reserve the notice row to avoid changing map bounds on stage selection.
	_notice.modulate.a = 0.0 if _notice.text.is_empty() else 1.0
	if _notice.text.is_empty():
		_notice.text = " "
	for i in _concepts.size():
		_concepts[i].text = _data.stage_labels[i]
	_placeholder.visible = _data.illustration == null
	_update_disclaimer()


func _animate_stage() -> void:
	_stage_tween = create_tween()
	match current_stage:
		HistoricalStage.SETTLEMENT:
			_settlement.modulate.a = 0.0
			_settlement.scale = Vector2.ONE * 0.88
			_stage_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			_stage_tween.tween_property(_settlement, "modulate:a", 1.0, 0.36)
			_stage_tween.parallel().tween_property(_settlement, "scale", Vector2.ONE, 0.36)
		HistoricalStage.BLOCKADE:
			for marker in _blockade_markers:
				marker.modulate.a = 0.0
				marker.scale = Vector2.ONE * 0.85
				_stage_tween.tween_property(marker, "modulate:a", 1.0, 0.20)
				_stage_tween.parallel().tween_property(marker, "scale", Vector2.ONE, 0.20).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		HistoricalStage.PASSAGE:
			_set_passage_progress(0.0)
			_stage_tween.tween_method(_set_passage_progress, 0.0, 1.0, 1.35)
		HistoricalStage.ESCAPE:
			_set_escape_progress(0.0)
			_stage_tween.tween_method(_set_escape_progress, 0.0, 1.0, 2.25)
	_stage_tween.finished.connect(_finish_animation)


func _finish_animation() -> void:
	_stage_tween = null
	_reset_transforms()
	_apply_layers()


func _cancel_animation() -> void:
	if _stage_tween != null and _stage_tween.is_valid():
		_stage_tween.kill()
	_stage_tween = null
	_reset_transforms()


func _reset_transforms() -> void:
	for node in [_settlement, _vessel] + _blockade_markers:
		node.modulate = Color.WHITE
		node.rotation = 0.0
	# Sprite scale only fits artwork; animation belongs to the layer wrappers.
	_settlement.scale = Vector2.ONE
	_vessel.position = Vector2.ZERO
	for marker in _blockade_markers:
		marker.scale = Vector2.ONE
	_passage.modulate = Color.WHITE


func _layout_map() -> void:
	if not is_node_ready() or _data == null:
		return
	var texture_size := _image.texture.get_size() if _image.texture != null else Vector2(16, 9)
	var fitted_size := texture_size * minf(_map_area.size.x / texture_size.x, _map_area.size.y / texture_size.y)
	_fitted = Rect2((_map_area.size - fitted_size) * 0.5, fitted_size)
	_settlement.position = _map_point(_data.settlement_anchor)
	var compact := size.x < 950
	# Used rectangles include the supplied faint edge pixels; these extents give
	# the opaque settlement about 50 px at the wide layout, 36 px when compact.
	_set_sprite_size(_settlement_image, 56.0 if compact else 80.0)
	_set_sprite_size(_vessel, 32.0 if compact else 40.0)
	_settlement_label.position = _settlement.position + Vector2(-_settlement_label.size.x * 0.5, -44.0 if compact else -53.0)
	for i in _blockade_markers.size():
		_blockade_markers[i].position = _map_point(_data.blockade_anchors[i])
		_set_sprite_size(_blockade_images[i], 44.0 if compact else 48.0)
	var curve := Curve2D.new()
	curve.bake_interval = 2.0
	curve.add_point(_map_point(_data.settlement_anchor))
	for point in _data.passage_points:
		curve.add_point(_map_point(point))
	curve.add_point(_map_point(_data.water_exit_anchor))
	_path.curve = curve
	_set_passage_progress(passage_progress)
	_set_escape_progress(escape_progress)


func _map_point(anchor: Vector2) -> Vector2:
	return _fitted.position + anchor * _fitted.size


func _set_passage_progress(value: float) -> void:
	passage_progress = clampf(value, 0.0, 1.0)
	_passage.clear_points()
	_passage.visible = current_stage >= HistoricalStage.PASSAGE and passage_progress > 0.0
	if _path.curve == null or _path.curve.get_baked_length() <= 0.0:
		return
	# Use the same baked curve as the vessel so line and follower cannot diverge.
	var points := _path.curve.get_baked_points()
	var remaining := _path.curve.get_baked_length() * passage_progress
	var endpoint := points[0]
	_passage.add_point(endpoint)
	for i in range(1, points.size()):
		var target := points[i]
		var distance := endpoint.distance_to(target)
		if remaining < distance:
			_passage.add_point(endpoint.lerp(target, remaining / maxf(distance, 0.001)))
			break
		remaining -= distance
		endpoint = target
		_passage.add_point(endpoint)


func _set_escape_progress(value: float) -> void:
	escape_progress = clampf(value, 0.0, 1.0)
	# Containers can have zero bounds before their first layout after opening.
	if _path.curve != null and _path.curve.get_baked_length() > 0.0:
		_follower.progress_ratio = escape_progress


func _configure_sprite(sprite: Sprite2D, texture: Texture2D) -> void:
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = texture
	if texture != null:
		sprite.region_enabled = true
		sprite.region_rect = texture.get_image().get_used_rect()


func _set_sprite_size(sprite: Sprite2D, extent: float) -> void:
	if sprite.texture != null:
		sprite.scale = Vector2.ONE * extent / maxf(sprite.region_rect.size.x, sprite.region_rect.size.y)


func _resize_layout() -> void:
	if not is_node_ready():
		return
	var compact := size.x < 950
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_heading.add_theme_font_size_override("font_size", 22 if compact else 24)
	_body.add_theme_font_size_override("font_size", 20 if compact else 22)
	var sections := $Main/Margin/Layout/Sections
	var target: Container = sections if compact else _timeline
	for button in _concepts:
		if button.get_parent() != target:
			button.reparent(target)
		button.custom_minimum_size = Vector2(48, 48)
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER if compact else HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 16 if compact else 20)
	sections.visible = compact
	_timeline.visible = not compact
	$Main/Margin/Layout.add_theme_constant_override("separation", 6 if compact else 8)
	_information.add_theme_constant_override("separation", 6)
	_update_disclaimer()
	if _open:
		_sync_focus()
	_layout_map.call_deferred()


func _update_disclaimer() -> void:
	if _data != null:
		_disclaimer.text = _data.compact_disclaimer if size.x < 800 else _data.permanent_disclaimer


func open_sources() -> void:
	if not _open or _sources.visible:
		return
	show_stage(current_stage, false)
	super.open_sources()


func _update_speaker() -> void:
	super._update_speaker()
	_speaker.show()
	_speaker.text = "STOP" if _audio.playing else "LISTEN"
	_pending.text = "LCH-EXT-03   ·   Narration pending" if _audio.stream == null else "LCH-EXT-03"
	if _header_utilities != null: _header_utilities.refresh()

func _input(event: InputEvent) -> void:
	if not _open or _sources.visible:
		return
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
		var step := 1 if event.is_action_pressed("ui_right") else -1
		var target := clampi(current_stage + step, 0, HistoricalStage.ESCAPE)
		if target != current_stage:
			show_stage(target as HistoricalStage)
		_concepts[target].grab_focus()


func close_interaction() -> void:
	_cancel_animation()
	current_stage = HistoricalStage.SETTLEMENT
	_selected = 0
	if _data != null:
		_apply_layers()
	super.close_interaction()


func _exit_tree() -> void:
	_cancel_animation()
	super._exit_tree()

func _sync_focus() -> void:
	var controls: Array[Control] = []
	controls.append_array(_concepts)
	controls.append(_scroll)
	HeaderUtilities.sync_focus(self, controls)
