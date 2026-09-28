extends ConferenceRoomContent
const Personality = preload("res://scripts/landmarks/casa_real/cr_int_03_personality.gd")
@export var people: Array[Personality] = []
@export var period_ids: Array[StringName] = []
@export var period_labels: PackedStringArray
@export var compact_period_labels: PackedStringArray
@export var overview_heading: String
@export_multiline var overview_body: String
@export var overview_helper: String
@export var period_helper: String
@export var anchor_title: String
@export var anchor_location: String
