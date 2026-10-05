extends RefCounted
## Presentation adapter for Urduja instances only; shared implementations stay unchanged.

static func configure(panel: Control, id: String) -> void:
	if panel is InteractiveArtworkViewer:
		for control in [panel._title, panel._audio_controls, panel._sources_button, panel._close, panel._detail_sources]:
			control.hide()
		var sections: VBoxContainer = panel._sections
		# Keep the existing three sections, with the artwork still occupying half the canvas.
		sections.add_theme_constant_override("separation", 6)
		sections.hide()
		var navigation := HBoxContainer.new()
		navigation.name = "SectionRail"
		panel.get_node("Main/Margin/Layout").add_child(navigation)
		panel._section_title.add_theme_font_size_override("font_size", 22)
		panel._regions.reparent(panel.get_node("Detail/Margin/Layout"))
		panel.get_node("Detail/Margin/Layout").move_child(panel._regions, 2)
		panel._regions.columns = 4
		panel._inspection_heading.hide()
		panel._viewing.add_theme_font_size_override("font_size", 18)
	elif panel is InteractiveTimeline:
		panel._title.get_parent().hide()
		panel._speaker.get_parent().get_parent().hide()
		panel._sources_button.hide()
		panel._track.custom_minimum_size.x = 320
		panel._image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		var caption := Label.new()
		caption.name = "MediaClassification"
		caption.custom_minimum_size.x = 1
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption.add_theme_font_size_override("font_size", 16)
		var main_layout := panel.get_node("Main/Margin/Layout")
		main_layout.add_child(caption)
		main_layout.move_child(caption, 2)
		panel.milestone_changed.connect(func(_index: int) -> void: refresh(panel, id))
	elif panel is CeremonialHallInteraction:
		panel._title.get_parent().hide()
		for control in [panel._speaker, panel._sources_button, panel._space_sources]:
			control.hide()
		panel._sections[0].text = "ABOUT THE HALL"
		panel._sections[1].text = "OFFICIAL EVENTS"
		panel._sections[2].text = "VIEW THE SPACE"
		panel.section_changed.connect(func(_index: int) -> void: refresh(panel, id))
	elif panel is HistoricalSummaryInteraction:
		panel._title.get_parent().hide()
		panel._introduction.hide()
	# Respect Containers while removing unnecessary nested margins at compact sizes.
	for node in panel.find_children("*", "MarginContainer", true, false):
		for side in ["left", "right", "top", "bottom"]:
			node.add_theme_constant_override("margin_" + side, 8)
	panel.resized.connect(func() -> void: resize(panel, id))

static func refresh(panel: Control, _id: String) -> void:
	if panel is CeremonialHallInteraction:
		panel._speaker.hide()
		panel._space_sources.hide()
		panel._sources_button.hide()
		panel._detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel._detail.custom_minimum_size.x = 1
	if panel is InteractiveArtworkViewer:
		panel._audio_controls.hide()
		for button in panel._section_buttons:
			button.reparent(panel.get_node("Main/Margin/Layout/SectionRail"))
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.add_theme_font_size_override("font_size", 16)
		panel._sections.hide()
		for button in panel._region_buttons:
			button.add_theme_font_size_override("font_size", 16)
	if panel is InteractiveTimeline:
		panel._audio_pending.hide()
		var entry: InteractiveTimelineEntry = panel.content.entries[panel.get_selected_index()]
		panel.get_node("Main/Margin/Layout/MediaClassification").text = "AKAR INTERPRETIVE ART · Not a historical photograph." if entry.pixel_art else "DOCUMENTARY IMAGE · " + ("Present-day photograph." if panel.get_selected_index() == 3 else "Capture date unverified; not evidence of the selected year.")
	resize(panel, _id)

static func prepare_open(panel: Control) -> void:
	if panel is InteractiveArtworkViewer:
		panel._sections.show()
		for button in panel._section_buttons:
			button.reparent(panel._sections)

static func resize(panel: Control, _id: String) -> void:
	if not panel.is_node_ready():
		return
	for node in panel.find_children("*", "Label", true, false):
		if node.autowrap_mode != TextServer.AUTOWRAP_OFF:
			node.custom_minimum_size.x = 1
	if panel is InteractiveArtworkViewer:
		panel._body.add_theme_font_size_override("font_size", 20)
		panel._inspection_body.add_theme_font_size_override("font_size", 20)
		panel._regions.columns = 4
		panel._fit_artwork.call_deferred()
	elif panel is InteractiveTimeline:
		panel._body.add_theme_font_size_override("font_size", 20)
	elif panel is CeremonialHallInteraction:
		panel._body.add_theme_font_size_override("font_size", 20)
		panel._detail.add_theme_font_size_override("font_size", 18)
		panel._heading.add_theme_font_size_override("font_size", 22)
	elif panel is HistoricalSummaryInteraction:
		panel._body.add_theme_font_size_override("font_size", 20)

