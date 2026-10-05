extends "res://scripts/landmarks/urduja_house/uh_phase5_explorer.gd"
## Optional spatial observations of the explicitly interpretive image.
var focus_index: int = -1
@onready var outline: ReferenceRect = %FocusOutline
@onready var frame: Control = %MediaFrame

func _ready() -> void:
	for i in 3:
		get_node("%Focus" + str(i)).pressed.connect(focus_area.bind(i))
	frame.resized.connect(_align_focus)
	super._ready()

func focus_area(index: int) -> void:
	if not active or not can_process() or selected != 0:
		return
	focus_index = index
	%Heading.text = content.observation_headings[index]
	%Body.text = content.observation_bodies[index]
	%Note.text = content.observation_notes[index]
	%Note.visible = not %Note.text.is_empty()
	scroll.scroll_vertical = 0
	_align_focus()

func _align_focus() -> void:
	if outline == null or media.texture == null:
		return
	outline.visible = selected == 0 and focus_index in [0, 1]
	var image_size: Vector2 = media.texture.get_size()
	var fitted: Vector2 = image_size * minf(frame.size.x / image_size.x, frame.size.y / image_size.y)
	var areas: Array[Rect2] = [Rect2(0.26, 0.43, 0.49, 0.39), Rect2(0.13, 0.32, 0.74, 0.53)]
	if focus_index >= 0 and focus_index < areas.size():
		outline.position = (frame.size - fitted) / 2 + areas[focus_index].position * fitted
		outline.size = areas[focus_index].size * fitted
	for i in 3:
		get_node("%Focus" + str(i)).set_pressed_no_signal(i == focus_index)

func _present(index: int) -> void:
	super._present(index)
	focus_index = -1
	%RoomFocus.visible = index == 0
	media.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if index == 0 else CanvasItem.TEXTURE_FILTER_LINEAR
	_align_focus()

func reset_interaction() -> void:
	focus_index = -1
	super.reset_interaction()
