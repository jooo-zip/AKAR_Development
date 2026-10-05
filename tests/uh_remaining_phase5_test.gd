extends SceneTree
## Dedicated checkpoint: --script res://tests/uh_remaining_phase5_test.gd -- uh_ext_02
var checks: int = 0
var failures: int = 0
var id: String
var component: Control
var explorer: Control
var output: String
func _initialize() -> void:
	run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(id + ": " + message)
func settle(seconds: float = 0.3) -> void:
	await create_timer(seconds).timeout
func click(button: Control, touch: bool = false) -> void:
	Input.emulate_mouse_from_touch = true
	var ancestor: Node = button.get_parent()
	while ancestor != null:
		if ancestor is ScrollContainer:
			ancestor.ensure_control_visible(button)
		ancestor = ancestor.get_parent()
	await process_frame
	for down in [true, false]:
		if touch:
			var event := InputEventScreenTouch.new()
			event.index = 0
			event.pressed = down
			event.position = button.get_global_rect().get_center()
			Input.parse_input_event(event)
		else:
			var event := InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = down
			event.position = button.get_global_rect().get_center()
			Input.parse_input_event(event)
		await process_frame
	await settle()
func key(code: Key, shift: bool = false) -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = down
		event.shift_pressed = shift
		Input.parse_input_event(event)
		await process_frame
	await settle()
func run() -> void:
	id = OS.get_cmdline_user_args()[0]
	output = OS.get_environment("TEMP").path_join("akar_remaining_phase5")
	if Engine.is_editor_hint():
		await editor_check()
		return
	root.content_scale_size = Vector2i.ZERO
	root.size = Vector2i(1280, 720)
	var parent := Control.new()
	root.add_child(parent)
	parent.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	component = load("res://scenes/landmarks/urduja_house/components/" + id + ".tscn").instantiate()
	parent.add_child(component)
	explorer = component.interaction
	var closed_count: Array[int] = [0]
	component.closed.connect(func() -> void: closed_count[0] += 1)
	component.open_interaction()
	await settle()
	check(not component.audio.playing and not component.listen.disabled, "enabled without autoplay")
	# Ordinary Inspector layout properties remain authoritative at runtime.
	var margin: MarginContainer = component.get_node("Panel/MainMargin")
	var original_margin: int = margin.get_theme_constant("margin_left")
	margin.add_theme_constant_override("margin_left", original_margin + 3)
	var media_column: VBoxContainer = component.get_node("%MediaColumn")
	var original_ratio: float = media_column.size_flags_stretch_ratio
	media_column.size_flags_stretch_ratio = 0.57
	if id == "uh_int_01":
		check(explorer.lens_position.is_equal_approx(Vector2(0.5,0.5)), "lens opens centered")
	for dimensions in [Vector2i(1280,720),Vector2i(960,540),Vector2i(854,480)]:
		root.size = dimensions
		for inset in [false,true]:
			parent.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			if inset:
				parent.anchor_left=0.05
				parent.anchor_top=0.05
				parent.anchor_right=0.95
				parent.anchor_bottom=0.95
			await settle()
			for i in explorer.buttons.size():
				await click(explorer.buttons[i], i % 2 == 1)
				check(explorer.selected == i, "direct mouse/touch selection")
				check(component.get_node("%Heading").text == component.revision.headings[i], "state heading")
				check(component.get_node("%Body").text == component.revision.bodies[i], "state body")
				check(component.get_node("%Media").texture == component.revision.images[i], "documentary media mapping")
				check(not component.audio.playing, "selection never autoplays")
				if id == "uh_int_04":
					check(component.get_node("%RoomFocus").visible == (i == 0), "spatial focus only on interpretive view")
					if i == 0:
						for area in 3:
							await click(component.get_node("%Focus" + str(area)), area == 1)
							check(explorer.focus_index == area and explorer.outline.visible == (area != 2), "room spatial selection")
							check(not explorer.outline.visible or explorer.frame.get_global_rect().encloses(explorer.outline.get_global_rect()), "room focus follows fitted image")
							check(component.get_node("%Heading").text == component.revision.observation_headings[area], "room observation heading")
							check(component.get_node("%Body").text == component.revision.observation_bodies[area], "room observation body")
							check(component.get_node("%Note").text == component.revision.observation_notes[area], "room supporting line")
							await capture("room_"+str(dimensions.x)+str(inset)+"_"+str(area))
						check(not component.get_node("%Caption").visible, "interpretive disclosure only in Sources")
				if id == "uh_int_03" and i == 2:
					check(explorer.observation == -1, "hall exploration starts with approved intro")
					var plane: Control = component.get_node("%ObservationPlane")
					var frame: Control = component.get_node("%MediaFrame")
					var source_size := Vector2(531,352)
					var fitted: Vector2 = source_size * minf(frame.size.x/source_size.x, frame.size.y/source_size.y)
					check(plane.size.is_equal_approx(fitted), "hall markers follow letterboxed image")
					for area in 3:
						var marker: Button = component.get_node("%ObservationMarker"+str(area))
						check(marker.size.is_equal_approx(Vector2(52,52)) and plane.get_global_rect().grow(1).encloses(marker.get_global_rect()), "hall practical aligned touch target")
						await click(marker, area == 1)
						check(explorer.observation == area and marker.button_pressed, "hall mouse/touch observation")
						check(component.get_node("%Heading").text == component.revision.observation_headings[area], "hall approved observation heading")
						check(component.get_node("%Body").text == component.revision.observation_bodies[area], "hall approved observation body")
						await capture("hall_"+str(dimensions.x)+str(inset)+"_"+str(area))
				if id == "uh_int_03" and i == 1:
					await click(component.get_node("%Next"), true)
					check(explorer.event_index == 1 and explorer.media.texture == component.revision.event_images[1], "second event documentary image")
					check(component.get_node("%Heading").text == component.revision.event_titles[1] and component.get_node("%Body").text == "December 1, 2024", "second event title/date")
					check(component.get_node("%Note").text == "Photo by Ghe_Anne C. Palaganas", "approved photographer")
					if DisplayServer.get_name() != "headless":
						await RenderingServer.frame_post_draw
						root.get_texture().get_image().save_png(output.path_join(id+"_event2_"+str(dimensions.x)+str(inset)+".png"))
					await click(component.get_node("%Previous"))
					check(explorer.event_index == 0, "Previous event")
				if id == "uh_int_02":
					check(explorer.buttons[i].button_pressed, "time track snaps to selected date")
					check(component.get_node("%DocumentPanel").visible == (i == 0) and component.get_node("%OfficeTransfer").visible == (i == 2), "date and office transfer use UI graphics")
					if i == 2:
						await settle(0.8)
						check(explorer.office_progress > 0.0 and explorer.office_progress < 1.0, "only office token moves during sequence")
						await capture("office_mid_"+str(dimensions.x)+str(inset))
						await settle(1.5)
						check(explorer.office_complete and is_equal_approx(explorer.office_progress,1.0), "office animation completes")
						for name in ["ResidenceEndpoint","CapitolEndpoint","OfficeToken","ResidenceStatus","CapitolStatus"]:
							var visual: Control = component.get_node("%"+name)
							check(component.get_node("%OfficeTransfer").get_global_rect().grow(1).encloses(visual.get_global_rect()), "transfer layout fits "+name)
						check(component.get_node("%ResidenceStatus").modulate.a == 1.0 and component.get_node("%CapitolStatus").modulate.a == 1.0, "office moved residence remains")
				if id == "uh_int_01":
					check(explorer.image_rect().grow(1).encloses(explorer.lens.get_rect()), "lens clamped to fitted image after resize")
					check(explorer.sample.atlas == explorer.media.texture, "lens samples original painting")
				if id == "uh_ext_03":
					var plane: Control = component.get_node("%MarkerPlane")
					var frame: Control = component.get_node("%MediaFrame")
					var fitted: Vector2 = Vector2(4,3) * minf(frame.size.x/4,frame.size.y/3)
					check(plane.size.is_equal_approx(fitted), "markers account for fitted image letterboxing")
					var marker: Button = component.get_node("%Marker"+str(i))
					check(plane.get_global_rect().grow(1).encloses(marker.get_global_rect()), "marker in image")
					await click(marker, i % 2 == 0)
					check(explorer.selected == i and marker.button_pressed, "direct ring mouse/touch selection")

				var bounds: Rect2 = component.get_global_rect().grow(1)
				check(parent.get_global_rect().grow(1).encloses(component.get_global_rect()), "fits arbitrary parent")
				for name in ["Title","Sources","Listen","Close","MediaFrame","InfoScroll","Takeaway"]:
					var control: Control = component.get_node("%"+name)
					check(bounds.encloses(control.get_global_rect()), "bounds "+name)
				check(component.get_node("%MediaFrame").size.y >= 120, "useful media height")
				for button in explorer.buttons + [component.sources_button,component.listen,component.close_button]:
					check(button.size.y >= 48 and (bounds.encloses(button.get_global_rect()) or component.get_node("%InfoScroll").is_ancestor_of(button)), "usable touch target")
				if DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png(output.path_join(id+"_"+str(dimensions.x)+("_inset_" if inset else "_full_")+str(i)+".png"))
	if id == "uh_int_02":
		explorer.buttons[0].grab_focus()
		await key(KEY_END)
		check(explorer.selected == 3, "keyboard time track end")
		var rect: Rect2 = explorer.track.get_global_rect()
		var down := InputEventMouseButton.new()
		down.button_index = MOUSE_BUTTON_LEFT
		down.pressed = true
		down.position = explorer.buttons[3].get_global_rect().get_center()
		Input.parse_input_event(down)
		await process_frame
		var motion := InputEventMouseMotion.new()
		motion.position = rect.position + Vector2(4,rect.size.y/2)
		Input.parse_input_event(motion)
		await process_frame
		down.pressed = false
		down.position = motion.position
		Input.parse_input_event(down)
		await settle()
		check(explorer.selected == 0 and explorer.buttons[0].button_pressed, "mouse timeline drag snaps")
		await office_replay_checks()
	check(margin.get_theme_constant("margin_left") == original_margin + 3, "Inspector margins survive selection and resizing")
	check(is_equal_approx(media_column.size_flags_stretch_ratio, 0.57), "Inspector column ratio survives selection and resizing")
	margin.add_theme_constant_override("margin_left", original_margin)
	media_column.size_flags_stretch_ratio = original_ratio
	if id == "uh_int_01":
		await lens_drag(false)
		await lens_drag(true)
		explorer.lens.grab_focus()
		var previous: Vector2 = explorer.lens_position
		await key(KEY_LEFT)
		check(explorer.lens_position.x < previous.x, "keyboard lens movement")
	if id == "uh_int_03":
		explorer.select_state(2)
		await settle()
		for area in [2,0,1]:
			explorer.observe(area)
		check(explorer.observation == 1, "rapid hall observation latest input wins")
		var observation_button: Button = component.get_node("%ObservationChoice2")
		component.get_node("%InfoScroll").ensure_control_visible(observation_button)
		observation_button.grab_focus()
		await key(KEY_ENTER)
		check(explorer.observation == 2, "hall keyboard equivalent")
		explorer.select_state(1)
		await settle()
		for direction in [1,-1,1]:
			explorer.change_event(direction)
			await settle(0.025)
		await settle()
		check(explorer.event_index == 1 and component.get_node("%Heading").text == component.revision.event_titles[1], "rapid carousel latest input wins")
		explorer.event_index = 0
	if id == "uh_int_04":
		explorer.select_state(0)
		await settle()
		check(explorer.focus_index == -1, "room mode returns to default intro")
		component.get_node("%InfoScroll").ensure_control_visible(component.get_node("%Focus1"))
		component.get_node("%Focus1").grab_focus()
		await key(KEY_SPACE)
		check(explorer.focus_index == 1, "room keyboard observation")
	for i in [1,0,1,0]:
		explorer.select_state(i)
		await settle(0.025)
	await settle()
	check(explorer.selected == 0 and component.get_node("%Heading").text == component.revision.headings[0], "latest selection wins")
	check(is_equal_approx(explorer.media.modulate.a,1), "no stale fade")
	explorer.buttons[0].grab_focus()
	await key(KEY_RIGHT)
	check(explorer.selected == 1, "arrow navigation")
	await key(KEY_TAB)
	check(root.gui_get_focus_owner() != null, "Tab focus")
	await key(KEY_TAB,true)
	check(root.gui_get_focus_owner() == explorer.buttons[1], "reverse Tab")
	await click(component.listen)
	check(component.audio.playing and component.listen.button_pressed, "Listen mouse start")
	var before: float = component.audio.get_playback_position()
	await click(explorer.buttons[0])
	check(component.audio.playing and component.audio.get_playback_position() >= before, "selection retains audio")
	before = component.audio.get_playback_position()
	await click(component.sources_button)
	check(component.sources.visible and component.audio.playing and component.audio.get_playback_position() >= before, "Sources preserves audio")
	await key(KEY_ESCAPE)
	check(component.active and not component.sources.visible and explorer.selected == 0, "Escape closes only Sources")
	await click(component.sources_button)
	await click(component.source_close, true)
	check(component.active and not component.sources.visible, "Close Sources touch button")
	await click(component.sources_button)
	await key(KEY_BACKSPACE)
	check(component.active and not component.sources.visible, "Backspace closes only Sources")
	component.listen.grab_focus()
	await key(KEY_SPACE)
	check(not component.audio.playing and is_zero_approx(component.audio.get_playback_position()), "Space stops/resets")
	await key(KEY_ENTER)
	check(component.audio.playing and component.audio.get_playback_position() < 1, "Enter replays from zero")
	component.audio.seek(component.audio.stream.get_length()-0.15)
	await settle(0.7)
	check(not component.audio.playing and not component.listen.button_pressed, "natural end signal resets idle")
	await click(component.listen,true)
	check(component.audio.playing, "touch Listen")
	explorer.select_state(1)
	await click(component.close_button)
	check(not component.active and not component.audio.playing and explorer.selected == 0 and closed_count[0] == (2 if id == "uh_int_02" else 1), "close resets and signals")
	component.open_interaction()
	await settle()
	check(component.active and explorer.selected == 0 and not component.audio.playing, "reopen default without autoplay")
	component.reset_interaction()
	check(component.active and explorer.selected == 0, "public reset stays open")
	component.close_interaction()
	parent.queue_free()
	await process_frame
	# Harness instances the same production scene, with no required environment.
	var folder: String = "exterior" if id.contains("ext") else ("summary" if id.contains("end") else "interior")
	var harness: Control = load("res://scenes/landmarks/urduja_house/"+folder+"/"+id+".tscn").instantiate()
	root.add_child(harness)
	await settle()
	var hot: Control = harness.get_node("Frame/Hotspot")
	check(hot.active, "F6 opens production")
	hot.close_interaction()
	await settle()
	check(harness.get_node("Reopen").visible, "harness reopen shown")
	await click(harness.get_node("Reopen"))
	check(hot.active and not hot.audio.playing, "harness reopens idle")
	harness.queue_free()
	await process_frame
	finish()
func editor_check() -> void:
	await settle(4)
	while EditorInterface.get_resource_filesystem().is_scanning():
		await process_frame
	EditorInterface.open_scene_from_path("res://scenes/landmarks/urduja_house/components/"+id+".tscn")
	await settle(1)
	var scene: Control = EditorInterface.get_edited_scene_root()
	check(scene.size.is_equal_approx(Vector2(1280,720)), "editor reference rect")
	for name in ["Title","Content","MediaFrame","InfoScroll","Takeaway","Navigation"]:
		var control: Control = scene.get_node("%"+name)
		check(control.size.x > 0 and control.size.y > 0 and (scene.get_global_rect().encloses(control.get_global_rect()) or scene.get_node("%InfoScroll").is_ancestor_of(control)), "complete editor layout "+name)
		EditorInterface.edit_node(control)
		check(EditorInterface.get_inspector().get_edited_object() == control, "Inspector editable "+name)
	check(scene.get_node("%Media").texture != null or scene.get_node("%DocumentPanel").visible, "editor media present")
	if id == "uh_int_02":
		scene.get_node("%DocumentPanel").hide()
		scene.get_node("%OfficeTransfer").show()
		await settle()
		for name in ["OfficeTransfer","ResidenceEndpoint","CapitolEndpoint","OfficeToken","OfficeLine","ResidenceStatus","CapitolStatus"]:
			var visual: Control = scene.get_node("%"+name)
			check(visual.size.x > 0 and scene.get_global_rect().encloses(visual.get_global_rect()), "editor-authored transfer graphic "+name)
			EditorInterface.edit_node(visual)
			check(EditorInterface.get_inspector().get_edited_object() == visual, "editable transfer "+name)
	if id == "uh_int_03":
		scene.get_node("%ObservationAspect").show()
		await settle()
		for i in 3:
			var marker: Control = scene.get_node("%ObservationMarker"+str(i))
			check(scene.get_node("%ObservationPlane").get_global_rect().encloses(marker.get_global_rect()), "editor-authored hall marker")
			EditorInterface.edit_node(marker)
			check(EditorInterface.get_inspector().get_edited_object() == marker, "editable observation marker")
	finish()
func finish() -> void:
	print("CHECKPOINT ",id," checks=",checks," failures=",failures," editor=",Engine.is_editor_hint()," renderer=",DisplayServer.get_name())
	quit(0 if failures == 0 else 1)

func lens_drag(touch: bool) -> void:
	var start: Vector2 = explorer.lens.get_global_rect().get_center()
	var destination: Vector2 = explorer.frame.global_position + explorer.frame.size + Vector2(100,100)
	if touch:
		var down := InputEventScreenTouch.new()
		down.index = 2
		down.pressed = true
		down.position = start
		Input.parse_input_event(down)
		await process_frame
		var motion := InputEventScreenDrag.new()
		motion.index = 2
		motion.position = destination
		Input.parse_input_event(motion)
		await process_frame
		down.pressed = false
		down.position = destination
		Input.parse_input_event(down)
	else:
		var down := InputEventMouseButton.new()
		down.button_index = MOUSE_BUTTON_LEFT
		down.pressed = true
		down.position = start
		Input.parse_input_event(down)
		await process_frame
		var motion := InputEventMouseMotion.new()
		motion.position = destination
		Input.parse_input_event(motion)
		await process_frame
		down.pressed = false
		down.position = destination
		Input.parse_input_event(down)
	await settle()
	check(explorer.pointer == -2, "lens releases pointer")
	check(explorer.lens_position.x > 0.5, "lens drag moves")
	check(explorer.image_rect().grow(1).encloses(explorer.lens.get_rect()), "drag stays in painting")


func capture(suffix: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join(id+"_"+suffix+".png"))

func office_replay_checks() -> void:
	explorer.select_state(2)
	await settle(1.0)
	check(explorer.office_progress > 0.0 and explorer.office_progress < 1.0, "office starts from residence")
	await click(explorer.buttons[2], true)
	check(explorer.office_progress < 0.1 and not explorer.office_complete, "touch reselect replays office transfer")
	explorer.buttons[2].grab_focus()
	await key(KEY_ENTER)
	check(explorer.office_progress < 0.1, "keyboard reselect replays office transfer")
	await settle(0.8)
	explorer.select_state(3)
	check(is_zero_approx(explorer.office_progress) and not component.get_node("%OfficeTransfer").visible, "leaving cancels office transient immediately")
	for state in [2,1,2,3,2]:
		explorer.select_state(state)
		await settle(0.03)
	await settle(0.2)
	check(explorer.selected == 2 and explorer.office_progress < 0.1, "rapid return starts cleanly")
	await click(component.listen)
	check(component.audio.playing, "narration during office animation")
	await click(component.sources_button)
	check(component.audio.playing, "Sources during office animation preserves audio")
	await click(component.source_close)
	await settle(2.3)
	check(explorer.office_complete, "office animation resumes after Sources")
	explorer.select_state(2)
	await settle(0.9)
	component.close_interaction()
	check(is_zero_approx(explorer.office_progress) and not component.audio.playing, "close during office animation resets")
	component.open_interaction()
	await settle()
	check(explorer.selected == 0 and not component.get_node("%OfficeTransfer").visible, "reopen starts at 1953")
