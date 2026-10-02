@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/lingayen_church/lc_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview


const HeaderUtilities = preload("res://scripts/landmarks/lingayen_church/lc_header_utilities.gd")
var _header_utilities: RefCounted
## One church, four meanings. State is authoritative; animation is presentation.

signal close_requested
signal theme_selected(theme_id: StringName)

enum ThemeSelection { NONE, HISTORICAL_ROOTS, CATHEDRAL_ROLE, WAR_RECOVERY, LIVING_HERITAGE }
const GOLD := Color("dec787")
const NEUTRAL := Color("697261")
const SECONDARY := Color("c2bfab")

@export var animate_transitions: bool = true
var selected_theme: ThemeSelection = ThemeSelection.NONE
var _transition: Tween
var _panel_tween: Tween
var _closing: bool = false
var _subtitle: Label
var _pending: Label
var _prompt: Label
var _map: Control
var _cards: Array[LCEND01ThemeCard] = []
var _connectors: Array[Line2D] = []
var _center: Button
var _center_title: Label
var _context: VBoxContainer
var _primary: Label
var _secondary: Label
var _fallback: Label
var _credit: Label
var _theme_label: Label
var _meaning_label: Label
var _meaning: Label
var _source_basis: Label
var _synthesis: Label
var _outgoing_detail: Control

func _ready() -> void:
	if Engine.is_editor_hint():
		_refresh_editor_preview.call_deferred()
		return
	_presentation_root = self
	super._ready()
	_build_presentation()
	_header_utilities = HeaderUtilities.new(self, _pending)
	add_to_group("lingayen_church_narration")
	resized.connect(_on_resized)
	_map.resized.connect(_layout_map)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_open_standalone.call_deferred()

func _style_label(label: Label, font_size: int, secondary: bool = false) -> void:
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("line_spacing", 0)
	if secondary:
		label.add_theme_color_override("font_color", SECONDARY)

func _build_header() -> void:
	var header := _presentation_root.get_node("Main/Margin/Layout/Header")
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
	_style_label(_pending, 16, true)
	_pending.autowrap_mode = TextServer.AUTOWRAP_OFF
	listen_group.add_child(_pending)
	_close.custom_minimum_size = Vector2(80, 56)
	_close.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	header.add_theme_constant_override("separation", 12)
	_presentation_root.get_node("Main/Margin/Layout/Controls").hide()
	_style_label(_prompt, 18, true)
	_presentation_root.get_node("Main/Margin/Layout").add_child(_prompt)
	_presentation_root.get_node("Main/Margin/Layout").move_child(_prompt, 1)

func _build_map() -> void:
	var old_sections := _presentation_root.get_node("Main/Margin/Layout/Sections")
	old_sections.get_parent().remove_child(old_sections)
	old_sections.queue_free()
	_concepts.clear()
	_map.name = "MeaningMap"
	_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map.size_flags_stretch_ratio = 0.6
	_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_information.size_flags_stretch_ratio = 0.4
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_child(_map)
	_presentation_root.get_node("Main/Margin/Layout/Columns").move_child(_map, 0)
	for i in 4:
		var line := Line2D.new()
		line.default_color = NEUTRAL
		line.width = 1.5
		_map.add_child(line)
		_connectors.append(line)
		var card := LCEND01ThemeCard.new()
		_map.add_child(card)
		_cards.append(card)
		_concepts.append(card)
		if not Engine.is_editor_hint():
			card.pressed.connect(set_selected_theme.bind(i + 1))
			card.gui_input.connect(_card_input.bind(i))
	_map.add_child(_center)
	_concepts.append(_center)
	_center.custom_minimum_size = Vector2(160, 56)
	if not Engine.is_editor_hint():
		_center.pressed.connect(set_selected_theme.bind(ThemeSelection.NONE))
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color("12231e")
	frame.border_color = Color("887c55")
	frame.set_border_width_all(1)
	for state in ["normal", "hover", "pressed", "hover_pressed"]:
		_center.add_theme_stylebox_override(state, frame)
	_center.add_child(_center_title)
	_style_label(_center_title, 17)
	_center_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_image.reparent(_center)
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_center.add_child(_fallback)
	_style_label(_fallback, 13, true)
	_fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_center.add_child(_context)
	_context.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_context.alignment = BoxContainer.ALIGNMENT_CENTER
	_context.add_theme_constant_override("separation", 8)
	_context.add_child(_primary)
	_context.add_child(_secondary)
	for label in [_primary, _secondary]:
		_style_label(label, 18)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", GOLD)
	_map.add_child(_credit)
	_style_label(_credit, 13, true)
	_credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _build_interpretation() -> void:
	var text := _body.get_parent()
	_heading.reparent(text)
	text.move_child(_heading, 0)
	text.add_child(_theme_label)
	text.move_child(_theme_label, 0)
	_presentation_root.get_node("Main/Margin/Layout/Columns/Information/Meta").hide()
	_style_label(_theme_label, 15, true)
	_style_label(_heading, 24)
	_style_label(_body, 19)
	text.add_child(_meaning_label)
	text.add_child(_meaning)
	text.add_child(_source_basis)
	text.add_child(_synthesis)
	_style_label(_meaning_label, 15, true)
	_style_label(_meaning, 19)
	_meaning.add_theme_color_override("font_color", GOLD)
	_style_label(_source_basis, 14, true)
	_style_label(_synthesis, 17, true)
	_scroll.accessibility_name = "Summary interpretation. Scroll to read details."
	_source_close.custom_minimum_size.y = 56

func _build_footer() -> void:
	_takeaway.reparent(_presentation_root.get_node("Main/Margin/Layout"))
	_takeaway.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_label(_takeaway, 17, true)

func _entry() -> LCEND01ThemeContent:
	return null if selected_theme == ThemeSelection.NONE else (content as LCEND01Content).themes[selected_theme - 1]

func _open_standalone() -> void:
	if Engine.is_editor_hint():
		return
	if get_tree().current_scene == self:
		open_hotspot()

func open_hotspot() -> bool:
	if Engine.is_editor_hint():
		return false
	return open_interaction()

func open_interaction() -> bool:
	if Engine.is_editor_hint():
		return false
	if not is_node_ready() or not content is LCEND01Content:
		return false
	var summary := content as LCEND01Content
	if summary.themes.size() != 4 or summary.themes.has(null):
		return false
	if _open and not _closing:
		return true
	if not _open:
		var previous := get_viewport().gui_get_focus_owner()
		_return_focus = weakref(previous) if previous != null else null
	_open = true
	show()
	reset_hotspot()
	opened.emit()
	return true

func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_panel_tween()
	_closing = false
	_sources.hide()
	stop_narration()
	set_selected_theme(ThemeSelection.NONE)
	cancel_active_tweens()
	if _open:
		_sync_focus()
		_cards[0].grab_focus()

func set_selected_theme(theme: ThemeSelection) -> void:
	if Engine.is_editor_hint():
		return
	if not is_node_ready() or not content is LCEND01Content or _closing or _sources.visible:
		return
	var summary := content as LCEND01Content
	if summary.themes.size() != 4 or summary.themes.has(null):
		return
	cancel_active_tweens()
	if _open and animate_transitions:
		_capture_outgoing_detail()
	selected_theme = theme if theme >= ThemeSelection.NONE and theme <= ThemeSelection.LIVING_HERITAGE else ThemeSelection.NONE
	_apply_presentation()
	update_narration_state()
	_scroll.scroll_vertical = 0
	_resize_layout()
	if _open:
		_sync_focus()
		if animate_transitions:
			_play_transition()
	if _entry() != null:
		theme_selected.emit(_entry().theme_id)

func render_overview() -> void:
	var summary := content as LCEND01Content
	_theme_label.text = ""
	_theme_label.hide()
	_heading.text = summary.overview_heading
	_body.text = summary.overview_body
	_meaning_label.text = ""
	_meaning.text = ""
	_source_basis.text = ""
	for label in [_meaning_label, _meaning, _source_basis]:
		label.hide()
	_synthesis.text = summary.synthesis
	_synthesis.show()

func render_theme() -> void:
	var entry := _entry()
	_theme_label.text = entry.title
	_heading.text = entry.heading
	_body.text = entry.interpretation
	_meaning_label.text = entry.meaning_label
	_meaning.text = entry.meaning_statement
	_source_basis.text = "Source: " + entry.source_basis
	for label in [_theme_label, _meaning_label, _meaning, _source_basis]:
		label.show()
	_synthesis.text = ""
	_synthesis.hide()

func update_theme_cards() -> void:
	var summary := content as LCEND01Content
	for i in 4:
		_cards[i].configure(summary.themes[i], _is_compact())
		_cards[i].apply_selection(selected_theme == i + 1)

func update_connectors() -> void:
	for i in 4:
		var active := selected_theme == i + 1
		_connectors[i].default_color = GOLD if active else NEUTRAL
		_connectors[i].width = 3.0 if active else 1.5

func update_center_context() -> void:
	var summary := content as LCEND01Content
	_primary.text = summary.center_overview_primary if _entry() == null else _entry().center_context_primary
	_secondary.text = summary.center_overview_secondary if _entry() == null else _entry().center_context_secondary
	if _is_compact():
		_primary.text = _primary.text.replace("\n", " ")
		_secondary.text = _secondary.text.replace("\n", " ")

func _capture_outgoing_detail() -> void:
	if _heading.text.is_empty():
		return
	var outgoing := _body.get_parent().duplicate(0) as VBoxContainer
	_outgoing_detail.add_child(outgoing)
	_outgoing_detail.position = _scroll.global_position - global_position
	_outgoing_detail.size = _scroll.size
	outgoing.position = Vector2(0, -_scroll.scroll_vertical)
	outgoing.size = _body.get_parent().size
	outgoing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_outgoing_detail.show()

func update_narration_state() -> void:
	if Engine.is_editor_hint():
		return
	HeaderUtilities.bind_narration(self, (content as LCEND01Content).narration)
	_pending.text = (content as LCEND01Content).narration_pending
	_update_speaker()

func _play_transition() -> void:
	if Engine.is_editor_hint():
		return
	_transition = create_tween().set_parallel(true)
	if selected_theme != ThemeSelection.NONE:
		var card := _cards[selected_theme - 1]
		card.label.modulate.a = 0.65
		_transition.tween_property(card.label, "modulate:a", 1.0, 0.14)
		var line := _connectors[selected_theme - 1]
		line.modulate.a = 0.45
		_transition.tween_property(line, "modulate:a", 1.0, 0.20).set_delay(0.04)
	_context.modulate.a = 0.0
	_transition.tween_property(_context, "modulate:a", 1.0, 0.16).set_delay(0.08)
	_information.modulate.a = 0.0
	_transition.tween_property(_information, "modulate:a", 1.0, 0.20).set_delay(0.12)
	if _outgoing_detail.visible:
		_transition.tween_property(_outgoing_detail, "modulate:a", 0.0, 0.20).set_delay(0.12)
	_transition.chain().tween_callback(_settle_transition)

func cancel_active_tweens() -> void:
	if Engine.is_editor_hint():
		return
	if _transition != null and _transition.is_valid():
		_transition.kill()
	_transition = null
	_settle_transition()

func _settle_transition() -> void:
	_outgoing_detail.hide()
	_outgoing_detail.modulate.a = 1.0
	for child in _outgoing_detail.get_children():
		_outgoing_detail.remove_child(child)
		child.queue_free()
	_context.modulate.a = 1.0
	if is_instance_valid(_information):
		_information.modulate.a = 1.0
	for card in _cards:
		card.label.modulate.a = 1.0
	for line in _connectors:
		line.modulate.a = 1.0

func _is_compact() -> bool:
	return _presentation_root.size.x < 1000 or _presentation_root.size.y < 550

func _on_resized() -> void:
	if Engine.is_editor_hint():
		return
	# A resize settles the outgoing copy before its old geometry becomes stale.
	cancel_active_tweens()
	_resize_layout()

func _resize_layout() -> void:
	if not is_instance_valid(_presentation_root):
		return
	EditorPresentation.resize(self, _presentation_root)
	if not is_node_ready():
		return
	var compact := _is_compact()
	for side in ["left", "top", "right", "bottom"]:
		_presentation_root.get_node("Main/Margin").add_theme_constant_override("margin_" + side, 8 if compact else 16)
	_presentation_root.get_node("Main/Margin/Layout").add_theme_constant_override("separation", 6 if compact else 12)
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_theme_constant_override("separation", 12 if compact else 24)
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_prompt.add_theme_font_size_override("font_size", 16 if compact else 18)
	_heading.add_theme_font_size_override("font_size", 20 if compact else 24)
	_body.add_theme_font_size_override("font_size", 17 if compact else 19)
	_meaning.add_theme_font_size_override("font_size", 17 if compact else 19)
	_synthesis.add_theme_font_size_override("font_size", 16 if compact else 17)
	_takeaway.add_theme_font_size_override("font_size", 15 if compact else 17)
	_body.get_parent().add_theme_constant_override("separation", 8 if compact else 12)
	_source_text.add_theme_font_size_override("font_size", 18 if compact else 22)
	_context.add_theme_constant_override("separation", 3 if compact else 8)
	for label in [_primary, _secondary]:
		label.add_theme_font_size_override("font_size", 13 if compact else 18)
	_center_title.add_theme_font_size_override("font_size", 14 if compact else 18)
	_fallback.add_theme_font_size_override("font_size", 11 if compact else 13)
	_credit.add_theme_font_size_override("font_size", 12 if compact else 13)
	if content is LCEND01Content and (content as LCEND01Content).themes.size() == 4:
		update_theme_cards()
		update_center_context()
	_layout_map()
	if Engine.is_editor_hint():
		HeaderUtilities.resize_presentation(self, _pending, _presentation_root.size.x)
	elif _header_utilities != null:
		_header_utilities.resize()


func _layout_map() -> void:
	if not is_node_ready() or _cards.size() != 4:
		return
	var compact := _is_compact()
	var card_height := 56.0 if compact else 76.0
	var card_width := _map.size.x * 0.43
	var credit_height := 18.0
	var gap := 6.0 if compact else 24.0
	var inner_height := _map.size.y - credit_height
	for i in 4:
		_cards[i].position = Vector2(0 if i % 2 == 0 else _map.size.x - card_width, 0 if i < 2 else inner_height - card_height)
		_cards[i].size = Vector2(card_width, card_height)
	_center.position = Vector2(_map.size.x * 0.10, card_height + gap)
	_center.size = Vector2(_map.size.x * 0.80, maxf(56, inner_height - card_height * 2 - gap * 2))
	_center_title.position = Vector2(6, 3)
	_center_title.size = Vector2(_center.size.x - 12, 22)
	_image.position = Vector2(8, 28)
	_image.size = Vector2(_center.size.x * 0.42 - 12, maxf(1, _center.size.y - 36))
	_fallback.position = _image.position
	_fallback.size = _image.size
	_context.position = Vector2(_center.size.x * 0.42, 27)
	_context.size = Vector2(_center.size.x * 0.58 - 8, maxf(1, _center.size.y - 32))
	_credit.position = Vector2(0, inner_height)
	_credit.size = Vector2(_map.size.x, credit_height)
	for i in 4:
		var card := _cards[i]
		var top := i < 2
		var from := card.position + Vector2(card.size.x * 0.5, card.size.y if top else 0.0)
		var to := _center.position + Vector2(_center.size.x * (0.22 if i % 2 == 0 else 0.78), 0.0 if top else _center.size.y)
		_connectors[i].points = PackedVector2Array([from, to])

func _card_input(event: InputEvent, index: int) -> void:
	if Engine.is_editor_hint():
		return
	if _sources.visible or _closing or not event.is_pressed():
		return
	var next := index
	if event.is_action_pressed(&"ui_left"): next = index - 1 if index % 2 == 1 else index
	elif event.is_action_pressed(&"ui_right"): next = index + 1 if index % 2 == 0 else index
	elif event.is_action_pressed(&"ui_up"): next = index - 2 if index >= 2 else index
	elif event.is_action_pressed(&"ui_down"): next = index + 2 if index < 2 else index
	else: return
	get_viewport().set_input_as_handled()
	_cards[next].grab_focus()

func _reading_input(event: InputEvent, scroll: ScrollContainer) -> void:
	if Engine.is_editor_hint():
		return
	if not event is InputEventKey or not event.is_pressed():
		return
	var movement := 0
	if event.is_action_pressed(&"ui_down"): movement = 42
	elif event.is_action_pressed(&"ui_up"): movement = -42
	elif event.is_action_pressed(&"ui_page_down"): movement = int(scroll.size.y * 0.85)
	elif event.is_action_pressed(&"ui_page_up"): movement = -int(scroll.size.y * 0.85)
	elif event.is_action_pressed(&"ui_home"): movement = -100000
	elif event.is_action_pressed(&"ui_end"): movement = 100000
	else: return
	get_viewport().set_input_as_handled()
	scroll.scroll_vertical += movement

func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _closing or _sources.visible:
		return
	cancel_active_tweens()
	_source_title.text = "Sources"
	_source_text.text = (content as LCEND01Content).sources_text
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()

func _update_speaker() -> void:
	if Engine.is_editor_hint():
		return
	HeaderUtilities.update_speaker(self, _pending)


func toggle_narration() -> void:
	if Engine.is_editor_hint():
		return
	HeaderUtilities.toggle_narration(self)


func stop_narration() -> void:
	if Engine.is_editor_hint():
		return
	_audio.stream_paused = false
	super.stop_narration()

func close_interaction() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _closing:
		return
	cancel_active_tweens()
	_cancel_panel_tween()
	stop_narration()
	_closing = true
	_panel_tween = create_tween()
	_panel_tween.tween_property(self, "modulate:a", 0.0, 0.16)
	_panel_tween.tween_callback(_finish_close)

func _finish_close() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_panel_tween()
	_closing = false
	super.close_interaction()
	# A host may free the component immediately after notification.
	close_requested.emit()

func _cancel_panel_tween() -> void:
	if Engine.is_editor_hint():
		return
	if _panel_tween != null and _panel_tween.is_valid():
		_panel_tween.kill()
	_panel_tween = null
	modulate.a = 1.0

func _visibility_changed() -> void:
	if Engine.is_editor_hint():
		return
	if _open and not is_visible_in_tree():
		cancel_active_tweens()
		_finish_close()

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	cancel_active_tweens()
	_cancel_panel_tween()
	super._exit_tree()

func _sync_focus() -> void:
	if Engine.is_editor_hint():
		return
	HeaderUtilities.sync_focus(self)


func _build_presentation() -> void:
	_subtitle = Label.new()
	_pending = Label.new()
	_prompt = Label.new()
	_map = Control.new()
	_center = Button.new()
	_center_title = Label.new()
	_context = VBoxContainer.new()
	_primary = Label.new()
	_secondary = Label.new()
	_fallback = Label.new()
	_credit = Label.new()
	_theme_label = Label.new()
	_meaning_label = Label.new()
	_meaning = Label.new()
	_source_basis = Label.new()
	_synthesis = Label.new()
	_outgoing_detail = Control.new()
	_cards.clear()
	_connectors.clear()

	_build_header()
	_build_map()
	_build_interpretation()
	_build_footer()
	# A clipped, noninteractive outgoing copy enables a real detail crossfade.
	_presentation_root.add_child(_outgoing_detail)
	_presentation_root.move_child(_outgoing_detail, _sources.get_index())
	_outgoing_detail.clip_contents = true
	_outgoing_detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_outgoing_detail.hide()
	if not Engine.is_editor_hint():
		_scroll.gui_input.connect(_reading_input.bind(_scroll))
		_source_scroll.gui_input.connect(_reading_input.bind(_source_scroll))


func _apply_presentation() -> void:
	var summary := content as LCEND01Content
	_title.text = summary.title.to_upper()
	_subtitle.text = summary.subtitle
	_prompt.text = summary.prompt
	_takeaway.text = summary.reflection_prompt
	_image.texture = summary.center_media
	_image.visible = summary.center_media != null
	_image.accessibility_name = summary.center_media_caption
	_fallback.text = summary.center_fallback
	_fallback.visible = summary.center_media == null
	_center_title.text = summary.center_media_caption
	_center.accessibility_name = summary.center_accessible_name
	_center.tooltip_text = summary.center_accessible_name
	_credit.text = summary.center_media_credit if summary.center_media != null else ""
	_credit.visible = summary.center_media != null
	if selected_theme == ThemeSelection.NONE:
		render_overview()
	else:
		render_theme()
	update_theme_cards()
	update_connectors()
	update_center_context()


func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		super._unhandled_input(event)


func close_sources() -> void:
	if not Engine.is_editor_hint():
		super.close_sources()


func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready() or content == null:
		return
	_presentation_root = EditorPresentation.begin(self)
	_build_presentation()
	selected_theme = ThemeSelection.NONE
	_apply_presentation()
	_map.resized.connect(_layout_map)
	EditorPresentation.finish(self, _presentation_root, _pending, content.narration)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
