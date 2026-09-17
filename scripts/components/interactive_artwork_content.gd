class_name InteractiveArtworkContent
extends Resource
## Researcher-supplied artwork and educational content, without behavior.

@export var title: String = ""
@export var prompt: String = ""
@export var artwork_texture: Texture2D
@export var optional_detail_texture: Texture2D
## Neutral spatial labels paired with normalized rectangles in the primary artwork.
@export var inspection_labels: PackedStringArray = []
@export var inspection_regions: Array[Rect2] = []
@export_multiline var alt_text: String = ""
@export var section_labels: PackedStringArray = []
@export var section_headings: PackedStringArray = []
@export var section_bodies: PackedStringArray = []
@export var narration_stream: AudioStream
@export_multiline var narration_transcript: String = ""
@export_multiline var source_credit: String = ""
