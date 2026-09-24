extends ConferenceRoomInteraction
## Standalone orientation panel. The future host owns landmark navigation.

signal hotspot_closed

enum Section { ABOUT, HISTORICAL_NAME, PRESENT_ROLE }

const SectionEntry = preload("res://scripts/landmarks/lingayen_church/lc_ext_01_section.gd")
const ChurchContent = preload("res://scripts/landmarks/lingayen_church/lc_ext_01_content.gd")

var _media := VBoxContainer.new()
var _caption := Label.new()
var _formal_name := Label.new()
var _credit := Label.new()
var _pending := Label.new()
var _key_label := Label.new()
var _tabs: HBoxContainer
var _panel_tween: Tween
var _closing: bool = false


func _ready() -> void:
	super._ready()
	closed.connect(func() -> void: hotspot_closed.emit())
	var header := $Main/Margin/Layout/Header
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	header.move_child(titles, 0)
	_title.reparent(titles)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titles.add_child(_formal_name)
	_formal_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_formal_name.add_theme_font_size_override("font_size", 18)
	_formal_name.add_theme_color_override("font_color", Color(0.76, 0.75, 0.67, 1))
	# Keep the inherited speaker/Close controls and their existing signal wiring.
	var listen_group := VBoxContainer.new()
	listen_group.name = "ListenGroup"
	listen_group.add_theme_constant_override("separation", 4)
	header.add_child(listen_group)
	header.move_child(listen_group, 1)
	_speaker.reparent(listen_group)
	_speaker.custom_minimum_size = Vector2(136, 56)
	_pending.text = "Narration pending."
	_pending.add_theme_font_size_override("font_size", 16)
	_pending.add_theme_color_override("font_color", Color(0.76, 0.75, 0.67, 1))
	_pending.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	listen_group.add_child(_pending)
	header.add_theme_constant_override("separation", 12)
	_close.text = "Close"
	_close.custom_minimum_size = Vector2(80, 56)
	_close.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_media.name = "ChurchMedia"
	_media.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_media.size_flags_stretch_ratio = 0.46
	_information.size_flags_stretch_ratio = 0.54
	%Columns.add_child(_media)
	%Columns.move_child(_media, 0)
	_image.reparent(_media)
	_image.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_media.add_child(_caption)
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.add_theme_font_size_override("font_size", 16)
	_tabs = $Main/Margin/Layout/Sections
	_tabs.reparent(_information)
	_information.move_child(_tabs, 0)
	_heading.reparent(_body.get_parent())
	_body.get_parent().move_child(_heading, 0)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	$Main/Margin/Layout/Columns/Information/Meta.hide()
	_key_label.text = "KEY TAKEAWAY"
	_key_label.add_theme_font_size_override("font_size", 16)
	_key_label.add_theme_color_override("font_color", Color("d8c58b"))
	_takeaway.add_theme_color_override("font_color", Color(0.76, 0.75, 0.67, 1))
	_body.get_parent().add_child(_key_label)
	_body.get_parent().move_child(_key_label, 2)
	# Sources stays in its shared information-column position, below the scroll.
	_sources_button.text = "Sources"
	_sources_button.custom_minimum_size = Vector2(48, 56)
	_information.add_child(_credit)
	$Main/Margin/Layout/Controls.hide()
	_credit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_credit.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_credit.add_theme_font_size_override("font_size", 14)
	_credit.add_theme_color_override("font_color", Color(0.76, 0.75, 0.67, 1))
	_source_close.custom_minimum_size.y = 56
	for i in _concepts.size():
		_concepts[i].custom_minimum_size = Vector2(48, 56)
		_concepts[i].gui_input.connect(_tab_input.bind(i))
	resized.connect(_resize_layout)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	# F6 on the component itself is also useful; the preview provides the trigger.
	_open_standalone.call_deferred()


func _open_standalone() -> void:
	if get_tree().current_scene == self:
		open_hotspot()


func open_hotspot() -> bool:
	return open_interaction()


func open_interaction() -> bool:
	if not is_node_ready() or not content is ChurchContent or content.concepts.size() != 3:
		return false
	for entry in content.concepts:
		if not entry is SectionEntry:
			return false
	if _open and not _closing:
		return true
	_cancel_panel_tween()
	_closing = false
	if not _open and not super.open_interaction():
		return false
	reset_hotspot()
	modulate.a = 0.0
	_panel_tween = create_tween()
	_panel_tween.tween_property(self, "modulate:a", 1.0, 0.18)
	return true


func reset_hotspot() -> void:
	if not is_node_ready() or not content is ChurchContent:
		return
	_cancel_panel_tween()
	_closing = false
	_sources.hide()
	stop_narration()
	select_section(Section.ABOUT, false)
	if _open:
		_sync_focus()
		_concepts[0].grab_focus()


func select_concept(index: int) -> void:
	select_section(index)


func select_section(index: int, animate: bool = true) -> void:
	if not is_node_ready() or content == null or _sources.visible or _closing:
		return
	_selected = index if index >= Section.ABOUT and index <= Section.PRESENT_ROLE else Section.ABOUT
	_cancel_fade()
	_render()
	if animate and _open:
		_information.modulate.a = 0.65
		_fade = create_tween()
		_fade.tween_property(_information, "modulate:a", 1.0, 0.16)
	concept_changed.emit(_selected)


func _render() -> void:
	var entry := content.concepts[_selected] as SectionEntry
	_title.text = content.title.to_upper()
	_formal_name.text = content.formal_name
	_heading.text = entry.heading
	_body.text = entry.body
	_takeaway.text = entry.takeaway
	_takeaway.visible = not entry.takeaway.is_empty()
	_key_label.visible = _takeaway.visible
	_image.texture = entry.image if entry.image != null else content.illustration
	_image.accessibility_name = content.illustration_alt_text
	_caption.text = entry.image_caption
	_caption.visible = not entry.image_caption.is_empty()
	_credit.text = entry.image_credit if not entry.image_credit.is_empty() else content.image_credit
	_source_text.text = entry.heading + "\n\n" + entry.source_credit
	for i in _concepts.size():
		_concepts[i].set_pressed_no_signal(i == _selected)
	_scroll.scroll_vertical = 0
	_resize_layout()


func open_sources() -> void:
	if _closing:
		return
	super.open_sources()
	# Historical citations only; photo provenance stays below the Sources control.
	var entry := content.concepts[_selected] as SectionEntry
	_source_text.text = entry.heading + "\n\n" + entry.source_credit


func _update_speaker() -> void:
	super._update_speaker()
	_speaker.show()
	_speaker.disabled = _audio.stream == null
	_speaker.text = "STOP" if _audio.playing else "LISTEN"
	_pending.visible = _audio.stream == null


func stop_narration() -> void:
	_audio.stream_paused = false
	super.stop_narration()


func _tab_input(event: InputEvent, index: int) -> void:
	if _sources.visible or _closing:
		return
	var step := 0
	if event.is_action_pressed(&"ui_left"):
		step = -1
	elif event.is_action_pressed(&"ui_right"):
		step = 1
	if step != 0:
		get_viewport().set_input_as_handled()
		var target := clampi(index + step, 0, 2)
		select_section(target)
		_concepts[target].grab_focus()


func _resize_layout() -> void:
	if not is_node_ready() or _tabs == null:
		return
	var compact := size.x < 1000 or size.y < 550
	var margin := 8 if compact else 16
	for side in ["left", "top", "right", "bottom"]:
		$Main/Margin.add_theme_constant_override("margin_" + side, margin)
	%Columns.add_theme_constant_override("separation", 12 if compact else 24)
	$Main/Margin/Layout.add_theme_constant_override("separation", 4 if compact else 8)
	_information.add_theme_constant_override("separation", 4 if compact else 8)
	_body.get_parent().add_theme_constant_override("separation", 8 if compact else 12)
	_title.add_theme_font_size_override("font_size", 24 if compact else 30)
	_heading.add_theme_font_size_override("font_size", 20 if compact else 24)
	_body.add_theme_font_size_override("font_size", 18 if compact else 20)
	_takeaway.add_theme_font_size_override("font_size", 18)
	_key_label.add_theme_font_size_override("font_size", 14 if compact else 16)
	_tabs.add_theme_constant_override("separation", 4 if compact else 8)
	if content != null:
		for i in _concepts.size():
			var label: String = content.concepts[i].tab_label
			if compact:
				label = label.replace("THE CHURCH", "THE\nCHURCH").replace("HISTORICAL NAME", "HISTORICAL\nNAME").replace("PRESENT ROLE", "PRESENT\nROLE")
			_concepts[i].text = label
			_concepts[i].add_theme_font_size_override("font_size", 16 if compact else 18)
	if _open:
		_sync_focus()


func close_hotspot() -> void:
	close_interaction()


func close_interaction() -> void:
	if not _open or _closing:
		return
	_cancel_fade()
	_cancel_panel_tween()
	stop_narration()
	_closing = true
	_panel_tween = create_tween()
	_panel_tween.tween_property(self, "modulate:a", 0.0, 0.16)
	_panel_tween.tween_callback(_finish_close)


func _finish_close() -> void:
	_panel_tween = null
	_closing = false
	modulate.a = 1.0
	super.close_interaction()


func _cancel_panel_tween() -> void:
	if _panel_tween != null and _panel_tween.is_valid():
		_panel_tween.kill()
	_panel_tween = null
	modulate.a = 1.0


func _visibility_changed() -> void:
	if _open and not is_visible_in_tree():
		_cancel_panel_tween()
		_finish_close()


func _exit_tree() -> void:
	_cancel_panel_tween()
	super._exit_tree()
