@tool
extends ConferenceRoomInteraction

const EditorPresentation = preload("res://scripts/landmarks/casa_real/cr_editor_presentation.gd")
const EDITOR_VIEW_NAME := EditorPresentation.VIEW_NAME
var _presentation_root: Control
@export_tool_button("Refresh Editor Preview", "Reload") var refresh_editor_preview: Callable = _refresh_editor_preview

## Standalone interpretation: one building, three directly selectable identities.
## The inherited legacy _selected field is unused; current_state is authoritative.

enum IdentityState { ROYAL_HOUSE, GOVERNMENT_CENTER, BANAAN_TODAY }
const IdentityEntry = preload("res://scripts/landmarks/casa_real/cr_ext_01_identity.gd")

var current_state: IdentityState = IdentityState.ROYAL_HOUSE
var _subtitle: Label
var _key: Label
var _selectors: BoxContainer
var _interpretation: VBoxContainer
var _transition: Tween
var _reveal: Tween


func _ready() -> void:
	if Engine.is_editor_hint():
		_refresh_editor_preview.call_deferred()
		return
	_presentation_root = self
	super._ready()
	_build_presentation()
	resized.connect(_resize_layout)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_open_standalone.call_deferred()

func _build_presentation() -> void:
	_subtitle = Label.new()
	_key = Label.new()
	_selectors = BoxContainer.new()
	_interpretation = VBoxContainer.new()
	var header := _presentation_root.get_node("Main/Margin/Layout/Header")
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(titles)
	header.move_child(titles, 0)
	_title.reparent(titles)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titles.add_child(_subtitle)
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subtitle.add_theme_color_override("font_color", Color("c2bfae"))
	_sources_button.reparent(header)
	_speaker.reparent(header)
	header.move_child(_close, header.get_child_count() - 1)
	for button in [_sources_button, _speaker, _close]:
		button.custom_minimum_size = Vector2(108, 56)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_sources_button.text = "SOURCES"
	_close.text = "CLOSE"
	_speaker.expand_icon = true
	_speaker.add_theme_constant_override("icon_max_width", 24)
	_presentation_root.get_node("Main/Margin/Layout/Controls").hide()
	_presentation_root.get_node("Main/Margin/Layout/Sections").hide()
	_presentation_root.get_node("Main/Margin/Layout/Columns/Information/Meta").hide()
	_scroll.hide()
	_selectors.name = "IdentitySelectors"
	_selectors.vertical = true
	_information.add_child(_selectors)
	_information.move_child(_selectors, 0)
	for i in _concepts.size():
		var button := _concepts[i]
		button.reparent(_selectors)
		button.custom_minimum_size = Vector2(48, 60)
		if not Engine.is_editor_hint():
			button.gui_input.connect(_selector_input.bind(i))
	_interpretation.name = "Interpretation"
	_interpretation.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_information.add_child(_interpretation)
	_interpretation.add_child(_key)
	_key.add_theme_color_override("font_color", Color("d8c58b"))
	_key.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_heading.reparent(_interpretation)
	_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.reparent(_interpretation)
	_takeaway.reparent(_presentation_root.get_node("Main/Margin/Layout"))
	_image.size_flags_stretch_ratio = 0.59
	_information.size_flags_stretch_ratio = 0.41
	_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_source_close.custom_minimum_size.y = 56
	_source_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _open_standalone() -> void:
	if Engine.is_editor_hint():
		return
	if get_tree().current_scene == self:
		open_hotspot()


func open_hotspot() -> bool:
	if Engine.is_editor_hint():
		return false
	return open_interaction()


func open_interaction() -> bool:
	if Engine.is_editor_hint():
		return false
	if not is_node_ready() or content == null or content.concepts.size() != 3:
		return false
	for entry in content.concepts:
		if not entry is IdentityEntry:
			return false
	if _open:
		return true
	current_state = IdentityState.ROYAL_HOUSE
	if not super.open_interaction():
		return false
	reset_hotspot()
	modulate.a = 0.0
	_image.modulate.a = 0.0
	_reveal = create_tween().set_parallel(true)
	_reveal.tween_property(self, "modulate:a", 1.0, 0.22)
	_reveal.tween_property(_image, "modulate:a", 1.0, 0.30).set_delay(0.15)
	_reveal.chain().tween_callback(func() -> void: _reveal = null)
	return true


func reset_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	if not is_node_ready():
		return
	_cancel_animations()
	_sources.hide()
	_source_scroll.scroll_vertical = 0
	stop_narration()
	current_state = IdentityState.ROYAL_HOUSE
	_render()
	_sync_focus()
	if _open:
		_concepts[0].grab_focus()


func select_concept(index: int) -> void:
	if Engine.is_editor_hint():
		return
	select_state(index as IdentityState)


func get_selected_concept() -> int:
	return current_state


func select_state(new_state: IdentityState) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible or new_state < 0 or new_state > IdentityState.BANAAN_TODAY:
		return
	_cancel_transition()
	current_state = new_state
	_update_selection()
	_transition = create_tween()
	_transition.tween_property(_interpretation, "modulate:a", 0.0, 0.13)
	# Reads the authoritative state, never a captured old identity.
	_transition.tween_callback(_render)
	_transition.tween_property(_interpretation, "modulate:a", 1.0, 0.18)
	_transition.tween_callback(func() -> void: _transition = null)
	concept_changed.emit(current_state)


func _update_selection() -> void:
	for i in _concepts.size():
		_concepts[i].set_pressed_no_signal(i == current_state)
		_concepts[i].text = (content.concepts[i] as IdentityEntry).selector_label


func _render() -> void:
	var entry := content.concepts[current_state] as IdentityEntry
	_title.text = content.title
	_subtitle.text = content.prompt
	_key.text = entry.key_label
	_heading.text = entry.heading
	_body.text = entry.body
	_takeaway.text = content.learning_takeaway
	_takeaway.show()
	_update_selection()


func open_sources() -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible:
		return
	_cancel_transition()
	_render()
	# Reuse the shared overlay and lifecycle without its legacy selection index.
	_source_title.text = "Sources"
	_source_text.text = content.title + "\n\n" + content.source_credit
	_source_scroll.scroll_vertical = 0
	_sources.show()
	_sync_focus()
	_source_close.grab_focus()
	sources_opened.emit()


func _sync_focus() -> void:
	if Engine.is_editor_hint():
		return
	var main: Array[Control] = []
	main.append_array(_concepts)
	main.append_array([_sources_button, _speaker, _close])
	var overlay: Array[Control] = [_source_scroll, _source_close]
	for control in main + overlay + [_scroll]:
		control.focus_mode = Control.FOCUS_NONE
	var active: Array[Control] = overlay if _sources.visible else main
	for i in active.size():
		active[i].focus_mode = Control.FOCUS_ALL
		active[i].focus_next = active[i].get_path_to(active[(i + 1) % active.size()])
		active[i].focus_previous = active[i].get_path_to(active[posmod(i - 1, active.size())])


func _selector_input(event: InputEvent, index: int) -> void:
	if Engine.is_editor_hint():
		return
	if not _open or _sources.visible:
		return
	var step := 0
	if event.is_action_pressed(&"ui_left") or event.is_action_pressed(&"ui_up"):
		step = -1
	elif event.is_action_pressed(&"ui_right") or event.is_action_pressed(&"ui_down"):
		step = 1
	if step != 0:
		get_viewport().set_input_as_handled()
		_concepts[posmod(index + step, 3)].grab_focus()
	elif event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_SPACE]:
		# Space is explicit because Godot's ui_accept mapping may omit it.
		get_viewport().set_input_as_handled()
		if not event.echo:
			select_state(index as IdentityState)


func _update_speaker() -> void:
	if Engine.is_editor_hint():
		return
	super._update_speaker()
	_speaker.text = "STOP" if _audio.playing else "LISTEN"


func stop_narration() -> void:
	if Engine.is_editor_hint():
		return
	_audio.stream_paused = false
	super.stop_narration()


func _resize_layout() -> void:
	if Engine.is_editor_hint():
		EditorPresentation.resize(self, _presentation_root)
	if not is_node_ready():
		return
	# The root remains a host-sized overlay; only its visible panel is inset.
	var inset := 0.02 if size.x < 900 else 0.05
	var main: PanelContainer = _presentation_root.get_node("Main")
	main.set_anchor(SIDE_LEFT, inset, true)
	main.set_anchor(SIDE_TOP, inset, true)
	main.set_anchor(SIDE_RIGHT, 1.0 - inset, true)
	main.set_anchor(SIDE_BOTTOM, 1.0 - inset, true)
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		main.set_offset(side, 0.0)
	var available := size * (1.0 - 2.0 * inset)
	var compact := available.x < 1000 or available.y < 600
	var layout := _presentation_root.get_node("Main/Margin/Layout")
	var parent: Node = layout if compact else _information
	if _selectors.get_parent() != parent:
		_selectors.reparent(parent)
		parent.move_child(_selectors, 1 if compact else 0)
		# Relative focus paths change when the responsive selector row moves.
		_sync_focus()
	_selectors.vertical = not compact
	for side in ["left", "top", "right", "bottom"]:
		_presentation_root.get_node("Main/Margin").add_theme_constant_override("margin_" + side, 8 if compact else 16)
	layout.add_theme_constant_override("separation", 8 if compact else 12)
	_presentation_root.get_node("Main/Margin/Layout/Columns").add_theme_constant_override("separation", 18 if compact else 28)
	_information.add_theme_constant_override("separation", 8 if compact else 12)
	_interpretation.add_theme_constant_override("separation", 8)
	_selectors.add_theme_constant_override("separation", 8)
	for button in _concepts:
		button.custom_minimum_size.y = 56 if compact else 60
		button.add_theme_font_size_override("font_size", 17 if compact else 20)
	_title.add_theme_font_size_override("font_size", 26 if compact else 32)
	_subtitle.add_theme_font_size_override("font_size", 18 if compact else 20)
	_key.add_theme_font_size_override("font_size", 16 if compact else 18)
	_heading.add_theme_font_size_override("font_size", 22 if compact else 28)
	_body.add_theme_font_size_override("font_size", 18 if compact else 22)
	_takeaway.add_theme_font_size_override("font_size", 17 if compact else 20)
	_source_text.add_theme_font_size_override("font_size", 18 if compact else 22)


func _cancel_transition() -> void:
	if Engine.is_editor_hint():
		return
	if _transition != null and _transition.is_valid():
		_transition.kill()
	_transition = null
	_interpretation.modulate.a = 1.0


func _cancel_animations() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_transition()
	_cancel_fade()
	if _reveal != null and _reveal.is_valid():
		_reveal.kill()
	_reveal = null
	modulate.a = 1.0
	if is_instance_valid(_image):
		_image.modulate.a = 1.0


func close_hotspot() -> void:
	if Engine.is_editor_hint():
		return
	close_interaction()


func close_interaction() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_animations()
	super.close_interaction()


func _visibility_changed() -> void:
	if Engine.is_editor_hint():
		return
	if _open and not is_visible_in_tree():
		close_interaction()


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	_cancel_animations()
	super._exit_tree()

func close_sources() -> void:
	if not Engine.is_editor_hint():
		super.close_sources()

func toggle_narration() -> void:
	if not Engine.is_editor_hint():
		super.toggle_narration()

func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		super._unhandled_input(event)

func _refresh_editor_preview() -> void:
	if not Engine.is_editor_hint() or not is_node_ready() or content == null:
		return
	_presentation_root = EditorPresentation.begin(self)
	_build_presentation()
	current_state = IdentityState.ROYAL_HOUSE
	_image.texture = content.illustration
	_image.accessibility_name = content.illustration_alt_text
	_render()
	EditorPresentation.finish(self, _presentation_root)
	if not resized.is_connected(_resize_layout):
		resized.connect(_resize_layout)
	_resize_layout()
