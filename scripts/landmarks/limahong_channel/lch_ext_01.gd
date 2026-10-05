extends ConferenceRoomInteraction
const Lifecycle = preload("res://scripts/landmarks/limahong_channel/lch_lifecycle.gd")
const SourcesOverlay = preload("res://scripts/landmarks/limahong_channel/lch_sources_overlay.gd")
const HeaderUtilities = preload("res://scripts/landmarks/limahong_channel/lch_header_utilities.gd")
var _header_utilities: HeaderUtilities
## LCH-EXT-01 specialization of the existing embedded Urduja panel.
## Parent owns navigation; closed is the inherited close notification.

signal section_changed(index: int)

@export var introduction: HistoricalHotspotContent
@export var historical_note: HistoricalHotspotContent
@export var section_media: Array[HistoricalHotspotContent] = []
@export var locator_steps: Array[HistoricalHotspotContent] = []
@export var site_media: Array[HistoricalHotspotContent] = []
## Assign a researcher-approved licensed display font here. Body text is unaffected.
@export var display_font: Font

@onready var _subtitle: Label = %Subtitle
@onready var _opening: Label = %Opening
@onready var _note_button: Button = %NoteButton
@onready var _note_text: Label = %NoteText
@onready var _caption: Label = %Caption
@onready var _placeholder: Label = %Placeholder
@onready var _locator_buttons: Array[Button] = [%Lingayen, %Pangapisan, %Channel]
@onready var _previous: Button = %Previous
@onready var _next: Button = %Next
@onready var _image_area: Control = %ImageArea
@onready var _locator_frame: Control = %LocatorFrame

var _locator_index: int = 0
var _media_index: int = 0
var _locator_fade: Tween
@onready var _outgoing_locator: TextureRect = $"Main/Margin/Layout/Columns/Visual/ImageArea/LocatorFrame/OutgoingLocator"
var _locator_direction: int = 0


func _ready() -> void:
	super._ready()
	_bind_authored_content()
	_image_area.resized.connect(_layout_visual_frame)
	_note_button.pressed.connect(_toggle_note)
	for i in _concepts.size():
		_concepts[i].gui_input.connect(_section_input.bind(i))
	for i in _locator_buttons.size():
		_locator_buttons[i].pressed.connect(select_locator.bind(i))
		_locator_buttons[i].gui_input.connect(_locator_input.bind(i))
	_previous.pressed.connect(change_media.bind(-1))
	_next.pressed.connect(change_media.bind(1))
	_apply_display_font()
	resized.connect(_resize_layout)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_header_utilities = HeaderUtilities.new(self, %NarrationStatus, %SubtitleRow)
	add_child(SourcesOverlay.new(self))

func open_interaction() -> bool:
	if not is_node_ready() or introduction == null or historical_note == null or section_media.size() != 3:
		return false
	if _open:
		return true
	_locator_index = 0
	_media_index = 0
	_subtitle.text = introduction.title
	_opening.text = introduction.body
	_note_button.text = historical_note.title
	_note_text.text = historical_note.body
	_note_button.set_pressed_no_signal(false)
	_note_text.hide()
	return super.open_interaction()


func _render() -> void:
	_cancel_locator_transition()
	super._render()
	var media := section_media[_selected]
	if _selected == 2 and not site_media.is_empty():
		media = site_media[_media_index]
	_image.texture = media.image if media != null else null
	_image.accessibility_name = media.title if media != null else "Image unavailable"
	_caption.text = media.title if media != null else ""
	%LocatorSteps.visible = _selected == 0
	%MediaControls.visible = _selected == 2 and site_media.size() > 1
	# All three locator captions fit one line at the supported landscape sizes.
	_caption.custom_minimum_size.y = 26.0 if _selected == 0 else 0.0
	_layout_visual_frame()
	if _selected == 0:
		_render_locator()
	if _selected == 2:
		_update_media_controls()
	%Remember.visible = _takeaway.visible
	# Split the existing approved heading from the paragraph for display-font isolation.
	var takeaway_parts := content.learning_takeaway.split("\n", true, 1)
	%Remember.text = takeaway_parts[0]
	if takeaway_parts.size() > 1:
		_takeaway.text = takeaway_parts[1]
	_placeholder.visible = _image.texture == null
	_opening.visible = _selected == 0
	_note_button.visible = _selected == 1
	_note_button.set_pressed_no_signal(false)
	_note_text.hide()
	_note_button.accessibility_name = historical_note.title + " Expand"
	_sync_focus()


func select_locator(index: int) -> void:
	if not _open or _sources.visible or _selected != 0 or index < 0 or index >= locator_steps.size():
		return
	if index == _locator_index:
		return
	var previous_texture := _image.texture
	var direction := signi(index - _locator_index)
	_cancel_locator_transition()
	_locator_direction = direction
	_locator_index = index
	_render_locator()
	if previous_texture != null and _image.texture != null and previous_texture != _image.texture:
		_outgoing_locator.texture = previous_texture
		_outgoing_locator.modulate.a = 1.0
		_outgoing_locator.show()
		_image.self_modulate.a = 0.0
		_image.pivot_offset = _locator_frame.size * 0.5
		_outgoing_locator.pivot_offset = _image.pivot_offset
		_image.scale = Vector2.ONE * (1.03 if direction > 0 else 1.01)
		_locator_fade = create_tween()
		_locator_fade.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		# Separate screenshots: suggest depth without claiming a continuous map.
		_locator_fade.tween_property(_outgoing_locator, "scale", Vector2.ONE * (1.06 if direction > 0 else 0.96), 0.14)
		_locator_fade.parallel().tween_property(_outgoing_locator, "modulate:a", 0.0, 0.14)
		_locator_fade.tween_property(_image, "scale", Vector2.ONE, 0.16)
		_locator_fade.parallel().tween_property(_image, "self_modulate:a", 1.0, 0.16)
		_locator_fade.finished.connect(_cancel_locator_transition)


func _render_locator() -> void:
	for i in _locator_buttons.size():
		_locator_buttons[i].set_pressed_no_signal(i == _locator_index)
		if i < locator_steps.size():
			_locator_buttons[i].text = locator_steps[i].title
	if _locator_index < locator_steps.size():
		var step := locator_steps[_locator_index]
		_caption.text = step.title + " • " + step.body
		# Each existing content Resource has its own optional image slot.
		_image.texture = step.image if step.image != null else section_media[0].image
		_image.accessibility_name = step.title if step.image != null else "Present-day site-detail fallback"
		if step.image == null:
			_caption.text = step.title + " · site-detail fallback"
		_placeholder.visible = _image.texture == null


func _cancel_locator_transition() -> void:
	if _locator_fade != null and _locator_fade.is_valid():
		_locator_fade.kill()
	_locator_fade = null
	_locator_direction = 0
	if is_instance_valid(_image):
		_image.self_modulate.a = 1.0
		_image.scale = Vector2.ONE
	if is_instance_valid(_outgoing_locator):
		_outgoing_locator.hide()
		_outgoing_locator.texture = null
		_outgoing_locator.scale = Vector2.ONE
		_outgoing_locator.modulate.a = 1.0


func _layout_visual_frame() -> void:
	if not is_node_ready():
		return
	_cancel_locator_transition()
	var available := _image_area.size
	var frame_size := available
	if _selected == 0:
		var width := minf(available.x, available.y * 4.0 / 3.0)
		frame_size = Vector2(width, width * 3.0 / 4.0)
	_locator_frame.size = frame_size
	_locator_frame.position = (available - frame_size) * 0.5
	_locator_frame.get_node("Background").visible = _selected == 0


func close_interaction() -> void:
	_cancel_locator_transition()
	super.close_interaction()


func _exit_tree() -> void:
	_cancel_locator_transition()
	super._exit_tree()


func _locator_input(event: InputEvent, index: int) -> void:
	var direction := 0
	if event.is_action_pressed(&"ui_left"):
		direction = -1
	elif event.is_action_pressed(&"ui_right"):
		direction = 1
	if direction != 0:
		get_viewport().set_input_as_handled()
		var next := clampi(index + direction, 0, _locator_buttons.size() - 1)
		_locator_buttons[next].grab_focus()
		select_locator(next)


func change_media(direction: int) -> void:
	if not _open or _sources.visible or _selected != 2 or site_media.is_empty():
		return
	_media_index = clampi(_media_index + direction, 0, site_media.size() - 1)
	var media := site_media[_media_index]
	_image.texture = media.image if media != null else null
	_image.accessibility_name = media.title if media != null else "Image unavailable"
	_caption.text = media.title if media != null else ""
	_placeholder.visible = _image.texture == null
	_update_media_controls()
	_sync_focus()


func _update_media_controls() -> void:
	_previous.disabled = _media_index == 0
	_next.disabled = _media_index >= site_media.size() - 1
	%MediaCount.text = "%d / %d" % [_media_index + 1, site_media.size()]
	# Keep keyboard navigation usable when its pressed control reaches an endpoint.
	if _previous.has_focus() and _previous.disabled:
		_next.grab_focus()
	elif _next.has_focus() and _next.disabled:
		_previous.grab_focus()


func _apply_display_font() -> void:
	var displays: Array[Control] = [_title, _heading, _caption, _source_title,
		_sources_button, _source_close, _close, _speaker, _note_button,
		_previous, _next, %MediaCount, %Remember]
	displays.append_array(_concepts)
	displays.append_array(_locator_buttons)
	for control in displays:
		if display_font != null:
			control.add_theme_font_override("font", display_font)


func select_concept(index: int) -> void:
	if not _open or _sources.visible or index < 0 or index >= 3:
		return
	super.select_concept(index)
	section_changed.emit(index)


func _toggle_note() -> void:
	_note_text.visible = _note_button.button_pressed
	_note_button.accessibility_name = historical_note.title + (" Collapse" if _note_text.visible else " Expand")
	if _note_text.visible:
		_reveal_note()
	else:
		_scroll.scroll_vertical = 0


func _reveal_note() -> void:
	# Container minimum sizes settle after visibility changes, not at button press.
	await get_tree().process_frame
	await get_tree().process_frame
	if _open and _selected == 1 and _note_text.visible and not _sources.visible:
		_scroll.scroll_vertical = int(_note_text.position.y)


func _section_input(event: InputEvent, index: int) -> void:
	var direction := 0
	if event.is_action_pressed(&"ui_left"):
		direction = -1
	elif event.is_action_pressed(&"ui_right"):
		direction = 1
	if direction == 0:
		return
	get_viewport().set_input_as_handled()
	var next := clampi(index + direction, 0, 2)
	_concepts[next].grab_focus()
	select_concept(next)


func _sync_focus() -> void:
	var controls: Array[Control] = []
	controls.append_array(_concepts)
	controls.append_array(_locator_buttons)
	controls.append_array([_previous, _next, _scroll, _note_button])
	HeaderUtilities.sync_focus(self, controls)

func _unhandled_input(event: InputEvent) -> void:
	if _open and event.is_action_pressed(&"narration_toggle"):
		get_viewport().set_input_as_handled()
		if not event.is_echo():
			toggle_narration()
		return
	super._unhandled_input(event)


func toggle_narration() -> void:
	if not _open or _audio.stream == null:
		return
	if _audio.stream_paused:
		_audio.stream_paused = false
	elif _audio.playing:
		_audio.stream_paused = true
	else:
		_audio.play()
		narration_started.emit()
	_update_speaker()


func stop_narration() -> void:
	_audio.stream_paused = false
	super.stop_narration()


func _update_speaker() -> void:
	var action := "Play narration"
	_speaker.show()
	_speaker.disabled = _audio.stream == null
	_speaker.text = "LISTEN"
	%NarrationStatus.visible = _audio.stream == null
	if _audio.stream == null:
		action = "Narration pending"
	elif _audio.stream_paused:
		action = "Resume narration"
		_speaker.text = "RESUME"
	elif _audio.playing:
		action = "Pause narration"
		_speaker.text = "PAUSE"
	_speaker.set_pressed_no_signal(_audio.playing and not _audio.stream_paused)
	_speaker.tooltip_text = action
	_speaker.accessibility_name = action
	if _header_utilities != null: _header_utilities.refresh()

func _visibility_changed() -> void:
	# A parent hiding the component must not leave narration running invisibly.
	if _open and not is_visible_in_tree():
		close_interaction()


func _resize_layout() -> void:
	if not is_node_ready():
		return
	var compact := size.x < 1000 or size.y < 550
	var margin := 8 if compact else 16
	for side in ["left", "top", "right", "bottom"]:
		$Main/Margin.add_theme_constant_override("margin_" + side, margin)
	%Columns.add_theme_constant_override("separation", 12 if compact else 24)
	$Main/Margin/Layout.add_theme_constant_override("separation", 4 if compact else 8)
	_information.add_theme_constant_override("separation", 4 if compact else 8)
	_title.add_theme_font_size_override("font_size", 24 if compact else 30)
	_heading.add_theme_font_size_override("font_size", 20 if compact else 24)
	_opening.add_theme_font_size_override("font_size", 18)
	for label in [_body, _takeaway, _note_text]:
		label.add_theme_font_size_override("font_size", 20 if compact else 22)

func _bind_authored_content() -> void:
	# Resources remain the only authority for interpretation copy.
	get_node("Main/Margin/Layout/Columns/Information/Meta/Heading").text = content.concepts[0].heading
	get_node("Main/Margin/Layout/Columns/Information/NoteButton").text = historical_note.title
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/Body").text = content.concepts[0].body
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/NoteText").text = historical_note.body
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/Opening").text = introduction.body
	get_node("Main/Margin/Layout/Columns/Visual/LocatorSteps/Channel").text = locator_steps[2].title
	get_node("Main/Margin/Layout/Columns/Visual/LocatorSteps/Lingayen").text = locator_steps[0].title
	get_node("Main/Margin/Layout/Columns/Visual/LocatorSteps/Pangapisan").text = locator_steps[1].title
	get_node("Main/Margin/Layout/Header/TitleArea/SubtitleRow/Subtitle").text = introduction.title
	get_node("Main/Margin/Layout/Header/TitleArea/Title").text = content.title
	get_node("Main/Margin/Layout/Sections/OfficialFunction").text = content.concepts[1].heading
	get_node("Main/Margin/Layout/Sections/PublicInterior").text = content.concepts[0].heading
	get_node("Main/Margin/Layout/Sections/WhyItMatters").text = content.concepts[2].heading


func reset_interaction() -> void:
	Lifecycle.reset(self)
