extends Control
## One coordinate path for mouse, touch and keyboard; the original photo never moves.
const LENS_SIZE := 76.0
const HIT_SIZE := 96.0
const DETAIL_SIZE := LENS_SIZE * 2.0
const GOLD := Color(0.90, 0.82, 0.60)

var lens_normalized_position := Vector2(0.42, 0.55)
var lens_dragging: bool = false
var detail_view_side: int = 1 # 0 left, 1 right; hysteresis retains the middle band.
var hint_has_been_dismissed: bool = false
var displayed_image_rect := Rect2()
var source_region := Rect2()
@onready var lens: Control = $"MagnifierLens"
@onready var detail: PanelContainer = $"DetailView"
@onready var hint: Label = $"Label2"
var _photo: TextureRect
@onready var _detail_texture: TextureRect = $"DetailView/VBoxContainer0/TextureRect1"
@onready var _pending: Label = $"DetailView/VBoxContainer0/TextureRect1/Label0"
var _atlas := AtlasTexture.new()
var _hint_tween: Tween
var _enabled: bool = false
var _pointer: int = -1
var _drag_offset := Vector2.ZERO
var _drag_start := Vector2.ZERO


func configure(photo: TextureRect) -> void:
	_photo = photo
	_atlas.filter_clip = true
	lens.accessibility_name = "Magnifying lens. Drag to inspect, or use arrow keys. Shift moves faster."
	lens.draw.connect(_draw_magnifying_glass)
	lens.focus_entered.connect(lens.queue_redraw)
	lens.focus_exited.connect(lens.queue_redraw)
	lens.gui_input.connect(_lens_input)
	resized.connect(refresh_layout)
	detail.resized.connect(_position_detail)

func _draw_magnifying_glass() -> void:
	# Circle and handle stay inside the generous hit area. The optical center stays
	# at the control's center, so its diameter maps directly to the sampled region.
	var center := lens.size * 0.5
	var radius := LENS_SIZE * 0.5
	var handle_start := center + Vector2.ONE.normalized() * (radius - 2.0)
	var handle_end := center + Vector2(37, 37)
	var shadow_offset := Vector2(1, 2)
	lens.draw_line(handle_start + shadow_offset, handle_end + shadow_offset, Color(0.04, 0.06, 0.05, 0.65), 11.0, true)
	lens.draw_circle(handle_end + shadow_offset, 5.5, Color(0.04, 0.06, 0.05, 0.65), true, -1.0, true)
	lens.draw_line(handle_start, handle_end, GOLD, 7.0, true)
	lens.draw_circle(handle_end, 3.5, GOLD, true, -1.0, true)
	lens.draw_arc(center + shadow_offset, radius, 0, TAU, 80, Color(0.04, 0.06, 0.05, 0.65), 6.0, true)
	lens.draw_circle(center, radius, Color(0.90, 0.85, 0.67, 0.08), true, -1.0, true)
	lens.draw_arc(center, radius, 0, TAU, 80, GOLD, 3.0, true)
	lens.draw_arc(center, radius - 3.0, PI * 1.10, PI * 1.48, 24, Color(1.0, 0.97, 0.84, 0.65), 1.5, true)
	if lens.has_focus():
		lens.draw_style_box(get_theme_stylebox("focus", "Button"), Rect2(Vector2.ZERO, lens.size))


func reset(default_position: Vector2) -> void:
	stop()
	_enabled = true
	lens.mouse_filter = Control.MOUSE_FILTER_STOP
	detail_view_side = 1
	lens_normalized_position = default_position
	_atlas.atlas = _photo.texture
	_detail_texture.texture = _atlas if _photo.texture != null else null
	_pending.visible = _photo.texture == null
	refresh_layout()
	hint_has_been_dismissed = false
	hint.modulate.a = 1.0
	hint.show()
	_hint_tween = create_tween()
	_hint_tween.tween_interval(2.5)
	_hint_tween.tween_property(hint, "modulate:a", 0.0, 0.3)
	_hint_tween.tween_callback(dismiss_hint)


func refresh_layout() -> void:
	if _photo == null or lens == null:
		return
	cancel_drag()
	var native := _native_size()
	var fit := minf(_photo.size.x / native.x, _photo.size.y / native.y)
	var fitted := native * fit
	displayed_image_rect = Rect2(_photo.position + (_photo.size - fitted) * 0.5, fitted)
	set_lens_normalized_position(lens_normalized_position)
	hint.position = Vector2(maxf(0.0, (size.x - hint.size.x) * 0.5), maxf(0.0, size.y - 28.0))


func set_lens_normalized_position(value: Vector2) -> void:
	var fitted := displayed_image_rect.size
	if fitted.x <= 0.0 or fitted.y <= 0.0:
		return
	var margin := (Vector2.ONE * HIT_SIZE * 0.5 / fitted).min(Vector2.ONE * 0.5)
	lens_normalized_position = value.clamp(margin, Vector2.ONE - margin)
	var center := displayed_image_rect.position + fitted * lens_normalized_position
	lens.position = center - lens.size * 0.5
	var native := _native_size()
	var crop_size := (Vector2.ONE * LENS_SIZE / fitted * native).min(native)
	source_region = Rect2(lens_normalized_position * native - crop_size * 0.5, crop_size)
	_atlas.region = source_region
	if lens_normalized_position.x > 0.58:
		detail_view_side = 0
	elif lens_normalized_position.x < 0.42:
		detail_view_side = 1
	_position_detail()


func _native_size() -> Vector2:
	return _photo.texture.get_size() if _photo.texture != null else Vector2(1000, 1000)


func _position_detail() -> void:
	if detail == null:
		return
	detail.position = Vector2(maxf(8.0, size.x - detail.size.x - 8.0) if detail_view_side == 1 else 8.0, 8.0)


func _lens_input(event: InputEvent) -> void:
	if not _enabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_drag(-1, lens.get_global_transform_with_canvas() * event.position)
		lens.accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		_start_drag(event.index, lens.get_global_transform_with_canvas() * event.position)
		lens.accept_event()
	elif event is InputEventKey and event.pressed:
		var direction := Vector2.ZERO
		match event.keycode:
			KEY_LEFT: direction.x = -1
			KEY_RIGHT: direction.x = 1
			KEY_UP: direction.y = -1
			KEY_DOWN: direction.y = 1
		if direction != Vector2.ZERO:
			set_lens_normalized_position(lens_normalized_position + direction * (36.0 if event.shift_pressed else 18.0) / displayed_image_rect.size)
			dismiss_hint()
			lens.accept_event()


func _start_drag(pointer: int, viewport_position: Vector2) -> void:
	if lens_dragging:
		return
	lens_dragging = true
	_pointer = pointer
	_drag_start = get_global_transform_with_canvas().affine_inverse() * viewport_position
	_drag_offset = _drag_start - (lens.position + lens.size * 0.5)
	lens.grab_focus()


func _input(event: InputEvent) -> void:
	if not _enabled:
		return
	# Capture the native touch before optional mouse emulation loses its identifier.
	# Only the lens hit rectangle starts a drag; background touches pass through.
	if event is InputEventScreenTouch and event.pressed and (not lens_dragging or _pointer == -1):
		var local: Vector2 = lens.get_global_transform_with_canvas().affine_inverse() * event.position
		if Rect2(Vector2.ZERO, lens.size).has_point(local):
			# Desktop emulation can dispatch the synthetic mouse press first.
			# Adopt its native touch id before accepting subsequent drag events.
			cancel_drag()
			_start_drag(event.index, event.position)
			get_viewport().set_input_as_handled()
		return
	if not lens_dragging:
		return
	if _pointer == -1:
		if event is InputEventMouseMotion:
			_move_lens(event.position)
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			get_viewport().set_input_as_handled()
			_move_lens(event.position)
			cancel_drag()
	else:
		if event is InputEventScreenDrag and event.index == _pointer:
			_move_lens(event.position)
			get_viewport().set_input_as_handled()
		elif event is InputEventScreenTouch and event.index == _pointer and not event.pressed:
			get_viewport().set_input_as_handled()
			if not event.canceled:
				_move_lens(event.position)
			cancel_drag()


func _move_lens(viewport_position: Vector2) -> void:
	var local := get_global_transform_with_canvas().affine_inverse() * viewport_position
	if local.distance_to(_drag_start) > 2.0:
		dismiss_hint()
	set_lens_normalized_position((local - _drag_offset - displayed_image_rect.position) / displayed_image_rect.size)


func cancel_drag() -> void:
	lens_dragging = false
	_pointer = -1
	_drag_offset = Vector2.ZERO


func set_interaction_enabled(enabled: bool) -> void:
	_enabled = enabled
	lens.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	if not enabled:
		cancel_drag()


func dismiss_hint() -> void:
	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()
	_hint_tween = null
	hint_has_been_dismissed = true
	hint.hide()


func stop() -> void:
	set_interaction_enabled(false)
	dismiss_hint()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		cancel_drag()


func _exit_tree() -> void:
	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()
