extends SceneTree
## Production scene tests: four views, three features, real GUI events and media.
var failures: int = 0
var checks: int = 0
var closes: int = 0
const HEADINGS := ["Spanish Colonial Architecture with Georgian Influence", "Thick Masonry Walls", "Wooden Balcony", "Piedra China Staircase"]
const KEYS := ["", "ADOBE · BRICK · STONE", "FAÇADE DETAIL", "GRANITE STAIRCASE"]
const LABELS := ["MASONRY WALLS", "WOODEN BALCONY", "PIEDRA CHINA STAIRCASE"]
const COMPACT := ["MASONRY", "BALCONY", "PIEDRA CHINA"]
const CAPTIONS := ["Casa Real — Full Façade", "Masonry Detail", "Wooden Balcony", "Piedra China Staircase"]
const IMAGES := ["res://assets/landmarks/casa_real/exterior/cr_ext_01_facade.png", "res://assets/landmarks/casa_real/exterior/architecture/cr_ext_02_masonry.jpg", "res://assets/landmarks/casa_real/exterior/architecture/cr_ext_02_balcony.png", "res://assets/landmarks/casa_real/exterior/architecture/cr_ext_02_piedra_china.jpg"]
const BODIES := [
	"Casa Real is a two-storey stone-and-brick masonry structure. Among its documented architectural features are its thick masonry walls, wooden balcony, and piedra china staircase.",
	"Casa Real's thick adobe and brick walls form part of its stone-and-brick masonry construction and were designed for durability.",
	"The wooden balcony is one of Casa Real's documented architectural features and is a prominent exterior element of the building.",
	"Casa Real includes a piedra china staircase, a granite staircase that forms part of the building's documented architectural character."
]

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 5:
		await process_frame

func finish(panel) -> void:
	for tween in [panel._transition, panel._reveal]:
		if tween != null and tween.is_valid():
			tween.pause()
			tween.custom_step(2.0)
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

func assert_state(panel, expected: int) -> void:
	check(panel.current_state == expected and panel.get_selected_concept() == expected, "Authoritative architecture state")
	check(panel._heading.text == HEADINGS[expected] and panel._body.text == BODIES[expected], "Exact approved interpretation")
	check(panel._key.text == KEYS[expected] and panel._key.visible == (expected != 0), "Correct feature key")
	check(panel._caption.text == CAPTIONS[expected], "Correct documentary caption")
	check(panel._image.texture.resource_path == IMAGES[expected], "Correct supplied photograph")
	check(panel._image.scale == Vector2.ONE and panel._image.rotation == 0.0, "Unaltered image transform")
	check(panel._transition == null and panel._interpretation.modulate.a == 1.0 and panel._image.modulate.a == 1.0 and panel._caption.modulate.a == 1.0, "No stale transition or opacity")
	check(panel._concepts.size() == 3, "Exactly three feature selectors")
	for i in 3:
		check(panel._concepts[i].button_pressed == (i + 1 == expected), "Only selected feature; none in overview")
		check(panel._concepts[i].text == (COMPACT[i] if panel.size.x < 900 else LABELS[i]), "Approved responsive selector label")
	check(not panel._full_view.toggle_mode, "Full View is contextual navigation")

func assert_layout(panel) -> void:
	var main: Control = panel.get_node("Main")
	var share := 0.96 if panel.size.x < 900 else 0.90
	check(main.size.is_equal_approx(panel.size * share), "Inset dimensions: %s in %s" % [main.size, panel.size])
	check(main.get_global_rect().get_center().distance_to(panel.get_global_rect().get_center()) < 1, "Centered Main")
	check(main.position.x > 0 and main.position.y > 0 and main.get_rect().end.x < panel.size.x and main.get_rect().end.y < panel.size.y, "Margins on all sides")
	var bounds: Rect2 = main.get_global_rect().grow(0.5)
	for control in panel._concepts + [panel._full_view, panel._sources_button, panel._speaker, panel._close]:
		check(control.size.y >= 56 and control.size.x >= 48, "Touch targets remain large")
		check(bounds.encloses(control.get_global_rect()), "Control within visible Main")
	for label in [panel._title, panel._subtitle, panel._key, panel._heading, panel._body, panel._takeaway, panel._caption]:
		if label.visible:
			check(bounds.encloses(label.get_global_rect()), "Text fits Main: " + label.text)
			check(label.size.y >= label.get_minimum_size().y, "No clipped label height")
	check(panel._body.get_global_rect().end.y <= panel._takeaway.global_position.y, "Body clear of takeaway")
	check(panel._image.size.y >= 120 and panel._image.size.x >= 240, "Useful documentary viewing area")
	check(panel._image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED and panel._image.expand_mode == TextureRect.EXPAND_IGNORE_SIZE, "Contain entire photo at natural aspect")
	var photo_share: float = panel._viewer.size.x / (panel._viewer.size.x + panel._information.size.x)
	check(photo_share >= 0.58 and photo_share <= 0.62, "Dominant 58–62 percent viewer")
	check(panel._speaker.get_index() + 1 == panel._close.get_index() and panel._sources_button.get_index() + 1 == panel._speaker.get_index(), "Sources Listen Close adjacency")
	check(panel._concepts[0].get_theme_stylebox("focus") != panel._concepts[0].get_theme_stylebox("pressed"), "Focus distinct from selected")
	check(not panel._scroll.visible, "No whole-screen or interpretation scrolling")

func capture(name: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("akar_cr_ext_02_" + name + ".png")) == OK, "Captured screenshot")

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	create_timer(150.0).timeout.connect(func(): push_error("CR-EXT-02 timeout"); quit(1))
	root.content_scale_size = Vector2i.ZERO
	var preview = load("res://scenes/landmarks/casa_real/exterior/cr_ext_02_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("CR_EXT_02")
	var trigger: Button = preview.get_node("Reopen")
	panel.closed.connect(func(): closes += 1)
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		check(panel.open_hotspot(), "Open real production hotspot")
		await finish(panel)
		assert_state(panel, 0)
		check(not panel._audio.playing and not panel._audio.stream_paused and not panel._sources.visible, "No autoplay; overlays reset")
		check(panel._audio.stream.resource_path == "res://assets/landmarks/casa_real/audio/cr_ext_02_narration.ogg" and panel._audio.stream.get_length() > 0, "Actual imported CR-EXT-02 audio")
		check(panel._speaker.icon.resource_path == "res://assets/ui/icons/speaker.svg", "Existing AKAR speaker icon")
		for from_state in 4:
			for to_state in 4:
				panel.select_state(from_state)
				await finish(panel)
				await pointer(panel._full_view if to_state == 0 else panel._concepts[to_state - 1])
				await finish(panel)
				assert_state(panel, to_state)
		for state in 4:
			panel.select_state(state)
			await finish(panel)
			assert_layout(panel)
			await capture("%dx%d_state%d" % [dimensions.x, dimensions.y, state])
			panel.open_sources()
			check(panel.current_state == state and panel._image.texture.resource_path == IMAGES[state], "Sources preserves state/image")
			check(panel._source_text.text.contains(panel._entry().image_credit), "State photo attribution")
			await capture("%dx%d_sources%d" % [dimensions.x, dimensions.y, state])
			panel.close_sources()
		panel.select_state(-1)
		panel.select_state(4)
		assert_state(panel, 3)
		var old_tweens: Array[Tween] = []
		for state in [1, 3, 2, 0, 3, 1]:
			panel.select_state(state)
			panel._transition.pause()
			panel._transition.custom_step(0.07)
			old_tweens.append(panel._transition)
		await finish(panel)
		assert_state(panel, 1)
		for tween in old_tweens:
			check(not tween.is_valid(), "Previous transition cannot fire stale callback")
		panel._concepts[0].grab_focus()
		await key(KEY_DOWN)
		check(root.gui_get_focus_owner() == panel._concepts[1] and panel.current_state == 1, "Arrow focus does not select")
		await key(KEY_ENTER)
		await finish(panel)
		assert_state(panel, 2)
		await key(KEY_RIGHT)
		check(panel.current_state == 2 and root.gui_get_focus_owner() == panel._concepts[2], "Horizontal focus only")
		await key(KEY_SPACE)
		await finish(panel)
		assert_state(panel, 3)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._full_view, "Tab to Full View")
		await key(KEY_SPACE)
		await finish(panel)
		assert_state(panel, 0)
		panel._concepts[0].grab_focus()
		for target in [panel._concepts[1], panel._concepts[2], panel._full_view, panel._sources_button, panel._speaker, panel._close, panel._concepts[0]]:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == target, "Seven-control Tab order")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._close, "Shift Tab")
		for touch in [false, true]:
			for state in [1, 3, 2, 0, 3, 1, 1]:
				await pointer(panel._full_view if state == 0 else panel._concepts[state - 1], touch)
			await finish(panel)
			assert_state(panel, 1)
			await pointer(panel._speaker, touch)
			check(panel._audio.playing and panel._speaker.text == "PAUSE", "Listen starts actual audio")
			await create_timer(0.20).timeout
			var audio_position: float = panel._audio.get_playback_position()
			await pointer(panel._concepts[2], touch)
			await pointer(panel._full_view, touch)
			await finish(panel)
			check(panel._audio.get_playback_position() >= audio_position, "Feature and Full View do not restart/seek")
			await pointer(panel._speaker, touch)
			check(panel._audio.stream_paused and panel._speaker.text == "RESUME", "Pause narration")
			# Pause is delivered to the audio mixer asynchronously; sample after it settles.
			await create_timer(0.1).timeout
			audio_position = panel._audio.get_playback_position()
			panel.select_state(2)
			await finish(panel)
			check(is_equal_approx(panel._audio.get_playback_position(), audio_position), "Paused position unchanged by selection")
			await pointer(panel._speaker, touch)
			check(panel._audio.playing and not panel._audio.stream_paused, "Resume narration")
			await pointer(panel._sources_button, touch)
			await pointer(panel._concepts[0], touch)
			await pointer(panel._full_view, touch)
			panel.select_state(0)
			check(panel._sources.visible and panel.current_state == 2, "Sources shields feature and Full View")
			await key(KEY_ESCAPE)
			check(not panel._sources.visible and panel._open and panel.current_state == 2, "Escape dismisses Sources first")
			await pointer(panel._sources_button, touch)
			await pointer(panel._source_close, touch)
			check(not panel._sources.visible and panel.current_state == 2, "Pointer close Sources preserves view")
			var before_close := closes
			await pointer(panel._close, touch)
			check(closes == before_close + 1 and not panel._open and not panel._audio.playing and not panel._audio.stream_paused, "Close signal once and audio stopped")
			await pointer(trigger, touch)
			await finish(panel)
			assert_state(panel, 0)
			check(not panel._sources.visible and panel._audio.get_playback_position() == 0 and panel._speaker.text == "LISTEN", "Reopen restores media lifecycle")
		panel._sources_button.grab_focus()
		await key(KEY_SPACE)
		check(panel._sources.visible, "Keyboard Sources")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._source_scroll, "Modal focus stays inside Sources")
		await key(KEY_ESCAPE)
		panel._speaker.grab_focus()
		await key(KEY_ENTER)
		await create_timer(0.1).timeout
		await key(KEY_SPACE)
		check(panel._audio.stream_paused, "Keyboard pause")
		panel._close.grab_focus()
		await key(KEY_SPACE)
		check(not panel._audio.playing and not panel._audio.stream_paused, "Close resets paused narration")
		panel.open_hotspot()
		panel.select_state(3)
		await key(KEY_ESCAPE)
		check(not panel._open and panel._transition == null and panel._reveal == null, "Close interrupts opening and feature transitions")
		panel.open_hotspot()
		await finish(panel)
		assert_state(panel, 0)
		panel.close_hotspot()
		print("CR-EXT-02 ", dimensions, " complete; failures=", failures)
	# Future overlay host sizing, hide cleanup and orientation-return stability.
	panel.open_hotspot()
	panel.select_state(2)
	await finish(panel)
	root.size = Vector2i(480, 854)
	await settle()
	root.size = Vector2i(1280, 720)
	await settle()
	assert_state(panel, 2)
	assert_layout(panel)
	panel._concepts[2].grab_focus()
	await key(KEY_TAB)
	check(root.gui_get_focus_owner() == panel._full_view, "Focus paths survive reparent on resize")
	panel.toggle_narration()
	await create_timer(0.1).timeout
	panel.open_sources()
	panel.hide()
	check(not panel._open and not panel._audio.playing and not panel._sources.visible, "Host hiding cleans up overlay/audio")
	panel.open_hotspot()
	await finish(panel)
	assert_state(panel, 0)
	preview.queue_free()
	await settle()
	print("CR-EXT-02: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)
