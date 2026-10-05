extends "res://scripts/landmarks/urduja_house/uh_revision_content.gd"
## Per-perspective media for the existing identity explorer; other hotspots are unchanged.
@export var context_labels: PackedStringArray
@export var images: Array[Texture2D]
@export var captions: PackedStringArray

@export var history_years: PackedStringArray
@export var history_headings: PackedStringArray
@export_multiline var history_photo_body: String
@export var observation_label: String
@export_multiline var observation_text: String
