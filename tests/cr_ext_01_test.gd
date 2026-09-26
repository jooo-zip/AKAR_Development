extends SceneTree
## Real GUI input and rendered layout checks for the production F6 instance.
var failures: int = 0
var checks: int = 0
var closes: int = 0
const HEADINGS := ["The Royal House", "Residence and Office of the Alcalde Mayor", "Banáan Pangasinan Provincial Museum"]
const KEYS := ["1840", "PROVINCIAL GOVERNMENT", "PRESENT DAY"]
const LABELS := ["ROYAL HOUSE", "GOVERNMENT CENTER", "BANÁAN TODAY"]
const BODIES := [
	"Casa Real, meaning “Royal House,” was constructed in 1840 during the Spanish colonial period.",
	"Casa Real served as the residence and office of the Alcalde Mayor and supported Pangasinan's provincial administrative and judicial functions.",
	"Today, the restored Casa Real houses the Banáan Pangasinan Provincial Museum, continuing its public role through heritage preservation and education."
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
	check(panel.current_state == expected and panel.get_selected_concept() == expected, "Authoritative state")
	check(panel._key.text == KEYS[expected], "Exact key")
	check(panel._heading.text == HEADINGS[expected], "Exact heading")
	check(panel._body.text == BODIES[expected], "Exact approved body")
	check(panel._interpretation.modulate.a == 1.0 and panel._transition == null, "No stale transition or opacity")
	check(panel._image.texture.resource_path == "res://assets/landmarks/casa_real/exterior/cr_ext_01_facade.png", "Same researcher photo")
	for i in 3:
		check(panel._concepts[i].button_pressed == (i == expected), "One selected card")
		check(panel._concepts[i].text == LABELS[i], "Full selector wording")

func assert_layout(panel) -> void:
	var main: Control = panel.get_node("Main")
	var bounds: Rect2 = main.get_global_rect().grow(0.5)
	var expected_share := 0.96 if panel.size.x < 900 else 0.90
	check(main.size.is_equal_approx(panel.size * expected_share), "Responsive inset panel dimensions: %s in %s" % [main.size, panel.size])
	check(main.get_global_rect().get_center().distance_to(panel.get_global_rect().get_center()) < 1.0, "Visible panel centered")
	check(main.position.x > 0 and main.position.y > 0 and main.get_rect().end.x < panel.size.x and main.get_rect().end.y < panel.size.y, "Breathing room on all four sides")
	check(panel.get_node("DimLayer").get_rect() == Rect2(Vector2.ZERO, panel.size), "Dim layer follows full overlay root")
	for control in panel._concepts + [panel._sources_button, panel._speaker, panel._close]:
		check(control.size.y >= 56 and control.size.x >= 48, "Large touch target")
		check(bounds.encloses(control.get_global_rect()), "Control within canvas")
	for label in [panel._title, panel._subtitle, panel._key, panel._heading, panel._body, panel._takeaway]:
		check(bounds.encloses(label.get_global_rect()), "Label within canvas: " + label.text)
		check(label.size.y >= label.get_minimum_size().y, "Text height fits")
	check(panel._body.get_global_rect().end.y <= panel._takeaway.global_position.y, "Interpretation does not overlap takeaway")
	check(panel._image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Documentary aspect preserved")
	var photo_share: float = panel._image.size.x / (panel._image.size.x + panel._information.size.x)
	check(photo_share >= 0.58 and photo_share <= 0.60, "58–60% photo width")
	check(panel._speaker.get_parent() == panel._close.get_parent() and panel._speaker.get_index() + 1 == panel._close.get_index(), "Listen directly left of Close")
	check(panel._sources_button.get_index() + 1 == panel._speaker.get_index(), "Sources Listen Close order")
	check(not panel._scroll.visible, "No interpretation or screen scrolling")
	check(panel._concepts[0].get_theme_stylebox("focus") != panel._concepts[0].get_theme_stylebox("pressed"), "Focus distinct from selection")

func capture(name: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		var path := OS.get_environment("TEMP").path_join("akar_cr_ext_01_" + name + ".png")
		check(root.get_texture().get_image().save_png(path) == OK, "Screenshot saved")

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	create_timer(120.0).timeout.connect(func(): push_error("CR-EXT-01 test timeout"); quit(1))
	root.content_scale_size = Vector2i.ZERO
	var preview = load("res://scenes/landmarks/casa_real/exterior/cr_ext_01_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("CR_EXT_01")
	var trigger: Button = preview.get_node("Reopen")
	panel.closed.connect(func(): closes += 1)
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		check(panel.open_hotspot(), "Open real component")
		await finish(panel)
		assert_state(panel, 0)
		check(not panel._audio.playing and not panel._sources.visible, "No autoplay or Sources on open")
		check(panel._speaker.icon.resource_path == "res://assets/ui/icons/speaker.svg", "Shared speaker")
		check(panel._audio.stream.resource_path == "res://assets/landmarks/casa_real/audio/cr_ext_01_narration.ogg", "Real narration")
		check(panel._audio.stream.get_length() > 0, "Imported audio has duration")
		# All six directed paths, repeat selection, and visual snapshots of each state.
		for state in [1, 0, 2, 0, 1, 2, 1, 1]:
			await pointer(panel._concepts[state])
			await finish(panel)
			assert_state(panel, state)
			assert_layout(panel)
		for state in 3:
			panel.select_state(state)
			await finish(panel)
			assert_layout(panel)
			await capture("%dx%d_state%d" % [dimensions.x, dimensions.y, state])
		panel.select_state(-1)
		panel.select_state(3)
		assert_state(panel, 2)
		for state in [0, 2, 1, 0, 2]:
			panel.select_state(state)
			panel._transition.pause()
			panel._transition.custom_step(0.07)
		await finish(panel)
		assert_state(panel, 2)
		# Arrow navigation moves focus only; Enter and Space choose.
		panel._concepts[0].grab_focus()
		await key(KEY_DOWN)
		check(root.gui_get_focus_owner() == panel._concepts[1] and panel.current_state == 2, "Arrow focus only")
		await key(KEY_ENTER)
		await finish(panel)
		assert_state(panel, 1)
		await key(KEY_RIGHT)
		check(panel.current_state == 1 and root.gui_get_focus_owner() == panel._concepts[2], "Horizontal focus only")
		await key(KEY_SPACE)
		await finish(panel)
		assert_state(panel, 2)
		panel._concepts[0].grab_focus()
		for target in [panel._concepts[1], panel._concepts[2], panel._sources_button, panel._speaker, panel._close, panel._concepts[0]]:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == target, "Tab order")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._close, "Shift Tab wraps")
		# Each pointer mode exercises all toolbar controls and modal shielding.
		for touch in [false, true]:
			for state in [0, 2, 1, 0, 2, 2]:
				await pointer(panel._concepts[state], touch)
			await finish(panel)
			assert_state(panel, 2)
			await pointer(panel._speaker, touch)
			check(panel._audio.playing, "Pointer Listen starts narration")
			var position_before: float = panel._audio.get_playback_position()
			panel.select_state(1)
			await finish(panel)
			check(panel._audio.playing and panel._audio.get_playback_position() >= position_before, "Selection preserves narration position")
			await pointer(panel._sources_button, touch)
			check(panel._sources.visible, "Sources opens")
			await pointer(panel._concepts[0], touch)
			panel.select_state(0)
			check(panel.current_state == 1, "Modal shields selectors and selection API")
			await capture("%dx%d_sources" % [dimensions.x, dimensions.y])
			await key(KEY_ESCAPE)
			check(not panel._sources.visible and panel._open and panel.current_state == 1, "Escape closes Sources first")
			await pointer(panel._sources_button, touch)
			await pointer(panel._source_close, touch)
			check(not panel._sources.visible and panel.current_state == 1, "Pointer Sources close preserves state")
			await pointer(panel._close, touch)
			check(not panel._open and not panel._audio.playing and panel._transition == null, "Pointer close stops audio and animation")
			await pointer(trigger, touch)
			await finish(panel)
			assert_state(panel, 0)
			check(not panel._sources.visible and not panel._audio.playing and panel._audio.get_playback_position() == 0, "Reopen resets overlays and audio")
		# Close during transition and opening reveal, then reopen before old callbacks.
		panel.select_state(2)
		await key(KEY_ESCAPE)
		check(not panel._open and panel._transition == null, "Escape hotspot closes pending transition")
		panel.open_hotspot()
		panel.close_hotspot()
		check(panel._reveal == null and panel.modulate.a == 1.0, "Closing cancels opening reveal")
		panel.open_hotspot()
		await finish(panel)
		assert_state(panel, 0)
		# Keyboard toolbar activation and local focus trap.
		panel._sources_button.grab_focus()
		await key(KEY_SPACE)
		check(panel._sources.visible, "Space opens Sources")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._source_scroll, "Sources focus trapped")
		await key(KEY_ESCAPE)
		panel._speaker.grab_focus()
		await key(KEY_ENTER)
		check(panel._audio.playing, "Keyboard Listen")
		await key(KEY_SPACE)
		check(not panel._audio.playing, "Keyboard Stop")
		panel._close.grab_focus()
		await key(KEY_SPACE)
		check(not panel._open, "Keyboard Close")
		print("CR-EXT-01 ", dimensions, " finished; failures=", failures)
	check(closes == 15, "One shared closed signal per close")
	# Return from an unsupported portrait size to the approved landscape layout.
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
	check(root.gui_get_focus_owner() == panel._sources_button, "Focus survives orientation return")
	panel.toggle_narration()
	panel.open_sources()
	panel.hide()
	check(not panel._open and not panel._audio.playing and not panel._sources.visible, "Host hide cleans up audio and overlays")
	panel.open_hotspot()
	await finish(panel)
	assert_state(panel, 0)
	panel.close_hotspot()
	preview.queue_free()
	await settle()
	# Original Urduja consumer of the unchanged shared shell.
	var urduja = load("res://scenes/landmarks/urduja_house/interior/uh_int_04.tscn").instantiate()
	root.add_child(urduja)
	await settle()
	var shared = urduja.get_node("HotspotFrame/ConferenceRoomInteraction")
	check(shared.open_interaction(), "UH-INT-04 shared shell opens")
	for index in 3:
		shared.select_concept(index)
		check(shared.get_selected_concept() == index and shared._body.text == shared.content.concepts[index].body, "UH-INT-04 content unchanged")
	shared.open_sources()
	check(shared._sources.visible, "UH-INT-04 Sources works")
	shared.close_sources()
	shared.toggle_narration()
	check(shared._audio.playing, "UH-INT-04 narration works")
	# Let the mixer consume the queued start before stopping/removing its player.
	await create_timer(0.1).timeout
	shared.close_interaction()
	check(not shared._open and not shared._audio.playing, "UH-INT-04 close works")
	await create_timer(0.1).timeout
	urduja.queue_free()
	await settle()
	print("CR-EXT-01: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)
