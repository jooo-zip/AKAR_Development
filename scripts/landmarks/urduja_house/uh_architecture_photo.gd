extends "res://scripts/landmarks/urduja_house/uh_phase5_explorer.gd"
## Scene-authored aspect frame maps the ring anchors onto the fitted photograph.
func _ready() -> void:
	super._ready()
	for i in buttons.size():
		var marker: Button = get_node("%Marker" + str(i))
		marker.pressed.connect(select_state.bind(i))
		marker.gui_input.connect(_key.bind(i))
	_sync_markers()
func select_state(index: int) -> void:
	super.select_state(index)
	_sync_markers()
func reset_interaction() -> void:
	super.reset_interaction()
	_sync_markers()
func _sync_markers() -> void:
	for i in content.labels.size():
		var marker: Button = get_node("%Marker" + str(i))
		marker.set_pressed_no_signal(i == selected)
		marker.modulate.a = 1.0 if i == selected else 0.72
