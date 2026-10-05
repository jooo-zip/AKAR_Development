extends "res://scripts/landmarks/urduja_house/uh_visual_explorer.gd"
## Focused extension of the existing discovery rail. The shared shell owns Sources/audio.
const DURATION: float = 0.22
var context_label: Label
var takeaway_label: Label
var history_sections: VBoxContainer
var media_column: VBoxContainer
var takeaway_margin: MarginContainer
var _shown: int = 0
var _initialized: bool = false

@export_category("Responsive compact layout")
@export var compact_breakpoint: float = 900.0
@export var compact_heading_size: int = 20
@export var compact_body_size: int = 18
@export var compact_column_gap: int = 12
@export var compact_text_gap: int = 6
@export_range(0.1, 0.9) var compact_media_ratio: float = 0.53
var _wide_layout: Dictionary
var _content_view: Node

func _ready() -> void:
	# Static UI is authored in the scene; do not run the inherited UI factory.
	picture = %MediaTexture
	heading = %Heading
	body = %Body
	caption = %MediaCaption
	track = %DiscoveryRail
	handle = %Selector
	text_scroll = %InfoScroll
	text_column = %InfoColumn
	columns = %ContentRow
	image_area = %MediaFrame
	context_label = %ContextLabel
	takeaway_label = %Takeaway
	history_sections = %HistorySections
	media_column = %MediaColumn
	takeaway_margin = %TakeawayMargin
	_content_view = $EditorContent
	_content_view.content = content
	_content_view.refresh()
	selectors.assign([%Place, %History, %Today])
	for i in selectors.size():
		selectors[i].pressed.connect(select_state.bind(i))
		selectors[i].gui_input.connect(_key_input.bind(i))
		selectors[i].gui_input.connect(_handle_input)
	track.gui_input.connect(_handle_input)
	handle.gui_input.connect(_handle_input)
	%Stops.sort_children.connect(_layout_rail)
	_wide_layout = {
		"heading": heading.get_theme_font_size("font_size"),
		"body": body.get_theme_font_size("font_size"),
		"column_gap": columns.get_theme_constant("separation"),
		"text_gap": text_column.get_theme_constant("separation"),
		"media_ratio": media_column.size_flags_stretch_ratio,
		"text_ratio": text_scroll.size_flags_stretch_ratio,
	}
	resized.connect(_responsive)
	_responsive()
	hide()

func _responsive() -> void:
	if _wide_layout.is_empty():
		return
	var compact := size.x < compact_breakpoint
	heading.add_theme_font_size_override("font_size", compact_heading_size if compact else _wide_layout.heading)
	body.add_theme_font_size_override("font_size", compact_body_size if compact else _wide_layout.body)
	columns.add_theme_constant_override("separation", compact_column_gap if compact else _wide_layout.column_gap)
	text_column.add_theme_constant_override("separation", compact_text_gap if compact else _wide_layout.text_gap)
	media_column.size_flags_stretch_ratio = compact_media_ratio if compact else _wide_layout.media_ratio
	text_scroll.size_flags_stretch_ratio = 1.0 - compact_media_ratio if compact else _wide_layout.text_ratio

func _point(index: int) -> float:
	return _content_view.stop_position(index).x

func _layout_rail() -> void:
	_cancel_move()
	_dragging = false
	_pointer = -2
	_content_view.align_rail(selected)

func _apply_state(index: int) -> void:
	_shown = index
	_content_view.refresh(index)
	text_scroll.scroll_vertical = 0

func _restore_opacity() -> void:
	for control in [picture, text_column, caption]:
		control.modulate.a = 1.0

func select_identity(index: int) -> void:
	if not active or not can_process() or index < 0 or index >= selectors.size():
		return
	var changed := index != selected
	selected = index
	_dragging = false
	_pointer = -2
	_cancel_move()
	if _fade != null:
		_fade.kill()
	_restore_opacity()
	for i in selectors.size():
		selectors[i].set_pressed_no_signal(i == index)
	if _initialized and (changed or _shown != index):
		_fade = create_tween()
		for control in [picture, text_column, caption]:
			_fade.parallel().tween_property(control, "modulate:a", 0.0, 0.09)
		_fade.chain().tween_callback(_apply_state.bind(index))
		for control in [picture, text_column, caption]:
			_fade.parallel().tween_property(control, "modulate:a", 1.0, 0.13)
	else:
		_apply_state(index)
	_initialized = true
	_move = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_move.tween_property(handle, "position:x", _point(index) - handle.size.x * 0.5, DURATION)
	track.queue_redraw()
	selection_changed.emit(index)

func _handle_input(event: InputEvent) -> void:
	if not active or not can_process():
		return
	super._handle_input(event)

func _input(event: InputEvent) -> void:
	if not _dragging or not active or not can_process():
		return
	var matches_pointer: bool = (_pointer == -1 and (event is InputEventMouseMotion or event is InputEventMouseButton)) or (event is InputEventScreenDrag and event.index == _pointer) or (event is InputEventScreenTouch and event.index == _pointer)
	if not matches_pointer:
		return
	var local: Vector2 = track.get_global_transform_with_canvas().affine_inverse() * event.position
	handle.position.x = clampf(local.x, _point(0), _point(2)) - handle.size.x * 0.5
	get_viewport().set_input_as_handled()
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and (not event.pressed or (event is InputEventScreenTouch and event.canceled)):
		select_identity(roundi((handle.position.x + handle.size.x * 0.5 - _point(0)) / maxf(1, _point(2) - _point(0)) * 2))

func close_interaction() -> void:
	# Reset immediately as well as on reopen; no deferred transition may restore old media.
	if _fade != null:
		_fade.kill()
	_cancel_move()
	selected = 0
	_initialized = false
	_pointer = -2
	_apply_state(0)
	_restore_opacity()
	for i in selectors.size():
		selectors[i].set_pressed_no_signal(i == 0)
	_layout_rail()
	super.close_interaction()
