class_name HistoricalHotspot
extends Button
## Instance the scene as a focusable landmark trigger. Content is assigned separately.

signal opened
signal closed

@export var content: HistoricalHotspotContent

@onready var _popup: PopupPanel = $InformationPopup
@onready var _title: Label = $InformationPopup/Margin/Layout/Title
@onready var _scroll: ScrollContainer = $InformationPopup/Margin/Layout/Scroll
@onready var _body: Label = $InformationPopup/Margin/Layout/Scroll/Content/Body
@onready var _image: TextureRect = $InformationPopup/Margin/Layout/Scroll/Content/Image
@onready var _transcript: Label = $InformationPopup/Margin/Layout/Scroll/Content/Transcript
@onready var _source: Label = $InformationPopup/Margin/Layout/Scroll/Content/SourceCredit
@onready var _narration_button: Button = $InformationPopup/Margin/Layout/Actions/Narration
@onready var _close_button: Button = $InformationPopup/Margin/Layout/Actions/Close
@onready var _audio: AudioStreamPlayer = $NarrationPlayer

var _return_focus: WeakRef
var _open: bool = false


func _ready() -> void:
	pressed.connect(open_information)
	_popup.window_input.connect(_on_popup_input)
	_popup.popup_hide.connect(_on_popup_hidden)
	_popup.close_requested.connect(close_information)
	_close_button.pressed.connect(close_information)
	_narration_button.pressed.connect(toggle_narration)
	_audio.finished.connect(_update_narration_button)


func _gui_input(event: InputEvent) -> void:
	if has_focus() and not disabled and event.is_action_pressed(&"interact"):
		accept_event()
		if not event.is_echo():
			open_information()


## Returns false if no resource is assigned or this instance cannot be opened.
func open_information(return_focus: Control = null) -> bool:
	if not is_node_ready() or content == null or disabled or not is_visible_in_tree():
		return false
	if _open:
		return true
	var previous: Control = return_focus
	if previous == null:
		previous = get_viewport().gui_get_focus_owner()
	if previous == null:
		previous = self
	_return_focus = weakref(previous)
	_title.text = content.title
	_body.text = content.body
	_image.texture = content.image
	_image.visible = content.image != null
	_transcript.text = "Transcript\n" + content.transcript
	_transcript.visible = not content.transcript.strip_edges().is_empty()
	_source.text = "Source / credit\n" + content.source_credit
	_source.visible = not content.source_credit.strip_edges().is_empty()
	_audio.stop()
	_audio.stream_paused = false
	_audio.stream = content.narration
	_narration_button.visible = content.narration != null
	_update_narration_button()
	_scroll.scroll_vertical = 0
	_open = true
	_popup.popup_centered_clamped(Vector2i(880, 600), 0.9)
	_close_button.grab_focus()
	opened.emit()
	return true


func close_information() -> void:
	if _open:
		_popup.hide()


func is_information_open() -> bool:
	return _open


func toggle_narration() -> void:
	if not _open or _audio.stream == null:
		return
	if _audio.stream_paused:
		_audio.stream_paused = false
	elif _audio.playing:
		_audio.stream_paused = true
	else:
		_audio.play()
	_update_narration_button()


func _update_narration_button() -> void:
	if _audio.stream_paused:
		_narration_button.text = "Resume narration (N)"
	elif _audio.playing:
		_narration_button.text = "Pause narration (N)"
	else:
		_narration_button.text = "Play narration (N)"


func _on_popup_input(event: InputEvent) -> void:
	if not _open:
		return
	if event.is_action_pressed(&"go_back"):
		# The popup is its own viewport. Consume input before hiding or emitting.
		var viewport: Viewport = _popup.get_viewport()
		viewport.set_input_as_handled()
		if not event.is_echo():
			close_information()
	elif event.is_action_pressed(&"narration_toggle"):
		_popup.get_viewport().set_input_as_handled()
		if not event.is_echo():
			toggle_narration()


func _on_popup_hidden() -> void:
	if not _open:
		return
	_open = false
	_audio.stop()
	_audio.stream_paused = false
	_restore_focus.call_deferred()
	closed.emit()


func _restore_focus() -> void:
	if _open or not is_inside_tree():
		return
	var target: Control = null
	if _return_focus != null:
		target = _return_focus.get_ref() as Control
	if not _can_focus(target):
		target = self
	if _can_focus(target):
		target.grab_focus()


func _can_focus(control: Control) -> bool:
	return is_instance_valid(control) and control.is_inside_tree() \
		and control.is_visible_in_tree() and control.focus_mode != Control.FOCUS_NONE \
		and not (control is BaseButton and (control as BaseButton).disabled)
