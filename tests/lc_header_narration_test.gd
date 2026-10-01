extends SceneTree
## Utility-only revision: real supplied streams, input, modal/state and layout checks.
const IDS := ["lc_ext_01", "lc_ext_02", "lc_ext_03", "lc_int_01", "lc_int_02", "lc_end_01"]
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 8: await process_frame

func finish(panel: Control) -> void:
	for prop in panel.get_property_list():
		if prop.name in ["_fade", "_transition", "_reveal", "_panel_tween"]:
			var tween: Tween = panel.get(prop.name)
			if tween != null and tween.is_valid():
				tween.pause()
				tween.custom_step(1.1)
	await settle()

func press(control: Control, touch: bool = false) -> void:
	var event: InputEvent
	if touch: event = InputEventScreenTouch.new()
	else:
		event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
	event.position = control.get_global_rect().get_center()
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func capture(name: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lc_header_" + name + ".png")) == OK, "Capture " + name)

func bind(panel: Control, id: String, stream: AudioStream) -> void:
	if id == "lc_end_01": panel.content.narration = stream
	else: panel.content.narration_stream = stream
	panel.HeaderUtilities.bind_narration(panel, stream)
	panel._update_speaker()
	panel._sync_focus()

func select_detail(panel: Control, id: String) -> void:
	match id:
		"lc_ext_01": panel.select_section(1)
		"lc_ext_02": panel.set_observation(2)
		"lc_ext_03": panel.set_story_state(2)
		"lc_int_01": panel.set_selected_person(3)
		"lc_int_02": panel.set_timeline_state(6)
		"lc_end_01": panel.set_selected_theme(4)

func snapshot(panel: Control) -> Array:
	var result: Array = [panel._heading.text, panel._body.text, panel._image.texture, panel._takeaway.text]
	for property in ["selected_person", "selected_timeline_state", "selected_theme", "_selected", "_wartime_view"]:
		for prop in panel.get_property_list():
			if prop.name == property: result.append(panel.get(property))
	return result

func check_header(panel: Control, casa: Control) -> void:
	var buttons: Array[Button] = [panel._sources_button, panel._speaker, panel._close]
	var actions: HBoxContainer = panel._sources_button.get_parent()
	check(actions.name == "HeaderActions" and actions.get_children() == buttons, "One SOURCES/LISTEN/CLOSE horizontal group")
	check(panel._sources_button.text == "SOURCES" and panel._close.text == "CLOSE", "Uppercase utility labels")
	check(panel.find_children("*", "Button", true, false).filter(func(b): return b.text == "SOURCES").size() == 1, "Exactly one Sources control")
	check(not panel._information.is_ancestor_of(panel._sources_button), "Old Sources footprint removed from content")
	check(panel._speaker.icon.resource_path == "res://assets/ui/icons/speaker.svg", "Same shared speaker icon")
	var speaker: Button = panel._speaker
	var text_width := speaker.get_theme_font("font").get_string_size(speaker.text, HORIZONTAL_ALIGNMENT_LEFT, -1, speaker.get_theme_font_size("font_size")).x
	check(speaker.size.x - text_width - speaker.get_theme_stylebox("normal").get_minimum_size().x >= 22, "Speaker icon has actual visible width")
	var bounds: Rect2 = panel.get_global_rect().grow(0.6)
	check(bounds.encloses(panel.get_node("Main").get_global_rect()), "No whole-screen overflow")
	check(panel._title.get_global_rect().end.x <= actions.global_position.x, "Title separate from utilities")
	for i in buttons.size():
		var button := buttons[i]
		check(bounds.encloses(button.get_global_rect()), "Header utility unclipped")
		check(button.size.y == 52 and button.size.x >= 48, "Casa Real 52px target height")
		check(is_equal_approx(button.global_position.y, buttons[0].global_position.y), "Equal sibling alignment")
		check(button.get_theme_font_size("font_size") == (16 if panel.size.x < 1100 else 18), "Casa Real responsive font size")
		for style in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
			check(button.get_theme_stylebox(style) == casa._close.get_theme_stylebox(style), "Actual shared Casa Real StyleBox reused: " + style)
		if i < 2: check(button.get_global_rect().end.x <= buttons[i + 1].global_position.x, "No utility overlap")
	for label in panel.find_children("*", "Label", true, false):
		if label.is_visible_in_tree() and (label.text.begins_with("PHOTO:") or label.text.begins_with("SOURCE:")):
			# Labels inside reading scrollers remain intentionally scrollable.
			if not panel._scroll.is_ancestor_of(label) and not panel._sources.is_ancestor_of(label):
				check(bounds.encloses(label.get_global_rect()), "Media credit retained and contained")

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	Input.emulate_mouse_from_touch = true
	var casa: Control = load("res://scenes/landmarks/casa_real/end/cr_end_01.tscn").instantiate()
	root.add_child(casa)
	await settle()
	casa.hide()
	for id in IDS:
		var folder: String = "exterior" if id.contains("ext") else "interior"
		var preview: Control = load("res://scenes/landmarks/lingayen_church/" + folder + "/" + id + "_preview.tscn").instantiate()
		root.add_child(preview)
		current_scene = preview
		await settle()
		var panel: Control = preview.get_node("HotspotFrame").get_child(0)
		panel.content = panel.content.duplicate(false)
		panel.open_hotspot()
		await finish(panel)
		var asset: AudioStream = load("res://assets/landmarks/lingayen_church/audio/" + id + "_narration.ogg")
		check(asset != null and asset.get_length() > 0, "Supplied recording loads: " + id)
		check(panel.find_children("*", "AudioStreamPlayer", true, false).size() == 1, "Reuse exactly one player")
		for dimensions in [Vector2i(1280,720), Vector2i(960,540), Vector2i(854,480)]:
			root.size = dimensions
			await settle()
			panel.reset_hotspot()
			await finish(panel)
			check_header(panel, casa)
			check(not panel._audio.playing and not panel._audio.stream_paused, "No autoplay")
			await capture("after_" + id + "_" + str(dimensions.x))
			# Exercise the saved permanent mapping without injecting a stream.
			check(panel._audio.stream == asset, "Saved resource binds its permanent narration path: " + id)
			check(not panel._speaker.disabled and not panel._pending.visible, "Valid stream enables LISTEN and removes status")
			await press(panel._speaker)
			check(panel._audio.playing and not panel._audio.stream_paused and panel._speaker.text == "PAUSE", "Mouse starts correct narration: " + id)
			check(panel._audio.stream == asset and panel._audio.stream.resource_path.ends_with(id + "_narration.ogg"), "Exact per-hotspot resource path")
			await create_timer(0.12).timeout
			check(panel._audio.get_playback_position() > 0, "Playback clock advances")
			select_detail(panel, id)
			await finish(panel)
			check(panel._audio.playing, "Overall narration survives educational selection, matching Casa Real")
			var selected := snapshot(panel)
			await press(panel._speaker, true)
			check(panel._audio.stream_paused and panel._speaker.text == "RESUME", "Touch pauses")
			var paused_at: float = panel._audio.get_playback_position()
			await create_timer(0.1).timeout
			check(absf(panel._audio.get_playback_position() - paused_at) < 0.1, "Pause preserves position")
			panel._speaker.grab_focus()
			await key(KEY_SPACE)
			check(not panel._audio.stream_paused and panel._speaker.text == "PAUSE", "Space resumes")
			await press(panel._sources_button, true)
			check(panel._sources.visible and snapshot(panel) == selected and panel._audio.playing, "Sources preserves state and ongoing audio")
			await key(KEY_ESCAPE)
			check(not panel._sources.visible and panel._open, "Escape closes Sources first")
			panel._sources_button.grab_focus()
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == panel._speaker, "Tab Sources to Listen")
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == panel._close, "Tab Listen to Close")
			panel._speaker.grab_focus()
			await key(KEY_ENTER)
			check(panel._speaker.text == "RESUME", "Enter pauses")
			await key(KEY_ENTER)
			check(panel._speaker.text == "PAUSE", "Enter resumes")
			await capture("audio_test_" + id + "_" + str(dimensions.x))
			panel._audio.seek(asset.get_length() - 0.08)
			await create_timer(0.3).timeout
			check(not panel._audio.playing and panel._speaker.text == "LISTEN" and not panel._speaker.button_pressed, "Actual completion restores idle")
			await press(panel._speaker)
			await press(panel._close, true)
			check(not panel._audio.playing and not panel._audio.stream_paused, "Close stops immediately")
			await finish(panel)
			panel.open_hotspot()
			await finish(panel)
			check(not panel._audio.playing and panel._speaker.text == "LISTEN", "Reopen stays stopped")
			await press(panel._speaker)
			check(panel._audio.get_playback_position() < 1.0, "Replay begins at zero")
			panel.close_interaction()
			panel.open_hotspot()
			await finish(panel)
			check(not panel._audio.playing and panel._open, "Rapid reopen cancels close and does not resume")
			bind(panel, id, null)
			check(panel._speaker.disabled and panel._pending.visible and not panel._audio.playing, "Null stream safely disables LISTEN")
			check_header(panel, casa)
			bind(panel, id, asset) # Restore after the deliberate missing-stream fallback.
			print("LC HEADER | ", id, " | ", dimensions, " | columns=", panel.get_node("Main/Margin/Layout/Columns").get_global_rect())
		bind(panel, id, asset)
		panel.toggle_narration()
		preview.hide()
		await settle()
		check(not panel._audio.playing, "Parent hide stops narration")
		preview.queue_free()
		await settle()
	# A second Church hotspot must stop an existing narration, even if the host
	# briefly leaves the first panel in the tree during navigation.
	var first: Control = load("res://scenes/landmarks/lingayen_church/interior/lc_int_02.tscn").instantiate()
	var second: Control = load("res://scenes/landmarks/lingayen_church/interior/lc_end_01.tscn").instantiate()
	root.add_child(first)
	root.add_child(second)
	await settle()
	first.open_hotspot()
	first.toggle_narration()
	check(first._audio.playing, "First overlapping hotspot starts")
	second.open_hotspot()
	check(not first._audio.playing, "Opening another Church hotspot stops earlier narration")
	second.toggle_narration()
	first.toggle_narration()
	check(first._audio.playing and not second._audio.playing, "At most one player active across Church panels")
	first.close_interaction()
	first.queue_free()
	second.queue_free()
	await settle()
	casa.queue_free()
	await settle()
	print("LC HEADER: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
