extends "res://scripts/landmarks/urduja_house/uh_phase5_explorer.gd"
var lens_position: Vector2 = Vector2(0.5, 0.5)
var pointer: int = -2
var sample := AtlasTexture.new()
@onready var frame: Control = %MediaFrame
@onready var lens: Control = %Lens
@onready var lens_image: TextureRect = %LensImage
func _ready() -> void:
	super._ready()
	lens.gui_input.connect(_lens_input)
	lens.focus_entered.connect(func() -> void: lens.modulate = Color(1.15,1.15,1.15))
	lens.focus_exited.connect(func() -> void: lens.modulate = Color.WHITE)
	frame.resized.connect(_align_lens)
	_align_lens.call_deferred()
func image_rect() -> Rect2:
	var native: Vector2 = media.texture.get_size()
	var fitted: Vector2 = native * minf(frame.size.x/native.x,frame.size.y/native.y)
	return Rect2((frame.size-fitted)*0.5,fitted)
func _align_lens() -> void:
	if not is_instance_valid(lens) or media.texture == null:
		return
	var rect := image_rect()
	if rect.size.x < lens.size.x or rect.size.y < lens.size.y:
		return
	var half: Vector2 = lens.size*0.5
	var center: Vector2 = rect.position + lens_position * rect.size
	center = center.clamp(rect.position+half,rect.end-half)
	lens.position = center-half
	lens_position = (center-rect.position)/rect.size.max(Vector2.ONE)
	var native: Vector2 = media.texture.get_size()
	var scale_factor: float = rect.size.x/native.x
	var crop: Vector2 = Vector2(78,78)/maxf(0.01,scale_factor*2.0)
	var source_center: Vector2 = lens_position*native
	sample.atlas = media.texture
	sample.region = Rect2((source_center-crop*0.5).clamp(Vector2.ZERO,native-crop),crop)
	lens_image.texture = sample
func _lens_input(event: InputEvent) -> void:
	if not active or not can_process():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pointer = -1 if event.pressed else -2
		lens.grab_focus()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch:
		pointer = event.index if event.pressed else -2
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and event.keycode in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]:
		var movement := Vector2.ZERO
		movement.x = -0.04 if event.keycode == KEY_LEFT else (0.04 if event.keycode == KEY_RIGHT else 0.0)
		movement.y = -0.04 if event.keycode == KEY_UP else (0.04 if event.keycode == KEY_DOWN else 0.0)
		lens_position += movement
		_align_lens()
		get_viewport().set_input_as_handled()
func _input(event: InputEvent) -> void:
	if not active or pointer == -2 or not can_process():
		return
	var matches: bool = (pointer == -1 and (event is InputEventMouseMotion or event is InputEventMouseButton)) or (event is InputEventScreenDrag and event.index == pointer) or (event is InputEventScreenTouch and event.index == pointer)
	if not matches:
		return
	var point: Vector2 = frame.get_global_transform_with_canvas().affine_inverse()*event.position
	var rect := image_rect()
	lens_position = (point-rect.position)/rect.size.max(Vector2.ONE)
	_align_lens()
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and not event.pressed:
		pointer = -2
	get_viewport().set_input_as_handled()
func reset_interaction() -> void:
	super.reset_interaction()
	pointer = -2
	lens_position = Vector2(0.5,0.5)
	_align_lens.call_deferred()

func cancel_pointer() -> void:
	pointer = -2
