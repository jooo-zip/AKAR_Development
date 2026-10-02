@tool
extends Control
## Geometry is supplied in local coordinates after layout; no historical state here.
var paths: Array[PackedVector2Array] = []
var highlighted: Array[bool] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	for i in paths.size():
		if paths[i].size() < 2: continue
		var color := Color("bca76c") if highlighted[i] else Color("46564c")
		draw_polyline(paths[i], color, 2.0 if highlighted[i] else 1.0, true)
		if highlighted[i]:
			draw_circle(paths[i][0], 3.0, color)
			draw_circle(paths[i][-1], 3.0, color)
