extends SceneTree
## Run with --editor --script res://tests/uh_ext_01_editor_layout_test.gd.
## Checks the actual edited scene, with non-tool interaction scripts inactive.
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func settle() -> void:
	await create_timer(0.5).timeout

func run() -> void:
	if not Engine.is_editor_hint():
		push_error("Use --editor for the editor-layout test.")
		quit(1)
		return
	await create_timer(4).timeout
	while EditorInterface.get_resource_filesystem().is_scanning():
		await process_frame
	EditorInterface.open_scene_from_path("res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn")
	EditorInterface.set_main_screen_editor("2D")
	await settle()
	var scene: Control = EditorInterface.get_edited_scene_root()
	var host: Control = scene.get_node("%Content")
	var view: Control = host.get_node("Discovery")
	check(scene.size.is_equal_approx(Vector2(1280, 720)), "editor root is reference size")
	check(host is MarginContainer, "Discovery host manages its child rect")
	check(view.size.is_equal_approx(host.size), "Discovery fills its host in editor")
	check(view.size.x > 1200 and view.size.y > 550, "Discovery is not a narrow strip")
	check(view.get_node("%MediaFrame").size.x > 650, "large media column")
	check(view.get_node("%InfoScroll").size.x > 450, "readable information column")
	for path in ["%MediaFrame", "%InfoScroll", "%DiscoveryRail", "%TakeawayMargin"]:
		var control: Control = view.get_node(path)
		check(scene.get_global_rect().encloses(control.get_global_rect()), path + " inside reference layout")
		EditorInterface.edit_node(control)
		check(EditorInterface.get_inspector().get_edited_object() == control, path + " selectable in Inspector")
	print("EDITOR_RECTS root=", scene.get_rect(), " discovery=", view.get_rect(), " media=", view.get_node("%MediaFrame").get_rect(), " info=", view.get_node("%InfoScroll").get_rect())
	if DisplayServer.get_name() != "headless":
		var viewport: SubViewport = EditorInterface.get_editor_viewport_2d()
		var scale_factor: float = minf(viewport.size.x / 1320.0, viewport.size.y / 760.0)
		viewport.global_canvas_transform = Transform2D(Vector2(scale_factor, 0), Vector2(0, scale_factor), Vector2(10, 10))
		viewport.canvas_transform = Transform2D.IDENTITY
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		RenderingServer.force_draw(false)
		viewport.get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("akar_uh_ext_01_editor_rect/editor.png"))
	# In-memory Inspector edits only. Never save the production scene from this test.
	var margin: MarginContainer = scene.get_node("Panel/MainMargin")
	var old_margin: int = margin.get_theme_constant("margin_left")
	margin.add_theme_constant_override("margin_left", 32)
	await settle()
	check(is_equal_approx(host.global_position.x, 32), "main margin edit visible in editor")
	margin.add_theme_constant_override("margin_left", old_margin)
	var media: VBoxContainer = view.get_node("%MediaColumn")
	var info: ScrollContainer = view.get_node("%InfoScroll")
	var old_width: float = media.size.x
	media.size_flags_stretch_ratio = 0.65
	info.size_flags_stretch_ratio = 0.35
	await settle()
	check(media.size.x > old_width, "column ratio edit visible in editor")
	media.size_flags_stretch_ratio = 0.57
	info.size_flags_stretch_ratio = 0.43
	media.add_theme_constant_override("separation", 11)
	view.get_node("%DiscoveryRail").custom_minimum_size.y = 64
	view.get_node("%TakeawayMargin").add_theme_constant_override("margin_top", 14)
	await settle()
	check(is_equal_approx(view.get_node("%MediaCaption").position.y - view.get_node("%MediaFrame").get_rect().end.y, 11), "caption spacing edit visible")
	check(is_equal_approx(view.get_node("%DiscoveryRail").size.y, 64), "rail height edit visible")
	check(is_equal_approx(view.get_node("%Takeaway").position.y, 14), "takeaway spacing edit visible")
	media.add_theme_constant_override("separation", 4)
	view.get_node("%DiscoveryRail").custom_minimum_size.y = 52
	view.get_node("%TakeawayMargin").add_theme_constant_override("margin_top", 6)
	print("UH-EXT-01 editor layout: %d checks; %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
