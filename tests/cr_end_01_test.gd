extends SceneTree
## Exercises the actual production component through its F6 preview.
const IDS: Array[StringName] = [&"government", &"architecture", &"history", &"preservation", &"museum"]
const HEADINGS := ["FROM ROYAL HOUSE TO GOVERNMENT CENTER", "ARCHITECTURE THAT CARRIES HISTORY", "A WITNESS TO CHANGING TIMES", "PRESERVING CASA REAL", "A HISTORIC BUILDING WITH A NEW PUBLIC ROLE"]
const BODIES := ["Casa Real was constructed in 1840 as the residence and office of the Alcalde Mayor and became an important center of provincial administration and judicial activity.", "Casa Real's stone-and-brick masonry, wooden balcony, French doors, ventanillas, and piedra china staircase contribute to its historic architectural character.", "Casa Real witnessed revolution, political transition, wartime occupation, and changing public functions while remaining connected with Pangasinan's civic history.", "After years of deterioration and severe damage from Typhoon Cosme in 2008, Casa Real underwent a multi-phase restoration and was formally turned over to the Provincial Government of Pangasinan in 2021.", "In 2023, the restored Casa Real formally opened as the Banáan Pangasinan Provincial Museum, continuing the building's public role through heritage preservation and education."]
const INTERPRETATIONS := ["Casa Real reflects Lingayen's long connection with provincial government and public service.", "These features help visitors recognize Casa Real as a historic public structure as well as the present home of Banáan Museum.", "The building connects several periods of Pangasinan history within one surviving historic place.", "Preservation allowed Casa Real's historical and architectural character to remain part of public life.", "Casa Real now provides a setting where visitors can encounter different stories of Pangasinan's history and cultural identity."]
const ANCHORS := ["1840", "", "ACROSS PERIODS", "2008 → 2021", "2023"]
const MEDIA := ["res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_government_center.jpg.jpg", "res://assets/landmarks/casa_real/exterior/cr_ext_01_facade.png", "res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_historical_marker.jpg", "res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_cosme_damage.JPG", "res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_banaan_identity.jpg"]
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
	check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("akar_cr_end_01_" + label + ".png")) == OK, "Capture " + label)

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

func swipe(scroller: Control) -> void:
	var origin := scroller.get_global_rect().get_center()
	var touch := InputEventScreenTouch.new()
	touch.position = origin
	touch.pressed = true
	Input.parse_input_event(touch)
	await process_frame
	for step in range(1, 6):
		var motion := InputEventScreenDrag.new()
		motion.position = origin + Vector2(0, -22 * step)
		motion.relative = Vector2(0, -22)
		Input.parse_input_event(motion)
		await process_frame
	touch = touch.duplicate()
	touch.pressed = false
	touch.position = origin + Vector2(0, -110)
	Input.parse_input_event(touch)
	await settle()

func assert_theme(panel, index: int) -> void:
	check(panel.selected_theme == IDS[index], "Authoritative theme ID")
	check(panel._heading.text == HEADINGS[index], "Exact locked heading")
	check(panel._body.text == BODIES[index], "Exact locked body")
	check(panel._takeaway.text == INTERPRETATIONS[index], "Exact locked interpretation")
	check(panel._why.text == "WHY IT MATTERS", "Interpretation label")
	check(panel._anchor_label.text == ANCHORS[index], "Exact anchor")
	check(panel._anchor_label.visible == (index != 1), "No invented architecture date")
	check(panel._image.texture.resource_path == MEDIA[index], "Exact reused image")
	check(panel._caption.text == panel.content.themes[index].caption, "Caption synchronized")
	for i in 5: check(panel._theme_cards[i].button_pressed == (i == index), "Exactly one selected theme")
	check(panel._image.modulate.a == 1.0 and panel._detail_copy.modulate.a == 1.0, "Transition settled without transform buildup")
	check(panel._previous_image.texture == null, "No stale crossfade image")
	check(panel._transition == null or not panel._transition.is_running(), "No pending transition")

func assert_default(panel) -> void:
	assert_theme(panel, 0)
	check(panel.current_view == panel.ViewState.SUMMARY and panel._summary.visible and not panel._reflection.visible, "Fresh Summary")
	check(not panel._sources.visible, "Fresh Sources closed")
	check(not panel._audio.playing and not panel._audio.stream_paused, "Fresh narration stopped")
	check(panel._detail_scroll.scroll_vertical == 0 and panel._reflection_scroll.scroll_vertical == 0, "Reading reset")
	check(panel._transition == null and panel._speaker.text == "LISTEN", "Fresh audio/transition controls")

func assert_layout(panel) -> void:
	var main: Control = panel.get_node("Main")
	var bounds := main.get_global_rect().grow(0.6)
	check(panel.get_global_rect().grow(1).encloses(main.get_global_rect()), "Inset inside viewport")
	check(main.get_global_rect().get_center().distance_to(panel.get_global_rect().get_center()) < 1, "Centered panel")
	for control in [panel._title, panel._subtitle, panel._summary, panel._reflection, panel._mosaic, panel._columns, panel._visual, panel._caption, panel._detail_scroll, panel._reflection_scroll]:
		if control.is_visible_in_tree(): check(bounds.encloses(control.get_global_rect()), "Visible control contained " + str(control))
	for button in panel._buttons():
		if not button.is_visible_in_tree() or button == panel._source_close: continue
		check(bounds.encloses(button.get_global_rect()), "Button contained " + button.text)
		check(button.size.y >= 48, "Practical touch height")
	for card in panel._theme_cards: check(card.size.y >= 64, "Theme card touch height")
	if panel.current_view == panel.ViewState.SUMMARY:
		check(panel._mosaic.columns == (3 if root.size.x == 854 else 5), "Responsive mosaic arrangement")
		for i in 5:
			for j in range(i + 1, 5): check(not panel._theme_cards[i].get_global_rect().intersects(panel._theme_cards[j].get_global_rect()), "No overlapping cards")
		check(not panel._mosaic.get_global_rect().intersects(panel._columns.get_global_rect()), "Mosaic/content separation")
		check(not panel._columns.get_global_rect().intersects(panel._reflect.get_global_rect()), "Content/reflection-action separation")
		check(panel._visual.size.x / panel._columns.size.x > 0.39 and panel._visual.size.x / panel._columns.size.x < 0.44, "Image/detail proportion")
		check(panel._image.size.y > 70 and panel._detail_scroll.size.y > 100, "Compact media/detail remain usable")
		check(panel._image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Uncropped documentary image")
		if root.size.x == 1280: check(panel._detail_copy.size.y <= panel._detail_scroll.size.y + 1, "Full reference-size detail readable")
	else:
		check(panel._background.texture == panel.content.themes[4].image, "Reflection reuses museum photograph")
		check(panel._shade.color.a >= 0.8, "Runtime reflection contrast overlay")
		check(panel._back.is_visible_in_tree() and not panel._reflect.is_visible_in_tree(), "Single view action")

func assert_no_game(node: Node) -> void:
	if node is Label or node is Button:
		var text: String = node.text.to_lower()
		for term in ["score", "achievement", "unlocked", "reward", "completion", "congratulations", "quiz", "progress", "bombed"]:
			check(not term in text, "No unsupported/game wording: " + term)
	check(not node is LineEdit and not node is TextEdit, "No answer field")
	for child in node.get_children(): assert_no_game(child)

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	root.size = Vector2i(1280, 720)
	var preview = load("res://scenes/landmarks/casa_real/end/cr_end_01_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.panel
	check(panel._open, "Real F6 component opens")
	panel.narration_started.connect(func() -> void: audio_starts += 1)
	panel.closed.connect(func() -> void: close_count += 1)
	check(panel.content.hotspot_id == "CR-END-01" and panel.content.themes.size() == 5, "Exact identity and five themes")
	check(panel._audio.stream is AudioStreamOggVorbis and panel._audio.stream.get_length() > 20, "Real imported narration")
	check(panel._audio.stream.resource_path.ends_with("cr_end_01_narration.ogg"), "Hotspot-specific narration only")
	check("1917–1918" in panel.content.themes[0].caption and not "1840" in panel.content.themes[0].caption and not "1901" in panel.content.themes[0].caption, "Early photograph context qualification")
	for entry in panel.content.themes:
		check(ResourceLoader.exists(entry.image.resource_path), "Media resource exists")
		check("Unspecified" in entry.permission_status, "Inherited media permission status")
	check(panel._question.text == "How can preserving a historic building like Casa Real help communities understand and pass on their heritage?", "Exact reflection question")
	check(panel._prompt.text == "Think about how Casa Real changed from a government building into a museum while continuing to serve the public.", "Exact reflection prompt")
	check(panel._reflection_takeaway.text == "Casa Real shows how a historic place can change in function while continuing to connect people with the history, public life, and cultural heritage of Pangasinan.", "Exact learning takeaway")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		panel.reset_hotspot()
		await settle()
		var label := str(dimensions.x)
		assert_default(panel)
		assert_layout(panel)
		await capture(label + "_default")
		for i in 5:
			await tap(panel._theme_cards[i], i % 2 == 0)
			await finish(panel)
			assert_theme(panel, i)
			assert_layout(panel)
			await capture(label + "_theme" + str(i))
			await swipe(panel._detail_scroll)
			check(panel._detail_scroll.scroll_vertical > 0 or panel._detail_copy.size.y <= panel._detail_scroll.size.y, "Touch detail scroll")
			panel._detail_scroll.grab_focus()
			await key(KEY_END)
			check(panel._takeaway.get_global_rect().end.y <= panel._detail_scroll.get_global_rect().end.y + 1, "Last interpretation line reachable")
			panel._detail_scroll.scroll_vertical = 0
		panel._sources_button.grab_focus()
		var expected: Array[Control] = [panel._speaker, panel._close]
		expected.append_array(panel._theme_cards)
		expected.append(panel._reflect)
		for target in expected:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == target, "Summary Tab order")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._theme_cards[4], "Shift+Tab reverses")
		await key(KEY_SPACE)
		await finish(panel)
		assert_theme(panel, 4)
		panel._theme_cards[3].grab_focus()
		await key(KEY_ENTER)
		await finish(panel)
		assert_theme(panel, 3)
		for id in [&"government", &"architecture", &"history", &"preservation", &"museum", &"government", &"preservation"]: panel.select_theme(id)
		await finish(panel)
		assert_theme(panel, 3)
		panel.select_theme(&"invalid")
		assert_theme(panel, 3)
		await tap(panel._reflect, true)
		check(panel.current_view == panel.ViewState.REFLECTION and panel.selected_theme == &"preservation", "Optional reflection preserves theme")
		assert_layout(panel)
		await capture(label + "_reflection")
		await swipe(panel._reflection_scroll)
		panel._reflection_scroll.grab_focus()
		await key(KEY_END)
		check(panel._reflection_takeaway.get_global_rect().end.y <= panel._reflection_scroll.get_global_rect().end.y + 1, "Reflection takeaway reachable")
		await capture(label + "_reflection_scrolled")
		panel._sources_button.grab_focus()
		for target in [panel._speaker, panel._close, panel._back]:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == target, "Reflection Tab order")
		await tap(panel._sources_button, true)
		check(panel._sources.visible, "Header Sources via touch")
		for section in ["HISTORICAL CONTENT", "MEDIA CREDITS", "AUDIO", "CR-END-01 narration — AKAR Research Team"]: check(section in panel._source_text.text, "Sources section " + section)
		panel.select_theme(&"government")
		panel.back_to_summary()
		panel.open_reflection()
		check(panel.current_view == panel.ViewState.REFLECTION and panel.selected_theme == &"preservation", "Sources blocks underlying state changes")
		check(panel._back.focus_mode == Control.FOCUS_NONE, "Sources blocks underlying focus")
		for step in 4:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() in [panel._source_scroll, panel._source_close], "Sources focus trap")
		await swipe(panel._source_scroll)
		check(panel._source_scroll.scroll_vertical > 0, "Touch Sources reading")
		await capture(label + "_sources")
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel.current_view == panel.ViewState.REFLECTION, "Escape closes Sources first")
		await key(KEY_ESCAPE)
		check(panel.current_view == panel.ViewState.SUMMARY, "Escape Reflection to Summary")
		assert_theme(panel, 3)
		await tap(panel._sources_button)
		panel.select_theme(&"museum")
		check(panel.selected_theme == &"preservation", "Sources blocks summary selection")
		await tap(panel._source_close)
		await tap(panel._reflect)
		await tap(panel._back, true)
		assert_theme(panel, 3)
		assert_no_game(panel)
		await key(KEY_ESCAPE)
		check(not panel._open and preview.get_node("Reopen").visible, "Escape Summary closes")
		await tap(preview.get_node("Reopen"))
		assert_default(panel)
	panel.toggle_narration()
	await create_timer(0.25).timeout
	check(panel._audio.playing and audio_starts == 1, "Manual narration start")
	var prior_position: float = panel._audio.get_playback_position()
	panel.select_theme(&"museum")
	panel.open_reflection()
	panel.open_sources()
	await create_timer(0.2).timeout
	check(panel._audio.playing and panel._audio.get_playback_position() >= prior_position and audio_starts == 1, "Theme/reflection/Sources do not restart narration")
	panel.close_sources()
	panel.back_to_summary()
	panel.toggle_narration()
	check(panel._audio.stream_paused and panel._speaker.text == "RESUME", "Pause narration")
	panel.select_theme(&"history")
	panel.open_reflection()
	panel.back_to_summary()
	check(panel._audio.stream_paused, "Exploration preserves pause")
	panel.toggle_narration()
	check(not panel._audio.stream_paused and audio_starts == 1, "Resume without restart")
	panel.select_theme(&"museum")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480), Vector2i(960, 540), Vector2i(1280, 720)]:
		root.size = dimensions
		await finish(panel)
		assert_theme(panel, 4)
		assert_layout(panel)
	panel.open_reflection()
	panel.open_sources()
	panel.close_interaction()
	await settle()
	check(not panel._open and not panel._audio.playing and not panel._audio.stream_paused, "Close resets audio")
	check(close_count == 4, "Normal close signal once per close")
	panel.open_hotspot()
	await settle()
	assert_default(panel)
	panel.close_interaction()
	var original: Resource = panel.content
	panel.content = original.duplicate(true)
	panel.content.narration_path = "res://assets/landmarks/casa_real/audio/missing_cr_end_01.ogg"
	check(panel.open_hotspot(), "Missing narration does not block content")
	await settle()
	check(panel._speaker.visible and panel._speaker.disabled and panel._audio_status.text == "Narration pending." and panel._audio_status.visible, "Visible disabled narration fallback")
	panel.toggle_narration()
	check(not panel._audio.playing and panel._audio.stream == null, "No substitute audio")
	panel.close_interaction()
	panel.content = original
	preview.queue_free()
	await settle()
	print("CR-END-01: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
