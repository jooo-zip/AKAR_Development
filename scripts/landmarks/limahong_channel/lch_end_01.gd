extends ConferenceRoomInteraction
const Lifecycle = preload("res://scripts/landmarks/limahong_channel/lch_lifecycle.gd")
const SourcesOverlay = preload("res://scripts/landmarks/limahong_channel/lch_sources_overlay.gd")
const HeaderUtilities = preload("res://scripts/landmarks/limahong_channel/lch_header_utilities.gd")
var _header_utilities: HeaderUtilities
## Standalone optional summary: reading alone is valid; NONE is a real state.
signal close_requested
signal topic_changed(topic_index: int)

enum SummaryTopic { NONE = -1, RETREAT, BLOCKADE, ESCAPE, TRADITION, HERITAGE }
const SummaryContent = preload("res://scripts/landmarks/limahong_channel/lch_end_01_content.gd")
const GOLD := Color(0.88, 0.80, 0.55)
const NEUTRAL := Color(0.40, 0.48, 0.42)
var current_topic: SummaryTopic = SummaryTopic.NONE
var _data: SummaryContent
@onready var _board: Control = $"Main/Margin/Layout/SummaryStoryline"
@onready var _intro: HBoxContainer = $"Main/Margin/Layout/Intro"
@onready var _intro_heading: Label = $"Main/Margin/Layout/Intro/IntroHeading"
@onready var _intro_body: Label = $"Main/Margin/Layout/Intro/IntroBody"
@onready var _reflection: VBoxContainer = $"Main/Margin/Layout/Columns/Reflection"
@onready var _reflection_heading: Label = $"Main/Margin/Layout/Columns/Reflection/ReflectionHeading"
@onready var _reflection_body: Label = $"Main/Margin/Layout/Columns/Reflection/ReflectionBody"
@onready var _takeaway_heading: Label = $"Main/Margin/Layout/Columns/Reflection/TakeawayHeading"
@onready var _pending: Label = $"Main/Margin/Layout/Header/HeaderUtilityArea/NarrationStatusSlot/Pending"
@onready var _card_titles: Array[Label] = [$"Main/Margin/Layout/SummaryStoryline/PublicInterior/CardMargins0/VBoxContainer0/HBoxContainer0/CardTitles0", $"Main/Margin/Layout/SummaryStoryline/OfficialFunction/CardMargins1/VBoxContainer0/HBoxContainer0/CardTitles1", $"Main/Margin/Layout/SummaryStoryline/WhyItMatters/CardMargins2/VBoxContainer0/HBoxContainer0/CardTitles2", $"Main/Margin/Layout/SummaryStoryline/TraditionCard/CardMargins3/VBoxContainer0/HBoxContainer0/CardTitles3", $"Main/Margin/Layout/SummaryStoryline/HeritageCard/CardMargins4/VBoxContainer0/HBoxContainer0/CardTitles4"]
@onready var _card_bodies: Array[Label] = [$"Main/Margin/Layout/SummaryStoryline/PublicInterior/CardMargins0/VBoxContainer0/CardBodies0", $"Main/Margin/Layout/SummaryStoryline/OfficialFunction/CardMargins1/VBoxContainer0/CardBodies1", $"Main/Margin/Layout/SummaryStoryline/WhyItMatters/CardMargins2/VBoxContainer0/CardBodies2", $"Main/Margin/Layout/SummaryStoryline/TraditionCard/CardMargins3/VBoxContainer0/CardBodies3", $"Main/Margin/Layout/SummaryStoryline/HeritageCard/CardMargins4/VBoxContainer0/CardBodies4"]
@onready var _card_qualifiers: Array[Label] = [$"Main/Margin/Layout/SummaryStoryline/PublicInterior/CardMargins0/VBoxContainer0/CardQualifiers0", $"Main/Margin/Layout/SummaryStoryline/OfficialFunction/CardMargins1/VBoxContainer0/CardQualifiers1", $"Main/Margin/Layout/SummaryStoryline/WhyItMatters/CardMargins2/VBoxContainer0/CardQualifiers2", $"Main/Margin/Layout/SummaryStoryline/TraditionCard/CardMargins3/VBoxContainer0/CardQualifiers3", $"Main/Margin/Layout/SummaryStoryline/HeritageCard/CardMargins4/VBoxContainer0/CardQualifiers4"]
@onready var _card_numbers: Array[Label] = [$"Main/Margin/Layout/SummaryStoryline/PublicInterior/CardMargins0/VBoxContainer0/HBoxContainer0/CardNumbers0", $"Main/Margin/Layout/SummaryStoryline/OfficialFunction/CardMargins1/VBoxContainer0/HBoxContainer0/CardNumbers1", $"Main/Margin/Layout/SummaryStoryline/WhyItMatters/CardMargins2/VBoxContainer0/HBoxContainer0/CardNumbers2", $"Main/Margin/Layout/SummaryStoryline/TraditionCard/CardMargins3/VBoxContainer0/HBoxContainer0/CardNumbers3", $"Main/Margin/Layout/SummaryStoryline/HeritageCard/CardMargins4/VBoxContainer0/HBoxContainer0/CardNumbers4"]
@onready var _card_margins: Array[MarginContainer] = [$"Main/Margin/Layout/SummaryStoryline/PublicInterior/CardMargins0", $"Main/Margin/Layout/SummaryStoryline/OfficialFunction/CardMargins1", $"Main/Margin/Layout/SummaryStoryline/WhyItMatters/CardMargins2", $"Main/Margin/Layout/SummaryStoryline/TraditionCard/CardMargins3", $"Main/Margin/Layout/SummaryStoryline/HeritageCard/CardMargins4"]
@onready var _symbols: Array[Control] = [$"Main/Margin/Layout/SummaryStoryline/PublicInterior/CardMargins0/VBoxContainer0/HBoxContainer0/Symbols0", $"Main/Margin/Layout/SummaryStoryline/OfficialFunction/CardMargins1/VBoxContainer0/HBoxContainer0/Symbols1", $"Main/Margin/Layout/SummaryStoryline/WhyItMatters/CardMargins2/VBoxContainer0/HBoxContainer0/Symbols2", $"Main/Margin/Layout/SummaryStoryline/TraditionCard/CardMargins3/VBoxContainer0/HBoxContainer0/Symbols3", $"Main/Margin/Layout/SummaryStoryline/HeritageCard/CardMargins4/VBoxContainer0/HBoxContainer0/Symbols4"]
var _selected_styles: Array[StyleBoxFlat] = []
var _emphasis: Array[float] = [0, 0, 0, 0, 0]
var _compact: bool = false
var _entrance: Tween
var _selection: Tween

func _ready() -> void:
	_concepts = [$"Main/Margin/Layout/SummaryStoryline/PublicInterior", $"Main/Margin/Layout/SummaryStoryline/OfficialFunction", $"Main/Margin/Layout/SummaryStoryline/WhyItMatters", $"Main/Margin/Layout/SummaryStoryline/TraditionCard", $"Main/Margin/Layout/SummaryStoryline/HeritageCard"]
	super._ready()
	_data = content as SummaryContent
	_bind_authored_content()
	for i in 5:
		var card := _concepts[i]
		card.text = ""
		card.accessibility_name = _data.topics[i].full_title + ". " + _data.topics[i].short_body
		card.gui_input.connect(_card_input.bind(i))
		var selected: StyleBoxFlat = card.get_theme_stylebox("pressed").duplicate()
		_selected_styles.append(selected)
		card.add_theme_stylebox_override("pressed", selected)
		card.add_theme_stylebox_override("hover_pressed", selected)
		_symbols[i].draw.connect(_draw_symbol.bind(i))
	_scroll.gui_input.connect(_scroll_key.bind(_scroll))
	_source_scroll.gui_input.connect(_scroll_key.bind(_source_scroll))
	_board.draw.connect(_draw_storyline)
	_board.resized.connect(_layout_cards)
	resized.connect(_resize_layout)
	visibility_changed.connect(func():
		if _open and not is_visible_in_tree(): close_interaction())
	_resize_layout()
	_header_utilities = HeaderUtilities.new(self, _pending)
	add_child(SourcesOverlay.new(self))









func open_interaction() -> bool:
	if not is_node_ready() or _data == null or _data.topics.size() != 5:
		return false
	for i in 5:
		if _data.topics[i] == null or _data.topics[i].topic_id != i: return false
	if _open: return true
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	_cancel_animation()
	current_topic = SummaryTopic.NONE
	_title.text = content.title
	_audio.stream = content.narration_stream
	_audio.stop()
	_sources.hide()
	_open = true
	show()
	_update_speaker()
	_render()
	_resize_layout()
	_sync_focus()
	# Keep the default card appearance neutral while retaining visible keyboard focus.
	_sources_button.grab_focus()
	_board.modulate.a = 0.0
	_entrance = create_tween()
	_entrance.tween_property(_board, "modulate:a", 1.0, 0.4)
	_entrance.finished.connect(func(): _entrance = null)
	opened.emit()
	return true

func select_concept(index: int) -> void:
	select_topic(index)

func select_topic(topic: int, animate: bool = true) -> void:
	if not _open or _sources.visible or topic < -1 or topic > 4: return
	_cancel_animation()
	current_topic = (SummaryTopic.NONE if topic == current_topic else topic) as SummaryTopic
	_render()
	if animate:
		_information.modulate.a = 0.65
		_fade = create_tween()
		_fade.tween_property(_information, "modulate:a", 1.0, 0.18)
		_fade.finished.connect(func(): _fade = null)
		if current_topic != SummaryTopic.NONE:
			_set_emphasis(0.0, current_topic)
			_selection = create_tween()
			_selection.tween_method(_set_emphasis.bind(current_topic), 0.0, 1.0, 0.2)
			_selection.finished.connect(func(): _selection = null)
	topic_changed.emit(current_topic)

func _render() -> void:
	_selected = current_topic
	_heading.text = _data.default_detail_heading if current_topic == SummaryTopic.NONE else _data.topics[current_topic].full_title
	_body.text = _data.default_detail_body if current_topic == SummaryTopic.NONE else _data.topics[current_topic].detail_body
	_scroll.scroll_vertical = 0
	_takeaway.show()
	for i in 5:
		_concepts[i].set_pressed_no_signal(i == current_topic)
		_concepts[i].modulate = Color.WHITE
		_concepts[i].scale = Vector2.ONE
		_set_emphasis(1.0 if i == current_topic else 0.0, i)

func _set_emphasis(value: float, index: int) -> void:
	_emphasis[index] = value
	_selected_styles[index].border_color = NEUTRAL.lerp(GOLD, value)
	_board.queue_redraw()

func _cancel_animation() -> void:
	for tween in [_entrance, _selection]:
		if tween != null and tween.is_valid(): tween.kill()
	_entrance = null
	_selection = null
	_cancel_fade()
	_board.modulate = Color.WHITE
	if _selected_styles.size() == 5: _render()

func _resize_layout() -> void:
	if _card_titles.size() != 5: return
	_cancel_animation()
	var small := size.x < 1050
	_compact = size.x < 820
	for side in ["left", "top", "right", "bottom"]:
		$Main/Margin.add_theme_constant_override("margin_" + side, 8 if small else 16)
	# Reclaim shell spacing for the utility status row at the smallest viewport.
	if _compact:
		$Main/Margin.add_theme_constant_override("margin_top", 4)
		$Main/Margin.add_theme_constant_override("margin_bottom", 4)
	$Main/Margin/Layout.add_theme_constant_override("separation", 1 if _compact else (6 if small else 12))
	_title.add_theme_font_size_override("font_size", 18 if small else 26)
	_intro_heading.add_theme_font_size_override("font_size", 12 if small else 15)
	_intro_body.add_theme_font_size_override("font_size", 13 if small else 18)
	_board.custom_minimum_size.y = 180 if _compact else (158 if small else 180)
	%Columns.add_theme_constant_override("separation", 12 if small else 24)
	_information.add_theme_constant_override("separation", 3 if small else 8)
	_reflection.add_theme_constant_override("separation", 3 if small else 8)
	_information.size_flags_stretch_ratio = 0.8 if _compact else 1.0
	_heading.add_theme_font_size_override("font_size", 15 if small else 24)
	_body.add_theme_font_size_override("font_size", 13 if small else 20)
	for label in [_reflection_heading, _takeaway_heading]:
		label.add_theme_font_size_override("font_size", 12 if small else 16)
	for label in [_reflection_body, _takeaway]:
		label.add_theme_font_size_override("font_size", 12 if _compact else (14 if small else 18))
		label.add_theme_constant_override("line_spacing", -2 if _compact else 0)
	for i in 5:
		_card_titles[i].text = _data.topics[i].compact_label if _compact else _data.topics[i].full_title
		_card_titles[i].add_theme_font_size_override("font_size", 12 if small else 15)
		_card_bodies[i].add_theme_font_size_override("font_size", 12 if small else 15)
		_card_qualifiers[i].add_theme_font_size_override("font_size", 10 if small else 12)
		_card_numbers[i].add_theme_font_size_override("font_size", 12 if small else 14)
		for side in ["left", "top", "right", "bottom"]:
			_card_margins[i].add_theme_constant_override("margin_" + side, 4 if small else 8)
	_layout_cards()

func _layout_cards() -> void:
	if _concepts.size() != 5: return
	var gap := 8.0 if _compact else 12.0
	var columns := 3 if _compact else 5
	var width := (_board.size.x - gap * (columns - 1)) / columns
	for i in 5:
		var lower := _compact and i >= 3
		var x := (i - 3) * (width + gap) + (width + gap) * 0.5 if lower else i * (width + gap)
		_concepts[i].position = Vector2(x, 96 if lower else 12)
		_concepts[i].size = Vector2(width, 84.0 if lower else (76.0 if _compact else _board.size.y - 12.0))
	_board.queue_redraw()

func _draw_storyline() -> void:
	if _concepts.size() != 5: return
	var centers: Array[Vector2] = []
	for card in _concepts: centers.append(Vector2(card.get_rect().get_center().x, card.position.y - 6))
	for i in 4:
		if _compact and i == 2:
			var from := Vector2(centers[i].x, _concepts[i].get_rect().end.y)
			_board.draw_polyline(PackedVector2Array([from, Vector2(from.x, centers[i + 1].y), centers[i + 1]]), NEUTRAL, 1.0, true)
		else:
			_board.draw_line(centers[i], centers[i + 1], NEUTRAL, 1.0, true)
	for i in 5:
		_board.draw_line(centers[i] - Vector2(12, 0), centers[i] + Vector2(12, 0), NEUTRAL.lerp(GOLD, _emphasis[i]), 2.0, true)
		_board.draw_line(centers[i], centers[i] + Vector2(0, 6), NEUTRAL, 1.0)

func _draw_symbol(index: int) -> void:
	var canvas := _symbols[index]
	match _data.topics[index].icon_type:
		"path":
			canvas.draw_polyline(PackedVector2Array([Vector2(2, 15), Vector2(8, 15), Vector2(8, 6), Vector2(18, 6), Vector2(14, 2)]), GOLD, 1.5, true)
			canvas.draw_line(Vector2(18, 6), Vector2(14, 10), GOLD, 1.5, true)
		"arc": canvas.draw_arc(Vector2(10, 10), 7, 0.4, TAU - 0.4, 24, GOLD, 1.5, true)
		"water":
			for row in 2:
				var points := PackedVector2Array()
				for x in 19: points.append(Vector2(x + 1, 6 + row * 7 + sin(x * 0.3) * 2))
				canvas.draw_polyline(points, GOLD, 1.5, true)
		"document":
			canvas.draw_rect(Rect2(4, 2, 12, 16), GOLD, false, 1.5)
			for y in [6, 10, 14]: canvas.draw_line(Vector2(7, y), Vector2(13, y), GOLD, 1.0)
		"book":
			canvas.draw_polyline(PackedVector2Array([Vector2(2, 3), Vector2(10, 5), Vector2(18, 3), Vector2(18, 16), Vector2(10, 18), Vector2(2, 16), Vector2(2, 3)]), GOLD, 1.5, true)
			canvas.draw_line(Vector2(10, 5), Vector2(10, 18), GOLD, 1.0)

func _card_input(event: InputEvent, index: int) -> void:
	if not _open or _sources.visible or not event is InputEventKey or not event.pressed: return
	if event.keycode in [KEY_LEFT, KEY_RIGHT]:
		_concepts[index].accept_event()
		_concepts[clampi(index + (-1 if event.keycode == KEY_LEFT else 1), 0, 4)].grab_focus()

func _scroll_key(event: InputEvent, scroll: ScrollContainer) -> void:
	if not event is InputEventKey or not event.pressed: return
	var delta := 0
	match event.keycode:
		KEY_UP: delta = -32
		KEY_DOWN: delta = 32
		KEY_PAGEUP: delta = -int(scroll.size.y * 0.8)
		KEY_PAGEDOWN: delta = int(scroll.size.y * 0.8)
		KEY_HOME: delta = -int(scroll.get_v_scroll_bar().max_value)
		KEY_END: delta = int(scroll.get_v_scroll_bar().max_value)
		_: return
	scroll.accept_event()
	scroll.scroll_vertical += delta

func _sync_focus() -> void:
	var controls: Array[Control] = []
	controls.append_array(_concepts)
	controls.append(_scroll)
	HeaderUtilities.sync_focus(self, controls)

func open_sources() -> void:
	if not _open or _sources.visible: return
	_cancel_animation()
	_source_title.text = "Sources"
	_source_text.text = content.title + "\n\n" + content.source_credit
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()

func _update_speaker() -> void:
	super._update_speaker()
	_speaker.show()
	_speaker.disabled = _audio.stream == null
	_pending.visible = _audio.stream == null
	if _header_utilities != null: _header_utilities.refresh()

func close_interaction() -> void:
	if not _open: return
	_cancel_animation()
	super.close_interaction()
	current_topic = SummaryTopic.NONE
	_render()
	close_requested.emit()

func _exit_tree() -> void:
	for tween in [_entrance, _selection]:
		if tween != null and tween.is_valid(): tween.kill()
	super._exit_tree()

func _bind_authored_content() -> void:
	# Resources remain the only authority for interpretation copy.
	get_node("Main/Margin/Layout/Columns/Information/Heading").text = content.default_detail_heading
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/Body").text = content.default_detail_body
	get_node("Main/Margin/Layout/Columns/Reflection/ReflectionBody").text = content.reflection_prompt
	get_node("Main/Margin/Layout/Columns/Reflection/ReflectionHeading").text = content.reflection_heading
	get_node("Main/Margin/Layout/Columns/Reflection/Takeaway").text = content.learning_takeaway
	get_node("Main/Margin/Layout/Columns/Reflection/TakeawayHeading").text = content.takeaway_heading
	get_node("Main/Margin/Layout/Header/TitleArea/VBoxContainer0/HBoxContainer0/Label0").text = content.hotspot_id
	get_node("Main/Margin/Layout/Header/TitleArea/VBoxContainer0/Title").text = content.title
	get_node("Main/Margin/Layout/Intro/IntroBody").text = content.intro_body
	get_node("Main/Margin/Layout/Intro/IntroHeading").text = content.intro_heading
	get_node("Main/Margin/Layout/SummaryStoryline/OfficialFunction/CardMargins1/VBoxContainer0/CardBodies1").text = content.topics[1].short_body
	get_node("Main/Margin/Layout/SummaryStoryline/OfficialFunction/CardMargins1/VBoxContainer0/HBoxContainer0/CardNumbers1").text = content.topics[1].card_number
	get_node("Main/Margin/Layout/SummaryStoryline/OfficialFunction/CardMargins1/VBoxContainer0/HBoxContainer0/CardTitles1").text = content.topics[1].full_title
	get_node("Main/Margin/Layout/SummaryStoryline/WhyItMatters/CardMargins2/VBoxContainer0/CardBodies2").text = content.topics[2].short_body
	get_node("Main/Margin/Layout/SummaryStoryline/WhyItMatters/CardMargins2/VBoxContainer0/HBoxContainer0/CardNumbers2").text = content.topics[2].card_number
	get_node("Main/Margin/Layout/SummaryStoryline/WhyItMatters/CardMargins2/VBoxContainer0/HBoxContainer0/CardTitles2").text = content.topics[2].full_title
	get_node("Main/Margin/Layout/SummaryStoryline/HeritageCard/CardMargins4/VBoxContainer0/CardBodies4").text = content.topics[4].short_body
	get_node("Main/Margin/Layout/SummaryStoryline/HeritageCard/CardMargins4/VBoxContainer0/HBoxContainer0/CardNumbers4").text = content.topics[4].card_number
	get_node("Main/Margin/Layout/SummaryStoryline/HeritageCard/CardMargins4/VBoxContainer0/HBoxContainer0/CardTitles4").text = content.topics[4].full_title
	get_node("Main/Margin/Layout/SummaryStoryline/PublicInterior/CardMargins0/VBoxContainer0/CardBodies0").text = content.topics[0].short_body
	get_node("Main/Margin/Layout/SummaryStoryline/PublicInterior/CardMargins0/VBoxContainer0/HBoxContainer0/CardNumbers0").text = content.topics[0].card_number
	get_node("Main/Margin/Layout/SummaryStoryline/PublicInterior/CardMargins0/VBoxContainer0/HBoxContainer0/CardTitles0").text = content.topics[0].full_title
	get_node("Main/Margin/Layout/SummaryStoryline/TraditionCard/CardMargins3/VBoxContainer0/CardBodies3").text = content.topics[3].short_body
	get_node("Main/Margin/Layout/SummaryStoryline/TraditionCard/CardMargins3/VBoxContainer0/CardQualifiers3").text = content.topics[3].qualifier_label
	get_node("Main/Margin/Layout/SummaryStoryline/TraditionCard/CardMargins3/VBoxContainer0/HBoxContainer0/CardNumbers3").text = content.topics[3].card_number
	get_node("Main/Margin/Layout/SummaryStoryline/TraditionCard/CardMargins3/VBoxContainer0/HBoxContainer0/CardTitles3").text = content.topics[3].full_title


func reset_interaction() -> void:
	Lifecycle.reset(self)
