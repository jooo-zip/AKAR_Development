extends ConferenceRoomContent
const SummaryTheme = preload("res://scripts/landmarks/casa_real/cr_end_01_theme.gd")
@export var themes: Array[SummaryTheme] = []
@export var subtitle: String
@export var interpretation_label: String
@export_file("*.ogg") var narration_path: String
@export var reflect_label: String
@export var reflection_eyebrow: String
@export var reflection_heading: String
@export_multiline var reflection_question: String
@export_multiline var reflection_prompt: String
@export var reflection_background: Texture2D
@export var back_label: String
