extends "res://tests/lch_header_test.gd"
## Production components exercised without any preview, player, or environment.
var lifecycle_events := Vector2i.ZERO

func production_path(id: String) -> String:
	var folder := "exterior" if id.begins_with("ext") else ("interior" if id.begins_with("int") else "summary")
	return "res://scenes/landmarks/limahong_channel/%s/lch_%s.tscn" % [folder, id]

func content_value(value: Variant) -> Variant:
	if value is Resource:
		if value.get_script() == null:
			return value.resource_path
		var fields := {}
		for property in value.get_property_list():
			if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				fields[property.name] = content_value(value.get(property.name))
		return fields
	if value is Array:
		var items := []
		for item in value: items.append(content_value(item))
		return items
	return value

func node_count(node: Node) -> int:
	var count := 1
	for child in node.get_children(): count += node_count(child)
	return count

func check_owned_children(node: Node, id: String) -> void:
	# Native ScrollContainer internals are intentionally unowned and not serialized.
	for child in node.get_children():
		check(child.owner != null, id + " actual owned node: " + str(child.name))
		check_owned_children(child, id)

func authored_round_trip(id: String, packed: PackedScene) -> void:
	# No _ready/builders execute: these are the actual saved production nodes.
	var authored := packed.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var count := node_count(authored)
	if id != "ext_03":
		check(count >= 45, id + " meaningful persistent production structure")
		check(authored.has_node("Main/Margin/Layout/Header/HeaderUtilityArea/HeaderActions"), id + " authored header")
		check(authored.get_node("%Scroll") is ScrollContainer, id + " authored interpretation scroll")
		check_owned_children(authored, id)
	var resaved := PackedScene.new()
	check(resaved.pack(authored) == OK, id + " editor-state repack")
	var path := OS.get_environment("TEMP").path_join("lch-architecture-" + id + ".tscn")
	check(ResourceSaver.save(resaved, path) == OK, id + " save to isolated temporary scene")
	var reopened: PackedScene = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	check(reopened != null, id + " reopen saved scene")
	var second := reopened.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	check(node_count(second) == count, id + " save/reopen preserves tree without generated branches")
	check(not FileAccess.get_file_as_string(path).contains("EditorPresentation"), id + " no editor-only branch serialized")
	second.free()
	authored.free()

func active_switch(panel, id: String, index: int) -> void:
	match id:
		"ext_01": panel.select_locator(index % 3)
		"ext_02", "ext_03": panel.show_stage(index % (4 if id == "ext_03" else 3))
		"int_01": panel.select_section(index % 2)
		"int_02": panel.select_person(index % 3)
		"int_03": panel.select_stage(index % 3)
		"end_01": panel.select_topic(index % 5)

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	AudioServer.set_bus_mute(0, true)
	for id in IDS:
		var packed: PackedScene = load(production_path(id))
		check(packed != null, id + " production loads")
		authored_round_trip(id, packed)
		var preview: PackedScene = load(production_path(id).replace(".tscn", "_preview.tscn"))
		check(preview != null, id + " isolated preview loads")
		for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
			root.size = dimensions
			for inset in [0.0, 0.05]:
				var host := Control.new()
				root.add_child(host)
				host.position = Vector2(dimensions) * inset
				host.size = Vector2(dimensions) * (1.0 - inset * 2)
				var panel = packed.instantiate()
				var original_content := var_to_str(content_value(panel.content))
				host.add_child(panel)
				panel.opened.connect(func(): lifecycle_events.x += 1)
				panel.closed.connect(func(): lifecycle_events.y += 1)
				await settle()
				var tag := "%s %s inset=%s" % [id, dimensions, inset]
				check(not panel._open and not panel._audio.playing, tag + " initially closed/silent")
				check(panel.open_interaction(), tag + " public opener")
				await settle()
				var initial := state(panel)
				check(panel.position.is_equal_approx(Vector2.ZERO) and panel.size.is_equal_approx(host.size), tag + " ordinary parent-sized Control")
				geometry(panel, tag, false)
				var structural_count := node_count(panel)
				for index in [2, 0, 1, 2, 1]: active_switch(panel, id, index)
				host.size *= 0.95
				await settle()
				host.size /= 0.95
				await settle()
				check(panel.size.is_equal_approx(host.size), tag + " resize during transition")
				panel.toggle_narration()
				check(panel._audio.playing, tag + " approved assigned narration remains available")
				for touch in [false, true]:
					await activate(panel._sources_button, touch)
					check(panel._sources.visible, tag + " mouse/touch Sources")
					await key(KEY_ESCAPE)
					check(panel._open and not panel._sources.visible, tag + " modal Escape hierarchy")
				panel.open_sources()
				var before_reset := lifecycle_events
				panel.reset_interaction()
				await settle()
				check(lifecycle_events == before_reset, tag + " reset does not notify host closure/opening")
				check(panel._open and state(panel) == initial, tag + " active reset restores default")
				check(not panel._sources.visible and not panel._audio.playing, tag + " reset cleans modal/audio")
				check(node_count(panel) == structural_count, tag + " reset creates no extra UI")
				panel._speaker.grab_focus()
				await key(KEY_ENTER)
				check(panel._audio.playing, tag + " keyboard Listen")
				await key(KEY_ESCAPE)
				check(not panel._open and not panel._audio.playing, tag + " Escape closes and stops narration")
				var closed_events := lifecycle_events
				panel.close_interaction()
				panel.reset_interaction()
				check(not panel._open and lifecycle_events == closed_events, tag + " repeated close and closed reset harmless")
				check(panel.open_interaction(), tag + " reusable opener")
				await settle()
				check(state(panel) == initial and not panel._audio.playing, tag + " deterministic reopen")
				check(var_to_str(content_value(panel.content)) == original_content, tag + " authoritative Resource not mutated")
				check(root.size == dimensions and root.content_scale_size == Vector2i.ZERO, tag + " no global Window changes")
				if "--capture" in OS.get_cmdline_user_args():
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lch-architecture-%s-%dx%d-%s.png" % [id, dimensions.x, dimensions.y, inset]))
				panel.close_interaction()
				host.queue_free()
				await settle()
		print("Architecture verified: ", id)
	print("Limahong architecture: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)
