class_name LCINT01Content
extends ConferenceRoomContent
## Source-backed project content prepared for validation; inherited shell fields
## supply hotspot_id, title and prompt. The shell's concept array is unused.

@export var subtitle: String = ""
@export var overview_heading: String = ""
@export_multiline var overview_body: String = ""
@export_multiline var takeaway: String = ""
@export var people: Array[LCINT01PersonContent] = []
@export_multiline var sources_text: String = ""
