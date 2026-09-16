class_name HistoricalVideoContent
extends Resource
## Supplied media and text, separate from playback behavior.

@export var title: String = ""
@export var video: VideoStream
@export_multiline var transcript: String = ""
@export var transcript_is_development: bool = false
