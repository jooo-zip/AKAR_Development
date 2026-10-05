extends VBoxContainer
## Direct, optional concept selection. Static presentation lives in each TSCN.
@export var content: Resource
var selected: int = 0
var active: bool = false
var buttons: Array[Button] = []
var transition: Tween
@onready var media: TextureRect = %Media
@onready var info: VBoxContainer = %Info
@onready var scroll: ScrollContainer = %InfoScroll
@onready var view: Node = %ContentView

func _ready() -> void:
	for i in content.labels.size():
		var button: Button = get_node("%Choice" + str(i))
		buttons.append(button)
		button.pressed.connect(select_state.bind(i))
		button.gui_input.connect(_key.bind(i))
	view.refresh()
	reset_interaction()

func _key(event: InputEvent, index: int) -> void:
	if not active or not can_process():
		return
	if event is InputEventKey and event.pressed and event.keycode in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]:
		get_viewport().set_input_as_handled()
		var next: int = posmod(index + (-1 if event.keycode in [KEY_LEFT, KEY_UP] else 1), buttons.size())
		select_state(next)
		buttons[next].grab_focus()

func select_state(index: int) -> void:
	if not active or not can_process() or index < 0 or index >= buttons.size():
		return
	selected = index
	_cancel()
	for i in buttons.size():
		buttons[i].set_pressed_no_signal(i == index)
	transition = create_tween()
	transition.tween_property(media, "modulate:a", 0.3, 0.09)
	transition.parallel().tween_property(info, "modulate:a", 0.3, 0.09)
	transition.tween_callback(_present.bind(index))
	transition.tween_property(media, "modulate:a", 1.0, 0.13)
	transition.parallel().tween_property(info, "modulate:a", 1.0, 0.13)
	var connector: Control = get_node_or_null("%Connector")
	if connector != null:
		connector.modulate.a = 0.25
		transition.parallel().tween_property(connector, "modulate:a", 0.8, 0.22)

func _present(index: int) -> void:
	view.refresh(index)
	scroll.scroll_vertical = 0

func _cancel() -> void:
	if transition != null:
		transition.kill()
	media.modulate.a = 1.0
	info.modulate.a = 1.0

func reset_interaction() -> void:
	_cancel()
	selected = 0
	_present(0)
	for i in buttons.size():
		buttons[i].set_pressed_no_signal(i == 0)

func open_interaction() -> void:
	active = true
	reset_interaction()

func close_interaction() -> void:
	active = false
	reset_interaction()
