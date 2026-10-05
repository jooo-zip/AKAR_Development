extends Resource
## Revision-approved UI/content metadata. Narration may use researcher-authorized temporary recordings.
@export var hotspot_id: String
@export var title: String
@export var subtitle: String
@export_multiline var transcript: String
@export_multiline var historical_references: String
@export_multiline var media_credits: String
@export var narration: AudioStream
@export var labels: PackedStringArray
@export var headings: PackedStringArray
@export var bodies: PackedStringArray
@export var positions: PackedVector2Array
@export var icons: Array[Texture2D]
@export var image: Texture2D
@export var image_caption: String
@export_multiline var takeaway: String
