extends "res://scripts/landmarks/urduja_house/uh_phase5_explorer.gd"
var event_index: int = 0
var observation: int = -1
func _ready() -> void:
	super._ready()
	%Previous.pressed.connect(change_event.bind(-1))
	%Next.pressed.connect(change_event.bind(1))
	for i in 3:
		get_node("%ObservationMarker" + str(i)).pressed.connect(observe.bind(i))
		get_node("%ObservationChoice" + str(i)).pressed.connect(observe.bind(i))
func change_event(direction: int) -> void:
	if not active or not can_process() or selected != 1:
		return
	event_index = posmod(event_index+direction,content.event_titles.size())
	select_state(1)
func _present(index: int) -> void:
	super._present(index)
	%Carousel.visible = index == 1
	observation = -1
	%ObservationAspect.visible = index == 2
	%ObservationChoices.visible = index == 2
	_update_observation_buttons()
	if index == 1:
		%Heading.text = content.event_titles[event_index]
		%Body.text = content.event_dates[event_index]
		%Note.text = content.event_credits[event_index]
		media.texture = content.event_images[event_index]
		media.accessibility_name = content.event_titles[event_index]
		%Caption.text = "Official event • " + content.event_dates[event_index]
func reset_interaction() -> void:
	event_index = 0
	observation = -1
	super.reset_interaction()

func observe(index: int) -> void:
	if not active or not can_process() or selected != 2:
		return
	observation = index
	%Heading.text = content.observation_headings[index]
	%Body.text = content.observation_bodies[index]
	%Note.hide()
	scroll.scroll_vertical = 0
	_update_observation_buttons()

func _update_observation_buttons() -> void:
	for i in 3:
		var marker: Button = get_node("%ObservationMarker" + str(i))
		marker.set_pressed_no_signal(i == observation)
		marker.modulate.a = 1.0 if i == observation else 0.7
		marker.get_node("Ring").add_theme_stylebox_override("panel", marker.get_theme_stylebox("observation_selected" if i == observation else "observation_idle"))
		get_node("%ObservationChoice" + str(i)).set_pressed_no_signal(i == observation)
