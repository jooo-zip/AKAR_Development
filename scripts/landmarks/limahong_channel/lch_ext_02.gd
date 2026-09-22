extends ConferenceRoomInteraction
## Shared embedded shell and Sources behavior; map state is local to this hotspot.
enum HistoricalStage { MANILA, NORTHWARD, PANGASINAN }
@export var display_font: Font
var current_stage: HistoricalStage = HistoricalStage.MANILA
var route_progress: float = 0.0
var _route_tween: Tween
var _stage_tween: Tween
var _map_region := VBoxContainer.new()
var _map_area := Control.new()
var _route := Line2D.new()
var _path := Path2D.new()
var _follower := PathFollow2D.new()
var _movement := Sprite2D.new()
var _markers: Array[Label] = []
var _location_markers: Array[Sprite2D] = []
var _settlement := Control.new()
var _settlement_image := Sprite2D.new()
var _settlement_base_position := Vector2.ZERO
var _stage_number := Label.new()
var _timeline := VBoxContainer.new()
var _notice := Label.new()
var _date := Label.new()
var _pending := Label.new()
var _placeholder := Label.new()
var _fitted := Rect2()

func _ready() -> void:
	super._ready()
	_map_region.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map_region.size_flags_stretch_ratio = 1.78
	%Columns.add_child(_map_region)
	%Columns.move_child(_map_region, 0)
	_map_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_map_region.add_child(_map_area)
	_image.reparent(_map_area)
	_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_map_area.add_child(_route)
	_route.name = "RouteLine"
	_route.antialiased = false
	_route.width = 3.0
	_route.default_color = Color("d8c58b")
	_path.name = "RoutePath"
	_follower.name = "RouteFollower"
	_map_area.add_child(_path)
	_path.add_child(_follower)
	_follower.loop = false
	_follower.rotates = false
	_follower.cubic_interp = false
	_follower.add_child(_movement)
	_movement.name = "RouteShip"
	_configure_sprite(_movement, content.route_ship, 44)
	_movement.position = Vector2.ZERO
	_movement.z_index = 2
	_movement.modulate.a = 0.0
	for title in ["MANILA", "PANGASINAN"]:
		var label := Label.new()
		label.text = title
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_shadow_color", Color.BLACK)
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_map_area.add_child(label)
		_markers.append(label)
		var marker := Sprite2D.new()
		_configure_sprite(marker, content.location_marker, 28)
		_map_area.add_child(marker)
		_location_markers.append(marker)
	_map_area.add_child(_settlement)
	_settlement.name = "SettlementIcon"
	_settlement.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settlement.add_child(_settlement_image)
	_configure_sprite(_settlement_image, content.fortified_settlement, 44)
	_placeholder.text = "DEVELOPMENT PLACEHOLDER\nRegional map pending"
	_placeholder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_placeholder.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_map_area.add_child(_placeholder)
	_map_region.add_child(_notice)
	_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notice.add_theme_font_size_override("font_size", 18)
	_notice.custom_minimum_size.y = 44
	_information.add_child(_date)
	_information.move_child(_date, 0)
	_information.add_child(_stage_number)
	_information.move_child(_stage_number, 0)
	_stage_number.add_theme_font_size_override("font_size", 16)
	_stage_number.add_theme_color_override("font_color", Color("d8c58b"))
	_information.add_child(_timeline)
	_timeline.add_theme_constant_override("separation", 6)
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
	_pending.text = "LCH-EXT-02   ·   Narration pending"
	_pending.add_theme_font_size_override("font_size", 16)
	$Main/Margin/Layout.add_child(_pending)
	$Main/Margin/Layout.move_child(_pending, 1)
	for button in _concepts:
		button.custom_minimum_size.y = 56
	_close.custom_minimum_size.y = 56
	_sources_button.custom_minimum_size.y = 56
	if display_font != null:
		for control in [_title, _heading, _date] + _concepts:
			control.add_theme_font_override("font", display_font)
	_map_area.resized.connect(_layout_map)
	resized.connect(_resize_layout)
	_resize_layout()

func open_interaction() -> bool:
	if content == null or content.get("stage_labels") == null or content.stage_labels.size() != 3 or content.date_labels.size() != 3:
		return false
	if _open:
		return true
	if not super.open_interaction():
		return false
	show_stage(HistoricalStage.MANILA, false)
	return true

func select_concept(index: int) -> void:
	show_stage(index as HistoricalStage)

func show_stage(stage: HistoricalStage, animate: bool = true) -> void:
	if not _open or _sources.visible or stage < 0 or stage > 2:
		return
	_cancel_route()
	_cancel_stage_effect()
	_cancel_fade()
	current_stage = stage
	_selected = stage
	_render()
	_notice.text = content.route_notice
	_notice.modulate.a = 0.0 if stage == HistoricalStage.MANILA else 1.0
	_route.modulate.a = 0.55 if stage == HistoricalStage.PANGASINAN else 1.0
	_movement.show()
	_movement.modulate.a = 1.0 if stage != HistoricalStage.PANGASINAN else 1.0
	_settlement.visible = stage == HistoricalStage.PANGASINAN
	_location_markers[1].visible = true
	_settlement.scale = Vector2.ONE
	_settlement.position = _settlement_base_position
	_layout_map()
	for i in _markers.size():
		_markers[i].modulate = Color("f3dfaa") if (i == 0 and stage != HistoricalStage.PANGASINAN) or (i == 1 and stage == HistoricalStage.PANGASINAN) else Color("aaaaaa")
		_location_markers[i].modulate = _markers[i].modulate
	_set_progress(0.0 if stage == HistoricalStage.MANILA or (stage == HistoricalStage.NORTHWARD and animate) else 1.0)
	if stage == HistoricalStage.NORTHWARD and animate:
		_route_tween = create_tween()
		_route_tween.tween_method(_set_progress, 0.0, 1.0, 2.5)
	if animate and stage == HistoricalStage.PANGASINAN:
		# Arrival transitions into establishment by replacement: the ship fades
		# out, then the settlement symbol scales in and settles.
		_settlement.modulate.a = 0.0
		_settlement.scale = Vector2.ONE * 0.82
		_settlement.position = _settlement_base_position
		_stage_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_stage_tween.tween_property(_movement, "modulate:a", 0.0, 0.18)
		_stage_tween.tween_callback(_movement.hide)
		_stage_tween.tween_callback(_location_markers[1].hide)
		_stage_tween.tween_property(_settlement, "modulate:a", 1.0, 0.08)
		_stage_tween.parallel().tween_property(_settlement, "scale", Vector2.ONE, 0.22)
		_stage_tween.tween_property(_settlement, "position:x", _settlement_base_position.x - 3.0, 0.04)
		_stage_tween.tween_property(_settlement, "position:x", _settlement_base_position.x + 3.0, 0.04)
		_stage_tween.tween_property(_settlement, "position:x", _settlement_base_position.x - 2.0, 0.04)
		_stage_tween.tween_property(_settlement, "position:x", _settlement_base_position.x + 2.0, 0.04)
		_stage_tween.tween_property(_settlement, "position:x", _settlement_base_position.x, 0.04)
	elif animate and stage == HistoricalStage.MANILA:
		_location_markers[0].modulate = Color.WHITE
		_stage_tween = create_tween()
		_stage_tween.tween_property(_location_markers[0], "modulate", Color("f3dfaa"), 0.25)
	_sync_focus()
	concept_changed.emit(stage)

func _render() -> void:
	super._render()
	_date.text = content.date_labels[_selected]
	_stage_number.text = "STAGE %02d / 03" % (_selected + 1)
	for i in _concepts.size():
		_concepts[i].text = content.stage_labels[i]
	_placeholder.visible = content.illustration == null

func _layout_map() -> void:
	if not is_node_ready():
		return
	var texture_size := _image.texture.get_size() if _image.texture != null else Vector2(2, 3)
	var fitted_size := texture_size * minf(_map_area.size.x / texture_size.x, _map_area.size.y / texture_size.y)
	_fitted = Rect2((_map_area.size - fitted_size) * 0.5, fitted_size)
	var destination: Vector2 = _fitted.position + content.pangasinan_anchor * _fitted.size
	for i in _markers.size():
		var anchor: Vector2 = content.manila_anchor if i == 0 else content.pangasinan_anchor
		_location_markers[i].position = _fitted.position + anchor * _fitted.size
		_markers[i].position = _location_markers[i].position + Vector2(18, -12)
	# The settlement symbol shares the destination coordinate with the Pangasinan pin.
	var symbol_size := 44.0 if size.x >= 950 else 36.0
	_set_sprite_size(_settlement_image, symbol_size)
	_settlement_image.position = Vector2.ZERO
	_settlement.position = Vector2(
		destination.x,
		destination.y
	)
	_settlement_base_position = _settlement.position
	var curve := Curve2D.new()
	curve.bake_interval = 2.0
	var route_points: PackedVector2Array = content.schematic_points.duplicate()
	if route_points.is_empty():
		route_points = PackedVector2Array([content.manila_anchor, content.pangasinan_anchor])
	else:
		route_points[0] = content.manila_anchor
		route_points[route_points.size() - 1] = content.pangasinan_anchor
	for point in route_points:
		curve.add_point(_fitted.position + point * _fitted.size)
	_path.curve = curve
	_set_progress(route_progress)

func _set_progress(value: float) -> void:
	route_progress = clampf(value, 0, 1)
	_route.clear_points()
	if _path.curve == null or _path.curve.get_baked_length() <= 0:
		_movement.hide()
		return
	_movement.show()
	# One normalized progress value drives the follower and the visible line.
	_follower.progress_ratio = route_progress
	var points := _path.curve.get_baked_points()
	var remaining := _path.curve.get_baked_length() * route_progress
	var endpoint := points[0]
	_route.add_point(endpoint)
	for i in range(1, points.size()):
		var target := points[i]
		var distance := endpoint.distance_to(target)
		if remaining < distance:
			endpoint = endpoint.lerp(target, remaining / maxf(distance, 0.001))
			_route.add_point(endpoint)
			break
		remaining -= distance
		endpoint = target
		_route.add_point(endpoint)
	_route.visible = route_progress > 0.0
	if current_stage == HistoricalStage.NORTHWARD:
		_markers[1].modulate = Color("aaaaaa").lerp(Color("f3dfaa"), route_progress)
		_location_markers[1].modulate = _markers[1].modulate

func _resize_layout() -> void:
	if not is_node_ready():
		return
	var compact := size.x < 950
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_heading.add_theme_font_size_override("font_size", 22 if compact else 24)
	_body.add_theme_font_size_override("font_size", 20 if compact else 22)
	_takeaway.add_theme_font_size_override("font_size", 18 if compact else 20)
	var sections := $Main/Margin/Layout/Sections
	var target: Container = sections if compact else _timeline
	for button in _concepts:
		if button.get_parent() != target:
			button.reparent(target)
		button.custom_minimum_size.y = 48 if compact else 52
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER if compact else HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 18 if compact else 20)
	sections.visible = compact
	_timeline.visible = not compact
	$Main/Margin/Layout.add_theme_constant_override("separation", 6 if compact else 10)
	_information.add_theme_constant_override("separation", 6 if compact else 10)
	if _open:
		_sync_focus()
	_layout_map.call_deferred()

func _configure_sprite(sprite: Sprite2D, texture: Texture2D, extent: float) -> void:
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if texture != null:
		# Trim only transparent padding at display time; source PNG remains unchanged.
		sprite.region_enabled = true
		sprite.region_rect = texture.get_image().get_used_rect()
		_set_sprite_size(sprite, extent)

func _set_sprite_size(sprite: Sprite2D, extent: float) -> void:
	if sprite.texture != null:
		sprite.scale = Vector2.ONE * extent / maxf(sprite.region_rect.size.x, sprite.region_rect.size.y)

func _sync_focus() -> void:
	# Keep the inherited Sources trap, return focus and keyboard navigation intact.
	var previous := get_viewport().gui_get_focus_owner()
	var main: Array[Control] = []
	main.append_array(_concepts)
	main.append_array([_speaker, _scroll, _sources_button, _close])
	var overlay: Array[Control] = [_source_scroll, _source_close]
	var active: Array[Control] = []
	for control in main + overlay:
		control.focus_mode = Control.FOCUS_NONE
	for control in (overlay if _sources.visible else main):
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

func _cancel_stage_effect() -> void:
	if _stage_tween != null and _stage_tween.is_valid():
		_stage_tween.kill()
	_stage_tween = null
	_settlement.modulate.a = 1.0
	_settlement.scale = Vector2.ONE
	_settlement.position = _settlement_base_position
	_movement.modulate.a = 1.0
	if _location_markers.size() > 1:
		_location_markers[1].show()

func _update_speaker() -> void:
	super._update_speaker()
	_speaker.show()
	_speaker.text = "STOP" if _audio.playing else "LISTEN"
	_pending.show()
	_pending.text = "LCH-EXT-02   ·   Narration pending" if _audio.stream == null else "LCH-EXT-02"

func _input(event: InputEvent) -> void:
	if not _open or _sources.visible:
		return
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
		var step := 1 if event.is_action_pressed("ui_right") else -1
		var target := clampi(current_stage + step, 0, 2)
		if target != current_stage:
			show_stage(target as HistoricalStage)
		_concepts[target].grab_focus()

func _cancel_route() -> void:
	if _route_tween != null and _route_tween.is_valid():
		_route_tween.kill()
	_route_tween = null

func close_interaction() -> void:
	_cancel_route()
	_cancel_stage_effect()
	super.close_interaction()

func _exit_tree() -> void:
	_cancel_route()
	_cancel_stage_effect()
	super._exit_tree()
