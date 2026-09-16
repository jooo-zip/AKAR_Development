extends Control
## Direct child Buttons share one non-modal information panel. Content stays in scenes.

@export var information_panel: PanelContainer
@export var title_label: Label
@export var description_label: Label
@export var close_button: Button

var _selected_marker: Button


func _ready() -> void:
	information_panel.hide()
	close_button.pressed.connect(close_information)
	for child in get_children():
		if child is Button:
			var marker := child as Button
			marker.pressed.connect(_select_marker.bind(marker))
			marker.gui_input.connect(_on_marker_input.bind(marker))


func _on_marker_input(event: InputEvent, marker: Button) -> void:
	if marker.has_focus() and not marker.disabled and event.is_action_pressed(&"interact"):
		marker.accept_event()
		if not event.is_echo():
			_select_marker(marker)


func _select_marker(marker: Button) -> void:
	_selected_marker = marker
	title_label.text = marker.text
	description_label.text = str(marker.get_meta(&"description", ""))
	description_label.visible = not description_label.text.is_empty()
	information_panel.show()
	marker.grab_focus()


func close_information() -> void:
	if not information_panel.visible:
		return
	information_panel.hide()
	if is_instance_valid(_selected_marker) and _selected_marker.is_visible_in_tree() \
			and not _selected_marker.disabled:
		_selected_marker.grab_focus()
	_selected_marker = null


## Connect an introductory popup's opened signal here without stealing its focus.
func dismiss_for_introduction() -> void:
	information_panel.hide()
	_selected_marker = null


func _unhandled_input(event: InputEvent) -> void:
	if information_panel.visible and event.is_action_pressed(&"go_back"):
		var viewport := get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()
		if not event.is_echo():
			close_information()
