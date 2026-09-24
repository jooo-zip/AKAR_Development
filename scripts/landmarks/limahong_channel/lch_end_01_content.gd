extends ConferenceRoomContent
## Reuses the shell's source and single narration fields; topics are independent.
const Topic = preload("res://scripts/landmarks/limahong_channel/lch_end_01_topic.gd")
@export var intro_heading: String
@export_multiline var intro_body: String
@export var topics: Array[Topic] = []
@export var default_detail_heading: String
@export_multiline var default_detail_body: String
@export var reflection_heading: String
@export_multiline var reflection_prompt: String
@export var takeaway_heading: String
