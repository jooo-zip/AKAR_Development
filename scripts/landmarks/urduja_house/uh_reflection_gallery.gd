extends "res://scripts/landmarks/urduja_house/uh_phase5_explorer.gd"
## Selection only; no visited/completion state or stored response.
func _present(index: int) -> void:
	super._present(index)
	# Supplied exterior JPEG has EXIF orientation 3, ignored by Godot's importer.
	# Correct its display without altering the source bytes or other gallery images.
	media.flip_h = index == 4
	media.flip_v = index == 4
