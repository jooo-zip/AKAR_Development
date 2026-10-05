extends SceneTree
## Regression only: preserves the approved, withheld-video ENT-01 implementation.
var checks: int = 0
var failures: int = 0
func _initialize() -> void:
	run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func settle() -> void:
	await create_timer(0.3).timeout
func click(control: Control, touch: bool = false) -> void:
	Input.emulate_mouse_from_touch = true
	for down in [true, false]:
		if touch:
			var event := InputEventScreenTouch.new()
			event.position = control.get_global_rect().get_center()
			event.pressed = down
			Input.parse_input_event(event)
		else:
			var event := InputEventMouseButton.new()
			event.position = control.get_global_rect().get_center()
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = down
			Input.parse_input_event(event)
		await process_frame
	await settle()
func key(code: Key) -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = down
		Input.parse_input_event(event)
		await process_frame
	await settle()
func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	var parent := Control.new()
	root.add_child(parent)
	parent.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var hot: Control = load("res://scenes/landmarks/urduja_house/components/uh_ent_01.tscn").instantiate()
	parent.add_child(hot)
	var counts: Array[int] = [0, 0]
	hot.closed.connect(func() -> void: counts[0] += 1)
	hot.skip_requested.connect(func() -> void: counts[1] += 1)
	for size in [Vector2i(1280,720),Vector2i(960,540),Vector2i(854,480)]:
		root.size = size
		for inset in [false, true]:
			parent.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			if inset:
				parent.anchor_left = 0.05
				parent.anchor_top = 0.05
				parent.anchor_right = 0.95
				parent.anchor_bottom = 0.95
			hot.open_interaction()
			await settle()
			var video: Control = hot.interaction
			check(hot.active and not video.player.is_playing(), "ENT opens without autoplay")
			check(hot.listen.disabled and video.watch_button.disabled and video.replay_button.disabled and video.mute_button.disabled, "unverified media remains withheld")
			check(parent.get_global_rect().grow(1).encloses(hot.get_global_rect()), "ENT arbitrary parent")
			for button in [hot.sources_button,hot.close_button,video.watch_button,video.replay_button,video.mute_button]:
				check(hot.get_global_rect().grow(1).encloses(button.get_global_rect()) and button.size.y >= 48, "ENT button bounds")
			await click(hot.sources_button, inset)
			check(hot.sources.visible and not hot.sources_text.text.is_empty(), "ENT Sources")
			await click(hot.source_close)
			check(not hot.sources.visible and hot.active, "ENT Close Sources")
			var transcript: Button
			var skip: Button
			for button in video.find_children("*", "Button", true, false):
				if button.text == "TRANSCRIPT":
					transcript = button
				if button.text == "SKIP":
					skip = button
			await click(transcript, true)
			check(video.transcript.visible, "ENT transcript")
			await key(KEY_ESCAPE)
			check(hot.active and not video.transcript.visible, "ENT Escape closes subview")
			transcript.grab_focus()
			await key(KEY_ENTER)
			check(video.transcript.visible, "ENT keyboard transcript")
			await key(KEY_BACKSPACE)
			await key(KEY_TAB)
			check(root.gui_get_focus_owner() != null, "ENT Tab focus")
			if DisplayServer.get_name() != "headless":
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("akar_remaining_phase5/uh_ent_01_"+str(size.x)+str(inset)+".png"))
			await click(hot.close_button)
			check(not hot.active and not video.active, "ENT Close")
			hot.open_interaction()
			await settle()
			check(hot.active and not video.transcript.visible and not video.player.is_playing(), "ENT reopen reset")
			await click(skip, true)
			check(not hot.active, "ENT optional Skip")
	check(counts[0] == 6 and counts[1] == 6, "ENT signals emitted once")
	parent.queue_free()
	await process_frame
	print("CHECKPOINT uh_ent_01 checks=",checks," failures=",failures," renderer=",DisplayServer.get_name())
	quit(0 if failures == 0 else 1)
