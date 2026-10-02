@tool
extends Node
## Explicit opt-in isolated editor test. Never quits a normal editor session.
const IDS := ["lc_ext_02", "lc_ext_03", "lc_int_01", "lc_int_02", "lc_end_01"]
var checks := 0
var failures := 0
var emitted := 0
var viewport: SubViewport
var tree: SceneTree

func _ready() -> void:
	if not Engine.is_editor_hint() or "--church-editor-test" not in OS.get_cmdline_user_args():
		return
	tree = get_tree()
	viewport = SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	run.call_deferred()

func scene_path(id: String) -> String:
	return "res://scenes/landmarks/lingayen_church/%s/%s.tscn" % ["exterior" if id.begins_with("lc_ext") else "interior", id]

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle(frames: int = 12) -> void:
	for i in frames: await tree.process_frame

func snapshot(panel: Node) -> Array:
	var packed := PackedScene.new()
	check(packed.pack(panel) == OK, "Packable production")
	var state := packed.get_state()
	var result: Array = []
	for i in state.get_node_count():
		var properties: Array = []
		for j in state.get_node_property_count(i):
			properties.append([state.get_node_property_name(i, j), state.get_node_property_value(i, j)])
		result.append([state.get_node_path(i), state.get_node_type(i), properties])
	return result

func check_inert(node: Node) -> void:
	check(node.owner == null, "Generated node unowned: " + str(node.name))
	if node is Control:
		check(node.focus_mode == Control.FOCUS_NONE and node.mouse_filter == Control.MOUSE_FILTER_IGNORE, "No editor input: " + str(node.name))
	if node is BaseButton:
		check(node.get_signal_connection_list("pressed").is_empty(), "No visitor signal wiring")
	check(not node is AudioStreamPlayer and not node is VideoStreamPlayer and not node is Timer, "No editor playback/timer")
	for child in node.get_children(true): check_inert(child)

func assert_view(panel: Control, id: String) -> void:
	var view: Control = panel.get_node(panel.EDITOR_VIEW_NAME)
	check_inert(view)
	check(panel.get_children().filter(func(n): return n.name == panel.EDITOR_VIEW_NAME).size() == 1, "One presentation")
	check(panel._title.text.to_upper() == panel.content.title.to_upper(), id + " title")
	check(panel._subtitle.text == panel.content.subtitle, id + " subtitle")
	check(not panel._open and not panel._closing and panel._panel_tween == null and panel._fade == null, "No runtime lifecycle")
	check(not panel.is_in_group("lingayen_church_narration"), "No runtime narration registration")
	check(panel.get_node("NarrationPlayer").stream == null and not panel.get_node("NarrationPlayer").playing, "Authored audio untouched")
	check(panel._speaker.text == "LISTEN" and not panel._speaker.disabled and not panel._pending.visible, "Idle narration")
	check(panel._sources_button.text == "SOURCES" and panel._close.text == "CLOSE", "Header utilities")
	check(not panel._sources.visible, "Sources initially closed")
	check(emitted == 0, "No runtime signals")
	check(viewport.gui_get_focus_owner() == null, "No visitor focus")
	var bounds := view.get_global_rect().grow(1)
	for control in [panel._title, panel._subtitle, panel._speaker, panel._close, panel._sources_button, panel._information]:
		check(bounds.encloses(control.get_global_rect()), id + " fits " + str(control.name))
	check(panel._title.get_global_rect().end.x <= panel._sources_button.global_position.x + 1, "Header clear")
	if id.begins_with("lc_ext"):
		check(panel._selected == 0 and panel._heading.text == panel.content.concepts[0].heading and panel._body.text == panel.content.concepts[0].body, "Overview resource text")
		check(panel._image.texture != null, "Default photograph")
	else:
		check(panel._heading.text == panel.content.overview_heading and panel._body.text == panel.content.overview_body, "Overview resource text")
	match id:
		"lc_ext_02":
			check(panel._concepts.size() == 3 and panel._image.texture == panel.content.illustration, "Tower markers and photograph")
			check(not panel._detail_holder.visible and not panel._focus_overlay.visible, "Tower overview")
		"lc_ext_03":
			check(panel._concepts.size() == 3 and not panel._documentary.visible and not panel._comparison.visible, "Bell story overview")
		"lc_int_01":
			check(panel.selected_person == 0 and panel._cards.size() == 4, "Unselected portrait wall")
			for i in 4: check(panel._cards[i].portrait.texture == panel.content.people[i].portrait, "Authoritative portrait")
		"lc_int_02":
			check(panel.selected_timeline_state == 0 and panel._points.size() == 8 and panel._reveal == null, "Timeline overview without reveal")
			check(panel._image.texture == panel.content.overview_media and not panel._diagram.visible, "Timeline initial media")
		"lc_end_01":
			check(panel.selected_theme == 0 and panel._cards.size() == 4 and panel._transition == null, "Four-theme overview")
			check(panel._image.texture == panel.content.center_media and panel._synthesis.text == panel.content.synthesis, "Summary resource media and synthesis")

func run() -> void:
	await settle()
	while EditorInterface.get_resource_filesystem().is_scanning(): await tree.process_frame
	for id in IDS:
		for cycle in 3:
			var panel: Control = load(scene_path(id)).instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
			panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
			panel.size = Vector2(1280, 720)
			var before := snapshot(panel)
			var original: Resource = panel.content
			for signal_name in ["opened", "closed", "narration_started", "narration_stopped", "sources_opened", "sources_closed"]:
				panel.connect(signal_name, func(): emitted += 1)
			viewport.add_child(panel)
			await settle()
			for dimensions in [Vector2i(1280,720), Vector2i(960,540), Vector2i(854,480)]:
				viewport.size = dimensions
				panel.size = dimensions
				await settle()
				for repeat in 3:
					panel._refresh_editor_preview()
					await settle()
					assert_view(panel, id)
				check(panel.get_signal_connection_list("resized").size() == 1, "Single resize connection")
				check(not panel.open_hotspot(), "Editor open blocked")
				panel.reset_hotspot()
				panel.toggle_narration()
				panel.open_sources()
				panel.close_sources()
				panel.close_interaction()
				check(not panel._open and not panel.get_node("NarrationPlayer").playing and not panel._sources.visible, "Runtime entry points inert")
				if cycle == 0 and "--capture" in OS.get_cmdline_user_args():
					await RenderingServer.frame_post_draw
					check(viewport.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join(id+"_batch_editor_"+str(dimensions.x)+".png")) == OK, "Editor capture")
			panel.size = Vector2(1280,720)
			await settle()
			check(snapshot(panel) == before, "No authored changes: " + id)
			check(panel.get_script().reload(true) == OK, "Script reload")
			panel._refresh_editor_preview()
			await settle()
			assert_view(panel, id)
			check(panel.content == original and snapshot(panel) == before, "Reload preserves resource and serialization")
			var packed := PackedScene.new()
			packed.pack(panel)
			var saved := OS.get_environment("TEMP").path_join(id+"_batch_roundtrip.tscn")
			check(ResourceSaver.save(packed, saved) == OK, "Save roundtrip")
			check(not FileAccess.get_file_as_string(saved).contains(panel.EDITOR_VIEW_NAME), "No serialized presentation")
			panel.queue_free()
			await settle()
			var reopened: Control = load(saved).instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
			viewport.add_child(reopened)
			await settle()
			assert_view(reopened, id)
			reopened.queue_free()
			await settle()
		print("CHURCH EDITOR completed: ", id)
	# Open actual production scenes directly, reload from disk, then revisit.
	for id in IDS:
		for repeat in 2:
			EditorInterface.open_scene_from_path(scene_path(id))
			if repeat == 1:
				EditorInterface.reload_scene_from_path(scene_path(id))
			EditorInterface.set_main_screen_editor("2D")
			# A hidden isolated editor may stop drawing once the fixture is detached.
			# Keep its actual 2D viewport rendering; do not wait on an absent frame.
			EditorInterface.get_editor_viewport_2d().render_target_update_mode = SubViewport.UPDATE_ALWAYS
			await settle(60)
			var edited: Control = EditorInterface.get_edited_scene_root()
			check(edited.scene_file_path == scene_path(id), "Actual production editor")
			assert_view(edited, id)
			if repeat == 0 and "--capture" in OS.get_cmdline_user_args():
				RenderingServer.force_draw(false)
				check(EditorInterface.get_editor_viewport_2d().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join(id+"_batch_actual_editor.png")) == OK, "Actual editor capture")
			EditorInterface.open_scene_from_path(scene_path("lc_ext_01"))
			await settle()
	print("CHURCH EDITOR: %d checks, %d failures" % [checks, failures])
	tree.quit(1 if failures else 0)
