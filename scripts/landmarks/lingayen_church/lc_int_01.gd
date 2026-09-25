extends ConferenceRoomInteraction
## Four portrait controls inside the shared AKAR shell. No completion state.

signal close_requested

enum PersonSelection { NONE, GUERRERO, MADRIAGA, SHEEHAN, FEENY }

const SECONDARY := Color("c2bfab")
const PRIMARY := Color("e2cc91")
const ANCHOR_SECONDARY := Color("d9c184")
const ANCHOR_NEUTRAL := Color("8e9789")
const ANCHORS := [&"1929", &"1933", &"WAR / POSTWAR", &"1963"]

var selected_person: PersonSelection = PersonSelection.NONE
var _subtitle := Label.new()
var _pending := Label.new()
var _prompt := Label.new()
var _wall := Control.new()
var _role := Label.new()
var _connection := Label.new()
var _connection_label := Label.new()
var _connection_group := VBoxContainer.new()
var _source_line := Label.new()
var _anchor_strip := HBoxContainer.new()
var _anchor_labels: Array[Label] = []
var _anchor_markers: Array[Panel] = []
var _footer := HBoxContainer.new()
var _cards: Array[LCINT01PersonCard] = []
var _panel_tween: Tween
var _closing: bool = false


func _ready() -> void:
	super._ready()
	_build_header()
	_build_wall()
	_build_details()
	_build_footer()
	_scroll.gui_input.connect(_reading_input.bind(_scroll))
	_source_scroll.gui_input.connect(_reading_input.bind(_source_scroll))
	resized.connect(_resize_layout)
	_wall.resized.connect(_layout_cards)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_open_standalone.call_deferred()


func _style_label(label: Label, font_size: int, secondary: bool = false) -> void:
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	if secondary:
		label.add_theme_color_override("font_color", SECONDARY)


func _build_header() -> void:
	var header := $Main/Margin/Layout/Header
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	header.move_child(titles, 0)
	_title.reparent(titles)
	_style_label(_title, 28)
	titles.add_child(_subtitle)
	_style_label(_subtitle, 18, true)
	var listen_group := VBoxContainer.new()
	header.add_child(listen_group)
	header.move_child(listen_group, 1)
	_speaker.reparent(listen_group)
	_speaker.custom_minimum_size = Vector2(136, 56)
	_pending.text = "Narration pending."
	_style_label(_pending, 16, true)
	_pending.autowrap_mode = TextServer.AUTOWRAP_OFF
	_pending.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	listen_group.add_child(_pending)
	_close.custom_minimum_size = Vector2(80, 56)
	_close.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	header.add_theme_constant_override("separation", 12)
	$Main/Margin/Layout/Controls.hide()
	_style_label(_prompt, 18, true)
	$Main/Margin/Layout.add_child(_prompt)
	$Main/Margin/Layout.move_child(_prompt, 1)


func _build_wall() -> void:
	# Remove the shared concept row; the four portrait cards ARE the selectors.
	var old_sections := $Main/Margin/Layout/Sections
	old_sections.get_parent().remove_child(old_sections)
	old_sections.queue_free()
	_concepts.clear()
	_image.hide()
	_wall.name = "PortraitWall"
	_wall.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wall.mouse_filter = Control.MOUSE_FILTER_IGNORE
	%Columns.add_child(_wall)
	%Columns.move_child(_wall, 0)
	for i in 4:
		var card := LCINT01PersonCard.new()
		card.name = ["Guerrero", "Madriaga", "Sheehan", "Feeny"][i]
		_wall.add_child(card)
		_cards.append(card)
		_concepts.append(card)
		card.pressed.connect(set_selected_person.bind(i + 1))
		card.gui_input.connect(_card_input.bind(i))


func _build_details() -> void:
	var text := _body.get_parent()
	_heading.reparent(text)
	text.move_child(_heading, 0)
	text.add_child(_role)
	text.move_child(_role, 0)
	$Main/Margin/Layout/Columns/Information/Meta.hide()
	_style_label(_role, 16, true)
	_style_label(_heading, 24)
	_style_label(_body, 19)
	text.add_child(_connection_group)
	_connection_group.add_theme_constant_override("separation", 4)
	_connection_group.add_child(_connection_label)
	_connection_group.add_child(_connection)
	text.add_child(_source_line)
	_style_label(_connection_label, 15, true)
	_style_label(_connection, 18)
	_style_label(_source_line, 15, true)
	_scroll.accessibility_name = "Selected person's parish history. Scroll to read details."
	_source_close.custom_minimum_size.y = 56


func _build_footer() -> void:
	_anchor_strip.name = "HistoricalConnections"
	_anchor_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Main/Margin/Layout.add_child(_anchor_strip)
	for i in ANCHORS.size():
		if i > 0:
			var connector := HSeparator.new()
			connector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			connector.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			connector.mouse_filter = Control.MOUSE_FILTER_IGNORE
			connector.modulate = Color("77715a")
			_anchor_strip.add_child(connector)
		var anchor := HBoxContainer.new()
		anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
		anchor.add_theme_constant_override("separation", 6)
		_anchor_strip.add_child(anchor)
		var marker_frame := Control.new()
		marker_frame.custom_minimum_size = Vector2(12, 12)
		marker_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		marker_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		anchor.add_child(marker_frame)
		var marker := Panel.new()
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marker_frame.add_child(marker)
		_anchor_markers.append(marker)
		var label := Label.new()
		label.text = ANCHORS[i]
		_style_label(label, 16, true)
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		anchor.add_child(label)
		_anchor_labels.append(label)
	$Main/Margin/Layout.add_child(_footer)
	_footer.add_theme_constant_override("separation", 20)
	_takeaway.reparent(_footer)
	_takeaway.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_label(_takeaway, 17, true)
	_sources_button.reparent(_footer)
	_sources_button.custom_minimum_size = Vector2(110, 56)
	_sources_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER


func _open_standalone() -> void:
	if get_tree().current_scene == self:
		open_hotspot()


func open_hotspot() -> bool:
	return open_interaction()


func open_interaction() -> bool:
	if not is_node_ready() or not content is LCINT01Content:
		return false
	var parish := content as LCINT01Content
	if parish.people.size() != 4 or parish.people.has(null):
		return false
	if _open and not _closing:
		return true
	if not _open:
		var previous := get_viewport().gui_get_focus_owner()
		_return_focus = weakref(previous) if previous != null else null
	_open = true
	show()
	reset_hotspot()
	modulate.a = 0.65
	_panel_tween = create_tween()
	_panel_tween.tween_property(self, "modulate:a", 1.0, 0.16)
	opened.emit()
	return true


func reset_hotspot() -> void:
	if not is_node_ready() or not content is LCINT01Content:
		return
	_cancel_panel_tween()
	_closing = false
	_sources.hide()
	set_selected_person(PersonSelection.NONE)
	_cancel_fade()
	_resize_layout()
	if _open:
		_sync_focus()
		_cards[0].grab_focus()


func set_selected_person(person: PersonSelection) -> void:
	if not is_node_ready() or not content is LCINT01Content or _closing or _sources.visible:
		return
	var parish := content as LCINT01Content
	if parish.people.size() != 4 or parish.people.has(null):
		return
	selected_person = person if person >= PersonSelection.NONE and person <= PersonSelection.FEENY else PersonSelection.NONE
	_cancel_fade()
	stop_narration()
	_title.text = parish.title.to_upper()
	_subtitle.text = parish.subtitle
	_prompt.text = parish.prompt
	_takeaway.text = parish.takeaway
	var entry: LCINT01PersonContent = null
	if selected_person == PersonSelection.NONE:
		_heading.text = parish.overview_heading
		_body.text = parish.overview_body
	else:
		entry = parish.people[selected_person - 1]
		_heading.text = entry.detail_heading
		_body.text = entry.body
	_role.text = entry.short_role if entry != null else ""
	_connection.text = entry.parish_connection if entry != null else ""
	_connection_label.text = entry.connection_label if entry != null else ""
	_source_line.text = entry.compact_source_line if entry != null else ""
	_connection_group.visible = entry != null
	for label in [_role, _connection, _connection_label, _source_line]:
		label.visible = not label.text.is_empty()
	for i in _cards.size():
		_cards[i].set_pressed_no_signal(selected_person == i + 1)
		_cards[i].accessibility_description = "Selected" if selected_person == i + 1 else "Select to read parish connection"
	for i in ANCHORS.size():
		var primary: bool = entry != null and entry.primary_anchor == ANCHORS[i]
		var secondary: bool = entry != null and entry.secondary_anchor == ANCHORS[i]
		var color: Color = PRIMARY if primary else (ANCHOR_SECONDARY if secondary else ANCHOR_NEUTRAL)
		_anchor_labels[i].add_theme_color_override("font_color", color)
		# Geometry makes the hierarchy visible without relying on color alone.
		var marker_style := StyleBoxFlat.new()
		marker_style.bg_color = color
		marker_style.border_color = color
		marker_style.set_corner_radius_all(6)
		marker_style.draw_center = not secondary
		marker_style.set_border_width_all(2 if secondary else 0)
		_anchor_markers[i].add_theme_stylebox_override("panel", marker_style)
		_anchor_markers[i].position = Vector2.ZERO if primary or secondary else Vector2(3, 3)
		_anchor_markers[i].size = Vector2.ONE * (12 if primary or secondary else 6)
		_anchor_labels[i].accessibility_name = String(ANCHORS[i]) + (", primary connection" if primary else (", secondary connection" if secondary else ""))
	_audio.stream = entry.narration if entry != null else null
	_update_speaker()
	_scroll.scroll_vertical = 0
	if _open:
		_sync_focus()
		_information.modulate.a = 0.65
		_fade = create_tween()
		_fade.tween_property(_information, "modulate:a", 1.0, 0.16)


func open_sources() -> void:
	if not _open or _closing or _sources.visible:
		return
	_source_title.text = "Sources"
	_source_text.text = (content as LCINT01Content).sources_text
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()


func _update_speaker() -> void:
	super._update_speaker()
	_speaker.show()
	_speaker.disabled = _audio.stream == null
	_speaker.text = "STOP" if _audio.playing else "LISTEN"
	_pending.visible = _audio.stream == null


func stop_narration() -> void:
	_audio.stream_paused = false
	super.stop_narration()


func _card_input(event: InputEvent, index: int) -> void:
	if _sources.visible or _closing:
		return
	var target := index
	if event.is_action_pressed(&"ui_left"):
		target = index - 1 if index % 2 == 1 else index
	elif event.is_action_pressed(&"ui_right"):
		target = index + 1 if index % 2 == 0 else index
	elif event.is_action_pressed(&"ui_up"):
		target = index - 2 if index >= 2 else index
	elif event.is_action_pressed(&"ui_down"):
		target = index + 2 if index < 2 else index
	else:
		return
	get_viewport().set_input_as_handled()
	_cards[target].grab_focus()


func _reading_input(event: InputEvent, scroll: ScrollContainer) -> void:
	var movement := 0
	if event.is_action_pressed(&"ui_down"):
		movement = 40
	elif event.is_action_pressed(&"ui_up"):
		movement = -40
	elif event.is_action_pressed(&"ui_page_down"):
		movement = int(scroll.size.y * 0.85)
	elif event.is_action_pressed(&"ui_page_up"):
		movement = -int(scroll.size.y * 0.85)
	elif event.is_action_pressed(&"ui_home"):
		movement = -100000
	elif event.is_action_pressed(&"ui_end"):
		movement = 100000
	else:
		return
	get_viewport().set_input_as_handled()
	scroll.scroll_vertical += movement


func _resize_layout() -> void:
	if not is_node_ready():
		return
	var compact := size.x < 1000 or size.y < 550
	var smallest := size.x < 800
	var margin := 8 if compact else 16
	for side in ["left", "top", "right", "bottom"]:
		$Main/Margin.add_theme_constant_override("margin_" + side, margin)
	$Main/Margin/Layout.add_theme_constant_override("separation", 4 if compact else 12)
	%Columns.add_theme_constant_override("separation", 12 if compact else 24)
	_wall.size_flags_stretch_ratio = 0.44 if smallest else 0.52
	_information.size_flags_stretch_ratio = 0.56 if smallest else 0.48
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_heading.add_theme_font_size_override("font_size", 18 if compact else 24)
	_body.add_theme_font_size_override("font_size", 16 if compact else 19)
	_connection.add_theme_font_size_override("font_size", 16 if compact else 18)
	_role.add_theme_font_size_override("font_size", 14 if compact else 16)
	_connection_label.add_theme_font_size_override("font_size", 14 if compact else 15)
	_source_line.add_theme_font_size_override("font_size", 14 if compact else 15)
	for label in [_heading, _body, _connection, _role, _connection_label, _source_line]:
		label.add_theme_constant_override("line_spacing", 0 if compact else 3)
	_prompt.add_theme_font_size_override("font_size", 16 if compact else 18)
	_takeaway.add_theme_font_size_override("font_size", 15 if compact else 17)
	_body.get_parent().add_theme_constant_override("separation", 6 if compact else 14)
	_source_text.add_theme_font_size_override("font_size", 18 if compact else 22)
	_layout_cards()


func _layout_cards() -> void:
	if not is_node_ready() or not content is LCINT01Content:
		return
	var parish := content as LCINT01Content
	if parish.people.size() != 4 or parish.people.has(null):
		return
	var compact := size.x < 1000 or size.y < 550
	var gap := 8.0 if compact else 14.0
	var card_size := (_wall.size - Vector2.ONE * gap) * 0.5
	for i in _cards.size():
		_cards[i].size = card_size
		_cards[i].position = Vector2(i % 2, i / 2) * (card_size + Vector2.ONE * gap)
		_cards[i].configure(parish.people[i], compact)


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
	_cancel_panel_tween()
	_closing = false
	super.close_interaction()
	# All cleanup precedes notification; the host may free this node immediately.
	close_requested.emit()


func _cancel_panel_tween() -> void:
	if _panel_tween != null and _panel_tween.is_valid():
		_panel_tween.kill()
	_panel_tween = null
	modulate.a = 1.0


func _visibility_changed() -> void:
	if _open and not is_visible_in_tree():
		_finish_close()


func _exit_tree() -> void:
	_cancel_panel_tween()
	super._exit_tree()
