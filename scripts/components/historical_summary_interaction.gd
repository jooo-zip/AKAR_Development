class_name HistoricalSummaryInteraction
extends Control
## Parent-sized single-summary review. Navigation belongs to the parent controller.

signal opened
signal closed
signal summary_changed(index: int)
signal return_to_map_requested

@export var content: HistoricalSummaryContent

@onready var _title: Label = %Title
@onready var _introduction: Label = %Introduction
@onready var _close: Button = %Close
@onready var _selected_panel: HBoxContainer = %SelectedPanel
@onready var _icon: TextureRect = %Icon
@onready var _heading: Label = %Heading
@onready var _body: Label = %Body
@onready var _scroll: ScrollContainer = %Scroll
@onready var _return_button: Button = %Return
@onready var _points: Array[Button] = [%Point1, %Point2, %Point3, %Point4, %Point5]

@onready var _previous: Button = %Previous
@onready var _next: Button = %Next
@onready var _track: Control = %Track
@onready var _marker: TextureRect = %VisitorMarker

var _move: Tween
var _shimmer: Tween
var _glint_alpha: float = 0.0
var _glint_x: float = 0.0
var _glint_from: float = 0.0
var _glint_to: float = 0.0

var _open: bool = false
var _selected: int = 0
var _return_focus: WeakRef
var _fade: Tween


func _ready() -> void:
	hide()
	_close.pressed.connect(close_interaction)
	_return_button.pressed.connect(request_return_to_map)
	_previous.pressed.connect(func() -> void: select_summary(posmod(_selected - 1, _points.size())))
	_next.pressed.connect(func() -> void: select_summary((_selected + 1) % _points.size()))
	_track.draw.connect(_draw_track)
	_track.resized.connect(_layout_track)
	# Preserve the supplied PNG; ignore transparent padding through an AtlasTexture.
	var marker_image := _marker.texture.get_image()
	var marker_region := AtlasTexture.new()
	marker_region.atlas = _marker.texture
	marker_region.region = Rect2(marker_image.get_used_rect())
	marker_region.filter_clip = true
	_marker.texture = marker_region
	for i in _points.size():
		_points[i].pressed.connect(select_summary.bind(i))


func open_interaction() -> bool:
	if not is_node_ready() or content == null or content.summary_entries.size() != 5:
		return false
	for entry in content.summary_entries:
		if entry == null:
			return false
	if _open:
		return true
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_title.text = content.title
	_introduction.text = content.introduction
	_return_button.text = content.return_button_label
	for i in _points.size():
		_points[i].text = str(i + 1)
		_points[i].tooltip_text = content.summary_entries[i].title
		_points[i].accessibility_name = content.summary_entries[i].title
	_selected = 0
	_cancel_fade()
	_open = true
	show()
	_render()
	_layout_track.call_deferred()
	_sync_focus()
	_points[0].grab_focus()
	opened.emit()
	return true


func select_summary(index: int) -> void:
	if not _open or index < 0 or index >= _points.size():
		return
	if index == _selected:
		_render()
		return
	var movement_start := _marker.position.x + 28.0
	_selected = index
	_cancel_fade()
	_render()
	_move_marker()
	_start_shimmer(movement_start)
	_selected_panel.modulate.a = 0.65
	_fade = create_tween()
	_fade.tween_property(_selected_panel, "modulate:a", 1.0, 0.2)
	summary_changed.emit(index)


func get_selected_summary() -> int:
	return _selected


func _render() -> void:
	var entry := content.summary_entries[_selected]
	_heading.text = entry.title
	_body.text = entry.body
	_icon.texture = entry.icon
	_icon.accessibility_name = entry.icon_alt_text
	for i in _points.size():
		_points[i].set_pressed_no_signal(i == _selected)
	_scroll.scroll_vertical = 0


func request_return_to_map() -> void:
	if not _open:
		return
	# A future parent may remove this component synchronously in its signal handler.
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
	return_to_map_requested.emit()


func _sync_focus() -> void:
	var controls: Array[Control] = []
	controls.append(_previous)
	controls.append_array(_points)
	controls.append(_next)
	controls.append_array([_return_button, _scroll, _close])
	for i in controls.size():
		controls[i].focus_mode = Control.FOCUS_ALL
		controls[i].focus_next = controls[i].get_path_to(controls[(i + 1) % controls.size()])
		controls[i].focus_previous = controls[i].get_path_to(controls[posmod(i - 1, controls.size())])


func _unhandled_input(event: InputEvent) -> void:
	if not _open or not event.is_action_pressed(&"go_back"):
		return
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
	if not event.is_echo():
		close_interaction()


func close_interaction() -> void:
	if not _open:
		return
	_open = false
	_cancel_move()
	_cancel_shimmer()
	_cancel_fade()
	hide()
	_restore_focus.call_deferred()
	closed.emit()


func _restore_focus() -> void:
	if _open or not is_inside_tree() or _return_focus == null:
		return
	var previous := _return_focus.get_ref() as Control
	if is_instance_valid(previous) and previous.is_visible_in_tree() and previous.focus_mode != Control.FOCUS_NONE:
		previous.grab_focus()


func _cancel_fade() -> void:
	if _fade != null and _fade.is_valid():
		_fade.kill()
	_fade = null
	if is_instance_valid(_selected_panel):
		_selected_panel.modulate.a = 1.0


func _exit_tree() -> void:
	_cancel_move()
	_cancel_shimmer()
	_cancel_fade()


func _point_x(index: int) -> float:
	# Local track coordinates only; endpoint padding preserves the 64px hit areas.
	return lerpf(32.0, maxf(32.0, _track.size.x - 32.0), float(index) / 4.0)


func _layout_track() -> void:
	_cancel_move()
	_cancel_shimmer()
	for i in _points.size():
		_points[i].position = Vector2(_point_x(i) - 32.0, 60.0)
		_points[i].size = Vector2(64.0, 64.0)
	_marker.position = Vector2(_point_x(_selected) - 28.0, 0.0)
	_track.queue_redraw()


func _move_marker() -> void:
	_cancel_move()
	_move = create_tween()
	_move.tween_property(_marker, "position", Vector2(_point_x(_selected) - 28.0, 0.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _cancel_move() -> void:
	if _move != null and _move.is_valid():
		_move.kill()
	_move = null


func _draw_track() -> void:
	_track.draw_line(Vector2(_point_x(0), 92.0), Vector2(_point_x(4), 92.0), Color(0.66, 0.7, 0.6), 2.0)
	if _glint_alpha > 0.0:
		var low := minf(_glint_from, _glint_to)
		var high := maxf(_glint_from, _glint_to)
		var start := Vector2(maxf(low, _glint_x - 14.0), 92.0)
		var end := Vector2(minf(high, _glint_x + 14.0), 92.0)
		# Layered low-opacity strokes provide a soft glint without shaders or particles.
		_track.draw_line(start, end, Color(0.92, 0.83, 0.60, _glint_alpha * 0.22), 10.0, true)
		_track.draw_line(start, end, Color(0.94, 0.87, 0.68, _glint_alpha * 0.4), 6.0, true)
		_track.draw_line(start, end, Color(0.98, 0.93, 0.78, _glint_alpha), 2.0, true)


func _start_shimmer(from_x: float) -> void:
	_cancel_shimmer()
	_glint_from = from_x
	_glint_to = _point_x(_selected)
	_shimmer = create_tween()
	_shimmer.tween_method(_update_shimmer, 0.0, 1.0, 0.35)


func _update_shimmer(phase: float) -> void:
	# Travel alongside the 200ms marker slide, then fade quietly after arrival.
	var travel := clampf(phase * 0.35 / 0.2, 0.0, 1.0)
	var eased := (1.0 - cos(travel * PI)) * 0.5
	_glint_x = lerpf(_glint_from, _glint_to, eased)
	_glint_alpha = sin(phase * PI) * 0.22 if phase < 1.0 else 0.0
	_track.queue_redraw()


func _cancel_shimmer() -> void:
	if _shimmer != null and _shimmer.is_valid():
		_shimmer.kill()
	_shimmer = null
	_glint_alpha = 0.0
	if is_instance_valid(_track):
		_track.queue_redraw()
