extends Control
## Passive, aspect-fitted documentary compositions. No image interaction or viewer.
var primary: Texture2D
var secondary: Texture2D
var previous_primary: Texture2D
var previous_secondary: Texture2D
var left_label: String = ""
var right_label: String = ""
var blend: float = 1.0:
	set(value):
		blend = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	focus_mode = FOCUS_NONE
	texture_filter = TEXTURE_FILTER_LINEAR
	resized.connect(queue_redraw)


func configure(record: ConferenceRoomConceptEntry) -> void:
	primary = record.get_meta(&"image")
	secondary = record.get_meta(&"second_image") if record.has_meta(&"second_image") else null
	left_label = record.get_meta(&"left_label", "")
	right_label = record.get_meta(&"right_label", "")
	accessibility_name = record.get_meta(&"caption")
	queue_redraw()


func clear_transition() -> void:
	previous_primary = null
	previous_secondary = null
	blend = 1


func fitted_rect(texture: Texture2D, area: Rect2) -> Rect2:
	if texture == null:
		return Rect2()
	var native := texture.get_size()
	var scale_factor := minf(area.size.x / native.x, area.size.y / native.y)
	var fitted := native * maxf(0, scale_factor)
	return Rect2(area.position + (area.size - fitted) * 0.5, fitted)


func image_area(index: int, split: bool) -> Rect2:
	if not split:
		return Rect2(Vector2.ZERO, size)
	var pane_width := maxf(1, (size.x - 16) * 0.5)
	return Rect2(Vector2(index * (pane_width + 16), 48), Vector2(pane_width, maxf(1, size.y - 48)))


func _draw_images(first: Texture2D, second: Texture2D, alpha: float) -> void:
	if first == null or alpha <= 0:
		return
	draw_texture_rect(first, fitted_rect(first, image_area(0, second != null)), false, Color(1, 1, 1, alpha))
	if second != null:
		draw_texture_rect(second, fitted_rect(second, image_area(1, true)), false, Color(1, 1, 1, alpha))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("101a17"))
	_draw_images(previous_primary, previous_secondary, 1.0 - blend)
	_draw_images(primary, secondary, blend)
	if secondary == null:
		return
	var font := get_theme_default_font()
	for i in 2:
		var area := image_area(i, true)
		var lines := (left_label if i == 0 else right_label).split("\n")
		for row in lines.size():
			var width := font.get_string_size(lines[row], HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
			draw_string(font, Vector2(area.position.x + (area.size.x - width) * 0.5, 18 + row * 22), lines[row], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("dfcf9e") if row == 0 else Color("f4efe1"))
