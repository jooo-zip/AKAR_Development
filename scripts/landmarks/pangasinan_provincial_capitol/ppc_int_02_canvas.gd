@tool
extends Control
## Conceptual civic relationships, never a physical route or floor plan.
signal branch_selected(id: StringName)

var mode: StringName = &"overview"
var photo: TextureRect
var previous_photo: TextureRect
var diagram: Control
var lobby_label: Label
var schematic: Label
var branches: Array[Button] = []
var branch_labels: Array[Label] = []
var comparison: HBoxContainer
var compare_photos: Array[TextureRect] = []
var compare_actions: Array[Button] = []
var compare_summaries: Array[Label] = []
var comparison_cards: Array[VBoxContainer] = []
var highlighted: StringName = &"none"
var highlight_strength: float = 0.0:
	set(value):
		highlight_strength = value
		queue_redraw()


func _ready() -> void:
	photo = TextureRect.new()
	previous_photo = TextureRect.new()
	diagram = Control.new()
	lobby_label = Label.new()
	schematic = Label.new()
	comparison = HBoxContainer.new()
	mouse_filter = MOUSE_FILTER_IGNORE
	add_child(previous_photo)
	_fit_photo(previous_photo)
	add_child(photo)
	_fit_photo(photo)
	add_child(diagram)
	diagram.mouse_filter = MOUSE_FILTER_IGNORE
	diagram.add_child(lobby_label)
	lobby_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lobby_label.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(schematic)
	schematic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	schematic.add_theme_font_size_override("font_size", 14)
	schematic.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(comparison)
	comparison.add_theme_constant_override("separation", 18)
	for i in 2:
		var id: StringName = &"executive" if i == 0 else &"legislative"
		var branch := Button.new()
		branch.text = "EXECUTIVE" if i == 0 else "LEGISLATIVE"
		if not Engine.is_editor_hint():
			branch.pressed.connect(func() -> void: branch_selected.emit(id))
		diagram.add_child(branch)
		branches.append(branch)
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.mouse_filter = MOUSE_FILTER_IGNORE
		diagram.add_child(label)
		branch_labels.append(label)
		var card := VBoxContainer.new()
		card.size_flags_horizontal = SIZE_EXPAND_FILL
		card.add_theme_constant_override("separation", 6)
		comparison.add_child(card)
		comparison_cards.append(card)
		var heading := Label.new()
		heading.text = branch.text + " FUNCTION"
		heading.add_theme_color_override("font_color", Color("e8d5b4"))
		card.add_child(heading)
		var space := Label.new()
		space.name = "Space"
		card.add_child(space)
		var image := TextureRect.new()
		_fit_photo(image)
		image.size_flags_vertical = SIZE_EXPAND_FILL
		card.add_child(image)
		compare_photos.append(image)
		var summary := Label.new()
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		summary.custom_minimum_size.y = 80
		summary.add_theme_font_size_override("font_size", 17)
		card.add_child(summary)
		compare_summaries.append(summary)
		var action := Button.new()
		action.text = "EXPLORE " + branch.text
		if not Engine.is_editor_hint():
			action.pressed.connect(func() -> void: branch_selected.emit(id))
		card.add_child(action)
		compare_actions.append(action)
	if not Engine.is_editor_hint():
		resized.connect(arrange)
	comparison.minimum_size_changed.connect(arrange.call_deferred)
	comparison.resized.connect(arrange.call_deferred)


func _fit_photo(image: TextureRect) -> void:
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture_filter = TEXTURE_FILTER_LINEAR
	image.mouse_filter = MOUSE_FILTER_IGNORE


func configure(view: StringName, record: ConferenceRoomConceptEntry, executive: ConferenceRoomConceptEntry, legislative: ConferenceRoomConceptEntry, disclaimer: String) -> void:
	mode = view
	previous_photo.texture = photo.texture if record.has_meta(&"image") else null
	photo.texture = record.get_meta(&"image") if record.has_meta(&"image") else null
	photo.accessibility_name = record.get_meta(&"caption", "")
	photo.visible = view in [&"lobby", &"executive", &"legislative"]
	diagram.visible = view in [&"overview", &"lobby"]
	schematic.visible = diagram.visible
	schematic.text = disclaimer
	comparison.visible = view == &"comparison"
	lobby_label.text = "YOU ARE HERE\nPUBLIC LOBBY" if view == &"lobby" else "PUBLIC LOBBY"
	for i in 2:
		var item: ConferenceRoomConceptEntry = executive if i == 0 else legislative
		branches[i].visible = view == &"lobby"
		branch_labels[i].visible = view == &"overview"
		branch_labels[i].text = str(item.get_meta(&"context")) + "\n" + item.heading
		comparison_cards[i].get_node("Space").text = item.heading
		compare_photos[i].texture = item.get_meta(&"image")
		compare_photos[i].accessibility_name = item.get_meta(&"caption")
		compare_summaries[i].text = item.get_meta(&"summary")
	arrange()


func arrange() -> void:
	if not is_node_ready():
		return
	photo.position = Vector2.ZERO
	photo.size = size
	diagram.position = Vector2.ZERO
	diagram.size = Vector2(size.x, maxf(1, size.y - 28))
	if mode == &"lobby":
		photo.size.x = size.x * 0.36
		photo.size.y = maxf(1, size.y - 28)
		diagram.position.x = size.x * 0.39
		diagram.size.x = size.x * 0.61
	lobby_label.position = Vector2(0, 8)
	lobby_label.size = Vector2(diagram.size.x, 52)
	var branch_y := maxf(74, diagram.size.y * 0.62)
	for i in 2:
		branches[i].position = Vector2(i * (diagram.size.x * 0.5 + 4), branch_y)
		branches[i].size = Vector2(diagram.size.x * 0.5 - 4, 52)
		branch_labels[i].position = branches[i].position
		branch_labels[i].size = Vector2(branches[i].size.x, 60)
	schematic.position = Vector2(0, maxf(0, size.y - 24))
	schematic.size = Vector2(size.x, 24)
	comparison.position = Vector2.ZERO
	previous_photo.position = photo.position
	previous_photo.size = photo.size
	var summary_height := 70.0
	for summary in compare_summaries:
		summary_height = maxf(summary_height, summary.get_minimum_size().y)
	for summary in compare_summaries:
		summary.custom_minimum_size.y = summary_height
	comparison.size = size
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("101d19"))
	if not diagram.visible:
		return
	var origin := diagram.position
	var w := diagram.size.x
	var stem := origin + Vector2(w * 0.5, 63)
	var joint := origin + Vector2(w * 0.5, maxf(68, diagram.size.y * 0.45))
	draw_line(stem, joint, Color("8e6c51"), 2)
	for i in 2:
		var end := origin + Vector2(w * (0.25 if i == 0 else 0.75), branches[i].position.y - 6)
		var color := Color("8e6c51")
		if highlighted == (&"executive" if i == 0 else &"legislative"):
			color = color.lerp(Color("e8d5b4"), highlight_strength)
		draw_line(joint, Vector2(end.x, joint.y), color, 2)
		draw_line(Vector2(end.x, joint.y), end, color, 2)
		draw_line(end, end + Vector2(-4, -5), color, 2)
		draw_line(end, end + Vector2(4, -5), color, 2)
