extends SceneTree
## Production chronology, true input dispatch, original media and responsive checks.
const PREVIEW := preload("res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01_preview.tscn")
const EXPECTED := {
	&"overview": ["FROM WARTIME RUINS TO PRESERVATION","The Pangasinan Provincial Capitol experienced wartime destruction, postwar reconstruction, later refurbishment, and formal heritage protection. Explore five moments that shaped the building after 1945.","","Present-day contextual view of the Pangasinan Provincial Capitol.","SELECT A YEAR TO TRACE WHAT CHANGED."],
	&"damage_1945": ["THE CAPITOL IN RUINS","During the liberation of Pangasinan in January 1945, the Capitol was left in ruins. Its surviving structure later made reconstruction possible.","1945\nWAR DAMAGE","Pangasinan Provincial Capitol after wartime damage, 1945.",""],
	&"reconstruction_1946_1949": ["REBUILDING THE CAPITOL","Postwar rebuilding received assistance associated with the Philippine Rehabilitation Act under Governor Enrique Braganza, and the Capitol was reconstructed in 1949.","1946–1949\nRECONSTRUCTION","Present-day contextual view; no verified reconstruction photograph was supplied.","Reconstruction restored the Capitol while preserving its neoclassical character and its role as the province's administrative center."],
	&"recognition_2003": ["ARCHITECTURAL RECOGNITION","The Capitol was recognized as one of the Eight Architectural Treasures of the Philippines by Filipino Heritage Festival, Inc., an NCCA grantee.","2003\nARCHITECTURAL RECOGNITION","Researcher-supplied source excerpt documenting the Capitol's architectural recognition.",""],
	&"refurbishment_2008": ["A REFURBISHED CAPITOL","The refurbished Capitol building was inaugurated in June 2008 under Governor Amado T. Espino Jr.","2008\nREFURBISHMENT","Refurbished Pangasinan Provincial Capitol, 2008.","Compare the wartime-damaged Capitol with its later refurbished appearance."],
	&"protection_2018": ["HERITAGE SITE PROTECTION","Provincial Ordinance No. 220-2018 declared the Capitol a heritage site in the Province of Pangasinan and provided funds for its preservation.","2018\nHERITAGE PROTECTION","Certification page for Provincial Ordinance No. 220-2018.",""],
}
const IMAGES := {
	&"overview": "ppc_ext_01_government_today.jpeg",
	&"damage_1945": "ppc_int_01_1945_damage.png",
	&"reconstruction_1946_1949": "ppc_ext_01_government_today.jpeg",
	&"recognition_2003": "ppc_int_01_2003_recognition.png",
	&"refurbishment_2008": "ppc_int_01_2008_refurbished.png",
	&"protection_2018": "ppc_int_01_2018_heritage_protection.png",
}
var checks := 0
var failures := 0
var starts := 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 6:
		await process_frame

func finish(panel) -> void:
	for tween in [panel._transition, panel._media_tween]:
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

func date_pointer(panel, index: int, touch: bool = false) -> void:
	panel._rail.ensure_control_visible(panel._period_buttons[index])
	await settle()
	await pointer(panel._period_buttons[index], touch)

func drag(canvas: Control, touch: bool, start_amount: float, end_amount: float, vertical: bool = false) -> void:
	var start: InputEvent = InputEventScreenTouch.new() if touch else InputEventMouseButton.new()
	start.position = canvas.global_position + canvas.size * (Vector2(0.5, start_amount) if vertical else Vector2(start_amount, 0.5))
	if not touch:
		start.button_index = MOUSE_BUTTON_LEFT
	start.pressed = true
	Input.parse_input_event(start)
	await process_frame
	var motion: InputEvent = InputEventScreenDrag.new() if touch else InputEventMouseMotion.new()
	var midpoint := lerpf(start_amount, end_amount, 0.5)
	motion.position = canvas.global_position + canvas.size * (Vector2(0.5, midpoint) if vertical else Vector2(midpoint, 0.5))
	motion.relative = motion.position - start.position
	if not touch:
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(motion)
	await process_frame
	var final_position := canvas.global_position + canvas.size * (Vector2(0.5, end_amount) if vertical else Vector2(end_amount, 0.5))
	motion = motion.duplicate()
	motion.relative = final_position - motion.position
	motion.position = final_position
	Input.parse_input_event(motion)
	await process_frame
	start.position = motion.position
	start.pressed = false
	Input.parse_input_event(start)
	await settle()

func default_state(panel) -> void:
	check(panel.selected_period == &"overview" and panel.comparison_amount == 0.5, "Fresh overview and comparison midpoint")
	check(not panel._sources.visible and not panel.media_view_open, "Fresh modal state")
	check(panel.media_id == &"none" and panel.media_origin_period == &"none", "Cleared media identity")
	check(not panel._audio.playing and panel._audio.get_playback_position() == 0.0, "No autoplay / reset playback")
	check(panel._period_buttons.all(func(button): return not button.button_pressed), "No date automatically selected")
	check(panel._rail.scroll_horizontal == 0, "Timeline reset")

func assert_period(panel, id: StringName) -> void:
	check(panel.selected_period == id, "Authoritative selected period " + id)
	check(panel._heading.text == EXPECTED[id][0] and panel._body.text == EXPECTED[id][1], "Exact period heading/body")
	check(panel._takeaway.text == EXPECTED[id][4], "Exact supporting interpretation")
	check(panel._canvas.image.resource_path.ends_with(IMAGES[id]), "Correct unmodified documentary image")
	check(panel._canvas.comparing == (id == &"refurbishment_2008"), "Comparison only in refurbishment")
	check(panel._enlarge.visible == (id in panel.MEDIA_PERIODS), "Relevant historical viewer action")
	for i in panel.PERIODS.size():
		check(panel._period_buttons[i].button_pressed == (panel.PERIODS[i] == id), "One selected date without completion state")

func layout_checks(panel, dimensions: Vector2i) -> void:
	var bounds: Rect2 = panel.get_global_rect().grow(1)
	check(Rect2(Vector2.ZERO, dimensions).encloses(panel.get_global_rect()), "Root within viewport")
	check(bounds.encloses(panel.get_node("Main").get_global_rect()), "No root overflow")
	for control in panel._all_controls():
		if control is Button and control.is_visible_in_tree():
			check(control.size.x >= 48 and control.size.y >= 48, "Touchable button " + control.text)
			if not control in panel._period_buttons:
				check(bounds.encloses(control.get_global_rect()), "Button within bounds " + control.text)
	for button in panel._period_buttons:
		check(button.size.x >= 188 and button.size.y >= 64, "Date tabs never squeezed")
	check(panel._workspace.get_global_rect().end.y <= panel._rail.global_position.y, "Timeline below media and interpretation")
	if dimensions.x == 854:
		check(panel._information.global_position.y >= panel._visual.get_global_rect().end.y, "Compact interpretation drawer below media")
		check(panel._rail.get_h_scroll_bar().max_value > panel._rail.size.x, "Compact timeline scrolls")
	else:
		check(panel._visual.size.x >= panel._workspace.size.x * 0.65, "Media dominates desktop workspace")
	check(panel._canvas.size.y >= 120, "Meaningful media height")
	check(panel._visual.get_global_rect().grow(1).encloses(panel._canvas.get_global_rect()), "Canvas stays inside media: " + str(panel._visual.size) + " / " + str(panel._canvas.size) + " min=" + str(panel._visual.get_combined_minimum_size()))
	check(panel._canvas.get_global_rect().end.y <= panel._rail.global_position.y, "Canvas cannot overlap chronology")
	if panel._canvas.comparing:
		var frames: Array[Rect2] = panel._canvas.comparison_frames()
		check(is_equal_approx(frames[0].end.x, frames[1].position.x), "Divider meets both frame boundaries")
		check(is_equal_approx(frames[0].size.x + frames[1].size.x, panel._canvas.size.x), "Frames fill canvas")
		check(panel._canvas.divider_hit_rect().size.x >= 56, "Generous divider hit target")
		for i in 2:
			var texture: Texture2D = panel._canvas.damage_image if i == 0 else panel._canvas.image
			var rect: Rect2 = panel._canvas.fitted_rect(texture, frames[i])
			check(frames[i].grow(0.1).encloses(rect), "Whole image stays inside its own frame")
			if rect.has_area():
				check(is_equal_approx(rect.size.x / rect.size.y, float(texture.get_width()) / texture.get_height()), "No photo distortion")
	check(panel._canvas.scale == Vector2.ONE, "No image warping")
	if panel.media_view_open:
		check(bounds.encloses(panel._media_scroll.get_global_rect()), "Source image scroll contained")
		check(panel._media_scroll.size.y >= panel.size.y * 0.55, "Source photo/document dominates modal")
		check(panel._media_image.texture.resource_path.ends_with(IMAGES[panel.media_id]), "Exact source image in viewer")

func focus_checks(panel) -> void:
	var active: Array[Control] = []
	for control in panel.focus_order():
		if control.is_visible_in_tree() and control.focus_mode == Control.FOCUS_ALL and not (control is BaseButton and control.disabled):
			active.append(control)
	active[0].grab_focus()
	await settle()
	for control in active:
		check(root.gui_get_focus_owner() == control, "Expected Tab target " + str(control.name))
		await key(KEY_TAB)
	check(root.gui_get_focus_owner() == active[0], "Tab cycle trapped")
	await key(KEY_TAB, true)
	check(root.gui_get_focus_owner() == active.back(), "Reverse Tab cycle")

func capture(name: String) -> void:
	if "--capture" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("ppc_int_01_" + name + ".png")) == OK, "Rendered capture")

func _initialize() -> void:
	run.call_deferred()
	create_timer(150).timeout.connect(func(): push_error("PPC-INT-01 timeout"); quit(2))

func run() -> void:
	var preview := PREVIEW.instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("HotspotFrame/CapitolInteraction")
	var trigger: Button = preview.get_node("Margin/Layout/OpenHotspot")
	panel.narration_started.connect(func(): starts += 1)
	check(panel.content.concepts.size() == 6, "Five periods and neutral overview")
	for id in EXPECTED:
		var record = panel.entry(id)
		check(record.heading == EXPECTED[id][0] and record.body == EXPECTED[id][1], "Exact approved Resource copy " + id)
		check(record.get_meta(&"caption") == EXPECTED[id][3], "Exact caption " + id)
		check(record.get_meta(&"image").resource_path.ends_with(IMAGES[id]), "Correct resource media mapping " + id)
	check(panel.content.narration_stream is AudioStreamOggVorbis, "Supplied OGG imports as Vorbis")
	check(panel.content.narration_stream.get_length() > 1, "Narration decodes")
	print("PPC-INT-01 narration length: ", panel.content.narration_stream.get_length())
	check(panel._left_label.text == "1945 — WAR DAMAGE" and panel._right_label.text == "2008 — REFURBISHED CAPITOL", "Exact truthful comparison labels")
	check(panel.entry(&"reconstruction_1946_1949").get_meta(&"image") == panel.content.illustration, "Present-day context, no invented reconstruction photograph")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		root.content_scale_size = Vector2i.ZERO
		panel.close_hotspot()
		trigger.grab_focus()
		panel.open_hotspot()
		await finish(panel)
		default_state(panel)
		assert_period(panel, &"overview")
		layout_checks(panel, dimensions)
		await capture(str(dimensions.x) + "_overview")
		await focus_checks(panel)
		await pointer(panel._speaker, true)
		check(panel._audio.playing, "Touch starts narration once")
		var starts_before := starts
		var position_before: float = panel._audio.get_playback_position()
		for index in [4, 0, 2, 3, 1, 4]:
			await date_pointer(panel, index, index % 2 == 0)
			await finish(panel)
			assert_period(panel, panel.PERIODS[index])
			layout_checks(panel, dimensions)
			await capture(str(dimensions.x) + "_" + panel.PERIODS[index])
		for index in 5:
			panel._period_buttons[index].grab_focus()
			await key(KEY_ENTER if index % 2 == 0 else KEY_SPACE)
			await finish(panel)
			assert_period(panel, panel.PERIODS[index])
		panel.select_history_period(&"refurbishment_2008")
		await finish(panel)
		await drag(panel._canvas, false, 0.5, 0.72)
		check(absf(panel.comparison_amount - 0.72) < 0.01, "Mouse divider drag")
		await drag(panel._canvas, true, 0.72, 0.3)
		check(absf(panel.comparison_amount - 0.3) < 0.01, "Touch divider drag")
		panel._canvas.grab_focus()
		await key(KEY_RIGHT)
		check(absf(panel.comparison_amount - 0.4) < 0.01, "Keyboard +0.1")
		await key(KEY_LEFT)
		check(absf(panel.comparison_amount - 0.3) < 0.01, "Keyboard -0.1")
		await key(KEY_HOME)
		await key(KEY_LEFT)
		check(panel.comparison_amount == 0, "Comparison lower clamp")
		layout_checks(panel, dimensions)
		await key(KEY_END)
		await key(KEY_RIGHT)
		check(panel.comparison_amount == 1, "Comparison upper clamp")
		layout_checks(panel, dimensions)
		panel.set_comparison_amount(0.72)
		panel.select_history_period(&"protection_2018")
		panel.select_history_period(&"refurbishment_2008")
		await finish(panel)
		check(panel.comparison_amount == 0.72 and panel._canvas.amount == 0.72, "Comparison memory")
		await focus_checks(panel)
		panel.set_comparison_amount(0.5)
		await capture(str(dimensions.x) + "_comparison")
		for id in panel.MEDIA_PERIODS:
			panel.select_history_period(id)
			await finish(panel)
			var before: float = panel.comparison_amount
			await pointer(panel._enlarge, true)
			await finish(panel)
			check(panel.media_view_open and panel.media_id == id and panel.media_origin_period == id, "Media origin " + id)
			check(panel._media_heading.text == EXPECTED[id][0] and panel._media_caption.text == EXPECTED[id][3], "Viewer correct heading/caption")
			check(panel._media_credit.text == panel.entry(id).get_meta(&"credit"), "Known source credit only")
			check(root.gui_get_focus_owner() == panel._media_close, "Viewer initial close focus")
			panel.select_history_period(&"refurbishment_2008")
			panel.set_comparison_amount(0.1)
			panel.open_sources()
			check(panel.selected_period == id and panel.comparison_amount == before and not panel._sources.visible, "Viewer blocks background and modal stacking")
			layout_checks(panel, dimensions)
			await focus_checks(panel)
			await capture(str(dimensions.x) + "_source_" + id)
			await pointer(panel._media_zoom)
			check(panel._media_scale == 2, "Source enlargement")
			await capture(str(dimensions.x) + "_enlarged_" + id)
			if id == &"protection_2018":
				await drag(panel._media_scroll, true, 0.8, 0.2, true)
				check(panel._media_scroll.scroll_vertical > 0, "Touch pans enlarged ordinance")
			panel._media_scroll.grab_focus()
			await key(KEY_DOWN)
			panel._media_close.grab_focus()
			await key(KEY_ESCAPE)
			await finish(panel)
			check(not panel.media_view_open and panel.selected_period == id and panel.comparison_amount == before, "Close returns exact source context")
			check(root.gui_get_focus_owner() == panel._enlarge, "Viewer restores opening control focus")
			panel._enlarge.grab_focus()
			await key(KEY_ENTER)
			check(panel.media_view_open, "Enter opens source")
			panel._media_close.grab_focus()
			await key(KEY_SPACE)
			await finish(panel)
			check(not panel.media_view_open, "Space closes source")
		check(panel._audio.playing and starts == starts_before and panel._audio.get_playback_position() >= position_before, "Narration continuous through chronology/comparison/media")
		panel.select_history_period(&"refurbishment_2008")
		panel.set_comparison_amount(0.72)
		await pointer(panel._sources_button)
		check(panel._sources.visible, "Sources opens")
		panel.select_history_period(&"damage_1945")
		panel.set_comparison_amount(0)
		check(panel.selected_period == &"refurbishment_2008" and panel.comparison_amount == 0.72, "Sources isolates background")
		await focus_checks(panel)
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel._open and panel._audio.playing, "Escape Sources only, audio continues")
		check(root.gui_get_focus_owner() == panel._sources_button, "Sources return focus")
		for id in [&"damage_1945", &"refurbishment_2008", &"protection_2018", &"reconstruction_1946_1949", &"recognition_2003"]:
			panel.select_history_period(id)
		await finish(panel)
		assert_period(panel, &"recognition_2003")
		check(panel._transition == null and panel._canvas.previous_image == null and panel._canvas.transition_alpha == 1, "Latest period wins, stale image cleared")
		for attempt in 6:
			panel.open_historical_media(&"recognition_2003")
			var opening: Tween = panel._media_tween
			panel.close_historical_media()
			check(not opening.is_valid(), "Closing cancels incomplete open tween")
			panel.open_historical_media(&"recognition_2003")
			panel.select_history_period(&"damage_1945")
			check(panel.selected_period == &"recognition_2003" and panel.media_view_open, "Closing fade keeps modal isolation")
			await finish(panel)
		check(panel.find_children("HistoricalSource", "PanelContainer", false, false).size() == 1, "One reusable historical viewer")
		if dimensions.x == 854:
			panel._rail.scroll_horizontal = 0
			await settle()
			var before_swipe: StringName = panel.selected_period
			await drag(panel._rail, true, 0.8, 0.2)
			check(panel._rail.scroll_horizontal > 0, "Native touch scrolls compact date rail")
			check(panel.selected_period == before_swipe and panel._scroll_touch_index == -1, "Swiping neither selects a date nor leaves a drag active")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(panel.selected_period == &"overview" and panel._open and panel.comparison_amount == 0.72, "Escape to overview preserves local comparison")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel._open, "Escape overview closes hotspot")
		default_state(panel)
		check(root.gui_get_focus_owner() == trigger, "Launcher focus restored")
		panel.open_hotspot()
		await finish(panel)
		default_state(panel)
		panel.select_history_period(&"damage_1945")
		panel.open_historical_media(&"damage_1945")
		panel.close_hotspot()
		panel.open_hotspot()
		await finish(panel)
		default_state(panel)
	panel.select_history_period(&"damage_1945")
	panel.toggle_narration()
	panel.open_historical_media(&"damage_1945")
	preview.hide()
	check(not panel._open and not panel.media_view_open and not panel._audio.playing, "Host hide cleans all activity")
	preview.show()
	var audio: AudioStream = panel.content.narration_stream
	panel.content.narration_stream = null
	panel.open_hotspot()
	check(panel._speaker.visible and panel._speaker.disabled and panel._pending.visible, "Missing audio fallback")
	panel.content.narration_stream = audio
	var visitor_copy: String = panel.content.title + panel.content.prompt
	for record in panel.content.concepts:
		visitor_copy += record.heading + record.body + str(record.get_meta(&"caption")) + str(record.get_meta(&"note")) + str(record.get_meta(&"label"))
	# Construct the obsolete label so it never occurs literally in test/source text.
	var obsolete := "Provincial " + "Cultural " + "Treasure"
	for excluded in [obsolete, "before and after " + "reconstruction", "1949 — RECONSTRUCTED", "NCCA declared", "1911", "1917", "1918", "1919", "score", "points", "reward", "achievement", "unlock", "completion counter"]:
		check(not visitor_copy.to_lower().contains(excluded.to_lower()), "Excluded unsupported claim or feature")
	for path in ["res://data/landmarks/pangasinan_provincial_capitol/ppc_int_01.tres", "res://scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01.gd", "res://scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01_canvas.gd"]:
		check(not FileAccess.get_file_as_string(path).to_lower().contains(obsolete.to_lower()), "No obsolete production designation")
	panel.close_hotspot()
	preview.queue_free()
	await settle()
	await create_timer(0.2).timeout
	print("PPC-INT-01: ", checks, " checks; failures: ", failures)
	quit(1 if failures else 0)
