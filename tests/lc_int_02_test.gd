extends SceneTree
## The actual standalone component: exact supplied copy, real input and renders.

const YEARS := ["1500s", "1898", "1928", "1933", "1945", "1954", "1963", "1981"]
const TITLES := ["Early Missionary Activity", "Transition in Parish Administration", "Cathedral and Episcopal Seat", "Columban Missionary Service Begins", "Wartime Destruction", "Co-Cathedral Transition", "Metropolitan Archdiocese", "Filipino Diocesan Leadership Continues"]
const BODIES := [
	"Catholic missionary activity began in Lingayen during the 16th century through Augustinian missionaries. The mission was later administered by the Dominicans.",
	"Dominican administration came to an end around the close of Spanish rule, and the parish later came under Filipino diocesan clergy.",
	"On May 19, 1928, the Diocese of Lingayen was established, and Lingayen Church became its cathedral and episcopal seat.",
	"Columban missionaries began serving the cathedral parish in 1933, supporting pastoral, educational, and community work.",
	"During the liberation of Lingayen on January 9, 1945, the bishop's residence was greatly damaged, the church was partially destroyed, and old church bells fell.",
	"In 1954, the episcopal seat was transferred to Dagupan, while Lingayen retained its historical role as a co-cathedral.",
	"On February 16, 1963, Lingayen-Dagupan became a metropolitan archdiocese.",
	"In 1981, the Columban Fathers concluded their parish administration, and Filipino diocesan priests continued the ministry."
]
const TRANSFORMS := [
	["EARLY CATHOLIC MISSION", "AUGUSTINIAN MISSIONARIES", "LATER DOMINICAN ADMINISTRATION"],
	["DOMINICAN ADMINISTRATION", "TRANSITION TOWARD", "FILIPINO DIOCESAN CLERGY"],
	["PARISH CHURCH", "CATHEDRAL", "EPISCOPAL SEAT"],
	["PARISH ADMINISTRATION", "COLUMBAN MISSIONARY\nSERVICE BEGINS", ""],
	["PREWAR CHURCH", "1945 WARTIME DAMAGE", ""],
	["EPISCOPAL SEAT\nIN LINGAYEN", "SEAT TRANSFERRED\nTO DAGUPAN", "LINGAYEN REMAINS\nCO-CATHEDRAL"],
	["DIOCESE OF\nLINGAYEN-DAGUPAN", "METROPOLITAN\nARCHDIOCESE", ""],
	["COLUMBAN ADMINISTRATION", "FILIPINO DIOCESAN\nLEADERSHIP CONTINUES", ""]
]
const MEDIA := ["res://assets/landmarks/lingayen_church/lc_ext_01/images/lc_ext_01_exterior_current.jpg", "", "", "res://assets/landmarks/lingayen_church/lc_int_01/images/lc_int_01_guerrero_portrait.png", "res://assets/landmarks/lingayen_church/lc_int_01/images/lc_int_01_sheehan_portrait.png", "res://assets/landmarks/lingayen_church/lc_ext_03/images/lc_ext_03_church_postwar_damage.jpg", "", "res://assets/landmarks/lingayen_church/lc_int_01/images/lc_int_01_madriaga_portrait.png", ""]
const CREDITS := ["PHOTO: AKAR Research Team, 2026", "", "", "SOURCE: Lingayen: Memories of Times Past (2021), p. 16.", "IMAGE SOURCE: Missionary Society of St. Columban — Philippines", "SOURCE: Lingayen: Memories of Times Past (2021), p. 20.", "", "SOURCE: Lingayen: Memories of Times Past (2021), p. 17.", ""]
const MODES := [0, 2, 2, 1, 1, 0, 2, 1, 2]
const ERAS := [0, 1, 1, 2, 2, 3, 3, 4, 4]
const NOTE := "1710 is traditionally associated with the historic church structure, but it should not be treated as a confirmed parish founding date."
var failures: int = 0
var checks: int = 0
var close_count: int = 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 8:
		await process_frame

func finish(panel: Control) -> void:
	for tween in [panel._reveal, panel._panel_tween]:
		if tween != null and tween.is_valid():
			tween.pause()
			tween.custom_step(1.01)
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
	if touch:
		event = InputEventScreenTouch.new()
	else:
		event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
	# Effective target corner, outside the small visible dot.
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
		check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lc_int_02_" + name + ".png")) == OK, "Capture " + name)

func check_state(panel: Control, state: int) -> void:
	check(panel.selected_timeline_state == state and panel.get_active_era() == ERAS[state], "Authoritative state and exact era mapping")
	check(panel.get_media_mode() == MODES[state], "Intentional media mode")
	check(panel._note.visible == (state == 1), "1710 supplementary only in Early Mission")
	check(panel._note_body.text == (NOTE if state == 1 else ""), "Correct note without stale text")
	check(panel._points.size() == 8 and panel.content.milestones.size() == 8, "Exactly eight milestones, no 1710 point")
	check(panel.find_children("*", "Button", true, false).size() == 12, "Eight dates plus four shared controls; no carousel or comparison buttons")
	for i in 8:
		check(panel._points[i].year.text == YEARS[i], "Timeline dates ordered")
		check(panel._points[i].button_pressed == (state == i + 1), "Exactly one selected, NONE allows zero")
		check(panel._points[i].accessibility_name == YEARS[i] + " — " + TITLES[i], "Full accessible milestone name")
		check(panel.content.milestones[i].explanation == BODIES[i], "Exact supplied explanation")
	for i in 4:
		var style: StyleBoxFlat = panel._era_panels[i].get_theme_stylebox("panel")
		check(style.border_color == (panel.GOLD if ERAS[state] == i + 1 else Color("414b3e")), "Only mapped era active")
		check(panel._era_panels[i].focus_mode == Control.FOCUS_NONE and panel._era_panels[i].mouse_filter == Control.MOUSE_FILTER_IGNORE, "Passive era, no tabs")
	if state == 0:
		check(panel._heading.text == "A Church Across Changing Times", "Overview heading")
		check(panel._body.text == "From its missionary beginnings to its role as a co-cathedral, Lingayen Church passed through major periods of religious, institutional, and wartime change.", "Overview body")
		check(not panel._diagram.visible and panel._date.text.is_empty(), "Overview no stale transformation/date")
	else:
		check(panel._entry().result_connector == (["down", "none", "plus", "down", "down", "none", "down", "down"][state - 1]), "Correct succession/additional/retained relationship")
		check(panel._date.text == ("16th Century" if state == 1 else YEARS[state - 1]), "Exact date display")
		check(panel._heading.text == TITLES[state - 1] and panel._body.text == BODIES[state - 1], "Selected milestone copy")
		check(panel._source_basis.text == "Source: " + panel.content.milestones[state - 1].source_basis, "Correct source basis")
		for i in 3:
			check(panel._transform_labels[i].text.replace("\n", " ") == TRANSFORMS[state - 1][i].replace("\n", " "), "Exact transformation wording; responsive line breaks")
			check(panel._transform_labels[i].visible == not TRANSFORMS[state - 1][i].is_empty(), "Final transformation remains visible")
			check(is_equal_approx(panel._transform_labels[i].modulate.a, 1.0), "Transformation alpha settled")
	if MEDIA[state].is_empty():
		check(panel._image.texture == null and not panel._image.visible and not panel._missing.visible, "Transformation-only is complete without image placeholder")
	else:
		check(panel._image.texture.resource_path == MEDIA[state], "Exact original media reused")
		check(panel._image.visible and not panel._missing.visible, "Real media visible")
	check(panel._credit.text == CREDITS[state], "Correct original asset credit")
	check(not panel._outgoing.visible and panel._outgoing.texture == null, "No stale crossfade media")
	check(panel._speaker.visible and panel._speaker.disabled == (panel._audio.stream == null) and panel._pending.visible == (panel._audio.stream == null) and panel._pending.text == "Narration pending.", "One shared pending LISTEN")
	check(not panel._audio.playing and panel._audio.stream == panel.content.narration_stream, "No autoplay or stale audio")
	for connector in panel._connectors:
		check(connector.scale == Vector2.ONE, "Connector reveal settled")
	check(panel._takeaway.text == "Lingayen Church developed across missionary, cathedral, wartime, and co-cathedral periods while continuing to serve the religious community of Lingayen.", "Exact takeaway")

func check_layout(panel: Control, dimensions: Vector2i) -> void:
	var bounds: Rect2 = panel.get_global_rect().grow(0.2)
	check(Rect2(Vector2.ZERO, Vector2(dimensions)).grow(0.3).encloses(bounds), "Panel fits viewport")
	check(bounds.encloses(panel.get_node("Main").get_global_rect()), "No whole-screen overflow")
	for item in [panel._time_window, panel._stage, panel._ribbon, panel._era_strip, panel._takeaway, panel._sources_button, panel._pending, panel._close]:
		check(bounds.encloses(item.get_global_rect()), "Main control contained: " + item.name)
	check(panel._title.get_global_rect().end.x <= panel._speaker.global_position.x, "Header no overlap")
	var ratio: float = panel._time_window.size.x / (panel._time_window.size.x + panel._information.size.x)
	check(absf(ratio - 0.6) < 0.02, "60/40 visual/interpretation")
	for i in 8:
		var point: Control = panel._points[i]
		check(point.size.x >= 56 and point.size.y >= 56, "Large timeline target")
		check(bounds.encloses(point.get_global_rect()), "All eight dates visible")
		check(point.get_theme_stylebox("focus") != point.get_theme_stylebox("pressed"), "Focus distinct from selection")
		if i < 7:
			check(not point.get_global_rect().intersects(panel._points[i + 1].get_global_rect()), "No overlapping hit regions")
	if panel.selected_timeline_state != 0:
		for label in panel._transform_labels:
			if label.visible:
				check(panel._stage.get_global_rect().grow(0.2).encloses(label.get_global_rect()), "Transformation readable within Time Window: %s %s in %s" % [label.text, label.get_global_rect(), panel._stage.get_global_rect()])
	if panel.get_media_mode() == 1:
		check(panel._image.size.x / panel._stage.size.x > 0.25 and panel._image.size.x / panel._stage.size.x < 0.35, "Contextual portrait is supporting 25–35% width")
	check(panel._image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Source aspect preserved")
	if dimensions.x == 1280:
		check(not panel._scroll.get_v_scroll_bar().visible, "Normal reference-size interpretation fits: %s in %s" % [panel._body.get_parent().size, panel._scroll.size])
	check(panel._stage.size.y >= 80, "Time Window has meaningful height")

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	Input.emulate_mouse_from_touch = true
	var preview: Control = load("res://scenes/landmarks/lingayen_church/interior/lc_int_02_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel: Control = preview.get_node("HotspotFrame/ChurchInteraction")
	panel.content = panel.content.duplicate(true)
	panel.close_requested.connect(func() -> void: close_count += 1)
	var trigger: Button = preview.get_node("Margin/Layout/OpenArtwork")
	check(trigger.text == "Explore the Timeline", "Preview opens actual hotspot")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		await capture("%d_preview" % dimensions.x)
		await press(trigger)
		await finish(panel)
		check_state(panel, 0)
		check_layout(panel, dimensions)
		check(root.gui_get_focus_owner() == panel._points[0], "Default focus without selecting")
		await capture("%d_overview" % dimensions.x)
		for state in range(1, 9):
			await press(panel._points[state - 1])
			check(panel.selected_timeline_state == state, "Input immediately establishes authoritative state")
			await finish(panel)
			check_state(panel, state)
			check_layout(panel, dimensions)
			await capture("%d_%s" % [dimensions.x, YEARS[state - 1]])
		panel._points[0].grab_focus()
		await key(KEY_LEFT)
		check(root.gui_get_focus_owner() == panel._points[0] and panel.selected_timeline_state == 8, "Left clamps; focus does not select")
		for i in range(1, 8):
			await key(KEY_RIGHT)
			check(root.gui_get_focus_owner() == panel._points[i] and panel.selected_timeline_state == 8, "Chronological focus only")
		await key(KEY_RIGHT)
		check(root.gui_get_focus_owner() == panel._points[7], "Right clamps")
		await key(KEY_LEFT)
		await key(KEY_ENTER)
		await finish(panel)
		check_state(panel, 7)
		await key(KEY_LEFT)
		await key(KEY_SPACE)
		await finish(panel)
		check_state(panel, 6)
		panel._points[7].grab_focus()
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._scroll, "Tab skips disabled LISTEN")
		await press(panel._sources_button)
		check(panel._sources.visible and root.gui_get_focus_owner() == panel._source_close, "Sources focus")
		check(panel._source_text.text == panel.content.sources_text, "Full sources preserved")
		check_state(panel, 6)
		await capture("%d_sources" % dimensions.x)
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel._open, "Escape closes Sources first")
		check_state(panel, 6)
		await press(panel._sources_button, true)
		check(panel._sources.visible, "Synthetic touch opens Sources")
		await press(panel._source_close, true)
		check(not panel._sources.visible and panel.selected_timeline_state == 6, "Touch closes Sources preserving timeline")
		for state in [3, 5, 8, 4, 6]:
			var stale: Tween = panel._reveal
			panel.set_timeline_state(state)
			check(stale == null or not stale.is_valid(), "Previous reveal killed before next selection")
		await finish(panel)
		check_state(panel, 6)
		for state in range(1, 9):
			await press(panel._points[state - 1], true)
			await finish(panel)
			check_state(panel, state)
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel._open and root.gui_get_focus_owner() == trigger, "Second Escape closes and restores focus")
		print("LC-INT-02 input/layout checked at ", dimensions)
	await press(trigger)
	await finish(panel)
	check_state(panel, 0)
	root.size = Vector2i(1280, 720)
	await settle()
	# Step a paused real tween to inspect ordering/duration without wall-clock flakiness.
	for state in range(1, 9):
		panel.set_timeline_state(state)
		panel._reveal.pause()
		await settle()
		var rect_before: Rect2 = panel._ribbon.get_global_rect()
		panel._reveal.custom_step(0.10)
		check(panel._transform_labels[0].modulate.a > 0 and panel._transform_labels[1].modulate.a == 0, "Context precedes change")
		check(is_zero_approx(panel._connectors[0].scale.y), "Layout preserves hidden connector before its reveal")
		if state == 6: await capture("1280_1954_reveal_context")
		panel._reveal.custom_step(0.65)
		check(panel._transform_labels[1].modulate.a > 0 and panel._body.modulate.a == 0, "Transformation precedes explanation")
		if state == 6: await capture("1280_1954_reveal_change")
		panel._reveal.custom_step(0.26)
		await settle()
		check_state(panel, state)
		check(panel._ribbon.get_global_rect() == rect_before, "No animation-driven layout movement")
		check(not panel._reveal.is_running(), "Complete reveal at or below one second")
		if state == 6: await capture("1280_1954_reveal_final")
	# Host low-motion opt-out resolves the same final content immediately.
	panel.animate_reveals = false
	for state in range(0, 9):
		panel.set_timeline_state(state)
		check_state(panel, state)
		check(panel._reveal == null, "Instant presentation has no queued tween")
	panel.animate_reveals = true
	for state in [1, 5]:
		panel.set_timeline_state(state)
		panel.open_sources()
		check(panel._sources.visible and panel._reveal == null, "Sources safely settles ongoing reveal")
		check_state(panel, state)
		panel.close_sources()
		check_state(panel, state)
	for state in [0, 3, 4, 5, 7]:
		var texture: Texture2D = panel.content.overview_media if state == 0 else panel.content.milestones[state - 1].media
		if state == 0: panel.content.overview_media = null
		else: panel.content.milestones[state - 1].media = null
		panel.set_timeline_state(state)
		await finish(panel)
		check(panel._missing.visible and panel._missing.text == "DOCUMENTARY IMAGE\nSOURCE UNAVAILABLE" and panel._image.texture == null, "Safe missing media, never substituted")
		check(panel._diagram.visible == (state != 0), "Fallback retains transformation and date/title")
		await capture("1280_fallback_%d" % state)
		if state == 0: panel.content.overview_media = texture
		else: panel.content.milestones[state - 1].media = texture
	panel.set_timeline_state(1)
	var clip := AudioStreamWAV.new()
	clip.mix_rate = 44100
	var silence := PackedByteArray()
	silence.resize(44100 * 2)
	clip.data = silence
	var original_narration: AudioStream = panel.content.narration_stream
	panel.content.narration_stream = clip
	panel.set_timeline_state(1)
	check(panel._audio.stream == clip and not panel._speaker.disabled, "Overall hotspot narration binding")
	panel.toggle_narration()
	check(panel._audio.playing, "LISTEN can play future selected clip")
	panel.set_timeline_state(5)
	check(panel._audio.playing and panel._audio.stream == clip, "Overall narration persists across milestones")
	panel.set_timeline_state(1)
	panel.toggle_narration()
	panel.close_interaction()
	check(not panel._audio.playing, "Closing immediately stops narration")
	panel.open_hotspot()
	panel.content.narration_stream = original_narration
	panel.reset_hotspot()
	await finish(panel)
	check_state(panel, 0)
	check(panel._reveal == null and not panel._sources.visible, "Reset kills active reveal")
	panel.set_timeline_state(5)
	panel.open_sources()
	check(panel._sources.visible and panel._reveal == null, "Sources during reveal settles newest state safely")
	panel.close_sources()
	panel.close_interaction()
	panel.open_hotspot()
	await finish(panel)
	check_state(panel, 0)
	check(not panel._closing and panel.modulate.a == 1, "Reopen cancels pending close")
	await press(panel._close, true)
	await finish(panel)
	check(not panel._open, "Touch close")
	check(close_count == 4, "External close_requested once per completed close")
	await press(trigger)
	panel.set_timeline_state(3)
	preview.get_node("HotspotFrame").hide()
	await settle()
	check(not panel._open and panel._reveal == null and not panel._audio.playing, "Parent-hide cleanup")
	preview.queue_free()
	await settle()
	print("LC-INT-02: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
