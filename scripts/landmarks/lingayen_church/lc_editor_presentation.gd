extends RefCounted
## Church-only static editor shell. Never initializes a runtime controller.
const VIEW_NAME := "_ChurchEditorPresentation"
const HeaderUtilities = preload("res://scripts/landmarks/lingayen_church/lc_header_utilities.gd")
const BINDINGS := {
	"_title": "Title", "_close": "Close", "_image": "Image",
	"_information": "Information", "_heading": "Heading", "_body": "Body",
	"_takeaway": "Takeaway", "_scroll": "Scroll", "_sources_button": "SourcesButton",
	"_speaker": "Speaker", "_sources": "Sources", "_source_title": "SourceTitle",
	"_source_text": "SourceText", "_source_scroll": "SourceScroll", "_source_close": "SourceClose"
}

static func begin(owner_panel: ConferenceRoomInteraction) -> Control:
	if not Engine.is_editor_hint():
		return null
	var old := owner_panel.get_node_or_null(NodePath(VIEW_NAME))
	if old != null:
		owner_panel.remove_child(old)
		old.queue_free()
	var shell: Control = load("res://scenes/components/conference_room_interaction.tscn").instantiate()
	shell.theme = owner_panel.theme
	shell.get_node("Main/Margin/Layout/Header/Title").add_theme_color_override("font_color", owner_panel.get_node("Main/Margin/Layout/Header/Title").get_theme_color("font_color"))
	shell.set_script(null)
	shell.get_node("NarrationPlayer").free()
	shell.name = VIEW_NAME
	owner_panel.add_child(shell)
	shell.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	for path in ["Main", "Sources"]:
		shell.get_node(path).add_theme_stylebox_override("panel", owner_panel.get_node(path).get_theme_stylebox("panel"))
	for property in BINDINGS:
		owner_panel.set(property, shell.find_child(BINDINGS[property], true, false))
	owner_panel._concepts.assign([shell.find_child("PublicInterior", true, false), shell.find_child("OfficialFunction", true, false), shell.find_child("WhyItMatters", true, false)])
	seal(shell)
	return shell

static func finish(owner_panel: ConferenceRoomInteraction, shell: Control, pending: Label, narration: AudioStream) -> void:
	HeaderUtilities.build_presentation(owner_panel, pending, shell.get_node("Main/Margin/Layout/Header"))
	owner_panel._speaker.text = "LISTEN"
	owner_panel._speaker.disabled = narration == null
	owner_panel._speaker.accessibility_name = "Listen narration"
	pending.text = "Narration pending."
	pending.visible = narration == null
	seal(shell)

static func seal(node: Node) -> void:
	# Include internal scrollbars. The entire branch is unsaved and inert.
	node.owner = null
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.focus_mode = Control.FOCUS_NONE
	for child in node.get_children(true):
		seal(child)

static func resize(owner_panel: Control, shell: Control) -> void:
	if Engine.is_editor_hint():
		shell.size = owner_panel.size if owner_panel.size.x > 0 and owner_panel.size.y > 0 else Vector2(1280, 720)
