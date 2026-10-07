extends ConferenceRoomInteraction
const Lifecycle = preload("res://scripts/landmarks/limahong_channel/lch_lifecycle.gd")
const SourcesOverlay = preload("res://scripts/landmarks/limahong_channel/lch_sources_overlay.gd")
const HeaderUtilities = preload("res://scripts/landmarks/limahong_channel/lch_header_utilities.gd")
var _header_utilities: HeaderUtilities
## Shared embedded shell and Sources behavior; map state is local to this hotspot.
enum HistoricalStage { MANILA, NORTHWARD, PANGASINAN }
@export var display_font: Font
var current_stage: HistoricalStage = HistoricalStage.MANILA
var route_progress: float = 0.0
var _route_tween: Tween
var _stage_tween: Tween
# Read by lch_ext_02_test.gd to verify the map's share of the layout.
@warning_ignore("unused_private_class_variable")
@onready var _map_region: VBoxContainer = $"Main/Margin/Layout/Columns/MapRegion"
@onready var _map_area: Control = $"Main/Margin/Layout/Columns/MapRegion/MapArea"
@onready var _route: Line2D = $"Main/Margin/Layout/Columns/MapRegion/MapArea/RouteLine"
@onready var _path: Path2D = $"Main/Margin/Layout/Columns/MapRegion/MapArea/RoutePath"
@onready var _follower: PathFollow2D = $"Main/Margin/Layout/Columns/MapRegion/MapArea/RoutePath/RouteFollower"
@onready var _movement: Sprite2D = $"Main/Margin/Layout/Columns/MapRegion/MapArea/RoutePath/RouteFollower/RouteShip"
@onready var _markers: Array[Label] = [$"Main/Margin/Layout/Columns/MapRegion/MapArea/Markers0", $"Main/Margin/Layout/Columns/MapRegion/MapArea/Markers1"]
@onready var _location_markers: Array[Sprite2D] = [$"Main/Margin/Layout/Columns/MapRegion/MapArea/LocationMarkers0", $"Main/Margin/Layout/Columns/MapRegion/MapArea/LocationMarkers1"]
@onready var _settlement: Control = $"Main/Margin/Layout/Columns/MapRegion/MapArea/SettlementIcon"
@onready var _settlement_image: Sprite2D = $"Main/Margin/Layout/Columns/MapRegion/MapArea/SettlementIcon/SettlementImage"
var _settlement_base_position := Vector2.ZERO
@onready var _stage_number: Label = $"Main/Margin/Layout/Columns/Information/StageNumber"
@onready var _timeline: VBoxContainer = $"Main/Margin/Layout/Columns/Information/Timeline"
@onready var _notice: Label = $"Main/Margin/Layout/Columns/MapRegion/Notice"
@onready var _date: Label = $"Main/Margin/Layout/Columns/Information/Date"
@onready var _pending: Label = $"Main/Margin/Layout/Header/HeaderUtilityArea/NarrationStatusSlot/Pending"
@onready var _placeholder: Label = $"Main/Margin/Layout/Columns/MapRegion/MapArea/Placeholder"
var _fitted := Rect2()

func _ready() -> void:
	super._ready()
	_bind_authored_content()
	_configure_sprite(_movement, content.route_ship, 44)
	for marker in _location_markers:
		_configure_sprite(marker, content.location_marker, 28)
	_configure_sprite(_settlement_image, content.fortified_settlement, 44)
	if display_font != null:
		for control in [_title, _heading, _date] + _concepts:
			control.add_theme_font_override("font", display_font)
	_map_area.resized.connect(_layout_map)
	resized.connect(_resize_layout)
	_resize_layout()
	_header_utilities = HeaderUtilities.new(self, _pending)
	add_child(SourcesOverlay.new(self))

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
		_markers[i].modulate = Color("e8d5b4") if (i == 0 and stage != HistoricalStage.PANGASINAN) or (i == 1 and stage == HistoricalStage.PANGASINAN) else Color("aaaaaa")
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
		_stage_tween.tween_property(_location_markers[0], "modulate", Color("e8d5b4"), 0.25)
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
		_markers[1].modulate = Color("aaaaaa").lerp(Color("e8d5b4"), route_progress)
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
	var controls: Array[Control] = []
	controls.append_array(_concepts)
	controls.append(_scroll)
	HeaderUtilities.sync_focus(self, controls)

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
	_pending.show()
	_pending.text = "LCH-EXT-02   ·   Narration pending" if _audio.stream == null else "LCH-EXT-02"
	if _header_utilities != null: _header_utilities.refresh()

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

func _bind_authored_content() -> void:
	# Resources remain the only authority for interpretation copy.
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/Body").text = content.concepts[0].body
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/Heading").text = content.concepts[0].heading
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/Takeaway").text = content.learning_takeaway
	get_node("Main/Margin/Layout/Columns/MapRegion/Notice").text = content.route_notice
	get_node("Main/Margin/Layout/Header/TitleArea/Label1").text = content.hotspot_id
	get_node("Main/Margin/Layout/Header/TitleArea/Title").text = content.title


func reset_interaction() -> void:
	Lifecycle.reset(self)
