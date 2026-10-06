extends RefCounted
## Limahong-only utility toolbar. Existing buttons retain their signals and audio owner.
const SPEAKER = preload("res://assets/ui/icons/speaker.svg")
var panel: ConferenceRoomInteraction
var actions: HBoxContainer
var utility_area: VBoxContainer
var title_area: VBoxContainer
var status_slot: Control
var status: Label
var _styles: Dictionary = {}

func _init(owner_panel: ConferenceRoomInteraction, narration_status: Label, context: Control = null) -> void:
	panel = owner_panel
	status = narration_status
	var header: HBoxContainer = panel.get_node("Main/Margin/Layout/Header")
	if header.has_node("HeaderUtilityArea"):
		title_area = header.get_node("TitleArea")
		utility_area = header.get_node("HeaderUtilityArea")
		actions = utility_area.get_node("HeaderActions")
		status_slot = utility_area.get_node("NarrationStatusSlot")
	else:
		_build_legacy_header(header, context)
	for state in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
		_styles[state] = panel.get_theme_stylebox(state, "Button").duplicate()
	var disabled: StyleBoxFlat = _styles.normal.duplicate()
	disabled.bg_color = Color("1f2621")
	disabled.border_color = Color("666653")
	_styles.disabled = disabled
	panel.resized.connect(resize)
	resize()
	refresh()

func _build_legacy_header(header: HBoxContainer, context: Control) -> void:
	# Accepted EXT-03 exception: preserve its tested runtime shell.
	actions = HBoxContainer.new()
	utility_area = VBoxContainer.new()
	title_area = VBoxContainer.new()
	status_slot = Control.new()
	var old_titles := panel._title.get_parent()
	title_area.name = "TitleArea"
	title_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_area.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_area.add_theme_constant_override("separation", 2)
	header.add_child(title_area)
	header.move_child(title_area, 0)
	if old_titles == header:
		panel._title.reparent(title_area)
	else:
		old_titles.reparent(title_area)
	utility_area.name = "HeaderUtilityArea"
	utility_area.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	utility_area.add_theme_constant_override("separation", 2)
	header.add_child(utility_area)
	actions.name = "HeaderActions"
	utility_area.add_child(actions)
	for button in [panel._sources_button, panel._speaker, panel._close]:
		button.reparent(actions)
		button.size_flags_horizontal = Control.SIZE_FILL
		button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		button.expand_icon = true
	panel._speaker.icon = SPEAKER
	status_slot.name = "NarrationStatusSlot"
	utility_area.add_child(status_slot)
	status.reparent(status_slot)
	status.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status.autowrap_mode = TextServer.AUTOWRAP_OFF
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status.add_theme_color_override("font_color", Color("b9b5a4"))
	if context != null:
		context.reparent(title_area)
	elif old_titles == header:
		var code := Label.new()
		code.text = panel.content.hotspot_id
		code.add_theme_font_size_override("font_size", 12)
		code.add_theme_color_override("font_color", Color("d8c58b"))
		title_area.add_child(code)
	# EXT-01's original ListenGroup is now empty; it must not reserve header width.
	for child in header.get_children():
		if child != title_area and child != utility_area and child is Control:
			child.hide()

func resize() -> void:
	var small := panel.size.x < 1050
	var font_size := 16 if small else 18
	var height := 48 if small else 56
	var header: HBoxContainer = utility_area.get_parent()
	header.add_theme_constant_override("separation", 10 if small else 20)
	actions.add_theme_constant_override("separation", 4 if small else 8)
	status_slot.custom_minimum_size.y = 16 if small else 18
	status.add_theme_font_size_override("font_size", 12 if small else 13)
	panel._title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel._title.add_theme_font_size_override("font_size", 18 if small else 26)
	var buttons: Array[Button] = [panel._sources_button, panel._speaker, panel._close]
	var widths := [92, 112, 80] if small else [110, 136, 100]
	for style_name in _styles:
		var style: StyleBoxFlat = _styles[style_name]
		if style_name != "focus":
			style.content_margin_left = 8 if small else 12
			style.content_margin_right = 8 if small else 12
	for i in buttons.size():
		var button := buttons[i]
		button.custom_minimum_size = Vector2(widths[i], height)
		button.add_theme_font_size_override("font_size", font_size)
		button.add_theme_constant_override("icon_max_width", 20 if small else 24)
		for state in _styles: button.add_theme_stylebox_override(state, _styles[state])
		for color_name in ["font_color", "font_hover_color", "font_focus_color"]:
			button.add_theme_color_override(color_name, Color("f7f5eb"))
		button.add_theme_color_override("font_disabled_color", Color("aaa898"))
		button.add_theme_color_override("icon_disabled_color", Color("aaa898"))

func refresh() -> void:
	panel._sources_button.text = "SOURCES"
	panel._speaker.text = "RESUME" if panel._audio.stream_paused else ("PAUSE" if panel._audio.playing else "LISTEN")
	panel._close.text = "CLOSE"
	panel._speaker.show()
	panel._speaker.disabled = panel._audio.stream == null
	status.text = "Narration pending"
	status.visible = panel._audio.stream == null

static func sync_focus(owner_panel: ConferenceRoomInteraction, content_controls: Array[Control]) -> void:
	var previous := owner_panel.get_viewport().gui_get_focus_owner()
	var main: Array[Control] = [owner_panel._sources_button, owner_panel._speaker, owner_panel._close]
	main.append_array(content_controls)
	var overlay: Array[Control] = [owner_panel._source_scroll, owner_panel._source_close]
	var active: Array[Control] = []
	for control in main + overlay: control.focus_mode = Control.FOCUS_NONE
	for control in (overlay if owner_panel._sources.visible else main):
		if control.is_visible_in_tree() and not (control is BaseButton and control.disabled):
			control.focus_mode = Control.FOCUS_ALL
			active.append(control)
	for i in active.size():
		active[i].focus_next = active[i].get_path_to(active[(i + 1) % active.size()])
		active[i].focus_previous = active[i].get_path_to(active[posmod(i - 1, active.size())])
	if previous in active: previous.grab_focus()
	elif not active.is_empty(): active[0].grab_focus()
