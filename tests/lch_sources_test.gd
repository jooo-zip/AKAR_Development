extends "res://tests/lch_header_test.gd"
## Approved reference sets plus actual modal input, scrolling and state preservation.
const REFERENCES := {
	"sande": "Sande, F. de. (1903).",
	"shutz": "Shutz, J. T. (2019).",
	"province": "Provincial Government of Pangasinan. (n.d.).",
	"martindale": "Martindale, W. (2024).",
	"lingayen2020": "Municipality of Lingayen. (2020).",
	"lingayen2025": "Municipality of Lingayen. (2025).",
	"austria2018": "Austria, H. (2018).",
	"austria2019": "Austria, H. (2019).",
	"pasiliao": "Pasiliao, J. J. (2020)."
}
const EXPECTED := {
	"ext_01": ["lingayen2020", "austria2019", "province", "martindale"],
	"ext_02": ["sande", "shutz"],
	"ext_03": ["sande", "shutz", "province", "martindale"],
	"int_01": ["sande", "shutz", "province", "martindale"],
	"int_02": ["sande", "shutz"],
	"int_03": ["austria2018", "austria2019", "lingayen2020", "lingayen2025", "pasiliao"],
	"end_01": ["sande", "shutz", "martindale", "province", "lingayen2020", "austria2018", "austria2019", "pasiliao"]
}
const URLS := {
	"sande": "https://www.gutenberg.org/cache/epub/12635/pg12635-images.html",
	"shutz": "https://doi.org/10.13185/2244-1638.1019",
	"province": "https://www.pangasinan.gov.ph/the-province/history/",
	"martindale": "https://scholarsarchive.byu.edu/asj/vol9/iss1/6",
	"lingayen2020": "https://www.lingayen.gov.ph/limahong-channel-tourism-center-soon-to-be-operational/",
	"lingayen2025": "https://www.lingayen.gov.ph/wp-content/uploads/INVITATION-TO-BID-_CONSTRUCTION-OF-MULTI-PURPOSE-BUILDING-SENIOR-CITIZEN-BUILDING-IN-LIMAHONG-TOURSIM-CENTER-BARANGAY-PANGAPISAN-NORTH.pdf",
	"austria2018": "https://www.pna.gov.ph/articles/1029395",
	"austria2019": "https://www.pna.gov.ph/articles/1071673",
	"pasiliao": "https://www.pna.gov.ph/articles/1091355"
}

func verify_content(panel, id: String) -> void:
	var text: String = panel._source_text.text
	check(panel._source_title.text == "SOURCES", id + " Sources title")
	check(text.begins_with("HISTORICAL REFERENCES\n\n") and text.count("MEDIA CREDITS") == 1, id + " standard sections")
	check(not text.to_lower().contains("validation sheet") and not text.contains("Validation Sheet"), id + " no internal validation instrument")
	check(not text.contains("http") and not text.contains("rightful owner"), id + " clean reference display")
	var urls: PackedStringArray = panel.content.get_meta("historical_source_urls")
	check(urls.size() == EXPECTED[id].size(), id + " exact URL count")
	for ref in REFERENCES:
		check(text.contains(REFERENCES[ref]) == (ref in EXPECTED[id]), id + " correct reference set: " + ref)
	for i in EXPECTED[id].size(): check(urls[i] == URLS[EXPECTED[id][i]], id + " canonical URL/order")
	match id:
		"ext_01":
			check(text.contains("Asset: lch_ext_01_channel_present\nCourtesy of the Lingayen Tourism Office.\nProvided directly to the AKAR Research Team for project use."), "Tourism Office credit, no AKAR ownership")
			check(text.contains("All other locator graphics"), "Other EXT-01 media distinguished")
		"ext_02": check(text.contains("All maps, route graphics") and text.contains("fortified-settlement graphics"), "EXT-02 own visual media credit")
		"ext_03": check(text.contains("All tactical-map graphics") and text.contains(panel.content.permanent_disclaimer), "EXT-03 media and full qualification")
		"int_01": check(text.contains("Limahong statue photograph and all interface graphics/icons"), "Statue photo project credit")
		"int_02":
			for name in ["LIMAHONG / LIN FENG", "GUIDO DE LAVEZARIS", "JUAN DE SALCEDO", "Lingayen in Time, p. 5.", "Scanned book copy used by the AKAR Research Team.", "Kahimyang.", "Jardin Solei / The Crafty Historian.", "June 7, 2020."]:
				check(text.contains(name), "Every personality image credit: " + name)
			check(not text.to_lower().contains("public domain") and not text.contains("Permission/license status:"), "No invented portrait permissions")
			check(panel.content.concepts[0].get_meta("source_url") == "https://kahimyang.com/kauswagan/articles/1705/slavery-among-the-natives-according-guido-de-lavezaris", "Lavezaris URL retained")
			check(panel.content.concepts[1].get_meta("source_url") == "https://jardinsolei.wordpress.com/2020/06/07/the-love-story-of-kandarapa-and-juan-de-salcedo-an-ill-fated-romance/comment-page-1/", "Salcedo URL retained")
		"int_03":
			for media in [panel.content.groundbreaking, panel.content.contributor_image, panel.content.present_site]:
				check(text.contains(media.source_text()), "INT-03 full existing metadata preserved")
			check(text.contains("Credit: Liwayway Yparraguirre / Philippine News Agency") and text.contains("Credit: Municipality of Lingayen") and text.contains("Credit: AKAR research team"), "INT-03 specific credit strings")
			check(text.contains("2026-07-18 11:44:09") and text.contains("Research-team captured / authorized for AKAR use"), "INT-03 exact supplied date/permission")
		"end_01": check(text.contains("All summary symbols, diagrams, icons") and not text.contains("photograph"), "Summary project graphics only")
	if id != "int_03": check(text.contains("AKAR Project / AKAR Research Team.\nOriginal project resources."), id + " project-created media identified")

func swipe(scroll: ScrollContainer) -> void:
	var origin := scroll.get_global_rect().get_center() + Vector2(0, 65)
	var event := InputEventScreenTouch.new()
	event.index = 9
	event.position = origin
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	for i in 6:
		var drag := InputEventScreenDrag.new()
		drag.index = 9
		drag.position = origin - Vector2(0, (i + 1) * 20)
		drag.relative = Vector2(0, -20)
		Input.parse_input_event(drag)
		await process_frame
	event = event.duplicate()
	event.position = origin - Vector2(0, 120)
	event.pressed = false
	Input.parse_input_event(event)
	await settle()

func sources_capture(tag: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args(): return
	await create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lch-sources-" + tag + ".png"))

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	AudioServer.set_bus_mute(0, true)
	for id in IDS:
		var folder := "exterior" if id.begins_with("ext") else ("interior" if id.begins_with("int") else "summary")
		var preview = load("res://scenes/landmarks/limahong_channel/%s/lch_%s_preview.tscn" % [folder, id]).instantiate()
		root.add_child(preview)
		await settle()
		var panel = preview.get_node("HotspotFrame").get_child(0)
		for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
			root.size = dimensions
			await settle()
			panel.open_interaction()
			await settle()
			var tag := "%s-%dx%d" % [id, dimensions.x, dimensions.y]
			var header: Array[Rect2] = geometry(panel, tag, false)
			for index in [1, 2, 0, 2]: change_content(panel, id, index)
			if id == "int_01": panel._magnifier.set_lens_normalized_position(Vector2(0.62, 0.38))
			await settle()
			var selected := state(panel)
			var audio: AudioStream = panel._audio.stream
			panel.toggle_narration()
			await create_timer(0.08).timeout
			var playback: float = panel._audio.get_playback_position()
			await activate(panel._sources_button)
			check(panel._sources.visible, tag + " mouse Sources opens")
			check(panel._sources.z_index == 3, tag + " modal draws above content")
			if id == "ext_02": check(panel._sources.z_index > panel._movement.z_index, tag + " route ship stays behind Sources")
			verify_content(panel, id)
			var bounds: Rect2 = panel.get_global_rect().grow(1)
			for control in [panel._sources, panel._source_title, panel._source_scroll, panel._source_close]:
				check(bounds.encloses(control.get_global_rect()), tag + " bounded overlay " + control.name)
			check(panel._source_close.size.y >= 48 and panel._source_text.get_theme_font_size("font_size") >= 20, tag + " readable/tappable overlay")
			check(not panel._source_scroll.get_h_scroll_bar().visible, tag + " no horizontal scrolling")
			check(panel._source_text.size.x <= panel._source_scroll.size.x, tag + " references wrap")
			check(root.gui_get_focus_owner() in [panel._source_close, panel._source_scroll], tag + " focus enters modal")
			await sources_capture(tag + "-top")
			var scroll: ScrollContainer = panel._source_scroll
			var maximum := int(scroll.get_v_scroll_bar().max_value - scroll.get_v_scroll_bar().page)
			check(maximum > 0, tag + " long references overflow internally")
			var wheel := InputEventMouseButton.new()
			wheel.position = scroll.get_global_rect().get_center()
			wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
			wheel.pressed = true
			Input.parse_input_event(wheel)
			await settle()
			check(scroll.scroll_vertical > 0, tag + " mouse wheel scrolls")
			scroll.scroll_vertical = 0
			await swipe(scroll)
			check(scroll.scroll_vertical > 0, tag + " touch swipe scrolls content")
			scroll.grab_focus()
			await key(KEY_HOME)
			check(scroll.scroll_vertical == 0, tag + " keyboard Home")
			await key(KEY_PAGEDOWN)
			check(scroll.scroll_vertical > 0, tag + " keyboard PageDown")
			await key(KEY_END)
			check(abs(scroll.scroll_vertical - maximum) <= 1, tag + " keyboard End reaches final credit")
			await sources_capture(tag + "-bottom")
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == panel._source_close, tag + " close reachable")
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() == scroll, tag + " modal focus cycle")
			await key(KEY_ESCAPE)
			check(panel._open and not panel._sources.visible and state(panel) == selected, tag + " Escape preserves hotspot state")
			check(root.gui_get_focus_owner() == panel._sources_button, tag + " logical focus restored")
			check(panel._audio.playing and panel._audio.stream == audio and panel._audio.get_playback_position() >= playback, tag + " Sources leaves narration unchanged")
			check(geometry(panel, tag + " returned", false) == header, tag + " header geometry unchanged")
			await activate(panel._sources_button, true)
			check(panel._sources.visible and scroll.scroll_vertical == 0, tag + " touch open starts at references")
			await activate(panel._source_close, true)
			check(not panel._sources.visible and state(panel) == selected, tag + " touch close preserves state")
			# Reopening each historical state must keep the same full hotspot source set.
			for index in range(5 if id == "end_01" else (4 if id == "ext_03" else 3)):
				change_content(panel, id, index)
				await settle()
				selected = state(panel)
				panel.open_sources()
				verify_content(panel, id)
				panel.close_sources()
				check(state(panel) == selected, tag + " Sources round trip state " + str(index))
			if id == "end_01":
				panel.select_topic(-1, false)
				panel.open_sources()
				panel.close_sources()
				check(panel.current_topic == -1, "Summary NONE preserved")
			await key(KEY_ESCAPE)
			check(not panel._open and not panel._audio.playing, tag + " hotspot Escape still closes/stops")
			print("Sources verified: ", tag)
		preview.queue_free()
		await settle()
	print("Limahong Sources: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)
