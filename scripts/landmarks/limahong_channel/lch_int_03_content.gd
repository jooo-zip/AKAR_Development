extends ConferenceRoomContent
const Media = preload("res://scripts/landmarks/limahong_channel/lch_int_03_media.gd")
const Facility = preload("res://scripts/landmarks/limahong_channel/lch_int_03_facility.gd")
@export_range(0, 2) var default_stage: int = 0
@export var groundbreaking: Media
@export var contributor_image: Media
@export var present_site: Media
@export_multiline var documentary_label: String
@export var present_site_label: String
@export var contributor_name: String
@export var contributor_role: String
@export_multiline var contributor_body: String
@export var preservation_nodes: PackedStringArray
@export var plan_heading: String
@export_multiline var qualification: String
@export var facilities: Array[Facility] = []
