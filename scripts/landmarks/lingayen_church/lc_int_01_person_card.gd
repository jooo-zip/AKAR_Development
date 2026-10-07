@tool
class_name LCINT01PersonCard
extends Button
## Presentation only. The owning hotspot supplies selection and spatial focus.

var portrait := TextureRect.new()
var name_label := Label.new()
var role_label := Label.new()
var placeholder := Label.new()
var _frame := Panel.new()
var _copy := VBoxContainer.new()
var _compact: bool = false


func _ready() -> void:
	toggle_mode = true
	custom_minimum_size = Vector2(100, 90)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("9c4a25")
	normal.border_color = Color("8e6c51")
	normal.set_border_width_all(1)
	var selected := normal.duplicate() as StyleBoxFlat
	selected.bg_color = Color("6f3317")
	selected.border_color = Color("e8d5b4")
	selected.set_border_width_all(2)
	for state in ["normal", "hover"]:
		add_theme_stylebox_override(state, normal)
	for state in ["pressed", "hover_pressed"]:
		add_theme_stylebox_override(state, selected)
	# The shared bright outline remains separate from the muted selected fill.
	add_child(_frame)
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color("101d19")
	_frame.add_theme_stylebox_override("panel", frame_style)
	_frame.add_child(portrait)
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(placeholder)
	placeholder.text = "Portrait source pending"
	placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	placeholder.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	placeholder.add_theme_font_size_override("font_size", 14)
	add_child(_copy)
	_copy.add_theme_constant_override("separation", 8)
	_copy.add_child(name_label)
	_copy.add_child(role_label)
	for label in [name_label, role_label]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_constant_override("line_spacing", 0)
	name_label.add_theme_color_override("font_color", Color("f9f5f0"))
	role_label.add_theme_color_override("font_color", Color("d6c5ab"))
	for child in [_frame, portrait, placeholder, _copy, name_label, role_label]:
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_layout)
	_copy.minimum_size_changed.connect(_layout)


func configure(person: LCINT01PersonContent, compact: bool) -> void:
	_compact = compact
	name_label.text = person.compact_display_name if compact and person.portrait != null else person.display_name
	role_label.text = person.compact_role if compact and person.portrait != null else person.short_role
	portrait.texture = person.portrait
	portrait.accessibility_name = person.display_name
	placeholder.visible = person.portrait == null
	_frame.visible = person.portrait != null
	accessibility_name = person.display_name + ". " + person.short_role
	if person.portrait == null:
		accessibility_name += ". Portrait source pending"
	name_label.add_theme_font_size_override("font_size", 15 if compact else 19)
	role_label.add_theme_font_size_override("font_size", 14 if compact else 16)
	_copy.add_theme_constant_override("separation", 4 if compact else 10)
	if compact and person.portrait == null:
		name_label.add_theme_font_size_override("font_size", 13)
		role_label.add_theme_font_size_override("font_size", 12)
		_copy.add_theme_constant_override("separation", 2)
	placeholder.add_theme_font_size_override("font_size", 12 if compact else 14)
	_layout()


func _layout() -> void:
	if not is_node_ready():
		return
	var padding := 7.0 if _compact else 12.0
	if portrait.texture == null:
		padding = 4.0 if _compact else 12.0
		_copy.position = Vector2.ONE * padding
		_copy.size = Vector2(size.x - padding * 2, _copy.get_combined_minimum_size().y)
		placeholder.position = Vector2(padding, size.y - padding - 20)
		placeholder.size = Vector2(size.x - padding * 2, 20)
		return
	var portrait_width := (size.x - padding * 3) * (0.33 if _compact else 0.36)
	_frame.position = Vector2(padding, padding)
	_frame.size = Vector2(portrait_width, maxf(0, size.y - padding * 2))
	_copy.position.x = _frame.position.x + portrait_width + padding
	_copy.size.x = maxf(1, size.x - _copy.position.x - padding)
	_copy.size.y = _copy.get_combined_minimum_size().y
	_copy.position.y = maxf(padding, (size.y - _copy.size.y) * 0.5)
