extends Resource
## Optional documentary media resolves safely even when the supplied file is absent.
@export_file("*.png", "*.jpg", "*.jpeg") var image_path: String
@export var media_type: String
@export var event: String
@export var date: String
@export var photographer: String
@export var article_author: String
@export var source: String
@export var page_context: String
@export var credit: String
@export var permission_status: String = "PENDING"
@export var location: String

func resolve_image() -> Texture2D:
	if not image_path.is_empty() and ResourceLoader.exists(image_path, "Texture2D"):
		return load(image_path) as Texture2D
	push_warning("LCH-INT-03 documentary image unavailable: " + image_path)
	return null

func source_text() -> String:
	var result := ""
	for field in [["Media type", media_type], ["Event", event], ["Date", date],
		["Photographer", photographer], ["Article author", article_author],
		["Publisher/source", source], ["Page context", page_context], ["Credit", credit],
		["Permission/reuse", permission_status], ["Location", location]]:
		result += "%s: %s\n" % [field[0], field[1] if not field[1].is_empty() else "Pending researcher confirmation"]
	return result
