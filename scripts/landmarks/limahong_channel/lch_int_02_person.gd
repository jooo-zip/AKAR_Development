extends ConferenceRoomConceptEntry
## heading/body reuse the shared content fields as display name/main body.
@export var person_id: String
@export var role_label: String
@export_multiline var connection_body: String
@export var portrait: Texture2D
@export var portrait_media_type: String
@export_multiline var portrait_credit: String
@export_multiline var portrait_source: String
@export_multiline var portrait_permission_status: String
@export var narration_audio: AudioStream
@export_multiline var narration_transcript: String
@export var wide_anchor: Vector2
@export var medium_anchor: Vector2
@export var compact_anchor: Vector2
