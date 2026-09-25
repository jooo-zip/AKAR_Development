class_name LCINT01PersonContent
extends Resource

@export var person_id: StringName
@export var display_name: String = ""
@export var short_role: String = ""
@export var compact_display_name: String = ""
@export var compact_role: String = ""
@export var detail_heading: String = ""
@export_multiline var body: String = ""
@export_multiline var parish_connection: String = ""
@export var connection_label: String = "Connection to Lingayen Church"
@export var compact_source_line: String = ""
@export var primary_anchor: StringName
@export var secondary_anchor: StringName
@export var portrait: Texture2D
@export var image_credit: String = ""
@export var source_basis: String = ""
@export_multiline var internal_validation_note: String = ""
@export var rights_status: String = ""
@export var narration: AudioStream
