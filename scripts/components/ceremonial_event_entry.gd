class_name CeremonialEventEntry
extends Resource
## Researcher-supplied event details. Empty credits remain unverified.

@export var event_id: String = ""
@export var event_title: String = ""
@export var date_label: String = ""
@export var venue: String = ""
@export_multiline var participating_institution: String = ""
@export var image: Texture2D
@export var image_alt_text: String = ""
@export_multiline var source_credit: String = ""
