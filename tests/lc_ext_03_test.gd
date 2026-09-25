extends SceneTree
## Real dispatched input, provenance, state lifecycle and landscape layout checks.

var failures: int = 0
var close_count: int = 0
const IMAGE_PATH := "res://assets/landmarks/lingayen_church/lc_ext_03/images/"
const MAIN_FILES := ["lc_ext_03_bells_overview.jpg.JPG", "lc_ext_03_bell_display_detail.jpg.JPG", "lc_ext_03_church_postwar_damage.jpg", "lc_ext_03_bells_overview.jpg.JPG"]
const SUPPORT_FILES := ["", "lc_ext_03_book_bells_display_crop.png", "lc_ext_03_book_bell_fell_crop.png", ""]
const HEADINGS := ["A Material Link to 1945", "Bells of the Earlier Church", "Wartime Destruction", "What the Bells Tell Us Today"]
const BODIES := [
	"Historical accounts record that Lingayen Church was partially destroyed during the liberation of Lingayen in 1945 and that old church bells fell during the destruction. Explore the three story points to understand how the bells connect the church’s earlier history, the wartime event, and its heritage today.",
	"Old church bells formed part of Lingayen Church’s earlier religious life. Parish historical accounts record that bells were present when the church was damaged during the liberation of Lingayen in 1945.",
	"During the liberation of Lingayen on January 9, 1945, bombing greatly damaged the bishop’s residence and partially destroyed the church. Historical accounts also record that old church bells fell during the destruction.",
	"Historic bells preserved at Lingayen Church connect visitors with the parish’s earlier history and its wartime story. Project sources record that old bells fell during the 1945 destruction, but the exact identity and dates of the bells currently displayed still require historical confirmation."
]
const CAPTIONS := ["Historic bells preserved on the church grounds today.", "Historic bells displayed on the church grounds.", "Lingayen Church showing wartime/postwar damage.", "Historic bells preserved on the church grounds today."]
const PHOTO := "PHOTO: AKAR Research Team, 2026"
const PAGE20 := "SOURCE: Lingayen: Memories of Times Past (2021), p. 20."
const PAGE30 := "SOURCE: Lingayen: Memories of Times Past (2021), p. 30."
const NOTE := "The exact identity and dates of the currently displayed bells remain subject to historical confirmation."
const BIBLIOGRAPHY := "Arcinue, Arabela Ventenilla (Ed.), & Sicam, Paulynn Paredes. (2021). Lingayen: Memories of Times Past. Lingayen, Pangasinan: Arabela Ventenilla Arcinue (Self-published)."

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 6:
		await process_frame

func key(code: Key, shift: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	event.shift_pressed = shift
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func press(control: Control, touch: bool = false, offset: Vector2 = Vector2.ZERO) -> void:
	var event: InputEvent
	if touch:
		event = InputEventScreenTouch.new()
	else:
		event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
	event.position = control.get_global_rect().get_center() + offset
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func finish(panel: Control) -> void:
	for tween in [panel._panel_tween, panel._fade]:
		if tween != null and tween.is_valid():
			tween.pause()
			tween.custom_step(1.0)
	await settle()

func capture(name: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join(name + ".png"))

func check_state(panel: Control, state: int, wartime_view: int = 0) -> void:
	check(panel.get_story_state() == state, "Authoritative story state")
	check(panel.get_wartime_view() == wartime_view, "Authoritative wartime sub-state")
	check(panel._heading.text == HEADINGS[state] and panel._body.text == BODIES[state], "Exact approved heading/body")
	check(panel._takeaway.text == "The story of Lingayen Church’s bells provides a tangible link to the wartime destruction of 1945.", "Approved takeaway")
	check(panel._prompt.visible == (state == 0) and panel._prompt.text == "Select a story point.", "Overview prompt")
	check(panel._note.visible == (state == 3), "Historical note only in Heritage Today")
	check(panel._note_text.text == (NOTE if state == 3 else ""), "Exact note without stale content")
	check(panel._comparison.visible == (state == 2), "Comparison only in wartime state")
	for i in 3:
		check(panel._concepts[i].button_pressed == (state == i + 1), "One story selected, none in Overview")
		check(panel._concepts[i].accessibility_name == ["HISTORIC BELLS", "JANUARY 9, 1945", "HERITAGE TODAY"][i], "Full accessible story labels")
	for i in 2:
		check(panel._comparison_buttons[i].button_pressed == (wartime_view == i), "One comparison selected")
	if state == 2 and wartime_view == 1:
		check(panel._image.texture == load("res://assets/landmarks/lingayen_church/lc_ext_01/images/lc_ext_01_exterior_current.jpg"), "Reuses LC-EXT-01 present photo")
		check(panel._caption.text == "Lingayen Church at present." and panel._credit.text == PHOTO, "Present photo attribution")
	else:
		if state == 1:
			check(panel._image.texture is AtlasTexture and panel._image.texture.atlas == load(IMAGE_PATH + MAIN_FILES[state]), "Non-destructive crop uses approved bell image")
		else:
			check(panel._image.texture == load(IMAGE_PATH + MAIN_FILES[state]), "Correct main image")
		check(panel._caption.text == CAPTIONS[state], "Correct main caption")
		check(panel._credit.text == (PAGE20 if state == 2 else PHOTO), "Correct image provenance")
	check(panel._support.visible == (state in [1, 2]), "Documentary evidence visibility")
	if state in [1, 2]:
		check(panel._support_image.texture == load(IMAGE_PATH + SUPPORT_FILES[state]), "Correct documentary crop")
		check(panel._support_credit.text == PAGE30, "Documentary credit distinct from team photos")
		var caption := "Book source showing the historic bells on display." if state == 1 else "Book source describing the large church bell that fell from the belfry."
		check(panel._support_caption.text == caption, "Exact support caption")
	else:
		check(panel._support_image.texture == null and panel._support_credit.text.is_empty(), "No stale documentary evidence")
	check(not panel._outgoing.visible and panel._outgoing_image.texture == null and is_equal_approx(panel._incoming.modulate.a, 1.0), "Crossfade fully settled")
	var visible_copy: String = panel._heading.text + panel._body.text + panel._note_text.text + panel._caption.text + panel._support_caption.text
	for prohibited in ["original Spanish bell", "1710 bell", "surviving bell from the tower", "1587", "1710", "1874", "1881", "1929", "casting year", "same bells that fell", "military unit", "aircraft", "weapon"]:
		check(not visible_copy.contains(prohibited), "Historical exclusion: " + prohibited)

func check_layout(panel: Control, dimensions: Vector2i) -> void:
	check(Rect2(Vector2.ZERO, Vector2(dimensions)).grow(0.1).encloses(panel.get_global_rect()), "Panel fits viewport")
	check(panel.get_global_rect().grow(0.1).encloses(panel.get_node("Main").get_global_rect()), "No whole-panel overflow")
	check(panel._title.get_global_rect().end.x <= panel._speaker.global_position.x, "Title clear of Listen")
	check(panel._speaker.get_global_rect().end.x <= panel._close.global_position.x, "Listen clear of Close")
	check(panel._pending.global_position.y >= panel._speaker.get_global_rect().end.y, "Pending status below Listen")
	var ratio: float = panel._media.size.x / (panel._media.size.x + panel._information.size.x)
	check(absf(ratio - 0.58) < 0.02, "58/42 media-led allocation")
	check(panel._image.size.x >= 350 and panel._image.size.y >= 150, "Main media remains usable: %s" % panel._image.size)
	check(panel._scroll.size.y >= 130, "Usable reading area: %s" % panel._scroll.size)
	if dimensions.x == 1280 and panel.get_story_state() == 1:
		check(not panel._scroll.get_v_scroll_bar().visible, "Historic Bells fits without reference-size scrolling: text %s / scroll %s" % [panel._body.get_parent().size, panel._scroll.size])
		check(panel._support_image.size.y >= 150, "Meaningful documentary preview")
		for item in [panel._support_caption, panel._support_credit, panel._detail_button]:
			check(panel.get_global_rect().encloses(item.get_global_rect()), "Evidence metadata fully visible")
	for rect in [panel._image, panel._support_image, panel._outgoing_image]:
		check(rect.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "All photos aspect-fit")
	for control in [panel._caption, panel._credit, panel._story_row, panel._sources_button, panel._close, panel._speaker, panel._pending]:
		check(panel.get_global_rect().grow(0.1).encloses(control.get_global_rect()), "Control within panel: " + control.name)
	check(panel._incoming.get_global_rect().grow(0.1).encloses(panel._credit.get_global_rect()), "Credit not clipped by media frame")
	for button in panel._concepts + panel._comparison_buttons + [panel._sources_button, panel._close, panel._speaker]:
		if button.is_visible_in_tree():
			check(button.size.x >= 48 and button.size.y >= 52, "Comfortable hit target")
	check(panel._story_row.global_position.y >= panel.get_node("Main/Margin/Layout/Columns").get_global_rect().end.y, "Story controls beneath both columns")
	check(panel._concepts[0].get_theme_stylebox("focus") != panel._concepts[0].get_theme_stylebox("pressed"), "Focus distinct from selected fill")
	check(panel._story_row.get_child_count() == 5, "Three evidence points with two decorative connectors")
	for i in 3:
		check(panel._concepts[i].text.is_empty() and not panel._story_labels[i].text.is_empty(), "Evidence node renders separate dot and label")
	if panel.get_story_state() == 1:
		for i in 2:
			var marker: Button = panel._bell_buttons[i]
			check(marker.size.is_equal_approx(Vector2(56, 56)), "56 px observation target")
			check(panel._bell_overlay.get_global_rect().grow(0.1).encloses(marker.get_global_rect()), "Observation target stays inside fitted crop")
			check((marker.position + marker.size * 0.5).is_equal_approx(panel.BELL_MARKERS[i] * panel._bell_overlay.size), "Normalized observation alignment")
		check(not panel._bell_buttons[0].get_global_rect().intersects(panel._bell_buttons[1].get_global_rect()), "Observation targets do not overlap")

func check_observation(panel: Control, observation: int) -> void:
	check(panel.get_bell_observation() == observation, "Authoritative bell observation")
	check(panel._bell_focus.visible == (observation != 0 and panel.get_story_state() == 1), "Bell focus visibility")
	for i in 2:
		check(panel._bell_buttons[i].button_pressed == (observation == i + 1), "Only one observation selected")
	if observation != 0:
		var region: Rect2 = panel.BELL_REGIONS[observation]
		check(panel._bell_focus.position.is_equal_approx(region.position * panel._bell_overlay.size), "Focus position normalized to crop")
		check(panel._bell_focus.size.is_equal_approx(region.size * panel._bell_overlay.size), "Focus size normalized to crop")
		check(panel._body.text == BODIES[1], "Observation does not reinterpret historical text")

func exercise_observations(panel: Control, dimensions: Vector2i) -> void:
	check_observation(panel, 0)
	check(panel._image.texture.region.is_equal_approx(Rect2(Vector2(2592, 1728) * panel.BELL_CROP.position, Vector2(2592, 1728) * panel.BELL_CROP.size)), "Atlas region uses original dimensions")
	for observation in [1, 2]:
		await press(panel._bell_buttons[observation - 1], true, Vector2(23, 0))
		await finish(panel)
		check_observation(panel, observation)
		check_layout(panel, dimensions)
		await capture("lc_ext_03_%d_observation%d" % [dimensions.x, observation])
	panel._bell_buttons[0].grab_focus()
	await key(KEY_RIGHT)
	check(root.gui_get_focus_owner() == panel._bell_buttons[1], "Observation arrow focus")
	await key(KEY_TAB, true)
	check(root.gui_get_focus_owner() == panel._bell_buttons[0], "Reverse observation focus")
	await key(KEY_SPACE)
	check_observation(panel, 1)
	for i in 30:
		panel.set_bell_observation(i % 2 + 1)
		panel.set_story_state(2)
		panel.set_story_state(3)
		panel.set_story_state(1)
	check_observation(panel, 0)
	panel.set_bell_observation(2)
	panel.open_sources()
	panel.set_bell_observation(1)
	check_observation(panel, 2)
	await key(KEY_ESCAPE)
	check_observation(panel, 2)
	panel.set_bell_observation(0)
	await finish(panel)

func exercise_detail(panel: Control, dimensions: Vector2i) -> void:
	var state: int = panel.get_story_state()
	var view: int = panel.get_wartime_view()
	var observation: int = panel.get_bell_observation()
	panel._detail_button.grab_focus()
	await settle()
	await press(panel._detail_button, true)
	check(panel._documentary.visible, "Touch opens nested documentary view")
	check(panel._documentary_image.texture == panel._support_image.texture, "Full documentary image without reinterpretation")
	check(panel._documentary_credit.text == PAGE30, "Detail keeps source credit")
	for control in [panel._documentary_image, panel._documentary_caption, panel._documentary_credit, panel._documentary_close]:
		check(panel.get_global_rect().encloses(control.get_global_rect()), "Documentary detail fits")
	check(panel._documentary_image.size.y >= 260, "Large documentary view")
	panel.set_story_state(3)
	panel.set_wartime_view(0)
	panel.set_bell_observation(1)
	check(panel.get_story_state() == state and panel.get_wartime_view() == view and panel.get_bell_observation() == observation, "Detail blocks background state mutation")
	await key(KEY_TAB)
	check(root.gui_get_focus_owner() == panel._documentary_close, "Documentary focus confinement")
	await capture("lc_ext_03_%d_story%d_detail" % [dimensions.x, state])
	await key(KEY_ESCAPE)
	check(panel._open and not panel._documentary.visible and not panel._sources.visible, "First Escape closes documentary only")
	check(root.gui_get_focus_owner() == panel._detail_button, "Detail returns focus to trigger")
	check(panel.get_story_state() == state and panel.get_wartime_view() == view and panel.get_bell_observation() == observation, "Detail preserves all state")
	panel._scroll.scroll_vertical = 0

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	root.content_scale_size = Vector2i(1280, 720)
	var preview = load("res://scenes/landmarks/lingayen_church/exterior/lc_ext_03_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("HotspotFrame/BellsInteraction")
	var trigger: Button = preview.get_node("Margin/Layout/OpenArtwork")
	panel.hotspot_closed.connect(func(): close_count += 1)
	check(not panel._open and not panel.visible, "Preview begins closed")
	check(root.content_scale_size == Vector2i.ZERO, "Preview uses actual logical client size")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		trigger.grab_focus()
		for control in [trigger, preview.get_node("Margin/Layout/Header"), preview.get_node("Margin/Layout/DevelopmentNote")]:
			check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(control.get_global_rect()), "Neutral preview fits")
		await capture("lc_ext_03_%d_preview" % dimensions.x)
		await press(trigger, dimensions.x == 960)
		await finish(panel)
		check_state(panel, 0)
		check_layout(panel, dimensions)
		check(root.gui_get_focus_owner() == panel._concepts[0], "Predictable opening focus without selection")
		check(panel._speaker.visible and panel._speaker.disabled and panel._speaker.text == "LISTEN", "Visible disabled narration")
		check(panel._pending.visible and panel._pending.text == "Narration pending.", "Narration pending")
		check(panel._audio.stream == null and not panel._audio.playing, "No autoplay or fake narration")
		for button in panel.find_children("*", "Button", true, false):
			check(button.text.to_upper() not in ["NEXT", "PREVIOUS", "REPLAY", "TRANSCRIPT", "READ TRANSCRIPT"], "No sequential/transcript controls")
		await capture("lc_ext_03_%d_overview" % dimensions.x)
		for state in [2, 1, 3, 2]:
			await press(panel._concepts[state - 1], state != 1)
			await finish(panel)
			check_state(panel, state)
			check_layout(panel, dimensions)
			await capture("lc_ext_03_%d_story%d" % [dimensions.x, state])
			if state == 1:
				await exercise_observations(panel, dimensions)
			if state in [1, 2]:
				await exercise_detail(panel, dimensions)
			# Evidence/note/takeaway stay reachable in the local reading flow.
			panel._scroll.scroll_vertical = 10000
			await settle()
			var takeaway_area: Control = panel._takeaway_row if panel._takeaway_row.visible else panel._scroll
			check(panel._takeaway.get_global_rect().end.y <= takeaway_area.get_global_rect().end.y + 1, "Takeaway reachable in footer or reading area")
			await capture("lc_ext_03_%d_story%d_reading" % [dimensions.x, state])
			panel._scroll.scroll_vertical = 0
		for view in [1, 0, 1]:
			var body_before: String = panel._body.text
			var support_before: Texture2D = panel._support_image.texture
			await press(panel._comparison_buttons[view], true)
			await finish(panel)
			check_state(panel, 2, view)
			check(panel._body.text == body_before and panel._support_image.texture == support_before, "Comparison changes only main media metadata")
			check_layout(panel, dimensions)
			await capture("lc_ext_03_%d_wartime%d" % [dimensions.x, view])
		panel.set_story_state(2)
		await finish(panel)
		check_state(panel, 2, 1)
		panel.set_story_state(1)
		panel.set_story_state(2)
		await finish(panel)
		check_state(panel, 2, 0)
		for i in 40:
			panel.set_story_state(i % 3 + 1)
		panel.set_story_state(2)
		for i in 50:
			panel.set_wartime_view(i % 2)
		await finish(panel)
		check_state(panel, 2, 1)
		panel.set_wartime_view(0)
		panel._fade.pause()
		panel._fade.custom_step(0.09)
		check(panel._incoming.modulate.a > 0 and panel._incoming.modulate.a < 1, "Restrained media crossfade")
		check(panel._outgoing_credit.text == PHOTO and panel._credit.text == PAGE20, "Outgoing photo retains its own credit during fade")
		await finish(panel)
		panel.set_wartime_view(1)
		panel.open_sources()
		check(panel._sources.visible and panel._source_text.text.contains(BIBLIOGRAPHY), "Full supplied source entry")
		check(panel._source_text.text.contains("p. 20") and panel._source_text.text.contains("p. 30"), "Source pages preserved")
		check_state(panel, 2, 1)
		panel.set_story_state(1)
		panel.set_wartime_view(0)
		check_state(panel, 2, 1)
		for i in 4:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() in [panel._source_scroll, panel._source_close], "Sources traps focus")
		await capture("lc_ext_03_%d_sources" % dimensions.x)
		await key(KEY_ESCAPE)
		check(panel._open and not panel._sources.visible and root.gui_get_focus_owner() == panel._sources_button, "Escape closes Sources first")
		check_state(panel, 2, 1)
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel._open and root.gui_get_focus_owner() == trigger, "Second Escape closes hotspot and restores launcher")
		await key(KEY_ENTER)
		await finish(panel)
		check_state(panel, 0)
		check(not panel._sources.visible and panel._audio.get_playback_position() == 0, "Sources/audio reset")
		await key(KEY_RIGHT)
		check(root.gui_get_focus_owner() == panel._concepts[1] and panel.get_story_state() == 0, "Arrow moves focus, not state")
		await key(KEY_SPACE)
		await finish(panel)
		check_state(panel, 2)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._concepts[2], "Story focus order")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._comparison_buttons[0], "Comparison joins focus order")
		await key(KEY_TAB)
		await key(KEY_ENTER)
		await finish(panel)
		check_state(panel, 2, 1)
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._comparison_buttons[0], "Reverse comparison focus")
		panel._scroll.grab_focus()
		await key(KEY_DOWN)
		check(panel._scroll.scroll_vertical > 0 or not panel._scroll.get_v_scroll_bar().visible, "Keyboard can scroll when reading exceeds viewport")
		panel.set_story_state(3)
		panel.open_sources()
		panel.reset_hotspot()
		check_state(panel, 0)
		check_observation(panel, 0)
		check(panel._fade == null and panel._panel_tween == null and not panel._sources.visible, "Reset clears transitions and Sources")
		panel.set_wartime_view(1)
		check_state(panel, 0)
		panel.set_story_state(3)
		panel.close_hotspot()
		panel.open_hotspot()
		await finish(panel)
		check_state(panel, 0)
		panel.set_story_state(-1)
		await finish(panel)
		check_state(panel, 0)
		await press(panel._close, true)
		await finish(panel)
		check(not panel._open, "Touch Close")
		print("LC-EXT-03 checked: ", dimensions)
	check(close_count == 6, "Exactly one notification per completed close")
	panel.open_hotspot()
	panel.set_story_state(2)
	panel.set_wartime_view(1)
	root.size = Vector2i(960, 540)
	await finish(panel)
	check_state(panel, 2, 1)
	check_layout(panel, root.size)
	root.size = Vector2i(854, 480)
	await settle()
	check_state(panel, 2, 1)
	check_layout(panel, root.size)
	preview.hide()
	check(not panel._open and panel._fade == null and panel._panel_tween == null and not panel._audio.playing, "Parent hide cleanup")
	preview.show()
	panel.open_hotspot()
	await finish(panel)
	check_state(panel, 0)
	panel.set_story_state(1)
	panel.set_bell_observation(2)
	root.size = Vector2i(1280, 720)
	await finish(panel)
	check_observation(panel, 2)
	check_layout(panel, root.size)
	root.size = Vector2i(854, 480)
	await settle()
	check_observation(panel, 2)
	check_layout(panel, root.size)
	panel.open_documentary_detail()
	panel.reset_hotspot()
	check(not panel._documentary.visible, "Reset clears documentary view")
	check_observation(panel, 0)
	panel.set_story_state(1)
	panel.open_documentary_detail()
	preview.queue_free()
	await settle()
	check(root.content_scale_size == Vector2i(1280, 720), "Preview restores host canvas sizing")
	print("LC-EXT-03 failures: ", failures)
	quit(1 if failures else 0)
