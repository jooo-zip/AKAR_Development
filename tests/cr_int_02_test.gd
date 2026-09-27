extends SceneTree
## Exercises the real F6 scene, native input events and real video completion.
const IDS := ["G01", "G02", "G03", "G04", "G05A", "G05B", "G06A", "G06B", "G07", "G08", "G09", "G10", "G11"]
const TITLES := ["Where Asin and Bolo Embraced", "The Shape of Our Homeland", "Asin Gallery & Dayat Exhibit", "Watered by the Hands of Ama-Gaolay", "The Descendants of Apolaqui", "Desired by the Sea Merchants", "Patriots and Nation Builders", "Frontrunner of Modernization", "Festivals by the Sea and the Fields", "Beachhead of Valor", "The Pilgrims Who Responded to the Call", "Sung Romances under the Guava Tree", "Luminaries of Anacbanuas"]
var checks: int = 0
var failures: int = 0
var external_urls: Array[String] = []
var close_count: int = 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for frame in 5: await process_frame

func finish(panel) -> void:
	for tween in [panel._transition, panel._media_transition, panel._trail.tween]:
		if tween != null and tween.is_valid():
			tween.pause()
			tween.custom_step(1.0)
	await settle()

func capture(label: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("akar_cr_int_02_" + label + ".png")) == OK, "Rendered capture " + label)

func pointer(control: Control, touch: bool = false) -> void:
	await tap_at(control.get_global_rect().get_center(), touch)

func tap_at(at: Vector2, touch: bool) -> void:
	var event: InputEvent = InputEventScreenTouch.new() if touch else InputEventMouseButton.new()
	event.position = at
	if not touch: event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
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

func drag(control: Control, motion: Vector2, touch: bool) -> void:
	var origin := control.get_global_rect().get_center()
	var event: InputEvent = InputEventScreenTouch.new() if touch else InputEventMouseButton.new()
	event.position = origin
	event.pressed = true
	if not touch: event.button_index = MOUSE_BUTTON_LEFT
	Input.parse_input_event(event)
	await process_frame
	for step in range(1, 6):
		var move: InputEvent = InputEventScreenDrag.new() if touch else InputEventMouseMotion.new()
		move.position = origin + motion * step / 5.0
		move.relative = motion / 5.0
		if not touch: move.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(move)
		await process_frame
	event = event.duplicate()
	event.position = origin + motion
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func assert_photo(panel, index: int) -> void:
	check(panel.selected_gallery_index == index, "Authoritative index")
	check(panel._gallery_title.text == TITLES[index], "Exact approved title")
	check(panel._image.texture == panel.content.galleries[index].preview_texture, "Correct photograph")
	check(panel.preview_mode == panel.PreviewMode.PHOTO and panel._image.visible and not panel._video.visible, "Stable photograph default")
	check(not panel._video.is_playing() and panel._video.stream == null, "No stale video stream")
	check(panel._trail.selected == index, "Trail selection agrees")
	check(panel._image.modulate.a == 1.0 and panel._actions.modulate.a == 1.0, "Stable opacity")

func assert_layout(panel) -> void:
	var main: Control = panel.get_node("Main")
	var bounds := main.get_global_rect().grow(0.6)
	check(main.size.is_equal_approx(panel.size * (0.96 if panel.size.x < 1100 else 0.9)), "Inset follows viewport: %s" % main.size)
	check(main.get_global_rect().get_center().distance_to(panel.get_global_rect().get_center()) < 1, "Centered inset")
	for control in [panel._title, panel._subtitle, panel._sources_button, panel._speaker, panel._close, panel._directory, panel._preview, panel._focus_view]:
		if control.is_visible_in_tree(): check(bounds.encloses(control.get_global_rect()), "Contained " + str(control))
	for button in [panel._sources_button, panel._speaker, panel._close, panel._watch, panel._view_photo, panel._directory_button, panel._continue, panel._enter, panel._previous, panel._next, panel._open_preview, panel._focus_close]:
		check(button.custom_minimum_size.y >= 56, "Minimum touch height")
	check(panel._speaker.get_index() + 1 == panel._close.get_index(), "Listen immediately left of Close")
	if panel.current_view == panel.ViewState.PREVIEW:
		check(panel._media.size.x >= 400 and panel._media.size.y >= 250, "Useful media size")
		check(panel._actions_scroll.size.x >= 240, "Readable actions column")
		check(panel._image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Photo contain")
		check(panel._actions_scroll.get_h_scroll_bar().max_value <= panel._actions_scroll.size.x + 1, "No horizontal actions overflow")

func run() -> void:
	create_timer(420).timeout.connect(func() -> void: push_error("CR-INT-02 test timeout"); quit(1))
	root.content_scale_size = Vector2i.ZERO
	root.size = Vector2i(1280, 720)
	var preview = load("res://scenes/landmarks/casa_real/interior/cr_int_02_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("CR_INT_02")
	panel.close_requested.connect(func() -> void: close_count += 1)
	check(panel._url_opener == Callable(OS, "shell_open"), "Production external opener is OS.shell_open")
	panel._url_opener = func(url: String) -> Error:
		external_urls.append(url)
		return OK
	if "--visit-only" in OS.get_cmdline_user_args():
		for dimensions in [Vector2i(1280,720), Vector2i(960,540), Vector2i(854,480)]:
			root.size = dimensions
			await settle()
			await test_visit_modal(panel, dimensions)
		preview.queue_free()
		await settle()
		print("CR-INT-02 visit modal: ", checks, " checks; ", failures, " failures")
		quit(1 if failures else 0)
		return
	if "--navigation-only" in OS.get_cmdline_user_args():
		for dimensions in [Vector2i(1280,720), Vector2i(960,540), Vector2i(854,480)]:
			root.size = dimensions
			await settle()
			await test_preview_navigation(panel, dimensions)
		preview.queue_free()
		await settle()
		print("CR-INT-02 navigation: ", checks, " checks; ", failures, " failures")
		quit(1 if failures else 0)
		return
	check(panel.content.galleries.size() == 13 and panel._trail.plaques.size() == 13, "Thirteen directory entries")
	check(panel.content.overview_body.contains("11 principal gallery groupings"), "Approved group count")
	check(panel._audio.stream.resource_path.ends_with("cr_int_02_narration.ogg") and panel._audio.stream.get_length() > 0, "Real narration")
	for i in 13:
		var entry = panel.content.galleries[i]
		check(entry.gallery_id == IDS[i] and entry.official_title == TITLES[i], "Official order and title")
		check(entry.preview_texture.resource_path.get_file().get_basename() == "cr_int_02_" + IDS[i].to_lower(), "Unique photo mapping")
		check(entry.preview_video.resource_path.ends_with("cr_int_02_" + IDS[i].to_lower() + "_preview.ogv"), "Unique video mapping")
		check(not entry.media_credit.is_empty() and not entry.video_source.is_empty() and entry.optional_location_hint.is_empty(), "Traceable sources; no room geography")
	for dimensions in [Vector2i(1280,720), Vector2i(960,540), Vector2i(854,480)]:
		root.size = dimensions
		await settle()
		panel.open_hotspot()
		panel.reset_hotspot()
		await finish(panel)
		check(panel.current_view == panel.ViewState.DIRECTORY and panel.selected_gallery_index == 0 and not panel._audio.playing, "Reopen directory G01 without autoplay")
		assert_layout(panel)
		await capture("%dx%d_directory" % [dimensions.x, dimensions.y])
		for i in 13:
			panel.select_gallery(i, true)
			await finish(panel)
			assert_photo(panel, i)
			assert_layout(panel)
			await capture("%dx%d_%s_photo" % [dimensions.x, dimensions.y, IDS[i]])
			panel.toggle_glimpse()
			await create_timer(0.35).timeout
			check(panel._video.is_playing() and panel._video.stream == panel.content.galleries[i].preview_video, "Correct real video playing")
			check(panel._video.volume == 0 and not panel._video.loop and not panel._video.autoplay, "Muted manual single play")
			var texture: Texture2D = panel._video.get_video_texture()
			check(texture != null and texture.get_width() > 0, "Decoded video texture")
			if texture != null:
				check(absf(panel._video.size.aspect() - texture.get_size().aspect()) < 0.01, "Video aspect preserved")
			await capture("%dx%d_%s_video" % [dimensions.x, dimensions.y, IDS[i]])
			# Every clip finishes naturally once; other sizes exercise skip/replay.
			if dimensions.x == 1280:
				var started := Time.get_ticks_msec()
				while panel.preview_mode == panel.PreviewMode.VIDEO and Time.get_ticks_msec() - started < 10000:
					await process_frame
				print("CLIP ", IDS[i], " approximate seconds=", snappedf((Time.get_ticks_msec() - started) / 1000.0 + 0.35, 0.01))
				check(panel.preview_mode == panel.PreviewMode.PHOTO, "Natural video finish")
			else:
				panel.toggle_glimpse()
			await finish(panel)
			assert_photo(panel, i)
			check(panel._watch.text == "REPLAY GLIMPSE", "Replay available")
			panel.toggle_glimpse()
			await create_timer(0.1).timeout
			panel.toggle_glimpse()
			await finish(panel)
			assert_photo(panel, i)
			panel.open_image_focus()
			await finish(panel)
			check(panel.current_view == panel.ViewState.IMAGE_FOCUS and panel._focus_photo.texture == panel.content.galleries[i].preview_texture, "Same photo in Image Focus")
			assert_layout(panel)
			if i == 3: await capture("%dx%d_focus" % [dimensions.x, dimensions.y])
			await key(KEY_ESCAPE)
			check(panel.current_view == panel.ViewState.PREVIEW, "Escape from Image Focus")
			panel.toggle_glimpse()
			panel.select_gallery(mini(i + 1, 12), true)
			await finish(panel)
			assert_photo(panel, mini(i + 1, 12))
			panel.select_gallery(i, true)
			panel.continue_exploring()
			await finish(panel)
			check(panel.current_view == panel.ViewState.PREVIEW and panel.selected_gallery_index == (i + 1) % 13, "Continue opens next preview and wraps G11 to G01")
			panel.select_gallery(i, true)
			panel.toggle_glimpse()
			panel.close_hotspot()
			check(not panel._video.is_playing() and panel._video.stream == null, "Close during video stops stream")
			panel.open_hotspot()
			await finish(panel)
			assert_photo(panel, 0)
		for touch in [false, true]:
			panel.reset_hotspot()
			await finish(panel)
			await drag(panel._trail, Vector2(-90, 0), touch)
			await finish(panel)
			check(panel.selected_gallery_index == 1 and panel.current_view == panel.ViewState.DIRECTORY and not panel.trail_dragging, "Swipe selects without opening")
			await drag(panel._trail, Vector2(8, -65), touch)
			await finish(panel)
			check(panel.selected_gallery_index == 1, "Vertical gesture does not select")
			var neighbor: Control = panel._trail.plaques[2]
			var visible_rect := neighbor.get_global_rect().intersection(panel._trail.get_global_rect())
			await tap_at(visible_rect.get_center(), touch)
			await finish(panel)
			check(panel.selected_gallery_index == 2 and panel.current_view == panel.ViewState.PREVIEW, "Neighbor tap opens selected gallery")
			await pointer(panel._watch, touch)
			check(panel.preview_mode == panel.PreviewMode.VIDEO, "Pointer Watch")
			await pointer(panel._watch, touch)
			await finish(panel)
			assert_photo(panel, 2)
			await pointer(panel._view_photo, touch)
			await finish(panel)
			check(panel.current_view == panel.ViewState.IMAGE_FOCUS, "Pointer View Photo")
			await pointer(panel._focus_close, touch)
			await pointer(panel._speaker, touch)
			await create_timer(0.2).timeout
			check(panel._audio.playing, "Narration starts deliberately")
			await pointer(panel._speaker, touch)
			# Wait for the audio mixer to acknowledge pause before sampling position.
			await create_timer(0.1).timeout
			var audio_position: float = panel._audio.get_playback_position()
			panel.toggle_glimpse()
			panel.open_sources()
			await settle()
			check(panel._audio.stream_paused and is_equal_approx(panel._audio.get_playback_position(), audio_position), "Sources/video preserve narration position: paused=%s before=%s after=%s" % [panel._audio.stream_paused, audio_position, panel._audio.get_playback_position()])
			check(panel.preview_mode == panel.PreviewMode.PHOTO and not panel._video.is_playing(), "Sources stabilizes video")
			panel.select_gallery(12, true)
			check(panel.selected_gallery_index == 2, "Sources blocks selection")
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == panel._source_scroll, "Sources focus trap")
			await drag(panel._source_scroll, Vector2(0,-75), true)
			check(panel._source_scroll.scroll_vertical > 0, "Touch scroll Sources")
			await capture("%dx%d_sources" % [dimensions.x, dimensions.y])
			await key(KEY_ESCAPE)
			check(not panel._sources.visible and panel.current_view == panel.ViewState.PREVIEW, "Sources Escape hierarchy")
			await pointer(panel._speaker, touch)
			check(panel._audio.playing and not panel._audio.stream_paused, "Narration resumes")
			panel._actions_scroll.ensure_control_visible(panel._directory_button)
			await settle()
			await pointer(panel._directory_button, touch)
			check(panel.current_view == panel.ViewState.DIRECTORY and panel.selected_gallery_index == 2, "Return retains gallery")
			panel.select_gallery(7, true)
			await finish(panel)
			panel._actions_scroll.ensure_control_visible(panel._continue)
			await settle()
			await pointer(panel._continue, touch)
			await finish(panel)
			check(panel.current_view == panel.ViewState.PREVIEW and panel.selected_gallery_index == 8, "Pointer Continue Exploring stays in Preview")
			panel.select_gallery(9, true)
			await finish(panel)
			panel._actions_scroll.ensure_control_visible(panel._enter)
			await settle()
			await pointer(panel._enter, touch)
			check(panel._visit_modal.visible and panel._open and panel.selected_gallery_index == 9, "Enter Gallery opens visit invitation over G08")
			await pointer(panel._visit_back, touch)
			check(not panel._visit_modal.visible and panel.current_view == panel.ViewState.PREVIEW and panel.selected_gallery_index == 9, "Back restores G08 Preview")
			panel.close_hotspot()
			await pointer(preview.get_node("Reopen"), touch)
			await finish(panel)
			check(panel._open and panel.selected_gallery_index == 0 and not panel._audio.playing, "Pointer reopen resets")
		panel._trail.grab_focus()
		for code in [KEY_END, KEY_LEFT, KEY_HOME, KEY_RIGHT]:
			await key(code)
			await finish(panel)
			var expected: int = {KEY_END:12, KEY_LEFT:11, KEY_HOME:0, KEY_RIGHT:1}[code]
			check(panel.selected_gallery_index == expected and panel.current_view == panel.ViewState.DIRECTORY, "Keyboard directory navigation")
		await key(KEY_SPACE)
		await finish(panel)
		check(panel.current_view == panel.ViewState.PREVIEW, "Keyboard opens preview")
		panel._watch.grab_focus()
		await key(KEY_ENTER)
		check(panel._video.is_playing(), "Keyboard Watch")
		await key(KEY_SPACE)
		await finish(panel)
		check(not panel._video.is_playing(), "Keyboard Skip")
		panel._close.grab_focus()
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._media, "Tab wraps")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._close, "Shift Tab wraps")
		for i in [0,1,4,9,2,9,10,6]:
			panel.select_gallery(i, true)
			panel.toggle_glimpse()
		panel.return_to_directory()
		await finish(panel)
		assert_photo(panel, 6)
		check(panel.current_view == panel.ViewState.DIRECTORY, "Rapid changes settle")
		panel.select_gallery(6, true)
		panel.open_image_focus()
		panel.open_sources()
		await key(KEY_ESCAPE)
		check(panel.current_view == panel.ViewState.IMAGE_FOCUS, "Sources preserves Image Focus")
		await key(KEY_ESCAPE)
		await key(KEY_ESCAPE)
		await key(KEY_ESCAPE)
		check(not panel._open and not panel._audio.playing and not panel.trail_dragging, "Full Escape hierarchy")
		await test_visit_modal(panel, dimensions)
		await test_preview_navigation(panel, dimensions)
		print("CR-INT-02 ", dimensions, " complete; failures=", failures)
	panel.open_hotspot()
	panel.select_gallery(3, true)
	panel.toggle_glimpse()
	panel.hide()
	check(not panel._open and not panel._video.is_playing(), "Host hide cleans up")
	preview.queue_free()
	await settle()
	print("CR-INT-02: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)

func test_visit_modal(panel, dimensions: Vector2i) -> void:
	panel.open_hotspot()
	panel.reset_hotspot()
	panel.select_gallery(9, true)
	await finish(panel)
	panel.toggle_narration()
	await create_timer(0.15).timeout
	var narration_position: float = panel._audio.get_playback_position()
	var trail_position: float = panel._trail.position_index
	var photo: Texture2D = panel._image.texture
	var before_urls := external_urls.size()
	panel.toggle_glimpse()
	panel._actions_scroll.ensure_control_visible(panel._enter)
	await settle()
	panel._enter.grab_focus()
	await key(KEY_ENTER)
	await finish(panel)
	check(panel._visit_modal.visible and panel._open and panel.current_view == panel.ViewState.PREVIEW, "Keyboard Enter opens visit modal")
	check(panel.selected_gallery_index == 9 and panel._image.texture == photo and panel._trail.position_index == trail_position, "Invitation preserves gallery/photo/trail")
	check(panel.preview_mode == panel.PreviewMode.PHOTO and panel._video.stream == null and not panel._video.is_playing(), "Invitation resets video to photo")
	check(panel.video_has_played, "Invitation preserves replay state")
	check(panel._audio.playing and not panel._audio.stream_paused and panel._audio.get_playback_position() >= narration_position, "Invitation preserves playing narration")
	check(external_urls.size() == before_urls, "Opening invitation never opens links automatically")
	check(panel._visit_title.text == "ENTER THE FULL EXPERIENCE AT BANÁAN", "Exact invitation title")
	check(panel._visit_body.text == "You’ve seen a glimpse of this gallery in AKAR.\n\nVisit the Banáan Pangasinan Provincial Museum to experience the complete exhibits, artifacts, and curatorial narratives in person.", "Exact invitation body")
	check(panel.content.reservation_heading == "Online Reservation" and panel.content.visitor_info_heading == "Visitor Information" and panel.content.museum_inquiries_heading == "Museum inquiries", "Exact section labels")
	check(panel._reservation_link.text == "banaan.seepangasinan.com/online-reservation/" and panel._visitor_info_link.text == "banaan.seepangasinan.com/visitor-guidelines/", "Exact visible URL labels")
	check(panel.content.museum_phone == "(075) 511-9821" and panel.content.museum_email == "banaanppm@gmail.com", "Exact museum contact")
	check(panel._visit_back.text == "BACK", "Back label")
	var bounds: Rect2 = panel.get_node("Main").get_global_rect()
	check(bounds.encloses(panel._visit_panel.get_global_rect()), "Visit modal inside existing inset: panel=%s minimum=%s bounds=%s" % [panel._visit_panel.get_global_rect(), panel._visit_panel.get_combined_minimum_size(), bounds])
	check(bounds.get_center().distance_to(panel._visit_panel.get_global_rect().get_center()) < 1, "Visit modal centered")
	check(panel._visit_panel.get_global_rect().encloses(panel._visit_back.get_global_rect()), "Back always reachable")
	for link in [panel._reservation_link, panel._visitor_info_link]:
		check(link is LinkButton and link.custom_minimum_size.y >= 48 and link.underline == LinkButton.UNDERLINE_MODE_ALWAYS, "Text link with padded touch target")
	check(panel._visit_scroll.get_h_scroll_bar().max_value <= panel._visit_scroll.size.x + 1, "Visit URLs fit without horizontal scrolling")
	if dimensions.x >= 960:
		check(panel._visit_scroll.get_v_scroll_bar().max_value <= panel._visit_scroll.size.y + 1, "No modal text scrolling at larger sizes")
	await capture("%dx%d_visit" % [dimensions.x, dimensions.y])
	panel.select_gallery(1, true)
	panel.continue_exploring()
	panel.return_to_directory()
	panel.open_image_focus()
	panel.toggle_glimpse()
	panel.toggle_narration()
	await pointer(panel._media)
	check(panel._visit_modal.visible and panel.selected_gallery_index == 9 and panel.current_view == panel.ViewState.PREVIEW and panel.preview_mode == panel.PreviewMode.PHOTO, "Modal blocks underlying actions and pointer")
	check(panel._audio.playing and not panel._audio.stream_paused, "Underlying narration control blocked")
	panel._reservation_link.grab_focus()
	await key(KEY_TAB)
	check(root.gui_get_focus_owner() == panel._visitor_info_link, "Modal Tab to information link")
	await key(KEY_TAB)
	check(root.gui_get_focus_owner() == panel._visit_back, "Modal Tab to Back")
	await key(KEY_TAB)
	check(root.gui_get_focus_owner() == panel._reservation_link, "Modal focus wraps")
	await key(KEY_TAB, true)
	check(root.gui_get_focus_owner() == panel._visit_back, "Modal reverse focus wraps")
	for touch in [false, true]:
		for link in [panel._reservation_link, panel._visitor_info_link]:
			panel._visit_scroll.ensure_control_visible(link)
			await settle()
			var count := external_urls.size()
			await pointer(link, touch)
			check(external_urls.size() == count + 1, "Deliberate mouse/touch link opens once")
			var expected: String = panel.content.reservation_url if link == panel._reservation_link else panel.content.visitor_info_url
			check(external_urls.back() == expected, "Exact external link request")
	for code in [KEY_ENTER, KEY_SPACE]:
		for link in [panel._reservation_link, panel._visitor_info_link]:
			link.grab_focus()
			await settle()
			var count := external_urls.size()
			await key(code)
			check(external_urls.size() == count + 1, "Keyboard link activates exactly once")
	check(panel.content.reservation_url == "https://banaan.seepangasinan.com/online-reservation/" and panel.content.visitor_info_url == "https://banaan.seepangasinan.com/visitor-guidelines/", "Approved external targets")
	panel._open_visit_link("https://example.invalid/")
	check(external_urls.back() == panel.content.visitor_info_url, "Only supplied targets accepted")
	panel.open_sources()
	await key(KEY_ESCAPE)
	check(not panel._sources.visible and panel._visit_modal.visible and root.gui_get_focus_owner() == panel._reservation_link, "Sources retains Escape priority")
	await key(KEY_ESCAPE)
	check(not panel._visit_modal.visible and panel.current_view == panel.ViewState.PREVIEW and panel.selected_gallery_index == 9 and root.gui_get_focus_owner() == panel._enter, "Escape returns to G08 Preview and Enter focus")
	panel.toggle_narration()
	await create_timer(0.1).timeout
	narration_position = panel._audio.get_playback_position()
	panel._enter.grab_focus()
	await key(KEY_SPACE)
	check(panel._visit_modal.visible, "Keyboard Space opens invitation")
	await pointer(panel._visit_back, true)
	check(not panel._visit_modal.visible and panel.selected_gallery_index == 9 and panel.current_view == panel.ViewState.PREVIEW, "Touch Back preserves G08")
	check(panel._audio.stream_paused and is_equal_approx(panel._audio.get_playback_position(), narration_position), "Back preserves paused narration position")
	panel._open_visit_banaan_modal()
	panel.close_hotspot()
	panel.open_hotspot()
	await finish(panel)
	check(not panel._visit_modal.visible and panel.selected_gallery_index == 0 and panel.current_view == panel.ViewState.DIRECTORY, "Close/reopen clears invitation")
	check(not panel._audio.playing, "Reopen retains narration reset")
	print("Visit modal ", dimensions, " complete; failures=", failures)

func test_preview_navigation(panel, dimensions: Vector2i) -> void:
	panel.open_hotspot()
	panel.reset_hotspot()
	panel.select_gallery(0, true)
	await finish(panel)
	var tracking := {"active": true}
	var on_directory_visibility := func() -> void:
		if tracking.active:
			check(not panel._directory.visible, "Continue never briefly reveals Directory")
	panel._directory.visibility_changed.connect(on_directory_visibility)
	# Two complete cycles validate every adjacency, A/B subdivision and wrap.
	for step in 26:
		panel.continue_exploring()
		var expected := (step + 1) % 13
		check(panel.current_view == panel.ViewState.PREVIEW and not panel._directory.visible, "Continue remains in Preview synchronously")
		await finish(panel)
		assert_photo(panel, expected)
		check(panel._watch.text == "WATCH GLIMPSE" and not panel.video_has_played, "Next gallery starts with manual Watch Glimpse")
		check(panel._transition == null, "No stale preview transition")
		check(panel._entry().preview_video.resource_path.ends_with("cr_int_02_" + IDS[expected].to_lower() + "_preview.ogv"), "Next gallery video mapping")
		if step == 12: await capture("%dx%d_continue_wrap" % [dimensions.x, dimensions.y])
	# Fast consecutive requests must settle at the last requested gallery.
	for start in [3, 11]:
		panel.select_gallery(start, true)
		var abandoned: Array[Tween] = []
		for request in 3:
			abandoned.append(panel._transition)
			panel.continue_exploring()
			check(panel.current_view == panel.ViewState.PREVIEW and not panel._directory.visible, "Rapid Continue never leaves Preview")
		await finish(panel)
		assert_photo(panel, (start + 3) % 13)
		for tween in abandoned:
			check(not tween.is_valid(), "Replaced preview tween killed")
	# Real G07 video: Continue after playing, skip, replay and natural completion.
	for mode in ["playing", "skip", "replay", "finished"]:
		panel.select_gallery(8, true)
		await finish(panel)
		panel.stop_narration()
		panel.toggle_narration()
		panel.toggle_glimpse()
		await create_timer(0.15).timeout
		if mode in ["skip", "replay"]:
			panel.toggle_glimpse()
			if mode == "replay": panel.toggle_glimpse()
		elif mode == "finished":
			var started := Time.get_ticks_msec()
			while panel.preview_mode == panel.PreviewMode.VIDEO and Time.get_ticks_msec() - started < 10000:
				await process_frame
			check(panel.preview_mode == panel.PreviewMode.PHOTO, "G07 naturally completes before Continue")
		var position_before: float = panel._audio.get_playback_position()
		panel.continue_exploring()
		check(panel._video.stream == null and not panel._video.is_playing(), "Continue immediately clears prior video")
		await finish(panel)
		assert_photo(panel, 9)
		check(panel._audio.playing and not panel._audio.stream_paused and panel._audio.get_playback_position() >= position_before, "Continue preserves running narration")
		check(panel._watch.text == "WATCH GLIMPSE", "G08 does not inherit replay helper")
		panel.toggle_glimpse()
		check(panel._video.stream == panel.content.galleries[9].preview_video, "G08 Watch uses G08 clip")
		panel.toggle_glimpse()
	panel.stop_narration()
	panel.toggle_narration()
	await create_timer(0.15).timeout
	panel.toggle_narration()
	await create_timer(0.1).timeout
	var paused_position: float = panel._audio.get_playback_position()
	panel.continue_exploring()
	await finish(panel)
	check(panel._audio.stream_paused and is_equal_approx(panel._audio.get_playback_position(), paused_position), "Continue preserves paused narration")
	panel.open_image_focus()
	panel.continue_exploring()
	check(panel.current_view == panel.ViewState.IMAGE_FOCUS and panel.selected_gallery_index == 10 and not panel._continue.is_visible_in_tree(), "Continue unavailable in Image Focus")
	panel.close_image_focus()
	panel.open_sources()
	panel.continue_exploring()
	check(panel.selected_gallery_index == 10 and panel._sources.visible, "Sources blocks Continue")
	panel.close_sources()
	panel._open_visit_banaan_modal()
	panel.continue_exploring()
	check(panel.selected_gallery_index == 10 and panel._visit_modal.visible, "Visit modal blocks Continue")
	panel._close_visit_banaan_modal()
	tracking.active = false
	# Return keeps the current gallery centered, including G11 without wrapping.
	for index in [3, 12]:
		panel.select_gallery(index, true)
		panel.toggle_glimpse()
		panel.return_to_directory()
		await finish(panel)
		check(panel.current_view == panel.ViewState.DIRECTORY and panel.selected_gallery_index == index, "Return preserves current gallery")
		check(is_equal_approx(panel._trail.position_index, float(index)), "Return centers same gallery")
		assert_photo(panel, index)
		panel.select_gallery(11, true)
		await finish(panel)
		assert_photo(panel, 11)
	# Both controls remain reachable with each input method at each viewport.
	for input_method in ["mouse", "touch", "enter", "space"]:
		panel.select_gallery(12, true)
		await finish(panel)
		for button in [panel._continue, panel._directory_button]:
			panel._actions_scroll.ensure_control_visible(button)
			await settle()
			check(panel._actions_scroll.get_global_rect().grow(1).encloses(button.get_global_rect()), "Navigation control reachable")
			if input_method in ["mouse", "touch"]:
				await pointer(button, input_method == "touch")
			else:
				button.grab_focus()
				await key(KEY_ENTER if input_method == "enter" else KEY_SPACE)
			await finish(panel)
			if button == panel._continue:
				check(panel.current_view == panel.ViewState.PREVIEW and panel.selected_gallery_index == 0, "Input Continue wraps to G01 Preview")
			else:
				check(panel.current_view == panel.ViewState.DIRECTORY and panel.selected_gallery_index == 0, "Input Return preserves G01")
	for button in panel._actions.get_children():
		if button is BaseButton:
			check(not button.text.to_lower().contains("previous") and not button.text.contains("←"), "No Previous Gallery control in Preview")
	panel._directory.visibility_changed.disconnect(on_directory_visibility)
	panel.stop_narration()
	print("Preview navigation ", dimensions, " complete; failures=", failures)
