extends ConferenceRoomContent
## Extends the shared historical prose resource with regional map presentation.
@export var stage_labels: PackedStringArray
@export var date_labels: PackedStringArray
@export_multiline var route_notice: String
@export var location_marker: Texture2D
@export var route_ship: Texture2D
@export var fortified_settlement: Texture2D
## Broad regional anchors on the supplied illustration, not surveyed locations.
@export var manila_anchor := Vector2(0.45, 0.76)
@export var pangasinan_anchor := Vector2(0.30, 0.50)
@export var schematic_points := PackedVector2Array([Vector2(0.45, 0.76), Vector2(0.08, 0.72), Vector2(0.08, 0.50), Vector2(0.30, 0.50)])
