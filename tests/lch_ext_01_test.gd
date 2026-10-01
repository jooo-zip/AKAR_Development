extends SceneTree

var failures: int = 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 5:
		await process_frame

func finish_locator(panel: Control) -> void:
	if panel._locator_fade != null and panel._locator_fade.is_valid():
		panel._locator_fade.pause()
		panel._locator_fade.custom_step(1.0)
	await settle()

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

func click(control: Control) -> void:
	var event := InputEventMouseButton.new()
	event.position = control.get_global_rect().get_center()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func touch(control: Control) -> void:
	var event := InputEventScreenTouch.new()
	event.position = control.get_global_rect().get_center()
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	var preview = load("res://scenes/landmarks/limahong_channel/exterior/lch_ext_01_preview.tscn").instantiate()
	root.add_child(preview)
	await settle()
	var panel = preview.get_node("HotspotFrame/LimahongChannelInteraction")
	# Keep the existing missing-narration regression scenario; assigned audio is covered by lch_header_test.
	panel.content = panel.content.duplicate(true)
	panel.content.narration_stream = null
	var trigger = preview.get_node("Margin/Layout/OpenArtwork")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		trigger.grab_focus()
		check(panel.open_interaction(), "Open failed")
		await settle()
		check(panel.get_selected_concept() == 0, "Initial section")
		check(not panel.get_node("%NoteText").visible, "Initial note")
		check(not panel.get_node("NarrationPlayer").playing, "Autoplay")
		var speaker: Button = panel.get_node("%Speaker")
		check(speaker.visible and speaker.disabled, "Missing narration must remain visibly inactive")
		check(speaker.icon == load("res://assets/ui/icons/speaker.svg"), "Exact Urduja speaker icon")
		check(panel.content.narration_stream == null and panel.get_node("NarrationPlayer").stream == null, "No Urduja audio attached")
		check(speaker.size.y >= 48 and speaker.size.x >= 48, "Narration footprint")
		check(not speaker.get_global_rect().intersects(panel.get_node("%Close").get_global_rect()), "Speaker/Close collision")
		check(panel.get_node("%Title").get_global_rect().end.x <= speaker.get_global_rect().position.x, "Title/Listen collision")
		check(panel._locator_index == 0 and panel._media_index == 0, "Locator/media reset")
		check(panel.get_node("%Image").texture == panel.locator_steps[0].image, "Default Lingayen visual")
		check(panel.get_node("%Caption").text == "LINGAYEN • municipality locator", "Default exact caption")
		check(is_equal_approx(panel._locator_frame.size.x / panel._locator_frame.size.y, 4.0 / 3.0), "4:3 locator frame")
		check(panel._image_area.get_global_rect().grow(1).encloses(panel._locator_frame.get_global_rect()), "Frame fits parent")
		check(panel.get_node("%Image").stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Aspect-preserving image fit")
		var initial_frame: Rect2 = panel._locator_frame.get_global_rect()
		for locator in 3:
			await click(panel._locator_buttons[locator])
			await finish_locator(panel)
			check(panel._locator_index == locator, "Mouse selects every locator")
			await touch(panel._locator_buttons[(locator + 1) % 3])
			await touch(panel._locator_buttons[locator])
			await finish_locator(panel)
			check(panel._locator_index == locator, "Touch selects every locator")
			check(panel._locator_frame.get_global_rect().is_equal_approx(initial_frame), "Frame identical at every level")
		await click(panel.get_node("%Pangapisan"))
		check(panel._locator_index == 1, "Locator mouse activation")
		check(panel.get_node("%Image").texture == panel.locator_steps[1].image, "Pangapisan Norte visual")
		check(panel.get_node("%Caption").text.contains("PANGAPISAN NORTE"), "Locator caption feedback")
		await key(KEY_RIGHT)
		check(panel._locator_index == 2, "Locator keyboard right")
		check(panel.get_node("%Image").texture == panel.locator_steps[2].image, "Limahong Channel visual")
		await key(KEY_RIGHT)
		check(panel._locator_index == 2, "Locator right boundary")
		await key(KEY_LEFT)
		check(panel._locator_index == 1, "Locator keyboard left")
		await touch(panel.get_node("%Lingayen"))
		check(panel._locator_index == 0, "Locator synthetic touch")
		check(panel.get_node("%Image").texture == panel.locator_steps[0].image, "Lingayen touch visual")
		panel.get_node("%Channel").grab_focus()
		await key(KEY_ENTER)
		check(panel._locator_index == 2, "Locator Enter")
		panel.get_node("%Lingayen").grab_focus()
		await key(KEY_SPACE)
		check(panel._locator_index == 0, "Locator Space")
		for locator in 3:
			panel.select_locator(locator)
			await finish_locator(panel)
			check(panel.get_node("%Image").texture == panel.locator_steps[locator].image, "Settled locator visual")
			check(is_equal_approx(panel.get_node("%Image").self_modulate.a, 1.0) and not panel._outgoing_locator.visible, "Transition settles")
			if "--capture" in OS.get_cmdline_user_args():
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(OS.get_environment("TEMP") + "/lch_locator_" + str(dimensions.x) + "_" + str(locator) + ".png")
		# Both adjacent steps and direct jumps; deterministic advancement, no frame timing.
		for pair in [[0, 1], [1, 2], [0, 2], [2, 1], [1, 0], [2, 0]]:
			panel.select_locator(pair[0])
			await finish_locator(panel)
			var frame_before: Rect2 = panel._locator_frame.get_global_rect()
			panel.select_locator(pair[1])
			var direction: int = signi(pair[1] - pair[0])
			check(panel._locator_direction == direction, "Geographic zoom direction")
			check(panel._outgoing_locator.visible and panel.get_node("%Image").self_modulate.a == 0.0, "Zoom starts with outgoing image")
			panel._locator_fade.pause()
			panel._locator_fade.custom_step(0.07)
			check((panel._outgoing_locator.scale.x > 1.0) == (direction > 0), "Outgoing zoom path")
			check(panel._locator_frame.get_global_rect().is_equal_approx(frame_before), "No frame jump during zoom")
			await finish_locator(panel)
			check(panel._locator_frame.get_global_rect().is_equal_approx(frame_before), "No frame jump after zoom")
			check(panel.get_node("%Image").scale.is_equal_approx(Vector2.ONE), "Settled zoom scale")
			check(panel._locator_fade == null and panel.get_node("%Image").self_modulate.a == 1.0, "Settled zoom opacity")
			check(panel.get_node("%Caption").text == panel.locator_steps[pair[1]].title + " • " + panel.locator_steps[pair[1]].body, "Caption follows selected level")
		for i in 50:
			panel.select_locator(i % 3)
		await finish_locator(panel)
		check(panel._locator_index == 1 and panel.get_node("%Image").texture == panel.locator_steps[1].image, "Rapid locator last input wins")
		check(panel.get_node("%Caption").text == "PANGAPISAN NORTE • barangay locator" and panel._locator_buttons[1].button_pressed, "Rapid caption and button agree")
		check(not panel._outgoing_locator.visible and is_equal_approx(panel.get_node("%Image").self_modulate.a, 1.0), "Rapid transition settles")
		panel.select_locator(2)
		panel.select_concept(1)
		await finish_locator(panel)
		check(panel.get_node("%Image").texture == panel.section_media[1].image and not panel._outgoing_locator.visible, "Section change cancels locator transition")
		check(panel.get_node("%Image").scale.is_equal_approx(Vector2.ONE), "Other section retains neutral scale")
		panel.select_concept(0)
		panel.select_locator(0)
		panel.close_interaction()
		await settle()
		trigger.grab_focus()
		panel.open_interaction()
		await finish_locator(panel)
		check(panel._locator_index == 0 and panel.get_node("%Image").texture == panel.locator_steps[0].image, "Reopen during locator transition")
		check(panel.get_node("%Image").scale.is_equal_approx(Vector2.ONE) and panel._locator_fade == null, "Reopen neutral scale and no transition")
		check(not panel._outgoing_locator.visible and is_equal_approx(panel.get_node("%Image").self_modulate.a, 1.0), "Close clears locator transition")
		for button in panel._locator_buttons:
			check(button.size.y >= 56 and button.size.x >= 48, "Locator touch target")
			check(panel.get_global_rect().grow(1).encloses(button.get_global_rect()), "Locator bounds")
		for i in 3:
			await click(panel._concepts[i])
			await settle()
			check(panel.get_selected_concept() == i, "Mouse selection")
			if "--capture" in OS.get_cmdline_user_args():
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(OS.get_environment("TEMP") + "/lch_" + str(dimensions.x) + "_" + str(i) + ".png")
			var expected_image = panel.locator_steps[0].image if i == 0 else panel.section_media[i].image
			check(panel.get_node("%Image").texture == expected_image, "Section image")
			check(panel.get_node("%Body").text == panel.content.concepts[i].body, "Section body")
			for name in ["Close", "SourcesButton", "PublicInterior", "OfficialFunction", "WhyItMatters"]:
				var button: Control = panel.get_node("%" + name)
				check(button.size.y >= 48, "Small target " + name)
				check(panel.get_global_rect().grow(1).encloses(button.get_global_rect()), "Clipped " + name + " at " + str(dimensions))
			check(panel.get_node("%Scroll").size.y >= 100, "Information scroll too short")
			check(panel.get_node("%Visual").size.x >= panel.size.x * 0.5, "Visual region emphasis")
		check(panel.get_node("%Previous").disabled, "Media first boundary")
		await click(panel.get_node("%Next"))
		check(panel._media_index == 1, "Media mouse next")
		check(panel.get_node("%Image").texture == panel.site_media[1].image, "Media visual change")
		check(panel.get_node("%Caption").text == panel.site_media[1].title, "Media caption")
		await key(KEY_SPACE)
		check(panel._media_index == 2, "Media keyboard next")
		await touch(panel.get_node("%Next"))
		check(panel._media_index == 3 and panel.get_node("%Next").disabled, "Media last boundary")
		check(root.gui_get_focus_owner() == panel.get_node("%Previous"), "Media endpoint focus")
		await key(KEY_ENTER)
		check(panel._media_index == 2, "Media keyboard previous")
		for control in [panel.get_node("%Previous"), panel.get_node("%Next")]:
			check(control.size.y >= 56 and control.size.x >= 48, "Media touch target")
			check(panel.get_global_rect().grow(1).encloses(control.get_global_rect()), "Media bounds")
		var selected_image: Texture2D = panel.get_node("%Image").texture
		await create_timer(0.25).timeout
		check(panel.get_node("%Image").texture == selected_image, "Unrequested slideshow")
		panel._concepts[0].grab_focus()
		await key(KEY_LEFT)
		check(panel.get_selected_concept() == 0, "Left boundary")
		await key(KEY_RIGHT)
		check(panel.get_selected_concept() == 1, "Right arrow selection")
		check(root.gui_get_focus_owner() == panel._concepts[1], "Arrow focus")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._concepts[2], "Tab order")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._concepts[1], "Shift Tab order")
		await key(KEY_SPACE)
		check(panel.get_selected_concept() == 1, "Space activation")
		panel.get_node("%NoteButton").grab_focus()
		await key(KEY_ENTER)
		check(panel.get_node("%NoteText").visible, "Enter note activation")
		var note_rect: Rect2 = panel.get_node("%NoteText").get_global_rect()
		var scroll_rect: Rect2 = panel.get_node("%Scroll").get_global_rect()
		check(note_rect.position.y >= scroll_rect.position.y - 1 and note_rect.position.y < scroll_rect.end.y - 20, "Expanded note start must be revealed")
		check(panel.get_global_rect().grow(1).encloses(panel.get_node("%NoteButton").get_global_rect()), "Pinned note bounds")
		if "--capture" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OS.get_environment("TEMP") + "/lch_" + str(dimensions.x) + "_note.png")
		await key(KEY_SPACE)
		check(not panel.get_node("%NoteText").visible, "Space note collapse")
		check(panel.get_node("%NoteButton").icon != null, "Information icon")
		check(panel.get_node("%NoteButton").size.y >= 56, "Note touch target")
		panel.get_node("%NoteButton").set_pressed_no_signal(true)
		panel._toggle_note()
		check(panel.get_node("%NoteText").visible, "Note expansion")
		await touch(panel.get_node("%SourcesButton"))
		await settle()
		check(panel.get_node("%Sources").visible, "Sources open")
		check(panel.get_selected_concept() == 1, "Sources changed section")
		await key(KEY_ESCAPE)
		check(root.gui_get_focus_owner() == panel.get_node("%SourcesButton"), "Source return focus")
		await key(KEY_ESCAPE)
		await settle()
		check(root.gui_get_focus_owner() == trigger, "Trigger return focus")
		check(panel.open_interaction(), "Reopen failed")
		check(panel.get_selected_concept() == 0 and not panel.get_node("%NoteText").visible, "Reset failed")
		check(panel._media_index == 0 and panel._locator_index == 0, "Exploration reset failed")
		for i in 50:
			panel.select_concept(i % 3)
		panel.close_interaction()
		panel.close_interaction()
		print("Checked ", dimensions, " inset ", panel.size)
	# Exercise fallback without altering saved media.
	panel.open_interaction()
	var original = panel.section_media[0].image
	var original_locator = panel.locator_steps[0].image
	panel.locator_steps[0].image = null
	panel.select_concept(0)
	check(panel.get_node("%Image").texture == original and not panel.get_node("%Placeholder").visible, "Missing state visual uses existing fallback")
	panel.section_media[0].image = null
	panel.select_concept(0)
	check(panel.get_node("%Placeholder").visible, "Missing media fallback")
	panel.section_media[0].image = original
	panel.locator_steps[0].image = original_locator
	panel.select_concept(2)
	var original_site = panel.site_media[0].image
	panel.site_media[0].image = null
	panel.change_media(0)
	check(panel.get_node("%Placeholder").visible, "Missing gallery media fallback")
	panel.site_media[0].image = original_site
	panel.close_interaction()
	# Silent in-memory test signal: no dependency on final audio or Urduja speech.
	var silence := AudioStreamWAV.new()
	silence.mix_rate = 8000
	var samples := PackedByteArray()
	samples.resize(8000 * 5)
	samples.fill(128)
	silence.data = samples
	panel.content.narration_stream = silence
	panel.open_interaction()
	var player: AudioStreamPlayer = panel.get_node("NarrationPlayer")
	player.volume_db = -80
	check(not player.playing, "Narration initial silence")
	panel.toggle_narration()
	await create_timer(0.1).timeout
	check(player.playing, "Narration start")
	panel.toggle_narration()
	check(player.stream_paused, "Narration pause")
	panel.select_concept(2)
	check(player.stream_paused, "Selection changed narration pause")
	panel.toggle_narration()
	check(not player.stream_paused and player.playing, "Narration resume")
	var position := player.get_playback_position()
	panel.select_concept(1)
	check(player.playing and player.get_playback_position() >= position, "Narration restarted on section change")
	panel.hide()
	check(not player.playing and not player.stream_paused, "Hidden narration")
	panel.open_interaction()
	check(not player.playing, "Narration reopen")
	panel.close_interaction()
	panel.content.narration_stream = null
	preview.queue_free()
	await settle()
	print("LCH-EXT-01 failures: ", failures)
	quit.call_deferred(1 if failures else 0)
