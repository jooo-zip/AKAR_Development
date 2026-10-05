extends "res://scripts/landmarks/urduja_house/uh_revision_content.gd"
## Validated content is kept separate from presentation and interaction.
@export var images: Array[Texture2D]
@export var captions: PackedStringArray
@export var notes: PackedStringArray
@export_multiline var introduction: String
@export_multiline var reflection: String

@export var event_images: Array[Texture2D]
@export var event_titles: PackedStringArray
@export var event_dates: PackedStringArray
@export var event_credits: PackedStringArray
