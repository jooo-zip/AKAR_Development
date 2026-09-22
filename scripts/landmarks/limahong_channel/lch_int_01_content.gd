extends ConferenceRoomContent
## Approved section prose and inspection defaults for the statue explorer.
@export var section_labels: PackedStringArray
@export var compact_section_labels: PackedStringArray
@export_range(0, 1) var default_section: int = 0
@export var default_lens_position := Vector2(0.42, 0.55)
