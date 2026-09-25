class_name LCINT02Content
extends ConferenceRoomContent
## Source-backed project content prepared for validation. Shell concepts unused.

@export var subtitle: String = ""
@export var overview_heading: String = ""
@export_multiline var overview_body: String = ""
@export var overview_media: Texture2D
@export var overview_media_credit: String = ""
@export_multiline var takeaway: String = ""
@export var milestones: Array[LCINT02MilestoneContent] = []
@export_multiline var sources_text: String = ""
