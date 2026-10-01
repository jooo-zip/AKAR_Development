extends Node
## Sources-only presentation/input for the seven Limahong panels.
## Historical references stay in content.source_credit; other landmarks are untouched.
var panel: ConferenceRoomInteraction
var _pointer: int = -1
var _origin: Vector2
var _scroll_origin: int

func _init(owner_panel: ConferenceRoomInteraction) -> void:
	panel = owner_panel
	name = "LimahongSourcesOverlay"

func _ready() -> void:
	# EXT-02's route ship uses z_index 2; the modal must cover it too.
	panel._sources.z_index = 3
	panel.sources_opened.connect(_opened)
	panel._sources.visibility_changed.connect(_reset_drag)
	panel.resized.connect(_resize)
	panel._source_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resize()

func _opened() -> void:
	panel._source_title.text = "SOURCES"
	panel._source_text.text = panel.content.source_credit
	_reset_drag()

func _resize() -> void:
	panel._source_text.add_theme_font_size_override("font_size", 20 if panel.size.x < 1050 else 22)

func _reset_drag() -> void:
	_pointer = -1

func _input(event: InputEvent) -> void:
	if not panel._open or not panel._sources.is_visible_in_tree():
		_pointer = -1
		return
	var scroll := panel._source_scroll
	if event is InputEventKey and event.pressed and scroll.has_focus():
		var delta: int
		match event.keycode:
			KEY_UP: delta = -32
			KEY_DOWN: delta = 32
			KEY_PAGEUP: delta = -int(scroll.size.y * 0.8)
			KEY_PAGEDOWN: delta = int(scroll.size.y * 0.8)
			KEY_HOME: delta = -int(scroll.get_v_scroll_bar().max_value)
			KEY_END: delta = int(scroll.get_v_scroll_bar().max_value)
			_: return
		get_viewport().set_input_as_handled()
		scroll.scroll_vertical += delta
	elif event is InputEventScreenTouch:
		if event.pressed and _pointer == -1 and scroll.get_global_rect().has_point(event.position):
			_pointer = event.index
			_origin = event.position
			_scroll_origin = scroll.scroll_vertical
			scroll.grab_focus()
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == _pointer:
			get_viewport().set_input_as_handled()
			_reset_drag()
	elif event is InputEventScreenDrag and _pointer != -1 and event.index == _pointer:
		get_viewport().set_input_as_handled()
		scroll.scroll_vertical = _scroll_origin + int(_origin.y - event.position.y)
