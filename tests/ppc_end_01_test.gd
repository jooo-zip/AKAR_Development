extends SceneTree
## Real production summary, dispatched input, optional reflection and responsive checks.
const PREVIEW := preload("res://scenes/landmarks/pangasinan_provincial_capitol/summary/ppc_end_01_preview.tscn")
var checks := 0
var failures := 0
var starts := 0

const THEMES := [&"origins", &"architecture", &"resilience", &"public_service", &"heritage"]
const CHOICES := [&"history", &"architecture", &"public_role", &"preservation"]
const EXPECTED := {
	&"overview": ["More Than a Historic Building", "The Pangasinan Provincial Capitol brings together more than a century of government, architecture, historical change, and heritage preservation. Explore the ideas that define its continuing significance.", "SELECT A THEME TO EXPLORE WHAT THE CAPITOL REPRESENTS."],
	&"origins": ["A Provincial Government Center", "Constructed from 1917 to 1918 under Governor Daniel Maramba and designed by Ralph Harrington Doane, the Capitol established a permanent provincial government center in Lingayen.", "The Capitol represents Pangasinan's transition from the Spanish-era Casa Real to an American-period provincial government center."],
	&"architecture": ["Neoclassical Civic Design", "The Capitol's balanced façade, Ionic-order entrance columns, large windows, colonnades, and other architectural features give the building its formal neoclassical character while responding to Pangasinan's tropical climate.", "Its architecture combines monumental civic form with practical features for light, air, shade, and protection from the weather."],
	&"resilience": ["Damage, Rebuilding, and Renewal", "After being left in ruins during the liberation of Pangasinan in 1945, the Capitol was reconstructed in 1949 and later refurbished while preserving its architectural character.", "The Capitol's survival, reconstruction, and later renewal became part of its continuing historical significance."],
	&"public_service": ["A Living Seat of Government", "The Capitol remains an active seat of provincial government where executive and legislative functions continue to be carried out.", "The building is both a preserved heritage landmark and a working center of provincial government."],
	&"heritage": ["Recognition and Preservation", "The Capitol's architectural significance has received wider recognition, while Provincial Ordinance No. 220-2018 supports its preservation as a heritage site in the Province of Pangasinan.", "Recognition and preservation help protect the Capitol's architectural and historical significance for future generations."]
}
const RESPONSES := [
	"The Capitol carries the memory of more than a century of change—from its establishment as a government center to wartime destruction and postwar rebuilding.",
	"Its neoclassical design remains one of the clearest visual reminders of the Capitol's historic civic character.",
	"The Capitol remains significant because its historic spaces continue to support provincial government today.",
	"Preserving the Capitol helps protect a landmark that connects Pangasinan's architectural heritage, historical memory, and continuing civic life."
]
const IMAGES := {
	&"overview": "exterior/ppc_ext_01/ppc_ext_01_government_today.jpeg",
	&"origins": "exterior/ppc_ext_01/ppc_ext_01_government_today.jpeg",
	&"architecture": "exterior/ppc_ext_02/ppc_ext_02_detail_facade_rhythm.JPG",
	&"resilience": "interior/ppc_int_01/ppc_int_01_1945_damage.png",
	&"public_service": "interior/ppc_int_02/ppc_int_02_governor_office.png",
	&"heritage": "interior/ppc_int_01/ppc_int_01_2018_heritage_protection.png"
}
const CAPTIONS := {
	&"overview": "Present-day view of the Pangasinan Provincial Capitol, Lingayen.",
	&"origins": "Present-day view of the Pangasinan Provincial Capitol, Lingayen.",
	&"architecture": "Rhythm of columns and windows on the Capitol façade.",
	&"resilience": "Pangasinan Provincial Capitol after wartime damage, 1945.",
	&"public_service": "Governor's Office and Session Hall of the Pangasinan Provincial Capitol.",
	&"heritage": "Certification page for Provincial Ordinance No. 220-2018."
}

func _initialize() -> void:
	run.call_deferred()
	create_timer(300).timeout.connect(func() -> void:
		push_error("PPC-END-01 test timeout")
		quit(2)
	)

func defaults(panel) -> void:
	check(panel.selected_theme == &"overview", "Default overview")
	check(not panel.reflection_view_open and panel.reflection_choice == &"" and panel.reflection_origin_theme == &"overview", "Reflection default state")
	check(not panel._sources.visible and not panel._audio.playing, "No modal or autoplay")
	check(panel._rail.scroll_horizontal == 0, "Rail reset")
	for button in panel._theme_buttons:
		check(not button.button_pressed and not button.disabled, "Every theme available, none preselected")
	check(panel._reflect.is_visible_in_tree() and not panel._reflect.disabled, "Reflection immediately available")
	assert_theme(panel, &"overview")

func assert_theme(panel, id: StringName) -> void:
	check(panel.selected_theme == id, "Authoritative selected theme")
	check(panel._heading.text == EXPECTED[id][0], "Exact heading " + id)
	check(panel._body.text == EXPECTED[id][1], "Exact body " + id)
	check(panel._takeaway.text == EXPECTED[id][2], "Exact takeaway " + id)
	check(panel._canvas.primary.resource_path == "res://assets/landmarks/pangasinan_provincial_capitol/" + IMAGES[id], "Direct existing image reference " + id)
	check(panel._caption.text == CAPTIONS[id], "Date-safe image caption " + id)
	for i in THEMES.size():
		check(panel._theme_buttons[i].button_pressed == (THEMES[i] == id), "Single theme selection")
	check(panel._canvas.previous_primary == null and panel._canvas.previous_secondary == null and panel._canvas.blend == 1, "Crossfade leaves no stale visual")
	check((panel._canvas.secondary != null) == (id == &"public_service"), "Split only for Public Service")

func activate(panel, button: Button, method: int) -> void:
	if button in panel._theme_buttons:
		panel._rail.ensure_control_visible(button)
		await settle()
	if method < 2:
		await pointer(button, method == 1)
	else:
		button.grab_focus()
		await key(KEY_ENTER if method == 2 else KEY_SPACE)
	await finish(panel)

func focus_checks(panel) -> void:
	var order: Array = panel.focus_order()
	order[0].grab_focus()
	for control in order:
		check(root.gui_get_focus_owner() == control, "Tab follows requested order")
		await key(KEY_TAB)
	check(root.gui_get_focus_owner() == order[0], "Context focus loop")
	for i in range(order.size() - 1, -1, -1):
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == order[i], "Reverse focus loop")

func geometry(panel) -> void:
	var bounds: Rect2 = panel.get_global_rect()
	for control in panel._all_controls():
		if control is Button and control.is_visible_in_tree():
			check(control.size.y >= 48 and control.size.x >= 48, "48 px touch target")
			check(control.get_theme_font("font").get_string_size(control.text, HORIZONTAL_ALIGNMENT_LEFT, -1, control.get_theme_font_size("font_size")).x <= control.size.x - 20, "No clipped button text: " + control.text)
			if control not in panel._theme_buttons:
				check(bounds.grow(1).encloses(control.get_global_rect()), "Control in safe area: " + control.text)
	if panel.reflection_view_open:
		check(panel._choice_grid.columns == 2, "Reflection uses 2 by 2 grid")
		check(panel._response_scroll.get_global_rect().end.y <= panel._back.global_position.y, "Reflection text does not overlap Back")
		check(panel._response_scroll.size.y > 55, "Reflection reading area remains usable")
	else:
		check(panel._canvas.get_global_rect().end.y <= panel._rail.global_position.y, "Theme visual does not overlap controls")
		check(panel._information.get_global_rect().end.y <= panel._rail.global_position.y, "Synthesis does not overlap controls")
		check(panel._canvas.size.y >= 60, "Theme image remains meaningful")
		var split: bool = panel._canvas.secondary != null
		for i in (2 if split else 1):
			var texture: Texture2D = panel._canvas.primary if i == 0 else panel._canvas.secondary
			var area: Rect2 = panel._canvas.image_area(i, split)
			var fitted: Rect2 = panel._canvas.fitted_rect(texture, area)
			check(area.grow(1).encloses(fitted), "Full documentary image fits")
			check(absf(fitted.size.x / fitted.size.y - texture.get_width() / float(texture.get_height())) < 0.001, "No image distortion")
		if split:
			check(panel._canvas.image_area(0, true).size == panel._canvas.image_area(1, true).size, "Equal civic image areas")
			check(panel._canvas.secondary.resource_path.ends_with("ppc_int_02_session_hall.jpeg"), "Session Hall split image")
			check(panel._canvas.left_label == "EXECUTIVE\nGovernor's Office" and panel._canvas.right_label == "LEGISLATIVE\nSession Hall", "Balanced civic labels")

func capture(name: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("ppc_end_01_" + name + ".png")) == OK, "Screenshot " + name)

func run() -> void:
	var preview := PREVIEW.instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("HotspotFrame/CapitolInteraction")
	var trigger := preview.get_node("Margin/Layout/OpenHotspot")
	panel.narration_started.connect(func() -> void: starts += 1)
	check(panel.content.narration_stream is AudioStreamOggVorbis and panel.content.narration_stream.get_length() > 5, "Narration imported")
	print("Narration duration: ", panel.content.narration_stream.get_length())
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		print("Validating ", dimensions)
		root.size = dimensions
		root.content_scale_size = Vector2i.ZERO
		await settle()
		panel.close_hotspot()
		await settle()
		trigger.grab_focus()
		panel.open_hotspot()
		await finish(panel)
		defaults(panel)
		geometry(panel)
		await focus_checks(panel)
		await capture(str(dimensions.x) + "_overview")
		await activate(panel, panel._reflect, 1)
		check(panel.reflection_view_open and panel.reflection_origin_theme == &"overview", "Immediate reflection without prerequisite visits")
		check(not panel._response.visible and not panel._closing_synthesis.visible, "No response before optional choice")
		geometry(panel)
		await capture(str(dimensions.x) + "_reflection_empty")
		await focus_checks(panel)
		for method in 4:
			for i in CHOICES.size():
				await activate(panel, panel._choice_buttons[i], method)
				check(panel.reflection_choice == CHOICES[i], "All reflection choices via every input")
				check(panel._response.text == RESPONSES[i], "Exact reflection response")
				check(panel._closing_synthesis.visible and panel._closing_synthesis.text == "The Capitol connects Pangasinan's past with its present through architecture, historical memory, preservation, and continuing public service.", "Approved closing synthesis")
				for j in CHOICES.size():
					check(panel._choice_buttons[j].button_pressed == (i == j), "Single reflection selected")
				geometry(panel)
				if method == 0:
					await capture(str(dimensions.x) + "_reflection_" + str(CHOICES[i]))
		await activate(panel, panel._back, 2)
		check(not panel.reflection_view_open and panel.selected_theme == &"overview" and panel.reflection_choice == &"preservation", "Return to overview keeps choice")
		check(root.gui_get_focus_owner() == panel._reflect, "Reflection opener focus restored")
		for method in 4:
			for i in THEMES.size():
				await activate(panel, panel._theme_buttons[i], method)
				assert_theme(panel, THEMES[i])
				geometry(panel)
				if method == 0:
					await focus_checks(panel)
					await capture(str(dimensions.x) + "_" + str(THEMES[i]))
				await activate(panel, panel._reflect, method)
				check(panel.reflection_origin_theme == THEMES[i] and panel.reflection_view_open, "Reflection accessible from every theme")
				check(panel._reflection_background.primary == panel._canvas.primary and panel._reflection_background.secondary == panel._canvas.secondary, "Origin visual retained")
				check(panel.reflection_choice == &"preservation", "Reflection memory retained across themes")
				panel.select_meaning_theme(&"overview")
				check(panel.selected_theme == THEMES[i], "Reflection blocks underlying themes")
				await activate(panel, panel._back, method)
				check(panel.selected_theme == THEMES[i] and not panel.reflection_view_open, "Exact reflection origin return")
				check(root.gui_get_focus_owner() == panel._reflect, "Opener focus restored for all input paths")
		for id in [&"heritage", &"origins", &"public_service", &"architecture", &"resilience"]:
			panel.select_meaning_theme(id)
		await finish(panel)
		assert_theme(panel, &"resilience")
		panel.select_meaning_theme(&"architecture")
		await finish(panel)
		await activate(panel, panel._speaker, 1)
		await create_timer(0.3).timeout
		var before_starts := starts
		var before_position: float = panel._audio.get_playback_position()
		check(panel._audio.playing and before_position > 0, "Native touch starts narration once")
		for id in THEMES:
			panel.select_meaning_theme(id)
			await finish(panel)
		panel.open_reflection()
		await finish(panel)
		for id in CHOICES:
			panel.select_reflection(id)
			await finish(panel)
		await pointer(panel._sources_button)
		check(panel._sources.visible, "Sources accessible within reflection")
		panel.select_reflection(&"history")
		panel.select_meaning_theme(&"origins")
		panel.close_reflection()
		panel.toggle_narration()
		check(panel.reflection_choice == &"preservation" and panel.selected_theme == &"heritage" and panel.reflection_origin_theme == &"heritage" and panel.reflection_view_open, "Sources isolates and preserves reflection")
		await focus_checks(panel)
		await capture(str(dimensions.x) + "_sources")
		await drag(panel._source_scroll, true, 0.8, 0.2, true)
		check(panel._source_scroll.scroll_vertical > 0, "Sources touch scroll")
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel.reflection_view_open and root.gui_get_focus_owner() == panel._sources_button, "Escape closes Sources first")
		panel.close_reflection()
		await finish(panel)
		panel.open_sources()
		check(panel.selected_theme == &"heritage" and not panel.reflection_view_open and panel.reflection_choice == &"preservation", "Sources preserves summary too")
		panel.close_sources()
		check(panel._audio.playing and starts == before_starts and panel._audio.get_playback_position() >= before_position, "Narration continuous through all contexts")
		panel.stop_narration()
		for id in [&"origins", &"heritage", &"architecture", &"public_service", &"resilience"]:
			panel.select_meaning_theme(id)
		await finish(panel)
		assert_theme(panel, &"resilience")
		panel.open_reflection()
		for id in [&"history", &"preservation", &"architecture", &"public_role"]:
			panel.select_reflection(id)
		await finish(panel)
		check(panel.reflection_choice == &"public_role" and panel._response.text == RESPONSES[2] and panel._response_copy.modulate.a == 1, "Latest reflection input wins")
		if panel._response_scroll.get_v_scroll_bar().max_value > panel._response_scroll.size.y:
			await drag(panel._response_scroll, true, 0.8, 0.2, true)
			check(panel._response_scroll.scroll_vertical > 0, "Reflection response touch scroll")
		panel.close_reflection()
		panel.open_sources()
		await finish(panel)
		check(panel._sources.visible and panel.reflection_view_open and not panel._reflection_closing, "Sources supersedes unfinished return safely")
		await key(KEY_ESCAPE)
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel.reflection_view_open and panel.selected_theme == &"resilience" and panel.reflection_choice == &"public_role", "Escape reflection preserves origin and memory")
		if panel._scroll.get_v_scroll_bar().max_value > panel._scroll.size.y:
			await drag(panel._scroll, true, 0.8, 0.2, true)
			check(panel._scroll.scroll_vertical > 0, "Synthesis touch scroll")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(panel.selected_theme == &"overview" and panel._open, "Escape theme to overview")
		if dimensions.x == 854:
			panel._rail.scroll_horizontal = 0
			await settle()
			await drag(panel._rail, true, 0.8, 0.2)
			check(panel._rail.scroll_horizontal > 0 and panel.selected_theme == &"overview", "Touch rail scroll without accidental activation")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel._open and root.gui_get_focus_owner() == trigger, "Escape overview closes to host")
		panel.open_hotspot()
		await finish(panel)
		defaults(panel)
		panel.select_meaning_theme(&"heritage")
		panel.open_reflection()
		panel.select_reflection(&"preservation")
		panel.toggle_narration()
		panel.open_sources()
		panel.close_hotspot()
		panel.open_hotspot()
		await finish(panel)
		defaults(panel)
	check(panel.entry(&"origins").get_meta(&"cue") == "1917 · CONSTRUCTION BEGAN  →  1918 · COMPLETED", "Construction cue separate from modern image")
	check(panel.entry(&"resilience").get_meta(&"cue") == "1945 · WAR DAMAGE  →  1949 · RECONSTRUCTION  →  2008 · REFURBISHMENT", "Historical synthesis cue")
	check(panel.entry(&"architecture").get_meta(&"cue") == "BALANCE   ·   IONIC COLUMNS   ·   VENTILATION & PROTECTION", "Architectural summary cues")
	check(panel.entry(&"heritage").get_meta(&"cue").contains("PROVINCIAL ORDINANCE NO. 220-2018"), "Heritage protection cue")
	var copy: String = panel.content.source_credit
	for record in panel.content.concepts:
		copy += record.heading + record.body + str(record.get_meta(&"takeaway", ""))
	for required in ["AKAR Historical Information Validation Sheet", "Victory Liner", "Photographer/creator: AKAR Team", "Photo: AKAR Research Team", "Creator not identified", "permission/license status was not supplied", "reuse/permission documentation pending", "provided funds for its preservation"]:
		check(copy.contains(required), "Inherited source metadata")
	for excluded in ["Provincial " + "Cultural Treasure", "score", "points", "reward", "badge", "achievement", "leaderboard", "personality result", "best answer", "vote for", "campaign", "party affiliation", "unrestricted reuse", "public domain", "Credits to owner"]:
		check(not copy.to_lower().contains(excluded.to_lower()), "No unsupported content or assessment")
	for path in ["res://scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01.gd", "res://scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01_canvas.gd", "res://data/landmarks/pangasinan_provincial_capitol/ppc_end_01.tres"]:
		var source := FileAccess.get_file_as_string(path).to_lower()
		for excluded in ["provincial " + "cultural treasure", "all_hotspots_complete", "unlock", "view document", "view source", "view space", "return to landmark map", "FileAccess", "HTTPRequest"]:
			check(not source.contains(excluded.to_lower()), "No unsupported production feature")
	check(panel._theme_buttons[0].get_theme_stylebox("focus") != panel._theme_buttons[0].get_theme_stylebox("pressed"), "Focus distinct from selected state")
	panel.select_meaning_theme(&"heritage")
	panel.open_reflection()
	panel.toggle_narration()
	preview.hide()
	check(not panel._open and not panel.reflection_view_open and not panel._audio.playing, "Host hide resets activity")
	preview.show()
	var audio: AudioStream = panel.content.narration_stream
	panel.content.narration_stream = null
	panel.open_hotspot()
	check(panel._speaker.disabled and panel._pending.visible, "Missing audio remains graceful")
	panel.content.narration_stream = audio
	panel.close_hotspot()
	preview.queue_free()
	await settle()
	await create_timer(0.2).timeout
	print("PPC-END-01: ", checks, " checks; failures: ", failures)
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 6:
		await process_frame

func finish(panel) -> void:
	for tween in [panel._transition, panel._reflection_tween, panel._response_tween]:
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
