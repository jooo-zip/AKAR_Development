extends Resource
## Approved interpretive text and documentary provenance, independent of UI state.
@export var id: StringName
@export var display_name: String
@export var short_name: String
@export var role_label: String
@export var period_id: StringName
@export var period_label: String
@export var date_label: String
@export var compact_date: String
@export_multiline var contribution: String
@export var portrait: Texture2D
@export var context_image: Texture2D
@export var context_label: String
@export var portrait_source_name: String
@export var portrait_source_reference: String
@export var portrait_source_url: String
@export var portrait_credit: String
@export var portrait_permission_status: String
@export var historical_source_name: String
@export var historical_source_reference: String
@export_multiline var context_source: String
@export var context_permission_status: String
