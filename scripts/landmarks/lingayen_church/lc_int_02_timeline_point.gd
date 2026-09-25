class_name LCINT02TimelinePoint
extends Button
## A date's hit region and visual state only; chronology belongs to the owner.

var dot := Panel.new()
var year := Label.new()

func _ready() -> void:
	toggle_mode = true
	custom_minimum_size = Vector2(56, 56)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for state in ["normal", "hover", "pressed", "hover_pressed"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	add_child(dot)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.size = Vector2(18, 18)
	add_child(year)
	year.mouse_filter = Control.MOUSE_FILTER_IGNORE
	year.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	year.add_theme_font_size_override("font_size", 17)
	resized.connect(_layout)
	_layout()

func configure(short_year: String, full_title: String) -> void:
	year.text = short_year
	accessibility_name = short_year + " — " + full_title
	_layout()

func apply_selection(selected: bool) -> void:
	set_pressed_no_signal(selected)
	var color := Color("dec787") if selected else Color("8e9789")
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(9)
	dot.add_theme_stylebox_override("panel", style)
	year.add_theme_color_override("font_color", color)
	accessibility_description = "Selected" if selected else "Select this point in time"

func _layout() -> void:
	dot.position = Vector2((size.x - 18) * 0.5, 4)
	year.position = Vector2(0, 26)
	year.size = Vector2(size.x, 26)
