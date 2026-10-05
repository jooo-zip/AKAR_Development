extends Control
## Embedded video lifecycle. Unverified supplied media stays unassigned in its Resource.
signal closed
signal skip_requested
@export var content: HistoricalVideoContent
var player: VideoStreamPlayer
var transcript: ScrollContainer
var status: Label
var watch_button: Button
var replay_button: Button
var mute_button: Button
var active: bool = false
var _resume: bool = false

func _ready() -> void:
	var layout := VBoxContainer.new()
	add_child(layout)
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	player = VideoStreamPlayer.new()
	player.expand = true
	player.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(player)
	transcript = ScrollContainer.new()
	transcript.size_flags_vertical = Control.SIZE_EXPAND_FILL
	transcript.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(transcript)
	var text := Label.new()
	text.text = content.transcript
	text.custom_minimum_size.x = 1
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	transcript.add_child(text)
	status = Label.new()
	status.custom_minimum_size.x = 1
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(status)
	var row := HBoxContainer.new()
	layout.add_child(row)
	watch_button = _button(row, "WATCH / PLAY", watch)
	replay_button = _button(row, "REPLAY", replay)
	mute_button = _button(row, "MUTE", func() -> void: player.volume = 0 if player.volume > 0 else 1)
	_button(row, "TRANSCRIPT", func() -> void:
		if not close_subview():
			_resume = player.is_playing()
			player.paused = true
			player.hide()
			transcript.show())
	_button(row, "SKIP", func() -> void:
		get_viewport().set_input_as_handled()
		player.stop()
		skip_requested.emit())
	player.finished.connect(func() -> void: status.text = "Video ended. Replay or close whenever you wish.")
	hide()

func _button(parent: Node, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 52
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 16)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func open_interaction() -> bool:
	active = true
	player.stream = content.video
	player.stop()
	player.paused = false
	player.volume = 1
	transcript.hide()
	player.show()
	for button in [watch_button, replay_button, mute_button]:
		button.disabled = content.video == null
	status.text = "Video pending historical-content and transcript verification. You may read the status, skip or close." if content.video == null else "Ready. Watching is optional."
	show()
	return true

func watch() -> void:
	if active and player.stream != null:
		close_subview()
		player.play()

func replay() -> void:
	player.stop()
	watch()

func close_subview() -> bool:
	if not transcript.visible:
		return false
	transcript.hide()
	player.show()
	player.paused = not _resume
	return true

func close_interaction() -> void:
	active = false
	player.stop()
	_resume = false
	transcript.hide()
	hide()
	closed.emit()
