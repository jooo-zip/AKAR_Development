extends SceneTree
## Logical landscape sizing and real dispatched mouse, keyboard and touch events.

var failures: int = 0
var close_count: int = 0
const IMAGE_PATH := "res://assets/landmarks/lingayen_church/lc_ext_02/images/"
const HEADINGS := ["Look Closely at the Bell Tower", "A Tall, Tiered Tower", "A Pagoda-Like Profile", "Part of the Church's Present Form"]
const BODIES := [
	"Lingayen Church is distinguished by a tall, tiered bell tower commonly described as pagoda-like. Select a marker to examine its visible form and relationship to the church.",
	"The bell tower rises prominently beside the main church structure. Its form is divided into several visible levels or tiers, giving the tower a strong vertical presence.",
	"The tower's stacked and narrowing form creates a distinctive silhouette commonly described as pagoda-like.",
	"The tower stands as a prominent part of the church's exterior composition. Because Lingayen Church experienced major wartime damage and later reconstruction, the present structure reflects different periods of architectural development."
]

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

func check_observation(panel: Control, state: int) -> void:
	check(panel.get_observation() == state, "Authoritative observation %d" % state)
	check(panel._heading.text == HEADINGS[state] and panel._body.text == BODIES[state], "Exact approved heading/body %d" % state)
	check(panel._takeaway.text == "The bell tower's tiered, pagoda-like form is one of the most recognizable features of Lingayen Church.", "Exact takeaway")
	check(panel._prompt.visible == (state == 0), "Overview-only prompt")
	check(panel._focus_overlay.visible == (state != 0), "Focus overlay visibility")
	check(panel._detail_holder.visible == (state != 0), "Detail visibility")
	for i in 3:
		check(panel._concepts[i].visible and panel._concepts[i].button_pressed == (state == i + 1), "All markers visible, exactly one selected")
	if state == 0:
		check(panel._detail.texture == null and panel._focus_region == Rect2(), "Overview clears detail/focus")
	else:
		var entry = panel.content.concepts[state]
		var region: Rect2 = entry.focus_rect
		check(panel._focus_region.is_equal_approx(region), "Correct normalized focus region")
		check(panel._focus_overlay.position.is_equal_approx(region.position * panel._viewer.size), "Focus position follows fitted image")
		check(panel._focus_overlay.size.is_equal_approx(region.size * panel._viewer.size), "Focus dimensions follow fitted image")
		check(panel._viewer.get_global_rect().grow(0.1).encloses(panel._focus_overlay.get_global_rect()), "Focus remains within image")
		if state == 1:
			check(panel._detail.texture == load(IMAGE_PATH + "lc_ext_02_detail_overall_form.jpg"), "Overall Form detail asset")
		elif state == 2:
			check(panel._detail.texture == load(IMAGE_PATH + "lc_ext_02_detail_tiered_silhouette.JPG"), "Tiered Silhouette case-sensitive asset")
		else:
			check(panel._detail.texture is AtlasTexture, "Non-destructive Tower & Church crop")
			check(panel._detail.texture.atlas == panel.content.illustration, "Crop uses original main photo")
			check(panel._detail.texture.region == Rect2(160, 1920, 2680, 1080), "Tower and adjoining church crop pixels")
		check(panel._detail.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Detail aspect preserved")
	check(not panel._outgoing_detail.visible and is_equal_approx(panel._detail.modulate.a, 1.0), "Crossfade settles without stale image")
	for text in [panel._heading.text, panel._body.text, panel._takeaway.text]:
		for excluded in ["1587", "1710", "Chinese architecture", "Chinese design", "Chinese influence", "Asian architecture", "original Spanish tower", "original tower", "prewar tower", "surviving tower", "Spanish-era tower", "1928", "1954", "Columbans"]:
			check(not text.contains(excluded), "Unsupported wording excluded: " + excluded)

func check_layout(panel: Control, dimensions: Vector2i) -> void:
	check(panel.get_global_rect().encloses(panel.get_node("Main").get_global_rect()), "No whole-panel overflow")
	check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(panel.get_global_rect()), "Panel fits viewport")
	check(panel._speaker.get_global_rect().end.x <= panel._close.global_position.x, "Header controls separated")
	check(panel._title.get_global_rect().end.x <= panel._speaker.global_position.x, "Title clear of controls")
	check(not panel._pending.visible or panel._pending.global_position.y >= panel._speaker.get_global_rect().end.y, "Narration status associated with Listen")
	check(is_equal_approx(panel._viewer.size.x / panel._viewer.size.y, 4.0 / 3.0), "Main image full 4:3 aspect")
	check(panel._viewer.size.x >= 300 and panel._viewer.size.y >= 225, "Usable main photograph")
	var media_share: float = panel._media.size.x / (panel._media.size.x + panel._information.size.x)
	check(absf(media_share - 0.6) < 0.02, "60/40 image-dominant columns")
	check(panel._scroll.size.y >= 130, "Readable internal scroll area")
	check(panel._credit.get_line_count() == 1, "Photo credit fits")
	for control in [panel._speaker, panel._close, panel._sources_button, panel._credit, panel._pending, panel._caption, panel._legend]:
		check(panel.get_global_rect().grow(0.1).encloses(control.get_global_rect()), "Shell content within panel: " + control.name)
	for control in [panel._speaker, panel._close, panel._sources_button] + panel._concepts:
		check(control.size.y >= (52 if control in [panel._speaker, panel._close, panel._sources_button] else 56), "56 px target")
	for i in 3:
		var marker: Button = panel._concepts[i]
		var center: Vector2 = marker.position + marker.size * 0.5
		check(center.is_equal_approx(panel.content.concepts[i + 1].marker_position * panel._viewer.size), "Image-relative marker center")
		check(marker.size.is_equal_approx(Vector2(56, 56)), "Marker full hit area: %s" % marker.size)
		check(panel._badges[i].size == Vector2(34, 34), "Compact numbered symbol")
		check(panel._viewer.get_global_rect().encloses(marker.get_global_rect()), "Hit target within image")
		check(marker.accessibility_name == panel.content.concepts[i + 1].label, "Accessible marker name")
		check(marker.get_theme_stylebox("focus") != panel._marker_selected, "Focus distinct from selection")
		for j in range(i + 1, 3):
			check(not marker.get_global_rect().intersects(panel._concepts[j].get_global_rect()), "Marker hit areas do not overlap")

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	root.content_scale_size = Vector2i(1280, 720)
	var preview = load("res://scenes/landmarks/lingayen_church/exterior/lc_ext_02_preview.tscn").instantiate()
	root.add_child(preview)
	current_scene = preview
	await settle()
	var panel = preview.get_node("HotspotFrame/TowerInteraction")
	var trigger: Button = preview.get_node("Margin/Layout/OpenArtwork")
	panel.hotspot_closed.connect(func(): close_count += 1)
	check(not panel.visible and not panel._open, "Preview starts closed")
	check(root.content_scale_size == Vector2i.ZERO, "Preview tests actual logical window size")
	check(not preview.has_node("Exterior"), "Neutral preview, no photo background")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		trigger.grab_focus()
		for control in [trigger, preview.get_node("Margin/Layout/Header"), preview.get_node("Margin/Layout/DevelopmentNote")]:
			check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(control.get_global_rect()), "Preview fits")
		await capture("lc_ext_02_%d_preview" % dimensions.x)
		await press(trigger, dimensions.x == 960)
		await finish(panel)
		check_observation(panel, 0)
		check_layout(panel, dimensions)
		check(root.gui_get_focus_owner() == panel._concepts[0] and not panel._concepts[0].button_pressed, "Predictable focus without selection")
		check(panel._speaker.visible and panel._speaker.disabled == (panel._audio.stream == null) and panel._speaker.text == "LISTEN", "Visible disabled Listen")
		check(panel._pending.visible == (panel._audio.stream == null) and panel._pending.text == "Narration pending.", "Pending narration status")
		check(panel._speaker.icon == load("res://assets/ui/icons/speaker.svg"), "Shared speaker icon")
		check(panel._audio.stream == panel.content.narration_stream and not panel._audio.playing, "No narration/autoplay")
		check(panel._credit.text == "PHOTO: AKAR Research Team, 2026", "Approved photo attribution")
		for button in panel.find_children("*", "Button", true, false):
			check(button.text.to_upper() not in ["NEXT", "PREVIOUS", "REPLAY", "READ TRANSCRIPT", "ABOUT THE CHURCH", "HISTORICAL NAME", "PRESENT ROLE"], "No sequential, tab or transcript controls")
		await capture("lc_ext_02_%d_overview" % dimensions.x)
		# Direct non-sequential selection with real mouse and touchscreen events.
		for observation in [1, 3, 2, 1]:
			await press(panel._concepts[observation - 1], observation == 2)
			await finish(panel)
			check_observation(panel, observation)
			check_layout(panel, dimensions)
			await capture("lc_ext_02_%d_observation%d" % [dimensions.x, observation])
		# Every marker accepts touch, including a tap near its 56 px hit-area edge.
		for i in 3:
			await press(panel._concepts[i], true, Vector2(23, 0))
			await finish(panel)
			check_observation(panel, i + 1)
		panel.reset_hotspot()
		await key(KEY_RIGHT)
		check(root.gui_get_focus_owner() == panel._concepts[1] and panel.get_observation() == 0, "Arrow moves focus independently of selection")
		await key(KEY_SPACE)
		await finish(panel)
		check_observation(panel, 2)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._concepts[2], "Tab order within markers")
		await key(KEY_ENTER)
		await finish(panel)
		check_observation(panel, 3)
		await key(KEY_RIGHT)
		check(root.gui_get_focus_owner() == panel._concepts[2], "Arrow clamps at final marker")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._concepts[1], "Reverse Tab order")
		for i in 50:
			panel.set_observation((i % 3) + 1)
		panel.set_observation(3)
		await finish(panel)
		check_observation(panel, 3)
		panel.set_observation(2)
		# Inspect an intermediate step deterministically, independent of frame rate.
		panel._fade.pause()
		panel._fade.custom_step(0.08)
		check(panel._detail.modulate.a > 0 and panel._detail.modulate.a < 1, "Subtle detail crossfade in progress")
		panel._layout_viewer()
		await finish(panel)
		check_observation(panel, 2)
		var old_image: Texture2D = panel._detail.texture
		var old_region: Rect2 = panel._focus_region
		await press(panel._sources_button, true)
		check(panel._sources.visible and panel.get_observation() == 2, "Sources preserves observation")
		check(panel._source_text.text.contains(HEADINGS[2]) and panel._source_text.text.contains("Historical source details pending researcher input."), "Truthful source context")
		check(not panel._source_text.text.contains("AKAR Research Team"), "Photo credit separate from sources")
		for i in 4:
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() in [panel._source_close, panel._source_scroll], "Sources traps keyboard focus")
		panel.set_observation(1)
		check(panel.get_observation() == 2, "Modal blocks background selection")
		await key(KEY_ESCAPE)
		check(panel._open and not panel._sources.visible and root.gui_get_focus_owner() == panel._sources_button, "First Escape closes Sources and restores focus")
		check(panel._detail.texture == old_image and panel._focus_region == old_region, "Sources leaves image and focus unchanged")
		await key(KEY_ESCAPE)
		await finish(panel)
		check(not panel._open and root.gui_get_focus_owner() == trigger, "Second Escape closes hotspot and restores launcher")
		await key(KEY_ENTER)
		await finish(panel)
		check_observation(panel, 0)
		check(not panel._sources.visible and panel._audio.get_playback_position() == 0, "Reopen resets sources and audio")
		panel.set_observation(1)
		panel.open_sources()
		panel.reset_hotspot()
		check_observation(panel, 0)
		check(panel._fade == null and panel._panel_tween == null, "Explicit reset clears tweens")
		panel.set_observation(3)
		panel.close_hotspot()
		panel.open_hotspot()
		await finish(panel)
		check_observation(panel, 0)
		panel.set_observation(-1)
		await finish(panel)
		check_observation(panel, 0)
		await press(panel._close, true)
		await finish(panel)
		check(not panel._open, "Touch Close")
		print("LC-EXT-02 checked: ", dimensions)
	check(close_count == 6, "One close notification per completed close")
	panel.open_hotspot()
	panel.set_observation(2)
	root.size = Vector2i(960, 540)
	await finish(panel)
	check_observation(panel, 2)
	check_layout(panel, root.size)
	root.size = Vector2i(854, 480)
	await settle()
	check_observation(panel, 2)
	check_layout(panel, root.size)
	preview.hide()
	check(not panel._open and panel._fade == null and panel._panel_tween == null and not panel._audio.playing, "Parent hide clears activity")
	preview.show()
	panel.open_hotspot()
	await finish(panel)
	check_observation(panel, 0)
	panel.set_observation(3)
	preview.queue_free()
	await settle()
	check(root.content_scale_size == Vector2i(1280, 720), "Preview restores host canvas policy")
	print("LC-EXT-02 failures: ", failures)
	quit(1 if failures else 0)
