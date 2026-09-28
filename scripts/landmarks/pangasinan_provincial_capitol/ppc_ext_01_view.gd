extends ConferenceRoomConceptEntry
## Documentary view metadata; heading/body use the shared content fields.

@export var view_id: StringName
@export var selector_label: String
@export var context_label: String
@export_multiline var takeaway: String
@export var image: Texture2D
@export var caption: String
@export_multiline var media_credit: String
@export var permission_status: String
@export var observation_labels: PackedStringArray = []
@export var focus_region: Rect2 = Rect2()
