extends RefCounted
## Capitol-only static shell. Authored nodes and approved Resources stay untouched.
const VIEW_NAME := "_CapitolEditorPresentation"
const BINDINGS := {
	"_title": "Title", "_close": "Close", "_image": "Image",
	"_information": "Information", "_heading": "Heading", "_body": "Body",
	"_takeaway": "Takeaway", "_scroll": "Scroll", "_sources_button": "SourcesButton",
	"_speaker": "Speaker", "_sources": "Sources", "_source_title": "SourceTitle",
	"_source_text": "SourceText", "_source_scroll": "SourceScroll", "_source_close": "SourceClose"
}

static func begin(panel: ConferenceRoomInteraction) -> Control:
	if not Engine.is_editor_hint():
		return null
	var old := panel.get_node_or_null(NodePath(VIEW_NAME))
	if old != null:
		panel.remove_child(old)
		old.queue_free()
	var shell: Control = load("res://scenes/components/conference_room_interaction.tscn").instantiate()
	shell.set_script(null)
	shell.get_node("NarrationPlayer").free()
	shell.name = VIEW_NAME
	panel.add_child(shell)
	shell.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	for path in ["Main", "Sources"]:
		shell.get_node(path).add_theme_stylebox_override("panel", panel.get_node(path).get_theme_stylebox("panel"))
	for property in BINDINGS:
		panel.set(property, shell.find_child(BINDINGS[property], true, false))
	panel._concepts.assign([shell.find_child("PublicInterior", true, false), shell.find_child("OfficialFunction", true, false), shell.find_child("WhyItMatters", true, false)])
	panel.set_process(false)
	panel.set_process_input(false)
	panel.set_process_unhandled_input(false)
	return shell

static func finish(panel: ConferenceRoomInteraction, shell: Control) -> void:
	panel._sources.hide()
	panel._speaker.text = "LISTEN"
	panel._speaker.show()
	panel._speaker.disabled = panel.content.get("narration_stream") == null
	panel._speaker.set_pressed_no_signal(false)
	panel._speaker.accessibility_name = "Listen narration"
	var pending: Label = panel.get("_pending") if "_pending" in panel else null
	if pending != null:
		pending.visible = panel._speaker.disabled
	seal(shell)

static func seal(node: Node) -> void:
	node.owner = null
	node.set_process(false)
	node.set_process_input(false)
	node.set_process_unhandled_input(false)
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.focus_mode = Control.FOCUS_NONE
	for child in node.get_children(true):
		seal(child)

static func resize(panel: Control, shell: Control) -> void:
	if Engine.is_editor_hint() and is_instance_valid(shell):
		shell.size = panel.size if panel.size.x > 0 and panel.size.y > 0 else Vector2(1280, 720)
