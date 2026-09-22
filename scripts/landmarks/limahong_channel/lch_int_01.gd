extends ConferenceRoomInteraction
## Embedded statue explorer. The inherited shell owns Sources, audio and Escape.
signal section_changed(index: int)
signal close_requested

enum InfoSection { WHO_WAS_LIMAHONG, WHY_THIS_SITE }

const Magnifier = preload("res://scripts/landmarks/limahong_channel/lch_int_01_magnifier.gd")
const StatueContent = preload("res://scripts/landmarks/limahong_channel/lch_int_01_content.gd")
const GOLD := Color(0.88, 0.80, 0.55)

var current_section: int = InfoSection.WHO_WAS_LIMAHONG
var _explorer: Control
var _magnifier: Control
var _section_buttons: Array[Button] = []
var _prompt: Label
var _status: Label
var _placeholder: Label


func _ready() -> void:
	super._ready()
	var header := $Main/Margin/Layout/Header
	_speaker.reparent(header)
	_sources_button.reparent(header)
	header.move_child(_close, -1)
	_speaker.text = "LISTEN"
	_speaker.custom_minimum_size = Vector2(116, 48)
	_speaker.add_theme_constant_override("icon_max_width", 24)
	_speaker.expand_icon = true
	var subtitle := HBoxContainer.new()
	subtitle.name = "Subtitle"
	$Main/Margin/Layout.add_child(subtitle)
	$Main/Margin/Layout.move_child(subtitle, 1)
	var code := Label.new()
	code.text = content.hotspot_id
	code.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	code.add_theme_font_size_override("font_size", 14)
	code.add_theme_color_override("font_color", GOLD)
	subtitle.add_child(code)
	_status = Label.new()
	_status.text = "Narration pending"
	_status.add_theme_font_size_override("font_size", 14)
	subtitle.add_child(_status)
	$Main/Margin/Layout/Controls.hide()
	# Remove the shell's original selector buttons, not just their photo visuals.
	# Historical navigation now belongs entirely to the two information buttons.
	var old_sections := $Main/Margin/Layout/Sections
	old_sections.get_parent().remove_child(old_sections)
	old_sections.queue_free()
	_concepts.clear()

	_explorer = Control.new()
	_explorer.name = "StatueExplorer"
	_explorer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_explorer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	%Columns.add_child(_explorer)
	%Columns.move_child(_explorer, 0)
	_image.reparent(_explorer)
	_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_placeholder = Label.new()
	_placeholder.text = "STATUE PHOTO PENDING"
	_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_placeholder.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_explorer.add_child(_placeholder)
	_placeholder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_magnifier = Magnifier.new()
	_magnifier.name = "InspectionLayer"
	_explorer.add_child(_magnifier)
	_magnifier.configure(_image)

	_prompt = Label.new()
	_prompt.text = content.prompt
	_prompt.add_theme_font_size_override("font_size", 18)
	_prompt.add_theme_color_override("font_color", GOLD)
	_information.add_child(_prompt)
	_information.move_child(_prompt, 0)
	var sections := VBoxContainer.new()
	sections.name = "SectionButtons"
	sections.add_theme_constant_override("separation", 6)
	_information.add_child(sections)
	_information.move_child(sections, 1)
	for i in 2:
		var button := Button.new()
		button.custom_minimum_size.y = 48
		button.toggle_mode = true
		button.pressed.connect(select_section.bind(i))
		sections.add_child(button)
		_section_buttons.append(button)
		_concepts.append(button)
	var text_column := _body.get_parent()
	_heading.reparent(text_column)
	text_column.move_child(_heading, 0)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_information.get_node("Meta").hide()
	resized.connect(_resize_layout)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()


func open_interaction() -> bool:
	var data := content as StatueContent
	if not is_node_ready() or data == null or data.concepts.size() != 2 or data.section_labels.size() != 2 or data.compact_section_labels.size() != 2:
		return false
	if data.default_section < 0 or data.default_section > 1 or data.concepts.has(null):
		return false
	if _open:
		return true
	# The shared opener requires three entries; initialize this two-section variant
	# locally while retaining its rendering, Sources, audio and close lifecycle.
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	current_section = data.default_section
	_selected = current_section
	_title.text = data.title
	_image.texture = data.illustration
	_image.accessibility_name = data.illustration_alt_text
	_audio.stream = data.narration_stream
	_audio.stop()
	_update_speaker()
	_sources.hide()
	_cancel_fade()
	_open = true
	show()
	_render()
	_placeholder.visible = content.illustration == null
	_magnifier.reset(data.default_lens_position)
	_resize_layout()
	_sync_focus()
	_section_buttons[current_section].grab_focus()
	opened.emit()
	return true


func select_concept(index: int) -> void:
	select_section(index)


func select_section(section: int) -> void:
	if not _open or _sources.visible or section < 0 or section > 1:
		return
	var old_section := current_section
	current_section = section
	_selected = section
	_render()
	if old_section != current_section:
		section_changed.emit(current_section)
		concept_changed.emit(current_section)


func _resize_layout() -> void:
	if _explorer == null:
		return
	var compact := size.x < 900
	_explorer.size_flags_stretch_ratio = 1.32 if compact else 1.78
	%Columns.add_theme_constant_override("separation", 12 if compact else 20)
	var padding := 10 if compact else 16
	for side in ["left", "top", "right", "bottom"]:
		$Main/Margin.add_theme_constant_override("margin_" + side, padding)
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_heading.add_theme_font_size_override("font_size", 22 if compact else 26)
	_body.add_theme_font_size_override("font_size", 20 if compact else 22)
	_information.add_theme_constant_override("separation", 10 if compact else 16)
	var data := content as StatueContent
	for i in _section_buttons.size():
		_section_buttons[i].text = data.compact_section_labels[i] if compact else data.section_labels[i]


func _update_speaker() -> void:
	super._update_speaker()
	_speaker.show()
	_speaker.disabled = _audio.stream == null
	if _status != null:
		_status.visible = _audio.stream == null


func open_sources() -> void:
	if _open:
		_magnifier.set_interaction_enabled(false)
	super.open_sources()


func close_sources() -> void:
	super.close_sources()
	if _open:
		_magnifier.set_interaction_enabled(true)


func _sync_focus() -> void:
	var previous := get_viewport().gui_get_focus_owner()
	var main: Array[Control] = []
	main.append_array(_section_buttons)
	main.append_array([_magnifier.lens, _scroll, _speaker, _sources_button, _close])
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


func close_interaction() -> void:
	if not _open:
		return
	_magnifier.stop()
	super.close_interaction()
	close_requested.emit()


func _visibility_changed() -> void:
	if _open and not is_visible_in_tree():
		close_interaction()
