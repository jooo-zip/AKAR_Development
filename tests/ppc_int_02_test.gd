extends SceneTree
## Real production preview with mouse, native touch and keyboard input dispatch.
const PREVIEW := preload("res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02_preview.tscn")
var checks := 0
var failures := 0
var starts := 0

const TOPICS := {
	&"executive_role": ["Executive Function", "The Governor's Office represents the executive side of provincial government within the Capitol."],
	&"coordination": ["Coordinating Provincial Administration", "Provincial executive offices coordinate administrative work and the implementation of government programs and services."],
	&"public_service": ["Serving the Province", "Provincial executive offices support public programs and services that connect the provincial government with the people it serves."],
	&"ordinances": ["Provincial Ordinances", "The Sangguniang Panlalawigan enacts provincial ordinances as part of its legislative responsibilities."],
	&"resolutions": ["Provincial Resolutions", "The provincial legislative body also approves resolutions as part of its official work."],
	&"provincial_policies": ["Provincial Policies", "Through legislation, the Sangguniang Panlalawigan helps establish policies under which the provincial government operates."]
}
const MEDIA := {
	&"lobby": ["ppc_int_02_lobby.png", "Second-floor lobby and reception area of the Pangasinan Provincial Capitol.", "ARKITHIRD / MAG-ARCHISTORY"],
	&"governor_office": ["ppc_int_02_governor_office.png", "Governor's Office inside the Pangasinan Provincial Capitol.", "Victory Liner"],
	&"session_hall": ["ppc_int_02_session_hall.jpeg", "Session Hall of the Pangasinan Provincial Capitol.", "Photo: AKAR Research Team"]
}

func _initialize() -> void:
	run.call_deferred()
	create_timer(300).timeout.connect(func() -> void:
		push_error("PPC-INT-02 test timeout")
		quit(2)
	)

func activate(panel, button: Button, method: int) -> void:
	if button.get_parent() == panel._controls:
		panel._rail.ensure_control_visible(button)
		await settle()
	if method < 2:
		await pointer(button, method == 1)
	else:
		button.grab_focus()
		await key(KEY_ENTER if method == 2 else KEY_SPACE)
	await finish(panel)

func defaults(panel) -> void:
	check(panel.civic_view == &"overview", "Default overview")
	check(panel.executive_topic == &"executive_role" and panel.legislative_topic == &"ordinances", "Default topic memory")
	check(not panel.space_view_open and panel.space_media_id == &"none" and panel.space_origin_view == &"none", "Viewer state reset")
	check(not panel._sources.visible and not panel._audio.playing, "No autoplay or Sources")
	check(panel._heading.text == "A Heritage Building Still in Use", "Approved overview heading")
	check(panel._body.text == "The Pangasinan Provincial Capitol is both a historic landmark and an active government building. Explore its approved civic spaces to see how executive and legislative functions continue within the Capitol.", "Approved overview copy")
	check(panel._rail.scroll_horizontal == 0 and panel._scroll.scroll_vertical == 0, "Local scroll reset")

func focus_checks(panel) -> void:
	var order: Array = panel.focus_order()
	order[0].grab_focus()
	for control in order:
		check(root.gui_get_focus_owner() == control, "Tab visits expected control " + str(control.name))
		await key(KEY_TAB)
	check(root.gui_get_focus_owner() == order[0], "Focus loops inside current context")
	for i in range(order.size() - 1, -1, -1):
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == order[i], "Reverse focus order")

func geometry(panel) -> void:
	var bounds: Rect2 = panel.get_global_rect()
	for control in panel._all_controls():
		if control is Button and control.is_visible_in_tree():
			check(control.size.y >= 48 and control.size.x >= 48, "Touch target >= 48: " + str(control.name))
			if control.get_parent() != panel._controls:
				check(bounds.grow(1).encloses(control.get_global_rect()), "Button remains in bounds: %s %s %s %s" % [root.size, panel.civic_view, control.text, control.get_global_rect()])
	check(panel._canvas.get_global_rect().end.y <= panel._rail.global_position.y + 1, "Visual does not cover function rail")
	check(panel._information.get_global_rect().end.y <= panel._rail.global_position.y + 1, "Interpretation does not cover rail")
	check(panel._canvas.photo.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Main image preserves aspect")
	check(panel._media_image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Viewer preserves aspect")
	if panel.civic_view == &"comparison":
		check(absf(panel._canvas.compare_photos[0].size.x - panel._canvas.compare_photos[1].size.x) < 2, "Comparison has equal width")
		check(absf(panel._canvas.compare_photos[0].size.y - panel._canvas.compare_photos[1].size.y) < 2, "Comparison has equal photo height")
		for i in 2:
			check(panel._canvas.compare_photos[i].size.y > 70, "Comparison photo stays meaningful")
			check(panel._canvas.compare_summaries[i].get_line_count() == panel._canvas.compare_summaries[i].get_visible_line_count(), "Both comparison summaries fit")

func capture(name: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var path := OS.get_environment("TEMP").path_join("ppc_int_02_" + name + ".png")
	check(root.get_texture().get_image().save_png(path) == OK, "Capture " + name)

func run() -> void:
	var preview := PREVIEW.instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("HotspotFrame/CapitolInteraction")
	var trigger := preview.get_node("Margin/Layout/OpenHotspot")
	panel.narration_started.connect(func() -> void: starts += 1)
	check(panel.content.narration_stream is AudioStreamOggVorbis, "Supplied OGG imports")
	check(panel.content.narration_stream.get_length() > 5, "Narration has playable duration")
	print("Narration duration: ", panel.content.narration_stream.get_length())
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		print("Validating ", dimensions)
		root.size = dimensions
		root.content_scale_size = Vector2i.ZERO
		await settle()
		panel.close_hotspot()
		await settle()
		trigger.grab_focus()
		panel.open_hotspot()
		await finish(panel)
		defaults(panel)
		geometry(panel)
		await focus_checks(panel)
		await capture(str(dimensions.x) + "_overview")
		check(panel._canvas.schematic.text == "SCHEMATIC PUBLIC-SPACE VIEW — NOT TO SCALE", "Explicit conceptual disclaimer")
		for method in 4:
			for i in 4:
				panel.select_civic_view(&"overview")
				await finish(panel)
				await activate(panel, panel._view_buttons[i], method)
				check(panel.civic_view == panel.VIEWS[i + 1], "All main views directly accessible by every input")
				geometry(panel)
				if method == 0:
					await focus_checks(panel)
					await capture(str(dimensions.x) + "_" + str(panel.civic_view))
				if panel.civic_view == &"lobby":
					check(panel._canvas.photo.texture.resource_path.ends_with(MEDIA[&"lobby"][0]), "Lobby image")
					for branch in 2:
						panel.select_civic_view(&"lobby")
						await finish(panel)
						await activate(panel, panel._canvas.branches[branch], method)
						check(panel.civic_view == (&"executive" if branch == 0 else &"legislative"), "Lobby branch transition")
				elif panel.civic_view in [&"executive", &"legislative"]:
					var executive: bool = panel.civic_view == &"executive"
					var topics: Array = panel.EXECUTIVE if executive else panel.LEGISLATIVE
					var texture: Texture2D = panel._canvas.photo.texture
					check(panel._heading.text == ("Governor's Office" if executive else "Session Hall"), "Audited space heading")
					for topic in 3:
						await activate(panel, panel._topic_buttons[topic], method)
						check((panel.executive_topic if executive else panel.legislative_topic) == topics[topic], "Topic activation")
						check(panel._topic_heading.text == TOPICS[topics[topic]][0] and panel._topic_body.text == TOPICS[topics[topic]][1], "Approved topic interpretation")
						check(panel._canvas.photo.texture == texture, "Topic keeps documentary photo")
						check(panel._topic_buttons[topic].button_pressed, "Selected topic visible")
						if method == 0:
							await capture(str(dimensions.x) + "_" + str(topics[topic]))
				else:
					check(panel._canvas.compare_photos[0].texture.resource_path.ends_with(MEDIA[&"governor_office"][0]), "Executive comparison image")
					check(panel._canvas.compare_photos[1].texture.resource_path.ends_with(MEDIA[&"session_hall"][0]), "Legislative comparison image")
					check(panel._canvas.compare_summaries[0].text == "Represents the executive side of provincial government and its continuing administrative and public-service role.", "Executive comparison copy")
					check(panel._canvas.compare_summaries[1].text == "Represents the legislative work of the Sangguniang Panlalawigan, including ordinances, resolutions, and provincial policies.", "Legislative comparison copy")
					for side in 2:
						panel.select_civic_view(&"comparison")
						await finish(panel)
						await activate(panel, panel._canvas.compare_actions[side], method)
						check(panel.civic_view == (&"executive" if side == 0 else &"legislative"), "Comparison explore action")
						check(panel.executive_topic == &"public_service" and panel.legislative_topic == &"provincial_policies", "Comparison preserves topics")
		panel.select_civic_view(&"legislative")
		panel.select_legislative_topic(&"resolutions")
		panel.select_civic_view(&"comparison")
		panel.select_civic_view(&"legislative")
		check(panel.legislative_topic == &"resolutions", "Specified legislative memory sequence")
		panel.select_civic_view(&"lobby")
		panel.select_civic_view(&"executive")
		check(panel.executive_topic == &"public_service", "Specified executive memory sequence")
		await finish(panel)
		if dimensions.x == 854:
			check(panel._topic_heading.global_position.y >= panel._scroll.global_position.y and panel._topic_body.get_global_rect().end.y <= panel._scroll.get_global_rect().end.y, "Compact topic immediately readable")
			await drag(panel._scroll, true, 0.8, 0.2, true)
			check(panel._scroll.scroll_vertical > 0, "Touch scroll reaches space introduction")
		await activate(panel, panel._speaker, 1)
		var before_starts := starts
		await create_timer(0.3).timeout
		var before_position: float = panel._audio.get_playback_position()
		check(panel._audio.playing and before_position > 0, "Touch starts narration once")
		for id in MEDIA:
			panel.select_civic_view(panel.MEDIA[id])
			await finish(panel)
			for method in 4:
				await activate(panel, panel._view_space, method)
				check(panel.space_view_open and panel.space_media_id == id and panel.space_origin_view == panel.MEDIA[id], "Viewer remembers media and origin")
				check(panel._media_image.texture.resource_path.ends_with(MEDIA[id][0]), "Viewer image")
				check(panel._media_caption.text == MEDIA[id][1], "Viewer caption")
				check(panel._media_credit.text.contains(MEDIA[id][2]), "Viewer source")
				check(root.gui_get_focus_owner() == panel._media_close, "Viewer Close first")
				panel.select_civic_view(&"comparison")
				panel.open_sources()
				panel.toggle_narration()
				check(panel.civic_view == panel.MEDIA[id] and not panel._sources.visible and panel._audio.playing, "Viewer blocks background")
				if method == 0:
					await focus_checks(panel)
					await capture(str(dimensions.x) + "_viewer_" + str(id))
				await activate(panel, panel._media_close, method)
				check(not panel.space_view_open and panel.civic_view == panel.MEDIA[id], "Viewer returns exact origin")
				check(root.gui_get_focus_owner() == panel._view_space, "Viewer restores opener focus")
		panel.select_legislative_topic(&"ordinances")
		panel.select_civic_view(&"executive")
		panel.select_executive_topic(&"coordination")
		panel.select_civic_view(&"comparison")
		await finish(panel)
		check(panel._audio.playing and starts == before_starts and panel._audio.get_playback_position() >= before_position, "All view/topic/viewer changes preserve narration")
		await pointer(panel._sources_button)
		check(panel._sources.visible, "Sources opens")
		panel.select_civic_view(&"lobby")
		panel.select_executive_topic(&"public_service")
		check(panel.civic_view == &"comparison" and panel.executive_topic == &"coordination", "Sources preserves state and blocks underlying API")
		await focus_checks(panel)
		await capture(str(dimensions.x) + "_sources")
		await drag(panel._source_scroll, true, 0.8, 0.2, true)
		check(panel._source_scroll.scroll_vertical > 0, "Sources touch scroll reaches lower credits")
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel._audio.playing and panel.civic_view == &"comparison", "Escape closes only Sources")
		for id in [&"lobby", &"executive", &"legislative", &"comparison", &"executive", &"lobby"]:
			panel.select_civic_view(id)
		await finish(panel)
		check(panel.civic_view == &"lobby" and panel._canvas.mode == &"lobby" and panel._canvas.photo.texture.resource_path.ends_with(MEDIA[&"lobby"][0]), "Rapid switching latest wins")
		panel._branch_selected(&"executive")
		panel.select_civic_view(&"legislative")
		await finish(panel)
		check(panel.civic_view == &"legislative", "New view cancels pending lobby branch")
		check(panel._canvas.previous_photo.texture == null and panel._canvas.photo.modulate.a == 1, "Photo crossfade clears stale image")
		panel.open_space_view(&"session_hall")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel.space_view_open and panel.civic_view == &"legislative", "Escape closes only viewer")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(panel.civic_view == &"overview" and panel._open, "Escape to overview")
		if panel._rail.get_h_scroll_bar().max_value > panel._rail.size.x:
			await drag(panel._rail, true, 0.8, 0.2)
			check(panel._rail.scroll_horizontal > 0 and panel.civic_view == &"overview", "Touch rail scroll does not select a function")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel._open and root.gui_get_focus_owner() == trigger, "Escape closes hotspot and restores host focus")
		defaults(panel)
		panel.open_hotspot()
		await finish(panel)
		defaults(panel)
		panel.select_civic_view(&"executive")
		panel.open_space_view(&"governor_office")
		panel.close_hotspot()
		panel.open_hotspot()
		await finish(panel)
		defaults(panel)
	var copy: String = panel.content.source_credit
	for record in panel.content.concepts:
		copy += record.heading + record.body + str(record.get_meta(&"caption", ""))
	for required in ["ARKITHIRD", "Victory Liner", "Photo: AKAR Research Team", "permission/reuse documentation pending", "AKAR Research Team — ppc_int_02_narration.ogg"]:
		check(copy.contains(required), "Required provenance: " + required)
	for excluded in ["credits to owner", "public domain", "unrestricted access", "campaign", "election", "vote for", "best governor", "ranking", "restricted-office route", "staff-only route", "score", "reward", "achievement", "locked rooms", "progress completion", "party branding"]:
		check(not copy.to_lower().contains(excluded), "No unsupported feature or claim: " + excluded)
	check(panel._topic_buttons[0].get_theme_stylebox("focus") != panel._topic_buttons[0].get_theme_stylebox("pressed"), "Focus styling differs from selected")
	panel.select_civic_view(&"executive")
	panel.toggle_narration()
	panel.open_space_view(&"governor_office")
	preview.hide()
	check(not panel._open and not panel._audio.playing and not panel.space_view_open, "Host hide cleans activity")
	preview.queue_free()
	await settle()
	await create_timer(0.2).timeout
	print("PPC-INT-02: ", checks, " checks; failures: ", failures)
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 6:
		await process_frame

func finish(panel) -> void:
	for tween in [panel._branch_tween, panel._transition, panel._topic_tween, panel._media_tween]:
		if tween != null and tween.is_valid():
			tween.pause()
			tween.custom_step(1.0)
	await settle()

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

func drag(canvas: Control, touch: bool, start_amount: float, end_amount: float, vertical: bool = false) -> void:
	var start: InputEvent = InputEventScreenTouch.new() if touch else InputEventMouseButton.new()
	start.position = canvas.global_position + canvas.size * (Vector2(0.5, start_amount) if vertical else Vector2(start_amount, 0.5))
	if not touch:
		start.button_index = MOUSE_BUTTON_LEFT
	start.pressed = true
	Input.parse_input_event(start)
	await process_frame
	var motion: InputEvent = InputEventScreenDrag.new() if touch else InputEventMouseMotion.new()
	var midpoint := lerpf(start_amount, end_amount, 0.5)
	motion.position = canvas.global_position + canvas.size * (Vector2(0.5, midpoint) if vertical else Vector2(midpoint, 0.5))
	motion.relative = motion.position - start.position
	if not touch:
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(motion)
	await process_frame
	var final_position := canvas.global_position + canvas.size * (Vector2(0.5, end_amount) if vertical else Vector2(end_amount, 0.5))
	motion = motion.duplicate()
	motion.relative = final_position - motion.position
	motion.position = final_position
	Input.parse_input_event(motion)
	await process_frame
	start.position = motion.position
	start.pressed = false
	Input.parse_input_event(start)
	await settle()
