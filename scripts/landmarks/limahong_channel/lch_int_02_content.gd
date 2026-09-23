extends ConferenceRoomContent
## concepts contains exactly three lch_int_02_person resources in navigation order.
@export var panel_prompt: String
@export var event_title: String
@export_multiline var event_subtitle: String
@export var connection_heading: String
@export var comparison_hint: String
@export_range(0, 2) var default_person: int = 1
@export var wide_event_anchor := Vector2(0.5, 0.58)
@export var medium_event_anchor := Vector2(0.5, 0.71)
@export var compact_event_anchor := Vector2(0.5, 0.82)
