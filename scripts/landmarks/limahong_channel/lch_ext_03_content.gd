extends ConferenceRoomContent
## Approved prose and adjustable schematic positions for the layered siege map.
@export var stage_labels: PackedStringArray
@export var date_labels: PackedStringArray
@export var stage_notices: PackedStringArray
@export_multiline var permanent_disclaimer: String
@export_multiline var compact_disclaimer: String
@export var settlement_label: String
@export var fortified_settlement: Texture2D
@export var blockade_marker: Texture2D
@export var escape_vessel: Texture2D
## Positions on the fitted illustration; these are not historical coordinates.
@export var settlement_anchor := Vector2(0.39, 0.47)
@export var blockade_anchors := PackedVector2Array([Vector2(0.18, 0.44), Vector2(0.35, 0.12), Vector2(0.60, 0.35), Vector2(0.53, 0.64)])
## Intermediate schematic points. Both line and vessel use the same Curve2D.
@export var passage_points := PackedVector2Array([Vector2(0.43, 0.60), Vector2(0.51, 0.71)])
@export var water_exit_anchor := Vector2(0.66, 0.90)
