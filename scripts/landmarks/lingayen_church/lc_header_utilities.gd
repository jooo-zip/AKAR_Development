extends RefCounted
## Church-only adapter for the existing Casa Real / conference-room utilities.
## Buttons retain their signals; the owning hotspot retains its single player.

const SPEAKER = preload("res://assets/ui/icons/speaker.svg")
var panel: ConferenceRoomInteraction
var actions := HBoxContainer.new()
var utility_area := VBoxContainer.new()
var status: Label

func _init(owner_panel: ConferenceRoomInteraction, narration_status: Label) -> void:
	panel = owner_panel
	status = narration_status
	var header: HBoxContainer = panel.get_node("Main/Margin/Layout/Header")
	var old_listen_group := panel._speaker.get_parent()
	utility_area.name = "HeaderUtilityArea"
	utility_area.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(utility_area)
	actions.name = "HeaderActions"
	utility_area.add_child(actions)
	for button in [panel._sources_button, panel._speaker, panel._close]:
		button.reparent(actions)
		button.size_flags_horizontal = Control.SIZE_FILL
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		# Inherit the exact shared theme used by CR-END-01, including disabled.
		for style in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
			button.remove_theme_stylebox_override(style)
		for color in ["font_disabled_color", "icon_disabled_color"]:
			button.remove_theme_color_override(color)
	panel._speaker.icon = SPEAKER
	panel._speaker.expand_icon = true
	panel._speaker.add_theme_constant_override("icon_max_width", 22)
	panel._sources_button.text = "SOURCES"
	panel._close.text = "CLOSE"
	panel._sources_button.accessibility_name = "Sources"
	panel._close.accessibility_name = "Close"
	status.reparent(utility_area)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status.autowrap_mode = TextServer.AUTOWRAP_OFF
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Remove the now-empty group instead of retaining its width or spacing.
	if old_listen_group != header and old_listen_group.get_child_count() == 0:
		old_listen_group.get_parent().remove_child(old_listen_group)
		old_listen_group.queue_free()
	header.remove_theme_constant_override("separation")
	panel.opened.connect(_stop_other_narration)
	resize()

func _stop_other_narration() -> void:
	for other in panel.get_tree().get_nodes_in_group("lingayen_church_narration"):
		if other != panel:
			other.stop_narration()

static func bind_narration(owner_panel: ConferenceRoomInteraction, stream: AudioStream) -> void:
	if owner_panel._audio.stream != stream:
		owner_panel.stop_narration()
		owner_panel._audio.stream = stream

func resize() -> void:
	var compact := panel.size.x < 1100
	var font_size := 16 if compact else 18
	panel._title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel._title.add_theme_font_size_override("font_size", 22 if compact else 28)
	# Long Church titles may wrap above their subtitle at 854px. Tighten only
	# that compact title gap so the documentary image retains its usable height.
	var titles := panel._title.get_parent() as VBoxContainer
	if titles != null:
		titles.add_theme_constant_override("separation", 0 if compact else 4)
	for button in [panel._sources_button, panel._speaker, panel._close]:
		button.custom_minimum_size = Vector2(56 if button == panel._speaker else 48, 52)
		button.add_theme_font_size_override("font_size", font_size)
	# expand_icon excludes the icon from Button's minimum-width calculation.
	# Reserve the shared 22px icon plus theme spacing for every playback label.
	var button := panel._speaker
	var text_width := button.get_theme_font("font").get_string_size("RESUME", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	button.custom_minimum_size.x = ceilf(text_width + 22 + button.get_theme_constant("h_separation") + button.get_theme_stylebox("normal").get_minimum_size().x)
	status.add_theme_font_size_override("font_size", 13)

static func update_speaker(owner_panel: ConferenceRoomInteraction, pending: Label) -> void:
	var player := owner_panel._audio
	var button := owner_panel._speaker
	button.show()
	button.disabled = player.stream == null
	button.text = "RESUME" if player.stream_paused else ("PAUSE" if player.playing else "LISTEN")
	button.set_pressed_no_signal(player.playing and not player.stream_paused)
	button.accessibility_name = button.text.capitalize() + " narration"
	button.tooltip_text = "Narration pending." if player.stream == null else button.accessibility_name
	pending.text = "Narration pending."
	pending.visible = player.stream == null

static func toggle_narration(owner_panel: ConferenceRoomInteraction) -> void:
	if not owner_panel._open or owner_panel._closing or owner_panel._sources.visible or owner_panel._audio.stream == null:
		return
	var player := owner_panel._audio
	if player.stream_paused:
		player.stream_paused = false
	elif player.playing:
		player.stream_paused = true
	else:
		# Only one Church narration may be active, even in overlapping host previews.
		for other in owner_panel.get_tree().get_nodes_in_group("lingayen_church_narration"):
			if other != owner_panel:
				other.stop_narration()
		player.play(0.0)
		owner_panel.narration_started.emit()
	owner_panel._update_speaker()

static func sync_focus(owner_panel: ConferenceRoomInteraction) -> void:
	var previous := owner_panel.get_viewport().gui_get_focus_owner()
	var main: Array[Control] = []
	main.append_array(owner_panel._concepts)
	main.append_array([owner_panel._scroll, owner_panel._sources_button, owner_panel._speaker, owner_panel._close])
	var overlay: Array[Control] = [owner_panel._source_scroll, owner_panel._source_close]
	var active: Array[Control] = []
	for control in main + overlay:
		control.focus_mode = Control.FOCUS_NONE
	for control in (overlay if owner_panel._sources.visible else main):
		if control.is_visible_in_tree() and not (control is BaseButton and control.disabled):
			control.focus_mode = Control.FOCUS_ALL
			active.append(control)
	for i in active.size():
		active[i].focus_next = active[i].get_path_to(active[(i + 1) % active.size()])
		active[i].focus_previous = active[i].get_path_to(active[posmod(i - 1, active.size())])
	if previous in active:
		previous.grab_focus()
	elif not active.is_empty():
		active[0].grab_focus()
