@tool
extends ConferenceRoomInteraction

const HeaderUtilities = preload("res://scripts/landmarks/lingayen_church/lc_header_utilities.gd")
var _header_utilities: RefCounted
## Standalone orientation panel. The future host owns landmark navigation.

signal hotspot_closed

enum Section { ABOUT, HISTORICAL_NAME, PRESENT_ROLE }

const SectionEntry = preload("res://scripts/landmarks/lingayen_church/lc_ext_01_section.gd")
const ChurchContent = preload("res://scripts/landmarks/lingayen_church/lc_ext_01_content.gd")

# LC-EXT-01 visual pilot only. Reference colors are screenshot-derived approximations,
# not recovered main-menu theme tokens. Cream/border tones adapt them for dark panels.
const AKAR_PANEL_DARK := Color("101d19")
const AKAR_BROWN_DARK := Color("6f3317")
const AKAR_BROWN_PRIMARY := Color("9c4a25")
const AKAR_ORANGE_ACCENT := Color("d37148")
const AKAR_CREAM_ACTIVE := Color("e8d5b4")
const AKAR_CREAM_HOVER := Color("f0dfc3")
const AKAR_BORDER_MUTED := Color("8e6c51")
const AKAR_TEXT_PRIMARY := Color("f9f5f0")
const AKAR_TEXT_SECONDARY := Color("d6c5ab")

var _media: VBoxContainer
var _caption: Label
var _formal_name: Label
var _credit: Label
var _pending: Label
var _key_label: Label
var _tabs: HBoxContainer
var _panel_tween: Tween
var _closing: bool = false
var _presentation_root: Control
var _presentation_built := false
const EDITOR_VIEW_NAME := "_LC_EXT_01_EditorPresentation"
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview


func _ready() -> void:
	if Engine.is_editor_hint():
		_refresh_editor_preview.call_deferred()
		return
	_presentation_root = self
	super._ready()
	_ensure_presentation()
	_initialize_runtime()


func _ensure_presentation() -> void:
	if _presentation_built:
		return
	_presentation_built = true
	if not is_instance_valid(_media):
		_media = VBoxContainer.new()
		_caption = Label.new()
		_formal_name = Label.new()
		_credit = Label.new()
		_pending = Label.new()
		_key_label = Label.new()
	var header := _presentation_root.get_node("Main/Margin/Layout/Header")
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	header.move_child(titles, 0)
	_title.reparent(titles)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titles.add_child(_formal_name)
	_formal_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_formal_name.add_theme_font_size_override("font_size", 18)
	_formal_name.add_theme_color_override("font_color", Color(0.76, 0.75, 0.67, 1))
	# Keep the inherited speaker/Close controls and their existing signal wiring.
	var listen_group := VBoxContainer.new()
	listen_group.name = "ListenGroup"
	listen_group.add_theme_constant_override("separation", 4)
	header.add_child(listen_group)
	header.move_child(listen_group, 1)
	_speaker.reparent(listen_group)
	_speaker.custom_minimum_size = Vector2(136, 56)
	_pending.text = "Narration pending."
	_pending.add_theme_font_size_override("font_size", 16)
	_pending.add_theme_color_override("font_color", Color(0.76, 0.75, 0.67, 1))
	_pending.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	listen_group.add_child(_pending)
	header.add_theme_constant_override("separation", 12)
	_close.text = "Close"
	_close.custom_minimum_size = Vector2(80, 56)
	_close.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_media.name = "ChurchMedia"
	_media.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_media.size_flags_stretch_ratio = 0.46
	_information.size_flags_stretch_ratio = 0.54
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_child(_media)
	_presentation_root.get_node("Main/Margin/Layout/Columns").move_child(_media, 0)
	_image.reparent(_media)
	_image.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_media.add_child(_caption)
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.add_theme_font_size_override("font_size", 16)
	_tabs = _presentation_root.get_node("Main/Margin/Layout/Sections")
	_tabs.reparent(_information)
	_information.move_child(_tabs, 0)
	_heading.reparent(_body.get_parent())
	_body.get_parent().move_child(_heading, 0)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_presentation_root.get_node("Main/Margin/Layout/Columns/Information/Meta").hide()
	_key_label.text = "KEY TAKEAWAY"
	_key_label.add_theme_font_size_override("font_size", 16)
	_key_label.add_theme_color_override("font_color", Color("d8c58b"))
	_takeaway.add_theme_color_override("font_color", Color(0.76, 0.75, 0.67, 1))
	_body.get_parent().add_child(_key_label)
	_body.get_parent().move_child(_key_label, 2)
	_information.add_child(_credit)
	_presentation_root.get_node("Main/Margin/Layout/Controls").hide()
	_credit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_credit.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_credit.add_theme_font_size_override("font_size", 14)
	_credit.add_theme_color_override("font_color", Color(0.76, 0.75, 0.67, 1))
	_source_close.custom_minimum_size.y = 56
	for i in _concepts.size():
		_concepts[i].custom_minimum_size = Vector2(48, 56)


func _initialize_runtime() -> void:
	closed.connect(func() -> void: hotspot_closed.emit())
	for i in _concepts.size():
		_concepts[i].gui_input.connect(_tab_input.bind(i))
	_header_utilities = HeaderUtilities.new(self, _pending)
	_apply_pilot_style()
	add_to_group("lingayen_church_narration")
	resized.connect(_resize_layout)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_open_standalone.call_deferred()


func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready():
		return
	# Rebuild only our unowned preview. Never reparent, hide or edit authored nodes.
	# A named branch also survives script hot reload when member references reset.
	var old := get_node_or_null(NodePath(EDITOR_VIEW_NAME))
	if old != null:
		remove_child(old)
		old.queue_free()
	for control in [_media, _caption, _formal_name, _credit, _pending, _key_label]:
		if is_instance_valid(control) and control.get_parent() == null:
			control.free()
	_media = VBoxContainer.new()
	_caption = Label.new()
	_formal_name = Label.new()
	_credit = Label.new()
	_pending = Label.new()
	_key_label = Label.new()
	var shell: Control = load("res://scenes/components/conference_room_interaction.tscn").instantiate()
	shell.set_script(null)
	shell.name = EDITOR_VIEW_NAME
	# No player or runtime controller exists in this presentation-only branch.
	shell.get_node("NarrationPlayer").free()
	_presentation_root = shell
	add_child(shell)
	_clear_editor_owners(shell)
	shell.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	for path in ["Main", "Sources"]:
		shell.get_node(path).add_theme_stylebox_override("panel", get_node(path).get_theme_stylebox("panel"))
	_title = shell.find_child("Title", true, false)
	_close = shell.find_child("Close", true, false)
	_image = shell.find_child("Image", true, false)
	_information = shell.find_child("Information", true, false)
	_heading = shell.find_child("Heading", true, false)
	_body = shell.find_child("Body", true, false)
	_takeaway = shell.find_child("Takeaway", true, false)
	_scroll = shell.find_child("Scroll", true, false)
	_sources_button = shell.find_child("SourcesButton", true, false)
	_speaker = shell.find_child("Speaker", true, false)
	_concepts.assign([shell.find_child("PublicInterior", true, false), shell.find_child("OfficialFunction", true, false), shell.find_child("WhyItMatters", true, false)])
	_sources = shell.find_child("Sources", true, false)
	_source_text = shell.find_child("SourceText", true, false)
	_source_close = shell.find_child("SourceClose", true, false)
	_presentation_built = false
	_ensure_presentation()
	HeaderUtilities.build_presentation(self, _pending, shell.get_node("Main/Margin/Layout/Header"))
	_apply_pilot_style()
	# Show idle availability from the resource without touching narration state.
	_speaker.text = "LISTEN"
	_speaker.disabled = content == null or content.narration_stream == null
	_pending.visible = _speaker.disabled
	if content != null and content.concepts.size() == 3:
		_apply_presentation(Section.ABOUT)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
	# No visitor controls participate in editor input/focus.
	_disable_editor_input(shell)


func _apply_pilot_style() -> void:
	# Duplicate all subresources so no shared component or other hotspot is recolored.
	var pilot_theme := _presentation_root.theme.duplicate(true) as Theme
	_presentation_root.theme = pilot_theme
	var fills := {
		"normal": AKAR_BROWN_PRIMARY, "hover": AKAR_BROWN_DARK,
		"pressed": AKAR_CREAM_ACTIVE, "hover_pressed": AKAR_CREAM_HOVER,
		"disabled": AKAR_PANEL_DARK
	}
	for state in fills:
		# Preserve existing margins and border thicknesses, including disabled fallback.
		var style := _close.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		style.bg_color = fills[state]
		style.border_color = AKAR_BORDER_MUTED if state == "disabled" else AKAR_ORANGE_ACCENT
		pilot_theme.set_stylebox(state, "Button", style)
	var focus := _close.get_theme_stylebox("focus").duplicate() as StyleBoxFlat
	focus.border_color = AKAR_TEXT_PRIMARY
	pilot_theme.set_stylebox("focus", "Button", focus)
	for state in ["font_color", "font_hover_color", "font_focus_color", "icon_normal_color", "icon_hover_color", "icon_focus_color"]:
		pilot_theme.set_color(state, "Button", AKAR_TEXT_PRIMARY)
	for state in ["font_pressed_color", "font_hover_pressed_color", "icon_pressed_color", "icon_hover_pressed_color"]:
		pilot_theme.set_color(state, "Button", AKAR_PANEL_DARK)
	for state in ["font_disabled_color", "icon_disabled_color"]:
		pilot_theme.set_color(state, "Button", AKAR_TEXT_SECONDARY)
	pilot_theme.set_color("font_color", "Label", AKAR_TEXT_PRIMARY)
	for path in ["Main", "Sources"]:
		var panel: PanelContainer = _presentation_root.get_node(path)
		var style := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		style.bg_color = AKAR_PANEL_DARK
		style.border_color = AKAR_BORDER_MUTED
		panel.add_theme_stylebox_override("panel", style)
	for label in [_formal_name, _caption, _credit, _pending, _takeaway]:
		label.add_theme_color_override("font_color", AKAR_TEXT_SECONDARY)
	_title.add_theme_color_override("font_color", AKAR_CREAM_ACTIVE)
	_key_label.add_theme_color_override("font_color", AKAR_ORANGE_ACCENT)


func _clear_editor_owners(node: Node) -> void:
	node.owner = null
	for child in node.get_children():
		_clear_editor_owners(child)


func _disable_editor_input(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.focus_mode = Control.FOCUS_NONE
	for child in node.get_children(true):
		_disable_editor_input(child)


func _open_standalone() -> void:
	if Engine.is_editor_hint():
		return
	if get_tree().current_scene == self:
		open_hotspot()


func open_hotspot() -> bool:
	return open_interaction()


func open_interaction() -> bool:
	if Engine.is_editor_hint():
		return false
	if not is_node_ready() or not content is ChurchContent or content.concepts.size() != 3:
		return false
	for entry in content.concepts:
		if not entry is SectionEntry:
			return false
	if _open and not _closing:
		return true
	_cancel_panel_tween()
	_closing = false
	if not _open and not super.open_interaction():
		return false
	reset_hotspot()
	modulate.a = 0.0
	_panel_tween = create_tween()
	_panel_tween.tween_property(self, "modulate:a", 1.0, 0.18)
	return true


func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	if not is_node_ready() or not content is ChurchContent:
		return
	_cancel_panel_tween()
	_closing = false
	_sources.hide()
	stop_narration()
	select_section(Section.ABOUT, false)
	if _open and not Engine.is_editor_hint():
		_sync_focus()
		_concepts[0].grab_focus()


func select_concept(index: int) -> void:
	if Engine.is_editor_hint():
		return
	select_section(index)


func select_section(index: int, animate: bool = true) -> void:
	if Engine.is_editor_hint():
		return
	if not is_node_ready() or content == null or _sources.visible or _closing:
		return
	_selected = index if index >= Section.ABOUT and index <= Section.PRESENT_ROLE else Section.ABOUT
	_cancel_fade()
	_render()
	if animate and _open:
		_information.modulate.a = 0.65
		_fade = create_tween()
		_fade.tween_property(_information, "modulate:a", 1.0, 0.16)
	concept_changed.emit(_selected)


func _render() -> void:
	if Engine.is_editor_hint():
		return
	_apply_presentation(_selected)
	_scroll.scroll_vertical = 0
	_resize_layout()


func _apply_presentation(index: int) -> void:
	var entry := content.concepts[index] as SectionEntry
	_title.text = content.title.to_upper()
	_formal_name.text = content.formal_name
	_heading.text = entry.heading
	_body.text = entry.body
	_takeaway.text = entry.takeaway
	_takeaway.visible = not entry.takeaway.is_empty()
	_key_label.visible = _takeaway.visible
	_image.texture = entry.image if entry.image != null else content.illustration
	_image.accessibility_name = content.illustration_alt_text
	_caption.text = entry.image_caption
	_caption.visible = not entry.image_caption.is_empty()
	_credit.text = entry.image_credit if not entry.image_credit.is_empty() else content.image_credit
	_source_text.text = entry.heading + "\n\n" + entry.source_credit
	for i in _concepts.size():
		_concepts[i].set_pressed_no_signal(i == index)


func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if _closing:
		return
	super.open_sources()
	# Historical citations only; photo provenance stays below the Sources control.
	var entry := content.concepts[_selected] as SectionEntry
	_source_text.text = entry.heading + "\n\n" + entry.source_credit


func _update_speaker() -> void:
	if Engine.is_editor_hint():
		return
	HeaderUtilities.update_speaker(self, _pending)


func toggle_narration() -> void:
	if Engine.is_editor_hint():
		return
	HeaderUtilities.toggle_narration(self)


func stop_narration() -> void:
	if Engine.is_editor_hint():
		return
	_audio.stream_paused = false
	super.stop_narration()


func _tab_input(event: InputEvent, index: int) -> void:
	if Engine.is_editor_hint():
		return
	if _sources.visible or _closing:
		return
	var step := 0
	if event.is_action_pressed(&"ui_left"):
		step = -1
	elif event.is_action_pressed(&"ui_right"):
		step = 1
	if step != 0:
		get_viewport().set_input_as_handled()
		var target := clampi(index + step, 0, 2)
		select_section(target)
		_concepts[target].grab_focus()


func _resize_layout() -> void:
	if not is_node_ready() or not is_instance_valid(_tabs) or not is_instance_valid(_presentation_root):
		return
	if Engine.is_editor_hint():
		_presentation_root.size = size if size.x > 0 and size.y > 0 else Vector2(1280, 720)
	var compact := _presentation_root.size.x < 1000 or _presentation_root.size.y < 550
	var margin := 8 if compact else 16
	for side in ["left", "top", "right", "bottom"]:
		_presentation_root.get_node("Main/Margin").add_theme_constant_override("margin_" + side, margin)
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_theme_constant_override("separation", 12 if compact else 24)
	_presentation_root.get_node("Main/Margin/Layout").add_theme_constant_override("separation", 4 if compact else 8)
	_information.add_theme_constant_override("separation", 4 if compact else 8)
	_body.get_parent().add_theme_constant_override("separation", 8 if compact else 12)
	_title.add_theme_font_size_override("font_size", 24 if compact else 30)
	_heading.add_theme_font_size_override("font_size", 20 if compact else 24)
	_body.add_theme_font_size_override("font_size", 18 if compact else 20)
	_takeaway.add_theme_font_size_override("font_size", 18)
	_key_label.add_theme_font_size_override("font_size", 14 if compact else 16)
	_tabs.add_theme_constant_override("separation", 4 if compact else 8)
	if content != null:
		for i in _concepts.size():
			var label: String = content.concepts[i].tab_label
			if compact:
				label = label.replace("THE CHURCH", "THE\nCHURCH").replace("HISTORICAL NAME", "HISTORICAL\nNAME").replace("PRESENT ROLE", "PRESENT\nROLE")
			_concepts[i].text = label
			_concepts[i].add_theme_font_size_override("font_size", 16 if compact else 18)
	if _open and not Engine.is_editor_hint():
		_sync_focus()
	if Engine.is_editor_hint():
		HeaderUtilities.resize_presentation(self, _pending, _presentation_root.size.x)
	elif _header_utilities != null:
		_header_utilities.resize()


func close_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	close_interaction()


func close_interaction() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _closing:
		return
	_cancel_fade()
	_cancel_panel_tween()
	stop_narration()
	_closing = true
	_panel_tween = create_tween()
	_panel_tween.tween_property(self, "modulate:a", 0.0, 0.16)
	_panel_tween.tween_callback(_finish_close)


func _finish_close() -> void:
	if Engine.is_editor_hint():
		return
	_panel_tween = null
	_closing = false
	modulate.a = 1.0
	super.close_interaction()


func _cancel_panel_tween() -> void:
	if Engine.is_editor_hint():
		return
	if _panel_tween != null and _panel_tween.is_valid():
		_panel_tween.kill()
	_panel_tween = null
	modulate.a = 1.0


func _visibility_changed() -> void:
	if Engine.is_editor_hint():
		return
	if _open and not is_visible_in_tree():
		_cancel_panel_tween()
		_finish_close()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_panel_tween()
	super._exit_tree()

func _sync_focus() -> void:
	if Engine.is_editor_hint():
		return
	HeaderUtilities.sync_focus(self)


func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		super._unhandled_input(event)
