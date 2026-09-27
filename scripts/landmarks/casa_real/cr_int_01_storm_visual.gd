extends Control
## Bounded procedural rain/wind over a neutral field, never over a building.
## No reconstruction, destruction, lightning bolt, particles or shader assets.
var intensity: float = 0.0
var darkness: float = 0.0
var flash: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	stop()

func start() -> void:
	_time = 0.0
	intensity = 0.0
	darkness = 0.0
	flash = 0.0
	show()
	set_process(true)

func stop() -> void:
	set_process(false)
	intensity = 0.0
	darkness = 0.0
	flash = 0.0
	hide()
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.055, 0.075, 0.08))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, darkness))
	for i in 56:
		var origin := Vector2(fposmod(i * 89.0 - _time * 90.0, maxf(size.x, 1.0)), fposmod(i * 61.0 + _time * 245.0, maxf(size.y, 1.0)))
		draw_line(origin, origin + Vector2(-12, 29), Color(0.7, 0.8, 0.82, intensity * 0.32), 1.0, true)
	for i in 7:
		var origin := Vector2(fposmod(i * 173.0 - _time * 140.0, maxf(size.x, 1.0)), size.y * (i + 1) / 8.0)
		draw_line(origin, origin + Vector2(65, -6), Color(0.75, 0.8, 0.8, intensity * 0.14), 1.0, true)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.82, 0.87, 0.88, flash))
