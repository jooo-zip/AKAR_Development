class_name LCEND01ThemeCard
extends Button
## Presentation only: the owner supplies state and spatial focus behavior.

var label := Label.new()

func _ready() -> void:
	toggle_mode = true
	custom_minimum_size = Vector2(100, 56)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("182923")
	normal.border_color = Color("697261")
	normal.set_border_width_all(1)
	var selected := normal.duplicate() as StyleBoxFlat
	selected.bg_color = Color("3d3d2c")
	selected.border_color = Color("dec787")
	selected.set_border_width_all(2)
	for state in ["normal", "hover"]:
		add_theme_stylebox_override(state, normal)
	for state in ["pressed", "hover_pressed"]:
		add_theme_stylebox_override(state, selected)
	add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 8
	label.offset_right = -8
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_constant_override("line_spacing", 0)

func configure(entry: LCEND01ThemeContent, compact: bool) -> void:
	label.text = (entry.short_title if compact else entry.title).to_upper()
	if not compact:
		label.text = label.text.replace(" & CO-CATHEDRAL", " &\nCO-CATHEDRAL")
	label.add_theme_font_size_override("font_size", 15 if compact else 19)
	accessibility_name = entry.accessible_title + " — summary theme"

func apply_selection(active: bool) -> void:
	set_pressed_no_signal(active)
	label.add_theme_color_override("font_color", Color("dec787") if active else Color("eeecdf"))
