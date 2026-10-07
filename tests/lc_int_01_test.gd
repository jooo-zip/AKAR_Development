extends SceneTree
## Dispatched input and rendered layout regression for the actual F6 component.

const NAMES := ["Bishop César María Guerrero", "Archbishop Mariano A. Madriaga", "Father Samuel Sheehan", "Father Dermot Feeny"]
const ROLES := ["First Bishop of Lingayen", "Wartime & Postwar Leadership", "Columban Missionary Service", "Wartime Service & Recovery"]
const HEADINGS := ["Establishing Episcopal Leadership", "Leadership Through War and Reconstruction", "Beginning the Columban Mission", "Serving Through War and Recovery"]
const BODIES := [
	"César María Guerrero became the first Bishop of Lingayen. He was consecrated on May 24, 1929 and served as bishop until December 16, 1937.",
	"Mariano A. Madriaga led the jurisdiction during the Second World War and postwar period. In 1963, he became the first Metropolitan Archbishop of Lingayen-Dagupan.",
	"Father Samuel Sheehan was the first Columban priest identified as arriving in Lingayen in 1933 and helped coordinate the early Columban mission.",
	"Father Dermot Feeny served as parish priest during the wartime period and was associated with postwar reconstruction efforts."
]
const CONNECTIONS := [
	"His episcopate belongs to the period when Lingayen Church served as the cathedral and episcopal center of the Diocese of Lingayen.",
	"His leadership connects the church's wartime recovery with the later development of the archdiocese.",
	"His arrival marked the beginning of the Columban missionary presence in the parish.",
	"His parish service connects him with the church's wartime experience and the recovery that followed."
]
const SOURCE_LINES := [
	"Source: Archdiocese of Lingayen-Dagupan · Portrait: Lingayen: Memories of Times Past (2021), p. 16",
	"Source: Archdiocese of Lingayen-Dagupan · Portrait: Lingayen: Memories of Times Past (2021), p. 17",
	"Source: Epiphany of Our Lord Parish history · Image: Missionary Society of St. Columban — Philippines",
	"Source: Epiphany of Our Lord Parish history · Image: Missionary Society of St. Columban — Philippines"
]
const CREDITS := ["SOURCE: Lingayen: Memories of Times Past (2021), p. 16.", "SOURCE: Lingayen: Memories of Times Past (2021), p. 17.", "IMAGE SOURCE: Missionary Society of St. Columban — Philippines", "IMAGE SOURCE: Missionary Society of St. Columban — Philippines"]
const IDS := ["guerrero", "madriaga", "sheehan", "feeny"]
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
	for tween in [panel._panel_tween, panel._fade]:
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


func press(control: Control, touch: bool = false, corner: bool = false) -> void:
	var event: InputEvent
	if touch:
		event = InputEventScreenTouch.new()
	else:
		event = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
	event.position = control.global_position + (Vector2(5, 5) if corner else control.size * 0.5)
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await settle()


func capture(label: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lc_int_01_" + label + ".png")) == OK, "Capture " + label)


func check_state(panel: Control, selected: int) -> void:
	check(panel.selected_person == selected, "Authoritative person state")
	for i in 4:
		var entry: LCINT01PersonContent = panel.content.people[i]
		check(entry.person_id == IDS[i] and entry.display_name == NAMES[i], "Exactly four specified personalities, correct order")
		check(entry.short_role == ROLES[i] and entry.detail_heading == HEADINGS[i], "Exact role and heading")
		check(entry.body == BODIES[i] and entry.parish_connection == CONNECTIONS[i], "Exact historical text and connection")
		check(entry.image_credit == CREDITS[i], "Exact credit")
		check(entry.compact_source_line == SOURCE_LINES[i], "Exact revised source line")
		check(panel._cards[i].button_pressed == (selected == i + 1), "Exclusive selection; NONE selects no card")
		check(panel._cards[i].accessibility_name.contains(NAMES[i]) and panel._cards[i].accessibility_name.contains(ROLES[i]), "Full accessible name and role")
		check(panel._cards[i].accessibility_description == ("Selected" if selected == i + 1 else "Select to read parish connection"), "Accessible selected state")
		check(panel._cards[i].portrait.texture == entry.portrait, "Correct portrait binding")
		check(entry.portrait.resource_path.ends_with("lc_int_01_" + IDS[i] + "_portrait.png"), "User-approved unchanged PNG reference")
	check(panel._prompt.text == "Select a portrait to discover how each person was connected with Lingayen Church.", "Exact prompt")
	check(panel._takeaway.text == "Lingayen Church's history was shaped by bishops and missionaries who guided the parish through major periods of change.", "Exact concise takeaway")
	if selected == 0:
		check(panel._heading.text == "People Across the Parish's History", "Overview heading")
		check(panel._body.text == "Bishops and missionaries helped guide Lingayen Church through major periods of cathedral leadership, missionary service, war, and postwar recovery.", "Concise overview body")
		for label in [panel._role, panel._connection, panel._connection_label, panel._source_line]:
			check(not label.visible and label.text.is_empty(), "No stale person metadata in overview")
	else:
		check(panel._role.text == ROLES[selected - 1] and panel._heading.text == HEADINGS[selected - 1], "Selected role and heading")
		check(panel._body.text == BODIES[selected - 1] and panel._connection.text == CONNECTIONS[selected - 1], "Selected history and parish connection")
		check(panel._connection_label.text == "Connection to Lingayen Church", "Separate connection heading")
		check(panel._source_line.text == SOURCE_LINES[selected - 1], "One combined source/portrait line")
		var source_labels: int = 0
		for child in panel._body.get_parent().get_children():
			if child is Label and child.visible and (child.text.begins_with("Source") or child.text.begins_with("SOURCE:") or child.text.begins_with("IMAGE SOURCE:")):
				source_labels += 1
		check(source_labels == 1, "No duplicate visitor-facing provenance labels")
	for i in 4:
		var primary: bool = i == [-1, 0, 2, 1, 2][selected]
		var secondary: bool = selected == 2 and i == 3
		check(panel._anchor_labels[i].text == String(panel.ANCHORS[i]), "Anchor labels contain no hierarchy/completion wording")
		var style: StyleBoxFlat = panel._anchor_markers[i].get_theme_stylebox("panel")
		var expected_color := Color("e8d5b4") if primary else (Color("d37148") if secondary else Color("d6c5ab"))
		check(panel._anchor_labels[i].get_theme_color("font_color") == expected_color, "Distinct primary/secondary/neutral text colors")
		check(style.draw_center == not secondary and style.border_width_left == (2 if secondary else 0), "Secondary outline distinct from primary fill")
		check(panel._anchor_markers[i].size == Vector2.ONE * (12 if primary or secondary else 6), "Active markers larger than neutral markers")
		check(style.border_color == expected_color and style.bg_color == expected_color, "Marker colors match historical connection state")
		check(panel._anchor_markers[i].focus_mode == Control.FOCUS_NONE and panel._anchor_markers[i].mouse_filter == Control.MOUSE_FILTER_IGNORE, "Markers passive")
		check(panel._anchor_labels[i].focus_mode == Control.FOCUS_NONE and panel._anchor_labels[i].mouse_filter == Control.MOUSE_FILTER_IGNORE, "Anchors passive, not navigation")
	if selected == 2:
		check(panel._anchor_labels[3].get_theme_color("font_color") != panel._anchor_labels[0].get_theme_color("font_color"), "Madriaga 1963 is NOT neutral")
		var secondary_style: StyleBoxFlat = panel._anchor_markers[3].get_theme_stylebox("panel")
		var primary_style: StyleBoxFlat = panel._anchor_markers[2].get_theme_stylebox("panel")
		check(not secondary_style.draw_center and secondary_style.border_width_left == 2 and primary_style.draw_center, "Madriaga: 1963 gold ring, WAR / POSTWAR filled gold")
	check(panel._speaker.visible and panel._speaker.disabled == (panel._audio.stream == null) and panel._pending.visible == (panel._audio.stream == null) and panel._pending.text == "Narration pending.", "Shared LISTEN pending")
	check(not panel._audio.playing and panel._audio.stream == panel.content.narration_stream, "No autoplay or stale narration")
	check(panel._speaker.focus_mode == (Control.FOCUS_NONE if panel._speaker.disabled or panel._sources.visible else Control.FOCUS_ALL), "LISTEN focus follows availability")
	check(not panel.has_node("Transcript"), "No transcript UI")
	var visible_copy: String = panel._body.text + panel._connection.text + panel._source_text.text
	for excluded in ["Gallagher", "Surname spelling", "Reuse/permission", "museum approved", "officially validated"]:
		check(not visible_copy.contains(excluded), "Internal/unsupported content not shown: " + excluded)


func check_layout(panel: Control, dimensions: Vector2i) -> void:
	var bounds: Rect2 = panel.get_global_rect().grow(0.2)
	check(Rect2(Vector2.ZERO, Vector2(dimensions)).grow(0.2).encloses(bounds.grow(-0.2)), "Panel inside viewport")
	check(bounds.encloses(panel.get_node("Main").get_global_rect()), "No whole-screen overflow")
	for control in [panel._wall, panel._scroll, panel._takeaway, panel._prompt, panel._anchor_strip, panel._title, panel._speaker, panel._pending, panel._close]:
		check(bounds.encloses(control.get_global_rect()), "Shell control contained: " + control.name)
	check(panel._title.get_global_rect().end.x <= panel._speaker.global_position.x, "Header no overlap")
	check(panel._speaker.get_global_rect().end.x <= panel._close.global_position.x, "Listen/Close no overlap")
	var ratio: float = panel._wall.size.x / (panel._wall.size.x + panel._information.size.x)
	check(absf(ratio - (0.44 if dimensions.x == 854 else 0.52)) < 0.02, "Responsive wall/detail split")
	for i in 4:
		var card: LCINT01PersonCard = panel._cards[i]
		check(panel._wall.get_global_rect().grow(0.2).encloses(card.get_global_rect()), "Card fits 2x2 wall")
		check(card.size.x >= 150 and card.size.y >= 90, "Large portrait target: %s" % card.size)
		check(card.get_global_rect().grow(-3).encloses(card.name_label.get_global_rect()) and card.get_global_rect().grow(-3).encloses(card.role_label.get_global_rect()), "Name/role fully contained: %s" % card.name)
		check(card.portrait.size.x >= 40 and card.portrait.size.y >= 70, "Portrait remains visible")
		check(card.portrait.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Documentary aspect ratio preserved")
		check(card.get_theme_stylebox("focus") != card.get_theme_stylebox("pressed"), "Focus distinct from selection")
		for j in range(i + 1, 4):
			check(not card.get_global_rect().intersects(panel._cards[j].get_global_rect()), "Cards do not overlap")
	check(panel._cards[0].position.y == panel._cards[1].position.y and panel._cards[2].position.y == panel._cards[3].position.y and panel._cards[2].position.y > panel._cards[0].position.y, "Spatial 2x2 relationship")
	for control in [panel._sources_button, panel._speaker, panel._close, panel._source_close]:
		if control.is_visible_in_tree():
			check(control.size.y >= (52 if control in [panel._speaker, panel._close, panel._sources_button] else 56), "56 px shared control")
	if dimensions.x == 1280:
		check(not panel._scroll.get_v_scroll_bar().visible, "Reference-size details fit without reading scroll: %s / %s" % [panel._body.get_parent().size, panel._scroll.size])
		if panel.selected_person != 0:
			check(panel._scroll.get_global_rect().grow(0.2).encloses(panel._source_line.get_global_rect()), "Reference-size source line fully visible")
	for marker in panel._anchor_markers:
		check(bounds.encloses(marker.get_global_rect()), "Historical marker visible within panel")
	check(panel._scroll.size.y >= 180, "Usable compact reading viewport: %s" % panel._scroll.size)


func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	Input.emulate_mouse_from_touch = true
	var preview: Control = load("res://scenes/landmarks/lingayen_church/interior/lc_int_01_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel: Control = preview.get_node("HotspotFrame/ChurchInteraction")
	panel.content = panel.content.duplicate(true)
	panel.close_requested.connect(func() -> void: close_count += 1)
	var trigger: Button = preview.get_node("Margin/Layout/OpenArtwork")
	check(trigger.text == "Meet the People", "Neutral preview trigger")
	check(panel.content.people.size() == 4, "Four people only")
	check(panel.content.people[3].internal_validation_note == "Surname spelling should be reconfirmed using parish or Columban records.", "Feeny validation metadata retained")
	for source in ["Archdiocese of Lingayen-Dagupan", "The Archbishops", "A Brief History of the Epiphany of Our Lord Parish", "Lingayen: Memories of Times Past (2021)", "Guerrero portrait: p. 16", "Madriaga portrait: p. 17", "Missionary Society of St. Columban — Philippines", "Samuel Sheehan portrait/image source", "Dermot Feeny portrait/image source"]:
		check(panel.content.sources_text.contains(source), "Required source entry: " + source)
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		await capture("%d_preview" % dimensions.x)
		await press(trigger)
		await finish(panel)
		check_state(panel, 0)
		check_layout(panel, dimensions)
		check(root.gui_get_focus_owner() == panel._cards[0], "Deterministic initial focus")
		await capture("%d_overview" % dimensions.x)
		for i in 4:
			await press(panel._cards[i], false, true)
			await finish(panel)
			check_state(panel, i + 1)
			check_layout(panel, dimensions)
			await capture("%d_%s" % [dimensions.x, IDS[i]])
			if dimensions.x < 1280:
				panel._scroll.grab_focus()
				await key(KEY_END)
				check(panel._scroll.get_global_rect().grow(0.2).encloses(panel._source_line.get_global_rect()), "Compact source line fully reachable by internal scroll")
				if i == 1:
					await capture("%d_madriaga_details" % dimensions.x)
				panel._scroll.scroll_vertical = 0
				await settle()
		# Spatial focus moves without selecting, and clamps at every outside edge.
		for i in 4:
			for direction in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]:
				panel._cards[i].grab_focus()
				var target: int = i
				if direction == KEY_LEFT and i % 2 == 1: target -= 1
				if direction == KEY_RIGHT and i % 2 == 0: target += 1
				if direction == KEY_UP and i >= 2: target -= 2
				if direction == KEY_DOWN and i < 2: target += 2
				await key(direction)
				check(root.gui_get_focus_owner() == panel._cards[target] and panel.selected_person == 4, "Spatial arrows focus only, including boundaries")
		panel._cards[0].grab_focus()
		await key(KEY_ENTER)
		await finish(panel)
		check_state(panel, 1)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._cards[1], "Tab moves through cards")
		await key(KEY_SPACE)
		await finish(panel)
		check_state(panel, 2)
		panel._cards[3].grab_focus()
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._scroll, "Tab skips disabled LISTEN")
		await key(KEY_END)
		check(panel._scroll.scroll_vertical > 0 or not panel._scroll.get_v_scroll_bar().visible, "Keyboard reading scroll")
		await press(panel._sources_button)
		check(panel._sources.visible and root.gui_get_focus_owner() == panel._source_close, "Sources opens with modal focus")
		check(panel._source_text.text == panel.content.sources_text, "Full references retained inside Sources")
		check_state(panel, 2)
		await capture("%d_sources" % dimensions.x)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._source_scroll, "Sources traps focus")
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel.visible and close_count == (0 if dimensions.x == 1280 else (1 if dimensions.x == 960 else 2)), "Escape closes Sources first")
		check_state(panel, 2)
		check(root.gui_get_focus_owner() == panel._sources_button, "Sources returns focus")
		await press(panel._sources_button, true)
		check(panel._sources.visible, "Synthetic touch opens Sources")
		await press(panel._source_close, true)
		check(not panel._sources.visible and panel.selected_person == 2, "Synthetic touch closes Sources without changing person")
		for state in [1, 4, 3, 2, 1]:
			panel.set_selected_person(state)
		await finish(panel)
		check_state(panel, 1)
		check(panel._scroll.scroll_vertical == 0 and is_equal_approx(panel._information.modulate.a, 1.0), "Rapid switch cancels stale fade and resets reading")
		for state in [2, 1, 4, 2, 3, 2]:
			panel.set_selected_person(state)
		await finish(panel)
		check_state(panel, 2)
		check(panel._scroll.scroll_vertical == 0 and is_equal_approx(panel._information.modulate.a, 1.0), "Revised rapid switch ends with settled Madriaga")
		for i in 4:
			await press(panel._cards[i], true, true)
			await finish(panel)
			check_state(panel, i + 1)
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel.visible and not panel._open and not panel._audio.playing, "Escape closes hotspot and stops narration")
		check(root.gui_get_focus_owner() == trigger, "Close restores preview trigger focus")
		print("LC-INT-01 input/layout passed at ", dimensions)
	# Null portrait uses only its own name/role and an explicit neutral placeholder.
	await press(trigger)
	await finish(panel)
	check_state(panel, 0)
	for i in 4:
		var original: Texture2D = panel.content.people[i].portrait
		panel.content.people[i].portrait = null
		panel._resize_layout()
		await settle()
		check(panel._cards[i].placeholder.visible and panel._cards[i].portrait.texture == null, "Safe missing portrait fallback")
		check(panel._cards[i].placeholder.text == "Portrait source pending" and panel._cards[i].name_label.text == NAMES[i] and panel._cards[i].role_label.text == ROLES[i], "Fallback retains name and historical role")
		var card: LCINT01PersonCard = panel._cards[i]
		check(card.get_global_rect().encloses(card.name_label.get_global_rect()) and card.get_global_rect().encloses(card.role_label.get_global_rect()), "Compact fallback text contained")
		check(card.role_label.get_global_rect().end.y <= card.placeholder.global_position.y, "Fallback status separate from role: " + IDS[i])
		await capture("854_fallback_" + IDS[i])
		panel.content.people[i].portrait = original
	panel._resize_layout()
	# One overall hotspot narration remains continuous across person selections.
	var clip := AudioStreamWAV.new()
	clip.mix_rate = 44100
	clip.data = PackedByteArray()
	var silence := PackedByteArray()
	silence.resize(44100 * 2)
	clip.data = silence
	var original_narration: AudioStream = panel.content.narration_stream
	panel.content.narration_stream = clip
	panel.set_selected_person(1)
	check(not panel._speaker.disabled and panel._audio.stream == clip, "Overall hotspot narration binding")
	await press(panel._speaker)
	check(panel._audio.playing, "LISTEN starts overall audio")
	panel.set_selected_person(2)
	check(panel._audio.playing and panel._audio.stream == clip, "Overall narration persists across people")
	panel.set_selected_person(1)
	panel.toggle_narration()
	panel.close_interaction()
	check(not panel._audio.playing, "Close immediately stops audio")
	panel.content.narration_stream = original_narration
	panel.open_hotspot()
	await finish(panel)
	check_state(panel, 0)
	check(not panel._closing and panel.modulate.a == 1.0, "Reopening during close cancels stale callback")
	panel.open_sources()
	panel.reset_hotspot()
	await finish(panel)
	check_state(panel, 0)
	check(not panel._sources.visible and root.gui_get_focus_owner() == panel._cards[0], "Reset closes Sources and restores focus")
	panel.open_sources()
	await settle()
	await press(panel._source_close)
	check(not panel._sources.visible, "Mouse closes Sources")
	await press(panel._close)
	await finish(panel)
	check(not panel._open and root.gui_get_focus_owner() == trigger, "Mouse Close and return focus")
	await press(trigger)
	await finish(panel)
	await press(panel._close, true)
	await finish(panel)
	check(not panel._open, "Synthetic touch Close")
	await press(trigger)
	await finish(panel)
	preview.get_node("HotspotFrame").hide()
	await settle()
	check(not panel._open and not panel._audio.playing, "Parent hide cleans up")
	preview.queue_free()
	await settle()
	print("LC-INT-01: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
