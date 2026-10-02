extends SceneTree
## Generic host uses public API/signals only; never instances preview harnesses.
const IDS := ["lc_ext_01", "lc_ext_02", "lc_ext_03", "lc_int_01", "lc_int_02", "lc_end_01"]
var checks := 0
var failures := 0
var opened_count := 0
var closed_count := 0
var integration_closed := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	for i in 12: await process_frame

func run() -> void:
	root.content_scale_size = Vector2i.ZERO
	var layer := CanvasLayer.new()
	layer.name = "HotspotLayer"
	root.add_child(layer)
	var frame := Control.new()
	layer.add_child(frame)
	for id in IDS:
		var path := "res://scenes/landmarks/lingayen_church/%s/%s.tscn" % ["exterior" if id.begins_with("lc_ext") else "interior", id]
		var panel: Control = load(path).instantiate()
		opened_count = 0
		closed_count = 0
		integration_closed = 0
		panel.opened.connect(func(): opened_count += 1)
		panel.closed.connect(func(): closed_count += 1)
		panel.connect("hotspot_closed" if id.begins_with("lc_ext") else "close_requested", func(): integration_closed += 1)
		frame.add_child(panel)
		await settle()
		check(not panel.visible, id + " waits for host to open")
		check(panel.get_node_or_null(panel.EDITOR_VIEW_NAME) == null, "No editor branch at runtime")
		var iteration := 0
		for dimensions in [Vector2(1280,720), Vector2(960,540), Vector2(854,480)]:
			# Deliberately inset inside a larger viewport: parent, not window, sizes UI.
			root.size = Vector2i(dimensions + Vector2(120,80))
			frame.position = Vector2(60,40)
			frame.size = dimensions
			await settle()
			check(panel.size.is_equal_approx(dimensions), id + " uses host dimensions")
			for repeat in 2:
				iteration += 1
				check(panel.open_hotspot(), id + " public open")
				await create_timer(0.25).timeout
				check(panel.visible and opened_count == iteration, id + " opened signal")
				panel.open_sources()
				await settle()
				panel.close_sources()
				panel.close_interaction()
				await create_timer(0.3).timeout
				check(not panel.visible and closed_count == iteration and integration_closed == iteration, id + " host close notification")
		panel.queue_free()
		await settle()
		print("CHURCH INTEGRATION completed: ", id)
	layer.queue_free()
	await settle()
	print("CHURCH INTEGRATION: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
