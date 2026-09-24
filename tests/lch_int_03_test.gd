extends SceneTree
## Exercise real embedded component, native mouse/key/touch, and evidence-safe content.
const TITLES := ["2019 — A NEW MILESTONE", "PRESERVING THE STORY", "DEVELOPMENT IN PHASES"]
const BODIES := [
	"The groundbreaking of the Limahong Channel Tourism Center was held in June 2019 in Barangay Pangapisan Norte, Lingayen.",
	"The Limahong Channel preserves local memory of the 1575 Pangasinan campaign and Limahong's escape.\n\nIts historical association also supports heritage education and tourism initiatives.",
	"The Limahong Channel Tourism Center has been developed as a phased tourism project at the site."
]
const TAKEAWAYS := [
	"It marked an important modern milestone in the site's heritage and tourism development.",
	"Modern heritage efforts give visitors another way to encounter and learn about the history remembered at the site.",
	"Development has proceeded in phases. Facilities listed in the original development plan should not automatically be interpreted as completed facilities."
]
const CONTRIBUTOR := "Former representative Leopoldo N. Bataoil promoted the Limahong Channel Tourism Center, authored the House measure identifying the channel as a tourist spot, and co-led its 2019 groundbreaking."
const FACILITIES := ["Limahong Park and Marker", "Pavilion", "Artifact Display Area", "River-Cruise Facilities", "Sunset Garden", "Mini-Forest", "Eco-Park", "Paved Activity Areas", "Improved Access Roads"]
var checks: int = 0
var failures: int = 0

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
	for tween in [panel._transition, panel._story_tween]:
		if tween != null and tween.is_valid():
			tween.pause()
			tween.custom_step(1.0)
	await settle()

func swipe_up(control: Control) -> void:
	var start := control.get_global_rect().get_center() + Vector2(0, 35)
	var press := InputEventScreenTouch.new()
	press.position = start
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	for i in 4:
		var drag := InputEventScreenDrag.new()
		drag.position = start - Vector2(0, (i + 1) * 16)
		drag.relative = Vector2(0, -16)
		Input.parse_input_event(drag)
		await process_frame
	press = press.duplicate()
	press.position = start - Vector2(0, 64)
	press.pressed = false
	Input.parse_input_event(press)
	await settle()

func assert_state(panel, stage: int) -> void:
	check(panel.current_stage == stage and panel._selected == stage, "One authoritative stage")
	check(panel._heading.text == TITLES[stage] and panel._body.text == BODIES[stage], "Exact approved title and body")
	check(panel._takeaway.text == TAKEAWAYS[stage] and panel._takeaway.visible, "Exact takeaway / phased-development qualification")
	for i in 3:
		check(panel._concepts[i].button_pressed == (i == stage), "Exactly one selected stage control")
		check(panel._views[i].visible == (i == stage), "Exactly one visible stage at rest")
		check(panel._views[i].modulate.a == 1.0 and panel._views[i].scale == Vector2.ONE, "No residual opacity or transform")
	check(panel._transition == null and panel._story_tween == null, "No stuck stage animation")
	if stage != 0:
		check(not panel.contributor_expanded and panel._contributor.disabled and panel._contributor.focus_mode == Control.FOCUS_NONE, "Inactive contributor is reset and cannot take focus/input")
	if stage == 1:
		check(panel._story_progress == 1.0, "Preservation lines finish their reveal")
		for i in 3:
			check(panel._story_nodes[i].modulate.a == 1.0 and panel._story_nodes[i].focus_mode == Control.FOCUS_NONE, "Informational story nodes fully visible without focus")
	if stage == 2:
		check(panel._notice.visible and not panel._scroll.is_ancestor_of(panel._takeaway), "Qualification stays outside scrolling areas")
		check(panel._facility_cards.size() == 9, "Exactly nine original-plan categories")
		for i in 9:
			check(panel._facility_names[i].text == FACILITIES[i], "Exact original facility name")
			check(panel._data.facilities[i].status == 0 and panel._facility_statuses[i].text == "ORIGINAL PLAN", "No unsupported current facility status")
			check(not panel._facility_cards[i] is BaseButton and panel._facility_cards[i].focus_mode == Control.FOCUS_NONE, "Facility cards are informational")

func assert_layout(panel, dimensions: Vector2i) -> void:
	var bounds: Rect2 = panel.get_global_rect().grow(0.5)
	check(panel.size.is_equal_approx(Vector2(dimensions) * 0.9), "Embedded inset parent dimensions")
	for control in [panel._title, panel._close, panel._speaker, panel._sources_button, panel._board, panel._information, panel._heading, panel._scroll]:
		check(bounds.encloses(control.get_global_rect()), "Shell control remains in parent: " + control.name)
	check(not panel._title.get_global_rect().intersects(panel._speaker.get_global_rect()), "Header title never overlaps Listen")
	check(panel._information.find_children("*", "Button", true, false).is_empty(), "No duplicate stage controls in info")
	for button in panel._concepts:
		check(bounds.encloses(button.get_global_rect()) and button.size.y >= 52, "Readable stage bar with generous touch targets")
		check(button.focus_mode == Control.FOCUS_ALL, "All stages keyboard-focusable")
		check(button.has_theme_stylebox("focus", "Button"), "Shared distinct keyboard focus style")
	for photo in panel._photos:
		check(photo.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED and photo.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR, "Documentary aspect ratio preserved without pixel filtering/cropping")
	var visual_bounds: Rect2 = panel._board.get_global_rect().grow(0.5)
	if panel.current_stage == 0:
		for control in [panel._photos[0], panel._documentary, panel._contributor, panel._photos[1]]:
			check(visual_bounds.encloses(control.get_global_rect()), "Milestone visual fits: " + control.name)
		check(panel._photos[0].size.y >= (40 if panel.contributor_expanded else 100), "Primary documentary photo retains usable area")
		check(panel._contributor.size.y >= 48, "Contributor card touch target")
		if panel.contributor_expanded:
			check(visual_bounds.encloses(panel._contributor_details.get_global_rect()), "Expanded contributor explanation stays within visual area")
			check(panel._contributor_heading.get_theme_color("font_color").r < 0.1, "Expanded card heading contrasts with muted-gold selection")
	if panel.current_stage == 1:
		for node in panel._story_nodes:
			check(visual_bounds.encloses(node.get_global_rect()), "Story node stays in board")
		for i in 2:
			check(not panel._story_nodes[0].get_rect().intersects(panel._story_nodes[i + 1].get_rect()), "Story nodes do not overlap")
			check(panel._story_lines[i].points[0].distance_to(panel._story_lines[i].points[1]) > 16, "Generated branch connector has visible length")
	if panel.current_stage == 2:
		check(bounds.encloses(panel._takeaway.get_global_rect()), "Entire qualification is visible without scrolling")
		var body_rect: Rect2 = panel._body.get_global_rect()
		var why_rect: Rect2 = panel._why.get_global_rect()
		var body_gap := why_rect.position.y - body_rect.end.y
		check(body_gap >= 6 and body_gap <= 16, "Development body and WHY IT MATTERS form a compact top-aligned stack")
		check(panel._scroll.get_global_rect().encloses(body_rect), "Entire Development body remains visible")
		check(panel._takeaway.get_global_rect().position.y >= why_rect.end.y, "Qualification never overlaps WHY IT MATTERS")
		var photo: TextureRect = panel._photos[2]
		var photo_dimensions := photo.texture.get_size()
		var display_dimensions := photo_dimensions * minf(photo.size.x / photo_dimensions.x, photo.size.y / photo_dimensions.y)
		var prior_height := 128.0 if dimensions.x == 1280 else 76.0
		check(display_dimensions.y >= prior_height * 1.3, "Present-site photo is at least 30 percent taller than the prior version")
		check(is_equal_approx(display_dimensions.x / display_dimensions.y, 4.0 / 3.0), "Present-site photo keeps its original 4:3 aspect ratio")
		check(photo.size.y <= visual_bounds.size.y * 0.4, "Enlarged site photo leaves most visual height for the board")
		print("Development layout ", dimensions, ": body-to-WHY gap=", body_gap, "px; displayed photo=", display_dimensions)
		for control in [panel._photos[2], panel._present_caption, panel._plan_heading, panel._facility_scroll]:
			check(visual_bounds.encloses(control.get_global_rect()), "Development visual fits: " + control.name)
		check(panel._facility_scroll.size.y >= 72, "Internal grid viewport fits at least one card row")
		check(panel._facility_grid.columns == (2 if dimensions.x == 854 else 3), "Responsive 3/2-column facility grid")
		for i in 9:
			var card_bounds: Rect2 = panel._facility_cards[i].get_global_rect().grow(0.5)
			check(card_bounds.encloses(panel._facility_names[i].get_global_rect()) and card_bounds.encloses(panel._facility_statuses[i].get_global_rect()), "Readable facility name and status inside card")
	else:
		check(panel._scroll.size_flags_vertical == Control.SIZE_EXPAND_FILL and panel._scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "Other stages retain their existing information scrolling layout")
	if dimensions.x in [1280, 854]:
		var ratio: float = panel._board.size.x / (panel._board.size.x + panel._information.size.x)
		check(ratio >= (0.62 if dimensions.x == 1280 else 0.55) and ratio <= (0.65 if dimensions.x == 1280 else 0.58), "Requested visual/info ratio")

func capture(tag: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lch-int-03-" + tag + ".png"))

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	create_timer(100.0).timeout.connect(func(): push_error("INT-03 test timeout"); quit(1))
	root.content_scale_size = Vector2i.ZERO
	var preview = load("res://scenes/landmarks/limahong_channel/interior/lch_int_03_preview.tscn").instantiate()
	root.add_child(preview)
	await settle()
	var panel = preview.get_node("HotspotFrame/HeritageDevelopmentInteraction")
	var trigger = preview.get_node("Margin/Layout/OpenArtwork")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		trigger.grab_focus()
		check(panel.open_interaction(), "Real INT-03 component opens")
		await settle()
		assert_state(panel, 0)
		assert_layout(panel, dimensions)
		check(not panel.contributor_expanded and not panel._sources.visible and not panel._audio.playing, "Milestone opens collapsed, Sources closed, no autoplay")
		check(panel._speaker.visible and panel._speaker.disabled and panel._pending.visible and panel._speaker.icon.resource_path == "res://assets/ui/icons/speaker.svg", "Visible shared LISTEN / pending")
		for i in 3:
			check(panel._photos[i].texture != null and not panel._fallbacks[i].visible, "All three supplied documentary images loaded")
		check(panel._photos[0].texture.get_size() == Vector2(415, 260) and panel._photos[1].texture.get_size() == Vector2(1122, 1402) and panel._photos[2].texture.get_size() == Vector2(4000, 3000), "Unchanged supplied image dimensions")
		await capture("%dx%d-milestone" % [dimensions.x, dimensions.y])
		await touch(panel._contributor)
		check(panel.contributor_expanded and panel._contributor_body.text == CONTRIBUTOR and panel._contributor_details.visible, "Touch expands exact sourced contributor role")
		assert_layout(panel, dimensions)
		await capture("%dx%d-contributor" % [dimensions.x, dimensions.y])
		panel._scroll.grab_focus()
		await key(KEY_END)
		check(panel._takeaway.get_global_rect().end.y <= panel._scroll.get_global_rect().end.y + 1, "Keyboard reaches full milestone takeaway")
		panel.open_sources()
		await key(KEY_ESCAPE)
		check(panel.contributor_expanded and panel._open, "Sources preserves contributor expansion")
		await click(panel._contributor)
		check(not panel.contributor_expanded, "Mouse collapses contributor")
		for stage in [1, 2, 0]:
			await click(panel._concepts[stage])
			await finish(panel)
			assert_state(panel, stage)
			assert_layout(panel, dimensions)
			await capture("%dx%d-stage%d" % [dimensions.x, dimensions.y, stage])
		for stage in [2, 1, 0]:
			await touch(panel._concepts[stage])
			await finish(panel)
			assert_state(panel, stage)
		await touch(panel._concepts[0])
		assert_state(panel, 0)
		panel._concepts[0].grab_focus()
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._concepts[1], "Tab advances stage order")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._concepts[0], "Shift+Tab reverses stage order")
		await key(KEY_LEFT)
		check(panel.current_stage == 0, "Left endpoint does not wrap")
		await key(KEY_RIGHT)
		await key(KEY_RIGHT)
		await key(KEY_RIGHT)
		await finish(panel)
		assert_state(panel, 2)
		check(root.gui_get_focus_owner() == panel._concepts[2], "Right endpoint does not wrap")
		panel._concepts[0].grab_focus()
		await key(KEY_ENTER)
		await finish(panel)
		assert_state(panel, 0)
		panel._contributor.grab_focus()
		await key(KEY_SPACE)
		check(panel.contributor_expanded, "Keyboard toggles contributor")
		panel._concepts[1].grab_focus()
		await key(KEY_SPACE)
		await finish(panel)
		assert_state(panel, 1)
		# Sequential 150 + 250 + 200 ms interpretation reveal.
		panel.select_stage(0, false)
		panel.select_stage(1)
		panel._transition.pause()
		panel._story_tween.pause()
		check(panel._views[0].visible and panel._views[1].visible and panel._contributor.disabled, "Crossfade outgoing view is inert")
		panel._transition.custom_step(0.21)
		check(not panel._views[0].visible and panel._views[1].modulate.a == 1.0, "200ms crossfade settles to one view")
		panel._story_tween.custom_step(0.16)
		check(panel._story_nodes[0].modulate.a == 1.0 and panel._story_nodes[1].modulate.a == 0.0, "Historical Memory appears first")
		panel._story_tween.custom_step(0.15)
		check(panel._story_progress > 0 and panel._story_progress < 1.0, "Connection lines reveal next")
		await finish(panel)
		assert_state(panel, 1)
		for sequence in [[0, 2, 1, 0, 2], [1, 2, 0]]:
			for stage in sequence:
				panel.select_stage(stage)
				if panel._transition != null:
					panel._transition.pause()
					panel._transition.custom_step(0.06)
			await finish(panel)
			assert_state(panel, sequence[-1])
		panel.select_stage(2)
		await finish(panel)
		if panel._facility_scroll.get_v_scroll_bar().max_value > panel._facility_scroll.get_v_scroll_bar().page:
			panel._facility_scroll.scroll_vertical = 0
			await swipe_up(panel._facility_scroll)
			check(panel._facility_scroll.scroll_vertical > 0, "Synthetic touch drag scrolls facility grid")
			panel._facility_scroll.scroll_vertical = 0
			panel._facility_scroll.grab_focus()
			await key(KEY_PAGEDOWN)
			check(panel._facility_scroll.scroll_vertical > 0, "Keyboard scrolls informational facility grid")
			panel._facility_scroll.scroll_vertical = 0
			var wheel := InputEventMouseButton.new()
			wheel.position = panel._facility_scroll.get_global_rect().get_center()
			wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
			wheel.pressed = true
			Input.parse_input_event(wheel)
			await settle()
			check(panel._facility_scroll.scroll_vertical > 0, "Mouse wheel scrolls facility grid")
		for card in panel._facility_cards:
			panel._facility_scroll.ensure_control_visible(card)
			await settle()
			check(panel._facility_scroll.get_global_rect().grow(1).encloses(card.get_global_rect()), "Each original-plan card is fully reachable through internal scrolling")
		panel._facility_scroll.scroll_vertical = 10000
		await settle()
		var scroll: int = panel._facility_scroll.scroll_vertical
		check(panel._facility_cards[8].get_global_rect().end.y <= panel._facility_scroll.get_global_rect().end.y + 1, "Last facility reachable within grid scroll")
		await capture("%dx%d-plan-bottom" % [dimensions.x, dimensions.y])
		await touch(panel._sources_button)
		check(panel._sources.visible, "Touch opens Sources")
		check(panel._source_text.text.contains("Liwayway Yparraguirre") and panel._source_text.text.contains("Municipality of Lingayen") and panel._source_text.text.contains("2026-07-18 11:44:09"), "Supplied and embedded media metadata appears in Sources")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() in [panel._source_scroll, panel._source_close], "Sources traps keyboard focus")
		panel.select_stage(0)
		check(panel.current_stage == 2, "Sources blocks background stage changes")
		await key(KEY_ESCAPE)
		check(panel._open and not panel._sources.visible and panel._facility_scroll.scroll_vertical == scroll, "Sources Escape preserves stage and scroll")
		assert_state(panel, 2)
		panel.select_stage(1)
		await key(KEY_ESCAPE)
		check(not panel._open and panel._transition == null and panel._story_tween == null and not panel._audio.playing, "Escape close cancels animations/audio")
		check(root.gui_get_focus_owner() == trigger, "Opener focus restored")
		await click(trigger)
		await settle()
		assert_state(panel, 0)
		check(not panel.contributor_expanded and panel._facility_scroll.scroll_vertical == 0, "Reopen resets contributor and facility scroll")
		await touch(panel._close)
		print("INT-03 viewport ", dimensions, " verified")
	# One overall narration: stage/contributor/Sources changes never restart it.
	panel.content = panel.content.duplicate(true)
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = 8000
	var silence := PackedByteArray()
	silence.resize(160000)
	audio.data = silence
	panel.content.narration_stream = audio
	panel.open_interaction()
	await settle()
	check(not panel._audio.playing and not panel._speaker.disabled, "Assigned narration never autoplays")
	await click(panel._speaker)
	await create_timer(0.15).timeout
	var playback: float = panel._audio.get_playback_position()
	panel.toggle_contributor()
	panel.select_stage(2)
	panel.open_sources()
	panel.close_sources()
	check(panel._audio.playing and panel._audio.stream == audio and panel._audio.get_playback_position() >= playback, "One narration survives all content changes without restarting")
	panel.close_interaction()
	check(not panel._audio.playing, "Close stops narration")
	# Absent files do not prevent resource loading or stage/contributor selection.
	for media in [panel._data.groundbreaking, panel._data.contributor_image, panel._data.present_site]:
		media.image_path = "res://assets/landmarks/limahong_channel/lch_int_03/not_supplied.jpg"
	panel.open_interaction()
	await settle()
	for i in 3:
		check(panel._photos[i].texture == null and panel._fallbacks[i].visible, "Missing image uses labelled documentary fallback")
	for stage in [1, 2, 0]:
		panel.select_stage(stage, false)
		await settle()
		assert_state(panel, stage)
	panel.toggle_contributor()
	check(panel.contributor_expanded, "Contributor remains functional without image")
	await capture("854x480-fallback")
	# Absence checks only; no removed-feature state/resources/interactions are built.
	check(panel.find_children("*", "VideoStreamPlayer", true, false).is_empty() and panel.find_children("*", "Slider", true, false).is_empty(), "No removed playback or image-comparison controls")
	var text := ""
	for label in panel.find_children("*", "Label", true, false):
		text += label.text.to_upper() + "\n"
	for unsupported in ["ALL FACILITIES COMPLETED", "FULLY COMPLETED TOURISM CENTER", "ALL FACILITIES EXISTING", "PROJECT FULLY FINISHED"]:
		check(not text.contains(unsupported), "No unsupported completion statement")
	check(panel._data.present_site.permission_status == "Research-team captured / authorized for AKAR use", "Researcher-supplied media authorization retained")
	check(panel._data.groundbreaking.permission_status == "PENDING" and panel._data.contributor_image.permission_status == "PENDING", "External image reuse permissions not invented")
	preview.queue_free()
	await settle()
	print("LCH-INT-03: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)
