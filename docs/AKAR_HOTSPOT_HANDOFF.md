# AKAR Hotspot Handoff

## Responsibility boundary

**The hotspot developer owns** hotspot UI, researcher-supplied historical/interpretive content, media, interaction behavior, narration/video, local focus/input, local responsive layout, Sources, and hotspot lifecycle.

**The environment developer owns** the exterior/interior 2D environment, avatar/player, movement, collisions, trigger locations, when hotspots open, suspension/resumption of movement, environment transitions, and overlay/host placement.

**The environment developer should NOT edit hotspot internal nodes or depend on internal NodePaths for normal integration.** Treat each production scene as a reusable component with a public root API.

AKAR is an educational historical walkthrough, not a game. Closure means the visitor dismissed the interaction; it does not establish a score, reward, completed requirement, or mandatory visit to every hotspot.

## Handoff baseline

- Branch: `integration/akar-landmarks`.
- Audited production commit: `1afda5a`.
- Integrated audit decision: **READY FOR HOTSPOT HANDOFF WITH LIMITATIONS**.
- Inventory: **34 production hotspots and 34 preview/F6 harnesses**.
- This document consolidates the completed integrated audit and verified 34-hotspot contract for researcher review. Documentation-only commits may follow the audited production baseline; production changes require appropriate revalidation.

Update your checkout using the team's normal Git workflow. With local work safely handled first, the usual commands are:

```sh
git fetch origin
git switch integration/akar-landmarks
git pull --ff-only origin integration/akar-landmarks
git rev-parse --short HEAD
```

Keep the complete project and its asset/Resource dependencies. Copying only one landmark folder can omit shared dependencies; for example, Limahong EXT-01 uses an existing Urduja information icon.

## Production versus preview — choose the correct scene

> **USE IN ENVIRONMENT:** the production hotspot `.tscn` listed in the contract.
>
> **DO NOT INTEGRATE:** a `_preview.tscn` or standalone F6 harness. These exist only for isolated testing.

For Church, Casa, Capitol and Limahong, the harness normally has a `_preview.tscn` suffix beside the production scene.

**Urduja is different:** production scenes are under `res://scenes/landmarks/urduja_house/components/`. Same-named scenes under `exterior/`, `interior/`, `supporting/` and `summary/` are F6 harnesses. For example, `components/uh_int_04.tscn` is production; `interior/uh_int_04.tscn` is its harness. Similar filenames do not make these interchangeable.

Open the production scene to inspect the component. Open its listed preview and press F6 to understand visitor interaction. Return to the environment and instance the **production** scene there.

## Host and responsive requirements

Place the production root below an ordinary, properly sized `Control` in your overlay. A `CanvasLayer` may contain that Control if your environment needs a camera-independent UI layer. The environment decides where the overlay lives; no specific avatar/environment hierarchy is required.

Give the host nonzero dimensions before opening the hotspot, keep its ancestry visible, and place it above the environment. Let the hotspot manage its own local responsive layout. Keep one visitor hotspot active at a time. Stop movement and environment trigger handling while it is open, but leave hotspot input and processing available. Do not pause the whole SceneTree or disable a shared parent in a way that also pauses the hotspot.

The intended experience is **landscape**. Validated viewport/reference sizes are **1280×720**, **960×540**, and **854×480**, with full and approximately 5% inset hosts exercised during the audit. The host's actual dimensions matter: a 5% inset on each edge of 854×480 leaves only **768.6×432** for the hotspot.

**Casa exception:** use the validated full 854×480 host for CR-EXT-02 at the smallest size. Its title and header controls clip at approximately 5% inset. CR-INT-02's minor overflow above an ordinary unclipped host stays visible and usable, but do not assume a parent with `clip_contents` enabled behaves the same way.

Keep the existing project configuration: Godot 4, GDScript, Compatibility rendering, `canvas_items` stretch, `expand` aspect and nearest filtering. Integration does not require changing `project.godot`.

## Canonical integration flow

Visitor reaches an environment trigger → environment suspends movement → environment calls the hotspot's public open method → hotspot manages its interaction → hotspot emits its documented exit signal → environment resumes movement.

The following is a **documentation-only adapter example**, not an environment/player implementation. Supply the PackedScene and Control host from your own controller. Connect `movement_blocked_changed` to your own movement/trigger gate before calling `show_hotspot`.

```gdscript
extends Node

signal movement_blocked_changed(blocked: bool)

var _hotspot: Control

func show_hotspot(scene: PackedScene, host: Control) -> void:
    if is_instance_valid(_hotspot):
        return
    _hotspot = scene.instantiate() as Control
    _hotspot.connect(&"closed", _on_hotspot_finished)
    if _hotspot.has_signal(&"skip_requested"):
        # UH-ENT-01 Skip is an alternative exit, not a closed emission.
        _hotspot.connect(&"skip_requested", _on_hotspot_finished)
    host.add_child(_hotspot) # A host already in the tree runs child _ready().
    movement_blocked_changed.emit(true)
    if not bool(_hotspot.call(&"open_interaction")):
        _on_hotspot_finished() # Opening failed: release the movement gate.

func request_hotspot_close() -> void:
    if is_instance_valid(_hotspot):
        _hotspot.call(&"close_interaction")
        # Resume on the exit signal, not immediately after this call.

func _on_hotspot_finished() -> void:
    if not is_instance_valid(_hotspot):
        return
    var finished := _hotspot
    _hotspot = null
    finished.queue_free() # Safe if a legacy controller emits another signal.
    movement_blocked_changed.emit(false)
```

This example disposes of the instance after exit. To cache/reuse an instance instead, connect its signals once, keep it closed between visits, and open it again only after its exit signal. Some closes animate asynchronously: do not call close and immediately reopen in the same frame. Do not directly show/hide the component as a substitute for its lifecycle.

Use the table's reset method only after the instance is ready. Reset is local state cleanup, not environment navigation or permission to resume movement. Limahong reset preserves open/closed state and suppresses lifecycle notifications during reset; the revised Urduja reset preserves the root's current openness. Legacy `reset_hotspot()` behavior remains controller-specific. For **UH-EXT-01 and UH-ENT-01**, no root reset is exposed: use the documented close/exit followed by reopen.

Connect the preferred `closed` signal once; do not also connect a legacy close alias to the same resume/navigation action. **UH-ENT-01 requires both `closed` and `skip_requested` exit handling** because Skip does not emit `closed`. If your input callback can trigger navigation that removes a screen, obtain the viewport and mark the input handled **before** emitting navigation.

## Complete 34-hotspot contract

All paths below are exact Godot `res://` project paths and are portable between teammates' checkouts. Open/close methods are on the **production root**; `open_interaction()` returns `bool`. Every listed root exposes `opened` and `closed`. The signal column names the preferred exit first, followed by optional legacy/selection signals. Selection signals do not imply completion.

Resources are **already assigned by the production scene**. Keep those bindings; do not load a different Resource for environment/player state. The table identifies the authoritative root content entry point(s); keep their nested Resource/media dependencies as well. Human-readable names come from the assigned root content Resources, not newly written historical content.

### Lingayen Church — 6 hotspots

| ID | Name / purpose | Production scene — use in environment | Preview/F6 — testing only | Authoritative Resource(s) | Public lifecycle | Signals: preferred exit; additional | Integration note / architecture |
|---|---|---|---|---|---|---|---|
| LC-EXT-01 | Meet Lingayen Church | `res://scenes/landmarks/lingayen_church/exterior/lc_ext_01.tscn` | `res://scenes/landmarks/lingayen_church/exterior/lc_ext_01_preview.tscn` | `res://data/landmarks/lingayen_church/lc_ext_01.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: hotspot_closed | ACCEPTABLE LEGACY; instance the scene, never copy its editor preview nodes. |
| LC-EXT-02 | THE PAGODA-LIKE BELL TOWER | `res://scenes/landmarks/lingayen_church/exterior/lc_ext_02.tscn` | `res://scenes/landmarks/lingayen_church/exterior/lc_ext_02_preview.tscn` | `res://data/landmarks/lingayen_church/lc_ext_02.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: hotspot_closed, observation_changed | ACCEPTABLE LEGACY; observations remain local to the component. |
| LC-EXT-03 | HISTORIC BELLS AND THE 1945 DESTRUCTION | `res://scenes/landmarks/lingayen_church/exterior/lc_ext_03.tscn` | `res://scenes/landmarks/lingayen_church/exterior/lc_ext_03_preview.tscn` | `res://data/landmarks/lingayen_church/lc_ext_03.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: hotspot_closed, story_state_changed, wartime_view_changed | ACCEPTABLE LEGACY; story and wartime-view selectors remain internal. |
| LC-INT-01 | People Who Shaped the Parish | `res://scenes/landmarks/lingayen_church/interior/lc_int_01.tscn` | `res://scenes/landmarks/lingayen_church/interior/lc_int_01_preview.tscn` | `res://data/landmarks/lingayen_church/lc_int_01.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: close_requested | ACCEPTABLE LEGACY; portrait selection stays local. |
| LC-INT-02 | Lingayen Church Through Time | `res://scenes/landmarks/lingayen_church/interior/lc_int_02.tscn` | `res://scenes/landmarks/lingayen_church/interior/lc_int_02_preview.tscn` | `res://data/landmarks/lingayen_church/lc_int_02.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: close_requested, milestone_selected | ACCEPTABLE LEGACY; timeline selection is optional. |
| LC-END-01 | What Lingayen Church Represents | `res://scenes/landmarks/lingayen_church/interior/lc_end_01.tscn` | `res://scenes/landmarks/lingayen_church/interior/lc_end_01_preview.tscn` | `res://data/landmarks/lingayen_church/lc_end_01.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: close_requested, theme_selected | ACCEPTABLE LEGACY; optional summary/reflection. |

### Casa Real / Banáan — 7 hotspots

| ID | Name / purpose | Production scene — use in environment | Preview/F6 — testing only | Authoritative Resource(s) | Public lifecycle | Signals: preferred exit; additional | Integration note / architecture |
|---|---|---|---|---|---|---|---|
| CR-EXT-01 | MEET CASA REAL | `res://scenes/landmarks/casa_real/exterior/cr_ext_01.tscn` | `res://scenes/landmarks/casa_real/exterior/cr_ext_01_preview.tscn` | `res://data/landmarks/casa_real/cr_ext_01.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | ACCEPTABLE LEGACY; stale cross-landmark test tail is not a Casa production failure. |
| CR-EXT-02 | ARCHITECTURE OF THE ROYAL HOUSE | `res://scenes/landmarks/casa_real/exterior/cr_ext_02.tscn` | `res://scenes/landmarks/casa_real/exterior/cr_ext_02_preview.tscn` | `res://data/landmarks/casa_real/cr_ext_02.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | ACCEPTABLE LEGACY; use full host at 854×480, not 5% inset. |
| CR-EXT-03 | CASA REAL THROUGH CHANGING ROLES | `res://scenes/landmarks/casa_real/exterior/cr_ext_03.tscn` | `res://scenes/landmarks/casa_real/exterior/cr_ext_03_preview.tscn` | `res://data/landmarks/casa_real/cr_ext_03.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | ACCEPTABLE LEGACY; known milestone Resource/test mismatch. |
| CR-INT-01 | FROM ROYAL HOUSE TO PROVINCIAL MUSEUM | `res://scenes/landmarks/casa_real/interior/cr_int_01.tscn` | `res://scenes/landmarks/casa_real/interior/cr_int_01_preview.tscn` | `res://data/landmarks/casa_real/cr_int_01.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | ACCEPTABLE LEGACY; component owns comparison/media behavior. |
| CR-INT-02 | DISCOVER BANÁAN | `res://scenes/landmarks/casa_real/interior/cr_int_02.tscn` | `res://scenes/landmarks/casa_real/interior/cr_int_02_preview.tscn` | `res://data/landmarks/casa_real/cr_int_02.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: close_requested | ACCEPTABLE LEGACY; manual gallery videos; inset header findings were false positives for an unclipped host. |
| CR-INT-03 | PEOPLE BEHIND CASA REAL | `res://scenes/landmarks/casa_real/interior/cr_int_03.tscn` | `res://scenes/landmarks/casa_real/interior/cr_int_03_preview.tscn` | `res://data/landmarks/casa_real/cr_int_03.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: close_requested | ACCEPTABLE LEGACY; component owns personality selection. |
| CR-END-01 | CASA REAL AT A GLANCE | `res://scenes/landmarks/casa_real/end/cr_end_01.tscn` | `res://scenes/landmarks/casa_real/end/cr_end_01_preview.tscn` | `res://data/landmarks/casa_real/cr_end_01.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: close_requested, summary_theme_changed | ACCEPTABLE LEGACY; optional summary. |

### Pangasinan Provincial Capitol — 5 hotspots

| ID | Name / purpose | Production scene — use in environment | Preview/F6 — testing only | Authoritative Resource(s) | Public lifecycle | Signals: preferred exit; additional | Integration note / architecture |
|---|---|---|---|---|---|---|---|
| PPC-EXT-01 | MEET THE PANGASINAN PROVINCIAL CAPITOL | `res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01.tscn` | `res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01_preview.tscn` | `res://data/landmarks/pangasinan_provincial_capitol/ppc_ext_01.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | ACCEPTABLE LEGACY; known observation-label Resource/test mismatch. |
| PPC-EXT-02 | MONUMENTAL NEOCLASSICAL DESIGN | `res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_02.tscn` | `res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_02_preview.tscn` | `res://data/landmarks/pangasinan_provincial_capitol/ppc_ext_02.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | ACCEPTABLE LEGACY; component owns reveal geometry. |
| PPC-INT-01 | DAMAGE, REBUILDING, AND PRESERVATION | `res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01.tscn` | `res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01_preview.tscn` | `res://data/landmarks/pangasinan_provincial_capitol/ppc_int_01.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | ACCEPTABLE LEGACY; component owns comparison geometry. |
| PPC-INT-02 | A LIVING SEAT OF GOVERNMENT | `res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02.tscn` | `res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02_preview.tscn` | `res://data/landmarks/pangasinan_provincial_capitol/ppc_int_02.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | ACCEPTABLE LEGACY; component owns branch/documentary views. |
| PPC-END-01 | WHAT THE PANGASINAN PROVINCIAL CAPITOL REPRESENTS | `res://scenes/landmarks/pangasinan_provincial_capitol/summary/ppc_end_01.tscn` | `res://scenes/landmarks/pangasinan_provincial_capitol/summary/ppc_end_01_preview.tscn` | `res://data/landmarks/pangasinan_provincial_capitol/ppc_end_01.tres` | Open: `open_interaction()`<br>Reset: `reset_hotspot()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | ACCEPTABLE LEGACY; optional summary. |

### Urduja House — 9 hotspots

| ID | Name / purpose | Production scene — use in environment | Preview/F6 — testing only | Authoritative Resource(s) | Public lifecycle | Signals: preferred exit; additional | Integration note / architecture |
|---|---|---|---|---|---|---|---|
| UH-EXT-01 | MEET URDUJA HOUSE | `res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn` | `res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn` | `res://data/landmarks/urduja_house/revision/uh_ext_01.tres` | Open: `open_interaction()`<br>Reset: not exposed<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | REVISED SCENE-AUTHORED; no public root reset. Close/exit, then reopen. |
| UH-EXT-02 | WHY IT WAS BUILT | `res://scenes/landmarks/urduja_house/components/uh_ext_02.tscn` | `res://scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn` | `res://data/landmarks/urduja_house/revision/uh_ext_02.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | REVISED SCENE-AUTHORED; reset keeps the current open/closed state. |
| UH-EXT-03 | BALINESE-INSPIRED ARCHITECTURE | `res://scenes/landmarks/urduja_house/components/uh_ext_03.tscn` | `res://scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn` | `res://data/landmarks/urduja_house/revision/uh_ext_03.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | REVISED SCENE-AUTHORED; image-relative marker geometry remains local. |
| UH-ENT-01 | The Story of Urduja House | `res://scenes/landmarks/urduja_house/components/uh_ent_01.tscn` | `res://scenes/landmarks/urduja_house/supporting/uh_ent_01.tscn` | `res://data/landmarks/urduja_house/revision/uh_ent_01.tres`<br>`res://data/landmarks/urduja_house/uh_ent_01.tres` | Open: `open_interaction()`<br>Reset: not exposed<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: skip_requested (alternative exit; no closed emission) | ACCEPTED RUNTIME COMPOSITION; handle Skip separately. Unverified narration/video is withheld; no public root reset. |
| UH-INT-01 | PRINCESS URDUJA PAINTING | `res://scenes/landmarks/urduja_house/components/uh_int_01.tscn` | `res://scenes/landmarks/urduja_house/interior/uh_int_01.tscn` | `res://data/landmarks/urduja_house/revision/uh_int_01.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | REVISED SCENE-AUTHORED; magnifier geometry stays local. |
| UH-INT-02 | URDUJA HOUSE THROUGH TIME | `res://scenes/landmarks/urduja_house/components/uh_int_02.tscn` | `res://scenes/landmarks/urduja_house/interior/uh_int_02.tscn` | `res://data/landmarks/urduja_house/revision/uh_int_02.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | REVISED SCENE-AUTHORED; time-track/transfer animation stays local. |
| UH-INT-03 | CEREMONIAL HALL | `res://scenes/landmarks/urduja_house/components/uh_int_03.tscn` | `res://scenes/landmarks/urduja_house/interior/uh_int_03.tscn` | `res://data/landmarks/urduja_house/revision/uh_int_03.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | REVISED SCENE-AUTHORED; hall markers and carousel stay local. |
| UH-INT-04 | CONFERENCE ROOM | `res://scenes/landmarks/urduja_house/components/uh_int_04.tscn` | `res://scenes/landmarks/urduja_house/interior/uh_int_04.tscn` | `res://data/landmarks/urduja_house/revision/uh_int_04.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | REVISED SCENE-AUTHORED; room-focus geometry stays local. |
| UH-END-01 | WHAT URDUJA HOUSE REPRESENTS | `res://scenes/landmarks/urduja_house/components/uh_end_01.tscn` | `res://scenes/landmarks/urduja_house/summary/uh_end_01.tscn` | `res://data/landmarks/urduja_house/revision/uh_end_01.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | REVISED SCENE-AUTHORED; optional reflection, no mandatory completion state. |

### Limahong Channel — 7 hotspots

| ID | Name / purpose | Production scene — use in environment | Preview/F6 — testing only | Authoritative Resource(s) | Public lifecycle | Signals: preferred exit; additional | Integration note / architecture |
|---|---|---|---|---|---|---|---|
| LCH-EXT-01 | LIMAHONG CHANNEL | `res://scenes/landmarks/limahong_channel/exterior/lch_ext_01.tscn` | `res://scenes/landmarks/limahong_channel/exterior/lch_ext_01_preview.tscn` | `res://data/landmarks/limahong_channel/lch_ext_01.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: section_changed | FULL STANDARD; additional assigned Resources are listed below. |
| LCH-EXT-02 | FROM MANILA TO PANGASINAN | `res://scenes/landmarks/limahong_channel/exterior/lch_ext_02.tscn` | `res://scenes/landmarks/limahong_channel/exterior/lch_ext_02_preview.tscn` | `res://data/landmarks/limahong_channel/lch_ext_02.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>No additional exit signal required. | STANDARD WITH DYNAMIC-GEOMETRY EXCEPTION. |
| LCH-EXT-03 | THE SIEGE AND ESCAPE ROUTE | `res://scenes/landmarks/limahong_channel/exterior/lch_ext_03.tscn` | `res://scenes/landmarks/limahong_channel/exterior/lch_ext_03_preview.tscn` | `res://data/landmarks/limahong_channel/lch_ext_03.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: stage_changed | ACCEPTABLE LEGACY SPECIAL CASE; editor shows inherited shell. |
| LCH-INT-01 | THE LIMAHONG STATUE | `res://scenes/landmarks/limahong_channel/interior/lch_int_01.tscn` | `res://scenes/landmarks/limahong_channel/interior/lch_int_01_preview.tscn` | `res://data/landmarks/limahong_channel/lch_int_01.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: close_requested, section_changed | STANDARD WITH DYNAMIC-GEOMETRY EXCEPTION. |
| LCH-INT-02 | PEOPLE BEHIND THE 1575 CAMPAIGN | `res://scenes/landmarks/limahong_channel/interior/lch_int_02.tscn` | `res://scenes/landmarks/limahong_channel/interior/lch_int_02_preview.tscn` | `res://data/landmarks/limahong_channel/lch_int_02.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: close_requested, person_changed | STANDARD WITH DYNAMIC-GEOMETRY EXCEPTION. |
| LCH-INT-03 | FROM ESCAPE ROUTE TO HERITAGE DESTINATION | `res://scenes/landmarks/limahong_channel/interior/lch_int_03.tscn` | `res://scenes/landmarks/limahong_channel/interior/lch_int_03_preview.tscn` | `res://data/landmarks/limahong_channel/lch_int_03.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: close_requested, stage_changed | STANDARD WITH DYNAMIC-GEOMETRY EXCEPTION. |
| LCH-END-01 | WHAT THE LIMAHONG CHANNEL REPRESENTS | `res://scenes/landmarks/limahong_channel/summary/lch_end_01.tscn` | `res://scenes/landmarks/limahong_channel/summary/lch_end_01_preview.tscn` | `res://data/landmarks/limahong_channel/lch_end_01.tres` | Open: `open_interaction()`<br>Reset: `reset_interaction()`<br>Close: `close_interaction()` | Exit: `closed`<br>Additional: close_requested, topic_changed | STANDARD WITH DYNAMIC-GEOMETRY EXCEPTION; optional summary. |

### Resource and API details that apply to the tables

UH-ENT-01 uses both the revised Resource (`revision/uh_ent_01.tres`) and the existing embedded-video content Resource (`uh_ent_01.tres`). Both assignments must be preserved.

LCH-EXT-01 also binds these content Resources directly in its production scene, in addition to the main Resource in its row:

- `res://data/landmarks/limahong_channel/lch_ext_01_introduction.tres`
- `res://data/landmarks/limahong_channel/lch_ext_01_note.tres`
- `res://data/landmarks/limahong_channel/lch_ext_01_locator.tres`
- `res://data/landmarks/limahong_channel/lch_ext_01_history.tres`
- `res://data/landmarks/limahong_channel/lch_ext_01_today.tres`
- `res://data/landmarks/limahong_channel/lch_ext_01_locator_lingayen.tres`
- `res://data/landmarks/limahong_channel/lch_ext_01_locator_pangapisan.tres`
- `res://data/landmarks/limahong_channel/lch_ext_01_locator_channel.tres`
- `res://data/landmarks/limahong_channel/lch_ext_01_today_02.tres`
- `res://data/landmarks/limahong_channel/lch_ext_01_today_03.tres`

The environment does not need to rebuild these Resource arrays or load the media itself.

Church/Casa/Capitol retain `open_hotspot()` aliases and some retain `close_hotspot()`. Use the consistently documented `open_interaction()` / `close_interaction()` pair above instead of assuming every alias exists.

Church/Casa/Capitol and Limahong inherit `concept_changed`, `narration_started`, `narration_stopped`, `sources_opened` and `sources_closed`. Their presence does not mean every specialised selection emits `concept_changed`. Normal environment integration needs only the documented exit signal(s); local selections and media controls remain the hotspot's responsibility.

Urduja's shared base declares `return_to_map_requested` and `skip_requested` on its roots. Declaration alone is not a completed navigation feature: **do not rely on `return_to_map_requested` as a completion signal for the revised components**. The current wired alternate exit is ENT-01 Skip, handled as shown above. Environment transitions remain the environment controller's responsibility.

## Landmark notes and known limitations

### Lingayen Church

These are working, acceptable legacy components with editor-visible representations. Instance the production scene; never copy the generated editor nodes. The temporary editor presentation is intentionally unowned/unserialized and is not the public integration surface.

Functional, generic-host and editor checks passed. One native LC-EXT-02 test initially crashed during process exit after reporting zero functional failures; two targeted reruns exited normally. Normal production open/close/reopen passed. Record this as a non-reproduced process-exit issue, not a proven production bug; its exact engine-level cause is undetermined.

### Casa Real / Banáan

Use the production scene and public root API, preserving its accepted legacy editor presentation.

| Hotspot | Known finding | Integration consequence |
|---|---|---|
| CR-EXT-01 | NEW TEST/HARNESS INCOMPATIBILITY: its old automated tail targets the former Urduja UH-INT-04 hierarchy. | Casa production checks passed before that obsolete assertion. Do not change Casa production to satisfy it. A separate test-only correction was recommended, not applied. |
| CR-EXT-03 | PRE-EXISTING CONTENT/TEST CONTRACT LIMITATION: milestone Resource values differ from test expectations. | Disclose the missing/mismatched milestone information; refer content reconciliation to the hotspot developer/researcher. |
| CR-EXT-02 | PRE-EXISTING RESPONSIVE LIMITATION at 854×480 with approximately 5% inset. | The reduced 768.6×432 host clips the title and button tops. Use the validated full 854×480 host until a separate fix is approved. |
| CR-INT-02 | TEST-BOUNDARY FALSE POSITIVE for three inset header bounds. | Buttons extend 4.5 px above the host but stay fully visible and clickable in the viewport under the tested unclipped ordinary Control. Do not impose clipping on that host without rechecking. |

The Casa controllers involved were unchanged by the landmark merges. Do not “repair” test mismatches by inventing or changing historical content. Sources, narration/video cleanup and local interactions stay inside the hotspot.

### Pangasinan Provincial Capitol

These are acceptable legacy components with editor-visible representations. Do not copy their generated editor hierarchy into an environment.

PPC-EXT-01 retains a **PRE-EXISTING CONTENT/TEST CONTRACT LIMITATION** for observation-label Resource values versus test expectations. Production loading and lifecycle passed. Content reconciliation belongs to the hotspot developer/researcher, not environment scripts.

### Urduja House

Eight revised production components have genuinely scene-authored structure. Use the `components/` production paths in the table; area scenes are F6 harnesses. Dynamic marker, lens, timeline and room-focus geometry still belongs to the component.

UH-ENT-01 remains an accepted runtime-generated composition and intentionally withholds unverified narration/video. Do not enable withheld media from the environment. UH-EXT-01 and UH-ENT-01 expose no root reset; close/exit and reopen. ENT-01 Skip requires separate exit handling. Existing content duplication/API differences are documented qualifications, not an invitation to normalise the implementations during environment work.

### Limahong Channel

- **LCH-EXT-01: FULL STANDARD.**
- **LCH-EXT-02, LCH-INT-01, LCH-INT-02, LCH-INT-03, LCH-END-01: STANDARD WITH DYNAMIC-GEOMETRY EXCEPTION.**
- **LCH-EXT-03: ACCEPTABLE LEGACY SPECIAL CASE.**

These classifications do **not** change environment integration: use the same public root open/reset/close API. All seven expose `reset_interaction()`. Its shared lifecycle helper is stateless; do not call that internal helper directly.

The six migrated scenes contain persistent authored hierarchy. Their editor content may be neutral placeholders, while media/content are bound at runtime. EXT-03 shows an inherited shell in the editor; use its F6 harness to inspect the tactical sequence. Do not rewrite it for visual/architectural uniformity.

## What the teammate must not do

- Copy/paste internal hotspot nodes into environment scenes.
- Use a preview or F6 harness as a production hotspot.
- Directly manipulate internal hotspot labels, buttons or media players.
- Depend on internal NodePaths, private fields or generated node counts.
- Move historical content into environment scripts.
- Directly start hotspot narration from the environment.
- Alter shared hotspot Resources to store player/environment state.
- Make a hotspot control avatar movement.
- Rewrite hotspot lifecycle or bypass its public close method.
- Convert dynamic interactions merely for visual uniformity.

Route requested hotspot changes to the hotspot developer. Historical corrections require researcher-supplied, validated content; failing tests are not historical sources.

## Recommended teammate workflow

1. Pull/update the integration branch using the team's normal Git workflow.
2. Open the intended production `.tscn` from the contract.
3. Open its listed preview and press F6 to understand the interaction.
4. Return to your environment scene.
5. Instance the **production** `.tscn`.
6. Place it inside your overlay's ordinary, sized Control host.
7. Leave it closed until the environment trigger activates it; do not call its open API from an unconditional environment startup hook.
8. Suspend avatar movement and environment trigger input, preserving hotspot input/processing.
9. Call the documented public open method after the node is ready; handle a `false` return by releasing the movement gate.
10. Listen for the documented close/exit signal; include ENT-01 Skip where applicable.
11. Resume avatar movement on that exit signal. If retaining the instance, reconnect nothing and reuse it after closure; otherwise use `queue_free()`.
12. Test at 1280×720, 960×540 and 854×480 in landscape, observing Casa's host-size qualification.

For the manual Godot handoff check, exercise mouse and keyboard, Sources then Escape, close/reopen, optional reset where exposed, and media cleanup on close. Check that one trigger cannot open duplicate panels, movement stays suspended during interaction, and it resumes once on ordinary Close and ENT-01 Skip. Do not require the visitor to view every hotspot.

## Debugging / handoff rule

If the supplied preview works but the environment integration fails, inspect these first:

- Parent/host dimensions and whether its children are being clipped.
- Environment input interception, movement gating and trigger re-entry.
- Overlay ordering and whether something covers the hotspot.
- Host/ancestor visibility and processing state.
- Whether the documented production-root API and exit signals are used.

Do not immediately modify the hotspot internals. Compare the same hotspot and Resource assignments in its supplied preview and in the environment at 1280×720. Report the hotspot ID, production path, host/viewport sizes, exact reproduction steps and relevant errors to the hotspot developer.

## Integrated test status

The completed integrated audit found all **34 production hotspots** and **34 preview harnesses**. It found **no new production integration regression** in the exercised coverage. Cross-landmark coexistence passed; all nine revised Urduja suites and all seven Limahong hotspot suites passed, along with Limahong's header/Sources/architecture checks. All five families passed editor verification. No shared-Resource mutation or production global-window resizing was detected.

The repository remained clean at `1afda5a` during the audit. That result does **not** mean every older automated test is green: the stale Casa cross-landmark assertion, existing content/test contracts and CR-EXT-02 inset limitation remain as documented above. Initial editor permission/capture problems were verification-environment issues, not failed hotspot behavior.

Native Godot Compatibility was validated. Browser/Web export was not part of this audit and remains a later deployment gate. Physical touchscreen/tablet testing was not part of this audit and remains a deployment/integration validation gate alongside browser/Web export. This document transfers the hotspot contract; it does not transfer responsibility for building the virtual environments to the hotspot developer.

## Before reporting a hotspot integration bug

- [ ] Correct production scene, not the preview/F6 harness?
- [ ] Correct assigned Resource(s), with their dependencies intact?
- [ ] Supplied preview works?
- [ ] Host has valid dimensions and appropriate clipping/visibility?
- [ ] Correct public open method, called after readiness?
- [ ] Correct close/exit signal, including ENT-01 Skip if relevant?
- [ ] Environment movement/trigger input disabled while open, with hotspot input still enabled?
- [ ] No internal NodePaths or private hotspot fields used?
- [ ] Reproduced at 1280×720 and checked against the documented limitations?
