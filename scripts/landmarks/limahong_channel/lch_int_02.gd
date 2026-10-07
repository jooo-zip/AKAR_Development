extends ConferenceRoomInteraction
const Lifecycle = preload("res://scripts/landmarks/limahong_channel/lch_lifecycle.gd")
const SourcesOverlay = preload("res://scripts/landmarks/limahong_channel/lch_sources_overlay.gd")
const HeaderUtilities = preload("res://scripts/landmarks/limahong_channel/lch_header_utilities.gd")
var _header_utilities: HeaderUtilities
## Event-role explorer within the existing interior shell; no navigation ownership.
signal close_requested
signal person_changed(person_index: int)

enum CampaignPerson { LAVEZARIS, SALCEDO, LIMAHONG }
const CampaignContent = preload("res://scripts/landmarks/limahong_channel/lch_int_02_content.gd")
const PersonContent = preload("res://scripts/landmarks/limahong_channel/lch_int_02_person.gd")
const GOLD := Color("e8d5b4")
const NEUTRAL := Color("8e6c51")
const INACTIVE_LINE := Color(Color("8e6c51"), 0.5)
const SELECTED_LINE_WIDTH := 3.5
const INACTIVE_LINE_WIDTH := 2.0

var current_person: CampaignPerson = CampaignPerson.SALCEDO
var _data: CampaignContent
@onready var _diagram: Control = $"Main/Margin/Layout/Columns/RoleDiagram"
@onready var _lines: Array[Line2D] = [$"Main/Margin/Layout/Columns/RoleDiagram/Connection0", $"Main/Margin/Layout/Columns/RoleDiagram/Connection1", $"Main/Margin/Layout/Columns/RoleDiagram/Connection2"]
@onready var _portraits: Array[TextureRect] = [$"Main/Margin/Layout/Columns/RoleDiagram/PublicInterior/Portrait", $"Main/Margin/Layout/Columns/RoleDiagram/OfficialFunction/Portrait", $"Main/Margin/Layout/Columns/RoleDiagram/WhyItMatters/Portrait"]
@onready var _placeholders: Array[Label] = [$"Main/Margin/Layout/Columns/RoleDiagram/PublicInterior/Portrait/Placeholders0", $"Main/Margin/Layout/Columns/RoleDiagram/OfficialFunction/Portrait/Placeholders1", $"Main/Margin/Layout/Columns/RoleDiagram/WhyItMatters/Portrait/Placeholders2"]
@onready var _media_labels: Array[Label] = [$"Main/Margin/Layout/Columns/RoleDiagram/PublicInterior/Portrait/MediaLabels0", $"Main/Margin/Layout/Columns/RoleDiagram/OfficialFunction/Portrait/MediaLabels1", $"Main/Margin/Layout/Columns/RoleDiagram/WhyItMatters/Portrait/MediaLabels2"]
@onready var _names: Array[Label] = [$"Main/Margin/Layout/Columns/RoleDiagram/PublicInterior/Names0", $"Main/Margin/Layout/Columns/RoleDiagram/OfficialFunction/Names1", $"Main/Margin/Layout/Columns/RoleDiagram/WhyItMatters/Names2"]
@onready var _roles: Array[Label] = [$"Main/Margin/Layout/Columns/RoleDiagram/PublicInterior/Roles0", $"Main/Margin/Layout/Columns/RoleDiagram/OfficialFunction/Roles1", $"Main/Margin/Layout/Columns/RoleDiagram/WhyItMatters/Roles2"]
@onready var _selected_badges: Array[Label] = [$"Main/Margin/Layout/Columns/RoleDiagram/PublicInterior/Portrait/SelectedBadges0", $"Main/Margin/Layout/Columns/RoleDiagram/OfficialFunction/Portrait/SelectedBadges1", $"Main/Margin/Layout/Columns/RoleDiagram/WhyItMatters/Portrait/SelectedBadges2"]
var _selected_styles: Array[StyleBoxFlat] = []
@onready var _event: Panel = $"Main/Margin/Layout/Columns/RoleDiagram/CampaignEvent"
@onready var _event_title: Label = $"Main/Margin/Layout/Columns/RoleDiagram/CampaignEvent/MarginContainer0/VBoxContainer0/EventTitle"
@onready var _event_subtitle: Label = $"Main/Margin/Layout/Columns/RoleDiagram/CampaignEvent/MarginContainer0/VBoxContainer0/EventSubtitle"
@onready var _role: Label = $"Main/Margin/Layout/Columns/Information/Role"
@onready var _connection_heading: Label = $"Main/Margin/Layout/Columns/Information/Scroll/Text/ConnectionHeading"
@onready var _connection_body: Label = $"Main/Margin/Layout/Columns/Information/Scroll/Text/ConnectionBody"
@onready var _hint: Label = $"Main/Margin/Layout/Header/TitleArea/HBoxContainer1/Hint"
@onready var _pending: Label = $"Main/Margin/Layout/Header/HeaderUtilityArea/NarrationStatusSlot/Pending"
var _selection_tween: Tween
var _hint_tween: Tween
var _hint_dismissed: bool = false
var _layout_mode: int = 0 # 0 wide triangle, 1 smaller triangle, 2 compact row.
var _card_size := Vector2(180, 240)
var _portrait_width: float = 120


func _ready() -> void:
	super._ready()
	_data = content as CampaignContent
	_bind_authored_content()
	_diagram.accessibility_name = content.prompt
	for i in 3:
		var button := _concepts[i]
		button.text = ""
		button.gui_input.connect(_card_input.bind(i))
		button.accessibility_name = _person(i).heading + ". " + _person(i).role_label
		button.tooltip_text = button.accessibility_name
		# Selection animation styles belong to this instance, never the PackedScene.
		var selected: StyleBoxFlat = button.get_theme_stylebox("pressed").duplicate()
		_selected_styles.append(selected)
		button.add_theme_stylebox_override("pressed", selected)
		button.add_theme_stylebox_override("hover_pressed", selected)
	_diagram.resized.connect(_layout_diagram)
	resized.connect(_resize_layout)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_header_utilities = HeaderUtilities.new(self, _pending)
	add_child(SourcesOverlay.new(self))











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
	if content.narration_stream == null:
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
	# Overall hotspot narration takes precedence; retain optional per-person fallback.
	var narration: AudioStream = content.narration_stream if content.narration_stream != null else person.narration_audio
	if _audio.stream != narration:
		_audio.stream = narration
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
	if _header_utilities != null: _header_utilities.refresh()

func open_sources() -> void:
	if not _open or _sources.visible:
		return
	_cancel_selection()
	super.open_sources()
	# Show provenance for every portrait, regardless of the currently selected person.
	for entry in content.concepts:
		_source_text.text += "\n\n" + entry.heading
		for field in [["Image type", entry.portrait_media_type], ["Credit", entry.portrait_credit],
			["Image source", entry.portrait_source], ["Permission/license status", entry.portrait_permission_status]]:
			if not field[1].is_empty():
				_source_text.text += "\n" + field[0] + ": " + field[1]


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

func _sync_focus() -> void:
	var controls: Array[Control] = []
	controls.append_array(_concepts)
	controls.append(_scroll)
	HeaderUtilities.sync_focus(self, controls)

func _bind_authored_content() -> void:
	# Resources remain the only authority for interpretation copy.
	get_node("Main/Margin/Layout/Columns/Information/Heading").text = content.concepts[1].heading
	get_node("Main/Margin/Layout/Columns/Information/Label0").text = content.panel_prompt
	get_node("Main/Margin/Layout/Columns/Information/Role").text = content.concepts[1].role_label
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/Body").text = content.concepts[1].body
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/ConnectionBody").text = content.concepts[1].connection_body
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/ConnectionHeading").text = content.connection_heading
	get_node("Main/Margin/Layout/Columns/RoleDiagram/CampaignEvent/MarginContainer0/VBoxContainer0/EventSubtitle").text = content.event_subtitle
	get_node("Main/Margin/Layout/Columns/RoleDiagram/CampaignEvent/MarginContainer0/VBoxContainer0/EventTitle").text = content.event_title
	get_node("Main/Margin/Layout/Columns/RoleDiagram/OfficialFunction/Names1").text = content.concepts[1].heading
	get_node("Main/Margin/Layout/Columns/RoleDiagram/OfficialFunction/Roles1").text = content.concepts[1].role_label
	get_node("Main/Margin/Layout/Columns/RoleDiagram/PublicInterior/Names0").text = content.concepts[0].heading
	get_node("Main/Margin/Layout/Columns/RoleDiagram/PublicInterior/Roles0").text = content.concepts[0].role_label
	get_node("Main/Margin/Layout/Columns/RoleDiagram/WhyItMatters/Names2").text = content.concepts[2].heading
	get_node("Main/Margin/Layout/Columns/RoleDiagram/WhyItMatters/Roles2").text = content.concepts[2].role_label
	get_node("Main/Margin/Layout/Header/TitleArea/HBoxContainer1/Hint").text = content.comparison_hint
	get_node("Main/Margin/Layout/Header/TitleArea/HBoxContainer1/Label0").text = content.hotspot_id
	get_node("Main/Margin/Layout/Header/TitleArea/Title").text = content.title


func reset_interaction() -> void:
	Lifecycle.reset(self)
