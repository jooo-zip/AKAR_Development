extends SceneTree
## Cross-hotspot utility contract; existing suites retain content-specific coverage.
const IDS := ["ext_01", "ext_02", "ext_03", "int_01", "int_02", "int_03", "end_01"]
var checks: int = 0
var failures: int = 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 12: await process_frame

func key(code: Key, shift: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.shift_pressed = shift
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func activate(control: Control, touch: bool = false) -> void:
	var event: InputEvent = InputEventScreenTouch.new() if touch else InputEventMouseButton.new()
	if event is InputEventMouseButton: event.button_index = MOUSE_BUTTON_LEFT
	event.position = control.get_global_rect().get_center()
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func state(panel) -> Array:
	var values: Array = []
	for property in ["_selected", "current_stage", "current_person", "current_section", "current_topic", "_locator_index", "_media_index", "contributor_expanded"]:
		if property in panel: values.append(panel.get(property))
	if "_magnifier" in panel: values.append(panel._magnifier.lens_normalized_position)
	values.append(panel._heading.text)
	values.append(panel._body.text)
	return values

func change_content(panel, id: String, index: int) -> void:
	match id:
		"ext_01": panel.select_locator(index % 3)
		"ext_02", "ext_03": panel.show_stage(index % (4 if id == "ext_03" else 3), false)
		"int_01": panel.select_section(index % 2)
		"int_02": panel.select_person(index % 3, false)
		"int_03": panel.select_stage(index % 3, false)
		"end_01": panel.select_topic(index % 5, false)

func geometry(panel, tag: String, pending: bool) -> Array[Rect2]:
	var header = panel._header_utilities
	var buttons: Array[Button] = [panel._sources_button, panel._speaker, panel._close]
	var rects: Array[Rect2] = []
	for i in 3:
		var button := buttons[i]
		rects.append(button.get_global_rect())
		check(button.get_parent() == header.actions and button.get_index() == i, tag + " utility structure/order")
		var narration_label := "RESUME" if panel._audio.stream_paused else ("PAUSE" if panel._audio.playing else "LISTEN")
		check(button.text == ["SOURCES", narration_label, "CLOSE"][i], tag + " exact utility label")
		check(button.size.y >= 48 and button.size.x >= 48, tag + " touch target")
		check(panel.get_global_rect().grow(1).encloses(rects[i]), tag + " utility within parent " + button.name + str(rects[i]))
		check(not panel._title.get_global_rect().intersects(rects[i]), tag + " title/action separation")
		check(is_equal_approx(button.size.y, buttons[0].size.y), tag + " matching button height")
		check(is_equal_approx(rects[i].position.y, rects[0].position.y), tag + " aligned utility row")
		for style in ["normal", "hover", "pressed", "focus", "disabled"]:
			check(button.get_theme_stylebox(style) == buttons[0].get_theme_stylebox(style), tag + " common utility " + style)
		if i > 0: check(rects[i].position.x >= rects[i - 1].end.x, tag + " nonoverlapping left-to-right order")
	check(panel._speaker.icon.resource_path == "res://assets/ui/icons/speaker.svg", tag + " exact shared speaker")
	check(panel._speaker.disabled == pending and panel._speaker.visible, tag + " assigned/pending Listen availability")
	check(header.status.visible == pending and header.status.text == "Narration pending", tag + " status visibility")
	check(header.status.get_global_rect().position.y >= rects[0].end.y, tag + " status beneath actions")
	check(is_equal_approx(header.status.get_global_rect().end.x, rects[2].end.x), tag + " status right aligned")
	check(header.status.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT, tag + " status text right aligned")
	check(not panel._information.is_ancestor_of(panel._sources_button), tag + " no content-area Sources")
	check(panel.find_children("*", "AudioStreamPlayer", true, false).size() == 1, tag + " one audio owner")
	return rects

func capture(panel, tag: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args(): return
	await create_timer(0.45).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lch-global-header-" + tag + ".png"))
	print(tag, " title=", panel._title.get_global_rect(), " header=", panel.get_node("Main/Margin/Layout/Header").get_global_rect(), " columns=", panel.get_node("%Columns").get_global_rect(), " root=", root.size, " main=", panel.get_node("Main").get_global_rect())
	if "_magnifier" in panel: print("Lens size: ", panel._magnifier.lens.size)

func silence() -> AudioStreamWAV:
	var result := AudioStreamWAV.new()
	result.format = AudioStreamWAV.FORMAT_8_BITS
	result.mix_rate = 8000
	var bytes := PackedByteArray()
	bytes.resize(240000)
	result.data = bytes
	return result

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	AudioServer.set_bus_mute(0, true)
	for id in IDS:
		var folder := "exterior" if id.begins_with("ext") else ("interior" if id.begins_with("int") else "summary")
		var preview = load("res://scenes/landmarks/limahong_channel/%s/lch_%s_preview.tscn" % [folder, id]).instantiate()
		root.add_child(preview)
		await settle()
		var panel = preview.get_node("HotspotFrame").get_child(0)
		panel.content = panel.content.duplicate(true)
		var assigned: AudioStream = panel.content.narration_stream
		check(assigned != null and assigned.resource_path == "res://assets/landmarks/limahong_channel/audio/lch_%s_narration.ogg" % id, id + " own resource narration path")
		check(assigned != null and assigned.get_length() > 0, id + " decodable supplied narration")
		for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
			root.size = dimensions
			await settle()
			var tag: String = "%s-%dx%d" % [id, dimensions.x, dimensions.y]
			panel.content.narration_stream = assigned
			check(panel.open_interaction(), tag + " open")
			await settle()
			check(panel._audio.stream == assigned and not panel._audio.playing, tag + " assigned but no autoplay")
			panel.toggle_narration()
			await create_timer(0.06).timeout
			check(panel._audio.playing and panel._audio.stream == assigned, tag + " supplied OGG plays on request")
			panel.toggle_narration()
			check(panel._audio.stream_paused and panel._speaker.text == "RESUME", tag + " standard pause state")
			panel.toggle_narration()
			check(panel._audio.playing and not panel._audio.stream_paused and panel._audio.stream == assigned and panel._speaker.text == "PAUSE", tag + " standard resume state")
			panel.stop_narration()
			geometry(panel, tag, false)
			await capture(panel, tag)
			panel.close_interaction()
			panel.content.narration_stream = null
			panel.open_interaction()
			await settle()
			var pending_rects := geometry(panel, tag + " pending", true)
			panel._sources_button.grab_focus()
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == panel._close, tag + " disabled Listen omitted from traversal")
			await key(KEY_TAB, true)
			check(root.gui_get_focus_owner() == panel._sources_button, tag + " reverse pending traversal")
			if dimensions.x == 854: await capture(panel, tag + "-pending")
			panel.close_interaction()
			# In-memory silence checks playback mechanics without altering supplied audio.
			panel.content.narration_stream = silence()
			panel.open_interaction()
			await settle()
			check(geometry(panel, tag + " assigned fixture", false) == pending_rects, tag + " stable geometry with/without narration")
			panel._sources_button.grab_focus()
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == panel._speaker, tag + " Sources then Listen")
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == panel._close, tag + " Listen then Close")
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() not in [panel._sources_button, panel._speaker, panel._close], tag + " content follows toolbar")
			panel._speaker.grab_focus()
			await key(KEY_ENTER)
			check(panel._audio.playing, tag + " keyboard activates narration")
			await create_timer(0.12).timeout
			var playback: float = panel._audio.get_playback_position()
			for index in [2, 0, 1, 2]: change_content(panel, id, index)
			await settle()
			check(panel._audio.playing and panel._audio.get_playback_position() >= playback, tag + " content changes preserve overall narration")
			var current := state(panel)
			for touch in [false, true]:
				await activate(panel._sources_button, touch)
				check(panel._sources.visible, tag + " mouse/touch Sources")
				await key(KEY_ESCAPE)
				check(panel._open and not panel._sources.visible and state(panel) == current, tag + " Sources Escape preserves state")
				check(panel._audio.playing, tag + " Sources preserves narration")
			panel._sources_button.grab_focus()
			await key(KEY_SPACE)
			check(panel._sources.visible, tag + " Space activates Sources")
			await key(KEY_ESCAPE)
			await key(KEY_ESCAPE)
			check(not panel._open and not panel._audio.playing, tag + " Escape closes/stops narration")
			panel.open_interaction()
			await settle()
			check(not panel._audio.playing and not panel._sources.visible, tag + " reopen silent/overlay closed")
			if id == "end_01": check(panel.current_topic == -1, "Summary reopens NONE")
			await activate(panel._speaker, true)
			check(panel._audio.playing, tag + " touch starts narration")
			await activate(panel._close, true)
			check(not panel._open and not panel._audio.playing, tag + " touch Close stops narration")
			panel.open_interaction()
			await settle()
			await activate(panel._speaker)
			check(panel._audio.playing, tag + " mouse starts narration")
			await activate(panel._close)
			check(not panel._open and not panel._audio.playing, tag + " mouse Close stops narration")
			print("Header verified: ", tag)
		preview.queue_free()
		await settle()
	print("Limahong header: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)
