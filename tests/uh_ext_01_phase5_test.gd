extends SceneTree
## Run headless for input/content checks; run with Compatibility for PNG capture too.
var checks: int = 0
var failures: int = 0
var panel: Control
var explorer: Control
var render: bool = false
var output: String

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle(seconds: float = 0.3) -> void:
	await create_timer(seconds).timeout

func key(code: Key, shift: bool = false) -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.shift_pressed = shift
		event.pressed = down
		Input.parse_input_event(event)
		await process_frame
	await settle()

func click(control: Control) -> void:
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = control.get_global_rect().get_center()
		event.pressed = down
		Input.parse_input_event(event)
		await process_frame
	await settle()

func drag_to(fraction: float, touch: bool = false) -> void:
	var initial: int = explorer.selected
	var start: Vector2 = explorer.handle.get_global_rect().get_center()
	var target: Vector2 = explorer.track.global_position + Vector2(lerpf(explorer._point(0), explorer._point(2), fraction), 26)
	if touch:
		var down := InputEventScreenTouch.new()
		down.index = 4
		down.position = start
		down.pressed = true
		Input.parse_input_event(down)
		await process_frame
		var motion := InputEventScreenDrag.new()
		motion.index = 4
		motion.position = target + Vector2(0, 90)
		Input.parse_input_event(motion)
		await process_frame
		check(explorer.selected == initial, "touch drag defers content until release")
		down.position = target
		down.pressed = false
		Input.parse_input_event(down)
	else:
		var down := InputEventMouseButton.new()
		down.button_index = MOUSE_BUTTON_LEFT
		down.position = start
		down.pressed = true
		Input.parse_input_event(down)
		await process_frame
		var motion := InputEventMouseMotion.new()
		motion.position = target + Vector2(0, -90)
		Input.parse_input_event(motion)
		await process_frame
		check(explorer.selected == initial, "mouse drag defers content until release")
		check(is_zero_approx(explorer.handle.position.y), "drag has no vertical drift")
		down.position = target
		down.pressed = false
		Input.parse_input_event(down)
	await settle()
	verify_state(clampi(roundi(fraction * 2), 0, 2))

func verify_state(index: int) -> void:
	check(explorer.selected == index, "selected state " + str(index))
	check(explorer.picture.texture == panel.revision.images[index], "correct state image")
	check(explorer.caption.text == panel.revision.captions[index], "correct caption")
	check(explorer.heading.text == panel.revision.headings[index], "correct heading")
	check(explorer.context_label.text == panel.revision.context_labels[index], "correct context")
	check(explorer.body.text == panel.revision.bodies[index], "correct body")
	check(is_equal_approx(explorer.handle.position.x + 26, explorer._point(index)), "selector snapped")
	for i in 3:
		check(explorer.selectors[i].button_pressed == (i == index), "exactly one selected label")
	for control in [explorer.picture, explorer.text_column, explorer.caption]:
		check(is_equal_approx(control.modulate.a, 1), "transition restores opacity")

func capture(name: String) -> void:
	if not render:
		return
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	var rect: Rect2 = panel.sources_button.get_global_rect()
	check(shot.get_pixel(int(rect.position.x + 4), int(rect.get_center().y)).r >= 0.09, "Sources header actually rendered")
	shot.save_png(output.path_join(name + ".png"))

func _initialize() -> void:
	run.call_deferred()

func inspector_layout_check() -> void:
	# Simulate saved Inspector edits before _ready; runtime must respect them.
	root.size = Vector2i(1280, 720)
	var packed: PackedScene = load("res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn")
	check(packed.get_state().get_node_count() > 15, "production owns visible presentation nodes")
	var probe: Control = packed.instantiate()
	var view: Control = probe.get_node("Panel/MainMargin/MainVBox/Content/Discovery")
	var margin: MarginContainer = probe.get_node("Panel/MainMargin")
	margin.add_theme_constant_override("margin_left", 25)
	view.get_node("%TakeawayMargin").add_theme_constant_override("margin_left", 31)
	view.get_node("%ContentRow").add_theme_constant_override("separation", 23)
	view.get_node("%MediaColumn").add_theme_constant_override("separation", 9)
	view.get_node("%Heading").add_theme_font_size_override("font_size", 25)
	view.get_node("%MediaCaption").horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	view.get_node("%DiscoveryRail").custom_minimum_size.y = 60
	view.get_node("%History").custom_minimum_size.x = 170
	view.get_node("%MediaFrame").custom_minimum_size.y = 145
	probe.get_node("Panel/MainMargin/MainVBox/Header").add_theme_constant_override("separation", 10)
	root.add_child(probe)
	probe.open_interaction()
	await settle(0.5)
	for width in [854, 1280]:
		root.size = Vector2i(width, 720)
		await settle(0.5)
		check(margin.get_theme_constant("margin_left") == 25, "Inspector main margin retained")
		check(view.takeaway_margin.get_theme_constant("margin_left") == 31, "Inspector takeaway margin retained")
		check(view.media_column.get_theme_constant("separation") == 9, "Inspector caption gap retained")
		check(view.caption.horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT, "Inspector caption alignment retained")
		check(view.track.custom_minimum_size.y == 60, "Inspector rail height retained")
		check(view.selectors[1].custom_minimum_size.x == 170, "Inspector stop size retained")
		check(view.image_area.custom_minimum_size.y == 145, "Inspector media-frame minimum retained")
		check(probe.get_node("Panel/MainMargin/MainVBox/Header").get_theme_constant("separation") == 10, "Inspector header gap retained")
	check(view.columns.get_theme_constant("separation") == 23, "wide layout restores scene-authored gap")
	check(view.heading.get_theme_font_size("font_size") == 25, "wide layout restores scene-authored font")
	probe.close_interaction()
	probe.queue_free()
	await process_frame

func run() -> void:
	render = DisplayServer.get_name() != "headless"
	output = OS.get_environment("TEMP").path_join("akar_uh_ext_01_editor")
	DirAccess.make_dir_recursive_absolute(output)
	root.content_scale_size = Vector2i.ZERO
	await inspector_layout_check()
	var preview: Control = load("res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn").instantiate()
	root.add_child(preview)
	panel = preview.get_node("Frame/Hotspot")
	explorer = panel.interaction
	await settle()
	check(panel.revision.labels == PackedStringArray(["PLACE", "HISTORY", "TODAY"]), "approved rail labels")
	check(panel.revision.title == "MEET URDUJA HOUSE", "approved title")
	check(panel.revision.subtitle == "Official Residence of the Governor of Pangasinan", "approved subtitle")
	check(not panel.listen.disabled and panel.listen.visible and panel.audio.stream == panel.revision.narration, "Listen enabled with supplied narration")
	check(not panel.audio.playing, "no autoplay")
	check(panel.revision.captions[1] == "Historical view of Urduja House • September 1982", "1982 photo caption")
	check(panel.revision.bodies[1] == "Construction of the governor's official residence began in 1953.", "construction start, not completion")
	check(panel.revision.images[0] != panel.revision.images[1] and panel.revision.images[1] != panel.revision.images[2], "three distinct images")
	check(panel.listen.accessibility_name == "LISTEN" and panel.listen.accessibility_description.contains("play narration"), "Listen has stable name and idle description")
	check(explorer.handle.find_children("*", "TextureRect", true, false).is_empty() and explorer.handle.has_node("Diamond"), "scene-authored diamond has no detailed image")
	check(panel.revision.history_years == PackedStringArray(["1953", "1982"]), "separate years")
	check(panel.revision.history_headings == PackedStringArray(["Construction Begins", "An Earlier View"]), "approved section headings")
	check(panel.revision.history_photo_body == "This September 1982 photograph provides a historical view of Urduja House during an earlier period.", "approved photo interpretation")
	check(panel.revision.observation_text == "Compare this historical view with TODAY to see the residence in the present.", "optional observation copy")
	verify_state(0)
	await narration_check()
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
		root.size = dimensions
		for inset in [false, true]:
			var frame: Control = preview.get_node("Frame")
			frame.anchor_left = 0.05 if inset else 0.0
			frame.anchor_top = 0.05 if inset else 0.0
			frame.anchor_right = 0.95 if inset else 1.0
			frame.anchor_bottom = 0.95 if inset else 1.0
			await settle(0.7)
			for index in 3:
				await click(explorer.selectors[index])
				verify_state(index)
				check(explorer.history_sections.visible == (index == 1), "history micro-sections only in HISTORY")
				check(explorer.caption.get_parent() == explorer.media_column, "caption belongs to media column")
				check(explorer.caption.global_position.y - explorer.image_area.get_global_rect().end.y <= 5, "caption immediately beneath media frame")
				check(explorer.takeaway_label.get_global_rect().position.x >= panel.global_position.x + 24, "takeaway side padding")
				for label in panel.find_children("*", "Label", true, false):
					check(not label.is_visible_in_tree() or not label.text.contains("Narration pending."), "no visitor development status")
				check(panel.get_global_rect().grow(1).encloses(panel.layout.get_global_rect()), "layout within parent")
				check(panel.get_global_rect().grow(1).encloses(explorer.takeaway_label.get_global_rect()), "takeaway always in parent")
				check(explorer.picture.size.y >= 140, "media retains usable height")
				for control in [panel.sources_button, panel.listen, panel.close_button, explorer.handle, explorer.selectors[0], explorer.selectors[1], explorer.selectors[2]]:
					check(control.size.y >= 48, "touch target height")
					check(panel.get_global_rect().grow(1).encloses(control.get_global_rect()), "target within parent")
				await capture(str(dimensions.x) + ("_inset_" if inset else "_full_") + str(index))
	for index in [0, 2, 1, 2]:
		explorer.select_state(index)
		await settle(0.025)
	await settle()
	verify_state(2)
	explorer.select_state(1)
	await settle()
	explorer.text_scroll.scroll_vertical = 10000
	await settle()
	check(explorer.text_scroll.scroll_vertical > 0, "compact history can scroll to observation cue")
	if render:
		await capture("854_history_scrolled")
	await drag_to(0.45)
	await drag_to(1.2)
	await drag_to(-0.2)
	await drag_to(0.55, true)
	await drag_to(1.0, true)
	await drag_to(0.0, true)
	explorer.selectors[0].grab_focus()
	await key(KEY_LEFT)
	verify_state(0)
	await key(KEY_RIGHT)
	verify_state(1)
	await key(KEY_RIGHT)
	await key(KEY_RIGHT)
	verify_state(2)
	explorer.selectors[0].grab_focus()
	await key(KEY_ENTER)
	verify_state(0)
	explorer.selectors[1].grab_focus()
	await key(KEY_SPACE)
	verify_state(1)
	await key(KEY_TAB)
	check(root.gui_get_focus_owner() == explorer.selectors[2], "Tab to next stop")
	await key(KEY_TAB, true)
	check(root.gui_get_focus_owner() == explorer.selectors[1], "Shift Tab to previous stop")
	await click(panel.sources_button)
	check(panel.sources.visible, "Sources opens")
	var position_before: Vector2 = explorer.handle.position
	await key(KEY_RIGHT)
	check(explorer.selected == 1 and explorer.handle.position == position_before, "Sources preserves selection/position")
	await key(KEY_TAB)
	check(panel.sources.is_ancestor_of(root.gui_get_focus_owner()), "Sources traps focus")
	if render:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("854_sources.png"))
	await key(KEY_ESCAPE)
	check(not panel.sources.visible and panel.active, "Escape closes only Sources")
	verify_state(1)
	explorer.select_state(2)
	root.size = Vector2i(960, 540)
	await settle(0.5)
	verify_state(2)
	explorer.select_state(1)
	panel.close_interaction()
	await settle()
	verify_state(0)
	check(not panel.active and not panel.audio.playing and not explorer._dragging, "close stops/resets")
	panel.open_interaction()
	await settle()
	verify_state(0)
	await key(KEY_BACKSPACE)
	check(not panel.active, "Backspace closes hotspot")
	panel.open_interaction()
	await settle()
	await click(panel.close_button)
	check(not panel.active, "Close button works")
	for node in panel.find_children("*", "Label", true, false):
		check(node.autowrap_mode == TextServer.AUTOWRAP_OFF or node.custom_minimum_size.x > 0, "wrapped label has width")
	preview.queue_free()
	await process_frame
	print("UH-EXT-01 Phase 5: ", checks, " checks; ", failures, " failures; render=", render)
	quit(1 if failures else 0)


func narration_check() -> void:
	check(panel.audio.stream.resource_path == "res://assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg", "exact researcher-approved file")
	await click(panel.listen)
	check(panel.audio.playing and panel.listen.button_pressed, "mouse starts narration with active styling")
	check(panel.audio.get_playback_position() < 1.0, "play starts at beginning")
	check(panel.listen.accessibility_name == "LISTEN" and panel.listen.accessibility_description.contains("stop narration"), "playing accessibility")
	for index in [1, 2, 0]:
		var before: float = panel.audio.get_playback_position()
		await click(explorer.selectors[index])
		check(panel.audio.playing and panel.audio.get_playback_position() >= before, "state change preserves continuous narration")
	var before_sources: float = panel.audio.get_playback_position()
	await click(panel.sources_button)
	check(panel.audio.playing and panel.audio.get_playback_position() >= before_sources, "Sources open preserves audio")
	var before_close: float = panel.audio.get_playback_position()
	await click(panel.source_close)
	check(panel.audio.playing and panel.audio.get_playback_position() >= before_close, "Sources close preserves audio")
	await click(panel.listen)
	check(not panel.audio.playing and not panel.listen.button_pressed and is_zero_approx(panel.audio.get_playback_position()), "mouse stop resets")
	panel.sources_button.grab_focus()
	for i in 12:
		if root.gui_get_focus_owner() == panel.listen:
			break
		await key(KEY_TAB)
	check(root.gui_get_focus_owner() == panel.listen, "Tab reaches Listen")
	await key(KEY_ENTER)
	check(panel.audio.playing and panel.audio.get_playback_position() < 1.0, "Enter replays from beginning")
	await key(KEY_SPACE)
	check(not panel.audio.playing and is_zero_approx(panel.audio.get_playback_position()), "Space stops and resets")
	# Synthetic touch exercises the engine's touch-to-mouse UI path.
	Input.emulate_mouse_from_touch = true
	for down in [true, false]:
		var event := InputEventScreenTouch.new()
		event.index = 0
		event.position = panel.listen.get_global_rect().get_center()
		event.pressed = down
		Input.parse_input_event(event)
		await process_frame
	await settle()
	check(panel.audio.playing, "touch starts narration")
	print("Waiting for supplied narration's natural finish (21 seconds).")
	await settle(panel.audio.stream.get_length() + 0.5)
	check(not panel.audio.playing and not panel.listen.button_pressed, "natural finish returns idle")
	check(is_zero_approx(panel.audio.get_playback_position()), "natural finish resets playback")
	await click(panel.listen)
	check(panel.audio.playing and panel.audio.get_playback_position() < 1.0, "replay after natural finish starts at beginning")
	panel.close_interaction()
	check(not panel.audio.playing and not panel.listen.button_pressed and is_zero_approx(panel.audio.get_playback_position()), "full close stops and resets audio")
	panel.open_interaction()
	await settle()
	check(not panel.listen.disabled and not panel.audio.playing and not panel.listen.button_pressed, "reopen enabled idle without autoplay")
	verify_state(0)
