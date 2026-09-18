class_name CeremonialHallContent
extends Resource

@export var hotspot_id: String = ""
@export var title: String = ""
@export var prompt: String = ""
@export_multiline var body: String = ""
@export var hall_image: Texture2D
@export var hall_alt_text: String = ""
@export var pixel_art_image: Texture2D
@export var pixel_art_alt_text: String = ""
@export_multiline var hall_source_credit: String = ""
@export_multiline var pixel_art_source_credit: String = ""
@export var narration_stream: AudioStream
@export_multiline var narration_transcript: String = ""
@export var events: Array[CeremonialEventEntry] = []
