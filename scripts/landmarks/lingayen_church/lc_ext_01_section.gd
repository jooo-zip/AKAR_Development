extends ConferenceRoomConceptEntry
## Only the extra per-section fields needed by this three-part interpretation panel.

@export var section_id: StringName
@export var tab_label: String = ""
@export_multiline var takeaway: String = ""
@export var image: Texture2D
@export var image_caption: String = ""
@export_multiline var source_credit: String = ""
@export var image_credit: String = ""
