extends ConferenceRoomConceptEntry
## Coordinates refer to the full main photograph, never to the screen or margins.

@export var observation_id: StringName
@export var label: String = ""
@export var marker_position: Vector2
@export var focus_rect: Rect2
@export var detail_image: Texture2D
## Optional normalized non-destructive crop of the main photo.
@export var detail_crop: Rect2
