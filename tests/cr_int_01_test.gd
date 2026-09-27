extends SceneTree
## Real production scene, input events, lifecycle and responsive validation.
var checks: int = 0
var failures: int = 0
var closes: int = 0

func finish(panel, include_storm: bool = true) -> void:
	for tween in [panel.active_stage_transition, panel._reveal]:
		if tween != null and tween.is_valid():
			tween.pause()
			tween.custom_step(5.0)
	if include_storm and panel.active_storm_tween != null and panel.active_storm_tween.is_valid():
		panel.active_storm_tween.pause()
		panel.active_storm_tween.custom_step(5.0)
	await settle()

func assert_clean_storm(panel) -> void:
	check(not panel.storm_active and panel.active_storm_tween == null, "No stale storm state or tween")
	check(not panel._storm.visible and not panel._storm.is_processing(), "Rain/wind stopped and hidden")
	check(panel._storm.flash == 0 and panel._storm.darkness == 0 and panel._storm.intensity == 0, "Flash/darkness/rain reset")
	check(not panel._storm_audio.playing, "Storm ambience stopped")

func assert_state(panel, stage: int) -> void:
	check(panel.current_stage == stage and panel.get_selected_concept() == stage, "Authoritative stage")
	check(panel._heading.text == HEADINGS[stage] and panel._body.text == BODIES[stage] and panel._period.text == YEARS[stage], "Approved stage copy")
	check(panel._body.visible, "Stable stage body visible")
	var expected_image: String = "res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_banaan_identity.jpg" if stage == 3 and panel.museum_photo_index == 1 else IMAGES[stage]
	check(panel._image.texture.resource_path == expected_image, "Correct documentary image")
	check(panel._ribbon.get_child_count() == 3, "Only three historical stage buttons")
	for i in 3:
		check(panel._concepts[i].button_pressed == (i + 1 == stage), "Selected fill matches stage")
	check(panel._comparison.visible == (stage == 2) and panel._after.visible == (stage == 2), "Comparison exclusive to Restoration")
	check(panel._identity.visible == (stage == 3), "Museum identity label exclusive to Museum")
	check(panel._image.scale == Vector2.ONE and panel._after.scale == Vector2.ONE, "No photo deformation")
	check(panel._visual.modulate.a == 1.0 and panel._interpretation.modulate.a == 1.0, "No stale stage opacity")
	check(panel.active_stage_transition == null, "Stage tween settled")
	assert_clean_storm(panel)
	if stage == 2:
		check(is_equal_approx(panel._after.modulate.a, panel.comparison_position) and is_equal_approx(panel._image.modulate.a, 1.0 - panel.comparison_position), "Comparison shows requested visibility")
		check(panel._after.texture.resource_path.ends_with("cr_int_01_restored_2022.png"), "Actual after image")
		check(panel._before_label.text == "BEFORE RESTORATION" and panel._after_label.text == "AFTER RESTORATION", "Comparison labels")

func assert_layout(panel) -> void:
	var main: Control = panel.get_node("Main")
	check(main.size.is_equal_approx(panel.size * (0.96 if panel.size.x < 1100 else 0.9)), "Centered inset dimensions")
	check(main.get_global_rect().get_center().distance_to(panel.get_global_rect().get_center()) < 1, "Inset centered")
	var bounds := main.get_global_rect().grow(0.5)
	for control in panel._concepts + [panel._overview, panel._sources_button, panel._speaker, panel._close]:
		check(control.size.y >= 56 and bounds.encloses(control.get_global_rect()), "Usable contained touch control")
	for control in [panel._title, panel._subtitle, panel._visual, panel._caption, panel._hint, panel._comparison, panel._comparison_labels, panel._scroll]:
		if control.is_visible_in_tree():
			check(bounds.encloses(control.get_global_rect()), "Visible content within panel: " + control.name)
	check(panel._image.size.x >= 320 and panel._image.size.y >= 110, "Useful visual size: %s" % panel._image.size)
	check(panel._storm.get_global_rect() == panel._image.get_global_rect(), "Storm confined to photograph area")
	check(panel._image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED and panel._after.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Preserved documentary aspect ratios")
	var share: float = panel._viewer.size.x / (panel._viewer.size.x + panel._information.size.x)
	check(share >= 0.64 and share <= 0.66, "Dominant visual proportion")
	check(panel._body.get_theme_font_size("font_size") >= 18, "Readable text")
	check(panel._speaker.get_index() + 1 == panel._close.get_index() and panel._sources_button.get_index() + 1 == panel._speaker.get_index(), "Sources Listen Close order")
	check(panel._concepts[0].get_theme_stylebox("pressed") != panel._concepts[0].get_theme_stylebox("focus"), "Focus differs from selected")
	check(panel._comparison.custom_minimum_size.y >= 56, "Large comparison drag target")

func capture(name: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("akar_cr_int_01_" + name + ".png")) == OK, "Rendered capture")

func drag_comparison(panel, touch: bool) -> void:
	var bar: Control = panel._comparison
	var origin := bar.global_position + Vector2(28, bar.size.y * 0.5)
	var end := bar.global_position + Vector2(bar.size.x - 28, bar.size.y * 0.5)
	var down: InputEvent = InputEventScreenTouch.new() if touch else InputEventMouseButton.new()
	down.position = origin
	down.pressed = true
	if not touch:
		down.button_index = MOUSE_BUTTON_LEFT
	Input.parse_input_event(down)
	await process_frame
	check(is_zero_approx(panel.comparison_position), "Drag starts at Before")
	for step in range(1, 6):
		var move: InputEvent = InputEventScreenDrag.new() if touch else InputEventMouseMotion.new()
		move.position = origin.lerp(end, step / 5.0)
		move.relative = (end - origin) / 5.0
		if not touch:
			move.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(move)
		await process_frame
		check(is_equal_approx(panel.comparison_position, step / 5.0), "Comparison tracks pointer without Tween")
	var up: InputEvent = down.duplicate()
	up.position = end
	up.pressed = false
	Input.parse_input_event(up)
	await settle()
	check(is_equal_approx(panel.comparison_position, 1.0) and not bar.dragging, "Drag ends at After and releases capture")

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	create_timer(180.0).timeout.connect(func(): push_error("CR-INT-01 timeout"); quit(1))
	root.content_scale_size = Vector2i.ZERO
	var preview = load("res://scenes/landmarks/casa_real/interior/cr_int_01_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("CR_INT_01")
	var trigger: Button = preview.get_node("Reopen")
	panel.closed.connect(func(): closes += 1)
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		check(panel.open_hotspot(), "Open real production preview")
		await finish(panel)
		assert_state(panel, 0)
		check(panel.comparison_position == 0.5 and panel.museum_photo_index == 0, "Default session state")
		check(not panel._audio.playing and not panel._sources.visible, "No autoplay or modal")
		check(panel._audio.stream.resource_path.ends_with("cr_int_01_narration.ogg") and panel._audio.stream.get_length() > 0, "Real narration imported")
		check(not panel._storm_audio.stream.loop and panel._storm_audio.stream.get_length() > 0, "Real non-looping storm stream")
		for from_stage in 4:
			for to_stage in 4:
				panel.select_stage(from_stage)
				await finish(panel)
				await pointer(panel._overview if to_stage == 0 else panel._concepts[to_stage - 1])
				await finish(panel)
				assert_state(panel, to_stage)
		for stage in 4:
			panel.select_stage(stage)
			await finish(panel)
			assert_layout(panel)
			await capture("%dx%d_stage%d" % [dimensions.x, dimensions.y, stage])
			panel.open_sources()
			check(panel.current_stage == stage and panel._source_text.text.contains(panel._entry().media_credit), "Sources preserves stage and attribution")
			await capture("%dx%d_sources%d" % [dimensions.x, dimensions.y, stage])
			panel.close_sources()
		# One real-time run verifies automatic reveal, not just manually advanced Tweens.
		panel.select_stage(1)
		check(panel.storm_active and not panel._image.visible and not panel._body.visible, "Neutral atmosphere before evidence")
		check(panel._caption.text == "ATMOSPHERIC INTERPRETATION" and panel._storm_audio.playing, "Atmosphere labelled, audio started deliberately")
		await create_timer(3.2).timeout
		assert_state(panel, 1)
		check(panel._caption.text == "DOCUMENTARY PHOTOGRAPH — 2008", "Documentary label after storm")
		panel.select_stage(1)
		panel.active_storm_tween.pause()
		panel.active_storm_tween.custom_step(1.22)
		check(panel._storm.flash > 0 and panel._storm.flash <= 0.12, "One restrained flash")
		assert_layout(panel)
		await capture("%dx%d_storm" % [dimensions.x, dimensions.y])
		panel.open_sources()
		assert_clean_storm(panel)
		check(panel.current_stage == 1 and panel._image.visible, "Sources stabilizes Damage")
		await key(KEY_ESCAPE)
		panel.select_stage(1)
		panel.select_stage(3)
		await finish(panel)
		assert_state(panel, 3)
		for touch in [false, true]:
			await pointer(panel._concepts[0], touch)
			await pointer(panel._visual, touch)
			assert_state(panel, 1)
			panel.select_stage(1)
			await pointer(panel._concepts[1], touch)
			await finish(panel)
			assert_state(panel, 2)
			await drag_comparison(panel, touch)
			panel.set_comparison_position(0.75)
			await pointer(panel._concepts[2], touch)
			await finish(panel)
			var previous: int = panel.museum_photo_index
			await pointer(panel._visual, touch)
			await finish(panel)
			check(panel.museum_photo_index == 1 - previous, "Museum image toggles")
			await capture("%dx%d_museum_toggle" % [dimensions.x, dimensions.y])
			await pointer(panel._concepts[1], touch)
			await finish(panel)
			check(panel.comparison_position == 0.75, "Comparison survives stage switch")
			panel.open_sources()
			panel.set_comparison_position(0.1)
			panel.select_stage(0)
			await pointer(panel._visual, touch)
			check(panel.current_stage == 2 and panel.comparison_position == 0.75, "Sources blocks hidden controls")
			await pointer(panel._source_close, touch)
			await pointer(panel._speaker, touch)
			await create_timer(0.2).timeout
			var audio_position: float = panel._audio.get_playback_position()
			panel.select_stage(1)
			check(panel._audio.playing and not panel._storm_audio.playing, "Storm suppressed under narration")
			panel._visual.grab_focus()
			await key(KEY_SPACE)
			assert_state(panel, 1)
			check(panel._audio.get_playback_position() >= audio_position, "Storm did not restart narration")
			await pointer(panel._speaker, touch)
			await create_timer(0.1).timeout
			audio_position = panel._audio.get_playback_position()
			check(panel._audio.stream_paused and panel._speaker.text == "RESUME", "Narration pause")
			panel.select_stage(2)
			await finish(panel)
			await drag_comparison(panel, touch)
			panel.select_stage(3)
			await finish(panel)
			await pointer(panel._visual, touch)
			await finish(panel)
			panel.open_sources()
			check(panel._audio.stream_paused and is_equal_approx(panel._audio.get_playback_position(), audio_position), "All interactions preserve paused narration")
			await key(KEY_ESCAPE)
			await pointer(panel._speaker, touch)
			check(panel._audio.playing and not panel._audio.stream_paused, "Narration resume")
			panel.stop_narration()
			panel.select_stage(1)
			await pointer(panel._speaker, touch)
			check(panel._audio.playing and not panel._storm_audio.playing and panel.storm_active, "Starting narration suppresses active ambience only")
			var before := closes
			await pointer(panel._close, touch)
			check(closes == before + 1 and not panel._open and not panel._audio.playing, "Close during storm emits once and stops narration")
			assert_clean_storm(panel)
			await pointer(trigger, touch)
			await finish(panel)
			assert_state(panel, 0)
			check(panel.comparison_position == 0.5 and panel.museum_photo_index == 0 and panel._audio.get_playback_position() == 0, "Reopen resets comparison/photo/audio")
		# Focus-only navigation, comparison endpoints, and keyboard museum toggle.
		panel._concepts[0].grab_focus()
		await key(KEY_RIGHT)
		check(panel.current_stage == 0 and root.gui_get_focus_owner() == panel._concepts[1], "Focus movement never selects")
		await key(KEY_ENTER)
		await finish(panel)
		panel._comparison.grab_focus()
		for code in [KEY_HOME, KEY_RIGHT, KEY_END, KEY_LEFT]:
			await key(code)
			var expected: float = {KEY_HOME: 0.0, KEY_RIGHT: 0.05, KEY_END: 1.0, KEY_LEFT: 0.95}[code]
			check(is_equal_approx(panel.comparison_position, expected), "Comparison keyboard step/endpoints")
		panel.set_comparison_position(-1)
		check(panel.comparison_position == 0, "Comparison lower clamp")
		await capture("%dx%d_comparison_before" % [dimensions.x, dimensions.y])
		panel.set_comparison_position(2)
		check(panel.comparison_position == 1, "Comparison upper clamp")
		await capture("%dx%d_comparison_after" % [dimensions.x, dimensions.y])
		panel.select_stage(3)
		await finish(panel)
		panel._visual.grab_focus()
		for code in [KEY_ENTER, KEY_SPACE]:
			var previous: int = panel.museum_photo_index
			await key(code)
			await finish(panel)
			check(panel.museum_photo_index == 1 - previous, "Keyboard museum toggle")
		panel._concepts[0].grab_focus()
		for target in [panel._concepts[1], panel._concepts[2], panel._visual, panel._overview, panel._scroll, panel._sources_button, panel._speaker, panel._close, panel._concepts[0]]:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == target, "Stage/visual/Overview/reading/toolbar focus order")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._close, "Shift Tab")
		panel._sources_button.grab_focus()
		await key(KEY_SPACE)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._source_scroll, "Sources modal focus trap")
		await touch_drag(panel._source_scroll)
		check(panel._source_scroll.scroll_vertical > 0, "Touch scroll Sources")
		await key(KEY_END)
		await capture("%dx%d_sources_end" % [dimensions.x, dimensions.y])
		await key(KEY_ESCAPE)
		check(panel._open and not panel._sources.visible, "Escape closes Sources first")
		var abandoned: Array[Tween] = []
		for i in 5:
			panel.select_stage(1)
			abandoned.append(panel.active_storm_tween)
			panel.select_stage(2)
			panel.set_comparison_position(0.7)
			panel.select_stage(3)
			panel._activate_visual()
			panel.select_stage(1)
			panel._activate_visual()
		panel.select_stage(2)
		await finish(panel)
		assert_state(panel, 2)
		panel._scroll.grab_focus()
		await key(KEY_END)
		check(panel._scroll.scroll_vertical > 0 or not panel._read_hint.visible, "Keyboard can read entire interpretation")
		await key(KEY_HOME)
		if panel._read_hint.visible:
			await touch_drag(panel._scroll)
			check(panel._scroll.scroll_vertical > 0, "Touch drag reads interpretation")
			panel._scroll.scroll_vertical = 0
		# Cancel an actual held comparison gesture when a modal takes over.
		var held := InputEventMouseButton.new()
		held.button_index = MOUSE_BUTTON_LEFT
		held.position = panel._comparison.get_global_rect().get_center()
		held.pressed = true
		Input.parse_input_event(held)
		await process_frame
		check(panel._comparison.dragging, "Comparison gesture captured")
		panel.open_sources()
		check(not panel._comparison.dragging, "Sources ends active comparison drag")
		held = held.duplicate()
		held.pressed = false
		Input.parse_input_event(held)
		panel.close_sources()
		for tween in abandoned:
			check(not tween.is_valid(), "No stale storm callback")
		panel.select_stage(-1)
		panel.select_stage(4)
		assert_state(panel, 2)
		panel.select_stage(1)
		panel.open_sources()
		panel.reset_hotspot()
		await finish(panel)
		assert_state(panel, 0)
		panel.select_stage(1)
		await key(KEY_ESCAPE)
		check(not panel._open and panel.active_stage_transition == null and panel._reveal == null, "Escape cleans all transitions")
		assert_clean_storm(panel)
		print("CR-INT-01 ", dimensions, " complete; failures=", failures)
	panel.open_hotspot()
	panel.select_stage(1)
	panel.hide()
	check(not panel._open, "Host hide closes hotspot")
	assert_clean_storm(panel)
	await create_timer(0.15).timeout
	preview.queue_free()
	await settle()
	print("CR-INT-01: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)
const HEADINGS := ["A HISTORIC BUILDING, A NEW PURPOSE","TYPHOON COSME DAMAGE","PRESERVING CASA REAL","A NEW PURPOSE"]
const BODIES := ["After years of changing public use and deterioration, Casa Real underwent a major preservation effort that transformed the historic structure into the Banáan Pangasinan Provincial Museum.","After decades of changing use and deterioration, Casa Real suffered severe damage during Typhoon Cosme in 2008.","A multi-phase restoration involving national and provincial government institutions sought to preserve Casa Real’s architectural and historical significance. Restoration began in 2015, and the restored structure was formally turned over to the Provincial Government of Pangasinan in 2021.","In 2023, Casa Real formally opened as the Banáan Pangasinan Provincial Museum. The restored historic building now serves as a center for education, cultural memory, and Pangasinan identity."]
const YEARS := ["","2008","2015–2021","2023"]
const IMAGES := ["res://assets/landmarks/casa_real/exterior/cr_ext_01_facade.png","res://assets/landmarks/casa_real/interior/transformation/cr_int_01_cosme_damage.png","res://assets/landmarks/casa_real/interior/transformation/cr_int_01_cosme_damage.png","res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_heritage_museum.jpg"]


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 5:
		await process_frame

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

func touch_drag(control: Control) -> void:
	var start := InputEventScreenTouch.new()
	start.position = control.get_global_rect().get_center()
	start.pressed = true
	Input.parse_input_event(start)
	await process_frame
	for step in 6:
		var drag := InputEventScreenDrag.new()
		drag.position = start.position - Vector2(0, (step + 1) * 10)
		drag.relative = Vector2(0, -10)
		Input.parse_input_event(drag)
		await process_frame
	start = start.duplicate()
	start.pressed = false
	start.position -= Vector2(0, 60)
	Input.parse_input_event(start)
	await settle()

func pointer(control: Control, touch: bool = false) -> void:
	var event: InputEvent = InputEventScreenTouch.new() if touch else InputEventMouseButton.new()
	event.position = control.get_global_rect().get_center()
	if not touch:
		event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()
