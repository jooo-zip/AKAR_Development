extends ConferenceRoomInteraction
## Event-role explorer within the existing interior shell; no navigation ownership.
signal close_requested
signal person_changed(person_index: int)

enum CampaignPerson { LAVEZARIS, SALCEDO, LIMAHONG }
const CampaignContent = preload("res://scripts/landmarks/limahong_channel/lch_int_02_content.gd")
const PersonContent = preload("res://scripts/landmarks/limahong_channel/lch_int_02_person.gd")
const GOLD := Color(0.88, 0.80, 0.55)
const NEUTRAL := Color(0.60, 0.64, 0.55)
const INACTIVE_LINE := Color(0.73, 0.68, 0.53, 0.5)
const SELECTED_LINE_WIDTH := 3.5
const INACTIVE_LINE_WIDTH := 2.0

var current_person: CampaignPerson = CampaignPerson.SALCEDO
var _data: CampaignContent
var _diagram := Control.new()
var _lines: Array[Line2D] = []
var _portraits: Array[TextureRect] = []
var _placeholders: Array[Label] = []
var _media_labels: Array[Label] = []
var _names: Array[Label] = []
var _roles: Array[Label] = []
var _selected_badges: Array[Label] = []
var _selected_styles: Array[StyleBoxFlat] = []
var _event := Panel.new()
var _event_title := Label.new()
var _event_subtitle := Label.new()
var _role := Label.new()
var _connection_heading := Label.new()
var _connection_body := Label.new()
var _hint := Label.new()
var _pending := Label.new()
var _selection_tween: Tween
var _hint_tween: Tween
var _hint_dismissed: bool = false
var _layout_mode: int = 0 # 0 wide triangle, 1 smaller triangle, 2 compact row.
var _card_size := Vector2(180, 240)
var _portrait_width: float = 120


func _ready() -> void:
	super._ready()
	_data = content as CampaignContent
	_build_header()
	_image.hide()
	_image.reparent($Main/Margin/Layout/Controls)
	$Main/Margin/Layout/Controls.hide()
	_diagram.name = "RoleDiagram"
	_diagram.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_diagram.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_diagram.accessibility_name = content.prompt
	%Columns.add_child(_diagram)
	%Columns.move_child(_diagram, 0)
	for i in 3:
		var line := Line2D.new()
		line.name = "Connection%d" % i
		line.antialiased = true
		_diagram.add_child(line)
		_lines.append(line)
	_event.name = "CampaignEvent"
	_event.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var event_style := _card_style(GOLD, 1)
	event_style.bg_color = Color(0.12, 0.17, 0.145)
	_event.add_theme_stylebox_override("panel", event_style)
	_diagram.add_child(_event)
	var event_margin := MarginContainer.new()
	event_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_event.add_child(event_margin)
	event_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		event_margin.add_theme_constant_override("margin_" + side, 8)
	var event_text := VBoxContainer.new()
	event_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	event_text.alignment = BoxContainer.ALIGNMENT_CENTER
	event_text.add_theme_constant_override("separation", 4)
	event_margin.add_child(event_text)
	event_text.add_child(_event_title)
	event_text.add_child(_event_subtitle)
	for label in [_event_title, _event_subtitle]:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_constant_override("line_spacing", 0)
	_event_title.text = _data.event_title
	_event_title.add_theme_color_override("font_color", GOLD)
	_event_subtitle.text = _data.event_subtitle
	for i in 3:
		_build_card(i)
	$Main/Margin/Layout/Sections.hide()
	_build_information()
	_diagram.resized.connect(_layout_diagram)
	resized.connect(_resize_layout)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()


func _build_header() -> void:
	var header := $Main/Margin/Layout/Header
	_speaker.reparent(header)
	_sources_button.reparent(header)
	header.move_child(_close, -1)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_speaker.text = "LISTEN"
	_speaker.custom_minimum_size = Vector2(112, 48)
	_speaker.expand_icon = true
	_speaker.add_theme_constant_override("icon_max_width", 24)
	var subtitle := HBoxContainer.new()
	subtitle.add_theme_constant_override("separation", 12)
	$Main/Margin/Layout.add_child(subtitle)
	$Main/Margin/Layout.move_child(subtitle, 1)
	var code := Label.new()
	code.text = content.hotspot_id
	code.add_theme_font_size_override("font_size", 13)
	code.add_theme_color_override("font_color", GOLD)
	subtitle.add_child(code)
	_hint.text = _data.comparison_hint
	_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 12)
	subtitle.add_child(_hint)
	_pending.text = "Narration pending"
	_pending.add_theme_font_size_override("font_size", 13)
	subtitle.add_child(_pending)


func _build_card(index: int) -> void:
	var person := _person(index)
	var button := _concepts[index]
	button.reparent(_diagram)
	button.text = ""
	button.custom_minimum_size = Vector2.ZERO
	button.gui_input.connect(_card_input.bind(index))
	button.add_theme_stylebox_override("normal", _card_style(NEUTRAL, 1))
	button.add_theme_stylebox_override("hover", _card_style(Color(0.90, 0.88, 0.76), 2))
	var selected := _card_style(GOLD, 3)
	_selected_styles.append(selected)
	button.add_theme_stylebox_override("pressed", selected)
	button.add_theme_stylebox_override("hover_pressed", selected)
	button.accessibility_name = person.heading + ". " + person.role_label
	button.tooltip_text = button.accessibility_name
	var portrait := TextureRect.new()
	portrait.name = "Portrait"
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.clip_contents = true
	button.add_child(portrait)
	_portraits.append(portrait)
	var placeholder := _card_label(portrait)
	placeholder.text = "IMAGE SOURCE\nPENDING"
	placeholder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_placeholders.append(placeholder)
	var media := _card_label(portrait)
	media.add_theme_font_size_override("font_size", 10)
	_media_labels.append(media)
	var badge := _card_label(portrait)
	badge.text = "SELECTED"
	badge.add_theme_font_size_override("font_size", 11)
	badge.add_theme_color_override("font_color", Color(0.05, 0.08, 0.065))
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = GOLD
	badge.add_theme_stylebox_override("normal", badge_style)
	_selected_badges.append(badge)
	_names.append(_card_label(button))
	_names[index].text = person.heading
	_roles.append(_card_label(button))
	_roles[index].text = person.role_label
	_roles[index].add_theme_color_override("font_color", GOLD)


func _card_label(parent: Control) -> Label:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_constant_override("line_spacing", 0)
	parent.add_child(label)
	return label


func _card_style(color: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.125, 0.11)
	style.border_color = color
	style.set_border_width_all(width)
	style.set_content_margin_all(0)
	return style


func _build_information() -> void:
	var prompt := Label.new()
	prompt.text = _data.panel_prompt
	prompt.tooltip_text = content.prompt
	prompt.add_theme_font_size_override("font_size", 18)
	prompt.add_theme_color_override("font_color", GOLD)
	_information.add_child(prompt)
	_information.move_child(prompt, 0)
	_heading.reparent(_information)
	_information.move_child(_heading, 1)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_information.get_node("Meta").hide()
	_role.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_role.add_theme_color_override("font_color", GOLD)
	_information.add_child(_role)
	_information.move_child(_role, 2)
	var text_column := _body.get_parent()
	text_column.add_child(_connection_heading)
	text_column.add_child(_connection_body)
	_connection_heading.text = _data.connection_heading
	_connection_heading.add_theme_color_override("font_color", GOLD)
	for label in [_connection_heading, _connection_body]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _person(index: int) -> PersonContent:
	return content.concepts[index] as PersonContent


func open_interaction() -> bool:
	if not is_node_ready() or _data == null or content.concepts.size() != 3:
		return false
	for entry in content.concepts:
		if not entry is PersonContent:
			return false
	if _data.default_person < 0 or _data.default_person > 2:
		return false
	if _open:
		return true
	current_person = _data.default_person as CampaignPerson
	_cancel_selection()
	_cancel_hint()
	_hint_dismissed = false
	_hint.modulate.a = 1.0
	if not super.open_interaction():
		return false
	_concepts[current_person].grab_focus()
	return true


func select_concept(index: int) -> void:
	select_person(index)


func select_person(person: int, animate: bool = true) -> void:
	if not _open or _sources.visible or person < 0 or person > 2:
		return
	_cancel_selection()
	if person == current_person:
		return
	stop_narration()
	current_person = person as CampaignPerson
	_render()
	_sync_focus()
	if not _hint_dismissed:
		_hint_dismissed = true
		_hint_tween = create_tween()
		_hint_tween.tween_property(_hint, "modulate:a", 0.0, 0.2)
	if animate:
		var card := _concepts[person]
		card.scale = Vector2.ONE * 0.97
		card.modulate.a = 0.85
		_selected_styles[person].border_color = NEUTRAL
		_lines[person].width = INACTIVE_LINE_WIDTH
		_lines[person].default_color = Color(GOLD, 0.5)
		_selection_tween = create_tween().set_parallel(true)
		_selection_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_selection_tween.tween_property(card, "scale", Vector2.ONE, 0.2)
		_selection_tween.tween_property(card, "modulate:a", 1.0, 0.2)
		_selection_tween.tween_property(_selected_styles[person], "border_color", GOLD, 0.2)
		_selection_tween.tween_property(_lines[person], "width", SELECTED_LINE_WIDTH, 0.3)
		_selection_tween.tween_property(_lines[person], "default_color", GOLD, 0.3)
		_selection_tween.finished.connect(_finish_selection)
	person_changed.emit(person)
	concept_changed.emit(person)


func _render() -> void:
	_selected = current_person
	super._render()
	var person := _person(current_person)
	_role.text = person.role_label
	_connection_body.text = person.connection_body
	if _audio.stream != person.narration_audio:
		_audio.stream = person.narration_audio
	_update_speaker()
	for i in 3:
		_concepts[i].text = ""
		_portraits[i].texture = _person(i).portrait
		_placeholders[i].visible = _person(i).portrait == null
		_media_labels[i].text = _person(i).portrait_media_type
		_media_labels[i].visible = not _person(i).portrait_media_type.is_empty()
	_normalize_selection()
	_layout_diagram()


func _normalize_selection() -> void:
	for i in _lines.size():
		_concepts[i].set_pressed_no_signal(i == current_person)
		_concepts[i].scale = Vector2.ONE
		_concepts[i].modulate.a = 1.0
		_selected_styles[i].border_color = GOLD
		_selected_badges[i].visible = i == current_person
		_lines[i].width = SELECTED_LINE_WIDTH if i == current_person else INACTIVE_LINE_WIDTH
		_lines[i].default_color = GOLD if i == current_person else INACTIVE_LINE


func _cancel_selection() -> void:
	if _selection_tween != null and _selection_tween.is_valid():
		_selection_tween.kill()
	_selection_tween = null
	_normalize_selection()


func _finish_selection() -> void:
	_selection_tween = null
	_normalize_selection()


func _cancel_hint() -> void:
	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()
	_hint_tween = null


func _card_input(event: InputEvent, index: int) -> void:
	if not _open or _sources.visible or not event is InputEventKey or not event.pressed:
		return
	if event.keycode != KEY_LEFT and event.keycode != KEY_RIGHT:
		return
	_concepts[index].accept_event()
	var target := clampi(index + (-1 if event.keycode == KEY_LEFT else 1), 0, 2)
	select_person(target)
	_concepts[target].grab_focus()


func _resize_layout() -> void:
	if _data == null or _roles.size() != 3:
		return
	_layout_mode = 0 if size.x >= 1050 else (1 if size.x >= 820 else 2)
	var small := _layout_mode != 0
	_diagram.size_flags_stretch_ratio = 1.55 if _layout_mode == 2 else 1.78
	_card_size = [Vector2(180, 240), Vector2(148, 204), Vector2(136, 194)][_layout_mode]
	_portrait_width = [120.0, 96.0, 88.0][_layout_mode]
	%Columns.add_theme_constant_override("separation", 12 if small else 20)
	for side in ["left", "top", "right", "bottom"]:
		$Main/Margin.add_theme_constant_override("margin_" + side, 10 if small else 16)
	_title.add_theme_font_size_override("font_size", 20 if small else 28)
	_heading.add_theme_font_size_override("font_size", 22 if small else 26)
	_role.add_theme_font_size_override("font_size", 16 if small else 18)
	_connection_heading.add_theme_font_size_override("font_size", 16 if small else 18)
	for label in [_body, _connection_body]:
		label.add_theme_font_size_override("font_size", 18 if small else 22)
	_information.add_theme_constant_override("separation", 8 if small else 12)
	_event.size = [Vector2(242, 112), Vector2(210, 122), Vector2(242, 110)][_layout_mode]
	_event_title.add_theme_font_size_override("font_size", 16 if small else 18)
	_event_subtitle.add_theme_font_size_override("font_size", 12 if small else 13)
	_layout_diagram()


func _layout_diagram() -> void:
	if _lines.size() != 3 or _roles.size() != 3:
		return
	_cancel_selection()
	var event_anchor: Vector2 = [_data.wide_event_anchor, _data.medium_event_anchor, _data.compact_event_anchor][_layout_mode]
	_event.position = _bounded_position(event_anchor, _event.size)
	for i in 3:
		var person := _person(i)
		var anchor: Vector2 = [person.wide_anchor, person.medium_anchor, person.compact_anchor][_layout_mode]
		var card := _concepts[i]
		card.size = _card_size
		card.position = _bounded_position(anchor, card.size)
		card.pivot_offset = card.size * 0.5
		var portrait := _portraits[i]
		portrait.position = Vector2((card.size.x - _portrait_width) * 0.5, 8)
		portrait.size = Vector2(_portrait_width, _portrait_width * 1.25)
		_names[i].add_theme_font_size_override("font_size", 16 if _layout_mode == 0 else 13)
		_names[i].position = Vector2(6, portrait.position.y + portrait.size.y + 2)
		_names[i].size = Vector2(card.size.x - 12, 40 if _layout_mode == 0 else 36)
		_roles[i].add_theme_font_size_override("font_size", 13 if _layout_mode == 0 else 12)
		_roles[i].position = Vector2(6, _names[i].get_rect().end.y)
		_roles[i].size = Vector2(card.size.x - 12, 32)
		_placeholders[i].add_theme_font_size_override("font_size", 12)
		_media_labels[i].position = Vector2.ZERO
		_media_labels[i].size = Vector2(_portrait_width, 28)
		_selected_badges[i].position = Vector2(0, portrait.size.y - 18)
		_selected_badges[i].size = Vector2(_portrait_width, 18)
		var card_rect := Rect2(card.position, card.size)
		var event_rect := Rect2(_event.position, _event.size)
		var line_start := _edge_point(card_rect, event_rect.get_center())
		var line_end := _edge_point(event_rect, card_rect.get_center())
		if _layout_mode == 2:
			# Keep every compact connector below the row, clear of neighboring cards.
			line_start = Vector2(card_rect.get_center().x, card_rect.end.y)
			line_end = event_rect.position + Vector2(event_rect.size.x * [0.2, 0.5, 0.8][i], 0)
		elif _layout_mode == 0 and i > 0:
			line_end = event_rect.position + Vector2(event_rect.size.x * (0.15 if i == 1 else 0.85), event_rect.size.y)
			line_start = _edge_point(card_rect, line_end)
		_lines[i].points = PackedVector2Array([line_start, line_end])


func _bounded_position(anchor: Vector2, dimensions: Vector2) -> Vector2:
	return (anchor * _diagram.size - dimensions * 0.5).clamp(Vector2.ZERO, (_diagram.size - dimensions).max(Vector2.ZERO))


func _edge_point(rect: Rect2, toward: Vector2) -> Vector2:
	var direction := toward - rect.get_center()
	var extent := rect.size * 0.5
	var fraction := minf(extent.x / maxf(absf(direction.x), 0.001), extent.y / maxf(absf(direction.y), 0.001))
	return rect.get_center() + direction * fraction


func _update_speaker() -> void:
	super._update_speaker()
	_speaker.show()
	_speaker.disabled = _audio.stream == null
	_pending.visible = _audio.stream == null


func open_sources() -> void:
	if not _open or _sources.visible:
		return
	_cancel_selection()
	super.open_sources()
	var person := _person(current_person)
	_source_text.text += "\n\nSelected image — " + person.heading
	_source_text.text += "\nImage type: " + _metadata_or_pending(person.portrait_media_type)
	_source_text.text += "\nCredit: " + _metadata_or_pending(person.portrait_credit)
	_source_text.text += "\nSource: " + _metadata_or_pending(person.portrait_source)
	_source_text.text += "\nPermission/license status: " + _metadata_or_pending(person.portrait_permission_status)


func _metadata_or_pending(value: String) -> String:
	return value if not value.is_empty() else "Pending researcher confirmation."


func close_interaction() -> void:
	if not _open:
		return
	_cancel_selection()
	_cancel_hint()
	super.close_interaction()
	close_requested.emit()


func _visibility_changed() -> void:
	if _open and not is_visible_in_tree():
		close_interaction()


func _exit_tree() -> void:
	if _selection_tween != null and _selection_tween.is_valid():
		_selection_tween.kill()
	_cancel_hint()
	super._exit_tree()
