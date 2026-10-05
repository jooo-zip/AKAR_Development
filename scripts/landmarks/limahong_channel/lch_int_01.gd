extends ConferenceRoomInteraction
const Lifecycle = preload("res://scripts/landmarks/limahong_channel/lch_lifecycle.gd")
const SourcesOverlay = preload("res://scripts/landmarks/limahong_channel/lch_sources_overlay.gd")
const HeaderUtilities = preload("res://scripts/landmarks/limahong_channel/lch_header_utilities.gd")
var _header_utilities: HeaderUtilities
## Embedded statue explorer. The inherited shell owns Sources, audio and Escape.
signal section_changed(index: int)
signal close_requested

enum InfoSection { WHO_WAS_LIMAHONG, WHY_THIS_SITE }

const Magnifier = preload("res://scripts/landmarks/limahong_channel/lch_int_01_magnifier.gd")
const StatueContent = preload("res://scripts/landmarks/limahong_channel/lch_int_01_content.gd")
const GOLD := Color(0.88, 0.80, 0.55)

var current_section: int = InfoSection.WHO_WAS_LIMAHONG
@onready var _explorer: Control = $"Main/Margin/Layout/Columns/StatueExplorer"
@onready var _magnifier: Control = $"Main/Margin/Layout/Columns/StatueExplorer/InspectionLayer"
@onready var _section_buttons: Array[Button] = [$"Main/Margin/Layout/Columns/Information/SectionButtons/PublicInterior", $"Main/Margin/Layout/Columns/Information/SectionButtons/OfficialFunction"]
@onready var _prompt: Label = $"Main/Margin/Layout/Columns/Information/Prompt"
@onready var _status: Label = $"Main/Margin/Layout/Header/HeaderUtilityArea/NarrationStatusSlot/Status"
@onready var _placeholder: Label = $"Main/Margin/Layout/Columns/StatueExplorer/Placeholder"


func _ready() -> void:
	_concepts = _section_buttons
	super._ready()
	_bind_authored_content()
	_magnifier.configure(_image)
	resized.connect(_resize_layout)
	visibility_changed.connect(_visibility_changed)
	_resize_layout()
	_header_utilities = HeaderUtilities.new(self, _status)
	add_child(SourcesOverlay.new(self))

func open_interaction() -> bool:
	var data := content as StatueContent
	if not is_node_ready() or data == null or data.concepts.size() != 2 or data.section_labels.size() != 2 or data.compact_section_labels.size() != 2:
		return false
	if data.default_section < 0 or data.default_section > 1 or data.concepts.has(null):
		return false
	if _open:
		return true
	# The shared opener requires three entries; initialize this two-section variant
	# locally while retaining its rendering, Sources, audio and close lifecycle.
	var previous := get_viewport().gui_get_focus_owner()
	_return_focus = weakref(previous) if previous != null else null
	current_section = data.default_section
	_selected = current_section
	_title.text = data.title
	_image.texture = data.illustration
	_image.accessibility_name = data.illustration_alt_text
	_audio.stream = data.narration_stream
	_audio.stop()
	_update_speaker()
	_sources.hide()
	_cancel_fade()
	_open = true
	show()
	_render()
	_placeholder.visible = content.illustration == null
	_magnifier.reset(data.default_lens_position)
	_resize_layout()
	_sync_focus()
	_section_buttons[current_section].grab_focus()
	opened.emit()
	return true


func select_concept(index: int) -> void:
	select_section(index)


func select_section(section: int) -> void:
	if not _open or _sources.visible or section < 0 or section > 1:
		return
	var old_section := current_section
	current_section = section
	_selected = section
	_render()
	if old_section != current_section:
		section_changed.emit(current_section)
		concept_changed.emit(current_section)


func _resize_layout() -> void:
	if _explorer == null:
		return
	var compact := size.x < 900
	_explorer.size_flags_stretch_ratio = 1.32 if compact else 1.78
	%Columns.add_theme_constant_override("separation", 12 if compact else 20)
	var padding := 10 if compact else 16
	for side in ["left", "top", "right", "bottom"]:
		$Main/Margin.add_theme_constant_override("margin_" + side, padding)
	_title.add_theme_font_size_override("font_size", 22 if compact else 28)
	_heading.add_theme_font_size_override("font_size", 22 if compact else 26)
	_body.add_theme_font_size_override("font_size", 20 if compact else 22)
	_information.add_theme_constant_override("separation", 10 if compact else 16)
	var data := content as StatueContent
	for i in _section_buttons.size():
		_section_buttons[i].text = data.compact_section_labels[i] if compact else data.section_labels[i]


func _update_speaker() -> void:
	super._update_speaker()
	_speaker.show()
	_speaker.disabled = _audio.stream == null
	if _status != null:
		_status.visible = _audio.stream == null
	if _header_utilities != null: _header_utilities.refresh()

func open_sources() -> void:
	if _open:
		_magnifier.set_interaction_enabled(false)
	super.open_sources()


func close_sources() -> void:
	super.close_sources()
	if _open:
		_magnifier.set_interaction_enabled(true)


func _sync_focus() -> void:
	var controls: Array[Control] = []
	controls.append_array(_section_buttons)
	controls.append_array([_magnifier.lens, _scroll])
	HeaderUtilities.sync_focus(self, controls)

func close_interaction() -> void:
	if not _open:
		return
	_magnifier.stop()
	super.close_interaction()
	close_requested.emit()


func _visibility_changed() -> void:
	if _open and not is_visible_in_tree():
		close_interaction()

func _bind_authored_content() -> void:
	# Resources remain the only authority for interpretation copy.
	get_node("Main/Margin/Layout/Columns/Information/Prompt").text = content.prompt
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/Body").text = content.concepts[0].body
	get_node("Main/Margin/Layout/Columns/Information/Scroll/Text/Heading").text = content.concepts[0].heading
	get_node("Main/Margin/Layout/Columns/Information/SectionButtons/OfficialFunction").text = content.concepts[1].heading
	get_node("Main/Margin/Layout/Header/TitleArea/Subtitle/Label0").text = content.hotspot_id
	get_node("Main/Margin/Layout/Header/TitleArea/Title").text = content.title


func reset_interaction() -> void:
	Lifecycle.reset(self)
