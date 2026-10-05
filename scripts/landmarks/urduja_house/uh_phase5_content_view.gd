@tool
extends Node
## Only binds researcher content; never sizes or creates editor UI.
@export var content: Resource
func _ready() -> void:
	if Engine.is_editor_hint():
		refresh()
func refresh(index: int = 0) -> void:
	if content == null:
		return
	var scene := get_parent()
	for pair in [["Title", content.title], ["Subtitle", content.subtitle], ["Heading", content.headings[index]], ["Body", content.bodies[index]], ["Caption", content.captions[index]], ["Takeaway", content.takeaway], ["Note", content.notes[index]], ["Introduction", content.introduction], ["Reflection", content.reflection]]:
		var label: Label = scene.get_node("%" + pair[0])
		label.text = pair[1]
		label.visible = not label.text.is_empty()
	var picture: TextureRect = scene.get_node("%Media")
	picture.texture = content.images[index]
	picture.accessibility_name = content.captions[index]
	picture.visible = picture.texture != null
	var date: Label = scene.get_node("%DocumentPanel")
	date.visible = picture.texture == null
	date.text = content.labels[index] + "\n" + content.headings[index].to_upper()
	for i in content.labels.size():
		var button: Button = scene.get_node("%Choice" + str(i))
		button.text = content.labels[i]
		button.accessibility_name = content.labels[i]
