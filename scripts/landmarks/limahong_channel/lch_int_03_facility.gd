extends Resource
## A planning category, never a runtime completion/unlock state.
enum FacilityStatus { ORIGINAL_PLAN, EXISTING, PHASED }
@export var facility_id: String
@export var display_name: String
@export var status: FacilityStatus = FacilityStatus.ORIGINAL_PLAN
@export_multiline var status_note: String

func status_label() -> String:
	return ["ORIGINAL PLAN", "EXISTING", "PHASED / UNDER DEVELOPMENT"][status]
