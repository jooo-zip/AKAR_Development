extends SceneTree
## Real embedded summary, optional NONE state, historical safety and native inputs.
const TITLES := ["RETREAT TO PANGASINAN", "THE 1575 BLOCKADE", "ESCAPE BY CHANNEL", "HISTORICAL TRADITION", "MODERN HERITAGE VALUE"]
const SHORT := [
	"Limahong sailed to Pangasinan and established a fortified settlement.",
	"Juan de Salcedo led the expedition that blockaded Limahong's settlement.",
	"Limahong's group escaped through a channel reportedly dug toward the sea.",
	"The present channel is traditionally associated with the 1575 escape route.",
	"The channel continues to support local historical memory, heritage education, and tourism."
]
const DETAILS := [
	"After his failed attacks on Manila in late 1574, Limahong sailed to Pangasinan and established a fortified settlement.",
	"Juan de Salcedo led the expedition against Limahong's fortified settlement in Pangasinan. Spanish and allied Luzonese forces blockaded the settlement in 1575.",
	"During the 1575 blockade, Limahong's group escaped through a channel that official provincial history states they had dug toward the China Sea.",
	"The present-day Limahong Channel is traditionally associated with the 1575 escape route. Its exact identification has not been independently established through archaeological evidence.",
	"The Limahong Channel preserves local memory of the 1575 Pangasinan campaign and supports heritage education and tourism initiatives in Lingayen."
]
const INTRO := "The Limahong Channel is a historical waterway in Pangapisan Norte, Lingayen, traditionally associated with Limahong's escape during the 1575 Pangasinan campaign."
const BRIEF := "The Limahong Channel connects the memory of the 1575 Pangasinan campaign with Lingayen's continuing heritage."
const REFLECTION := "Why has the Limahong Channel remained historically significant to Lingayen?"
const TAKEAWAY := "The Limahong Channel is remembered because of its traditional association with Limahong's 1575 escape from the Pangasinan blockade. That historical memory continues to contribute to Lingayen's local heritage, education, and tourism initiatives."
var checks: int = 0
var failures: int = 0
var reported_topics: Array[int] = []
var close_requests: int = 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 6: await process_frame

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

func activate(control: Control, touch: bool = false, corner: bool = false) -> void:
	var point := control.get_global_rect().position + Vector2(3, 3) if corner else control.get_global_rect().get_center()
	var event: InputEvent
	if touch:
		event = InputEventScreenTouch.new()
	else:
		event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func finish(panel) -> void:
	for tween in [panel._entrance, panel._selection, panel._fade]:
		if tween != null and tween.is_valid():
			tween.pause()
			tween.custom_step(1.0)
	await settle()

func state(panel, topic: int) -> void:
	check(panel.current_topic == topic and panel._selected == topic, "Authoritative optional topic state")
	check(panel._heading.text == ("THE STORY IN BRIEF" if topic == -1 else TITLES[topic]), "Correct full detail heading including NONE")
	check(panel._body.text == (BRIEF if topic == -1 else DETAILS[topic]), "Exact detail wording including historical qualification")
	check(panel._concepts.size() == 5, "Exactly five topic cards")
	for i in 5:
		check(panel._concepts[i].visible and not panel._concepts[i].disabled, "All cards remain available")
		check(panel._concepts[i].button_pressed == (i == topic), "Zero or one selected card")
		check(panel._emphasis[i] == (1.0 if i == topic else 0.0), "Storyline emphasis matches topic / neutral NONE")
		check(panel._concepts[i].modulate == Color.WHITE and panel._concepts[i].scale == Vector2.ONE, "No dimming, stale opacity or scale")
		check(panel._card_bodies[i].text == SHORT[i] and panel._card_numbers[i].text == "%02d" % (i + 1), "Card synopsis and chronological numbering")
		check(panel._concepts[i].find_children("*", "BaseButton", true, false).is_empty(), "One interaction / focus stop per card")
	check(panel._reflection_body.text == REFLECTION and panel._reflection_body.is_visible_in_tree(), "Reflection always visible")
	check(panel._takeaway.text == TAKEAWAY and panel._takeaway.is_visible_in_tree(), "Takeaway immediately visible without requirements")
	check(panel._card_qualifiers[3].text == "TRADITIONAL ASSOCIATION" and panel._card_qualifiers[3].is_visible_in_tree(), "Persistent traditional-association qualifier")
	check(panel._fade == null and panel._entrance == null and panel._selection == null, "No stale Tween callbacks")

func layout(panel, dimensions: Vector2i) -> void:
	var bounds: Rect2 = panel.get_global_rect().grow(1)
	check(panel.size.is_equal_approx(Vector2(dimensions) * 0.9), "Real embedded 90 percent parent")
	for control in [panel._title, panel._speaker, panel._sources_button, panel._close, panel._intro_heading, panel._intro_body, panel._board, panel._information, panel._reflection_heading, panel._reflection_body, panel._takeaway_heading, panel._takeaway]:
		check(bounds.encloses(control.get_global_rect()), "Layout stays in component: " + control.name + " " + str(control.get_global_rect()) + " bounds=" + str(bounds))
	check(not panel._title.get_global_rect().intersects(panel._speaker.get_global_rect()), "No header collision")
	check(panel._intro_body.text == INTRO and panel._intro_heading.text == "AT A GLANCE", "Standalone introduction visible")
	for i in 5:
		var card: Button = panel._concepts[i]
		var card_bounds := card.get_global_rect().grow(0.5)
		check(card.size.y >= 56 and bounds.encloses(card_bounds), "Whole card is a generous touch target")
		for control in [panel._card_titles[i], panel._card_bodies[i], panel._card_numbers[i], panel._symbols[i], panel._card_qualifiers[i]]:
			if control.is_visible_in_tree(): check(card_bounds.encloses(control.get_global_rect()), "Card text/symbol fits without clipping: " + str(i) + " " + control.text if control is Label else "Symbol fits")
		check(card.focus_mode == Control.FOCUS_ALL and card.get_theme_stylebox("focus") != card.get_theme_stylebox("pressed"), "Distinct keyboard focus and selection")
		for j in range(i + 1, 5): check(not card.get_global_rect().intersects(panel._concepts[j].get_global_rect()), "Cards never overlap")
	if dimensions.x == 854:
		check(panel._compact and panel._concepts[0].position.y == panel._concepts[2].position.y and panel._concepts[3].position.y > panel._concepts[0].position.y and panel._concepts[3].position.y == panel._concepts[4].position.y, "Compact 3+2 chronological arrangement")
	else:
		check(not panel._compact and panel._concepts[0].position.y == panel._concepts[4].position.y, "Five cards in horizontal storyline")
	if panel.current_topic == 3:
		check(panel._scroll.get_global_rect().grow(1).encloses(panel._body.get_global_rect()), "Entire archaeological qualification visible in Tradition detail")

func capture(tag: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lch-end-01-" + tag + ".png"))

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	create_timer(100).timeout.connect(func(): push_error("END-01 test timeout"); quit(1))
	root.content_scale_size = Vector2i.ZERO
	var preview = load("res://scenes/landmarks/limahong_channel/summary/lch_end_01_preview.tscn").instantiate()
	root.add_child(preview)
	await settle()
	var panel = preview.get_node("HotspotFrame/HeritageSummaryInteraction")
	# Keep the existing missing-narration regression scenario; assigned audio is covered by lch_header_test.
	panel.content = panel.content.duplicate(true)
	panel.content.narration_stream = null
	var trigger = preview.get_node("Margin/Layout/OpenArtwork")
	panel.topic_changed.connect(func(topic: int): reported_topics.append(topic))
	panel.close_requested.connect(func(): close_requests += 1)
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		trigger.grab_focus()
		check(panel.open_interaction(), "Summary opens without any previous hotspot")
		panel._entrance.pause()
		panel._entrance.custom_step(0.2)
		check(is_equal_approx(panel._board.modulate.a, 0.5), "All cards share the midpoint of a 400ms entrance")
		panel._entrance.custom_step(0.21)
		check(panel._entrance == null and panel._board.modulate.a == 1.0, "Entrance finishes within 400ms without sequential delays")
		await finish(panel)
		state(panel, -1)
		layout(panel, dimensions)
		check(root.gui_get_focus_owner() == panel._sources_button, "Default focus leaves every card visually neutral")
		check(panel._title.text == "WHAT THE LIMAHONG CHANNEL REPRESENTS", "Visitor title")
		check(not panel._sources.visible and not panel._audio.playing, "Default Sources closed and no autoplay")
		check(panel._speaker.visible and panel._speaker.disabled and panel._pending.visible and panel._speaker.icon.resource_path == "res://assets/ui/icons/speaker.svg", "Shared visible disabled LISTEN / pending")
		await capture("%dx%d-none" % [dimensions.x, dimensions.y])
		for i in 5:
			await activate(panel._concepts[i])
			await finish(panel)
			state(panel, i)
			layout(panel, dimensions)
			if i == 3: await capture("%dx%d-tradition" % [dimensions.x, dimensions.y])
			await activate(panel._concepts[i])
			await finish(panel)
			state(panel, -1)
			check(reported_topics[-1] == -1, "Parent topic signal includes NONE")
		for i in 5:
			await activate(panel._concepts[i], true, true)
			await finish(panel)
			state(panel, i)
			await activate(panel._concepts[i], true)
			await finish(panel)
			state(panel, -1)
		panel._concepts[0].grab_focus()
		await key(KEY_LEFT)
		check(root.gui_get_focus_owner() == panel._concepts[0] and panel.current_topic == -1, "Left endpoint stays put without selecting")
		for i in range(1, 5):
			await key(KEY_RIGHT)
			check(root.gui_get_focus_owner() == panel._concepts[i], "Chronological right focus even across compact rows")
		await key(KEY_RIGHT)
		check(root.gui_get_focus_owner() == panel._concepts[4], "Right endpoint does not wrap")
		await key(KEY_ENTER)
		await finish(panel)
		state(panel, 4)
		await key(KEY_SPACE)
		await finish(panel)
		state(panel, -1)
		for i in range(3, -1, -1):
			await key(KEY_TAB, true)
			check(root.gui_get_focus_owner() == panel._concepts[i], "Shift+Tab chronological order")
		for i in range(1, 5):
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == panel._concepts[i], "Tab one stop per card")
		for sequence in [[0, 2, 4, 1, 3], [3, 3, -1, 0], [3, 3, 0, 0, 4]]:
			panel.select_topic(-1, false)
			var expected := -1
			for topic in sequence:
				expected = -1 if topic == expected else topic
				panel.select_topic(topic)
				if panel._selection != null: panel._selection.custom_step(0.05)
			await finish(panel)
			state(panel, expected)
		for use_touch in [false, true]:
			panel.select_topic(-1, false)
			for i in [4, 2, 0, 1, 3]: await activate(panel._concepts[i], use_touch)
			await finish(panel)
			state(panel, 3)
		await activate(panel._sources_button)
		check(panel._sources.visible, "Sources opens")
		panel.select_topic(0)
		check(panel.current_topic == 3, "Sources prevents background topic changes")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() in [panel._source_scroll, panel._source_close], "Sources keyboard focus trap")
		await key(KEY_ESCAPE)
		check(panel._open and not panel._sources.visible, "Escape closes Sources first")
		state(panel, 3)
		layout(panel, dimensions)
		await activate(panel._sources_button, true)
		await activate(panel._source_close, true)
		state(panel, 3)
		panel.select_topic(2)
		await key(KEY_ESCAPE)
		check(not panel._open and panel.current_topic == -1 and panel._fade == null and panel._selection == null, "Escape close cancels/reset transient state")
		check(root.gui_get_focus_owner() == trigger, "Return focus restored")
		await activate(trigger)
		await finish(panel)
		state(panel, -1)
		await activate(panel._close, true)
		print("END-01 viewport ", dimensions, " verified")
	check(close_requests == 6, "One close request per full close")
	# Single overall optional audio, never tied to card activity.
	panel.content = panel.content.duplicate(true)
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = 8000
	var silence := PackedByteArray()
	silence.resize(160000)
	audio.data = silence
	panel.content.narration_stream = audio
	panel.open_interaction()
	await finish(panel)
	check(not panel._audio.playing and not panel._speaker.disabled, "Assigned recording does not autoplay")
	await activate(panel._speaker)
	await create_timer(0.15).timeout
	var playback: float = panel._audio.get_playback_position()
	panel.select_topic(0)
	panel.select_topic(3)
	panel.select_topic(3)
	panel.open_sources()
	panel.close_sources()
	check(panel._audio.playing and panel._audio.get_playback_position() >= playback, "Select/change/deselect/Sources preserve ongoing narration")
	panel.close_interaction()
	check(not panel._audio.playing, "Closing stops audio")
	# Production-only source checks distinguish safety warnings from claims.
	var production := FileAccess.get_file_as_string("res://scripts/landmarks/limahong_channel/lch_end_01.gd")
	for forbidden in ["visited_topics", "topics_viewed", "completed_topics", "summary_complete", "reflection_complete", "landmark_complete", "summary_completed", "reflection_completed", "all_topics_viewed", "landmark_completed", "PathFollow2D", "VideoStream", "Slider", "Magnifier"]:
		check(not production.contains(forbidden), "No prerequisites/completion or repeated earlier-hotspot interaction: " + forbidden)
	var visible_text := INTRO + BRIEF + REFLECTION + TAKEAWAY + " ".join(SHORT) + " ".join(DETAILS)
	for forbidden in ["proven exact escape route", "verified exact escape canal", "definitely used", "archaeologically confirmed", "As you learned earlier", "After completing", "all facilities", "Bataoil", "groundbreaking", "Correct", "Incorrect"]:
		check(not visible_text.contains(forbidden), "No unsupported claim, prerequisite or assessment wording")
	check(DETAILS[2].contains("official provincial history") and not DETAILS[2].contains("present-day"), "Historical escape and modern identification are distinct")
	check(DETAILS[3].contains("not been independently established through archaeological evidence"), "Archaeological caveat retained")
	check(panel.find_children("*", "LineEdit", true, false).is_empty() and panel.find_children("*", "VideoStreamPlayer", true, false).is_empty() and panel.find_children("*", "ProgressBar", true, false).is_empty(), "No entry, video or progress UI")
	preview.queue_free()
	await settle()
	print("LCH-END-01: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)
