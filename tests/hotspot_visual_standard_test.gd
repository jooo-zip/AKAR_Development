extends SceneTree
## Hotspot-scoped colors, selection contrast, scene loading, and generic-theme isolation.
## Run: --headless --path . --script res://tests/hotspot_visual_standard_test.gd
const INVENTORY = [
  {
    "id": "LC-EXT-01",
    "scene": "res://scenes/landmarks/lingayen_church/exterior/lc_ext_01.tscn",
    "preview": "res://scenes/landmarks/lingayen_church/exterior/lc_ext_01_preview.tscn"
  },
  {
    "id": "LC-EXT-02",
    "scene": "res://scenes/landmarks/lingayen_church/exterior/lc_ext_02.tscn",
    "preview": "res://scenes/landmarks/lingayen_church/exterior/lc_ext_02_preview.tscn"
  },
  {
    "id": "LC-EXT-03",
    "scene": "res://scenes/landmarks/lingayen_church/exterior/lc_ext_03.tscn",
    "preview": "res://scenes/landmarks/lingayen_church/exterior/lc_ext_03_preview.tscn"
  },
  {
    "id": "LC-INT-01",
    "scene": "res://scenes/landmarks/lingayen_church/interior/lc_int_01.tscn",
    "preview": "res://scenes/landmarks/lingayen_church/interior/lc_int_01_preview.tscn"
  },
  {
    "id": "LC-INT-02",
    "scene": "res://scenes/landmarks/lingayen_church/interior/lc_int_02.tscn",
    "preview": "res://scenes/landmarks/lingayen_church/interior/lc_int_02_preview.tscn"
  },
  {
    "id": "LC-END-01",
    "scene": "res://scenes/landmarks/lingayen_church/interior/lc_end_01.tscn",
    "preview": "res://scenes/landmarks/lingayen_church/interior/lc_end_01_preview.tscn"
  },
  {
    "id": "CR-EXT-01",
    "scene": "res://scenes/landmarks/casa_real/exterior/cr_ext_01.tscn",
    "preview": "res://scenes/landmarks/casa_real/exterior/cr_ext_01_preview.tscn"
  },
  {
    "id": "CR-EXT-02",
    "scene": "res://scenes/landmarks/casa_real/exterior/cr_ext_02.tscn",
    "preview": "res://scenes/landmarks/casa_real/exterior/cr_ext_02_preview.tscn"
  },
  {
    "id": "CR-EXT-03",
    "scene": "res://scenes/landmarks/casa_real/exterior/cr_ext_03.tscn",
    "preview": "res://scenes/landmarks/casa_real/exterior/cr_ext_03_preview.tscn"
  },
  {
    "id": "CR-INT-01",
    "scene": "res://scenes/landmarks/casa_real/interior/cr_int_01.tscn",
    "preview": "res://scenes/landmarks/casa_real/interior/cr_int_01_preview.tscn"
  },
  {
    "id": "CR-INT-02",
    "scene": "res://scenes/landmarks/casa_real/interior/cr_int_02.tscn",
    "preview": "res://scenes/landmarks/casa_real/interior/cr_int_02_preview.tscn"
  },
  {
    "id": "CR-INT-03",
    "scene": "res://scenes/landmarks/casa_real/interior/cr_int_03.tscn",
    "preview": "res://scenes/landmarks/casa_real/interior/cr_int_03_preview.tscn"
  },
  {
    "id": "CR-END-01",
    "scene": "res://scenes/landmarks/casa_real/end/cr_end_01.tscn",
    "preview": "res://scenes/landmarks/casa_real/end/cr_end_01_preview.tscn"
  },
  {
    "id": "PPC-EXT-01",
    "scene": "res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01.tscn",
    "preview": "res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01_preview.tscn"
  },
  {
    "id": "PPC-EXT-02",
    "scene": "res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_02.tscn",
    "preview": "res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_02_preview.tscn"
  },
  {
    "id": "PPC-INT-01",
    "scene": "res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01.tscn",
    "preview": "res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01_preview.tscn"
  },
  {
    "id": "PPC-INT-02",
    "scene": "res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02.tscn",
    "preview": "res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02_preview.tscn"
  },
  {
    "id": "PPC-END-01",
    "scene": "res://scenes/landmarks/pangasinan_provincial_capitol/summary/ppc_end_01.tscn",
    "preview": "res://scenes/landmarks/pangasinan_provincial_capitol/summary/ppc_end_01_preview.tscn"
  },
  {
    "id": "UH-EXT-01",
    "scene": "res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn",
    "preview": "res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn"
  },
  {
    "id": "UH-EXT-02",
    "scene": "res://scenes/landmarks/urduja_house/components/uh_ext_02.tscn",
    "preview": "res://scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn"
  },
  {
    "id": "UH-EXT-03",
    "scene": "res://scenes/landmarks/urduja_house/components/uh_ext_03.tscn",
    "preview": "res://scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn"
  },
  {
    "id": "UH-ENT-01",
    "scene": "res://scenes/landmarks/urduja_house/components/uh_ent_01.tscn",
    "preview": "res://scenes/landmarks/urduja_house/supporting/uh_ent_01.tscn"
  },
  {
    "id": "UH-INT-01",
    "scene": "res://scenes/landmarks/urduja_house/components/uh_int_01.tscn",
    "preview": "res://scenes/landmarks/urduja_house/interior/uh_int_01.tscn"
  },
  {
    "id": "UH-INT-02",
    "scene": "res://scenes/landmarks/urduja_house/components/uh_int_02.tscn",
    "preview": "res://scenes/landmarks/urduja_house/interior/uh_int_02.tscn"
  },
  {
    "id": "UH-INT-03",
    "scene": "res://scenes/landmarks/urduja_house/components/uh_int_03.tscn",
    "preview": "res://scenes/landmarks/urduja_house/interior/uh_int_03.tscn"
  },
  {
    "id": "UH-INT-04",
    "scene": "res://scenes/landmarks/urduja_house/components/uh_int_04.tscn",
    "preview": "res://scenes/landmarks/urduja_house/interior/uh_int_04.tscn"
  },
  {
    "id": "UH-END-01",
    "scene": "res://scenes/landmarks/urduja_house/components/uh_end_01.tscn",
    "preview": "res://scenes/landmarks/urduja_house/summary/uh_end_01.tscn"
  },
  {
    "id": "LCH-EXT-01",
    "scene": "res://scenes/landmarks/limahong_channel/exterior/lch_ext_01.tscn",
    "preview": "res://scenes/landmarks/limahong_channel/exterior/lch_ext_01_preview.tscn"
  },
  {
    "id": "LCH-EXT-02",
    "scene": "res://scenes/landmarks/limahong_channel/exterior/lch_ext_02.tscn",
    "preview": "res://scenes/landmarks/limahong_channel/exterior/lch_ext_02_preview.tscn"
  },
  {
    "id": "LCH-EXT-03",
    "scene": "res://scenes/landmarks/limahong_channel/exterior/lch_ext_03.tscn",
    "preview": "res://scenes/landmarks/limahong_channel/exterior/lch_ext_03_preview.tscn"
  },
  {
    "id": "LCH-INT-01",
    "scene": "res://scenes/landmarks/limahong_channel/interior/lch_int_01.tscn",
    "preview": "res://scenes/landmarks/limahong_channel/interior/lch_int_01_preview.tscn"
  },
  {
    "id": "LCH-INT-02",
    "scene": "res://scenes/landmarks/limahong_channel/interior/lch_int_02.tscn",
    "preview": "res://scenes/landmarks/limahong_channel/interior/lch_int_02_preview.tscn"
  },
  {
    "id": "LCH-INT-03",
    "scene": "res://scenes/landmarks/limahong_channel/interior/lch_int_03.tscn",
    "preview": "res://scenes/landmarks/limahong_channel/interior/lch_int_03_preview.tscn"
  },
  {
    "id": "LCH-END-01",
    "scene": "res://scenes/landmarks/limahong_channel/summary/lch_end_01.tscn",
    "preview": "res://scenes/landmarks/limahong_channel/summary/lch_end_01_preview.tscn"
  }
]
const FILLS = {"normal":"9c4a25", "hover":"6f3317", "pressed":"e8d5b4", "hover_pressed":"f0dfc3"}
var checks := 0
var failures := 0
var current_id := ""
func _initialize() -> void:
 run.call_deferred()
func check(ok: bool, message: String) -> void:
 checks += 1
 if not ok:
  failures += 1
  push_error(current_id+": "+message)
func settle() -> void:
 await create_timer(0.4).timeout
func find_production(node: Node, path: String) -> Control:
 if node.scene_file_path == path: return node as Control
 for child in node.get_children():
  var found := find_production(child,path)
  if found != null: return found
 return null
func check_controls(panel: Control, check_bounds: bool = true) -> void:
 var utilities := 0
 for button in panel.find_children("*", "Button", true, false):
  if not button.is_visible_in_tree() or button.text.to_upper() not in ["SOURCES","LISTEN","CLOSE"]: continue
  utilities += 1
  for state in FILLS:
   var style: StyleBoxFlat = button.get_theme_stylebox(state)
   check(style.bg_color.is_equal_approx(Color(FILLS[state])), button.text+" "+state+" fill")
   check(style.border_color.is_equal_approx(Color("d37148")), button.text+" "+state+" border")
  var focus: StyleBoxFlat = button.get_theme_stylebox("focus")
  check(not focus.draw_center and focus.border_width_left >= 3 and focus.border_color.is_equal_approx(Color("f9f5f0")), "separate visible keyboard focus")
  check(button.get_theme_color("font_pressed_color").is_equal_approx(Color("101d19")), "dark text on cream selection")
  if check_bounds: check(panel.get_global_rect().grow(0.6).encloses(button.get_global_rect()), "utility inside hotspot")
 check(utilities >= 2, "header utilities present")
func run() -> void:
 root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
 for item in INVENTORY:
  current_id = item.id
  for dimensions in [Vector2i(1280,720),Vector2i(960,540),Vector2i(854,480)]:
   root.size = dimensions
   var host := Control.new()
   root.add_child(host)
   host.size = dimensions
   var packed := load(item.scene) as PackedScene
   check(packed != null, "production loads")
   var panel := packed.instantiate() as Control
   host.add_child(panel)
   panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
   check(panel.open_interaction(), "production opens")
   await settle()
   check_controls(panel)
   panel.open_sources()
   await settle()
   var visible_sources := false
   for control in panel.find_children("*", "Button", true, false):
    if control.is_visible_in_tree() and control.text.to_upper().contains("CLOSE"): visible_sources = true
   check(visible_sources, "Sources has visible dismissal")
   panel.close_sources()
   panel.close_interaction()
   await settle()
   host.queue_free()
   await process_frame
   check(change_scene_to_file(item.preview) == OK, "preview/F6 scene loads")
   await scene_changed
   await settle()
   var preview_panel := find_production(current_scene,item.scene)
   check(preview_panel != null, "preview contains production instance")
   if preview_panel != null:
    # Legacy F6 harnesses wait for the visitor to open their production component.
    if not preview_panel.is_visible_in_tree():
     check(preview_panel.open_interaction(), "preview production opens on request")
     await settle()
    check(preview_panel.is_visible_in_tree(), "preview production visible")
    check_controls(preview_panel, false)
   var previous := current_scene
   current_scene = null
   previous.queue_free()
   await process_frame
  print("VISUAL ",item.id," production + preview at all three sizes")
 var generic: Control = load("res://scenes/components/conference_room_interaction.tscn").instantiate()
 check(generic.get_theme_stylebox("normal","Button").bg_color.is_equal_approx(Color(0.12,0.18,0.16,1)), "unrelated generic theme remains unchanged")
 generic.free()
 print("HOTSPOT VISUAL STANDARD: ",checks," checks, ",failures," failures")
 quit(0 if failures == 0 else 1)
