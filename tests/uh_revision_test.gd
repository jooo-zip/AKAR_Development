extends SceneTree
## Production components, real input, parent-sized layout and content safety.
var failures: int = 0
var checks: int = 0
const IDS := ["uh_ext_01", "uh_ext_02", "uh_ext_03", "uh_ent_01", "uh_int_01", "uh_int_02", "uh_int_03", "uh_int_04", "uh_end_01"]

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 8:
		await process_frame

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

func click(control: Control) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = control.get_global_rect().get_center()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame
	await settle()

func state_layout(panel, id: String) -> void:
	await settle()
	var controls: Array[Control] = []
	panel._controls(panel.layout, controls)
	for control in controls:
		if control is Button:
			check(panel.get_global_rect().grow(1).encloses(control.get_global_rect()), id + " internal-state bounds " + control.name)
	for node in panel.find_children("*", "Label", true, false):
		check(not node.text.contains("Princess Urduja Palace"), id + " no removed name")

func drag_rail(panel) -> void:
	var component = panel.interaction
	var stop: Control = component.selectors[0]
	var end: Vector2 = component.selectors[2].get_global_rect().get_center()
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = stop.get_global_rect().get_center()
	Input.parse_input_event(down)
	await process_frame
	var motion := InputEventMouseMotion.new()
	motion.position = end
	Input.parse_input_event(motion)
	await process_frame
	down.pressed = false
	down.position = end
	Input.parse_input_event(down)
	await settle()
	check(component.selected == 2, "identity mouse drag snaps to TODAY")
	# Direct touch follows the same selector method, without mouse-emulation dependence.
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = Vector2(20, 20)
	component.selectors[2].gui_input.emit(touch)
	touch.pressed = false
	touch.position = component.selectors[0].get_global_rect().get_center()
	Input.parse_input_event(touch)
	await settle()
	check(component.selected == 0, "identity touch release snaps to PLACE")

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	for id in IDS:
		var panel = load("res://scenes/landmarks/urduja_house/components/" + id + ".tscn").instantiate()
		root.add_child(panel)
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.open_interaction()
		await settle()
		check(panel.active, id + " opens")
		check(panel.listen.visible and panel.listen.disabled == (id == "uh_ent_01"), id + " temporary narration available only at its existing path")
		check(not panel.audio.playing, id + " no autoplay")
		for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(854, 480)]:
			root.size = dimensions
			for inset in [false, true]:
				panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				if inset:
					panel.anchor_left = 0.05
					panel.anchor_top = 0.05
					panel.anchor_right = 0.95
					panel.anchor_bottom = 0.95
				await settle()
				check(panel.host.size.y > 150, id + " usable content height " + str(dimensions))
				check(panel.layout.get_global_rect().end.x <= panel.get_global_rect().end.x + 1, id + " horizontal fit " + str(dimensions))
				check(panel.layout.get_global_rect().end.y <= panel.get_global_rect().end.y + 1, id + " vertical fit " + str(dimensions))
				var controls: Array[Control] = []
				panel._controls(panel.layout, controls)
				for control in controls:
					if control is Button:
						check(control.size.y >= 48, id + " target height " + control.name)
						check(panel.get_global_rect().grow(1).encloses(control.get_global_rect()), id + " button within component " + control.name)
				if "markers" in panel.interaction:
					for marker in panel.interaction.markers:
						check(panel.interaction.image_rect.grow(1).encloses(marker.get_rect()), id + " marker within image")
		var component = panel.interaction
		if id != "uh_ent_01":
			var filename: String = "uh-int-01-narration.ogg" if id == "uh_int_01" else id + "_narration.ogg"
			check(panel.audio.stream.resource_path == "res://assets/landmarks/urduja_house/audio/" + filename, id + " original narration path")
			await click(panel.listen)
			check(panel.audio.playing and panel.listen.button_pressed, id + " Listen starts from idle")
		if id == "uh_ext_01":
			await drag_rail(panel)
			component.selectors[0].grab_focus()
			await key(KEY_RIGHT)
			check(component.selected == 1, "identity keyboard right")
			await click(component.selectors[2])
			check(component.selected == 2, "identity direct mouse selection")
		if component.has_method("select_state"):
			for i in component.selectors.size():
				component.select_state(i)
				await state_layout(panel, id)
				check(component.heading.text == component.content.headings[i] and component.body.text == component.content.bodies[i], id + " exact state text")
				for a in component.markers.size():
					for b in range(a + 1, component.markers.size()):
						check(not component.markers[a].get_rect().intersects(component.markers[b].get_rect()), id + " marker touch areas do not overlap")
			for i in 20:
				component.select_state(i % component.selectors.size())
			check(component.selected == 19 % component.selectors.size(), id + " latest input wins")
		elif component is InteractiveTimeline:
			for i in 4:
				component.select_milestone(i)
				await state_layout(panel, id)
			for i in 20:
				component.select_milestone(i % 4)
			check(component.get_selected_index() == 3, "timeline latest input")
		elif component is HistoricalSummaryInteraction:
			for i in 5:
				component.select_summary(i)
				await state_layout(panel, id)
			for i in 20:
				component.select_summary(i % 5)
			check(component.get_selected_summary() == 4, "summary latest input")
			await create_timer(0.45).timeout
			check(is_zero_approx(component._glint_alpha), "summary shimmer fades completely")
			var requests: Array[int] = [0]
			panel.return_to_map_requested.connect(func() -> void: requests[0] += 1)
			component.request_return_to_map()
			check(requests[0] == 1 and panel.active, "Return emits once without forced close or navigation")
		elif component is CeremonialHallInteraction:
			for i in 3:
				component.select_section(i)
				await state_layout(panel, id)
			component.select_space_view(1)
			await state_layout(panel, id)
			component.select_section(1)
			for i in 20:
				component.select_event(i)
			check(component._event == 1, "event latest input")
		elif component is InteractiveArtworkViewer:
			for i in 3:
				component.select_section(i)
				await state_layout(panel, id)
			component.select_section(2)
			component.show_detail_view()
			component.select_inspection_region(3)
			await state_layout(panel, id)
			check(component._selected_region == 3, "artwork detail")
		await click(panel.sources_button)
		check(panel.sources.visible, id + " sources open")
		if id != "uh_ent_01" and id != "uh_end_01":
			check(panel.audio.playing, id + " internal selections and Sources preserve narration")
		check(panel.sources_text.text.contains("MEDIA CREDITS") and panel.sources_text.text.contains("HISTORICAL REFERENCES"), id + " structured sources")
		await key(KEY_TAB)
		check(panel.sources.is_ancestor_of(root.gui_get_focus_owner()), id + " sources focus trap")
		await key(KEY_ESCAPE)
		check(not panel.sources.visible, id + " sources close")
		if component is InteractiveArtworkViewer:
			await key(KEY_ESCAPE)
			check(not component._detail.visible and panel.active, "Escape closes artwork subview before hotspot")
		panel.sources_button.grab_focus()
		await key(KEY_ENTER)
		check(panel.sources.visible, id + " Enter activates Sources")
		await key(KEY_ESCAPE)
		await key(KEY_TAB, true)
		check(root.gui_get_focus_owner() != null, id + " Shift Tab focus")
		if id != "uh_ent_01":
			panel.stop_narration()
			panel.toggle_narration()
			await process_frame
			panel.toggle_narration()
			check(not panel.audio.playing and not panel.listen.button_pressed, id + " second activation stops and resets")
			panel.toggle_narration()
			check(panel.audio.get_playback_position() < 0.2, id + " subsequent activation starts at beginning")
			var other = load("res://scenes/landmarks/urduja_house/components/uh_ext_02.tscn").instantiate()
			root.add_child(other)
			other.open_interaction()
			check(not panel.audio.playing, id + " opening another hotspot stops prior narration")
			other.queue_free()
			await settle()
			panel.toggle_narration()
			panel.audio.seek(maxf(0, panel.audio.stream.get_length() - 0.02))
			await create_timer(0.25).timeout
			check(not panel.audio.playing and not panel.listen.button_pressed, id + " natural completion returns Listen to idle")
			panel.toggle_narration()
		panel.close_interaction()
		check(not panel.visible and not panel.audio.playing, id + " closes")
		panel.open_interaction()
		await settle()
		if "selected" in component:
			check(component.selected == 0, id + " resets")
		elif component is InteractiveTimeline:
			check(component.get_selected_index() == 0, "timeline resets")
		elif component is HistoricalSummaryInteraction:
			check(component.get_selected_summary() == 0, "summary resets")
		print(id, " tested")
		panel.close_interaction()
		root.remove_child(panel)
		panel.queue_free()
		await settle()
		var folder: String = "exterior" if "ext" in id else ("supporting" if "ent" in id else ("summary" if "end" in id else "interior"))
		var preview = load("res://scenes/landmarks/urduja_house/" + folder + "/" + id + ".tscn").instantiate()
		root.add_child(preview)
		await settle()
		check(preview.get_node("Frame/Hotspot").active, id + " F6 wrapper opens real component")
		if id == "uh_ent_01":
			preview.get_node("Frame/Hotspot").skip_interaction()
			check(not preview.get_node("Frame/Hotspot").active and preview.get_node("Reopen").visible, "video skip closes and permits reopening")
		preview.queue_free()
		await settle()
	print("Urduja revision: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)
