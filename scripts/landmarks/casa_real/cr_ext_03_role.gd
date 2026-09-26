extends ConferenceRoomConceptEntry
const DocumentaryPhoto = preload("res://scripts/landmarks/casa_real/cr_ext_03_photo.gd")
@export var period: String = ""
@export var selector_label: String = ""
@export var compact_label: String = ""
@export var tagline: String = ""
@export var milestone_dates: PackedStringArray = []
@export var milestone_labels: PackedStringArray = []
@export var photos: Array[DocumentaryPhoto] = []
