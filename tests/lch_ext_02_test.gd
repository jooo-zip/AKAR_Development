extends SceneTree

var failures: int = 0

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

func _initialize() -> void:
	run.call_deferred()

func finish_route(panel: Control) -> void:
	if panel._route_tween != null and panel._route_tween.is_valid():
		panel._route_tween.pause()
		panel._route_tween.custom_step(3.0)
	if panel._stage_tween != null and panel._stage_tween.is_valid():
		panel._stage_tween.pause()
		panel._stage_tween.custom_step(1.0)
	await settle()

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	var preview = load("res://scenes/landmarks/limahong_channel/exterior/lch_ext_02_preview.tscn").instantiate()
	root.add_child(preview)
	await settle()
	var panel = preview.get_node("HotspotFrame/LimahongChannelInteraction")
	# Keep the existing missing-narration regression scenario; assigned audio is covered by lch_header_test.
	panel.content = panel.content.duplicate(true)
	panel.content.narration_stream = null
	var trigger = preview.get_node("Margin/Layout/OpenArtwork")
	for dimensions in [Vector2i(1280,720), Vector2i(960,540), Vector2i(854,480)]:
		root.size = dimensions
		await settle()
		trigger.grab_focus()
		check(panel.open_interaction(), "Open")
		await settle()
		check(panel.current_stage == 0 and panel.route_progress == 0 and panel._movement.visible, "Initial map")
		check(panel._follower.progress_ratio == 0 and not panel._follower.loop, "Follower starts without looping")
		check(panel._follower.position.is_equal_approx(panel._fitted.position + panel.content.manila_anchor * panel._fitted.size), "Follower at Manila")
		check(not panel._settlement.visible, "Settlement hidden in Manila")
		check(panel._heading.text == "FAILED ATTACKS ON MANILA" and panel._date.text == "LATE 1574", "Manila heading/date")
		check(panel._body.text == "After his failed attacks on Manila in late 1574, Limahong left the area with his forces and sailed north.", "Manila wording")
		check(panel._speaker.visible and panel._speaker.disabled and panel._speaker.text == "LISTEN", "Pending listen")
		check(panel._speaker.icon == load("res://assets/ui/icons/speaker.svg"), "Shared icon")
		check(panel._audio.stream == null and not panel._audio.playing, "No unrelated audio/autoplay")
		for button in panel._concepts + [panel._close, panel._speaker, panel._sources_button]:
			check(button.size.y >= 48, "Touch target")
			check(panel.get_global_rect().encloses(button.get_global_rect()), "Button within parent")
		check(panel._scroll.size.y >= 100, "Readable scroll area")
		check(panel._map_area.size.y >= 160, "Map area")
		check(panel.size.x < root.size.x, "Inset parent")
		check(panel._movement.texture == panel.content.route_ship and panel._settlement_image.texture == panel.content.fortified_settlement, "Supplied visual assets")
		check(not panel.has_node("Previous") and not panel.has_node("Replay") and not panel.has_node("Next"), "Redundant controls absent")
		for texture in [panel.content.location_marker, panel.content.route_ship, panel.content.fortified_settlement]:
			check(texture.get_image().detect_alpha() != Image.ALPHA_NONE, "Transparent supplied art")
		var map_share: float = panel._map_region.size.x / (panel._map_region.size.x + panel._information.size.x)
		check(map_share >= 0.60 and map_share <= 0.66, "Map-dominant layout")
		check(panel._timeline.visible == (dimensions.x == 1280), "Responsive timeline")
		for marker in panel._location_markers:
			check(marker.texture == panel.content.location_marker, "Supplied marker instances")
		check(is_equal_approx(panel._fitted.size.x / panel._fitted.size.y, 2.0 / 3.0), "Map aspect preserved")
		await click(panel._concepts[1])
		check(panel.current_stage == 1, "Mouse Northward")
		await finish_route(panel)
		await touch(panel._concepts[1])
		check(panel.current_stage == 1 and panel.route_progress < 0.25, "Same-stage Northward replay restarts")
		await finish_route(panel)
		await touch(panel._concepts[0])
		check(panel.current_stage == 0, "Touch previous stage")
		panel._concepts[1].grab_focus()
		await key(KEY_SPACE)
		check(panel.current_stage == 1, "Keyboard stage activation")
		panel._concepts[0].grab_focus()
		await key(KEY_ENTER)
		check(panel.current_stage == 0, "Keyboard previous stage activation")
		await click(panel._concepts[2])
		check(panel.current_stage == 2 and panel.route_progress == 1, "Direct mouse jump")
		check(panel._follower.progress_ratio == 1 and panel._settlement.visible, "Destination follower/settlement")
		check(panel._movement.visible and panel._movement.modulate.a > 0.0, "Arrival briefly restores ship")
		check(panel._location_markers[1].visible, "Stage 3 briefly keeps Pangasinan pin")
		check(panel._settlement.position.is_equal_approx(panel._location_markers[1].position), "Settlement shares destination coordinate")
		panel._concepts[2].grab_focus()
		await key(KEY_ENTER)
		check(panel.current_stage == 2 and panel.route_progress == 1, "Pangasinan replay avoids journey")
		await finish_route(panel)
		check(panel._settlement.modulate.a == 1, "Settlement fade completes")
		check(not panel._location_markers[1].visible, "Stage 3 replaces Pangasinan pin")
		check(not panel._movement.visible and panel._movement.modulate.a == 0.0, "Arrival ship fades out")
		check(panel._settlement.scale.is_equal_approx(Vector2.ONE), "Settlement scale settles")
		check(panel._settlement.position.is_equal_approx(panel._settlement_base_position), "Settlement shake settles")
		var settlement_center: Vector2 = panel._settlement_base_position + panel._settlement_image.position
		var destination_point: Vector2 = panel._fitted.position + panel.content.pangasinan_anchor * panel._fitted.size
		check(settlement_center.distance_to(destination_point) <= panel._fitted.size.y * 0.35, "Settlement remains near Pangasinan: %s vs %s" % [settlement_center, destination_point])
		check(not panel.find_children("*", "Label", true, false).any(func(node): return (node as Label).text == "Artistic historical interpretation"), "Interpretation label removed from UI")
		check(panel._body.text == "In Pangasinan, Limahong established a fortified settlement.\n\nThis settlement became the setting of the 1575 campaign.", "Pangasinan wording")
		await touch(panel._concepts[0])
		check(panel.current_stage == 0 and panel.route_progress == 0, "Touch return")
		check(panel._settlement.scale.is_equal_approx(Vector2.ONE) and panel._settlement.position.is_equal_approx(panel._settlement_base_position), "Stage change restores settlement transform")
		await key(KEY_LEFT)
		check(panel.current_stage == 0, "No left wrap")
		await key(KEY_RIGHT)
		check(panel.current_stage == 1, "Right stage")
		check(not panel._settlement.visible, "Settlement hidden northward")
		check(panel._heading.text == "SAIL TO PANGASINAN" and panel._body.text == "Limahong sailed to Pangasinan, bringing the conflict north from Manila.", "Northward wording")
		panel.show_stage(1)
		panel._route_tween.pause()
		panel._route_tween.custom_step(1.25)
		check(panel.route_progress > 0.4 and panel.route_progress < 0.6, "Progressive reveal")
		check(panel._follower.position.is_equal_approx(panel._route.points[-1]), "Marker follows reveal")
		panel._layout_map()
		check(panel.route_progress > 0.4 and panel.route_progress < 0.6 and panel._follower.position.is_equal_approx(panel._route.points[-1]), "Relayout preserves progress")
		await finish_route(panel)
		check(panel.route_progress == 1, "Route completes")
		check(panel._location_markers[1].modulate.is_equal_approx(Color("f3dfaa")), "Destination emphasized after travel")
		check(panel._follower.progress_ratio == 1 and not panel._settlement.visible, "Northward endpoint without settlement")
		for stage in [0,1,2,0,1]:
			panel.show_stage(stage)
		await finish_route(panel)
		check(panel.current_stage == 1 and panel.route_progress == 1 and panel._concepts[1].button_pressed and not panel._settlement.visible, "Rapid final Northward")
		for stage in [0,1,2,0,1,2]:
			panel.show_stage(stage)
		await finish_route(panel)
		check(panel._settlement.modulate.a == 1, "Rapid opacity normalized")
		check(panel.current_stage == 2 and panel.route_progress == 1 and panel._concepts[2].button_pressed, "Rapid final state")
		check(panel._heading.text == "FORTIFIED SETTLEMENT", "Final text")
		check(panel._notice.modulate.a == 1 and panel._notice.text == panel.content.route_notice, "Route safeguard")
		check(panel._follower.position.is_equal_approx(panel._fitted.position + panel.content.pangasinan_anchor * panel._fitted.size), "Destination fitted to map")
		check(panel._path.curve.get_point_position(panel._path.curve.point_count - 1).is_equal_approx(panel._fitted.position + panel.content.pangasinan_anchor * panel._fitted.size), "Route endpoint shares Pangasinan coordinate")
		await key(KEY_RIGHT)
		check(panel.current_stage == 2, "No right wrap")
		panel._concepts[0].grab_focus()
		await key(KEY_ENTER)
		check(panel.current_stage == 0, "Enter")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._concepts[1], "Tab")
		await key(KEY_SPACE)
		check(panel.current_stage == 1, "Space")
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() == panel._concepts[0], "Shift tab")
		await touch(panel._sources_button)
		check(panel._sources.visible and panel.current_stage == 1, "Sources preserve stage")
		check(panel._concepts[1].focus_mode == Control.FOCUS_NONE and panel._sources_button.focus_mode == Control.FOCUS_NONE, "Sources traps stage focus")
		await key(KEY_ESCAPE)
		check(not panel._sources.visible and panel._open and root.gui_get_focus_owner() == panel._sources_button, "Sources escape/focus")
		if "--capture" in OS.get_cmdline_user_args():
			for stage in [0, 1]:
				panel.show_stage(stage)
				if stage == 1:
					panel._route_tween.pause()
					panel._route_tween.custom_step(1.25)
				await settle()
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lch_ext_02_%s_stage%s.png" % [dimensions.x, stage]))
			panel.show_stage(2)
			await finish_route(panel)
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lch_ext_02_%s.png" % dimensions.x))
		await key(KEY_ESCAPE)
		check(not panel._open and root.gui_get_focus_owner() == trigger, "Close/focus")
		panel.open_interaction()
		check(panel.current_stage == 0 and panel.route_progress == 0 and not panel._sources.visible, "Reopen reset")
		check(panel._follower.progress_ratio == 0 and not panel._settlement.visible, "Follower/settlement reset")
		check(panel._movement.visible and panel._movement.modulate.a == 1.0, "Reopen restores ship")
		await touch(panel._close)
		check(not panel._open, "Touch close")
		print("LCH-EXT-02 size passed: ", dimensions)
	# Future audio stays hotspot-level; use silence, never unrelated narration.
	var audio := AudioStreamWAV.new()
	audio.mix_rate = 8000
	var samples := PackedByteArray()
	samples.resize(40000)
	samples.fill(128)
	audio.data = samples
	panel.content = panel.content.duplicate()
	panel.content.narration_stream = audio
	panel.open_interaction()
	await click(panel._speaker)
	check(panel._audio.playing, "Explicit listen")
	panel._audio.seek(1.0)
	panel.show_stage(2)
	check(panel._audio.playing and panel._audio.get_playback_position() >= 0.9, "Stage leaves audio running")
	panel.close_interaction()
	check(not panel._audio.playing, "Close stops audio")
	panel.content.illustration = null
	panel.open_interaction()
	check(panel._placeholder.visible, "Missing map fallback")
	panel.close_interaction()
	preview.queue_free()
	await settle()
	print("LCH-EXT-02 failures: ", failures)
	quit.call_deferred(1 if failures else 0)
