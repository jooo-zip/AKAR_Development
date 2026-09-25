extends ConferenceRoomConceptEntry
## Interpretation and documentary provenance belong together in the resource.

@export var story_id: StringName
@export var label: String = ""
@export var compact_label: String = ""
@export var main_image: Texture2D
@export var main_caption: String = ""
@export var main_credit: String = ""
@export var support_image: Texture2D
@export_multiline var support_caption: String = ""
@export var support_credit: String = ""
@export_multiline var historical_note: String = ""
