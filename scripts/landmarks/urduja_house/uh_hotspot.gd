extends Control
## Urduja composition boundary: shared header and sources, distinct content interactions.
signal opened
signal closed
signal return_to_map_requested
signal skip_requested

@export var revision: Resource
@export var interaction_scene: PackedScene
@export var legacy_content: Resource
var interaction: Control
var sources: PanelContainer
var sources_text: Label
var sources_scroll: ScrollContainer
var sources_button: Button
var listen: Button
var close_button: Button
var source_close: Button
var audio: AudioStreamPlayer
var layout: VBoxContainer
var host: Control
var active: bool = false
var _old_focus: WeakRef
var _source_focus: WeakRef
var _redraw_generation: int = 0
const Presentation = preload("res://scripts/landmarks/urduja_house/uh_legacy_presentation.gd")

func _ready() -> void:
	var style_reference: Control = load("res://scenes/components/conference_room_interaction.tscn").instantiate()
	theme = style_reference.theme
	style_reference.free()
	var panel := PanelContainer.new()
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var border := StyleBoxFlat.new()
	border.bg_color = Color("101c18")
	border.border_color = Color("867951")
	border.set_border_width_all(1)
	border.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", border)
	layout = VBoxContainer.new()
	panel.add_child(layout)
	layout.add_theme_constant_override("separation", 8)
	var header := HBoxContainer.new()
	layout.add_child(header)
	var title := Label.new()
	title.text = revision.title
	title.custom_minimum_size.x = 1
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 26)
	header.add_child(title)
	sources_button = _button(header, "SOURCES", open_sources)
	listen = _button(header, "LISTEN", toggle_narration)
	listen.toggle_mode = true
	close_button = _button(header, "CLOSE", close_interaction)
	var context := HBoxContainer.new()
	layout.add_child(context)
	var subtitle := Label.new()
	subtitle.text = revision.subtitle
	subtitle.custom_minimum_size.x = 1
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subtitle.add_theme_font_size_override("font_size", 18)
	context.add_child(subtitle)
	var pending := Label.new()
	pending.text = "Narration pending." if revision.narration == null else "Development audio"
	pending.add_theme_font_size_override("font_size", 16)
	pending.visible = true
	context.add_child(pending)
	host = Control.new()
	host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(host)
	interaction = interaction_scene.instantiate()
	if legacy_content != null:
		interaction.set("content", legacy_content)
	else:
		interaction.set("content", revision)
	host.add_child(interaction)
	interaction.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	interaction.set_process_unhandled_input(false)
	Presentation.configure(interaction, revision.hotspot_id)
	if interaction.has_signal("return_to_map_requested"):
		interaction.connect("return_to_map_requested", func() -> void:
			get_viewport().set_input_as_handled()
			stop_narration()
			return_to_map_requested.emit())
	if interaction.has_signal("skip_requested"):
		interaction.connect("skip_requested", skip_interaction)
	_build_sources()
	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = revision.narration
	audio.finished.connect(stop_narration)
	listen.disabled = audio.stream == null
	add_to_group("urduja_hotspot_narration")
	resized.connect(_resize)
	visibility_changed.connect(func() -> void:
		if active and not is_visible_in_tree():
			close_interaction())
	_resize()
	hide()

func _button(parent: Node, label: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.accessibility_name = label
	button.custom_minimum_size = Vector2(96, 52)
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _build_sources() -> void:
	sources = PanelContainer.new()
	add_child(sources)
	sources.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	sources.add_child(margin)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	var column := VBoxContainer.new()
	margin.add_child(column)
	sources_scroll = ScrollContainer.new()
	sources_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sources_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(sources_scroll)
	sources_text = Label.new()
	sources_text.custom_minimum_size.x = 1
	sources_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sources_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sources_scroll.add_child(sources_text)
	source_close = _button(column, "CLOSE SOURCES", close_sources)
	sources.hide()

func open_interaction() -> bool:
	if active:
		return true
	var previous := get_viewport().gui_get_focus_owner()
	_old_focus = weakref(previous) if previous else null
	get_tree().call_group("urduja_hotspot_narration", "stop_narration")
	show()
	active = true
	interaction.process_mode = Node.PROCESS_MODE_INHERIT
	Presentation.prepare_open(interaction)
	interaction.open_interaction()
	Presentation.refresh(interaction, revision.hotspot_id)
	_focus_first.call_deferred()
	_redraw_layout.call_deferred()
	opened.emit()
	return true

func close_interaction() -> void:
	if not active:
		return
	get_viewport().set_input_as_handled()
	active = false
	sources.hide()
	interaction.process_mode = Node.PROCESS_MODE_INHERIT
	interaction.close_interaction()
	stop_narration()
	hide()
	if _old_focus != null:
		var previous := _old_focus.get_ref() as Control
		if is_instance_valid(previous) and previous.is_visible_in_tree():
			previous.grab_focus()
	closed.emit()

func skip_interaction() -> void:
	if not active:
		return
	get_viewport().set_input_as_handled()
	active = false
	sources.hide()
	interaction.process_mode = Node.PROCESS_MODE_INHERIT
	interaction.close_interaction()
	stop_narration()
	hide()
	# This signal is the final operation: a future parent may remove the hotspot.
	skip_requested.emit()

func open_sources() -> void:
	if not active or sources.visible:
		return
	var previous := get_viewport().gui_get_focus_owner()
	_source_focus = weakref(previous) if previous else null
	sources_text.text = revision.title + "\n\nHISTORICAL REFERENCES\n" + revision.historical_references + "\n\nMEDIA CREDITS\n" + revision.media_credits
	if legacy_content != null:
		if "source_credit" in legacy_content:
			sources_text.text += "\n\n" + legacy_content.source_credit
		if "events" in legacy_content:
			for entry in legacy_content.events:
				sources_text.text += "\n\n" + entry.event_title + "\n" + entry.date_label + "\n" + entry.participating_institution + "\n" + entry.source_credit
		if "entries" in legacy_content:
			for entry in legacy_content.entries:
				sources_text.text += "\n\n" + entry.date_label + " · " + entry.image_alt_text + "\n" + entry.source_credit
	sources_text.text += "\n\nAPPROVED NARRATION TRANSCRIPT\n" + revision.transcript
	interaction.process_mode = Node.PROCESS_MODE_DISABLED
	sources_scroll.scroll_vertical = 0
	sources.show()
	source_close.grab_focus()

func close_sources() -> void:
	sources.hide()
	interaction.process_mode = Node.PROCESS_MODE_INHERIT
	var previous: Control = _source_focus.get_ref() if _source_focus else null
	if is_instance_valid(previous) and previous.is_visible_in_tree():
		previous.grab_focus()
	else:
		sources_button.grab_focus()

func toggle_narration() -> void:
	if not active or audio.stream == null:
		return
	if audio.playing:
		stop_narration()
	else:
		get_tree().call_group("urduja_hotspot_narration", "stop_narration")
		audio.play(0)
		listen.set_pressed_no_signal(true)
		listen.accessibility_name = "Stop narration"

func stop_narration() -> void:
	if is_instance_valid(audio):
		audio.stop()
	if is_instance_valid(listen):
		listen.set_pressed_no_signal(false)
		listen.accessibility_name = "Play narration" if not listen.disabled else "Narration pending."

func _controls(node: Node, result: Array[Control]) -> void:
	for child in node.get_children():
		if child is Control and not child.is_visible_in_tree():
			continue
		if child is BaseButton and not child.disabled:
			result.append(child)
		elif child is ScrollContainer:
			result.append(child)
		_controls(child, result)

func _focus_first() -> void:
	var controls: Array[Control] = []
	_controls(interaction, controls)
	if not controls.is_empty():
		controls[0].focus_mode = Control.FOCUS_ALL
		controls[0].grab_focus()

func _input(event: InputEvent) -> void:
	if not active or not is_visible_in_tree():
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		get_viewport().set_input_as_handled()
		var controls: Array[Control] = []
		if sources.visible:
			_controls(sources, controls)
		elif interaction is InteractiveArtworkViewer and interaction._detail.visible:
			controls.append(sources_button)
			if not listen.disabled:
				controls.append(listen)
			controls.append(close_button)
			_controls(interaction._detail, controls)
		else:
			_controls(layout, controls)
		if controls.is_empty():
			return
		var current := controls.find(get_viewport().gui_get_focus_owner())
		var next := posmod(current + (-1 if event.shift_pressed else 1), controls.size())
		controls[next].focus_mode = Control.FOCUS_ALL
		controls[next].grab_focus()
	elif event is InputEventKey and event.pressed and not sources.visible and interaction is InteractiveTimeline and event.keycode in [KEY_LEFT, KEY_RIGHT]:
		if get_viewport().gui_get_focus_owner() in interaction._labels:
			get_viewport().set_input_as_handled()
			var index: int = clampi(interaction.get_selected_index() + (-1 if event.keycode == KEY_LEFT else 1), 0, interaction.content.entries.size() - 1)
			interaction.select_milestone(index)
			interaction._labels[index].grab_focus()
	elif event.is_action_pressed("go_back"):
		get_viewport().set_input_as_handled()
		if event.is_echo():
			return
		if sources.visible:
			close_sources()
		elif interaction.has_method("close_subview") and interaction.close_subview():
			pass
		elif interaction is InteractiveArtworkViewer and interaction._detail.visible:
			interaction.close_detail_view()
		else:
			close_interaction()

func _resize() -> void:
	if is_instance_valid(interaction):
		Presentation.resize(interaction, revision.hotspot_id)
		_redraw_layout.call_deferred()

func _redraw_layout() -> void:
	# Container layout is deferred. Refresh canvas commands after it settles;
	# Compatibility can otherwise retain stale clips for the runtime-built header.
	_redraw_generation += 1
	var generation := _redraw_generation
	await get_tree().create_timer(0.12).timeout
	if not is_inside_tree():
		return
	if generation != _redraw_generation:
		return
	for control in find_children("*", "Control", true, false):
		control.force_update_transform()
		control.queue_redraw()

func _exit_tree() -> void:
	stop_narration()
