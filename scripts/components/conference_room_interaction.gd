class_name ConferenceRoomInteraction
extends Control
## Parent-sized educational concept selector; approved content belongs to Resources.

signal opened
signal closed
signal concept_changed(index: int)
signal narration_started
signal narration_stopped
signal sources_opened
signal sources_closed

@export var content: ConferenceRoomContent

@onready var _title: Label = %Title
@onready var _close: Button = %Close
@onready var _image: TextureRect = %Image
@onready var _information: VBoxContainer = %Information
@onready var _heading: Label = %Heading
@onready var _body: Label = %Body
@onready var _takeaway: Label = %Takeaway
@onready var _scroll: ScrollContainer = %Scroll
@onready var _sources_button: Button = %SourcesButton
@onready var _speaker: Button = %Speaker
@onready var _concepts: Array[Button] = [%PublicInterior, %OfficialFunction, %WhyItMatters]
@onready var _sources: PanelContainer = %Sources
@onready var _source_title: Label = %SourceTitle
@onready var _source_text: Label = %SourceText
@onready var _source_scroll: ScrollContainer = %SourceScroll
@onready var _source_close: Button = %SourceClose
@onready var _audio: AudioStreamPlayer = $NarrationPlayer

var _open: bool = false
var _selected: int = 0
var _return_focus: WeakRef
var _fade: Tween


func _ready() -> void:
	hide()
	_close.pressed.connect(close_interaction)
	_sources_button.pressed.connect(open_sources)
	_source_close.pressed.connect(close_sources)
	_speaker.pressed.connect(toggle_narration)
	_audio.finished.connect(stop_narration)
	for i in _concepts.size():
		_concepts[i].pressed.connect(select_concept.bind(i))


func open_interaction() -> bool:
	if not is_node_ready() or content == null or content.concepts.size() != 3:
		return false
	for entry in content.concepts:
		if entry == null:
			return false
	if _open:
		return true
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_selected = 0
	_title.text = content.title
	_image.texture = content.illustration
	_image.accessibility_name = content.illustration_alt_text
	for i in _concepts.size():
		_concepts[i].text = content.concepts[i].heading.to_upper()
	_audio.stream = content.narration_stream
	_audio.stop()
	_speaker.visible = _audio.stream != null
	_speaker.disabled = _audio.stream == null
	_update_speaker()
	_sources.hide()
	_cancel_fade()
	_open = true
	show()
	_render()
	_sync_focus()
	_concepts[0].grab_focus()
	opened.emit()
	return true


func select_concept(index: int) -> void:
	if not _open or _sources.visible or index < 0 or index >= _concepts.size():
		return
	_selected = index
	_cancel_fade()
	_render()
	# Only the text fades; the illustration and narration remain stable.
	_information.modulate.a = 0.65
	_fade = create_tween()
	_fade.tween_property(_information, "modulate:a", 1.0, 0.18)
	concept_changed.emit(index)


func get_selected_concept() -> int:
	return _selected


func _render() -> void:
	var entry := content.concepts[_selected]
	_heading.text = entry.heading
	_body.text = entry.body
	_takeaway.text = content.learning_takeaway
	_takeaway.visible = entry.show_takeaway and not content.learning_takeaway.is_empty()
	for i in _concepts.size():
		_concepts[i].set_pressed_no_signal(i == _selected)
	_scroll.scroll_vertical = 0


func open_sources() -> void:
	if not _open or _sources.visible:
		return
	_source_title.text = "Sources"
	_source_text.text = content.concepts[_selected].heading + "\n\n" + content.source_credit
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
	_sources_button.grab_focus()
	sources_closed.emit()


func toggle_narration() -> void:
	if not _open or _audio.stream == null:
		return
	if _audio.stream_paused:
		_audio.stream_paused = false
	elif _audio.playing:
		_audio.stream_paused = true
	else:
		_audio.play(0.0)
		narration_started.emit()
	_update_speaker()


func stop_narration() -> void:
	var active := _audio.playing or _audio.stream_paused or _speaker.button_pressed
	_audio.stop()
	_audio.stream_paused = false
	_update_speaker()
	if active:
		narration_stopped.emit()


func _update_speaker() -> void:
	_speaker.set_pressed_no_signal(_audio.playing and not _audio.stream_paused)
	var action := "Resume narration" if _audio.stream_paused else ("Pause narration" if _audio.playing else "Play narration")
	if _audio.stream == null:
		action = "Narration audio pending"
	_speaker.tooltip_text = action
	_speaker.accessibility_name = action


func _sync_focus() -> void:
	var previous := get_viewport().gui_get_focus_owner()
	var main: Array[Control] = []
	main.append_array(_concepts)
	main.append_array([_speaker, _scroll, _sources_button, _close])
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
	if is_instance_valid(_information):
		_information.modulate.a = 1.0


func _exit_tree() -> void:
	_cancel_fade()
	if is_instance_valid(_audio):
		_audio.stop()
