extends ConferenceRoomContent
const StageEntry = preload("res://scripts/landmarks/casa_real/cr_int_01_stage.gd")
@export var overview: StageEntry
@export var storm_stream: AudioStream
@export var atmosphere_label: String = "ATMOSPHERIC INTERPRETATION"
@export var storm_helper: String = "TAP OR PRESS ENTER TO SKIP"
@export var before_label: String = "BEFORE RESTORATION"
@export var after_label: String = "AFTER RESTORATION"
