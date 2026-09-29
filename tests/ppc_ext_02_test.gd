extends SceneTree
## Real production scene, dispatched input, photo geometry, reset and audio isolation.
const PREVIEW := preload("res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_02_preview.tscn")
const EXPECTED := {
	&"overview": ["Look Closely at the Capitol","The Capitol's neoclassical character can be seen in its balanced façade, monumental entrance, and Ionic-order columns. Its large windows, colonnades, and projecting cornices also help the building respond to Pangasinan's tropical climate."],
	&"balance": ["A Balanced Façade","A strong central entrance anchors the extended sides of the building. Repeated openings and architectural elements create a regular rhythm across the façade."],
	&"entrance": ["Monumental Entrance","Select an architectural feature to examine."],
	&"steps": ["Broad Steps","A broad flight of steps raises the approach toward the Capitol's main entrance."],
	&"portico": ["Formal Portico","The formal portico marks the center of the façade and frames the Capitol's principal entrance."],
	&"ionic_columns": ["Ionic-Order Columns","Tall Ionic-order columns frame the main entrance and are among the defining classical features of the Capitol."],
	&"doors": ["Main Entrance Doors","Large hardwood doors form the principal entrance beneath the portico."],
	&"airflow": ["Natural Airflow","Large windows help admit natural light and air into the building."],
	&"shade": ["Shaded Colonnades","Exterior colonnades create shaded passageways and help reduce direct exposure to the sun."],
	&"rain": ["Protection from Rain","Projecting cornices and covered exterior spaces help protect walls and openings from rain."],
	&"facade_rhythm": ["REPEATED COLUMNS & WINDOWS","Repeated columns and tall window openings create a regular rhythm across the Capitol's façade. Their orderly arrangement contributes to the building's balanced and formal appearance."],
	&"entrance_composition": ["MAIN ENTRANCE COMPOSITION","Broad steps lead toward the Capitol's central entrance, framed by a formal portico, tall Ionic-order columns, large hardwood doors, and oversized windows."],
	&"pediment_relief": ["PEDIMENT & DECORATIVE RELIEF","A triangular pediment crowns the central entrance. Within it are decorative reliefs and an inscription identifying the building as the Provincial Capitol of Pangasinan."],
	&"back_entrance_passage": ["BACK ENTRANCE COLUMNED PASSAGEWAY","This columned passageway at the back entrance provides a closer view of the Capitol's sheltered exterior circulation. Exterior colonnades form shaded passageways that help protect the building from direct sun and rain."],
	&"interior_corridor": ["WIDE INTERIOR CORRIDOR","Wide corridors and high interior spaces are part of the Capitol's climate-responsive design. Together with large openings, they support the circulation of natural light and air through the building."],
}
const DETAIL_IMAGES := {
	&"facade_rhythm": "ppc_ext_02_detail_facade_rhythm.JPG",
	&"entrance_composition": "ppc_ext_02_detail_entrance.jpg",
	&"pediment_relief": "ppc_ext_02_detail_pediment.JPG",
	&"back_entrance_passage": "ppc_ext_02_detail_back_passage.JPG",
	&"interior_corridor": "ppc_ext_02_detail_corridor.jpg",
}
const CAPTIONS := {
	&"facade_rhythm": "Repeated columns and window openings along the Capitol façade.",
	&"entrance_composition": "Front entrance of the Pangasinan Provincial Capitol.",
	&"pediment_relief": "Pediment and decorative relief above the Capitol's central entrance.",
	&"back_entrance_passage": "Columned passageway at the back entrance of the Capitol.",
	&"interior_corridor": "Wide interior corridor of the Pangasinan Provincial Capitol.",
}
var checks := 0
var failures := 0
var narration_starts := 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for n in 6:
		await process_frame

func finish(panel) -> void:
	for tween in [panel._transition, panel._zoom_tween, panel._highlight_tween, panel._detail_tween]:
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

func drag(canvas: Control, touch: bool) -> void:
	var start: InputEvent = InputEventScreenTouch.new() if touch else InputEventMouseButton.new()
	start.position = canvas.global_position + Vector2(24, 38)
	if not touch:
		start.button_index = MOUSE_BUTTON_LEFT
	start.pressed = true
	Input.parse_input_event(start)
	await process_frame
	var motion: InputEvent = InputEventScreenDrag.new() if touch else InputEventMouseMotion.new()
	motion.position = canvas.global_position + Vector2(canvas.size.x - 24, 38)
	motion.relative = Vector2(canvas.size.x - 48, 0)
	if not touch:
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(motion)
	await process_frame
	start.position = motion.position
	start.pressed = false
	Input.parse_input_event(start)
	await settle()

func default_state(panel) -> void:
	check(panel.architecture_view == &"overview" and panel.balance_reveal == 0.0, "Fresh overview and zero reveal")
	check(panel.entrance_feature == &"none" and panel.climate_layer == &"airflow", "Fresh supporting state")
	check(not panel.detail_view_open and panel.detail_id == &"none" and panel.detail_origin_view == &"none", "Detail state cleared")
	check(not panel._sources.visible and not panel._audio.playing, "No modal or autoplay")
	check(panel._audio.get_playback_position() == 0.0, "Playback reset")
	check(panel._canvas.zoom == 1.0, "Full façade transform")
	check(panel._canvas.texture == panel.content.illustration, "Original full façade texture")

func layout_checks(panel, dimensions: Vector2i) -> void:
	var bounds: Rect2 = panel.get_global_rect().grow(1)
	check(Rect2(Vector2.ZERO, dimensions).encloses(panel.get_global_rect()), "Root within viewport")
	check(bounds.encloses(panel.get_node("Main").get_global_rect()), "Main does not overflow")
	check(panel._canvas.size.y >= dimensions.y * 0.36, "Architectural canvas remains dominant")
	for control in panel._all_controls():
		if control is Button and control.is_visible_in_tree():
			check(control.size.x >= 48 and control.size.y >= 48, "Touch size " + control.text)
			check(bounds.encloses(control.get_global_rect()), "Button within bounds " + control.text)
			check(control.get_minimum_size().x <= control.size.x + 1, "Button text fits " + control.text)
	var rect: Rect2 = panel._canvas.photo_rect()
	check(is_equal_approx(rect.size.x / rect.size.y, 4032.0 / 2055.0), "Photo ratio retained")
	var point: Vector2 = panel._canvas.image_point(Vector2(0.495, 0.78))
	check(point.is_equal_approx(rect.position + rect.size * Vector2(0.495, 0.78)), "Normalized overlay anchored to displayed image")
	check(panel._canvas.get_global_rect().end.y <= panel._concepts[0].global_position.y + 1, "Photo precedes modes")
	check(panel._concepts[0].get_global_rect().end.y <= panel._bottom.global_position.y + 1, "Modes precede interpretation")
	if panel.detail_view_open:
		check(panel._detail_photo.size.y >= panel.size.y * 0.60, "Detail photo dominates")
		check(panel._detail_photo.texture != null, "Documentary detail loaded")
		check(panel._detail_scroll.get_global_rect().end.y <= bounds.end.y, "Detail local scrolling contained")

func focus_checks(panel) -> void:
	var active: Array[Control] = []
	for control in panel.focus_order():
		if control.focus_mode == Control.FOCUS_ALL and control.is_visible_in_tree():
			active.append(control)
	if active.is_empty():
		check(false, "Nonempty focus order")
		return
	active[0].grab_focus()
	for i in active.size():
		check(root.gui_get_focus_owner() == active[i], "Tab reaches expected control " + str(i))
		await key(KEY_TAB)
	check(root.gui_get_focus_owner() == active[0], "Tab wraps within current context: " + str(panel.architecture_view) + " expected " + str(active[0].get_path()) + " got " + str(root.gui_get_focus_owner()))
	await key(KEY_TAB, true)
	check(root.gui_get_focus_owner() == active.back(), "Reverse tab wraps")

func capture(name: String) -> void:
	if "--capture" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var path := OS.get_environment("TEMP").path_join("ppc_ext_02_" + name + ".png")
		check(root.get_texture().get_image().save_png(path) == OK, "Rendered capture")

func _initialize() -> void:
	run.call_deferred()
	create_timer(120).timeout.connect(func(): push_error("PPC-EXT-02 test timeout"); quit(2))

func run() -> void:
	var preview := PREVIEW.instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("HotspotFrame/CapitolInteraction")
	var trigger: Button = preview.get_node("Margin/Layout/OpenHotspot")
	panel.narration_started.connect(func(): narration_starts += 1)
	check(panel.content.concepts.size() == EXPECTED.size(), "Exactly approved records")
	for id in EXPECTED:
		var record = panel.entry(id)
		check(record != null and record.heading == EXPECTED[id][0] and record.body == EXPECTED[id][1], "Exact approved copy " + id)
	check(panel.content.illustration.resource_path.ends_with("ppc_ext_01_government_today.jpeg"), "Authoritative reused image")
	check(panel.content.narration_stream is AudioStreamOggVorbis, "Real Vorbis audio")
	check(panel.content.narration_stream.get_length() > 1, "Audio decodes with nonzero duration")
	print("PPC-EXT-02 narration length: ", panel.content.narration_stream.get_length())
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		root.content_scale_size = Vector2i.ZERO
		panel.close_hotspot()
		trigger.grab_focus()
		panel.open_hotspot()
		await finish(panel)
		default_state(panel)
		layout_checks(panel, dimensions)
		await focus_checks(panel)
		await capture(str(dimensions.x) + "_overview")
		await pointer(panel._speaker, true)
		check(panel._audio.playing, "Touch starts narration")
		var starts_before := narration_starts
		var position_before: float = panel._audio.get_playback_position()
		await pointer(panel._concepts[0], true)
		await finish(panel)
		check(panel.architecture_view == &"balance", "Touch enters Balance")
		check(panel._canvas.image_point(Vector2(0.495, 0.29)).y >= 52, "Reveal rail stays above the architecture")
		check(panel._canvas.photo_rect().size.y >= panel._canvas.size.y - 1, "Reveal does not shrink the façade photo")
		await drag(panel._canvas, true)
		check(is_equal_approx(panel.balance_reveal, 1.0), "Touch drag reaches reveal limit")
		await drag(panel._canvas, false)
		check(is_equal_approx(panel.balance_reveal, 1.0), "Mouse drag reaches reveal limit")
		panel._canvas.grab_focus()
		for n in 3:
			await key(KEY_LEFT)
		check(is_equal_approx(panel.balance_reveal, 0.7), "Keyboard reveal increments")
		for n in 15:
			await key(KEY_RIGHT)
		check(panel.balance_reveal == 1.0, "Reveal upper bound")
		for n in 15:
			await key(KEY_LEFT)
		check(panel.balance_reveal == 0.0, "Reveal lower bound")
		for n in 7:
			await key(KEY_RIGHT)
		await focus_checks(panel)
		await capture(str(dimensions.x) + "_balance")
		await pointer(panel._concepts[1])
		await finish(panel)
		check(panel.architecture_view == &"entrance" and panel.entrance_feature == &"none", "Mouse entrance starts unselected")
		check(is_equal_approx(panel._canvas.zoom, 1.32), "Moderate entrance crop")
		for i in panel.FEATURES.size():
			await pointer(panel._feature_buttons[i], true)
			check(panel.entrance_feature == panel.FEATURES[i], "Touch feature")
			check(panel._heading.text == EXPECTED[panel.FEATURES[i]][0] and panel._body.text == EXPECTED[panel.FEATURES[i]][1], "Selected feature copy")
			check(panel._canvas.feature == panel.entrance_feature, "Overlay matches feature")
		panel.select_entrance_feature(&"steps")
		panel.select_entrance_feature(&"portico")
		panel.select_entrance_feature(&"ionic_columns")
		await finish(panel)
		check(panel.entrance_feature == &"ionic_columns" and panel._canvas.highlight_alpha == 1.0, "Latest feature wins")
		layout_checks(panel, dimensions)
		await focus_checks(panel)
		await capture(str(dimensions.x) + "_entrance")
		await pointer(panel._concepts[2], true)
		for i in panel.LAYERS.size():
			await pointer(panel._layer_buttons[i], i != 1)
			await finish(panel)
			check(panel.climate_layer == panel.LAYERS[i] and panel._canvas.layer == panel.LAYERS[i], "Climate layer input")
			check(panel._body.text == EXPECTED[panel.LAYERS[i]][1], "Climate copy")
			layout_checks(panel, dimensions)
			await capture(str(dimensions.x) + "_" + panel.LAYERS[i])
		await focus_checks(panel)
		panel.select_architecture_view(&"balance")
		check(is_equal_approx(panel.balance_reveal, 0.7), "Reveal preserved between modes")
		panel.select_architecture_view(&"entrance")
		check(panel.entrance_feature == &"ionic_columns", "Entrance memory")
		panel.select_architecture_view(&"climate")
		check(panel.climate_layer == &"rain", "Climate memory")
		panel.select_architecture_view(&"balance")
		panel.select_architecture_view(&"entrance")
		panel.select_architecture_view(&"climate")
		await finish(panel)
		check(panel.architecture_view == &"climate" and panel._canvas.mode == &"climate" and panel._canvas.zoom == 1.0, "Rapid modes retain latest state and transform")
		panel._full.grab_focus()
		await key(KEY_ENTER)
		check(panel.architecture_view == &"overview", "Keyboard Full Façade")
		panel._concepts[1].grab_focus()
		await key(KEY_SPACE)
		panel._feature_buttons[0].grab_focus()
		await key(KEY_ENTER)
		check(panel.architecture_view == &"entrance" and panel.entrance_feature == &"steps", "Keyboard mode and feature")
		panel._concepts[2].grab_focus()
		await key(KEY_ENTER)
		panel._layer_buttons[1].grab_focus()
		await key(KEY_SPACE)
		check(panel.climate_layer == &"shade", "Keyboard climate layer")
		for id in panel.DETAILS:
			if id == &"facade_rhythm":
				panel.select_architecture_view(&"balance")
			elif id in [&"entrance_composition", &"pediment_relief"]:
				panel.select_architecture_view(&"entrance")
			else:
				panel.select_architecture_view(&"climate")
				panel.select_climate_layer(&"shade" if id == &"back_entrance_passage" else &"airflow")
			await finish(panel)
			var origin: StringName = panel.architecture_view
			var state := [panel.balance_reveal, panel.entrance_feature, panel.climate_layer]
			var button: Button = panel._detail_buttons[id]
			await pointer(button, true)
			await finish(panel)
			check(panel.detail_view_open and panel.detail_id == id and panel.detail_origin_view == origin, "Detail state " + id)
			check(panel._detail_photo.texture.resource_path.ends_with(DETAIL_IMAGES[id]), "Correct detail image " + id)
			check(panel._detail_heading.text == EXPECTED[id][0] and panel._detail_body.text == EXPECTED[id][1], "Correct detail copy")
			check(panel._detail_caption.text == CAPTIONS[id] + "\nPhoto: AKAR Research Team", "Exact caption and credit")
			check(root.gui_get_focus_owner() == panel._detail_close, "Detail initial focus")
			panel.select_architecture_view(&"overview")
			panel.select_entrance_feature(&"doors")
			panel.select_climate_layer(&"rain")
			panel.open_sources()
			check(panel.architecture_view == origin and not panel._sources.visible, "No background actions or stacked modal")
			check([panel.balance_reveal, panel.entrance_feature, panel.climate_layer] == state, "Detail preserves all substates")
			layout_checks(panel, dimensions)
			await focus_checks(panel)
			await capture(str(dimensions.x) + "_" + id)
			await key(KEY_ESCAPE)
			await finish(panel)
			check(not panel.detail_view_open and panel.architecture_view == origin, "Escape restores origin")
			check(root.gui_get_focus_owner() == button, "Detail restores exact focus")
			button.grab_focus()
			await key(KEY_ENTER)
			check(panel.detail_view_open, "Enter opens detail")
			panel._detail_close.grab_focus()
			await key(KEY_SPACE)
			await finish(panel)
			check(not panel.detail_view_open and root.gui_get_focus_owner() == button, "Space closes detail")
			button.grab_focus()
			await key(KEY_SPACE)
			check(panel.detail_view_open, "Space opens detail")
			await pointer(panel._detail_close)
			await finish(panel)
			check(not panel.detail_view_open, "Mouse closes detail")
		check(panel._audio.playing and narration_starts == starts_before and panel._audio.get_playback_position() >= position_before, "Narration uninterrupted by all modes and details")
		var before_sources := [panel.architecture_view, panel.balance_reveal, panel.entrance_feature, panel.climate_layer]
		await pointer(panel._sources_button)
		check(panel._sources.visible, "Sources opens")
		panel.select_architecture_view(&"balance")
		check(before_sources == [panel.architecture_view, panel.balance_reveal, panel.entrance_feature, panel.climate_layer], "Sources preserves and blocks state")
		await focus_checks(panel)
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel._open, "Escape Sources only")
		check(root.gui_get_focus_owner() == panel._sources_button, "Sources focus restore")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(panel.architecture_view == &"overview" and panel._open, "Escape mode to overview")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel._open and not panel.visible, "Escape overview closes")
		default_state(panel)
		check(root.gui_get_focus_owner() == trigger, "Launcher focus restored")
		check(panel._scroll.scroll_vertical == 0 and panel._source_scroll.scroll_vertical == 0, "Scroll reset")
		panel.open_hotspot()
		default_state(panel)
		panel.select_architecture_view(&"entrance")
		for attempt in 8:
			panel.open_architectural_detail(&"pediment_relief")
			var opening: Tween = panel._detail_tween
			panel.close_architectural_detail()
			check(not opening.is_valid(), "Close cancels open tween")
			panel.open_architectural_detail(&"entrance_composition")
			panel.select_architecture_view(&"balance")
			check(panel.detail_id == &"pediment_relief" and panel.architecture_view == &"entrance", "Closing fade blocks underlying mutation")
			await finish(panel)
		check(panel.find_children("ArchitecturalDetail", "PanelContainer", false, false).size() == 1, "One detail viewer")
		panel.open_architectural_detail(&"pediment_relief")
		panel.close_hotspot()
		panel.open_hotspot()
		await finish(panel)
		default_state(panel)
	panel.select_architecture_view(&"entrance")
	panel.open_architectural_detail(&"entrance_composition")
	panel.toggle_narration()
	preview.hide()
	check(not panel._open and not panel.detail_view_open and not panel._audio.playing, "Host hide cleans activity")
	preview.show()
	var audio: AudioStream = panel.content.narration_stream
	panel.content.narration_stream = null
	panel.open_hotspot()
	check(panel._speaker.visible and panel._speaker.disabled and panel._pending.visible, "Missing audio fallback")
	panel.content.narration_stream = audio
	var visitor_copy: String = panel.content.title + panel.content.prompt
	for record in panel.content.concepts:
		visitor_copy += record.heading + record.body + str(record.get_meta(&"note"))
	for excluded in ["score", "points", " XP ", "reward", "achievement", "level", "unlock", "locked", "completion", "eagle", "shield", "shells", "wreath", "emblem", "pilaster", "Maramba", "WWII", "restoration", "Governor's Office", "Session Hall"]:
		check(not visitor_copy.to_lower().contains(excluded.to_lower()), "Excluded unsupported claim/feature " + excluded)
	check(not panel.entry(&"facade_rhythm").body.contains("Ionic"), "Side detail uses columns terminology")
	check(not panel.entry(&"back_entrance_passage").body.contains("principal entrance") and not panel.entry(&"back_entrance_passage").body.contains("main entrance"), "Back entrance terminology")
	check(panel.content.source_credit.contains("HISTORICAL / ARCHITECTURAL REFERENCES") and panel.content.source_credit.contains("DOCUMENTARY MEDIA"), "Categorized sources")
	panel.close_hotspot()
	preview.queue_free()
	await settle()
	await create_timer(0.2).timeout
	print("PPC-EXT-02: ", checks, " checks; failures: ", failures)
	quit(1 if failures else 0)
