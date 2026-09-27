extends ConferenceRoomContent
const Gallery = preload("res://scripts/landmarks/casa_real/cr_int_02_gallery.gd")
@export var subtitle: String
@export var overview_heading: String
@export_multiline var overview_body: String
@export var galleries: Array[Gallery] = []
@export var invitation: String
@export var directory_helper: String
@export var visit_modal_title: String
@export_multiline var visit_modal_body: String
@export var reservation_heading: String
@export var reservation_label: String
@export var reservation_url: String
@export var visitor_info_heading: String
@export var visitor_info_label: String
@export var visitor_info_url: String
@export var museum_inquiries_heading: String
@export var museum_phone: String
@export var museum_email: String
@export var visit_back_label: String
