extends "res://scripts/landmarks/urduja_house/uh_hotspot.gd"
## Scene-authored shell for the seven remaining Phase 5 components.
## Do not call the base UI factory or legacy layout adapter for this component.
func _ready() -> void:
	layout = %MainVBox
	host = %Content
	interaction = host
	sources = %SourcesOverlay
	sources_text = %SourcesText
	sources_scroll = %SourcesScroll
	sources_button = %Sources
	listen = %Listen
	close_button = %Close
	source_close = %CloseSources
	audio = %Narration
	$ContentView.content = revision
	$ContentView.refresh()
	sources_button.pressed.connect(open_sources)
	listen.pressed.connect(toggle_narration)
	close_button.pressed.connect(close_interaction)
	source_close.pressed.connect(close_sources)
	audio.stream = revision.narration
	audio.finished.connect(stop_narration)
	listen.disabled = audio.stream == null
	stop_narration()
	interaction.set_process_unhandled_input(false)
	add_to_group("urduja_hotspot_narration")
	resized.connect(_resize)
	visibility_changed.connect(func() -> void:
		if active and not is_visible_in_tree():
			close_interaction())
	sources.hide()
	hide()

func open_interaction() -> bool:
	if active:
		return true
	var previous := get_viewport().gui_get_focus_owner()
	_old_focus = weakref(previous) if previous else null
	get_tree().call_group("urduja_hotspot_narration", "stop_narration")
	show()
	active = true
	interaction.process_mode = Node.PROCESS_MODE_INHERIT
	interaction.open_interaction()
	_focus_first.call_deferred()
	_redraw_layout.call_deferred()
	opened.emit()
	return true

func _resize() -> void:
	if is_instance_valid(interaction):
		_redraw_layout.call_deferred()

func toggle_narration() -> void:
	super.toggle_narration()
	_update_listen_accessibility()

func stop_narration() -> void:
	super.stop_narration()
	_update_listen_accessibility()

func _update_listen_accessibility() -> void:
	if not is_instance_valid(listen):
		return
	listen.accessibility_name = listen.text
	listen.accessibility_description = "Activate to play narration from the beginning."
	if listen.disabled:
		listen.accessibility_description = "Narration unavailable"
	elif audio.stream_paused:
		listen.accessibility_description = "Activate to resume narration from the paused position."
	elif audio.playing:
		listen.accessibility_description = "Activate to pause narration at the current position."
	listen.tooltip_text = listen.accessibility_description

func reset_interaction() -> void:
	sources.hide()
	stop_narration()
	interaction.process_mode = Node.PROCESS_MODE_INHERIT
	interaction.reset_interaction()

func open_sources() -> void:
	if interaction.has_method("cancel_pointer"):
		interaction.cancel_pointer()
	super.open_sources()
	# These Sources panels contain only relevant historical/media records.
	sources_text.text = revision.title + "\n\nHISTORICAL REFERENCES\n" + revision.historical_references + "\n\nMEDIA CREDITS\n" + revision.media_credits

func _controls(node: Node, result: Array[Control]) -> void:
	for child in node.get_children():
		if child is Control and not child.is_visible_in_tree():
			continue
		if child is BaseButton:
			if not child.disabled:
				result.append(child)
		elif child is ScrollContainer or (child is Control and child.focus_mode == Control.FOCUS_ALL):
			result.append(child)
		_controls(child, result)
