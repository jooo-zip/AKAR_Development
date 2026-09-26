extends SceneTree
## Exercise the production component with actual GUI events at each target size.
var failures: int = 0
var checks: int = 0
var closes: int = 0
const HEADINGS := ["ONE BUILDING, CHANGING ROLES","PROVINCIAL GOVERNMENT CENTER","CONTINUED PUBLIC SERVICE","HERITAGE & MUSEUM"]
const BODIES := ["Casa Real has served Pangasinan in different ways across generations. Select a period to see how its public role changed.","Constructed in 1840, Casa Real served as Pangasinan's provincial government center, housing the residence and office of the Alcalde Mayor and supporting administrative and judicial functions.","After the new Pangasinan Provincial Capitol opened in 1919, Casa Real continued serving the public in different ways. It was used as a school, courthouse, and government office, including wartime office use before returning to court functions after the war.","Casa Real entered a new chapter centered on heritage preservation. After historical recognition, typhoon damage, and restoration, the building formally opened in 2023 as the Banáan Pangasinan Provincial Museum."]
const PERIODS := ["","1840–1918","1919–1996","2002–PRESENT"]
const TAGLINES := ["HOW DID CASA REAL'S ROLE CHANGE?","GOVERNMENT · ADMINISTRATION · JUDICIARY","SCHOOL · COURTHOUSE · GOVERNMENT USE","RECOGNITION · PRESERVATION · EDUCATION"]
const DATES := [[],["1840","1898","1901","1918"],["1919","1942–1945","POSTWAR–1996"],["2002","2008","2015","2021","2023"]]
const MILESTONES := [[],["CONSTRUCTED / GOVERNMENT CENTER","REVOLUTIONARY ATTACK","TAFT COMMISSION RECEPTION","END AS PRINCIPAL PROVINCIAL CAPITOL"],["CHANGING PUBLIC USES","WARTIME OFFICE","COURT USE"],["NATIONAL HISTORICAL LANDMARK","TYPHOON COSME DAMAGE","RESTORATION BEGAN","FORMAL TURNOVER","BANÁAN MUSEUM"]]
const IMAGES := [["res://assets/landmarks/casa_real/exterior/cr_ext_01_facade.png"],["res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_government_center.jpg.jpg"],["res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_public_service.jpg","res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_public_service_secondary.jpg"],["res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_historical_marker.jpg","res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_cosme_damage.JPG","res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_heritage_museum.jpg","res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_banaan_identity.jpg"]]
const CAPTIONS := [["Casa Real — Full Façade"],["Provincial Government Center"],["Continued Public Service","Continued Public Service — Additional View"],["National Historical Landmark Recognition","Typhoon Cosme Damage — 2008","Restored Casa Real","Banáan Pangasinan Provincial Museum"]]


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 5:
		await process_frame

func finish(panel) -> void:
	for tween in [panel.active_role_transition, panel.active_photo_transition, panel._reveal]:
		if tween != null and tween.is_valid():
			tween.pause()
			tween.custom_step(2.0)
	await settle()

func assert_state(panel, role: int, photo: int = 0) -> void:
	check(panel.current_role == role and panel.current_photo_index == photo, "Authoritative role and photo index")
	check(panel._heading.text == HEADINGS[role] and panel._body.text == BODIES[role], "Exact approved heading/body")
	check(panel._period.text == PERIODS[role] and panel._tagline.text == TAGLINES[role], "Exact period/tagline")
	check(panel._image.texture.resource_path == IMAGES[role][photo], "Correct documentary texture")
	check(panel._caption.text == CAPTIONS[role][photo], "Correct documentary caption")
	check(panel._counter.text == "%d / %d" % [photo + 1, IMAGES[role].size()], "Photo counter, not completion")
	check(panel._counter.visible == (role >= 2) and panel._hint.visible == (role >= 2), "Visible cycling affordance only for multiple photos")
	check(panel._photo_frame.focus_mode == (Control.FOCUS_ALL if role >= 2 else Control.FOCUS_NONE), "Only multi-photo viewer focusable")
	check(panel._milestones.visible == (role != 0) and panel._milestones.get_child_count() == DATES[role].size(), "Milestone strip matches role")
	for i in DATES[role].size():
		var label = panel._milestones.get_child(i)
		check(label is Label and label.focus_mode == Control.FOCUS_NONE and label.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Milestone informational only")
		check(label.text == DATES[role][i] + ("\n" + MILESTONES[role][i] if panel.size.x >= 1100 else ""), "Approved milestone copy")
	for i in 3:
		check(panel._concepts[i].button_pressed == (role == i + 1), "Selected role distinct from focus")
	check(panel._ribbon.get_child_count() == 3, "Exactly three historical role buttons")
	check(panel.active_role_transition == null and panel.active_photo_transition == null, "No pending transitions")
	check(panel._photo_visual.modulate.a == 1.0 and panel._interpretation.modulate.a == 1.0 and panel._milestones.modulate.a == 1.0, "No stale faded content")
	check(panel._image.scale == Vector2.ONE and panel._image.rotation == 0.0, "Original image transform")

func assert_layout(panel) -> void:
	var main: Control = panel.get_node("Main")
	check(main.size.is_equal_approx(panel.size * (0.96 if panel.size.x < 1100 else 0.90)), "Inset size: %s / %s" % [main.size, panel.size])
	check(main.get_global_rect().get_center().distance_to(panel.get_global_rect().get_center()) < 1, "Centered inset")
	var bounds := main.get_global_rect().grow(0.5)
	for control in panel._concepts + [panel._overview, panel._sources_button, panel._speaker, panel._close]:
		check(control.size.y >= 56 and control.size.x >= 48, "Large touch target")
		check(bounds.encloses(control.get_global_rect()), "Control contained by panel")
	for control in [panel._title, panel._subtitle, panel._caption, panel._hint, panel._counter, panel._milestones, panel._scroll, panel._image]:
		if control.is_visible_in_tree():
			check(bounds.encloses(control.get_global_rect()), "Visible content inside panel: " + control.name)
	check(panel._image.size.x >= 320 and panel._image.size.y >= 140, "Useful image area: %s" % panel._image.size)
	check(panel._image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Undistorted documentary image")
	var share: float = panel._viewer.size.x / (panel._viewer.size.x + panel._information.size.x)
	check(share >= 0.62 and share <= 0.65, "62–65 percent documentary viewer: %s" % share)
	check(panel._speaker.get_index() + 1 == panel._close.get_index() and panel._sources_button.get_index() + 1 == panel._speaker.get_index(), "Sources Listen Close adjacency")
	check(panel._concepts[0].get_theme_stylebox("focus") != panel._concepts[0].get_theme_stylebox("pressed"), "Focus outline differs from selection fill")
	check(panel._body.get_theme_font_size("font_size") >= 18, "Readable interpretation")
	check(panel._body.global_position.y + 20 <= panel._scroll.get_global_rect().end.y, "Explanation begins visibly before scrolling")
	check(panel._scroll.get_parent() == panel._information, "Only interpretation scrolls")
	check(panel._ribbon.get_global_rect().position.y >= panel._viewer.get_global_rect().end.y, "Role ribbon below story")

func capture(name: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("akar_cr_ext_03_" + name + ".png")) == OK, "Rendered screenshot saved")

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	create_timer(180.0).timeout.connect(func(): push_error("CR-EXT-03 timeout"); quit(1))
	root.content_scale_size = Vector2i.ZERO
	var preview = load("res://scenes/landmarks/casa_real/exterior/cr_ext_03_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("CR_EXT_03")
	var trigger: Button = preview.get_node("Reopen")
	panel.closed.connect(func(): closes += 1)
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		check(panel.open_hotspot(), "Open production hotspot")
		await finish(panel)
		assert_state(panel, 0)
		check(not panel._audio.playing and not panel._audio.stream_paused and not panel._sources.visible, "Overview with no autoplay/modal")
		check(panel._audio.stream.resource_path.ends_with("cr_ext_03_narration.ogg") and panel._audio.stream.get_length() > 0, "Actual imported narration")
		check(panel._speaker.icon.resource_path == "res://assets/ui/icons/speaker.svg", "Shared speaker icon")
		for from_role in 4:
			for to_role in 4:
				panel.select_role(from_role)
				await finish(panel)
				await pointer(panel._overview if to_role == 0 else panel._concepts[to_role - 1])
				await finish(panel)
				assert_state(panel, to_role)
		for role in 4:
			panel.select_role(role)
			await finish(panel)
			for photo in IMAGES[role].size():
				panel.show_photo(photo)
				await finish(panel)
				assert_state(panel, role, photo)
				assert_layout(panel)
				await capture("%dx%d_role%d_photo%d" % [dimensions.x, dimensions.y, role, photo])
				panel.open_sources()
				check(panel.current_role == role and panel.current_photo_index == photo, "Sources preserves role/photo")
				check(panel._source_text.text.contains(panel._entry().photos[photo].source_label), "Current documentary attribution")
				check(panel._source_text.text.contains("Unspecified / pending documentation"), "Reuse permission uncertainty")
				if photo == 0:
					await capture("%dx%d_sources%d" % [dimensions.x, dimensions.y, role])
				panel.close_sources()
			for touch in [false, true]:
				for step in IMAGES[role].size() + 1:
					var expected: int = (panel.current_photo_index + 1) % IMAGES[role].size()
					await pointer(panel._photo_frame, touch)
					await finish(panel)
					assert_state(panel, role, expected)
		panel.select_role(-1)
		panel.select_role(4)
		check(panel.current_role == 3, "Reject invalid role")
		var cancelled: Array[Tween] = []
		for role in [3, 2, 1, 3, 2]:
			panel.select_role(role)
			panel.active_role_transition.pause()
			panel.active_role_transition.custom_step(0.07)
			cancelled.append(panel.active_role_transition)
			panel.show_next_photo()
			panel.show_next_photo()
		panel.select_role(2)
		await finish(panel)
		assert_state(panel, 2)
		for tween in cancelled:
			check(not tween.is_valid(), "Superseded role transition killed")
		panel.select_role(3)
		panel.show_next_photo()
		panel.show_next_photo()
		await finish(panel)
		assert_state(panel, 3, 2)
		panel._concepts[0].grab_focus()
		await key(KEY_RIGHT)
		check(panel.current_role == 3 and root.gui_get_focus_owner() == panel._concepts[1], "Focus alone never selects")
		await key(KEY_ENTER)
		await finish(panel)
		assert_state(panel, 2)
		await key(KEY_RIGHT)
		await key(KEY_SPACE)
		await finish(panel)
		assert_state(panel, 3)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._overview, "Tab to Overview")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._photo_frame, "Tab to multiphoto viewer")
		for code in [KEY_ENTER, KEY_SPACE, KEY_RIGHT, KEY_LEFT]:
			var expected: int = posmod(panel.current_photo_index + (-1 if code == KEY_LEFT else 1), 4)
			await key(code)
			await finish(panel)
			assert_state(panel, 3, expected)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._scroll, "Keyboard access to local reading pane")
		await key(KEY_END)
		check(panel._scroll.scroll_vertical > 0 or not panel._read_hint.visible, "Keyboard can read lower interpretation")
		await key(KEY_HOME)
		check(panel._scroll.scroll_vertical == 0, "Reading pane Home")
		if panel._read_hint.visible:
			var wheel := InputEventMouseButton.new()
			wheel.position = panel._scroll.get_global_rect().get_center()
			wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
			wheel.pressed = true
			Input.parse_input_event(wheel)
			await settle()
			wheel = wheel.duplicate()
			wheel.pressed = false
			Input.parse_input_event(wheel)
			check(panel._scroll.scroll_vertical > 0, "Mouse wheel reads interpretation")
			panel._scroll.scroll_vertical = 0
			await touch_drag(panel._scroll)
			check(panel._scroll.scroll_vertical > 0, "Touch drag reads interpretation")
			panel._scroll.scroll_vertical = 0
		for target in [panel._sources_button, panel._speaker, panel._close, panel._concepts[0]]:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == target, "Tab order")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._close, "Shift Tab")
		for touch in [false, true]:
			for role in [1, 2, 3, 0, 3]:
				await pointer(panel._overview if role == 0 else panel._concepts[role - 1], touch)
			await finish(panel)
			assert_state(panel, 3)
			await pointer(panel._speaker, touch)
			await create_timer(0.20).timeout
			check(panel._audio.playing and panel._speaker.text == "PAUSE", "Listen starts")
			var position: float = panel._audio.get_playback_position()
			await pointer(panel._photo_frame, touch)
			await pointer(panel._concepts[1], touch)
			await pointer(panel._overview, touch)
			await finish(panel)
			check(panel._audio.get_playback_position() >= position, "Role/photo/Overview do not restart narration")
			await pointer(panel._speaker, touch)
			await create_timer(0.1).timeout
			position = panel._audio.get_playback_position()
			check(panel._audio.stream_paused and panel._speaker.text == "RESUME", "Pause")
			panel.select_role(3)
			panel.show_photo(2)
			await finish(panel)
			await pointer(panel._sources_button, touch)
			# At compact sizes the modal's Close Sources button occupies the
			# background ribbon coordinates; clicking there legitimately closes it.
			panel._concepts[0].pressed.emit()
			await pointer(panel._photo_frame, touch)
			panel.select_role(0)
			panel.show_next_photo()
			check(panel._sources.visible and panel.current_role == 3 and panel.current_photo_index == 2, "Sources shields role and photo")
			check(panel._audio.stream_paused and is_equal_approx(panel._audio.get_playback_position(), position), "Sources and selection preserve pause position")
			await key(KEY_ESCAPE)
			check(not panel._sources.visible and panel._open, "Escape closes Sources first")
			assert_state(panel, 3, 2)
			await pointer(panel._speaker, touch)
			check(panel._audio.playing and not panel._audio.stream_paused, "Resume")
			await pointer(panel._sources_button, touch)
			await pointer(panel._source_close, touch)
			var before := closes
			await pointer(panel._close, touch)
			check(closes == before + 1 and not panel._open and not panel._audio.playing and not panel._audio.stream_paused, "Single close signal; audio stops")
			await pointer(trigger, touch)
			await finish(panel)
			assert_state(panel, 0)
			check(not panel._sources.visible and panel._audio.get_playback_position() == 0, "Reopen resets Sources and audio")
		panel._sources_button.grab_focus()
		await key(KEY_SPACE)
		await key(KEY_TAB)
		check(panel._sources.visible and root.gui_get_focus_owner() == panel._source_scroll, "Sources keyboard focus trap")
		await touch_drag(panel._source_scroll)
		check(panel._source_scroll.scroll_vertical > 0, "Touch drag reads Sources")
		panel._source_scroll.grab_focus()
		await key(KEY_END)
		check(panel._source_scroll.scroll_vertical >= panel._source_scroll.get_v_scroll_bar().max_value - panel._source_scroll.size.y, "Keyboard reaches final media credit")
		await capture("%dx%d_sources_end" % [dimensions.x, dimensions.y])
		await key(KEY_HOME)
		check(panel._source_scroll.scroll_vertical == 0, "Sources Home")
		await key(KEY_ESCAPE)
		panel._speaker.grab_focus()
		await key(KEY_ENTER)
		await create_timer(0.1).timeout
		await key(KEY_SPACE)
		check(panel._audio.stream_paused, "Keyboard narration pause")
		panel.select_role(3)
		panel.show_next_photo()
		await key(KEY_ESCAPE)
		check(not panel._open and not panel._audio.stream_paused and panel.active_role_transition == null and panel.active_photo_transition == null and panel._reveal == null, "Escape interrupts and cancels all transitions")
		panel.open_hotspot()
		panel.select_role(3)
		panel.show_next_photo()
		panel.open_sources()
		panel.reset_hotspot()
		await finish(panel)
		assert_state(panel, 0)
		check(not panel._sources.visible, "Explicit reset from modal")
		panel.close_hotspot()
		print("CR-EXT-03 ", dimensions, " complete; failures=", failures)
	panel.open_hotspot()
	panel.select_role(3)
	panel.show_photo(3)
	await finish(panel)
	root.size = Vector2i(1280, 720)
	await settle()
	assert_state(panel, 3, 3)
	assert_layout(panel)
	panel.toggle_narration()
	await create_timer(0.1).timeout
	panel.open_sources()
	panel.hide()
	check(not panel._open and not panel._audio.playing and not panel._sources.visible, "Host hide stops audio and modal")
	# Allow the asynchronous audio mixer to release the last stopped stream.
	await create_timer(0.15).timeout
	preview.queue_free()
	await settle()
	print("CR-EXT-03: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)

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
