class_name CeremonialHallInteraction
extends Control
## A room/media viewer. Historical text and media belong to the content resource.

signal opened
signal closed
signal section_changed(index: int)
signal event_changed(index: int)
signal space_view_changed(index: int)
signal narration_started
signal narration_stopped
signal sources_opened
signal sources_closed

@export var content: CeremonialHallContent
@export var show_development_pending: bool = false

@onready var _title: Label = %Title
@onready var _close: Button = %Close
@onready var _columns: HBoxContainer = %Columns
@onready var _image: TextureRect = %Image
@onready var _information: VBoxContainer = %Information
@onready var _exploration_caption: Label = %ExplorationCaption
@onready var _space_sources: Button = %SpaceSources
@onready var _heading: Label = %Heading
@onready var _detail: Label = %Detail
@onready var _body: Label = %Body
@onready var _scroll: ScrollContainer = %Scroll
@onready var _sources_button: Button = %SourcesButton
@onready var _speaker: Button = %Speaker
@onready var _event_controls: HBoxContainer = %EventControls
@onready var _view_controls: HBoxContainer = %ViewControls
@onready var _sections: Array[Button] = [%About, %Events, %Space]
@onready var _event_buttons: Array[Button] = [%Previous, %Event1, %Event2, %Next]
@onready var _views: Array[Button] = [%Photo, %Pixel]
@onready var _sources: PanelContainer = %Sources
@onready var _source_title: Label = %SourceTitle
@onready var _source_text: Label = %SourceText
@onready var _source_scroll: ScrollContainer = %SourceScroll
@onready var _source_close: Button = %SourceClose
@onready var _audio: AudioStreamPlayer = $NarrationPlayer

var _open: bool = false
var _section: int = 0
var _event: int = 0
var _view: int = 0
var _return_focus: WeakRef
var _fade: Tween


func _ready() -> void:
	hide()
	_close.pressed.connect(close_interaction)
	_sources_button.pressed.connect(open_sources)
	_space_sources.pressed.connect(open_sources)
	_source_close.pressed.connect(close_sources)
	_speaker.pressed.connect(toggle_narration)
	_audio.finished.connect(stop_narration)
	for i in _sections.size():
		_sections[i].pressed.connect(select_section.bind(i))
	for i in _views.size():
		_views[i].pressed.connect(select_space_view.bind(i))
	_event_buttons[0].pressed.connect(func() -> void: select_event(_event - 1))
	_event_buttons[1].pressed.connect(select_event.bind(0))
	_event_buttons[2].pressed.connect(select_event.bind(1))
	_event_buttons[3].pressed.connect(func() -> void: select_event(_event + 1))


func open_interaction() -> bool:
	if not is_node_ready() or content == null or content.events.size() < 2:
		return false
	for entry in content.events:
		if entry == null:
			return false
	if _open:
		return true
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_section = 0
	_event = 0
	_view = 0
	_title.text = content.title
	_audio.stream = content.narration_stream
	_audio.stop()
	_speaker.visible = _audio.stream != null or show_development_pending
	_speaker.disabled = _audio.stream == null
	_update_speaker()
	_sources.hide()
	_open = true
	show()
	_render()
	_sync_focus()
	_sections[0].grab_focus()
	opened.emit()
	return true


func select_section(index: int) -> void:
	if not _open or _sources.visible or index < 0 or index > 2:
		return
	_section = index
	if index == 2:
		_view = 0
	_refresh()
	section_changed.emit(index)


func select_event(index: int) -> void:
	if not _open or _sources.visible or _section != 1:
		return
	_event = posmod(index, content.events.size())
	_refresh()
	event_changed.emit(_event)


func select_space_view(index: int) -> void:
	if not _open or _sources.visible or _section != 2 or index < 0 or index > 1:
		return
	_view = index
	_refresh()
	space_view_changed.emit(index)


func _refresh() -> void:
	_cancel_fade()
	# Apply the latest selection immediately, then fade in without queued callbacks.
	_render()
	_sync_focus()
	_columns.modulate.a = 0.65
	_fade = create_tween()
	_fade.tween_property(_columns, "modulate:a", 1.0, 0.18)


func _render() -> void:
	# The parent supplies the rectangle; exploration gives the media the full row.
	_information.visible = _section != 2
	_space_sources.visible = _section == 2
	_exploration_caption.visible = _section == 2 and _view == 1
	_exploration_caption.text = content.pixel_art_alt_text if _view == 1 else ""
	_event_controls.visible = _section == 1
	_view_controls.visible = _section == 2
	for i in _sections.size():
		_sections[i].set_pressed_no_signal(i == _section)
	for i in _views.size():
		_views[i].set_pressed_no_signal(i == _view)
	_event_buttons[1].set_pressed_no_signal(_event == 0)
	_event_buttons[2].set_pressed_no_signal(_event == 1)
	_detail.text = ""
	_body.text = ""
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	match _section:
		0:
			_heading.text = "About the Hall"
			_image.texture = content.hall_image
			_image.accessibility_name = content.hall_alt_text
			_body.text = content.body
		1:
			var entry := content.events[_event]
			_heading.text = "Official Events"
			_image.texture = entry.image
			_image.accessibility_name = entry.image_alt_text
			_detail.text = entry.event_title
			_body.text = entry.date_label + "\n\n" + entry.venue
			if not entry.participating_institution.is_empty():
				_body.text += "\n\n" + entry.participating_institution
		2:
			_heading.text = "View the Space"
			_detail.text = "FULL HALL PHOTO" if _view == 0 else "PIXEL-ART VIEW"
			_image.texture = content.hall_image if _view == 0 else content.pixel_art_image
			_image.accessibility_name = content.hall_alt_text if _view == 0 else content.pixel_art_alt_text
			if _view == 1:
				_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				_body.text = content.pixel_art_alt_text
	_detail.visible = not _detail.text.is_empty()
	_scroll.scroll_vertical = 0


func open_sources() -> void:
	if not _open or _sources.visible:
		return
	var credit := content.hall_source_credit
	var context := "About the Hall" if _section == 0 else "Full Hall Photo"
	if _section == 1:
		var entry := content.events[_event]
		context = entry.event_title
		credit = entry.source_credit
	elif _section == 2 and _view == 1:
		context = "Pixel-Art View"
		credit = content.pixel_art_source_credit
	_source_title.text = "Sources"
	_source_text.text = context
	if not credit.is_empty():
		_source_text.text += "\n\n" + credit
	elif show_development_pending:
		_source_text.text += "\n\nDEVELOPMENT ONLY\nSource metadata pending verification."
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()


func close_sources() -> void:
	if not _open or not _sources.visible:
		return
	_sources.hide()
	_sync_focus()
	if _section == 2:
		_space_sources.grab_focus()
	else:
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
	var previous := get_viewport().gui_get_focus_owner()
	var main: Array[Control] = []
	main.append_array(_sections)
	main.append_array(_event_buttons)
	main.append_array(_views)
	main.append_array([_speaker, _scroll, _sources_button, _space_sources, _close])
	var overlay: Array[Control] = [_source_scroll, _source_close]
	var active: Array[Control] = []
	for control in main + overlay:
		control.focus_mode = Control.FOCUS_NONE
	for control in (overlay if _sources.visible else main):
		if control.is_visible_in_tree() and not (control is BaseButton and (control as BaseButton).disabled):
			control.focus_mode = Control.FOCUS_ALL
			active.append(control)
	for i in active.size():
		active[i].focus_next = active[i].get_path_to(active[(i + 1) % active.size()])
		active[i].focus_previous = active[i].get_path_to(active[posmod(i - 1, active.size())])
	if previous in active:
		previous.grab_focus()
	elif not active.is_empty():
		active[0].grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not _open or not event.is_action_pressed(&"go_back"):
		return
	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
	if event.is_echo():
		return
	if _sources.visible:
		close_sources()
	else:
		close_interaction()


func close_interaction() -> void:
	if not _open:
		return
	_open = false
	_cancel_fade()
	stop_narration()
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


func _cancel_fade() -> void:
	if _fade != null and _fade.is_valid():
		_fade.kill()
	_fade = null
	if is_instance_valid(_columns):
		_columns.modulate.a = 1.0


func _exit_tree() -> void:
	_cancel_fade()
	if is_instance_valid(_audio):
		_audio.stop()
