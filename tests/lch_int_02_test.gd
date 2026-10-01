extends SceneTree
## Native GUI input and deterministic animation/geometry assertions in the real preview.
var checks: int = 0
var failures: int = 0
const NAMES := ["GUIDO DE LAVEZARIS", "JUAN DE SALCEDO", "LIMAHONG / LIN FENG"]
const ROLES := ["EXPEDITION PREPARATION", "EXPEDITION LEADER", "SETTLEMENT & ESCAPE"]
const BODIES := [
	"Governor-General Guido de Lavezaris appointed Juan de Salcedo as master-of-camp and oversaw preparations for the expedition against Limahong.",
	"Juan de Salcedo led the Spanish and allied Luzonese expedition that blockaded Limahong's settlement in 1575.",
	"Limahong, also known as Lin Feng, was a Chinese pirate leader. After his failed attacks on Manila in late 1574, he sailed to Pangasinan and established a fortified settlement."
]
const CONNECTIONS := [
	"His role was connected to organizing and preparing the expedition rather than leading it in the field.",
	"He led the expedition in the field during the 1575 Pangasinan campaign.",
	"His settlement and escape in Pangasinan form the central historical narrative associated with the Limahong Channel."
]

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 5:
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

func click(control: Control) -> void:
	var event := InputEventMouseButton.new()
	event.position = control.get_global_rect().get_center()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func touch(control: Control) -> void:
	var event := InputEventScreenTouch.new()
	event.position = control.get_global_rect().get_center()
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func finish(panel) -> void:
	if panel._selection_tween != null and panel._selection_tween.is_valid():
		var tween: Tween = panel._selection_tween
		tween.pause()
		tween.custom_step(0.4)
	await settle()

func assert_state(panel, person: int) -> void:
	check(panel.current_person == person and panel._selected == person, "One authoritative person state")
	check(panel._heading.text == NAMES[person] and panel._role.text == ROLES[person], "Name and role match selected person")
	check(panel._body.text == BODIES[person] and panel._connection_body.text == CONNECTIONS[person], "Exact approved main and connection wording")
	check(panel._connection_heading.text == "CONNECTION TO THE 1575 CAMPAIGN", "Exact connection heading")
	check(panel._audio.stream == panel._person(person).narration_audio, "Narration targets the same person")
	check(panel._event.visible and panel._event_title.text == "1575 PANGASINAN CAMPAIGN", "Permanent central event")
	check(panel._event_subtitle.text == "Different historical roles were connected to the same campaign.", "Event explains common campaign")
	for i in 3:
		check(panel._concepts[i].visible and panel._concepts[i].is_visible_in_tree(), "All three people stay visible")
		check(panel._concepts[i].button_pressed == (i == person), "Exactly one selected card")
		check(panel._selected_badges[i].visible == (i == person), "Text badge makes selection independent of color")
		check(panel._lines[i].width == (3.5 if i == person else 2.0), "Exactly one thicker line")
		check(panel._lines[i].default_color == (panel.GOLD if i == person else panel.INACTIVE_LINE), "Exactly one highlighted line")
		check(panel._concepts[i].scale.is_equal_approx(Vector2.ONE) and panel._concepts[i].modulate.a == 1.0, "No residual scaling or opacity")
	check(panel._selection_tween == null, "Selection animation finished and cleared")

func assert_layout(panel, dimensions: Vector2i) -> void:
	check(panel.size.is_equal_approx(Vector2(dimensions) * 0.9), "Embedded parent-sized component")
	check(panel._information.find_children("*", "Button", true, false).is_empty(), "Information panel has no redundant or replacement selection buttons")
	check(is_equal_approx(panel._scroll.get_global_rect().end.y, panel._information.get_global_rect().end.y), "Information scroll uses freed space to the panel bottom without a selector gap")
	var bounds := Rect2(Vector2.ZERO, panel._diagram.size)
	check(bounds.grow(0.1).encloses(panel._event.get_rect()), "Campaign event within diagram")
	check(panel._event.mouse_filter == Control.MOUSE_FILTER_IGNORE and panel._event.focus_mode == Control.FOCUS_NONE, "Campaign event is not an input control")
	var event_bounds: Rect2 = panel._event.get_global_rect()
	check(event_bounds.encloses(panel._event_title.get_global_rect()) and event_bounds.encloses(panel._event_subtitle.get_global_rect()), "Full event wording stays inside event panel")
	check(not panel._event_title.get_global_rect().intersects(panel._event_subtitle.get_global_rect()), "Event title and subtitle never overlap")
	for i in 3:
		var card: Button = panel._concepts[i]
		var portrait: TextureRect = panel._portraits[i]
		check(bounds.grow(0.1).encloses(card.get_rect()), "Person card within diagram")
		check(not card.get_rect().intersects(panel._event.get_rect()), "Person card does not overlap event")
		for j in range(i + 1, 3):
			check(not card.get_rect().intersects(panel._concepts[j].get_rect()), "People do not overlap")
		check(card.size.x >= 120 and card.size.y >= 150, "Whole card remains a large touch target")
		check(is_equal_approx(portrait.size.x / portrait.size.y, 0.8), "4:5 portrait frame")
		check(portrait.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED and portrait.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR, "Aspect-preserving photographic cover filtering")
		check(Rect2(Vector2.ZERO, card.size).encloses(panel._names[i].get_rect()) and Rect2(Vector2.ZERO, card.size).encloses(panel._roles[i].get_rect()), "Full name and role fit the card")
		check(not panel._names[i].get_rect().intersects(panel._roles[i].get_rect()), "Person name and role never overlap")
		var points: PackedVector2Array = panel._lines[i].points
		check(points.size() == 2, "One independent person-to-event line")
		check(card.get_rect().grow(0.1).has_point(points[0]) and panel._event.get_rect().grow(0.1).has_point(points[1]), "Line reaches its own card and campaign node")
		check(points[0].distance_to(points[1]) >= 4.0, "Connection has a visible span")
		for t in [0.15, 0.5, 0.85]:
			var point := points[0].lerp(points[1], t)
			for j in 3:
				if i != j:
					check(not panel._concepts[j].get_rect().has_point(point), "Line never passes through another person")
		check(card.focus_mode == Control.FOCUS_ALL, "Each portrait card remains keyboard-focusable")
	for control in [panel._close, panel._speaker, panel._sources_button, panel._scroll]:
		check(panel.get_global_rect().grow(0.1).encloses(control.get_global_rect()), "Header/text controls stay within parent")
	if dimensions.x == 1280:
		var ratio: float = panel._diagram.size.x / (panel._diagram.size.x + panel._information.size.x)
		check(ratio >= 0.62 and ratio <= 0.65, "Wide diagram/info ratio")
	if dimensions.x >= 960:
		check(panel._concepts[0].position.y < panel._event.position.y and panel._concepts[1].position.y > panel._concepts[0].position.y, "Triangular relationship structure")
	else:
		check(panel._concepts[0].position.y == panel._concepts[1].position.y and panel._concepts[1].position.y == panel._concepts[2].position.y, "Compact people share one horizontal row")
		check(panel._event.position.y > panel._concepts[0].get_rect().end.y, "Compact event sits below all people")

func capture(tag: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lch-int-02-" + tag + ".png"))

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	create_timer(90.0).timeout.connect(func(): push_error("INT-02 test timeout"); quit(1))
	root.content_scale_size = Vector2i.ZERO
	var preview = load("res://scenes/landmarks/limahong_channel/interior/lch_int_02_preview.tscn").instantiate()
	root.add_child(preview)
	await settle()
	var panel = preview.get_node("HotspotFrame/CampaignPeopleInteraction")
	# Keep the existing missing-narration regression scenario; assigned audio is covered by lch_header_test.
	panel.content = panel.content.duplicate(true)
	panel.content.narration_stream = null
	var trigger = preview.get_node("Margin/Layout/OpenArtwork")
	var close_events: Array[int] = [0]
	panel.close_requested.connect(func(): close_events[0] += 1)
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		trigger.grab_focus()
		check(panel.open_interaction(), "Real component opens")
		await settle()
		assert_state(panel, 1)
		assert_layout(panel, dimensions)
		check(panel._concepts.size() == 3 and panel._lines.size() == 3 and panel._diagram.find_children("*", "Button", true, false).size() == 3, "Exactly three person controls and independent relationships")
		check(panel._speaker.visible and panel._speaker.disabled and panel._speaker.text == "LISTEN" and panel._pending.visible, "Visible disabled pending LISTEN")
		check(panel._speaker.icon.resource_path == "res://assets/ui/icons/speaker.svg", "Exact shared speaker icon")
		check(not panel._audio.playing and not panel._sources.visible and panel._hint.modulate.a == 1.0, "Default audio/Sources/hint state")
		for i in 3:
			check(panel._portraits[i].texture == panel._person(i).portrait and panel._portraits[i].texture.get_size() == Vector2(1122, 1402), "Supplied final-size image used unchanged")
			check(not panel._placeholders[i].visible and not panel._media_labels[i].visible, "No fallback or invented media type for supplied portraits")
		await capture("%dx%d-default" % [dimensions.x, dimensions.y])
		await click(panel._event)
		assert_state(panel, 1)
		for i in [0, 2, 1]:
			await click(panel._concepts[i])
			await finish(panel)
			assert_state(panel, i)
		for i in [2, 0, 1]:
			await touch(panel._concepts[i])
			await finish(panel)
			assert_state(panel, i)
		for i in [0, 1, 2]:
			# Tap the role below the image to prove the entire card accepts touch.
			check(not panel._portraits[i].get_global_rect().has_point(panel._roles[i].get_global_rect().get_center()), "Whole-card touch point lies outside the portrait")
			await touch(panel._roles[i])
			await finish(panel)
			assert_state(panel, i)
			await capture("%dx%d-person%d" % [dimensions.x, dimensions.y, i])
		for i in [1, 0, 2]:
			await click(panel._names[i])
			await finish(panel)
			assert_state(panel, i)
		# Reselecting the current card must not toggle off the authoritative choice.
		await click(panel._concepts[2])
		assert_state(panel, 2)
		await touch(panel._roles[2])
		assert_state(panel, 2)
		# Portrait cards provide exactly one keyboard focus stop per person.
		panel._concepts[0].grab_focus()
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._concepts[1], "Tab advances to Salcedo")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._concepts[2], "Tab advances to Limahong")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._scroll, "Tab leaves the three portrait controls for information scroll")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._concepts[2], "Shift+Tab reverses traversal")
		await key(KEY_RIGHT)
		await finish(panel)
		assert_state(panel, 2)
		check(root.gui_get_focus_owner() == panel._concepts[2], "Right endpoint never wraps")
		await key(KEY_LEFT)
		await finish(panel)
		assert_state(panel, 1)
		await key(KEY_LEFT)
		await key(KEY_LEFT)
		await finish(panel)
		assert_state(panel, 0)
		check(root.gui_get_focus_owner() == panel._concepts[0], "Left endpoint never wraps")
		panel._concepts[2].grab_focus()
		await key(KEY_ENTER)
		await finish(panel)
		assert_state(panel, 2)
		panel._concepts[1].grab_focus()
		await key(KEY_SPACE)
		await finish(panel)
		assert_state(panel, 1)
		check(panel._concepts[1].has_theme_stylebox("focus", "Button"), "Visible inherited focus style")
		# Check transient timings without relying on wall-clock frame counts.
		panel.select_person(0)
		var tween: Tween = panel._selection_tween
		tween.pause()
		check(is_equal_approx(panel._concepts[0].scale.x, 0.97) and is_equal_approx(panel._concepts[0].modulate.a, 0.85), "Restrained card animation start")
		tween.custom_step(0.21)
		check(panel._concepts[0].scale.is_equal_approx(Vector2.ONE) and panel._concepts[0].modulate.a == 1.0, "Card settles after 200ms")
		check(panel._lines[0].width < 3.5 and panel._lines[0].width > 2.0, "Line emphasis continues toward 300ms")
		await finish(panel)
		assert_state(panel, 0)
		for sequence in [[1, 2, 0, 1, 2], [0, 2, 1]]:
			for person in sequence:
				panel.select_person(person)
				if panel._selection_tween != null:
					panel._selection_tween.pause()
					panel._selection_tween.custom_step(0.045)
			await finish(panel)
			assert_state(panel, sequence[-1])
		panel.select_person(2)
		panel.open_sources() # Also safely resolves an in-flight emphasis.
		check(panel._sources.visible, "Sources opens")
		check(panel._source_text.text.contains("Lingayen in Time, p. 5.") and panel._source_text.text.contains("Kahimyang.") and panel._source_text.text.contains("Jardin Solei / The Crafty Historian."), "Sources includes all three supplied portrait provenances")
		check(panel._source_text.text.contains("traditionally associated"), "Historical qualification retained")
		panel.select_person(0)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() in [panel._source_scroll, panel._source_close], "Sources traps focus")
		assert_state(panel, 2)
		await key(KEY_ESCAPE)
		check(panel._open and not panel._sources.visible, "Escape closes Sources first")
		assert_state(panel, 2)
		await click(panel._sources_button)
		check(panel._sources.visible, "Mouse opens shared Sources")
		await click(panel._source_close)
		assert_state(panel, 2)
		await touch(panel._sources_button)
		check(panel._sources.visible, "Touch opens shared Sources")
		await touch(panel._source_close)
		check(not panel._sources.visible, "Touch closes shared Sources")
		assert_state(panel, 2)
		panel._scroll.scroll_vertical = 10000
		await settle()
		check(panel._connection_body.get_global_rect().end.y <= panel._scroll.get_global_rect().end.y + 1.0, "Full connection text reachable inside info scroll")
		panel.select_person(0)
		await key(KEY_ESCAPE)
		check(not panel._open and panel._selection_tween == null and panel._hint_tween == null and not panel._audio.playing, "Close cancels all transient work")
		await settle()
		check(root.gui_get_focus_owner() == trigger, "Opener focus restored")
		await click(trigger)
		await settle()
		assert_state(panel, 1)
		check(not panel._hint_dismissed and panel._hint.modulate.a == 1.0 and not panel._sources.visible, "Reopen restores initial hint and Sources state")
		await touch(panel._close)
		check(not panel._open, "Touch closes the hotspot")
		await settle()
		print("INT-02 viewport ", dimensions, " verified")
	# Missing portrait and optional metadata behavior use cloned resources only.
	panel.content = panel.content.duplicate(true)
	for i in 3:
		panel._person(i).portrait = null
	panel.open_interaction()
	await settle()
	for i in 3:
		check(panel._placeholders[i].visible and panel._placeholders[i].text == "IMAGE SOURCE\nPENDING", "Clearly labeled missing portrait")
		await touch(panel._concepts[i])
		await finish(panel)
		assert_state(panel, i)
	await capture("854x480-fallback")
	panel._person(2).portrait_media_type = "TEST MEDIA TYPE"
	panel._person(2).portrait_credit = "Test credit"
	panel._person(2).portrait_source = "Test source"
	panel._person(2).portrait_permission_status = "Test permission"
	panel.open_sources()
	check(panel._source_text.text.contains("TEST MEDIA TYPE") and panel._source_text.text.contains("Test credit") and panel._source_text.text.contains("Test source") and panel._source_text.text.contains("Test permission"), "Supplied image metadata appears in Sources")
	panel.close_interaction()
	# Synthetic silence validates independent optional audio targets without adding media.
	for i in 2:
		var audio := AudioStreamWAV.new()
		audio.format = AudioStreamWAV.FORMAT_8_BITS
		audio.mix_rate = 8000
		var silence := PackedByteArray()
		silence.resize(80000)
		audio.data = silence
		panel._person(i).narration_audio = audio
	panel.open_interaction()
	await settle()
	check(not panel._audio.playing and not panel._speaker.disabled, "Default person audio assigned but never autoplays")
	await click(panel._speaker)
	check(panel._audio.playing, "Explicit Listen starts current person audio")
	await create_timer(0.15).timeout
	var playback: float = panel._audio.get_playback_position()
	panel.open_sources()
	panel.close_sources()
	panel.select_person(1)
	check(panel._audio.playing and panel._audio.get_playback_position() >= playback, "Sources and same-person reselect preserve narration")
	panel.select_person(0)
	check(not panel._audio.playing and panel._audio.stream == panel._person(0).narration_audio, "Changing person stops prior audio and switches target without autoplay")
	await touch(panel._speaker)
	check(panel._audio.playing, "Touch starts second person's audio")
	panel.select_person(2)
	check(not panel._audio.playing and panel._audio.stream == null and panel._speaker.disabled, "Missing person audio stops prior stream and disables Listen")
	panel.select_person(1, false)
	await click(panel._speaker)
	await click(panel._close)
	check(not panel._audio.playing, "Close stops narration")
	check(close_events[0] == 8, "Close requests emitted once per close")
	preview.queue_free()
	await settle()
	print("LCH-INT-02: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)
