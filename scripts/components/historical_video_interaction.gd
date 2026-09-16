class_name HistoricalVideoInteraction
extends PopupPanel
## Optional, modal video interaction. Hosts decide what closed/skip mean.

signal opened
signal closed
signal skip_requested
signal playback_started
signal playback_finished

@export var content: HistoricalVideoContent

@onready var _title: Label = $Margin/Layout/Title
@onready var _video_area: AspectRatioContainer = $Margin/Layout/VideoArea
@onready var _player: VideoStreamPlayer = $Margin/Layout/VideoArea/Video
@onready var _primary: HBoxContainer = $Margin/Layout/PrimaryControls
@onready var _watch: Button = $Margin/Layout/PrimaryControls/Watch
@onready var _muted_button: Button = $Margin/Layout/PrimaryControls/PlayWithoutSound
@onready var _replay: Button = $Margin/Layout/PrimaryControls/Replay
@onready var _transcript_button: Button = $Margin/Layout/PrimaryControls/Transcript
@onready var _status: Label = $Margin/Layout/Status
@onready var _transcript_panel: PanelContainer = $Margin/Layout/TranscriptPanel
@onready var _transcript_scroll: ScrollContainer = $Margin/Layout/TranscriptPanel/Margin/Layout/Scroll
@onready var _transcript_text: Label = $Margin/Layout/TranscriptPanel/Margin/Layout/Scroll/Text
@onready var _development: Label = $Margin/Layout/TranscriptPanel/Margin/Layout/Development
@onready var _transcript_close: Button = $Margin/Layout/TranscriptPanel/Margin/Layout/CloseTranscript

var _open: bool = false
var _muted: bool = false
var _skip_on_close: bool = false
var _resume_after_transcript: bool = false
var _return_focus: WeakRef


func _ready() -> void:
	_watch.pressed.connect(watch)
	_muted_button.pressed.connect(play_without_sound)
	_replay.pressed.connect(replay)
	_transcript_button.pressed.connect(show_transcript)
	_transcript_close.pressed.connect(hide_transcript)
	$Margin/Layout/SecondaryControls/Skip.pressed.connect(skip)
	$Margin/Layout/SecondaryControls/Close.pressed.connect(close_interaction)
	window_input.connect(_on_window_input)
	close_requested.connect(close_interaction)
	popup_hide.connect(_on_hidden)
	_player.finished.connect(_on_playback_finished)


func open_interaction(return_focus: Control = null) -> bool:
	if not is_node_ready() or content == null:
		return false
	if _open:
		return true
	var previous := return_focus
	if previous == null:
		previous = get_parent().get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_player.stop()
	_player.stream = content.video
	_player.paused = false
	_player.volume = 1.0
	_muted = false
	_skip_on_close = false
	_resume_after_transcript = false
	_title.text = content.title
	_transcript_text.text = content.transcript
	_development.visible = content.transcript_is_development
	_transcript_panel.hide()
	_video_area.show()
	_primary.show()
	_watch.disabled = content.video == null
	_muted_button.disabled = content.video == null
	_replay.disabled = content.video == null
	_transcript_button.disabled = content.transcript.strip_edges().is_empty()
	_status.text = "Ready. Watching is optional." if content.video != null else "Video unavailable. You may skip or close."
	_update_audio_controls(false)
	_open = true
	popup_centered_clamped(Vector2i(1120, 680), 0.96)
	if not _watch.disabled:
		_watch.grab_focus()
	elif not _transcript_button.disabled:
		_transcript_button.grab_focus()
	else:
		$Margin/Layout/SecondaryControls/Skip.grab_focus()
	opened.emit()
	return true


func is_interaction_open() -> bool:
	return _open


func watch() -> void:
	_play(false)


func play_without_sound() -> void:
	_play(true)


func replay() -> void:
	_play(_muted, true)


func _play(muted: bool, restart: bool = false) -> void:
	if not _open or _player.stream == null:
		return
	if _transcript_panel.visible:
		hide_transcript()
	_muted = muted
	_player.volume = 0.0 if muted else 1.0
	var starting := restart or not _player.is_playing()
	if starting:
		# Stop/play rewinds Theora without relying on unsupported seeking.
		_player.stop()
		_player.paused = false
		_player.play()
	_status.text = "Playing without sound." if muted else "Playing with sound."
	_update_audio_controls(true)
	if starting:
		playback_started.emit()


func _update_audio_controls(playing: bool) -> void:
	_watch.set_pressed_no_signal(playing and not _muted)
	_muted_button.set_pressed_no_signal(playing and _muted)


func show_transcript() -> void:
	if not _open or _transcript_button.disabled or _transcript_panel.visible:
		return
	_resume_after_transcript = _player.is_playing() and not _player.paused
	if _resume_after_transcript:
		_player.paused = true
	_video_area.hide()
	_primary.hide()
	_transcript_panel.show()
	_transcript_scroll.scroll_vertical = 0
	_status.text = "Playback paused while reading." if _resume_after_transcript else "Reading transcript."
	_transcript_close.grab_focus()


func hide_transcript() -> void:
	if not _open or not _transcript_panel.visible:
		return
	_transcript_panel.hide()
	_video_area.show()
	_primary.show()
	if _resume_after_transcript:
		_player.paused = false
		_status.text = "Playing without sound." if _muted else "Playing with sound."
	else:
		_status.text = "Ready. Watching is optional."
	_resume_after_transcript = false
	_transcript_button.grab_focus()


func skip() -> void:
	if _open:
		_skip_on_close = true
		hide()


func close_interaction() -> void:
	if _open:
		hide()


func _on_window_input(event: InputEvent) -> void:
	if _open and event.is_action_pressed(&"go_back"):
		var viewport := get_viewport()
		viewport.set_input_as_handled()
		if event.is_echo():
			return
		if _transcript_panel.visible:
			hide_transcript()
		else:
			close_interaction()


func _on_hidden() -> void:
	if not _open:
		return
	_open = false
	_player.stop()
	_player.paused = false
	_resume_after_transcript = false
	_transcript_panel.hide()
	_restore_focus.call_deferred()
	# Emit only one terminal signal, after cleanup. The host may remove this node.
	if _skip_on_close:
		skip_requested.emit()
	else:
		closed.emit()


func _restore_focus() -> void:
	if _open or not is_inside_tree() or _return_focus == null:
		return
	var target := _return_focus.get_ref() as Control
	if is_instance_valid(target) and target.is_inside_tree() and target.is_visible_in_tree() \
			and target.focus_mode != Control.FOCUS_NONE \
			and not (target is BaseButton and (target as BaseButton).disabled):
		target.grab_focus()


func _on_playback_finished() -> void:
	if not _open:
		return
	_status.text = "Playback finished. Replay, read transcript, or close."
	_update_audio_controls(false)
	playback_finished.emit()


func _exit_tree() -> void:
	if is_instance_valid(_player):
		_player.stop()
