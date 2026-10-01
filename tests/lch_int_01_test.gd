extends SceneTree
## Real GUI events, fitted-photo geometry and shell lifecycle in an inset parent.
var failures: int = 0
var checks: int = 0
const BODIES := [
	"Limahong, also known as Lin Feng, was a Chinese pirate and military leader. After his failed attacks on Manila in late 1574, he sailed to Pangasinan and established a fortified settlement.",
	"During the 1575 campaign, Limahong and part of his force escaped from Pangasinan by water. The present Limahong Channel is traditionally associated with that escape route."
]

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

func mouse_button(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = at
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame

func click(control: Control) -> void:
	var at := control.get_global_rect().get_center()
	await mouse_button(at, true)
	await mouse_button(at, false)
	await settle()

func touch_at(at: Vector2, pressed: bool, index: int = 0, canceled: bool = false) -> void:
	var event := InputEventScreenTouch.new()
	event.position = at
	event.index = index
	event.pressed = pressed
	event.canceled = canceled
	Input.parse_input_event(event)
	await process_frame

func touch(control: Control) -> void:
	var at := control.get_global_rect().get_center()
	await touch_at(at, true)
	await touch_at(at, false)
	await settle()

func motion(at: Vector2, touch_index: int = -1) -> void:
	var event: InputEvent
	if touch_index == -1:
		event = InputEventMouseMotion.new()
		event.button_mask = MOUSE_BUTTON_MASK_LEFT
	else:
		event = InputEventScreenDrag.new()
		event.index = touch_index
	event.position = at
	Input.parse_input_event(event)
	await process_frame

func assert_section(panel, section: int) -> void:
	check(panel.current_section == section and panel._selected == section, "Authoritative selected section")
	check(panel._body.text == BODIES[section], "Full approved section body, including historical role/connection")
	check(panel._heading.text == ["LIMAHONG / LIN FENG", "WHY THIS SITE?"][section], "Approved section heading")
	for i in 2:
		check(panel._section_buttons[i].button_pressed == (i == panel.current_section), "One active section")

func assert_crop(panel) -> void:
	var lens = panel._magnifier
	var photo_rect: Rect2 = lens.displayed_image_rect
	var crop: Rect2 = lens.source_region
	var native: Vector2 = lens._native_size()
	check(photo_rect.grow(0.01).encloses(Rect2(lens.lens.position, lens.lens.size)), "Entire 96px lens/handle hit area inside fitted photo")
	check(Rect2(Vector2.ZERO, native).grow(0.01).encloses(crop), "Crop inside source texture")
	check(crop.get_center().is_equal_approx(lens.lens_normalized_position * native), "Normalized center maps to native texels")
	check(is_equal_approx(crop.size.x, crop.size.y), "Square crop preserves photographic proportions")
	check(is_equal_approx(lens.DETAIL_SIZE / (crop.size.x * photo_rect.size.x / native.x), 2.0), "Fixed 2x visual detail")
	check(lens._atlas.atlas == panel.content.illustration and lens._atlas.region == crop, "Detail samples same authentic photo")
	check(panel._image.scale == Vector2.ONE and panel._image.rotation == 0.0, "Original photo stationary and untransformed")
	check(Rect2(Vector2.ZERO, panel._explorer.size).encloses(lens.detail.get_rect()), "Detail stays inside explorer")

func capture(tag: String) -> void:
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("lch-int-01-" + tag + ".png"))

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	create_timer(90.0).timeout.connect(func(): push_error("INT-01 test timeout"); quit(1))
	root.content_scale_size = Vector2i.ZERO
	var preview = load("res://scenes/landmarks/limahong_channel/interior/lch_int_01_preview.tscn").instantiate()
	root.add_child(preview)
	await settle()
	var panel = preview.get_node("HotspotFrame/LimahongStatueInteraction")
	# Keep the existing missing-narration regression scenario; assigned audio is covered by lch_header_test.
	panel.content = panel.content.duplicate(true)
	panel.content.narration_stream = null
	var trigger = preview.get_node("Margin/Layout/OpenArtwork")
	var lens = panel._magnifier
	var close_events: Array[int] = [0]
	panel.close_requested.connect(func(): close_events[0] += 1)
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		await settle()
		trigger.grab_focus()
		check(panel.open_interaction(), "Opens in real inset preview")
		await settle()
		assert_section(panel, 0)
		check(panel.size.is_equal_approx(Vector2(dimensions) * 0.9), "Parent-sized, no viewport-global placement")
		check(panel._concepts.size() == 2 and panel._section_buttons.size() == 2, "Exactly two historical section controls")
		check(panel._explorer.find_children("*", "BaseButton", true, false).is_empty(), "No historical marker buttons in explorer")
		for control in panel._explorer.find_children("*", "Control", true, false):
			if control != lens.lens:
				check(control.focus_mode == Control.FOCUS_NONE and control.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Only lens captures photo-area input")
		# Fractional parent placement can round a 96 px Control to 96.000015 px.
		check(lens.LENS_SIZE == 76.0 and lens.lens.size.is_equal_approx(Vector2(96, 96)), "Larger lens and generous hit area: %.9f x %.9f" % [lens.lens.size.x, lens.lens.size.y])
		check(lens.lens.visible and lens.detail.visible and lens.hint.visible, "Lens/detail/hint immediately available")
		check(lens.lens_normalized_position.is_equal_approx(panel.content.default_lens_position), "Default lens reset")
		check(panel._image.texture.resource_path.ends_with("lch_int_01_statue_photo.jpg.png"), "Actual provided filename retained")
		check(panel._image.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR, "Photographic filtering")
		check(panel._speaker.visible and panel._speaker.disabled and panel._speaker.text == "LISTEN" and panel._status.visible, "Visible pending narration shell")
		check(panel._speaker.icon.resource_path == "res://assets/ui/icons/speaker.svg", "Exact shared speaker")
		check(panel._audio.stream == null and not panel._audio.playing, "No other landmark's audio or autoplay")
		panel._section_buttons[0].grab_focus()
		var reached_lens := false
		for i in 10:
			await key(KEY_TAB)
			if root.gui_get_focus_owner() == lens.lens:
				reached_lens = true
		check(reached_lens, "Tab navigation reaches keyboard lens")
		panel._concepts[0].grab_focus()
		var ratio: float = panel._explorer.size.x / (panel._explorer.size.x + panel._information.size.x)
		check(ratio >= (0.62 if dimensions.x == 1280 else 0.55) and ratio <= (0.65 if dimensions.x == 1280 else 0.58), "Responsive explorer/info ratio")
		for control in panel._section_buttons + [panel._speaker, panel._sources_button, panel._close]:
			check(control.size.y >= 48.0, "Touch target at least 48px")
			check(panel.get_global_rect().grow(1).encloses(control.get_global_rect()), "Control within parent")
		check(panel.get_global_rect().grow(1).encloses(panel._scroll.get_global_rect()), "Text scroll stays in information panel")
		assert_crop(panel)
		await capture("%dx%d-default" % [dimensions.x, dimensions.y])
		# The full approved paragraph remains reachable in the existing info scroll.
		panel._scroll.scroll_vertical = 10000
		await settle()
		check(panel._body.get_global_rect().end.y <= panel._scroll.get_global_rect().end.y + 1.0, "Full historical-role text reachable at scroll bottom")
		panel._scroll.scroll_vertical = 0
		for old_anchor in [Vector2(0.10, 0.52), Vector2(0.90, 0.67), Vector2(0.10, 0.82)]:
			var at: Vector2 = panel._explorer.global_position + panel._explorer.size * old_anchor
			await mouse_button(at, true)
			await mouse_button(at, false)
			await touch_at(at, true)
			await touch_at(at, false)
			check(panel.current_section == 0 and not lens.lens_dragging, "Former marker positions no longer select or capture input")

		# Mouse drag captures only the lens, continuously samples, and releases in place.
		var start: Vector2 = lens.lens.get_global_rect().get_center()
		await mouse_button(start, true)
		check(lens.lens_dragging, "Mouse starts immediate lens drag")
		var original_crop: Rect2 = lens.source_region
		await motion(start + Vector2(24, -18))
		check(lens.source_region != original_crop and lens.lens_dragging, "Mouse motion updates crop before release")
		check(not lens.hint.visible and lens.hint_has_been_dismissed, "First meaningful drag dismisses hint")
		await mouse_button(start + Vector2(24, -18), false)
		check(not lens.lens_dragging, "Mouse releases drag")
		assert_crop(panel)
		# The short diagonal handle and enlarged outer hit area also start inspection.
		var handle: Vector2 = lens.lens.global_position + Vector2(85, 85)
		await mouse_button(handle, true)
		check(lens.lens_dragging, "Magnifier handle is draggable")
		await motion(handle + Vector2(6, 0))
		await mouse_button(handle + Vector2(6, 0), false)
		var saved: Vector2 = lens.lens_normalized_position
		await motion(start + Vector2(100, 80))
		check(lens.lens_normalized_position == saved, "Mouse move after release cannot move lens")
		await mouse_button(panel._image.global_position + Vector2(5, 5), true)
		await motion(start + Vector2(60, 50))
		await mouse_button(start + Vector2(60, 50), false)
		check(lens.lens_normalized_position == saved, "Photo background cannot initiate drag")

		# Real InputEventScreenTouch/ScreenDrag, not mouse emulation or direct method calls.
		start = lens.lens.get_global_rect().get_center()
		await touch_at(start, true, 3)
		check(lens.lens_dragging and lens._pointer == 3, "Synthetic touch starts lens drag directly")
		original_crop = lens.source_region
		await motion(start + Vector2(-32, 22), 3)
		check(lens.source_region != original_crop and lens.lens_dragging, "Touch updates crop continuously before release")
		saved = lens.lens_normalized_position
		await motion(start + Vector2(150, 90), 4)
		check(lens.lens_normalized_position == saved, "Second touch cannot hijack active drag")
		await touch_at(start + Vector2(-32, 22), false, 3)
		check(not lens.lens_dragging, "Touch release ends drag")
		assert_crop(panel)

		# Keyboard focus and every boundary through actual input events.
		lens.lens.grab_focus()
		var before: Vector2 = lens.lens.position
		await key(KEY_RIGHT)
		check(lens.lens.position.is_equal_approx(before + Vector2(18, 0)), "Keyboard arrow moves 18 logical pixels")
		before = lens.lens.position
		await key(KEY_UP, true)
		check(lens.lens.position.is_equal_approx(before + Vector2(0, -36)), "Shift-arrow moves 36 pixels")
		before = lens.lens.position
		await key(KEY_LEFT)
		await key(KEY_DOWN)
		check(lens.lens.position.is_equal_approx(before + Vector2(-18, 18)), "Keyboard left and down update lens")
		saved = lens.lens_normalized_position
		await key(KEY_SPACE)
		await key(KEY_ENTER)
		check(lens.lens_normalized_position == saved and not lens.lens_dragging, "No unnecessary inspection mode")
		for edge in [Vector2(-1000, -1000), Vector2(3000, -1000), Vector2(3000, 3000), Vector2(-1000, 3000)]:
			start = lens.lens.get_global_rect().get_center()
			await touch_at(start, true, 2)
			await motion(edge, 2)
			assert_crop(panel)
			await touch_at(edge, false, 2)
			check(not lens.lens_dragging, "Release outside photo ends drag")
		lens.set_lens_normalized_position(Vector2(0.65, 0.60))
		check(lens.detail_view_side == 0, "Right lens places detail left")
		await capture("%dx%d-detail-left" % [dimensions.x, dimensions.y])
		for x in [0.48, 0.52, 0.49, 0.55]:
			lens.set_lens_normalized_position(Vector2(x, 0.60))
			check(lens.detail_view_side == 0, "Hysteresis retains left detail in midpoint band")
		lens.set_lens_normalized_position(Vector2(0.35, 0.60))
		check(lens.detail_view_side == 1, "Left lens places detail right")
		lens.set_lens_normalized_position(Vector2(0.50, 0.60))
		check(lens.detail_view_side == 1, "Hysteresis retains right detail in midpoint band")

		# Both right-panel sections work through mouse, touch and keyboard.
		# Selection and Sources preserve inspection exactly, including reselect.
		saved = lens.lens_normalized_position
		original_crop = lens.source_region
		await click(panel._section_buttons[1])
		assert_section(panel, 1)
		await click(panel._section_buttons[0])
		assert_section(panel, 0)
		await touch(panel._section_buttons[1])
		assert_section(panel, 1)
		await touch(panel._section_buttons[0])
		assert_section(panel, 0)
		panel._section_buttons[0].grab_focus()
		await key(KEY_SPACE)
		assert_section(panel, 0)
		panel._section_buttons[1].grab_focus()
		await key(KEY_ENTER)
		assert_section(panel, 1)
		check(saved == lens.lens_normalized_position and original_crop == lens.source_region and lens.detail_view_side == 1, "Section inputs preserve lens/crop/side")
		check(not lens.hint.visible, "Selections never repeat hint")
		await capture("%dx%d-channel" % [dimensions.x, dimensions.y])
		await click(panel._sources_button)
		check(panel._sources.visible and not lens._enabled, "Sources blocks inspection")
		await key(KEY_TAB)
		check(root.gui_get_focus_owner() in [panel._source_scroll, panel._source_close], "Modal Sources focus trap")
		check(panel._source_text.text.begins_with("HISTORICAL REFERENCES") and panel.current_section == 1, "Standard Sources keeps active section")
		panel.select_section(0)
		assert_section(panel, 1)
		await key(KEY_ESCAPE)
		check(panel._open and not panel._sources.visible and lens._enabled, "Escape closes Sources first")
		check(saved == lens.lens_normalized_position and original_crop == lens.source_region and lens.detail_view_side == 1, "Sources round trip preserves exact inspection")

		# Cancel a captured pointer on Sources/close, then ignore its stale release.
		start = lens.lens.get_global_rect().get_center()
		await touch_at(start, true, 5)
		panel.open_sources()
		await motion(start + Vector2(99, 99), 5)
		await touch_at(start + Vector2(99, 99), false, 5)
		check(not lens.lens_dragging and saved == lens.lens_normalized_position, "Sources cancels drag; stale touch ignored")
		panel.close_sources()
		for i in 30:
			panel.select_section(i % 2)
		assert_section(panel, 1)
		check(saved == lens.lens_normalized_position and not lens.lens_dragging, "Rapid selections deterministic without resetting lens")
		await key(KEY_ESCAPE)
		check(not panel._open and not panel._audio.playing and lens._hint_tween == null and not lens.lens_dragging, "Close stops all active work")
		await settle()
		check(root.gui_get_focus_owner() == trigger, "Focus restored to opener")
		check(panel.open_interaction(), "Reopen")
		await settle()
		assert_section(panel, 0)
		check(lens.lens_normalized_position == panel.content.default_lens_position and lens.detail_view_side == 1 and lens.hint.visible, "Reopen resets lens/detail/hint")
		var tween: Tween = lens._hint_tween
		tween.pause()
		tween.custom_step(2.45)
		check(lens.hint.visible, "Hint survives first 2.45 seconds")
		tween.custom_step(0.5)
		check(not lens.hint.visible and lens._hint_tween == null, "Hint fades once by 2.8 seconds")
		start = lens.lens.get_global_rect().get_center()
		await touch_at(start, true, 7)
		panel.close_interaction()
		await motion(start + Vector2(100, 100), 7)
		await touch_at(start + Vector2(100, 100), false, 7)
		check(not lens.lens_dragging and not lens._enabled, "Close during drag ignores stale pointer events")
		await settle()
		print("PASS viewport ", dimensions, " mouse, keyboard, synthetic touch, crop bounds, sections, Sources, reset")

	# Source resolution/aspect changes and resized parent retain normalized inspection.
	panel.content = panel.content.duplicate()
	var original_texture: Texture2D = panel.content.illustration
	var sample := Image.create(1800, 900, false, Image.FORMAT_RGB8)
	panel.content.illustration = ImageTexture.create_from_image(sample)
	panel.open_interaction()
	await settle()
	lens.set_lens_normalized_position(Vector2(0.55, 0.56))
	var saved: Vector2 = lens.lens_normalized_position
	assert_crop(panel)
	root.size = Vector2i(1280, 720)
	await settle()
	check(saved.is_equal_approx(lens.lens_normalized_position), "Parent resize preserves normalized inspection")
	assert_crop(panel)
	panel.close_interaction()
	panel.content.illustration = null
	panel.open_interaction()
	await settle()
	check(panel._placeholder.visible and lens._pending.visible, "Missing-photo fallback explicit")
	lens.lens.grab_focus()
	await key(KEY_RIGHT)
	assert_crop(panel)
	panel.select_section(1)
	assert_section(panel, 1)
	panel.close_interaction()
	panel.content.illustration = original_texture

	# A temporary synthetic audio stream tests shell continuity; no media is assigned to data.
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = 8000
	var silence := PackedByteArray()
	silence.resize(80000)
	audio.data = silence
	panel.content.narration_stream = audio
	panel.open_interaction()
	await settle()
	check(not panel._audio.playing and not panel._speaker.disabled, "Assigned audio never autoplays")
	await click(panel._speaker)
	check(panel._audio.playing, "User starts narration")
	await create_timer(0.2).timeout
	var playback: float = panel._audio.get_playback_position()
	panel.select_section(0)
	panel.select_section(1)
	lens.set_lens_normalized_position(Vector2(0.60, 0.60))
	panel.open_sources()
	panel.close_sources()
	check(panel._audio.playing and panel._audio.get_playback_position() >= playback, "Selections/lens/Sources preserve narration playback")
	panel.close_interaction()
	check(not panel._audio.playing, "Close stops assigned narration")
	panel.content.narration_stream = null
	check(close_events[0] >= 9, "Parent receives close notification")
	preview.queue_free()
	await settle()
	print("LCH-INT-01: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)
