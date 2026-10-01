@tool
extends Node
## Open the companion test scene with --editor; never used by production.
const SCENE := "res://scenes/landmarks/lingayen_church/exterior/lc_ext_01.tscn"
var checks := 0
var failures := 0
var emitted := 0
var root: SubViewport
var _tree: SceneTree

func _ready() -> void:
	if not Engine.is_editor_hint() or "--lc-editor-test" not in OS.get_cmdline_user_args():
		return
	_tree = get_tree()
	root = SubViewport.new()
	root.size = Vector2i(1280, 720)
	root.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(root)
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 12: await _tree.process_frame

func packed_snapshot(panel: Node) -> Array:
	var packed := PackedScene.new()
	check(packed.pack(panel) == OK, "Production scene remains packable")
	var state := packed.get_state()
	var result: Array = []
	for i in state.get_node_count():
		var properties: Array = []
		for j in state.get_node_property_count(i):
			properties.append([state.get_node_property_name(i, j), state.get_node_property_value(i, j)])
		result.append([state.get_node_path(i), state.get_node_type(i), properties])
	return result

func check_unowned(node: Node) -> void:
	check(node.owner == null, "Generated node cannot be serialized: " + str(node.name))
	for child in node.get_children(): check_unowned(child)

func assert_view(panel: Control) -> void:
	var view: Control = panel.get_node(panel.EDITOR_VIEW_NAME)
	check_unowned(view)
	check(panel.get_children().filter(func(n): return n.name == panel.EDITOR_VIEW_NAME).size() == 1, "Exactly one generated presentation")
	check(panel._title.text == panel.content.title.to_upper(), "Resource title shown")
	check(panel._formal_name.text == panel.content.formal_name, "Resource formal name shown")
	var entry = panel.content.concepts[0]
	check(panel._heading.text == entry.heading and panel._body.text == entry.body, "ABOUT heading and body")
	check(panel._takeaway.text == entry.takeaway and panel._key_label.text == "KEY TAKEAWAY", "ABOUT takeaway")
	check(panel._image.texture == panel.content.illustration, "Existing photograph")
	check(panel._caption.text == entry.image_caption and panel._credit.text == panel.content.image_credit, "Caption and credit")
	check(panel._concepts[0].button_pressed and not panel._concepts[1].button_pressed and not panel._concepts[2].button_pressed, "ABOUT selected")
	check(panel._speaker.text == "LISTEN" and not panel._speaker.disabled and not panel._pending.visible, "Idle narration availability only")
	check(panel._sources_button.text == "SOURCES" and panel._close.text == "CLOSE", "Header retained")
	check(panel._sources_button.get_parent().get_children() == [panel._sources_button, panel._speaker, panel._close], "Header sibling order")
	check(not panel._open and not panel._closing and panel._panel_tween == null and panel._fade == null, "No runtime state or tween")
	check(not panel.is_in_group("lingayen_church_narration"), "No narration group registration")
	check(panel.get_node("NarrationPlayer").stream == null and not panel.get_node("NarrationPlayer").playing, "Authored player untouched")
	check(view.find_children("*", "AudioStreamPlayer", true, false).is_empty(), "No preview audio player")
	check(emitted == 0 and (root.gui_get_focus_owner() == null or not panel.is_ancestor_of(root.gui_get_focus_owner())), "No runtime signals or focus")
	var bounds := view.get_global_rect().grow(0.5)
	for control in [panel._title, panel._formal_name, panel._speaker, panel._close, panel._sources_button, panel._credit, panel._image]:
		check(bounds.encloses(control.get_global_rect()), "Visible content fits: " + str(control.name))
	check(panel._title.get_global_rect().end.x <= panel._sources_button.global_position.x, "Title clear of header")
	for control in view.find_children("*", "Control", true, false):
		check(control.focus_mode == Control.FOCUS_NONE and control.mouse_filter == Control.MOUSE_FILTER_IGNORE, "No editor visitor interaction: %s focus=%s mouse=%s" % [control.name, control.focus_mode, control.mouse_filter])

func run() -> void:
	check(Engine.is_editor_hint(), "Test must run in editor mode")
	if not Engine.is_editor_hint():
		_tree.quit(1)
		return
	# Let the editor finish initial import before testing or quitting.
	await settle()
	while EditorInterface.get_resource_filesystem().is_scanning(): await _tree.process_frame
	if "--editor-canvas-only" in OS.get_cmdline_user_args():
		await capture_actual_editor()
		print("LC EDITOR CANVAS: %d checks, %d failures" % [checks, failures])
		_tree.quit(1 if failures else 0)
		return
	for cycle in 3:
		var panel: Control = load(SCENE).instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
		panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		panel.size = Vector2(1280, 720)
		var serialized_before := packed_snapshot(panel)
		var original_content: Resource = panel.content
		for signal_name in ["opened", "closed", "hotspot_closed", "concept_changed", "narration_started", "narration_stopped", "sources_opened", "sources_closed"]:
			if signal_name == "concept_changed": panel.connect(signal_name, func(_i): emitted += 1)
			else: panel.connect(signal_name, func(): emitted += 1)
		root.add_child(panel)
		await settle()
		for dimensions in [Vector2i(1280,720), Vector2i(960,540), Vector2i(854,480)]:
			root.size = dimensions
			panel.size = dimensions
			await settle()
			for repeat in 3:
				panel._refresh_editor_preview()
				await settle()
				assert_view(panel)
			check(panel.get_signal_connection_list("resized").size() == 1, "One resize connection after refresh")
			check(not panel.open_hotspot(), "Runtime open blocked in editor")
			panel.toggle_narration()
			panel.reset_hotspot()
			check(not panel._open and not panel.get_node("NarrationPlayer").playing, "Runtime entry points inert")
			if cycle == 0 and "--capture" in OS.get_cmdline_user_args():
				await RenderingServer.frame_post_draw
				check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lc_ext_01_editor_"+str(dimensions.x)+".png")) == OK, "Editor-mode capture")
		panel.size = Vector2(1280,720)
		await settle()
		check(packed_snapshot(panel) == serialized_before, "No generated nodes, layout or content overrides serialized")
		# Keep-state script reload followed by the explicit refresh tool action.
		var controller: Script = panel.get_script()
		check(controller.reload(true) == OK, "Controller script reload")
		panel._refresh_editor_preview()
		await settle()
		assert_view(panel)
		check(panel.content == original_content, "Original content resource identity retained")
		check(packed_snapshot(panel) == serialized_before, "Serialization unchanged after reload")
		var packed := PackedScene.new()
		packed.pack(panel)
		var saved_path := OS.get_environment("TEMP").path_join("lc_ext_01_editor_roundtrip.tscn")
		check(ResourceSaver.save(packed, saved_path) == OK, "Save roundtrip to TEMP only")
		check(not FileAccess.get_file_as_string(saved_path).contains(panel.EDITOR_VIEW_NAME), "Saved scene excludes generated branch")
		panel.queue_free()
		await settle()
	await capture_actual_editor()
	print("LC EDITOR: %d checks, %d failures" % [checks, failures])
	_tree.quit(1 if failures else 0)

func capture_actual_editor() -> void:
	# Also open the actual production scene through the editor, not just a test instance.
	root.size = Vector2i(1600, 1000)
	EditorInterface.open_scene_from_path(SCENE)
	EditorInterface.set_main_screen_editor("2D")
	for i in 60: await _tree.process_frame
	var edited: Control = EditorInterface.get_edited_scene_root()
	check(edited != null and edited.scene_file_path == SCENE, "Production scene opened in actual editor")
	check(edited.get_node_or_null(edited.EDITOR_VIEW_NAME) != null and edited._title.text == "MEET LINGAYEN CHURCH", "Actual 2D editor shows resource-derived presentation without F6")
	check(not edited._open and not edited.get_node("NarrationPlayer").playing, "Actual editor has no runtime open/audio")
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(EditorInterface.get_editor_viewport_2d().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lc_ext_01_actual_editor_canvas.png")) == OK, "Actual 2D editor viewport capture")
