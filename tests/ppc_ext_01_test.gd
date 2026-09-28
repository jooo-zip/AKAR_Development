extends SceneTree
## Exercise the real production component with dispatched mouse, touch and keys.

const IDS := [&"capitol", &"civic_setting", &"government_today"]
const LABELS := ["THE CAPITOL", "CIVIC SETTING", "GOVERNMENT TODAY"]
const CONTEXTS := ["SEAT OF PROVINCIAL GOVERNMENT", "WITHIN THE GOVERNMENT COMPLEX", "CONTINUING CIVIC ROLE"]
const HEADINGS := ["The Pangasinan Provincial Capitol", "A Landmark Framed by Its Setting", "A Working Seat of Provincial Government"]
const BODIES := [
	"The Pangasinan Provincial Capitol is the seat of the Provincial Government of Pangasinan. Located in Lingayen, it continues to serve as an active center of provincial governance.",
	"The Capitol stands within a spacious government complex near Lingayen Gulf. Formal gardens, lawns, paved approaches, and tree-lined avenues frame the building.",
	"The Capitol continues to serve the Provincial Government of Pangasinan while preserving its historical character. It remains both a heritage landmark and an active government building."
]
const TAKEAWAYS := [
	"A historic landmark that remains a working government center.",
	"Its setting strengthens its role as a civic landmark.",
	"Its history and government function continue today."
]
const CAPTIONS := [
	"Present-day view of the Pangasinan Provincial Capitol, Lingayen.",
	"The Capitol within its formal government-complex setting in Lingayen.",
	"The Pangasinan Provincial Capitol remains an active provincial government center."
]
const IMAGES := ["ppc_ext_01_capitol_present.JPG", "ppc_ext_01_civic_setting.png", "ppc_ext_01_government_today.jpeg"]
const TRANSCRIPT := "Welcome to the Pangasinan Provincial Capitol in Lingayen. The Capitol is the building where the executive and legislative functions of the Provincial Government of Pangasinan are carried out. It stands within a spacious government complex near Lingayen Gulf, framed by formal gardens, open lawns, paved approaches, and tree-lined avenues. More than a historic landmark, the Capitol continues to serve as a center of provincial governance today. Explore the views to learn about the building, its civic setting, and its continuing role."
var failures: int = 0
var checks: int = 0
var starts: int = 0
var closes: int = 0


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)


func settle() -> void:
	for i in 6:
		await process_frame


func finish(panel) -> void:
	for tween in [panel._transition, panel._explore_tween]:
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


func assert_state(panel, index: int) -> void:
	check(panel.current_view == IDS[index] and panel.get_selected_concept() == index, "Authoritative view")
	check(panel._context.text == CONTEXTS[index], "Exact context")
	check(panel._heading.text == HEADINGS[index], "Exact heading")
	check(panel._body.text == BODIES[index], "Exact approved body")
	check(panel._takeaway.text == TAKEAWAYS[index], "Exact takeaway")
	check(panel._takeaway.visible, "Takeaway retained")
	check(panel.find_children("*", "Label", true, false).all(func(label): return label.text != "HISTORICAL TAKEAWAY"), "Takeaway heading removed")
	var observations: Array[String] = []
	for i in panel._observation_tags.size():
		if panel._observation_tags[i].visible:
			observations.append(panel._observation_labels[i].text)
	var expected: Array = [[], ["CAPITOL", "FORMAL APPROACH", "LANDSCAPED GROUNDS"], ["ACTIVE GOVERNMENT CENTER"]][index]
	check(observations == expected, "Exact observational labels")
	check(panel._focus_frame.visible == (index == 0), "Whole-landmark focus only on Capitol")
	check(panel._caption.text == CAPTIONS[index], "Exact caption")
	check(panel._image.texture.resource_path == "res://assets/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01/" + IMAGES[index], "Correct documentary photo")
	check(panel._image.modulate == Color.WHITE and panel.scale == Vector2.ONE, "No stale transforms")
	for i in 3:
		check(panel._concepts[i].button_pressed == (i == index), "Exactly one selected view")
		check(panel._concepts[i].text == LABELS[i], "Exact selector label")


func assert_layout(panel, dimensions: Vector2i) -> void:
	var bounds: Rect2 = panel.get_global_rect().grow(1.0)
	check(Rect2(Vector2.ZERO, dimensions).encloses(panel.get_global_rect()), "Panel within viewport")
	check(bounds.encloses(panel.get_node("Main").get_global_rect()), "No root overflow")
	for control in panel._concepts + [panel._photo_button, panel._sources_button, panel._speaker, panel._close, panel._source_close, panel._explore_close]:
		check(control.custom_minimum_size.y >= 56 and control.custom_minimum_size.x >= 48, "Declared touch target: " + control.name)
		if control.is_visible_in_tree():
			check(control.size.y >= 56 and control.size.x >= 48, "Laid-out touch target: " + control.name)
			check(bounds.encloses(control.get_global_rect()), "Control contained: " + control.name)
		check(control.get_theme_stylebox("focus") != control.get_theme_stylebox("pressed"), "Focus differs from selection")
	for control in [panel._title, panel._subtitle, panel._media, panel._caption, panel._scroll]:
		check(bounds.encloses(control.get_global_rect()), "Layout contained: " + control.name)
	check(panel._title.get_global_rect().end.x <= panel._sources_button.global_position.x, "Title clear of header controls")
	check(panel._sources_button.get_global_rect().end.x <= panel._speaker.global_position.x, "Sources before Listen")
	check(panel._speaker.get_global_rect().end.x <= panel._close.global_position.x, "Listen before Close")
	check(panel._subtitle.get_global_rect().end.y <= panel._concepts[0].global_position.y, "Header above selectors")
	check(panel._concepts[0].get_global_rect().end.y <= panel._media.global_position.y, "Selectors above photo")
	check(panel._media.get_global_rect().end.x <= panel._information.global_position.x, "Side-by-side panels")
	var share: float = panel._media.size.x / (panel._media.size.x + panel._information.size.x)
	check(absf(share - (0.59 if dimensions.x == 1280 else 0.55)) < 0.015, "Responsive photo share: " + str(share))
	check(panel._scroll.size.y >= 200, "Useful local reading area")
	check(panel._body.get_theme_font_size("font_size") >= 18, "Readable compact body")
	if dimensions.x == 1280:
		check(panel._body.get_parent().size.y <= panel._scroll.size.y, "Full-size interpretation fits without scrolling")
	check(panel._scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "No sideways text scrolling")
	check(panel._image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Photo aspect preserved")
	check(panel._photo_button.size.x >= 200 and panel._photo_button.size.y >= 90, "Large tappable photo area")
	check(panel._photo_button.get_global_rect() == panel._photo_frame.get_global_rect(), "Entire photo area is interactive")
	check(panel._photo_button.focus_mode == Control.FOCUS_ALL, "Image is keyboard focusable")
	check(panel._photo_button.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "Image uses pointer cursor")
	check(panel._photo_button.icon == null and panel._photo_button.text.is_empty(), "No invented icon or image instruction")
	var hover: StyleBoxFlat = panel._photo_button.get_theme_stylebox("hover")
	check(not hover.draw_center and hover.border_width_left == 1, "Restrained photo hover outline")
	for i in panel._observation_tags.size():
		var tag: PanelContainer = panel._observation_tags[i]
		if not tag.is_visible_in_tree():
			continue
		check(bounds.encloses(tag.get_global_rect()), "Observation label contained")
		check(tag.focus_mode == Control.FOCUS_NONE and tag.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Observation labels are passive")
		check(panel._observation_labels[i].get_theme_font_size("font_size") >= 16, "Observation label stays readable")
		check(tag.global_position.y >= panel._photo_frame.get_global_rect().end.y, "Labels do not cover photo")
	print("PPC-EXT-01 layout ", dimensions, ": panel=", panel.size, " photo_share=", share, " reading_area=", panel._scroll.size)


func capture(suffix: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("ppc_ext_01_" + suffix + ".png")) == OK, "Rendered capture saved")


func _initialize() -> void:
	run.call_deferred()


func run() -> void:
	create_timer(100.0).timeout.connect(func(): push_error("PPC-EXT-01 test timeout"); quit(1))
	root.content_scale_size = Vector2i(1280, 720)
	var preview = load("res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("HotspotFrame/CapitolInteraction")
	var trigger: Button = preview.get_node("Margin/Layout/OpenHotspot")
	panel.narration_started.connect(func(): starts += 1)
	panel.closed.connect(func(): closes += 1)
	check(root.content_scale_size == Vector2i.ZERO, "Standalone preview uses real viewport sizes")
	check(panel._open, "F6 opens real production component")
	check(panel.content.hotspot_id == "ppc_ext_01", "Internal ID")
	check(panel.content.narration_transcript == TRANSCRIPT, "Exact approved narration transcript")
	check(is_equal_approx(panel.TRANSITION_SECONDS, 0.2), "200 ms fade")
	check(panel.find_children("*", "BaseButton", true, false).size() == 9, "Only intended controls; no architectural-detail buttons")
	check(panel.find_children("ViewLarger", "Button", true, false).is_empty(), "Former ViewLarger node removed")
	check(panel.find_children("*", "Button", true, false).all(func(button): return button.text != "VIEW LARGER"), "No VIEW LARGER button exists")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		root.set_content_scale_size(Vector2i.ZERO)
		await settle()
		panel.open_hotspot()
		await settle()
		assert_state(panel, 0)
		check(not panel._audio.playing and panel._audio.get_playback_position() == 0, "No autoplay; audio starts at zero")
		check(panel._audio.stream.resource_path == "res://assets/landmarks/pangasinan_provincial_capitol/audio/ppc_ext_01_narration.ogg", "Correct imported OGG")
		check(panel._audio.stream.get_length() > 0 and panel._speaker.visible and not panel._speaker.disabled, "Narration loaded and available")
		check(panel._speaker.icon == load("res://assets/ui/icons/speaker.svg"), "Existing shared speaker icon")
		for index in [0, 2, 1, 0]:
			await pointer(panel._concepts[index], index % 2 == 0)
			await finish(panel)
			assert_state(panel, index)
			assert_layout(panel, dimensions)
			await capture("%s_%s" % [dimensions.x, IDS[index]])
			panel._scroll.scroll_vertical = 999
			await settle()
			check(panel._scroll.get_global_rect().encloses(panel._takeaway.get_global_rect()), "Complete takeaway is reachable through local reading scroll")
			panel._scroll.scroll_vertical = 0
			check(not panel._previous_image.visible and panel._transition == null, "Settled photo has no stale layer")
			await pointer(panel._photo_button, dimensions.x == 960)
			await finish(panel)
			check(panel.is_explore_open() and root.gui_get_focus_owner() == panel._explore_close, "Image activation opens Explore with close focus")
			check(panel._explore_image.texture == panel._image.texture and panel._explore_caption.text == CAPTIONS[index], "Enlarged photo matches current view")
			check(panel._explore_image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Explore preserves documentary aspect")
			check(panel.get_global_rect().encloses(panel._explore.get_global_rect()) and panel._explore.get_global_rect().encloses(panel._explore_image.get_global_rect()), "Explore fits hotspot")
			check(panel._explore_image.size.y > panel._image.size.y, "Explore supplies a larger image area")
			var texture_size: Vector2 = panel._image.texture.get_size()
			var normal_scale: float = minf(panel._image.size.x / texture_size.x, panel._image.size.y / texture_size.y)
			var large_scale: float = minf(panel._explore_image.size.x / texture_size.x, panel._explore_image.size.y / texture_size.y)
			check(large_scale >= normal_scale * 1.25, "Actual aspect-fit photograph is enlarged")
			check(panel._explore_close.size.y >= 56, "Touch-sized Close View")
			await capture("%s_%s_explore" % [dimensions.x, IDS[index]])
			for shift in [false, true]:
				await key(KEY_TAB, shift)
				check(root.gui_get_focus_owner() == panel._explore_close, "Explore traps keyboard focus")
			await pointer(panel._concepts[(index + 1) % 3], true)
			panel.select_view(IDS[(index + 1) % 3])
			panel.open_sources()
			check(not panel._sources.visible and panel.current_view == IDS[index], "Explore blocks selectors and conflicting Sources")
			if index == 1:
				await key(KEY_ESCAPE)
			else:
				await pointer(panel._explore_close, index == 2)
			await finish(panel)
			check(panel._open and not panel.is_explore_open() and root.gui_get_focus_owner() == panel._photo_button, "Close View/Escape returns focus to image")
			for activation in [KEY_ENTER, KEY_SPACE]:
				await key(activation)
				await finish(panel)
				check(panel.is_explore_open() and panel._explore_image.texture == panel._image.texture, "Enter/Space on image opens the selected photograph")
				await key(KEY_ESCAPE)
				await finish(panel)
				check(panel._open and not panel.is_explore_open() and root.gui_get_focus_owner() == panel._photo_button, "Escape restores image focus after keyboard activation")
			assert_state(panel, index)
		await pointer(panel._concepts[0], true)
		assert_state(panel, 0)
		panel._concepts[0].grab_focus()
		await key(KEY_LEFT)
		assert_state(panel, 0)
		await key(KEY_RIGHT)
		assert_state(panel, 1)
		await key(KEY_RIGHT)
		await key(KEY_RIGHT)
		assert_state(panel, 2)
		panel._concepts[0].grab_focus()
		await key(KEY_ENTER)
		assert_state(panel, 0)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._concepts[1], "Tab to civic setting")
		await key(KEY_SPACE)
		assert_state(panel, 1)
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._concepts[0], "Shift+Tab reverses order")
		for target in [panel._concepts[1], panel._concepts[2], panel._photo_button, panel._sources_button, panel._speaker, panel._close, panel._scroll, panel._concepts[0]]:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == target, "Complete focus cycle")
		await pointer(panel._speaker, true)
		check(panel._audio.playing, "Touch LISTEN starts narration")
		var initial_starts := starts
		panel._audio.seek(3.0)
		for index in [2, 0, 1]:
			await pointer(panel._concepts[index], index == 0)
		check(panel._audio.playing and panel._audio.get_playback_position() >= 2.9 and starts == initial_starts, "View switching neither stops nor restarts narration")
		var saved_scroll: int = panel._scroll.scroll_vertical
		panel._photo_button.grab_focus()
		await key(KEY_SPACE)
		check(panel.is_explore_open(), "Space opens Explore")
		await finish(panel)
		panel.toggle_narration()
		check(panel._audio.playing and starts == initial_starts and panel._audio.get_playback_position() >= 2.9, "Explore preserves audio and blocks underlying audio control")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(panel._audio.playing and starts == initial_starts and panel._audio.get_playback_position() >= 2.9, "Closing Explore does not restart narration")
		check(panel._scroll.scroll_vertical == saved_scroll, "Explore preserves reading position")
		await pointer(panel._sources_button, true)
		check(panel._sources.visible and panel._audio.playing, "Sources preserves narration")
		check(panel._source_close.size.y >= 56 and panel.get_global_rect().encloses(panel._source_close.get_global_rect()), "Visible Sources close target fits")
		assert_state(panel, 1)
		check(panel._source_text.text.contains("HISTORICAL REFERENCES") and panel._source_text.text.contains("DOCUMENTARY MEDIA") and panel._source_text.text.contains("AUDIO"), "Source sections")
		check(panel._source_text.text.contains("Not separately confirmed / pending documentation."), "Civic-setting permission qualified")
		check(panel._source_text.text.contains("The Province → History"), "Official photo source identified")
		panel.open_explore_view()
		check(not panel.is_explore_open(), "Sources prevents conflicting Explore overlay")
		await capture("%s_sources" % dimensions.x)
		for i in 4:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() in [panel._source_close, panel._source_scroll], "Sources traps focus")
		await pointer(panel._concepts[2], true)
		panel.select_view(&"government_today")
		panel.toggle_narration()
		assert_state(panel, 1)
		check(panel._audio.playing, "Sources blocks background audio control")
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel._open and root.gui_get_focus_owner() == panel._sources_button, "Escape closes Sources first")
		check(starts == initial_starts and panel._audio.get_playback_position() >= 2.9, "Sources preserves audio position")
		await key(KEY_RIGHT)
		assert_state(panel, 1)
		for index in 30:
			panel.select_view(IDS[index % 3])
			var old_tween: Tween = panel._transition
			if old_tween != null:
				old_tween.pause()
				old_tween.custom_step(0.07)
			panel.select_view(IDS[(index + 1) % 3])
			if old_tween != null:
				check(not old_tween.is_valid(), "Superseded tween killed")
		panel.select_view(&"capitol")
		await finish(panel)
		assert_state(panel, 0)
		check(panel._transition == null and not panel._previous_image.visible, "Latest input wins after interrupted fades")
		panel.select_view(&"invalid")
		assert_state(panel, 0)
		panel.select_view(&"government_today")
		for attempt in 12:
			panel.open_explore_view()
			panel.open_explore_view()
			var opening: Tween = panel._explore_tween
			opening.pause()
			opening.custom_step(0.05)
			panel.close_explore_view()
			check(not opening.is_valid(), "Closing cancels incomplete open fade")
			panel.open_explore_view()
			panel.select_view(&"capitol")
			check(panel.current_view == &"government_today", "Closing fade still blocks background state changes")
			await finish(panel)
			check(not panel.is_explore_open() and panel._explore_image.texture == null and panel._explore_tween == null, "Rapid open/close clears transient state")
		check(panel.find_children("ExploreView", "PanelContainer", false, false).size() == 1, "Single reusable Explore overlay")
		panel._scroll.scroll_vertical = 999
		await settle()
		if dimensions.x == 854:
			check(panel._scroll.scroll_vertical > 0, "Compact interpretation scrolls locally")
		await key(KEY_ESCAPE)
		await settle()
		check(not panel._open and not panel.visible and not panel._audio.playing and panel._audio.get_playback_position() == 0, "Escape closes and stops audio")
		assert_state(panel, 0)
		check(panel._scroll.scroll_vertical == 0 and not panel._sources.visible and not panel.is_explore_open() and panel._transition == null, "Close immediately resets all local state")
		check(root.gui_get_focus_owner() == trigger, "Close returns launcher focus")
		await pointer(trigger, true)
		assert_state(panel, 0)
		check(panel._open and not panel._audio.playing and root.gui_get_focus_owner() == panel._concepts[0], "Reopen is a fresh launch")
		panel.toggle_narration()
		panel.select_view(&"government_today")
		panel.open_sources()
		panel.reset_hotspot()
		assert_state(panel, 0)
		check(not panel._sources.visible and not panel._audio.playing and panel._transition == null, "Explicit reset clears overlay and audio")
		await pointer(panel._close, true)
		check(not panel._open, "Touch CLOSE")
	check(closes == 6, "One close signal per close")
	panel.open_hotspot()
	panel.select_view(&"civic_setting")
	panel.toggle_narration()
	panel.open_explore_view()
	var cancelled_open: Tween = panel._explore_tween
	panel.close_hotspot()
	panel.open_hotspot()
	await finish(panel)
	check(not cancelled_open.is_valid() and not panel.is_explore_open() and not panel._audio.playing, "Host close during Explore open resets without stale callback")
	assert_state(panel, 0)
	panel.open_explore_view()
	panel.close_explore_view()
	var cancelled_close: Tween = panel._explore_tween
	panel.reset_hotspot()
	await finish(panel)
	check(not cancelled_close.is_valid() and not panel.is_explore_open() and root.gui_get_focus_owner() == panel._concepts[0], "Reset during closing fade clears Explore and stale focus")
	panel.open_hotspot()
	panel.toggle_narration()
	panel.select_view(&"civic_setting")
	panel.open_explore_view()
	preview.hide()
	check(not panel._open and not panel._audio.playing and panel._transition == null and not panel.is_explore_open() and panel._explore_tween == null, "Host hide stops all activity")
	preview.show()
	panel.open_hotspot()
	assert_state(panel, 0)
	panel.close_hotspot()
	var narration: AudioStream = panel.content.narration_stream
	panel.content.narration_stream = null
	panel.open_hotspot()
	check(panel._speaker.visible and panel._speaker.disabled and panel._pending.visible and panel._pending.text == "Narration pending.", "Unavailable narration fallback")
	panel.content.narration_stream = narration
	var visitor_copy: String = panel.content.title + panel.content.prompt + TRANSCRIPT
	for entry in panel.content.concepts:
		visitor_copy += entry.heading + entry.body + entry.takeaway + entry.caption + entry.context_label + entry.selector_label
		visitor_copy += " ".join(entry.observation_labels)
	for excluded in ["1917", "1918", "1919", "1911", "25-hectare", "Maramba", "Doane", "Ionic", "Neoclassical", "World War", "Braganza", "2008", "Cultural Treasure", "2018", "Gallery", "Governor's Office", "Session Hall", "score", "points", " XP ", "reward", "badge", "achievement", "level", "collectible", "quest", "unlock", "prerequisite", "ranking", "combat", "puzzle", "account"]:
		check(not visitor_copy.to_lower().contains(excluded.to_lower()), "Excluded visitor claim/feature: " + excluded)
	preview.queue_free()
	await settle()
	# Audio mixing releases stopped OGG playback asynchronously in headless runs.
	# Frame-only waits can finish before the mixer has processed teardown.
	await create_timer(0.2).timeout
	check(root.content_scale_size == Vector2i(1280, 720), "Preview restores host canvas policy")
	print("PPC-EXT-01: ", checks, " checks; failures: ", failures)
	quit(1 if failures else 0)
