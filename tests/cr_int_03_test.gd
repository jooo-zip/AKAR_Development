extends SceneTree
## Tests the production instance inside the actual standalone F6 scene.
const IDS := ["P01_TAFT", "P02_SISON", "P03_ESPINO_JR", "P04_ESPINO_III", "P05_GUICO"]
const NAMES := ["WILLIAM HOWARD TAFT", "PERFECTO SISON", "AMADO T. ESPINO JR.", "AMADO I. ESPINO III", "RAMON V. GUICO III"]
const DATES := ["1901", "1901", "RESTORATION INITIATIVE", "2021", "2023"]
const PERIODS := [0, 0, 1, 1, 2]
const PORTRAITS := ["cr_int_03_p01_taft.png", "cr_int_03_p02_sison.jpg", "cr_int_03_p03_espino_jr.png", "cr_int_03_p04_espino_iii.png", "cr_int_03_p05_guico.png"]
const CONTEXTS := ["cr_ext_03_government_center.jpg.jpg", "cr_ext_03_government_center.jpg.jpg", "cr_ext_03_cosme_damage.JPG", "cr_ext_03_heritage_museum.jpg", "cr_ext_03_banaan_identity.jpg"]
const CONTRIBUTIONS := [
	"Led the Second Philippine Commission and visited Casa Real during the establishment of civil government in Pangasinan in 1901.",
	"Served as the first Civil Governor of Pangasinan and welcomed Taft and the Philippine Commission during their visit to the province.",
	"The restoration and preservation initiative for Casa Real began during his administration.",
	"Continued the completion of Casa Real's restoration. The restored building was formally turned over to the Provincial Government of Pangasinan during his term in 2021.",
	"Led the opening and continued development of Casa Real as the Banáan Pangasinan Provincial Museum."
]
var checks: int = 0
var failures: int = 0
var audio_starts: int = 0
var close_count: int = 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for frame in 6: await process_frame

func finish(panel) -> void:
	if panel._transition != null and panel._transition.is_valid():
		panel._transition.pause()
		panel._transition.custom_step(1.0)
	await settle()

func capture(label: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args(): return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("akar_cr_int_03_" + label + ".png")) == OK, "Capture " + label)

func tap(control: Control, touch: bool = false) -> void:
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

func swipe(control: Control, motion: Vector2, touch: bool) -> void:
	var event: InputEvent
	if touch: event = InputEventScreenTouch.new()
	else:
		event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
	var origin := control.get_global_rect().get_center()
	event.position = origin
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	for step in range(1, 6):
		var move: InputEvent
		if touch: move = InputEventScreenDrag.new()
		else:
			move = InputEventMouseMotion.new()
			move.button_mask = MOUSE_BUTTON_MASK_LEFT
		move.position = origin + motion * step / 5.0
		move.relative = motion / 5.0
		Input.parse_input_event(move)
		await process_frame
	event = event.duplicate()
	event.position = origin + motion
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func assert_overview(panel, fresh: bool = false) -> void:
	check(panel.current_view == panel.ViewState.OVERVIEW, "Overview state")
	check(panel.selected_person_index == -1 and panel.visual_mode == panel.VisualMode.PORTRAIT, "No selected person or stale visual mode")
	check(panel._image.texture == null and panel._old_image.texture == null, "No stale context image")
	check(not panel._focus_view.visible and panel._intro.visible, "Overview network shown")
	if fresh:
		check(panel.selected_period_id == &"", "Fresh period clear")
		check(not panel._sources.visible and not panel._audio.playing and not panel._audio.stream_paused, "Fresh Sources/audio")
		check(panel._rail.scroll_horizontal == 0 and panel._transition == null, "Fresh rail/tweens")
		check(not true in panel._connections.highlighted, "No active connection")
		for card in panel._portraits: check(card.modulate.a == 1.0 and not card.button_pressed, "Fresh portrait normal")

func assert_person(panel, index: int) -> void:
	var entry = panel.content.people[index]
	check(panel.current_view == panel.ViewState.PERSON_FOCUS and panel.selected_person_index == index, "Authoritative selected person")
	check(panel.selected_period_id == panel.content.period_ids[PERIODS[index]], "Person/period synchronized")
	check(panel._person_name.text == NAMES[index] and panel._date.text == DATES[index], "Approved name/date")
	check(panel._role.text == entry.role_label and panel._contribution.text == entry.contribution, "Contribution and role agree")
	check(panel._image.texture == entry.portrait and panel.visual_mode == panel.VisualMode.PORTRAIT, "Correct portrait default")
	check(panel._image.modulate.a == 1.0 and panel._focus_view.modulate.a == 1.0, "Transition settled")
	check(panel._old_image.texture == null, "No stale crossfade texture")
	check(panel._connections.highlighted.count(true) == 2, "Person-period-Casa Real connection")
	for i in 5: check(panel._portraits[i].button_pressed == (i == index), "One selected portrait")

func assert_layout(panel) -> void:
	var main: Control = panel.get_node("Main")
	var bounds := main.get_global_rect().grow(0.6)
	check(main.get_global_rect().get_center().distance_to(panel.get_global_rect().get_center()) < 1, "Centered inset")
	for control in [panel._title, panel._sources_button, panel._speaker, panel._close, panel._network, panel._rail, panel._focus_view, panel._view_all, panel._intro, panel._intro_body, panel._helper, panel._anchor]:
		if control.is_visible_in_tree(): check(bounds.encloses(control.get_global_rect()), "Contained " + str(control))
	for button in panel._buttons():
		if not button.is_visible_in_tree(): continue
		check(button.size.y >= 48, "Touch target height")
		if button not in panel._portraits and button != panel._source_close: check(bounds.encloses(button.get_global_rect()), "Button reachable " + button.text)
	for i in 3:
		check(bounds.encloses(panel._periods[i].get_global_rect()), "Period in bounds")
		if i < 2: check(not panel._periods[i].get_global_rect().intersects(panel._periods[i+1].get_global_rect()), "Periods do not overlap")
	if panel.current_view == panel.ViewState.PERSON_FOCUS:
		var preserved_width: float = {1280: 566.0, 960: 465.0, 854: 397.0}[root.size.x]
		check(panel._context.size == Vector2(preserved_width, 52), "Context button retains pre-revision dimensions")
		check(absf(panel._context.get_global_rect().get_center().x - panel._actions.get_global_rect().get_center().x) <= 0.51, "Context button centered within pixel rounding")
		check(panel._actions.get_child_count() == 1 and panel._actions.get_child(0) == panel._context, "No redundant lower Source control")
		check(panel._date.get_line_count() == 1, "Date badge stays on one line")
		check(not panel._focus_view.get_global_rect().intersects(panel._rail.get_global_rect()), "Rail does not overlap focus")
		check(panel._reading.size.y > 45, "Local reading viewport remains usable")
		check(panel._visual.size.x / panel._focus_view.size.x > 0.31 and panel._visual.size.x / panel._focus_view.size.x < 0.4, "Responsive visual proportion")
	else:
		check(not panel._intro_body.get_global_rect().intersects(panel._anchor.get_global_rect()), "Overview copy does not overlap anchor")
	check(panel._anchor.get_rect().end.y < panel._periods[0].position.y - 12, "Connection gap below anchor")
	for i in 5:
		check(panel._photos[i].stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "No portrait crop")
		check(panel._portraits[i].get_rect().size.y >= 76, "Portrait target size")
	for path in panel._connections.paths:
		for point in path: check(Rect2(Vector2.ZERO, panel._network.size).grow(1).has_point(point), "Connection inside network")

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	root.size = Vector2i(1280, 720)
	var preview = load("res://scenes/landmarks/casa_real/interior/cr_int_03_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.panel
	check(panel._open, "F6 opens real production component")
	panel.narration_started.connect(func() -> void: audio_starts += 1)
	panel.closed.connect(func() -> void: close_count += 1)
	for i in 5:
		var entry = panel.content.people[i]
		check(String(entry.id) == IDS[i], "Approved ID")
		check(entry.portrait != null and entry.context_image != null, "Portrait/context load")
		check(entry.portrait.resource_path.get_file() == PORTRAITS[i] and entry.context_image.resource_path.get_file() == CONTEXTS[i], "Exact asset mapping")
		check(entry.contribution == CONTRIBUTIONS[i], "Exact approved historical copy")
		check(ResourceLoader.exists(entry.portrait.resource_path) and ResourceLoader.exists(entry.context_image.resource_path), "Real media paths")
		check(not entry.portrait_source_name.is_empty() and not entry.portrait_permission_status.is_empty(), "Documented portrait provenance")
	check(panel.content.narration_stream.resource_path.ends_with("cr_int_03_narration.ogg") and panel.content.narration_stream.get_length() > 1, "Real narration")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		panel.reset_hotspot()
		await settle()
		var label := str(dimensions.x)
		assert_overview(panel, true)
		assert_layout(panel)
		await capture(label + "_overview")
		for period in 3:
			await tap(panel._periods[period], true)
			assert_overview(panel)
			check(panel.selected_period_id == panel.content.period_ids[period], "Touch period selection")
			for i in 5: check(is_equal_approx(panel._portraits[i].modulate.a, 1.0 if PERIODS[i] == period else 0.65), "Period emphasis without hiding")
			await capture(label + "_period" + str(period))
		for i in 5:
			panel.view_all_connections()
			await settle()
			await tap(panel._portraits[i], i % 2 == 0)
			await finish(panel)
			assert_person(panel, i)
			assert_layout(panel)
			await capture(label + "_person" + str(i))
			await swipe(panel._reading, Vector2(0, -180), true)
			panel._reading.scroll_vertical = int(panel._reading.get_v_scroll_bar().max_value)
			await settle()
			check(panel._contribution.get_global_rect().end.y <= panel._reading.get_global_rect().end.y + 1, "Contribution reachable to final line")
			if i == 3: await capture(label + "_contribution_scrolled")
			panel._reading.scroll_vertical = 0
			await tap(panel._context, true)
			await finish(panel)
			check(panel.visual_mode == panel.VisualMode.CASA_REAL_CONTEXT and panel._image.texture == panel.content.people[i].context_image, "Correct context image")
			check(panel._caption.text == panel.content.people[i].context_label and panel._caption.visible, "Context caption")
			assert_layout(panel)
			await capture(label + "_context" + str(i))
			await tap(panel._context)
			await finish(panel)
			assert_person(panel, i)
		panel.select_person(0)
		panel.toggle_context()
		panel.select_person(3)
		await finish(panel)
		assert_person(panel, 3)
		await tap(panel._sources_button, true)
		await settle()
		check(panel._source_text.text.find(NAMES[3]) < panel._source_text.text.find(NAMES[0]), "Active person first in Sources")
		for text in ["HISTORICAL CONTENT", "PORTRAIT", "CASA REAL CONTEXT IMAGE", "NARRATION"]: check(text in panel._source_text.text, "Source section " + text)
		panel.select_person(0)
		panel.select_period(panel.content.period_ids[0])
		panel.toggle_context()
		panel.view_all_connections()
		assert_person(panel, 3)
		check(panel._context.focus_mode == Control.FOCUS_NONE, "Sources traps underlying focus")
		for step in 4:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() in [panel._source_close, panel._source_scroll], "Tab stays in Sources")
		await swipe(panel._source_scroll, Vector2(0, -140), true)
		check(panel._source_scroll.scroll_vertical > 0, "Touch Sources scroll")
		await capture(label + "_sources")
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel.selected_person_index == 3, "Escape closes Sources first")
		await tap(panel._sources_button)
		check(panel._sources.visible, "Mouse header Sources")
		await tap(panel._source_close)
		panel.toggle_context()
		await key(KEY_ESCAPE)
		assert_overview(panel)
		for i in [0, 1, 2, 3, 4]: panel.select_person(i)
		await finish(panel)
		assert_person(panel, 4)
		for period in [0, 1, 2, 0]: panel.select_period(panel.content.period_ids[period])
		await finish(panel)
		assert_overview(panel)
		check(panel.selected_period_id == panel.content.period_ids[0], "Rapid period last wins")
		panel.select_person(0)
		await finish(panel)
		panel._context.grab_focus()
		for i in 5:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == panel._portraits[i], "Context action tabs through portrait rail")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._view_all, "Portrait rail tabs to View All Connections")
		panel.select_person(-1)
		panel.select_person(5)
		panel.select_period(&"INVALID")
		assert_person(panel, 0)
		panel._portraits[0].grab_focus()
		await key(KEY_LEFT)
		check(root.gui_get_focus_owner() == panel._portraits[0], "Left bounded")
		for i in 4: await key(KEY_RIGHT)
		check(root.gui_get_focus_owner() == panel._portraits[4] and panel.selected_person_index == 0, "Arrow focus without activation")
		await key(KEY_RIGHT)
		check(root.gui_get_focus_owner() == panel._portraits[4], "Right bounded")
		await key(KEY_ENTER)
		await finish(panel)
		assert_person(panel, 4)
		await key(KEY_LEFT)
		await key(KEY_SPACE)
		await finish(panel)
		assert_person(panel, 3)
		if dimensions.x < 1100:
			panel._rail.scroll_horizontal = 0
			await settle()
			await swipe(panel._rail, Vector2(-210, 0), true)
			check(panel._rail.scroll_horizontal > 0 and panel.selected_person_index == 3, "Touch rail swipe without activation")
			var offset: int = panel._rail.scroll_horizontal
			await swipe(panel._rail, Vector2(140, 0), false)
			check(panel._rail.scroll_horizontal < offset and panel.selected_person_index == 3, "Mouse rail drag without activation")
		panel._reading.grab_focus()
		await key(KEY_PAGEDOWN)
		check(panel._reading.scroll_vertical > 0 or panel._copy.size.y <= panel._reading.size.y, "Keyboard contribution scroll")
		panel.reset_hotspot()
		await settle()
		assert_overview(panel, true)
	root.size = Vector2i(1280, 720)
	await settle()
	panel.select_person(4)
	panel.toggle_context()
	# Keep the same person/context through every intermediate size in both directions.
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480), Vector2i(960, 540), Vector2i(1280, 720)]:
		root.size = dimensions
		await finish(panel)
		check(panel.selected_person_index == 4 and panel.visual_mode == panel.VisualMode.CASA_REAL_CONTEXT, "Resize preserves selected context")
		check(panel.selected_period_id == panel.content.period_ids[2] and panel._periods[2].button_pressed, "Resize preserves period synchronization")
		check(panel._portraits[4].button_pressed and panel._connections.highlighted.count(true) == 2, "Resize preserves portrait/connection selection")
		check(panel._image.texture == panel.content.people[4].context_image, "Resize preserves context resource")
		check(panel._rail.get_global_rect().grow(1).encloses(panel._portraits[4].get_global_rect()), "Resize keeps selected portrait reachable")
		assert_layout(panel)
		panel._reading.scroll_vertical = int(panel._reading.get_v_scroll_bar().max_value)
		await settle()
		check(panel._contribution.get_global_rect().end.y <= panel._reading.get_global_rect().end.y + 1, "Resize keeps full contribution reachable")
		panel._reading.scroll_vertical = 0
		await tap(panel._context)
		await finish(panel)
		assert_person(panel, 4)
		await tap(panel._context, true)
		await finish(panel)
		check(panel.visual_mode == panel.VisualMode.CASA_REAL_CONTEXT, "Resize retains usable mouse/touch controls")
	panel.reset_hotspot()
	panel.toggle_narration()
	await create_timer(0.25).timeout
	check(panel._audio.playing and audio_starts == 1, "Narration opt-in")
	var before: float = panel._audio.get_playback_position()
	for i in [0, 1, 2]: panel.select_person(i)
	panel.toggle_context()
	panel.select_person(3)
	panel.open_sources()
	await create_timer(0.2).timeout
	check(panel._audio.playing and panel._audio.get_playback_position() >= before and audio_starts == 1, "Narration persists through selection/context/Sources")
	panel.close_sources()
	panel.toggle_narration()
	await create_timer(0.12).timeout
	check(panel._audio.stream_paused and panel._speaker.text == "RESUME", "Narration pause")
	panel.view_all_connections()
	panel.select_period(panel.content.period_ids[2])
	check(panel._audio.stream_paused, "Period/overview preserve pause")
	panel.toggle_narration()
	check(not panel._audio.stream_paused and audio_starts == 1, "Resume does not restart")
	panel.select_person(4)
	panel.toggle_context()
	panel.open_sources()
	panel.close_interaction()
	await settle()
	check(close_count == 1 and not panel._open and preview.get_node("Reopen").visible, "Normal close and preview reopen")
	assert_overview(panel, true)
	await tap(preview.get_node("Reopen"))
	await settle()
	assert_overview(panel, true)
	await key(KEY_ESCAPE)
	check(close_count == 2 and not panel._open, "Overview Escape closes hotspot")
	preview.queue_free()
	await settle()
	print("CR-INT-03: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
