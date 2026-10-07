extends "res://scripts/landmarks/urduja_house/uh_phase5_explorer.gd"
## The date row is both directly selectable and draggable; no duplicated slider row.
var pointer: int = -2
var release_selection: int = -1
@onready var track: HBoxContainer = %Navigation
func _ready() -> void:
	super._ready()
	for i in buttons.size():
		buttons[i].gui_input.connect(_start_drag.bind(i))
func _start_drag(event: InputEvent, index: int) -> void:
	if not active or not can_process():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pointer = -1
		select_state(index)
	elif event is InputEventScreenTouch and event.pressed:
		pointer = event.index
		select_state(index)
func _input(event: InputEvent) -> void:
	if not active or not can_process() or pointer == -2:
		return
	var matches: bool = (pointer == -1 and (event is InputEventMouseMotion or event is InputEventMouseButton)) or (event is InputEventScreenDrag and event.index == pointer) or (event is InputEventScreenTouch and event.index == pointer)
	if not matches:
		return
	var nearest: int = 0
	var distance: float = INF
	for i in buttons.size():
		var delta: float = absf(event.position.x-buttons[i].get_global_rect().get_center().x)
		if delta < distance:
			distance = delta
			nearest = i
	if nearest != selected:
		select_state(nearest)
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and not event.pressed:
		release_selection = nearest
		_clear_release.call_deferred()
		pointer = -2
		return # Let the Button finish its own pressed/released visual state.
	get_viewport().set_input_as_handled()
func _key(event: InputEvent, index: int) -> void:
	if event is InputEventKey and event.pressed and event.keycode in [KEY_HOME,KEY_END] and active and can_process():
		get_viewport().set_input_as_handled()
		select_state(0 if event.keycode == KEY_HOME else 3)
		buttons[selected].grab_focus()
	else:
		super._key(event,index)
func _present(index: int) -> void:
	super._present(index)
	%OfficeTransfer.visible = index == 2
	if index == 2:
		%DocumentPanel.hide()
		# The graphic's own labels explain the function transfer. Its interpretation
		# disclosure remains in Sources, leaving room for both final statuses.
		%Caption.hide()
		_play_office_transfer()
func reset_interaction() -> void:
	super.reset_interaction()
	pointer = -2
func cancel_pointer() -> void:
	pointer = -2

func select_state(index: int) -> void:
	if release_selection >= 0 and release_selection == selected:
		for i in buttons.size():
			buttons[i].set_pressed_no_signal(i == selected)
		return
	super.select_state(release_selection if release_selection >= 0 else index)
func _clear_release() -> void:
	release_selection = -1


var office_tween: Tween
var office_progress: float = 0.0
var office_complete: bool = false

func _cancel() -> void:
	super._cancel()
	_reset_office_transfer()

func _reset_office_transfer() -> void:
	if office_tween != null:
		office_tween.kill()
	office_complete = false
	%OfficeTransfer.hide()
	_move_office(0.0)
	%OfficeLine.scale.x = 0.0
	%OfficeArrow.modulate.a = 0.0
	for node in [%ResidenceEndpoint, %CapitolEndpoint, %ResidenceStatus, %CapitolStatus]:
		node.modulate = Color.WHITE
		node.modulate.a = 0.0

func _move_office(progress: float) -> void:
	office_progress = progress
	var start: float = %ResidenceEndpoint.anchor_left
	var destination: float = %CapitolEndpoint.anchor_left
	var width: float = %ResidenceEndpoint.anchor_right - start
	%OfficeToken.anchor_left = lerpf(start, destination, progress)
	%OfficeToken.anchor_right = %OfficeToken.anchor_left + width

func _play_office_transfer() -> void:
	_reset_office_transfer()
	%OfficeTransfer.show()
	office_tween = create_tween()
	office_tween.tween_property(%ResidenceEndpoint, "modulate:a", 1.0, 0.25)
	office_tween.parallel().tween_property(%CapitolEndpoint, "modulate:a", 1.0, 0.25)
	office_tween.tween_property(%OfficeLine, "scale:x", 1.0, 0.3)
	office_tween.parallel().tween_property(%OfficeArrow, "modulate:a", 1.0, 0.3)
	office_tween.tween_method(_move_office, 0.0, 1.0, 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	office_tween.tween_property(%CapitolEndpoint, "modulate", Color("e8d5b4"), 0.15)
	office_tween.tween_property(%CapitolEndpoint, "modulate", Color.WHITE, 0.15)
	office_tween.parallel().tween_property(%ResidenceStatus, "modulate:a", 1.0, 0.15)
	office_tween.parallel().tween_property(%CapitolStatus, "modulate:a", 1.0, 0.15)
	office_tween.tween_callback(func() -> void: office_complete = true)
