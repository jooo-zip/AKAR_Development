class_name LCEND01Content
extends ConferenceRoomContent
## Reuses shell metadata; inherited concepts and theme-specific audio are unused.

@export var subtitle: String = ""
@export var overview_heading: String = ""
@export_multiline var overview_body: String = ""
@export var center_media: Texture2D
@export var center_media_caption: String = ""
@export var center_media_credit: String = ""
@export var center_overview_primary: String = ""
@export var center_overview_secondary: String = ""
@export var center_accessible_name: String = ""
@export_multiline var center_fallback: String = ""
@export var narration_pending: String = "Narration pending."
@export var themes: Array[LCEND01ThemeContent] = []
@export_multiline var reflection_prompt: String = ""
@export_multiline var synthesis: String = ""
@export var narration: AudioStream
@export_multiline var sources_text: String = ""
