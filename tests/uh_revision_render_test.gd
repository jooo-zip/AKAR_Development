extends SceneTree
var failures: int = 0
const IDS := ["uh_ext_01", "uh_ext_02", "uh_ext_03", "uh_ent_01", "uh_int_01", "uh_int_02", "uh_int_03", "uh_int_04", "uh_end_01"]
func _initialize() -> void:
 run.call_deferred()
func run() -> void:
 root.content_scale_size = Vector2i.ZERO
 DirAccess.make_dir_recursive_absolute(OS.get_environment("TEMP") + "/akar_urduja_revision")
 for id in IDS:
  var folder: String = "exterior" if "ext" in id else ("supporting" if "ent" in id else ("summary" if "end" in id else "interior"))
  var preview = load("res://scenes/landmarks/urduja_house/" + folder + "/" + id + ".tscn").instantiate()
  root.add_child(preview)
  for dims in [Vector2i(1280,720), Vector2i(960,540), Vector2i(854,480)]:
   root.size = dims
   for inset in [false,true]:
    var frame = preview.get_node("Frame")
    frame.anchor_left = 0.05 if inset else 0
    frame.anchor_top = 0.05 if inset else 0
    frame.anchor_right = 0.95 if inset else 1
    frame.anchor_bottom = 0.95 if inset else 1
    await create_timer(0.75).timeout
    print(id, " ", dims, " ", inset, " SOURCES: ", preview.get_node("Frame/Hotspot").sources_button.get_global_rect(), " VISIBLE: ", preview.get_node("Frame/Hotspot").sources_button.is_visible_in_tree())
    await RenderingServer.frame_post_draw
    var shot := root.get_texture().get_image()
    var source_rect: Rect2 = preview.get_node("Frame/Hotspot").sources_button.get_global_rect()
    var sample := shot.get_pixel(int(source_rect.position.x + 4), int(source_rect.get_center().y))
    if sample.r < 0.09:
     failures += 1
     push_error("Header failed to render: " + id + " " + str(dims) + " inset=" + str(inset))
    shot.save_png(OS.get_environment("TEMP") + "/akar_urduja_revision/" + id + "_" + str(dims.x) + ("_inset" if inset else "_full") + ".png")
  var panel = preview.get_node("Frame/Hotspot")
  var component = panel.interaction
  if id == "uh_int_01":
   component.show_detail_view()
   component.select_inspection_region(3)
  elif id == "uh_int_03":
   component.select_section(1)
   component.select_event(1)
  elif id == "uh_int_02":
   component.select_milestone(2)
  elif id == "uh_end_01":
   component.select_summary(1)
  elif id == "uh_ent_01":
   component.transcript.show()
   component.player.hide()
  await create_timer(0.4).timeout
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(OS.get_environment("TEMP") + "/akar_urduja_revision/" + id + "_detail.png")
  panel.open_sources()
  await create_timer(0.2).timeout
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(OS.get_environment("TEMP") + "/akar_urduja_revision/" + id + "_sources.png")
  print(id, " rendered at all three sizes, full/inset and Sources")
  root.remove_child(preview)
  preview.queue_free()
  await process_frame
 print("Urduja rendered header failures: ", failures)
 quit(1 if failures else 0)
