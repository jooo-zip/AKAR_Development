class_name InteractiveTimeline
extends Control
## Discrete timeline navigation; no landmark-specific history or audio seeking.

signal opened
signal closed
signal milestone_changed(index: int)
signal narration_started
signal narration_stopped
signal sources_opened
signal sources_closed

@export var content: InteractiveTimelineContent
@export var show_development_pending: bool = false

@onready var _title: Label = $Main/Margin/Layout/Header/Title
@onready var _close: Button = $Main/Margin/Layout/Header/Close
@onready var _columns: HBoxContainer = $Main/Margin/Layout/Columns
@onready var _image: TextureRect = $Main/Margin/Layout/Columns/Media/Image
@onready var _no_image: Label = $Main/Margin/Layout/Columns/Media/NoImage
@onready var _date: Label = $Main/Margin/Layout/Columns/ContentFrame/Margin/Content/Meta/Date
@onready var _heading: Label = $Main/Margin/Layout/Columns/ContentFrame/Margin/Content/Heading
@onready var _scroll: ScrollContainer = $Main/Margin/Layout/Columns/ContentFrame/Margin/Content/Scroll
@onready var _body: Label = $Main/Margin/Layout/Columns/ContentFrame/Margin/Content/Scroll/Body
@onready var _sources_button: Button = $Main/Margin/Layout/Columns/ContentFrame/Margin/Content/Meta/Sources
@onready var _speaker: Button = $Main/Margin/Layout/TimelineArea/AudioMargin/AudioRow/Speaker
@onready var _audio_pending: Label = $Main/Margin/Layout/TimelineArea/AudioMargin/AudioRow/Pending
@onready var _track: Control = $Main/Margin/Layout/TimelineArea/Track
@onready var _handle: Button = $Main/Margin/Layout/TimelineArea/Track/Handle
@onready var _sources: PanelContainer = $Sources
@onready var _source_title: Label = $Sources/Margin/Layout/Title
@onready var _source_scroll: ScrollContainer = $Sources/Margin/Layout/Scroll
@onready var _source_text: Label = $Sources/Margin/Layout/Scroll/Text
@onready var _source_close: Button = $Sources/Margin/Layout/Close
@onready var _audio: AudioStreamPlayer = $NarrationPlayer

const TRACK_INSET: float = 80.0
const HANDLE_SIZE: float = 56.0
const TRACK_Y: float = 76.0
const SNAP_SECONDS: float = 0.2

var _open: bool = false
var _selected: int = 0
var _displayed: int = 0
var _return_focus: WeakRef
var _labels: Array[Button] = []
var _nodes: Array[Button] = []
var _snap: Tween
var _fade: Tween
var _dragging: bool = false
var _touch_index: int = -1
var _drag_offset: float = 0.0


func _ready() -> void:
	hide()
	_close.pressed.connect(close_interaction)
	_sources_button.pressed.connect(open_sources)
	_source_close.pressed.connect(close_sources)
	_speaker.pressed.connect(toggle_narration)
	_audio.finished.connect(stop_narration)
	_handle.gui_input.connect(_handle_input)
	_track.draw.connect(_draw_track)
	_track.resized.connect(_layout_track)


func open_interaction(return_focus: Control = null) -> bool:
	if not is_node_ready() or content == null or content.entries.size() < 2:
		return false
	for entry in content.entries:
		if entry == null or entry.date_label.is_empty():
			return false
	if _open:
		return true
	var previous := return_focus if return_focus != null else get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_title.text = content.title
	_build_milestones()
	_selected = 0
	_show_entry(0)
	_update_selection()
	_audio.stream = content.narration_stream
	_audio.stop()
	_speaker.visible = _audio.stream != null or show_development_pending
	_speaker.disabled = _audio.stream == null
	_audio_pending.visible = _audio.stream == null and show_development_pending
	_update_speaker()
	_sources.hide()
	_columns.modulate.a = 1.0
	_open = true
	show()
	_layout_track.call_deferred()
	_sync_focus()
	_labels[0].grab_focus()
	opened.emit()
	return true


func is_interaction_open() -> bool:
	return _open


func get_selected_index() -> int:
	return _selected


func _build_milestones() -> void:
	for button in _labels + _nodes:
		_track.remove_child(button)
		button.queue_free()
	_labels.clear()
	_nodes.clear()
	for index in content.entries.size():
		for is_label in [true, false]:
			var button := Button.new()
			button.text = content.entries[index].date_label if is_label else "●"
			button.accessibility_name = content.entries[index].date_label
			button.toggle_mode = true
			button.pressed.connect(select_milestone.bind(index))
			_track.add_child(button)
			if is_label:
				_labels.append(button)
			else:
				_nodes.append(button)
	_track.move_child(_handle, -1)


func _point(index: int) -> float:
	return lerpf(TRACK_INSET, _track.size.x - TRACK_INSET, float(index) / float(maxi(1, _labels.size() - 1)))


func _layout_track() -> void:
	if not is_node_ready() or _labels.is_empty():
		return
	_cancel_snap()
	_dragging = false
	_touch_index = -1
	for index in _labels.size():
		_labels[index].position = Vector2(_point(index) - 76, 0)
		_labels[index].size = Vector2(152, 48)
		_nodes[index].position = Vector2(_point(index) - 28, TRACK_Y - 28)
		_nodes[index].size = Vector2(56, 56)
	_handle.position = Vector2(_point(_selected) - 28, TRACK_Y - 28)
	_track.queue_redraw()


func _draw_track() -> void:
	_track.draw_line(Vector2(TRACK_INSET, TRACK_Y), Vector2(_track.size.x - TRACK_INSET, TRACK_Y), Color(0.66, 0.7, 0.6), 3.0)


func select_milestone(index: int) -> void:
	if not _open or index < 0 or index >= content.entries.size():
		return
	_dragging = false
	_touch_index = -1
	var changed := _selected != index
	_selected = index
	_update_selection()
	_cancel_snap()
	_snap = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_snap.tween_property(_handle, "position:x", _point(index) - 28, SNAP_SECONDS)
	if changed:
		_cancel_fade()
		_fade = create_tween()
		_fade.tween_property(_columns, "modulate:a", 0.3, 0.08)
		_fade.tween_callback(_show_entry.bind(index))
		_fade.tween_property(_columns, "modulate:a", 1.0, 0.12)
	_update_sources()
	if changed:
		milestone_changed.emit(index)


func _update_selection() -> void:
	for index in _labels.size():
		var selected := index == _selected
		_labels[index].set_pressed_no_signal(selected)
		_nodes[index].set_pressed_no_signal(selected)
		_nodes[index].text = "◆" if selected else "●"
		var description := content.entries[index].date_label + (", selected" if selected else "")
		_labels[index].accessibility_name = description
		_nodes[index].accessibility_name = description
	_handle.accessibility_name = "Drag time marker: " + content.entries[_selected].date_label


func _show_entry(index: int) -> void:
	_displayed = index
	var entry := content.entries[index]
	_date.text = entry.date_label
	_heading.text = entry.event_title
	_body.text = entry.body
	_scroll.scroll_vertical = 0
	_image.texture = entry.image
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if entry.pixel_art else CanvasItem.TEXTURE_FILTER_LINEAR
	_image.accessibility_name = entry.image_alt_text
	_image.visible = entry.image != null
	_no_image.visible = entry.image == null
	_no_image.text = content.no_image_message


func _handle_input(event: InputEvent) -> void:
	if not _open or _sources.visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_drag(-1, _handle.get_global_transform_with_canvas() * event.position)
		_handle.accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		_start_drag(event.index, _handle.get_global_transform_with_canvas() * event.position)
		_handle.accept_event()


func _start_drag(pointer: int, position_in_viewport: Vector2) -> void:
	if _dragging:
		return
	_cancel_snap()
	_dragging = true
	_touch_index = pointer
	var local := _track.get_global_transform_with_canvas().affine_inverse() * position_in_viewport
	_drag_offset = local.x - (_handle.position.x + 28)


func _input(event: InputEvent) -> void:
	if not _open or not _dragging:
		return
	if _touch_index == -1:
		if event is InputEventMouseMotion:
			_move_handle(event.position)
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			get_viewport().set_input_as_handled()
			_move_handle(event.position)
			_finish_drag()
	else:
		if event is InputEventScreenDrag and event.index == _touch_index:
			_move_handle(event.position)
			get_viewport().set_input_as_handled()
		elif event is InputEventScreenTouch and event.index == _touch_index and not event.pressed:
			get_viewport().set_input_as_handled()
			if not event.canceled:
				_move_handle(event.position)
			_finish_drag()


func _move_handle(position_in_viewport: Vector2) -> void:
	var local := _track.get_global_transform_with_canvas().affine_inverse() * position_in_viewport
	_handle.position.x = clampf(local.x - _drag_offset, _point(0), _point(_labels.size() - 1)) - 28


func _finish_drag() -> void:
	var fraction := (_handle.position.x + 28 - _point(0)) / maxf(1.0, _point(_labels.size() - 1) - _point(0))
	select_milestone(roundi(fraction * (_labels.size() - 1)))


func _update_sources() -> void:
	var entry := content.entries[_selected]
	_source_title.text = "Sources — " + entry.date_label
	_source_text.text = entry.source_credit
	if entry.source_credit.is_empty():
		_source_text.text = "DEVELOPMENT ONLY: Verified source metadata is pending." if show_development_pending else "Source information is not available."
	_source_scroll.scroll_vertical = 0


func open_sources() -> void:
	if not _open or _sources.visible:
		return
	# Resolve an in-flight fade so the source panel and underlying entry agree.
	_cancel_fade()
	_show_entry(_selected)
	_columns.modulate.a = 1.0
	if _dragging:
		select_milestone(_selected)
	_update_sources()
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()


func close_sources() -> void:
	if not _open or not _sources.visible:
		return
	_sources.hide()
	_sync_focus()
	_sources_button.grab_focus()
	sources_closed.emit()


func toggle_narration() -> void:
	if not _open or _audio.stream == null:
		return
	if _audio.playing:
		stop_narration()
	else:
		_audio.play(0.0)
		_update_speaker()
		narration_started.emit()


func stop_narration() -> void:
	var active := _audio.playing or _speaker.button_pressed
	_audio.stop()
	_update_speaker()
	if active:
		narration_stopped.emit()


func _update_speaker() -> void:
	_speaker.set_pressed_no_signal(_audio.playing)
	var action := "Stop narration" if _audio.playing else "Play narration"
	if _audio.stream == null:
		action = "Narration audio pending"
	_speaker.tooltip_text = action
	_speaker.accessibility_name = action


func _sync_focus() -> void:
	var main: Array[Control] = []
	for button in _labels:
		main.append(button)
	main.append_array([_speaker, _scroll, _sources_button, _close])
	var overlay: Array[Control] = [_source_scroll, _source_close]
	for control in main + overlay:
		control.focus_mode = Control.FOCUS_NONE
	var active: Array[Control] = []
	for control in (overlay if _sources.visible else main):
		if control.is_visible_in_tree() and not (control is BaseButton and (control as BaseButton).disabled):
			control.focus_mode = Control.FOCUS_ALL
			active.append(control)
	for i in active.size():
		active[i].focus_next = active[i].get_path_to(active[(i + 1) % active.size()])
		active[i].focus_previous = active[i].get_path_to(active[(i - 1 + active.size()) % active.size()])
		for direction in ["left", "right", "top", "bottom"]:
			active[i].set("focus_neighbor_" + direction, NodePath("."))
	# Dates provide a keyboard alternative to dragging and duplicate node targets.
	for button in _nodes:
		button.focus_mode = Control.FOCUS_NONE
	_handle.focus_mode = Control.FOCUS_NONE


func _unhandled_input(event: InputEvent) -> void:
	if not _open or not event.is_action_pressed(&"go_back"):
		return
	get_viewport().set_input_as_handled()
	if event.is_echo():
		return
	if _sources.visible:
		close_sources()
	else:
		close_interaction()


func _cancel_snap() -> void:
	if _snap != null and _snap.is_valid():
		_snap.kill()
	_snap = null


func _cancel_fade() -> void:
	if _fade != null and _fade.is_valid():
		_fade.kill()
	_fade = null


func close_interaction() -> void:
	if not _open:
		return
	_open = false
	_dragging = false
	_touch_index = -1
	_cancel_snap()
	_cancel_fade()
	_audio.stop()
	_update_speaker()
	_columns.modulate.a = 1.0
	_sources.hide()
	hide()
	_restore_focus.call_deferred()
	closed.emit()


func _restore_focus() -> void:
	if _open or not is_inside_tree() or _return_focus == null:
		return
	var previous := _return_focus.get_ref() as Control
	if is_instance_valid(previous) and previous.is_visible_in_tree() and previous.focus_mode != Control.FOCUS_NONE:
		previous.grab_focus()


func _exit_tree() -> void:
	_cancel_snap()
	_cancel_fade()
	if is_instance_valid(_audio):
		_audio.stop()
