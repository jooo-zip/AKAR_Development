@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/casa_real/cr_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview

## Reuses the established shell, Sources modal and signals; directory state is local.
signal close_requested
enum ViewState { DIRECTORY, PREVIEW, IMAGE_FOCUS }
enum PreviewMode { PHOTO, VIDEO }
const GalleryContent = preload("res://scripts/landmarks/casa_real/cr_int_02_content.gd")
const Trail = preload("res://scripts/landmarks/casa_real/cr_int_02_trail.gd")
var current_view: ViewState = ViewState.DIRECTORY
var preview_mode: PreviewMode = PreviewMode.PHOTO
var selected_gallery_index: int = 0
var trail_dragging: bool = false
var video_has_played: bool = false
var _transition: Tween
var _media_transition: Tween
var _subtitle: Label
var _directory: VBoxContainer
var _intro_heading: Label
var _intro_body: Label
var _trail: Trail
var _helper: Label
var _preview: HBoxContainer
var _media: Button
var _video: VideoStreamPlayer
var _left_frame: ColorRect
var _right_frame: ColorRect
var _actions_scroll: ScrollContainer
var _actions: VBoxContainer
var _number: Label
var _gallery_title: Label
var _invitation: Label
var _watch: Button
var _view_photo: Button
var _directory_button: Button
var _continue: Button
var _enter: Button
var _focus_view: VBoxContainer
var _focus_title: Label
var _focus_photo: TextureRect
var _focus_close: Button
var _directory_controls: HBoxContainer
var _previous: Button
var _next: Button
var _open_preview: Button
var _visit_modal: Control
var _visit_panel: PanelContainer
var _visit_title: Label
var _visit_body: Label
var _visit_scroll: ScrollContainer
var _reservation_link: LinkButton
var _visitor_info_link: LinkButton
var _visit_back: Button
# Replaceable only by tests to observe external requests without launching a browser.
var _url_opener: Callable = OS.shell_open

func _ready() -> void:
	if Engine.is_editor_hint():
		_refresh_editor_preview.call_deferred()
		return
	_presentation_root = self
	super._ready()
	_build_presentation()
	resized.connect(_resize_layout)
	visibility_changed.connect(func() -> void:
		if _open and not is_visible_in_tree(): close_interaction())
	_resize_layout()
	_open_standalone.call_deferred()

func _build_presentation() -> void:
	_subtitle = Label.new()
	_directory = VBoxContainer.new()
	_intro_heading = Label.new()
	_intro_body = Label.new()
	_trail = Trail.new()
	_helper = Label.new()
	_preview = HBoxContainer.new()
	_media = Button.new()
	_video = VideoStreamPlayer.new()
	_left_frame = ColorRect.new()
	_right_frame = ColorRect.new()
	_actions_scroll = ScrollContainer.new()
	_actions = VBoxContainer.new()
	_number = Label.new()
	_gallery_title = Label.new()
	_invitation = Label.new()
	_watch = Button.new()
	_view_photo = Button.new()
	_directory_button = Button.new()
	_continue = Button.new()
	_enter = Button.new()
	_focus_view = VBoxContainer.new()
	_focus_title = Label.new()
	_focus_photo = TextureRect.new()
	_focus_close = Button.new()
	_directory_controls = HBoxContainer.new()
	_previous = Button.new()
	_next = Button.new()
	_open_preview = Button.new()
	_visit_modal = Control.new()
	_visit_panel = PanelContainer.new()
	_visit_title = Label.new()
	_visit_body = Label.new()
	_visit_scroll = ScrollContainer.new()
	_reservation_link = LinkButton.new()
	_visitor_info_link = LinkButton.new()
	_visit_back = Button.new()
	var layout := _presentation_root.get_node("Main/Margin/Layout")
	var header := _presentation_root.get_node("Main/Margin/Layout/Header")
	_sources_button.reparent(header)
	_speaker.reparent(header)
	header.move_child(_close, header.get_child_count() - 1)
	_title.text = content.title
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subtitle.text = content.subtitle
	layout.add_child(_subtitle)
	layout.move_child(_subtitle, 1)
	for old in [_presentation_root.get_node("Main/Margin/Layout/Controls"), _presentation_root.get_node("Main/Margin/Layout/Sections"), _presentation_root.get_node("Main/Margin/Layout/Columns")]:
		old.hide()
	for button in [_sources_button, _speaker, _close]:
		button.custom_minimum_size = Vector2(108, 56)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_sources_button.text = "SOURCES"
	_close.text = "CLOSE"
	_speaker.expand_icon = true
	_speaker.add_theme_constant_override("icon_max_width", 24)
	for page in [_directory, _preview, _focus_view]:
		layout.add_child(page)
		page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_directory.add_theme_constant_override("separation", 12)
	_directory.add_child(_intro_heading)
	_directory.add_child(_intro_body)
	_directory.add_child(_trail)
	_directory.add_child(_helper)
	_directory.add_child(_directory_controls)
	_intro_heading.text = content.overview_heading
	_intro_body.text = content.overview_body
	_helper.text = content.directory_helper
	_helper.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_trail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_trail.custom_minimum_size.y = 184
	_trail.configure(content.galleries)
	if not Engine.is_editor_hint():
		_trail.selection_requested.connect(select_gallery)
	if not Engine.is_editor_hint():
		_trail.dragging_changed.connect(func(active: bool) -> void: trail_dragging = active)
	_directory_controls.alignment = BoxContainer.ALIGNMENT_CENTER
	for button in [_previous, _open_preview, _next]:
		_directory_controls.add_child(button)
	_previous.text = "←"
	_next.text = "→"
	_previous.accessibility_name = "Previous directory entry"
	_next.accessibility_name = "Next directory entry"
	_open_preview.text = "PREVIEW GALLERY"
	if not Engine.is_editor_hint():
		_previous.pressed.connect(func() -> void: select_gallery(selected_gallery_index - 1))
	if not Engine.is_editor_hint():
		_next.pressed.connect(func() -> void: select_gallery(selected_gallery_index + 1))
	if not Engine.is_editor_hint():
		_open_preview.pressed.connect(func() -> void: select_gallery(selected_gallery_index, true))
	_preview.add_theme_constant_override("separation", 20)
	_preview.add_child(_media)
	_preview.add_child(_actions_scroll)
	_media.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_media.size_flags_stretch_ratio = 0.67
	_media.clip_contents = true
	_media.accessibility_name = "Gallery media. Play or skip a short gallery glimpse."
	if not Engine.is_editor_hint():
		_media.pressed.connect(toggle_glimpse)
	_image.reparent(_media)
	_media.add_child(_video)
	for frame in [_left_frame, _right_frame]:
		_media.add_child(frame)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.color = Color("101b16")
	_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_image.offset_left = 8
	_image.offset_top = 8
	_image.offset_right = -8
	_image.offset_bottom = -8
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_video.expand = true
	_video.autoplay = false
	_video.loop = false
	_video.volume = 0.0
	_video.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_video.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	if not Engine.is_editor_hint():
		_video.finished.connect(_finish_video)
	_actions_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_actions_scroll.size_flags_stretch_ratio = 0.33
	_actions_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_actions_scroll.add_child(_actions)
	_actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_actions.add_theme_constant_override("separation", 8)
	for control in [_number, _gallery_title, _watch, _view_photo, _invitation, _directory_button, _continue, _enter]:
		_actions.add_child(control)
	if not Engine.is_editor_hint():
		_watch.pressed.connect(toggle_glimpse)
	_view_photo.text = "VIEW PHOTO"
	if not Engine.is_editor_hint():
		_view_photo.pressed.connect(open_image_focus)
	_directory_button.text = "RETURN TO DIRECTORY"
	if not Engine.is_editor_hint():
		_directory_button.pressed.connect(return_to_directory)
	_continue.text = "CONTINUE EXPLORING"
	if not Engine.is_editor_hint():
		_continue.pressed.connect(continue_exploring)
	_enter.text = "ENTER GALLERY"
	if not Engine.is_editor_hint():
		_enter.pressed.connect(_open_visit_banaan_modal)
	_invitation.text = content.invitation
	_focus_view.add_child(_focus_title)
	_focus_view.add_child(_focus_photo)
	_focus_view.add_child(_focus_close)
	_focus_photo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_focus_photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_focus_photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_focus_photo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_focus_close.text = "CLOSE VIEW"
	if not Engine.is_editor_hint():
		_focus_close.pressed.connect(close_image_focus)
	for label in [_subtitle, _intro_heading, _intro_body, _helper, _number, _gallery_title, _invitation, _focus_title]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for label in [_subtitle, _helper, _invitation]:
		label.add_theme_color_override("font_color", Color("c2bfae"))
	_number.add_theme_color_override("font_color", Color("d8c58b"))
	for button in [_previous, _next, _open_preview, _watch, _view_photo, _directory_button, _continue, _enter, _focus_close, _source_close]:
		button.custom_minimum_size = Vector2(56, 56)
	for scroller in [_actions_scroll, _source_scroll]:
		if not Engine.is_editor_hint():
			scroller.gui_input.connect(_reading_input.bind(scroller))
		scroller.add_theme_stylebox_override("focus", _close.get_theme_stylebox("focus"))
	_source_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_build_visit_modal()

func _open_standalone() -> void:
	if Engine.is_editor_hint():
		return
	if get_tree().current_scene == self: open_hotspot()

func open_hotspot() -> bool:
	if Engine.is_editor_hint():
		return false
	return open_interaction()

func open_interaction() -> bool:
	if Engine.is_editor_hint():
		return false
	if not is_node_ready() or not content is GalleryContent or content.galleries.size() != 13:
		return false
	for entry in content.galleries:
		if entry.preview_texture == null or entry.preview_video == null: return false
	if content.narration_stream == null: return false
	if _open: return true
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = null
	if previous != null: _return_focus = weakref(previous)
	_open = true
	_audio.stream = content.narration_stream
	show()
	reset_hotspot()
	_trail.grab_focus()
	opened.emit()
	return true

func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	_visit_modal.hide()
	_cancel_transitions()
	_stop_video()
	stop_narration()
	_sources.hide()
	_source_scroll.scroll_vertical = 0
	current_view = ViewState.DIRECTORY
	video_has_played = false
	select_gallery(0)
	_trail.center_on(0, false)
	_render()
	if _open: _trail.grab_focus()

func select_gallery(index: int, open_preview: bool = false) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or _visit_modal.visible: return
	_cancel_transitions()
	_stop_video()
	selected_gallery_index = clampi(index, 0, content.galleries.size() - 1)
	video_has_played = false
	_trail.center_on(selected_gallery_index)
	if open_preview or current_view == ViewState.IMAGE_FOCUS:
		current_view = ViewState.PREVIEW
	_render()
	_actions_scroll.scroll_vertical = 0
	if current_view == ViewState.PREVIEW:
		_reveal_window()
		_watch.grab_focus()

func _entry() -> Resource:
	return content.galleries[selected_gallery_index]

func _render() -> void:
	_directory.visible = current_view == ViewState.DIRECTORY
	_preview.visible = current_view == ViewState.PREVIEW
	_focus_view.visible = current_view == ViewState.IMAGE_FOCUS
	var entry := _entry()
	_number.text = entry.display_number.to_upper()
	if entry.principal_group == 5: _number.text += " · GALLERY 5: 5A + 5B"
	if entry.principal_group == 6: _number.text += " · GALLERY 6: 6A + 6B"
	_gallery_title.text = entry.official_title
	_image.texture = entry.preview_texture
	_image.accessibility_name = entry.display_number + " — " + entry.official_title
	_focus_photo.texture = entry.preview_texture
	_focus_title.text = entry.display_number + " — " + entry.official_title
	_image.visible = preview_mode == PreviewMode.PHOTO
	_video.visible = preview_mode == PreviewMode.VIDEO
	_watch.text = "WATCH GLIMPSE"
	if video_has_played: _watch.text = "REPLAY GLIMPSE"
	if preview_mode == PreviewMode.VIDEO: _watch.text = "SKIP GLIMPSE"
	_previous.disabled = selected_gallery_index == 0
	_next.disabled = selected_gallery_index == content.galleries.size() - 1
	_sync_focus()

func _reveal_window() -> void:
	if Engine.is_editor_hint():
		return
	_image.modulate.a = 0.0
	_actions.modulate.a = 0.0
	for frame in [_left_frame, _right_frame]:
		frame.show()
		frame.size = Vector2(18, _media.size.y)
		frame.modulate.a = 0.65
	_left_frame.position = Vector2.ZERO
	_right_frame.position = Vector2(_media.size.x - 18, 0)
	_transition = create_tween().set_parallel(true)
	_transition.tween_property(_left_frame, "position:x", -18.0, 0.16).set_delay(0.12)
	_transition.tween_property(_right_frame, "position:x", _media.size.x, 0.16).set_delay(0.12)
	_transition.tween_property(_image, "modulate:a", 1.0, 0.16).set_delay(0.18)
	_transition.tween_property(_actions, "modulate:a", 1.0, 0.16).set_delay(0.22)
	_transition.chain().tween_callback(_cancel_transitions)

func toggle_glimpse() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or _visit_modal.visible or current_view != ViewState.PREVIEW: return
	_cancel_transitions()
	if preview_mode == PreviewMode.VIDEO:
		_finish_video()
		return
	_stop_video()
	preview_mode = PreviewMode.VIDEO
	video_has_played = true
	_video.stream = _entry().preview_video
	_video.volume = 0.0
	_video.loop = false
	_video.paused = false
	_video.play()
	_render()
	_fit_video()
	_video.modulate.a = 0.0
	_media_transition = create_tween()
	_media_transition.tween_property(_video, "modulate:a", 1.0, 0.18)

func _finish_video() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_transitions()
	_stop_video()
	_render()
	_image.modulate.a = 0.65
	_media_transition = create_tween()
	_media_transition.tween_property(_image, "modulate:a", 1.0, 0.18)

func _stop_video() -> void:
	if Engine.is_editor_hint():
		return
	_video.stop()
	_video.paused = false
	_video.stream = null
	_video.hide()
	preview_mode = PreviewMode.PHOTO
	_image.show()
	_image.modulate.a = 1.0

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _open and preview_mode == PreviewMode.VIDEO: _fit_video()

func _fit_video() -> void:
	if Engine.is_editor_hint():
		return
	var texture := _video.get_video_texture()
	if texture == null or texture.get_height() <= 0: return
	var available := _media.size - Vector2(16, 16)
	var factor := minf(available.x / texture.get_width(), available.y / texture.get_height())
	_video.size = texture.get_size() * factor
	_video.position = (_media.size - _video.size) / 2

func open_image_focus() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or _visit_modal.visible or current_view != ViewState.PREVIEW: return
	_cancel_transitions()
	_stop_video()
	current_view = ViewState.IMAGE_FOCUS
	_render()
	_focus_view.modulate.a = 0.65
	_transition = create_tween()
	_transition.tween_property(_focus_view, "modulate:a", 1.0, 0.2)
	_focus_close.grab_focus()

func close_image_focus() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or _visit_modal.visible: return
	_cancel_transitions()
	current_view = ViewState.PREVIEW
	_render()
	_view_photo.grab_focus()

func return_to_directory() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or _visit_modal.visible: return
	_cancel_transitions()
	_stop_video()
	current_view = ViewState.DIRECTORY
	_trail.center_on(selected_gallery_index)
	_render()
	_trail.grab_focus()

func continue_exploring() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or _visit_modal.visible or current_view != ViewState.PREVIEW: return
	var next_index := selected_gallery_index + 1
	if next_index >= content.galleries.size():
		next_index = 0
	select_gallery(next_index, true)

func _open_visit_banaan_modal() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or current_view != ViewState.PREVIEW: return
	if _visit_modal.visible: return
	_cancel_transitions()
	_stop_video()
	_render()
	_visit_scroll.scroll_vertical = 0
	_visit_modal.show()
	_resize_visit_modal.call_deferred()
	_sync_focus()
	_reservation_link.grab_focus()

func _close_visit_banaan_modal() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or not _visit_modal.visible: return
	_visit_modal.hide()
	_sync_focus()
	_enter.grab_focus()

func _build_visit_modal() -> void:
	_visit_modal.name = "VisitBanaanModal"
	_presentation_root.add_child(_visit_modal)
	_visit_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_visit_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	_visit_modal.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.55)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visit_modal.add_child(_visit_panel)
	_visit_panel.minimum_size_changed.connect(_resize_visit_modal.call_deferred)
	var border := StyleBoxFlat.new()
	border.bg_color = Color("14231d")
	border.border_color = Color("d8c58b")
	border.set_border_width_all(1)
	border.set_content_margin_all(12)
	_visit_panel.add_theme_stylebox_override("panel", border)
	var layout := VBoxContainer.new()
	_visit_panel.add_child(layout)
	layout.add_theme_constant_override("separation", 8)
	layout.add_child(_visit_title)
	_visit_title.text = content.visit_modal_title
	_visit_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_visit_title.add_theme_font_size_override("font_size", 22)
	_visit_title.add_theme_color_override("font_color", Color("d8c58b"))
	layout.add_child(_visit_scroll)
	_visit_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_visit_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_visit_scroll.follow_focus = true
	if not Engine.is_editor_hint():
		_visit_scroll.gui_input.connect(_reading_input.bind(_visit_scroll))
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override("separation", 4)
	_visit_scroll.add_child(text)
	text.add_child(_visit_body)
	_visit_body.text = content.visit_modal_body
	_visit_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_visit_body.add_theme_font_size_override("font_size", 18)
	for i in 2:
		var heading := Label.new()
		heading.text = content.reservation_heading if i == 0 else content.visitor_info_heading
		heading.add_theme_font_size_override("font_size", 18)
		text.add_child(heading)
		var link: LinkButton = _reservation_link if i == 0 else _visitor_info_link
		link.text = content.reservation_label if i == 0 else content.visitor_info_label
		link.custom_minimum_size.y = 48
		link.underline = LinkButton.UNDERLINE_MODE_ALWAYS
		link.add_theme_font_size_override("font_size", 17)
		link.add_theme_color_override("font_color", Color("d8c58b"))
		link.add_theme_color_override("font_hover_color", Color("fff1bb"))
		link.add_theme_stylebox_override("focus", _close.get_theme_stylebox("focus"))
		text.add_child(link)
		var url: String = content.reservation_url if i == 0 else content.visitor_info_url
		if not Engine.is_editor_hint():
			link.pressed.connect(_open_visit_link.bind(url))
		if not Engine.is_editor_hint():
			link.gui_input.connect(_visit_link_input.bind(link))
	var inquiries := Label.new()
	inquiries.text = content.museum_inquiries_heading + "\n" + content.museum_phone + "\n" + content.museum_email
	inquiries.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inquiries.add_theme_font_size_override("font_size", 18)
	text.add_child(inquiries)
	layout.add_child(_visit_back)
	_visit_back.text = content.visit_back_label
	_visit_back.custom_minimum_size.y = 56
	if not Engine.is_editor_hint():
		_visit_back.pressed.connect(_close_visit_banaan_modal)
	_visit_modal.hide()
	# Preserve Sources priority if the host opens it while the invitation is visible.
	_presentation_root.move_child(_sources, _presentation_root.get_child_count() - 1)

func _visit_link_input(event: InputEvent, link: LinkButton) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_SPACE]:
		link.accept_event()
		if not event.echo: link.pressed.emit()

func _open_visit_link(url: String) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or not _visit_modal.visible or _sources.visible: return
	if url not in [content.reservation_url, content.visitor_info_url]: return
	_url_opener.call(url)

func close_sources() -> void:
	if Engine.is_editor_hint():
		return
	if _visit_modal.visible:
		if not _open or not _sources.visible: return
		_sources.hide()
		_sync_focus()
		_reservation_link.grab_focus()
		sources_closed.emit()
	else:
		super.close_sources()

func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible: return
	_cancel_transitions()
	_trail.end_drag()
	_trail.center_on(selected_gallery_index, false)
	_stop_video()
	_render()
	_source_title.text = "Sources"
	_source_text.text = content.source_credit
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()

func toggle_narration() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or _visit_modal.visible: return
	if _audio.stream_paused:
		_audio.stream_paused = false
	elif _audio.playing:
		_audio.stream_paused = true
	else:
		_audio.play()
		narration_started.emit()
	_update_speaker()

func _update_speaker() -> void:
	if Engine.is_editor_hint():
		return
	_speaker.text = "LISTEN"
	if _audio.playing: _speaker.text = "PAUSE"
	if _audio.stream_paused: _speaker.text = "RESUME"
	_speaker.set_pressed_no_signal(_audio.playing and not _audio.stream_paused)
	_speaker.accessibility_name = _speaker.text.capitalize() + " narration"

func stop_narration() -> void:
	if Engine.is_editor_hint():
		return
	_audio.stream_paused = false
	super.stop_narration()

func _sync_focus() -> void:
	if Engine.is_editor_hint():
		return
	var previous := get_viewport().gui_get_focus_owner()
	var all: Array[Control] = [_trail, _previous, _open_preview, _next, _media, _actions_scroll, _watch, _view_photo, _directory_button, _continue, _enter, _focus_close, _sources_button, _speaker, _close, _source_scroll, _source_close]
	all.append_array([_reservation_link, _visitor_info_link, _visit_back])
	var active: Array[Control] = []
	if _sources.visible:
		active = [_source_scroll, _source_close]
	elif _visit_modal.visible:
		active = [_reservation_link, _visitor_info_link, _visit_back]
	elif current_view == ViewState.DIRECTORY:
		active = [_trail, _previous, _open_preview, _next]
	elif current_view == ViewState.PREVIEW:
		active = [_media, _watch, _view_photo, _actions_scroll, _directory_button, _continue, _enter]
	else:
		active = [_focus_close]
	if not _sources.visible and not _visit_modal.visible: active.append_array([_sources_button, _speaker, _close])
	for control in all: control.focus_mode = Control.FOCUS_NONE
	var enabled: Array[Control] = []
	for control in active:
		if control is BaseButton and control.disabled: continue
		enabled.append(control)
	for i in enabled.size():
		enabled[i].focus_mode = Control.FOCUS_ALL
		enabled[i].focus_next = enabled[i].get_path_to(enabled[(i + 1) % enabled.size()])
		enabled[i].focus_previous = enabled[i].get_path_to(enabled[posmod(i - 1, enabled.size())])
	if previous in enabled: previous.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or not event.is_action_pressed(&"go_back"): return
	var viewport := get_viewport()
	if viewport != null: viewport.set_input_as_handled()
	if event.is_echo(): return
	if _sources.visible: close_sources()
	elif _visit_modal.visible: _close_visit_banaan_modal()
	elif current_view == ViewState.IMAGE_FOCUS: close_image_focus()
	elif current_view == ViewState.PREVIEW: return_to_directory()
	else: close_interaction()

func _reading_input(event: InputEvent, scroller: ScrollContainer) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventScreenDrag:
		scroller.scroll_vertical -= int(event.relative.y)
		scroller.accept_event()
	elif event is InputEventKey and event.pressed and event.keycode in [KEY_UP, KEY_DOWN, KEY_PAGEUP, KEY_PAGEDOWN, KEY_HOME, KEY_END]:
		scroller.accept_event()
		match event.keycode:
			KEY_HOME: scroller.scroll_vertical = 0
			KEY_END: scroller.scroll_vertical = int(scroller.get_v_scroll_bar().max_value)
			_: scroller.scroll_vertical += (-1 if event.keycode in [KEY_UP, KEY_PAGEUP] else 1) * 80

func _resize_layout() -> void:
	if Engine.is_editor_hint():
		EditorPresentation.resize(self, _presentation_root)
	if not is_node_ready(): return
	var compact := size.x < 1100
	var small := size.x < 900
	_trail.custom_minimum_size.y = 140 if small else 184
	_presentation_root.get_node("Main/Margin/Layout").add_theme_constant_override("separation", 6 if small else 8)
	var inset := 0.02 if compact else 0.05
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		_presentation_root.get_node("Main").set_anchor(side, inset if side in [SIDE_LEFT, SIDE_TOP] else 1.0 - inset, true)
		_presentation_root.get_node("Main").set_offset(side, 0)
	for side in ["left", "top", "right", "bottom"]:
		_presentation_root.get_node("Main/Margin").add_theme_constant_override("margin_" + side, 8 if compact else 16)
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_subtitle.add_theme_font_size_override("font_size", 17 if compact else 20)
	_intro_heading.add_theme_font_size_override("font_size", 23 if compact else 28)
	_intro_body.add_theme_font_size_override("font_size", 18 if compact else 22)
	_gallery_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_number.add_theme_font_size_override("font_size", 16)
	_invitation.add_theme_font_size_override("font_size", 17 if compact else 20)
	_helper.add_theme_font_size_override("font_size", 14 if compact else 17)
	_source_text.add_theme_font_size_override("font_size", 18 if compact else 22)
	_preview.add_theme_constant_override("separation", 12 if compact else 24)
	for button in [_watch, _view_photo, _directory_button, _continue, _enter]:
		button.add_theme_font_size_override("font_size", 16 if compact else 18)
	_directory.add_theme_constant_override("separation", 4 if small else (6 if compact else 12))
	_fit_video()
	_resize_visit_modal.call_deferred()

func _resize_visit_modal() -> void:
	if not is_inside_tree(): return
	var main: Control = _presentation_root.get_node("Main")
	_visit_panel.size = Vector2(minf(760, main.size.x - 32), minf(552, main.size.y - 24))
	_visit_panel.position = main.position + (main.size - _visit_panel.size) / 2

func _cancel_transitions() -> void:
	if Engine.is_editor_hint():
		return
	for tween in [_transition, _media_transition]:
		if tween != null and tween.is_valid(): tween.kill()
	_transition = null
	_media_transition = null
	for control in [_image, _video, _actions, _focus_view]: control.modulate.a = 1.0
	_left_frame.hide()
	_right_frame.hide()
	_trail.cancel_tween()

func close_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	close_interaction()

func close_interaction() -> void:
	if Engine.is_editor_hint():
		return
	if not _open: return
	_visit_modal.hide()
	_cancel_transitions()
	_stop_video()
	_trail.end_drag()
	current_view = ViewState.DIRECTORY
	_focus_view.hide()
	super.close_interaction()
	close_requested.emit()

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_transitions()
	_video.stop()
	super._exit_tree()

func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready() or content == null:
		return
	_presentation_root = EditorPresentation.begin(self)
	_build_presentation()
	current_view = ViewState.DIRECTORY
	preview_mode = PreviewMode.PHOTO
	selected_gallery_index = 0
	video_has_played = false
	_visit_modal.hide()
	_render()
	EditorPresentation.finish(self, _presentation_root)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
