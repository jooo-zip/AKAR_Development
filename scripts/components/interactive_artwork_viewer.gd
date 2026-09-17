class_name InteractiveArtworkViewer
extends Control
## Landscape artwork viewer. All educational wording lives in the content resource.

signal opened
signal closed
signal section_changed(index: int)
signal artwork_view_changed(mode: StringName)
signal sources_opened
signal sources_closed

@export var content: InteractiveArtworkContent
@export var show_development_audio_pending: bool = false

@onready var _title: Label = $Main/Margin/Layout/Title
@onready var _art_holder: Control = $Main/Margin/Layout/Columns/Artwork/ImageArea
@onready var _art: TextureRect = $Main/Margin/Layout/Columns/Artwork/ImageArea/Image
@onready var _full_button: Button = $Main/Margin/Layout/Columns/Artwork/Views/FullArtwork
@onready var _detail_button: Button = $Main/Margin/Layout/Columns/Artwork/Views/DetailView
@onready var _section_title: Label = $Main/Margin/Layout/Columns/Education/SectionTitle
@onready var _scroll: ScrollContainer = $Main/Margin/Layout/Columns/Education/Scroll
@onready var _body: Label = $Main/Margin/Layout/Columns/Education/Scroll/Body
@onready var _sections: VBoxContainer = $Main/Margin/Layout/Columns/Education/Sections
@onready var _audio_controls: HBoxContainer = $Main/Margin/Layout/Columns/Artwork/AudioRow
@onready var _speaker: Button = $Main/Margin/Layout/Columns/Artwork/AudioRow/SpeakerButton
@onready var _sources_button: Button = $Main/Margin/Layout/Columns/Education/Actions/Sources
@onready var _close: Button = $Main/Margin/Layout/Columns/Education/Actions/Close
@onready var _detail: PanelContainer = $Detail
@onready var _detail_holder: Control = $Detail/Margin/Layout/Columns/ImageArea
@onready var _detail_image: TextureRect = $Detail/Margin/Layout/Columns/ImageArea/Image
@onready var _regions: GridContainer = $Detail/Margin/Layout/Columns/Inspection/Regions
@onready var _viewing: Label = $Detail/Margin/Layout/Columns/Inspection/Viewing
@onready var _inspection_heading: Label = $Detail/Margin/Layout/Columns/Inspection/SectionTitle
@onready var _inspection_scroll: ScrollContainer = $Detail/Margin/Layout/Columns/Inspection/Scroll
@onready var _inspection_body: Label = $Detail/Margin/Layout/Columns/Inspection/Scroll/Body
@onready var _audio_pending: Label = $Main/Margin/Layout/Columns/Artwork/AudioRow/PendingStatus
@onready var _detail_sources: Button = $Detail/Margin/Layout/Actions/Sources
@onready var _detail_close: Button = $Detail/Margin/Layout/Actions/CloseDetail
@onready var _sources: PanelContainer = $Sources
@onready var _source_scroll: ScrollContainer = $Sources/Margin/Layout/Scroll
@onready var _source_text: Label = $Sources/Margin/Layout/Scroll/Text
@onready var _source_close: Button = $Sources/Margin/Layout/CloseSources
@onready var _audio: AudioStreamPlayer = $NarrationPlayer

var _open: bool = false
var _selected_section: int = 0
var _return_focus: WeakRef
var _section_buttons: Array[Button] = []
var _region_buttons: Array[Button] = []
var _selected_region: int = 0


func _ready() -> void:
	hide()
	var modes := ButtonGroup.new()
	for button in [_full_button, _detail_button]:
		button.toggle_mode = true
		button.button_group = modes
	_full_button.pressed.connect(show_full_artwork)
	_detail_button.pressed.connect(show_detail_view)
	_detail_close.pressed.connect(close_detail_view)
	_sources_button.pressed.connect(open_sources)
	_detail_sources.pressed.connect(open_sources)
	_source_close.pressed.connect(close_sources)
	_close.pressed.connect(close_interaction)
	_speaker.pressed.connect(toggle_narration)
	_audio.finished.connect(stop_narration)
	_art_holder.resized.connect(_fit_artwork)
	_detail_holder.resized.connect(_fit_artwork)


func open_interaction(return_focus: Control = null) -> bool:
	if not is_node_ready() or content == null or content.section_labels.is_empty():
		return false
	if content.section_headings.size() != content.section_labels.size() \
			or content.section_bodies.size() != content.section_labels.size():
		return false
	if _open:
		return true
	var previous := return_focus
	if previous == null:
		previous = get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_title.text = content.title
	_art.texture = content.artwork_texture
	_art.accessibility_name = content.alt_text
	_detail_image.accessibility_name = content.alt_text
	_build_regions()
	_detail_button.disabled = _region_buttons.is_empty()
	_source_text.text = content.source_credit
	_sources_button.disabled = content.source_credit.strip_edges().is_empty()
	_detail_sources.disabled = _sources_button.disabled
	_audio.stop()
	_audio.stream_paused = false
	_audio.stream = content.narration_stream
	_audio_pending.visible = show_development_audio_pending and content.narration_stream == null
	_audio_controls.visible = content.narration_stream != null or _audio_pending.visible
	_update_audio_controls()
	_build_sections()
	_apply_section(0)
	_detail.hide()
	_update_mode_state()
	_sources.hide()
	_open = true
	show()
	_sync_focus_cycle()
	_section_buttons[0].grab_focus()
	_fit_artwork.call_deferred()
	opened.emit()
	return true


func is_interaction_open() -> bool:
	return _open


func _build_sections() -> void:
	for button in _section_buttons:
		_sections.remove_child(button)
		button.queue_free()
	_section_buttons.clear()
	var group := ButtonGroup.new()
	for index in content.section_labels.size():
		var button := Button.new()
		button.name = "Section%d" % index
		button.text = content.section_labels[index]
		button.custom_minimum_size = Vector2(0, 48)
		button.toggle_mode = true
		button.button_group = group
		button.pressed.connect(select_section.bind(index))
		_sections.add_child(button)
		_section_buttons.append(button)


func select_section(index: int) -> void:
	if not _open or index < 0 or index >= _section_buttons.size():
		return
	var changed := index != _selected_section
	_apply_section(index)
	if changed:
		section_changed.emit(index)


func _apply_section(index: int) -> void:
	_selected_section = index
	_section_title.text = content.section_headings[index]
	_body.text = content.section_bodies[index]
	_inspection_heading.text = _section_title.text
	_inspection_body.text = _body.text
	_inspection_scroll.scroll_vertical = 0
	_scroll.scroll_vertical = 0
	for i in _section_buttons.size():
		_section_buttons[i].set_pressed_no_signal(i == index)


func show_full_artwork() -> void:
	if not _open:
		return
	_sources.hide()
	_detail.hide()
	_update_mode_state()
	_sync_focus_cycle()
	_full_button.grab_focus()
	artwork_view_changed.emit(&"full")


func show_detail_view() -> void:
	if not _open or _detail_button.disabled or _detail.visible or _sources.visible:
		return
	_detail.show()
	_update_mode_state()
	_sync_focus_cycle()
	_fit_artwork.call_deferred()
	_region_buttons[_selected_region].grab_focus()
	artwork_view_changed.emit(&"inspect")


func close_detail_view() -> void:
	if not _open or not _detail.visible:
		return
	show_full_artwork()


func _update_mode_state() -> void:
	_full_button.set_pressed_no_signal(not _detail.visible)
	_detail_button.set_pressed_no_signal(_detail.visible)


func _build_regions() -> void:
	for button in _region_buttons:
		_regions.remove_child(button)
		button.queue_free()
	_region_buttons.clear()
	_detail_image.texture = null
	if content.artwork_texture == null or content.inspection_labels.size() != content.inspection_regions.size():
		return
	for rect in content.inspection_regions:
		if rect.size.x <= 0 or rect.size.y <= 0 or not Rect2(0, 0, 1, 1).encloses(rect):
			return
	var group := ButtonGroup.new()
	for index in content.inspection_labels.size():
		var button := Button.new()
		button.text = content.inspection_labels[index]
		button.accessibility_name = button.text
		button.custom_minimum_size = Vector2(0, 48)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		button.button_group = group
		button.pressed.connect(select_inspection_region.bind(index))
		_regions.add_child(button)
		_region_buttons.append(button)
	_selected_region = 0
	if not _region_buttons.is_empty():
		_apply_region(0)


func select_inspection_region(index: int) -> void:
	if not _open or index < 0 or index >= _region_buttons.size():
		return
	_apply_region(index)


func _apply_region(index: int) -> void:
	_selected_region = index
	var rect := content.inspection_regions[index]
	var native := content.artwork_texture.get_size()
	var crop := AtlasTexture.new()
	crop.atlas = content.artwork_texture
	crop.region = Rect2(rect.position * native, rect.size * native)
	crop.filter_clip = true
	_detail_image.texture = crop
	_viewing.text = "Viewing: " + content.inspection_labels[index]
	_detail_image.accessibility_name = _viewing.text + ". " + content.alt_text
	for i in _region_buttons.size():
		_region_buttons[i].set_pressed_no_signal(i == index)
	_fit_artwork.call_deferred()


func open_sources() -> void:
	if not _open or _sources_button.disabled or _sources.visible:
		return
	_sources.show()
	_source_scroll.scroll_vertical = 0
	_sync_focus_cycle()
	_source_close.grab_focus()
	sources_opened.emit()


func close_sources() -> void:
	if not _open or not _sources.visible:
		return
	_sources.hide()
	_sync_focus_cycle()
	if _detail.visible:
		_detail_sources.grab_focus()
	else:
		_sources_button.grab_focus()
	sources_closed.emit()


func toggle_narration() -> void:
	if not _open or _audio.stream == null:
		return
	if _audio.playing and not _audio.stream_paused:
		stop_narration()
	else:
		restart_narration()


func stop_narration() -> void:
	_audio.stop()
	_audio.stream_paused = false
	_update_audio_controls()


# Retained for compatibility with callers; the visitor UI exposes only play/stop.
func listen() -> void:
	if not _open or _audio.stream == null:
		return
	if _audio.stream_paused:
		_audio.stream_paused = false
	elif not _audio.playing:
		_audio.play()
	_update_audio_controls()


func pause_narration() -> void:
	if _open and _audio.playing:
		_audio.stream_paused = true
	_update_audio_controls()


func restart_narration() -> void:
	if not _open or _audio.stream == null:
		return
	_audio.stop()
	_audio.stream_paused = false
	_audio.play()
	_update_audio_controls()


func _update_audio_controls() -> void:
	var speaker_had_focus := _speaker.has_focus()
	var playing := _audio.playing and not _audio.stream_paused
	_speaker.disabled = _audio.stream == null
	_speaker.set_pressed_no_signal(playing)
	var action := "Stop narration" if playing else "Play narration"
	if _speaker.disabled:
		action = "Narration audio pending"
	_speaker.tooltip_text = action
	_speaker.accessibility_name = action
	if _open:
		_sync_focus_cycle()
		if speaker_had_focus and not _speaker.disabled and not _detail.visible and not _sources.visible:
			_speaker.grab_focus()


func _fit_artwork() -> void:
	if not is_node_ready():
		return
	_fit_image(_art, _art_holder, 1.0, 360.0)
	_fit_image(_detail_image, _detail_holder, 1.25, INF)


func _fit_image(image: TextureRect, holder: Control, scale_limit: float, height_limit: float) -> void:
	if image.texture == null:
		return
	var native := image.texture.get_size()
	var factor := minf(scale_limit, minf(holder.size.x / native.x, minf(holder.size.y, height_limit) / native.y))
	image.size = native * maxf(factor, 0.0)
	image.position = (holder.size - image.size) * 0.5


func _sync_focus_cycle() -> void:
	var main: Array[Control] = [_speaker, _full_button, _detail_button, _scroll]
	for button in _section_buttons:
		main.append(button)
	main.append_array([_sources_button, _close])
	var detail: Array[Control] = []
	for button in _region_buttons:
		detail.append(button)
	detail.append_array([_inspection_scroll, _detail_sources, _detail_close])
	var sources: Array[Control] = [_source_scroll, _source_close]
	for control in main + detail + sources:
		control.focus_mode = Control.FOCUS_NONE
	var candidates: Array[Control] = sources if _sources.visible else (detail if _detail.visible else main)
	var active: Array[Control] = []
	for control in candidates:
		if control.is_visible_in_tree() and not (control is BaseButton and (control as BaseButton).disabled):
			control.focus_mode = Control.FOCUS_ALL
			active.append(control)
	for index in active.size():
		var control := active[index]
		control.focus_previous = control.get_path_to(active[(index - 1 + active.size()) % active.size()])
		control.focus_next = control.get_path_to(active[(index + 1) % active.size()])
		# Keep directional focus within the active layer; scrolling still uses arrows.
		control.focus_neighbor_left = NodePath(".")
		control.focus_neighbor_right = NodePath(".")
		control.focus_neighbor_top = NodePath(".")
		control.focus_neighbor_bottom = NodePath(".")


func _unhandled_input(event: InputEvent) -> void:
	if not _open or not event.is_action_pressed(&"go_back"):
		return
	var viewport := get_viewport()
	viewport.set_input_as_handled()
	if event.is_echo():
		return
	if _sources.visible:
		close_sources()
	elif _detail.visible:
		close_detail_view()
	else:
		close_interaction()


func close_interaction() -> void:
	if not _open:
		return
	_open = false
	stop_narration()
	_sources.hide()
	_detail.hide()
	hide()
	_restore_focus.call_deferred()
	closed.emit()


func _restore_focus() -> void:
	if _open or not is_inside_tree() or _return_focus == null:
		return
	var target := _return_focus.get_ref() as Control
	if is_instance_valid(target) and target.is_inside_tree() and target.is_visible_in_tree() \
			and target.focus_mode != Control.FOCUS_NONE \
			and not (target is BaseButton and (target as BaseButton).disabled):
		target.grab_focus()


func _exit_tree() -> void:
	if is_instance_valid(_audio):
		_audio.stop()
