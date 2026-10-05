@tool
extends Node
## Resource-backed editor content only: no historical text is duplicated in scenes.
## Runtime uses the same bindings. Inspector layout/style properties are never changed here.
@export var content: Resource
@export_enum("discovery", "header") var section: String = "discovery"

func _ready() -> void:
	if Engine.is_editor_hint():
		refresh()
		if section == "discovery":
			get_parent().get_node("%Stops").sort_children.connect(_editor_rail)
			_editor_rail()

func _editor_rail() -> void:
	align_rail.call_deferred(0)

func _notification(what: int) -> void:
	if not Engine.is_editor_hint() or not is_inside_tree():
		return
	# Keep editor preview text out of saved scenes; the Resource remains authoritative.
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		var names := PackedStringArray(["Title", "Subtitle"] if section == "header" else ["ContextLabel", "Heading", "Body", "MediaCaption", "Takeaway", "Year1953", "Year1982", "Heading1953", "Heading1982", "Body1953", "Body1982", "ObservationLabel", "ObservationText"])
		for label_name in names:
			get_parent().get_node("%" + label_name).text = ""
		if section == "discovery":
			get_parent().get_node("%MediaTexture").accessibility_name = ""
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		refresh.call_deferred()

func refresh(index: int = 0) -> void:
	if content == null:
		return
	var scene := get_parent()
	if section == "header":
		scene.get_node("%Title").text = content.title
		scene.get_node("%Subtitle").text = content.subtitle
		return
	var values: Dictionary = {
		"ContextLabel": content.context_labels[index], "Heading": content.headings[index],
		"Body": content.bodies[index], "MediaCaption": content.captions[index],
		"Takeaway": content.takeaway, "Year1953": content.history_years[0],
		"Year1982": content.history_years[1], "Heading1953": content.history_headings[0],
		"Heading1982": content.history_headings[1], "Body1953": content.bodies[1],
		"Body1982": content.history_photo_body, "ObservationLabel": content.observation_label,
		"ObservationText": content.observation_text,
	}
	for key in values:
		scene.get_node("%" + key).text = values[key]
	scene.get_node("%Body").visible = index != 1
	scene.get_node("%HistorySections").visible = index == 1
	scene.get_node("%MediaTexture").texture = content.images[index]
	scene.get_node("%MediaTexture").accessibility_name = content.captions[index]
	for i in 3:
		var button: Button = scene.get_node("%" + ["Place", "History", "Today"][i])
		button.text = content.labels[i]
		button.accessibility_name = content.labels[i]

func stop_position(index: int) -> Vector2:
	var scene := get_parent()
	var rail: Control = scene.get_node("%DiscoveryRail")
	var dot: Control = scene.get_node("%" + ["Place", "History", "Today"][index]).get_node("Node")
	return rail.get_global_transform().affine_inverse() * dot.get_global_rect().get_center()

func align_rail(index: int) -> void:
	if not is_inside_tree():
		return
	var scene := get_parent()
	var line: ColorRect = scene.get_node("%Rail")
	var selector: Control = scene.get_node("%Selector")
	var first := stop_position(0)
	line.position = first - Vector2(0, line.size.y * 0.5)
	line.size.x = stop_position(2).x - first.x
	selector.position = stop_position(index) - selector.size * 0.5
