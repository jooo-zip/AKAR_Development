extends SceneTree
## Exercise the real inset component with input, geometry and optional captures.

const TITLES := ["Historical Roots", "Cathedral & Co-Cathedral", "War & Recovery", "Living Heritage"]
const HEADINGS := ["Centuries of Religious History", "A Changing Institutional Role", "History Marked by Wartime Change", "A Historic Church Still in Use"]
const BODIES := [
	"Lingayen Church traces its history to early Catholic missionary activity in the 16th century and was historically known as Los Tres Reyes or the Three Kings Parish.",
	"Lingayen Church became the cathedral and episcopal seat of the Diocese of Lingayen in 1928. After the episcopal seat moved to Dagupan in 1954, the church retained its historical role as a co-cathedral.",
	"The church was partially destroyed during the 1945 liberation of Lingayen and was later reconstructed. Surviving historical features continue to connect the present church with its wartime past.",
	"Lingayen Church is not only a historical site. It remains an active Roman Catholic parish and co-cathedral serving the religious community of Lingayen."
]
const MEANINGS := [
	"A long religious history connected with the development of Lingayen.",
	"A church whose institutional role changed while its historical significance continued.",
	"A heritage site shaped by destruction, recovery, and historical continuity.",
	"A connection between Lingayen's historical heritage and continuing religious community life."
]
const CONTEXT := [
	["EARLY MISSIONARY ROOTS", "LOS TRES REYES"],
	["1928\nCATHEDRAL & EPISCOPAL SEAT", "1954\nCO-CATHEDRAL"],
	["1945\nWARTIME DAMAGE", "↓\nRECONSTRUCTION"],
	["ACTIVE PARISH", "+\nCO-CATHEDRAL TODAY"]
]
const REFLECTION := "What makes Lingayen Church both a historical landmark and a living place of faith today?"
const SYNTHESIS := "Lingayen Church represents centuries of religious history, institutional change, wartime experience, and continuing community life. Its role has changed across time, but it remains an active co-cathedral and an important part of Lingayen's heritage."
const PHOTO := "res://assets/landmarks/lingayen_church/lc_ext_01/images/lc_ext_01_exterior_current.jpg"
var checks: int = 0
var failures: int = 0
var close_count: int = 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 8: await process_frame

func finish(panel: Control) -> void:
	for tween in [panel._transition, panel._panel_tween]:
		if tween != null and tween.is_valid():
			tween.pause()
			tween.custom_step(0.5)
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

func press(control: Control, touch: bool = false) -> void:
	var event: InputEvent
	if touch: event = InputEventScreenTouch.new()
	else:
		event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
	event.position = control.global_position + Vector2(5, 5)
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func capture(name: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lc_end_01_" + name + ".png")) == OK, "Capture " + name)

func check_state(panel: Control, state: int, missing: bool = false) -> void:
	check(panel.selected_theme == state, "Authoritative selection")
	check(panel._cards.size() == 4 and panel.content.themes.size() == 4, "Exactly four themes")
	check(panel.find_children("*", "Button", true, false).size() == 9, "Four themes, center and shared controls only")
	check(panel.find_children("*", "LineEdit", true, false).is_empty() and panel.find_children("*", "TextEdit", true, false).is_empty(), "No reflection input")
	check(panel._image.texture == panel.content.center_media and panel._image.visible == not missing, "Stable existing center image in every state")
	check(panel._fallback.visible == missing, "Safe media fallback only when missing")
	check(panel._center.accessibility_name == "Return to overview of what Lingayen Church represents", "Center overview accessible name")
	check(not panel._center.toggle_mode and not panel._center.button_pressed, "Center is not a fifth theme")
	check(panel._takeaway.visible and panel._takeaway.text == REFLECTION, "Exact passive reflection always visible")
	check(panel._speaker.visible and panel._speaker.disabled and panel._pending.visible and panel._pending.text == "Narration pending.", "One disabled pending LISTEN")
	check(not panel._audio.playing and panel._audio.stream == null, "No autoplay or theme audio")
	if not missing:
		check(panel._image.texture.resource_path == PHOTO, "Exact asset reference")
		check(panel._credit.text == "PHOTO: AKAR Research Team, 2026", "Exact provenance")
	for i in 4:
		check(panel._cards[i].button_pressed == (state == i + 1), "Exclusive theme selection")
		check(panel._connectors[i].default_color == (panel.GOLD if state == i + 1 else panel.NEUTRAL), "Exclusive connector emphasis")
		check(panel.content.themes[i].interpretation == BODIES[i] and panel.content.themes[i].meaning_statement == MEANINGS[i], "Exact resource copy")
		check(panel._cards[i].accessibility_name.ends_with(" — summary theme"), "Accessible theme label")
	if state == 0:
		check(panel._heading.text == "Four Meanings, One Historic Church", "Overview heading")
		check(panel._body.text == "Lingayen Church brings together centuries of religious history, institutional change, wartime experience, and continuing community life.", "Overview body")
		check(panel._synthesis.visible and panel._synthesis.text == SYNTHESIS, "Exact overall synthesis in overview")
		check(panel._primary.text == "ONE CHURCH" and panel._secondary.text == "FOUR CONNECTED MEANINGS", "Neutral center context")
		check(not panel._meaning.visible and panel._meaning.text.is_empty(), "No stale meaning")
	else:
		check(panel._theme_label.text == TITLES[state - 1] and panel._heading.text == HEADINGS[state - 1], "Full selected theme and heading")
		check(panel._body.text == BODIES[state - 1] and panel._meaning.text == MEANINGS[state - 1], "Exact interpretation and meaning")
		check(panel._meaning_label.text == "What it represents", "Meaning signpost")
		check(panel._primary.text.replace("\n", " ") == CONTEXT[state - 1][0].replace("\n", " ") and panel._secondary.text.replace("\n", " ") == CONTEXT[state - 1][1].replace("\n", " "), "Exact center context with responsive line breaks")
		check(panel._source_basis.text == "Source: " + panel.content.themes[state - 1].source_basis, "Source basis follows theme")
		check(not panel._synthesis.visible and panel._synthesis.text.is_empty(), "Only one interpretation paragraph per theme")
	check(is_equal_approx(panel._information.modulate.a, 1.0) and is_equal_approx(panel._context.modulate.a, 1.0), "Final content readable")
	check(not panel._outgoing_detail.visible and panel._outgoing_detail.get_child_count() == 0, "No stale outgoing detail after transition")

func check_layout(panel: Control, dimensions: Vector2i) -> void:
	var bounds: Rect2 = panel.get_global_rect().grow(0.5)
	check(Rect2(Vector2.ZERO, Vector2(dimensions)).grow(1).encloses(bounds), "Inset panel fits viewport")
	check(bounds.encloses(panel.get_node("Main").get_global_rect()), "No whole-screen overflow")
	var map_bounds: Rect2 = panel._map.get_global_rect().grow(0.5)
	for item in [panel._map, panel._information, panel._takeaway, panel._sources_button, panel._close, panel._pending]:
		check(bounds.encloses(item.get_global_rect()), "Main control fits: " + item.name)
	check(panel._title.get_global_rect().end.x <= panel._speaker.global_position.x, "Header avoids LISTEN")
	check(absf(panel._map.size.x / (panel._map.size.x + panel._information.size.x) - 0.6) < 0.02, "60/40 split")
	for control in panel._cards + [panel._center]:
		check(control.size.x >= 56 and control.size.y >= 56, "Large touch target")
		check(map_bounds.encloses(control.get_global_rect()), "All four themes and center remain visible")
		check(control.get_theme_stylebox("focus") != control.get_theme_stylebox("pressed"), "Focus distinct from selected")
	for i in 4:
		check(not panel._cards[i].get_global_rect().intersects(panel._center.get_global_rect()), "Center/card hit regions do not overlap")
		check(panel._cards[i].label.size.y >= panel._cards[i].label.get_minimum_size().y, "Card label fits")
		for point in panel._connectors[i].points:
			check(Rect2(Vector2.ZERO, panel._map.size).grow(1).has_point(point), "Connector stays within map")
	for label in [panel._primary, panel._secondary, panel._center_title, panel._image]:
		check(panel._center.get_global_rect().grow(0.5).encloses(label.get_global_rect()), "Center media/context fits: " + label.name)
	check(panel._image.size.y >= 35, "Center photo remains recognizable")
	check(panel._image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Photo aspect preserved")
	if dimensions.x == 1280:
		check(not panel._scroll.get_v_scroll_bar().visible, "Reference interpretation fits without scroll, state %s" % panel.selected_theme)

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	Input.emulate_mouse_from_touch = true
	var preview: Control = load("res://scenes/landmarks/lingayen_church/interior/lc_end_01_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel: Control = preview.get_node("HotspotFrame/ChurchInteraction")
	panel.content = panel.content.duplicate(true)
	panel.close_requested.connect(func() -> void: close_count += 1)
	var trigger: Button = preview.get_node("Margin/Layout/OpenArtwork")
	check(trigger.text == "Explore the Summary", "Preview opens actual component")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		await capture("%d_preview" % dimensions.x)
		await press(trigger)
		await finish(panel)
		check_state(panel, 0)
		check_layout(panel, dimensions)
		check(root.gui_get_focus_owner() == panel._cards[0], "Default focus, no default selection")
		await capture("%d_overview" % dimensions.x)
		for state in [4, 1, 3, 2]:
			await press(panel._cards[state - 1])
			await finish(panel)
			check_state(panel, state)
			check_layout(panel, dimensions)
			await capture("%d_theme_%d" % [dimensions.x, state])
		# Exhaustively check every spatial direction, including clamped edges.
		var neighbors := [[0, 1, 0, 2], [0, 1, 1, 3], [2, 3, 0, 2], [2, 3, 1, 3]]
		for i in 4:
			for direction in 4:
				panel._cards[i].grab_focus()
				await key([KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN][direction])
				check(root.gui_get_focus_owner() == panel._cards[neighbors[i][direction]] and panel.selected_theme == 2, "Spatial arrows focus only without wrap")
		panel._cards[0].grab_focus()
		await key(KEY_ENTER)
		await finish(panel)
		check_state(panel, 1)
		await key(KEY_DOWN)
		await key(KEY_SPACE)
		await finish(panel)
		check_state(panel, 3)
		panel._cards[3].grab_focus()
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._center, "Center follows themes in Tab order")
		await key(KEY_ENTER)
		await finish(panel)
		check_state(panel, 0)
		panel.set_selected_theme(4)
		await key(KEY_SPACE)
		await finish(panel)
		check_state(panel, 0)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._scroll, "Tab skips disabled LISTEN")
		for state in [1, 4, 3, 2]:
			var old: Tween = panel._transition
			panel.set_selected_theme(state)
			check(old == null or not old.is_valid(), "Rapid switching kills old tween")
		await finish(panel)
		check_state(panel, 2)
		await press(panel._sources_button)
		check(panel._sources.visible and panel._source_text.text == panel.content.sources_text, "Sources opens exact source groups")
		check_state(panel, 2)
		await capture("%d_sources" % dimensions.x)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._source_scroll, "Sources focus trap")
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel._open, "Escape closes Sources first")
		check_state(panel, 2)
		for state in range(1, 5):
			await press(panel._cards[state - 1], true)
			await finish(panel)
			check_state(panel, state)
		await press(panel._center, true)
		await finish(panel)
		check_state(panel, 0)
		await capture("%d_center_return" % dimensions.x)
		await press(panel._sources_button, true)
		check(panel._sources.visible, "Touch Sources")
		await press(panel._source_close, true)
		check(not panel._sources.visible, "Touch Close Sources")
		panel.set_selected_theme(4)
		panel._scroll.scroll_vertical = 200
		panel.set_selected_theme(2)
		await finish(panel)
		check(panel._scroll.scroll_vertical == 0, "Selection resets reading position")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel._open and not panel.visible, "Second-level Escape closes hotspot")
		print("LC-END-01 input/layout checked at ", dimensions)
	check(close_count == 3, "One close notification per viewport")
	root.size = Vector2i(1280, 720)
	await settle()
	panel.open_hotspot()
	await finish(panel)
	check_state(panel, 0)
	for state in range(1, 5):
		panel.set_selected_theme(state)
		panel._transition.pause()
		await settle()
		var map_rect: Rect2 = panel._map.get_global_rect()
		panel._transition.custom_step(0.10)
		check(panel._context.modulate.a > 0 and is_zero_approx(panel._information.modulate.a), "Center context precedes detail fade")
		check(panel._outgoing_detail.visible and panel._outgoing_detail.get_child_count() == 1, "Only one clipped outgoing presentation copy")
		panel._transition.custom_step(0.12)
		check(panel._outgoing_detail.modulate.a > 0 and panel._outgoing_detail.modulate.a < 1 and panel._information.modulate.a > 0, "Old and new detail crossfade together")
		panel._transition.custom_step(0.11)
		await settle()
		check_state(panel, state)
		check(not panel._transition.is_running() and panel._map.get_global_rect() == map_rect, "320ms transition, no layout movement")
	# Modal opening during a reveal settles presentation but preserves state.
	panel.set_selected_theme(2)
	panel.open_sources()
	check_state(panel, 2)
	panel.close_sources()
	panel.animate_transitions = false
	for state in range(0, 5):
		panel.set_selected_theme(state)
		check_state(panel, state)
		check(panel._transition == null, "Instant presentation option")
	panel.animate_transitions = true
	var media: Texture2D = panel.content.center_media
	panel.content.center_media = null
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		for state in range(0, 5):
			panel.set_selected_theme(state)
			await finish(panel)
			check_state(panel, state, true)
			check_layout(panel, dimensions)
			check(panel._center.get_global_rect().grow(0.5).encloses(panel._fallback.get_global_rect()), "Fallback text fits center")
		await capture("%d_fallback" % dimensions.x)
	check(panel._fallback.text == "LINGAYEN CHURCH\nEPIPHANY OF OUR LORD\nCO-CATHEDRAL PARISH", "Exact safe fallback")
	panel.content.center_media = media
	root.size = Vector2i(1280, 720)
	await settle()
	# Only one overall narration stream; no per-theme players/resources.
	var clip := AudioStreamWAV.new()
	clip.mix_rate = 8000
	clip.data = PackedByteArray()
	clip.data.resize(80000)
	panel.content.narration = clip
	panel.set_selected_theme(1)
	panel.toggle_narration()
	check(panel._audio.playing and not panel._speaker.disabled, "Future overall narration works")
	panel.set_selected_theme(2)
	check(not panel._audio.playing and panel._audio.stream == clip, "Selection stops audio and retains overall stream")
	panel.toggle_narration()
	panel.close_interaction()
	check(not panel._audio.playing, "Close immediately stops narration")
	panel.content.narration = null
	panel.open_hotspot()
	await finish(panel)
	check_state(panel, 0)
	panel.set_selected_theme(3)
	panel.reset_hotspot()
	check_state(panel, 0)
	panel.set_selected_theme(4)
	preview.hide()
	await settle()
	check(not panel._open and panel._transition == null and not panel._audio.playing, "Parent hide cleans up")
	preview.show()
	panel.open_hotspot()
	await finish(panel)
	panel.set_selected_theme(4)
	await press(panel._center)
	await finish(panel)
	check_state(panel, 0)
	await press(panel._close, true)
	await finish(panel)
	check(not panel._open, "Touch Close")
	# No completion/prerequisite or reflection persistence is introduced.
	var source := FileAccess.get_file_as_string("res://scripts/landmarks/lingayen_church/lc_end_01.gd").to_lower()
	for forbidden in ["completed", "unlocked", "visited_themes", "4/4", "fileaccess", "httprequest", "1710"]:
		check(not source.contains(forbidden), "No completion/storage/extra historical state: " + forbidden)
	preview.queue_free()
	await settle()
	print("LC-END-01: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
