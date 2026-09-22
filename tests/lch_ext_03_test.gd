extends SceneTree
## Deterministic stage assertions and real GUI input in the inset F6 preview.
var failures: int = 0
const BODIES := [
	"Limahong and his followers had established a fortified settlement in Pangasinan before the expedition against them.",
	"Juan de Salcedo led the Spanish and allied Luzonese expedition that blockaded Limahong's settlement in 1575.",
	"During the campaign, Limahong's followers reportedly excavated a passage leading from the settlement toward the sea.",
	"Limahong and many of his followers used the water route to move beyond the blockade and escape by water."
]
const BUTTONS := ["01 SETTLEMENT", "02 BLOCKADE", "03 PASSAGE", "04 ESCAPE"]
const HEADINGS := ["FORTIFIED SETTLEMENT", "THE BLOCKADE", "REPORTED ESCAPE PASSAGE", "ESCAPE BY WATER"]

func check(ok: bool, message: String) -> void:
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
	if panel._stage_tween != null and panel._stage_tween.is_valid():
		var tween: Tween = panel._stage_tween
		tween.pause()
		tween.custom_step(4.0)
	await settle()

func assert_state(panel, stage: int) -> void:
	check(panel.current_stage == stage and panel._selected == stage, "Authoritative stage")
	check(panel._image.visible and panel._image.texture == panel.content.illustration, "Stable map")
	check(panel._settlement.visible and panel._settlement_label.visible, "Settlement established")
	check(panel._blockade.visible == (stage >= 1), "Cumulative blockade")
	check(panel._blockade_markers.size() == 4 and panel._blockade.get_child_count() == 4, "Exactly four blockade symbols")
	check(panel._passage.visible == (stage >= 2), "Cumulative passage")
	check(panel.passage_progress == (1.0 if stage >= 2 else 0.0), "Complete/reset passage")
	check(panel._vessel.visible == (stage == 3), "Vessel only in Escape")
	check(panel.escape_progress == (1.0 if stage == 3 else 0.0), "Vessel progress final state")
	check(panel._settlement.scale.is_equal_approx(Vector2.ONE) and panel._settlement.modulate.a == 1.0, "Settlement transform stable")
	check(panel._settlement.position.is_equal_approx(panel._map_point(panel.content.settlement_anchor)), "Settlement fitted anchor")
	for i in 4:
		var marker: Node2D = panel._blockade_markers[i]
		check(marker.modulate.a == 1.0 and marker.scale.is_equal_approx(Vector2.ONE) and marker.rotation == 0.0, "Blockade transform stable")
		check(marker.position.is_equal_approx(panel._map_point(panel.content.blockade_anchors[i])), "Blockade fitted anchors, no chasing")
		check(panel._concepts[i].button_pressed == (i == stage), "Active stage obvious")
		check(panel._concepts[i].text == BUTTONS[i], "Exact numbered buttons")
	check(panel._body.text == BODIES[stage] and panel._heading.text == HEADINGS[stage], "Approved stage wording")
	check(panel._date.text == ("AUGUST 1575" if stage == 3 else "1575"), "Exact date")
	check(panel._stage_tween == null, "Animation finished/cleared")
	if stage >= 2:
		check(panel._notice.text == "Interpretive escape passage — exact historical path not established." and panel._notice.modulate.a == 1.0, "Passage notice remains visible")
		check(panel._passage.points[-1].is_equal_approx(panel._map_point(panel.content.water_exit_anchor)), "Line reaches water")
	if stage == 1:
		check(panel._notice.text == "Symbolic blockade representation — not exact troop positions.", "Blockade qualification")
	if stage == 3:
		check(panel._follower.position.is_equal_approx(panel._passage.points[-1]), "Vessel reaches same endpoint as visible passage")

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	# Fail rather than hang indefinitely if a scene cannot load.
	create_timer(90.0).timeout.connect(func(): push_error("EXT-03 test timeout"); quit(1))
	root.content_scale_size = Vector2i.ZERO
	var preview = load("res://scenes/landmarks/limahong_channel/exterior/lch_ext_03_preview.tscn").instantiate()
	root.add_child(preview)
	await settle()
	var panel = preview.get_node("HotspotFrame/LimahongChannelInteraction")
	var trigger = preview.get_node("Margin/Layout/OpenArtwork")
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		trigger.grab_focus()
		check(panel.open_interaction(), "Open four-stage component")
		check(panel._settlement.scale.x < 1.0 and panel._settlement.modulate.a == 0.0, "Initial introduction")
		await finish(panel)
		assert_state(panel, 0)
		check(panel._title.text == "THE SIEGE AND ESCAPE ROUTE", "Correct title")
		check(panel.size.x < root.size.x and panel.size.y < root.size.y, "Embedded parent sizing")
		var map_share: float = panel._map_area.size.x / (panel._map_area.size.x + panel._information.size.x)
		check(map_share >= 0.64 and map_share <= 0.66, "64–66 percent map")
		check(panel._fitted.size.x > 0 and is_equal_approx(panel._fitted.size.x / panel._fitted.size.y, panel._image.texture.get_size().aspect()), "Map aspect fitted")
		check(panel._scroll.size.y >= 100 and panel._fitted.size.y >= 150, "Readable map and prose areas")
		check(panel._timeline.visible == (dimensions.x == 1280), "Responsive stages")
		var label_rect: Rect2 = panel._settlement_label.get_global_rect()
		for sprite in panel._blockade_images:
			# Check the full fitted sprite bounds, including faint asset edge pixels.
			var marker_size: Vector2 = sprite.region_rect.size * sprite.scale
			check(not label_rect.intersects(Rect2(sprite.global_position - marker_size * 0.5, marker_size)), "Settlement label clear of blockade symbols")
		for button in panel._concepts + [panel._sources_button, panel._speaker, panel._close]:
			check(button.size.y >= 48 and button.size.x >= 48, "Touch target >=48")
			check(panel.get_global_rect().encloses(button.get_global_rect()), "Controls within parent")
		check(panel.get_global_rect().encloses(panel._disclaimer.get_global_rect()), "Disclaimer within parent")
		check(panel._disclaimer.text == (panel.content.compact_disclaimer if dimensions.x == 854 else panel.content.permanent_disclaimer), "Responsive permanent qualification")
		check(panel._speaker.visible and panel._speaker.disabled and panel._speaker.text == "LISTEN", "Visible pending narration")
		check(panel._speaker.icon == load("res://assets/ui/icons/speaker.svg"), "Exact shared speaker icon")
		check(panel._audio.stream == null and not panel._audio.playing, "No unrelated audio or autoplay")
		for texture in [panel.content.blockade_marker, panel.content.fortified_settlement, panel.content.escape_vessel]:
			var img: Image = texture.get_image()
			check(img.detect_alpha() != Image.ALPHA_NONE and img.get_pixel(0, 0).a == 0.0, "Transparent icon background")
			print("EXT-03 asset: ", texture.resource_path, " size=", img.get_size(), " used=", img.get_used_rect(), " alpha=", img.detect_alpha())
		check(not panel._follower.loop and not panel._follower.rotates, "No looping or auto-rotation")
		# Direct jumps, backwards removal, and same-stage replay use the same API.
		for stage in [0, 1, 2, 3, 1, 0, 2, 0, 3, 0]:
			panel.show_stage(stage)
			var tween: Tween = panel._stage_tween
			tween.pause()
			match stage:
				0:
					check(panel._settlement.modulate.a == 0.0 and is_equal_approx(panel._settlement.scale.x, 0.88), "Settlement replay resets")
				1:
					check(panel._blockade_markers.all(func(marker): return marker.modulate.a == 0.0), "Blockade replay resets four")
					tween.custom_step(0.3)
					check(panel._blockade_markers[0].modulate.a == 1 and panel._blockade_markers[1].modulate.a > 0 and panel._blockade_markers[2].modulate.a == 0, "Sequential blockade reveal")
				2:
					check(panel.passage_progress == 0.0 and not panel._vessel.visible, "Passage replay resets only line")
					tween.custom_step(0.675)
					check(panel.passage_progress > 0.4 and panel.passage_progress < 0.6 and panel._passage.points.size() > 1, "Progressive Line2D reveal")
				3:
					check(panel.escape_progress == 0.0 and panel.passage_progress == 1.0, "Escape replay starts vessel with route established")
					check(panel._follower.position.is_equal_approx(panel._settlement.position), "Vessel begins at settlement")
					tween.custom_step(1.125)
					check(panel.escape_progress > 0.4 and panel.escape_progress < 0.6, "Escape traverses PathFollow2D")
					var expected: Vector2 = panel._path.curve.sample_baked(panel._path.curve.get_baked_length() * panel.escape_progress)
					check(panel._follower.position.distance_to(expected) < 0.01, "Vessel follows shared curve")
			await finish(panel)
			assert_state(panel, stage)
			panel.show_stage(stage)
			check(panel._stage_tween != null, "Same-stage replay starts")
			await finish(panel)
			assert_state(panel, stage)
		for sequence in [[0,1,2,3,0], [3,2,1,3]]:
			var killed: Array[Tween] = []
			for stage in sequence:
				panel.show_stage(stage)
				panel._stage_tween.pause()
				panel._stage_tween.custom_step(0.12)
				killed.append(panel._stage_tween)
			await finish(panel)
			assert_state(panel, sequence[-1])
			for tween in killed:
				check(not tween.is_valid(), "Prior tween cannot leave stale callback")
		# Normalize every animation when Sources interrupts, preserve selection.
		for stage in 4:
			panel.show_stage(stage)
			panel.open_sources()
			assert_state(panel, stage)
			check(panel._sources.visible and panel._source_text.text.contains(panel.content.permanent_disclaimer), "Sources retains full qualification")
			check(panel._concepts.all(func(button): return button.focus_mode == Control.FOCUS_NONE), "Sources traps stage focus")
			await key(KEY_RIGHT)
			check(panel.current_stage == stage, "Sources blocks stage arrows")
			await key(KEY_ESCAPE)
			check(not panel._sources.visible and panel._open and root.gui_get_focus_owner() == panel._sources_button, "Escape closes Sources first")
			assert_state(panel, stage)
		# Input paths, including activation of the currently selected button.
		await click(panel._concepts[0])
		await finish(panel)
		await key(KEY_LEFT)
		check(panel.current_stage == 0 and panel._stage_tween == null, "Left clamps without replay")
		await key(KEY_RIGHT)
		check(panel.current_stage == 1, "Right arrow stage")
		for stage in 4:
			await click(panel._concepts[stage])
			check(panel.current_stage == stage, "Mouse stage")
			await touch(panel._concepts[stage])
			check(panel.current_stage == stage and panel._stage_tween != null, "Touch same-stage replay")
			await finish(panel)
		await key(KEY_RIGHT)
		check(panel.current_stage == 3 and panel._stage_tween == null, "Right clamps without replay")
		panel._concepts[0].grab_focus()
		await key(KEY_ENTER)
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._concepts[1], "Tab next stage focus")
		await key(KEY_SPACE)
		check(panel.current_stage == 1, "Space stage activation")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._concepts[0], "Shift+Tab previous focus")
		await touch(panel._sources_button)
		check(panel._sources.visible, "Touch Sources")
		await touch(panel._source_close)
		check(not panel._sources.visible, "Touch Close Sources")
		if "--capture" in OS.get_cmdline_user_args():
			for stage in 4:
				panel.show_stage(stage, false)
				await settle()
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lch_ext_03_%s_stage%s.png" % [dimensions.x, stage]))
		panel.show_stage(3)
		await key(KEY_ESCAPE)
		check(not panel._open and panel._stage_tween == null and root.gui_get_focus_owner() == trigger, "Escape closes safely and restores focus")
		panel.open_interaction()
		await finish(panel)
		assert_state(panel, 0)
		await touch(panel._close)
		check(not panel._open and panel._stage_tween == null, "Touch close clears animation")
		print("LCH-EXT-03 size passed: ", dimensions)
	# Reflow while moving retains progress and follows updated parent coordinates.
	panel.open_interaction()
	panel.show_stage(3)
	panel._stage_tween.pause()
	panel._stage_tween.custom_step(1.0)
	var retained: float = panel.escape_progress
	root.size = Vector2i(1280, 720)
	await settle()
	check(is_equal_approx(retained, panel.escape_progress), "Resize retains animation progress")
	await finish(panel)
	assert_state(panel, 3)
	# Changing editable anchors updates line, settlement, follower and endpoint together.
	panel.close_interaction()
	panel.content = panel.content.duplicate()
	panel.content.settlement_anchor = Vector2(0.40, 0.48)
	panel.content.water_exit_anchor = Vector2(0.70, 0.92)
	panel.open_interaction()
	panel.show_stage(3, false)
	assert_state(panel, 3)
	# Future correct audio remains user initiated and continues across stage selection.
	panel.close_interaction()
	var audio := AudioStreamWAV.new()
	audio.mix_rate = 8000
	var samples := PackedByteArray()
	samples.resize(40000)
	samples.fill(128)
	audio.data = samples
	panel.content.narration_stream = audio
	panel.open_interaction()
	check(not panel._audio.playing and not panel._speaker.disabled, "Assigned narration still does not autoplay")
	await touch(panel._speaker)
	check(panel._audio.playing, "Touch listen")
	panel._audio.seek(1.0)
	panel.show_stage(3)
	check(panel._audio.playing and panel._audio.get_playback_position() >= 0.9, "Stages do not restart audio")
	await click(panel._speaker)
	check(not panel._audio.playing, "Mouse stop narration")
	await click(panel._speaker)
	panel.close_interaction()
	check(not panel._audio.playing, "Close stops narration")
	panel.content.illustration = null
	panel.open_interaction()
	check(panel._placeholder.visible, "Clearly labeled missing-map fallback")
	panel.close_interaction()
	preview.queue_free()
	await settle()
	print("LCH-EXT-03 failures: ", failures)
	quit.call_deferred(1 if failures else 0)
