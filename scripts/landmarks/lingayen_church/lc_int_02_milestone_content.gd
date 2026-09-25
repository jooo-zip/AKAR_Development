class_name LCINT02MilestoneContent
extends Resource

@export var milestone_id: StringName
@export var year_short: String = ""
@export var date_display: String = ""
@export var era_id: StringName
@export var era_display: String = ""
@export var title: String = ""
@export var context_label: String = ""
@export var change_label: String = ""
@export var result_label: String = ""
## down: succession; plus: additional role; none: retained parallel status.
@export_enum("down", "plus", "none") var result_connector: String = "down"
@export_multiline var explanation: String = ""
@export var media_mode: StringName = &"TRANSFORMATION_ONLY"
@export var media: Texture2D
@export_multiline var media_caption: String = ""
@export var media_credit: String = ""
@export var source_basis: String = ""
@export var show_historical_note: bool = false
@export var historical_note_title: String = ""
@export_multiline var historical_note_body: String = ""
@export var rights_status: String = ""
@export var narration: AudioStream
