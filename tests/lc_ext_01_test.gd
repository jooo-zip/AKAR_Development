extends SceneTree
## Real logical viewport sizes and dispatched input, following the Limahong harness.

var failures: int = 0
var close_count: int = 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 6:
		await process_frame

func key(code: Key, shift: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	event.shift_pressed = shift
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func press(control: Control, touchscreen: bool = false) -> void:
	var event: InputEvent
	if touchscreen:
		event = InputEventScreenTouch.new()
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

func finish(panel: Control) -> void:
	for tween in [panel._panel_tween, panel._fade]:
		if tween != null and tween.is_valid():
			tween.pause()
			tween.custom_step(1.0)
	await settle()

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	root.content_scale_size = Vector2i(1280, 720)
	var preview = load("res://scenes/landmarks/lingayen_church/exterior/lc_ext_01_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	check(root.content_scale_size == Vector2i.ZERO, "F6 uses real responsive canvas sizes")
	var panel = preview.get_node("HotspotFrame/ChurchInteraction")
	var trigger: Button = preview.get_node("Margin/Layout/OpenArtwork")
	panel.hotspot_closed.connect(func(): close_count += 1)
	check(not panel.visible and not panel._open, "Preview initially closed")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		trigger.grab_focus()
		var preview_title: Label = preview.get_node("Margin/Layout/Header")
		var preview_note: Label = preview.get_node("Margin/Layout/DevelopmentNote")
		check(not panel.visible and preview.get_node("Margin").visible, "Neutral preview before launch")
		check(not preview.has_node("Exterior"), "No preview-background photograph")
		check(preview_title.text == "Meet Lingayen Church", "Preview title")
		check(preview_note.text == "DEVELOPMENT PREVIEW · LC-EXT-01\nExplore the church's identity, historical name and present-day role\nInset parent frame · No master landmark integration", "Exact preview label, description and note")
		check(trigger.text == "Meet Lingayen Church" and trigger.size.y >= 64 and trigger.size.x >= 480, "Large shared launcher without OPEN prefix")
		for control in [preview_title, preview_note, trigger]:
			check(control.is_visible_in_tree(), "Preview control visible")
			check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(control.get_global_rect()), "Preview content within viewport")
			check(absf(control.get_global_rect().get_center().x - dimensions.x * 0.5) <= 1.0, "Centered preview hierarchy")
		check(preview_title.get_global_rect().end.y <= preview_note.global_position.y and preview_note.get_global_rect().end.y <= trigger.global_position.y, "Preview text and launcher do not overlap")
		check(preview.find_children("*", "ScrollContainer", true, false).all(func(node): return panel.is_ancestor_of(node)), "No whole-preview scrolling")
		if "--capture" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lc_ext_01_%s_preview.png" % dimensions.x))
		if dimensions.x == 854:
			await key(KEY_ENTER)
		else:
			await press(trigger, dimensions.x == 960)
		await finish(panel)
		check(panel._open and panel.get_selected_concept() == 0, "Trigger opens About")
		check(panel._speaker.visible and panel._speaker.disabled == (panel._audio.stream == null) and panel._speaker.text == "LISTEN", "Disabled visible LISTEN")
		check(panel._pending.text == "Narration pending." and panel._pending.visible == (panel._audio.stream == null), "Pending status")
		check(panel._speaker.icon == load("res://assets/ui/icons/speaker.svg"), "Shared speaker resource")
		check(panel._audio.stream == panel.content.narration_stream and not panel._audio.playing, "No narration assigned or autoplay")
		check(panel._image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Aspect-fit photo")
		check(panel._image.texture.get_size() == Vector2(4080, 3072), "Supplied photo dimensions")
		check(panel._credit.text == "PHOTO: AKAR Research Team, 2026", "Researcher-supplied photo attribution")
		check(panel._credit.get_line_count() == 1 and panel.get_global_rect().encloses(panel._credit.get_global_rect()), "Photo credit fits without clipping")
		check(preview.get_node("Background").color.is_equal_approx(Color(0.16, 0.18, 0.2, 1)), "Limahong gray viewport")
		check(not preview.get_node("Margin").visible and not trigger.is_visible_in_tree(), "Open panel has unobstructed gray margins")
		check(panel.size.is_equal_approx(Vector2(dimensions) * 0.9), "Limahong five-percent inset")
		var border: StyleBoxFlat = panel.get_node("Main").get_theme_stylebox("panel")
		check(border.border_width_left == 2 and border.border_color.is_equal_approx(Color(0.46, 0.40, 0.25, 1)), "Shared heritage border")
		var header: Control = panel.get_node("Main/Margin/Layout/Header")
		check(header.is_ancestor_of(panel._speaker) and header.is_ancestor_of(panel._pending), "Listen and pending status in header")
		check(not panel._pending.visible or panel._pending.global_position.y >= panel._speaker.get_global_rect().end.y, "Pending status below Listen")
		check(panel._speaker.get_global_rect().end.x <= panel._close.global_position.x, "Listen before Close without collision")
		check(panel._formal_name.get_global_rect().end.x <= panel._speaker.global_position.x, "Subtitle clear of header controls")
		check(panel._close.text == "CLOSE", "Shared Close label")
		check(not panel.get_node("Main/Margin/Layout/Controls").visible, "No footer audio row")
		check(panel._sources_button.get_parent() == panel._speaker.get_parent(), "Sources in header action group")
		check(panel._sources_button.size.y == 52, "Casa Real utility target height")
		check(panel._sources_button.get_global_rect().end.y <= panel._scroll.global_position.y, "Sources above reading area")
		check(panel._credit.global_position.y >= panel._scroll.get_global_rect().end.y, "Credit preserved below reading area")
		check(panel._credit.get_theme_font_size("font_size") < panel._body.get_theme_font_size("font_size"), "Secondary image-credit typography")
		check(panel._takeaway.get_theme_font_size("font_size") < panel._heading.get_theme_font_size("font_size"), "Secondary takeaway typography")
		for label in panel.find_children("*", "Label", true, false):
			for excluded in ["1587", "1710", "National Historical Landmark", "validated", "approved"]:
				check(not label.text.contains(excluded), "Excluded claim absent: " + excluded)
		check(panel.find_children("*", "Button", true, false).all(func(button): return not "TRANSCRIPT" in button.text.to_upper()), "No transcript button")
		check(panel._scroll.size.y >= 170, "Useful internal reading area")
		check(panel._media.size.y >= 220, "Photo area preserved")
		var media_share: float = panel._media.size.x / (panel._media.size.x + panel._information.size.x)
		check(absf(media_share - 0.46) < 0.03, "46/54 columns")
		check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(panel.get_global_rect()), "Panel within viewport")
		check(panel.get_global_rect().encloses(panel.get_node("Main").get_global_rect()), "No whole-panel overflow")
		for control in panel._concepts + [panel._close, panel._speaker, panel._sources_button]:
			check(control.size.y >= (52 if control in [panel._speaker, panel._close, panel._sources_button] else 56), "Shared comfortable target: " + control.name)
			check(panel.get_global_rect().encloses(control.get_global_rect()), "Control within panel: " + control.name)
			check(control.get_theme_stylebox("focus") != control.get_theme_stylebox("pressed"), "Distinct focus style")
		for section in [2, 0, 1]:
			await press(panel._concepts[section], section == 1)
			await finish(panel)
			check(panel.get_selected_concept() == section, "Direct mouse/touch section selection")
			var entry = panel.content.concepts[section]
			check(panel._heading.text == entry.heading and panel._body.text == entry.body and panel._takeaway.text == entry.takeaway, "Coherent selected copy")
			check(panel._caption.text == "Lingayen Church — present-day view", "Caption")
			check(panel._image.texture == panel.content.illustration, "All sections reuse exterior photo")
			check(panel._credit.text == "PHOTO: AKAR Research Team, 2026", "All sections retain the photo credit")
			panel.open_sources()
			check(panel._source_text.text.contains(entry.source_credit), "Per-section source mapping")
			panel.close_sources()
			for i in 3:
				check(panel._concepts[i].button_pressed == (i == section), "One selected tab")
			if "--capture" in OS.get_cmdline_user_args():
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lc_ext_01_%s_section%s.png" % [dimensions.x, section]))
		panel._concepts[0].grab_focus()
		await key(KEY_ENTER)
		check(panel.get_selected_concept() == 0, "Enter selects About")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._concepts[1], "Tab order")
		await key(KEY_SPACE)
		check(panel.get_selected_concept() == 1, "Space selects Historical Name")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._concepts[0], "Shift+Tab order")
		await key(KEY_LEFT)
		check(panel.get_selected_concept() == 0, "Left clamps at About")
		await key(KEY_RIGHT)
		check(panel.get_selected_concept() == 1, "Right within tab group")
		await press(panel._sources_button, true)
		check(panel._sources.visible and panel.get_selected_concept() == 1, "Sources preserves selection")
		check(panel._source_text.text.contains("Epiphany of the Lord Parish — historical account"), "Selected citation")
		check(not panel._source_text.text.contains("AKAR Research Team"), "Photo credit separate from historical citations")
		for i in 4:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() in [panel._source_close, panel._source_scroll], "Sources focus trap")
		panel.select_section(2)
		check(panel.get_selected_concept() == 1, "Sources blocks background selection")
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel._open and root.gui_get_focus_owner() == panel._sources_button, "First Escape closes Sources, restores focus")
		await key(KEY_RIGHT)
		check(panel.get_selected_concept() == 1, "Arrows outside tabs do not select sections")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel._open and not panel.visible and root.gui_get_focus_owner() == trigger, "Second Escape closes hotspot, restores trigger")
		check(preview.get_node("Margin").visible and trigger.is_visible_in_tree(), "Close restores neutral preview and launcher")
		panel.open_hotspot()
		await finish(panel)
		check(panel.get_selected_concept() == 0 and not panel._sources.visible and not panel._audio.playing and panel._audio.get_playback_position() == 0, "Fresh reopen resets")
		for i in 50:
			panel.select_section(i % 3)
		panel.select_section(2)
		await finish(panel)
		check(panel.get_selected_concept() == 2 and panel._information.modulate.a == 1, "Rapid switching settles")
		panel.select_section(-1)
		check(panel.get_selected_concept() == 0, "Invalid section falls back to About")
		panel.select_section(99)
		check(panel.get_selected_concept() == 0, "Out-of-range section falls back to About")
		panel.select_section(2)
		panel.open_sources()
		panel.reset_hotspot()
		check(panel.get_selected_concept() == 0 and not panel._sources.visible and panel._fade == null and panel._panel_tween == null, "Explicit reset cancels state and tweens")
		panel.close_hotspot()
		panel.open_hotspot()
		await finish(panel)
		check(panel._open and panel.get_selected_concept() == 0 and panel.modulate.a == 1, "Open during close cancels stale close")
		await press(panel._close, true)
		await finish(panel)
		check(not panel._open, "Touch Close")
		print("LC-EXT-01 checked: ", dimensions)
	check(close_count == 6, "One close notification per completed close")
	panel.open_hotspot()
	panel.select_section(2)
	preview.hide()
	check(not panel._open and panel._fade == null and panel._panel_tween == null and not panel._audio.playing, "Parent hide clears activity")
	preview.show()
	panel.open_hotspot()
	check(panel.get_selected_concept() == 0, "Open after parent hide resets")
	var saved_caption: String = panel.content.concepts[0].image_caption
	panel.content.concepts[0].image_caption = ""
	panel.select_section(0)
	check(not panel._caption.visible, "Missing optional caption hides cleanly")
	panel.content.concepts[0].image_caption = saved_caption
	preview.queue_free()
	await settle()
	check(root.content_scale_size == Vector2i(1280, 720), "Preview restores host canvas policy")
	print("LC-EXT-01 failures: ", failures)
	quit(1 if failures else 0)
