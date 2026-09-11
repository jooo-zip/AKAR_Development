class_name HistoricalHotspotContent
extends Resource
## Researcher-supplied content only. This resource contains no navigation logic.

@export var title: String = ""
@export_multiline var body: String = ""
@export var image: Texture2D
@export var narration: AudioStream
@export_multiline var transcript: String = ""
@export_multiline var source_credit: String = ""
