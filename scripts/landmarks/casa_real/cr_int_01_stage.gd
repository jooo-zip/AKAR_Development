extends ConferenceRoomConceptEntry
enum Interaction { STATIC_PHOTO, STORM_REVEAL, COMPARISON, PHOTO_TOGGLE }
@export var year: String = ""
@export var selector_label: String = ""
@export var compact_label: String = ""
@export var prompt: String = ""
@export_multiline var identity_label: String = ""
@export var primary_texture: Texture2D
@export var secondary_texture: Texture2D
@export var primary_caption: String = ""
@export var secondary_caption: String = ""
@export_multiline var media_credit: String = ""
@export var helper_text: String = ""
@export var secondary_helper: String = ""
@export var interaction: Interaction = Interaction.STATIC_PHOTO
