class_name InteractiveTimelineContent
extends Resource

@export var title: String = ""
@export var prompt: String = ""
@export var entries: Array[InteractiveTimelineEntry] = []
@export var narration_stream: AudioStream
## Leave empty until a matching researcher-approved transcript is supplied.
@export_multiline var narration_transcript: String = ""
@export_multiline var no_image_message: String = ""
