class_name ConferenceRoomContent
extends Resource

@export var hotspot_id: String = ""
@export var title: String = ""
@export var prompt: String = ""
@export var illustration: Texture2D
@export_multiline var illustration_alt_text: String = ""
@export var narration_stream: AudioStream
@export_multiline var narration_transcript: String = ""
@export_multiline var learning_takeaway: String = ""
@export_multiline var source_credit: String = ""
@export var concepts: Array[ConferenceRoomConceptEntry] = []
