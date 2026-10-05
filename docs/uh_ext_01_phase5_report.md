# UH-EXT-01 final narration — supplied / enabled

Updated 3 October 2026. This section supersedes earlier pending/disabled narration statements in the historical reports below.

## Asset and assignment

- Filename: `uh_ext_01_narration.ogg`.
- Exact path: `res://assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg`.
- Godot 4.7.2 successfully loads the imported resource as AudioStreamOggVorbis: 21.0 seconds, loop false.
- SHA256: `5e44adb87270f4dc7586cf026902718c597544c394376fc0fdefe1e38fa4bd44`. Byte-identical to other repository recordings, including `assets/landmarks/urduja_house/audio/uh-int-01-narration.ogg` (21 matching files including the supplied file).
- **Researcher explicitly approved use of the supplied UH-EXT-01 narration file despite duplicate-file detection.** No audio files were edited, replaced, renamed or deleted. Spoken-word agreement with the transcript was not independently verified; the exact supplied file is accepted under the explicit approval.
- Assigned to `narration` in `data/landmarks/urduja_house/revision/uh_ext_01.tres`, used by production `scenes/landmarks/urduja_house/components/uh_ext_01.tscn`. Existing Narration AudioStreamPlayer/shared mechanism retained.
- Approved transcript and visible historical copy are unchanged.

## Behavior and tests

LISTEN is enabled in the editor and runtime. Runtime still disables it if the stream is absent. Mouse, Tab/Enter/Space and synthetic touch-to-mouse activation passed. The accessible name stays LISTEN; dynamic description explains play or stop/reset. Existing button pressed styling is retained; no audio-player UI added.

Play starts at zero. A second activation stops and resets to zero. Actual natural completion of the full 21-second stream was awaited in both runtime runs; it returns to idle and permits replay from zero. PLACE → HISTORY → TODAY and Sources open/close preserve playing state and advancing playback position. Full Close stops/resets/clears the button; reopening is enabled and idle. No autoplay on open, selection, Sources close or reopen.

- Headless runtime: **1240 checks, 0 failures**.
- Compatibility-rendered runtime: **1259 checks, 0 failures**.
- Actual editor-layout regression: **19 checks, 0 failures**. Root 1280×720, Discovery 1256×602, media frame 705×476; full header/columns/rail/takeaway remain available. Full Rect and Container fixes unchanged.
- 1280×720: PASS, all states, full and inset parent.
- 960×540: PASS, all states, full and inset parent.
- 854×480: PASS, all states, full and inset parent; rendered enabled LISTEN inspected.
- These are playback/input-state and rendering checks, not an auditory transcript audit or physical touchscreen/browser test. Complete the manual listening/touch check below.
- Existing Windows root-certificate diagnostic remains. The custom editor SceneTree probe may report shutdown RID/ObjectDB diagnostics. No final runtime test/script/resource failures.
- Logs: `%TEMP%/akar_uh_ext_01_audio/`; rendered PNGs: `%TEMP%/akar_uh_ext_01_editor/`.

## Files modified in this task

1. `data/landmarks/urduja_house/revision/uh_ext_01.tres` — assign supplied narration.
2. `scenes/landmarks/urduja_house/components/uh_ext_01.tscn` — saved enabled LISTEN and idle description; no layout edits.
3. `scripts/landmarks/urduja_house/uh_ext_01_hotspot.gd` — synchronize stable accessible name and dynamic play/stop description around inherited playback methods.
4. `tests/uh_ext_01_phase5_test.gd` — enabled-state assertions and playback/input regression coverage.
5. `docs/uh_ext_01_testing.md` — supplied/enabled status and manual retest.
6. `docs/uh_ext_01_phase5_report.md` — this report, updated in place.

No new files. No shared component edits. No other hotspot/audio edits. AGENTS.md and project.godot unchanged. No staging, commit or push.

## Exact F6 retest

1. Open `res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn`; press **F6**. Confirm PLACE, LISTEN enabled, no autoplay.
2. Activate LISTEN. Hear narration from the beginning. Activate again to stop/reset, then replay.
3. During playback select HISTORY, TODAY and PLACE, then open/close Sources; confirm uninterrupted audio.
4. Allow natural finish; confirm idle styling and replay from the beginning.
5. Close while playing; verify silence. Activate **OPEN UH-EXT-01 PREVIEW**; verify PLACE, enabled LISTEN, idle/no autoplay.
6. Tab to LISTEN; test Enter/Space, mouse and physical touch. Repeat at 1280×720, 960×540 and 854×480. Automated tests also cover full/inset parents.
7. Open the production scene directly in 2D and verify the unchanged editable layout.

## Git validation

`git diff --check`: passed (exit 0); existing CRLF conversion notices only. The pre-existing wider dirty tree remains intact. Final `git status --short`:

```text
 D assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.jpeg
 D assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.jpeg.import
 M data/landmarks/urduja_house/uh_end_01.tres
 M data/landmarks/urduja_house/uh_ent_01.tres
 M data/landmarks/urduja_house/uh_ext_01.tres
 M data/landmarks/urduja_house/uh_ext_02.tres
 M data/landmarks/urduja_house/uh_ext_03.tres
 M data/landmarks/urduja_house/uh_int_01.tres
 M data/landmarks/urduja_house/uh_int_02.tres
 M data/landmarks/urduja_house/uh_int_03.tres
 M data/landmarks/urduja_house/uh_int_04.tres
 M docs/uh_end_01_testing.md
 M docs/uh_ent_01_testing.md
 M docs/uh_ext_01_testing.md
 M docs/uh_ext_02_testing.md
 M docs/uh_ext_03_testing.md
 M docs/uh_int_01_testing.md
 M docs/uh_int_02_testing.md
 M docs/uh_int_03_testing.md
 M docs/uh_int_04_testing.md
 M scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn
 M scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn
 M scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_01.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_02.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_03.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_04.tscn
 M scenes/landmarks/urduja_house/summary/uh_end_01.tscn
 M scenes/landmarks/urduja_house/supporting/uh_ent_01.tscn
 M scripts/components/interactive_timeline.gd
 M tests/cr_ext_01_test.gd
?? assets/landmarks/urduja_house/audio/uh_end_01_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_end_01_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_02_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_02_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.JPG
?? assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.JPG.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png.import
?? data/landmarks/urduja_house/revision/
?? data/landmarks/urduja_house/uh_ext_01_theme.tres
?? docs/specifications/urduja_house/revision_2026_10_02.md
?? docs/uh_ext_01_phase5_report.md
?? docs/urduja_house_media_credits.md
?? docs/urduja_house_revision_report.md
?? scenes/landmarks/urduja_house/components/
?? scripts/landmarks/urduja_house/uh_embedded_video.gd
?? scripts/landmarks/urduja_house/uh_embedded_video.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_discovery.gd
?? scripts/landmarks/urduja_house/uh_ext_01_discovery.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_discovery_content.gd
?? scripts/landmarks/urduja_house/uh_ext_01_discovery_content.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_editor_content.gd
?? scripts/landmarks/urduja_house/uh_ext_01_editor_content.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_hotspot.gd
?? scripts/landmarks/urduja_house/uh_ext_01_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_hotspot.gd
?? scripts/landmarks/urduja_house/uh_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd.uid
?? scripts/landmarks/urduja_house/uh_preview.gd
?? scripts/landmarks/urduja_house/uh_preview.gd.uid
?? scripts/landmarks/urduja_house/uh_revision_content.gd
?? scripts/landmarks/urduja_house/uh_revision_content.gd.uid
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd.uid
?? tests/uh_ext_01_editor_layout_test.gd
?? tests/uh_ext_01_editor_layout_test.gd.uid
?? tests/uh_ext_01_phase5_test.gd
?? tests/uh_ext_01_phase5_test.gd.uid
?? tests/uh_revision_render_test.gd
?? tests/uh_revision_render_test.gd.uid
?? tests/uh_revision_test.gd
?? tests/uh_revision_test.gd.uid
```

---

Historical reports below are retained for context; their disabled/pending narration statements no longer apply.

# UH-EXT-01 editor-layout correction — 3 October 2026

## Cause and scope

No partial changes were left by the interrupted correction: every file matched its saved SHA256 baseline. Existing wider Urduja revision work was preserved.

The reported narrow strip in the production scene **did not reproduce from the current saved production scene**. Before editing, an actual EditorInterface probe already measured its root at 1280×720 and Discovery at 1256×602. It would be inaccurate to claim an established root cause for that specific screenshot or to attribute it to negative offsets.

A separate, reproducible saved-layout fault existed in the F6 harness: its Hotspot instance overrode `anchors_preset = 0`. Godot reset the inherited Full Rect anchors to zero, yielding a 0×0 Hotspot. Its Panel expanded around minimum size to 343×716 at (-171.5, -358), and Discovery became 319×0. The existing runtime test reproduced 221 failures before correction. This override is now Full Rect explicitly.

## Exact changes

Modified during this correction:

- `scenes/landmarks/urduja_house/components/uh_ext_01.tscn`: Content is now a MarginContainer, retaining its path and vertical expand flag. Discovery explicitly uses Container layout mode 2 and expand/fill flags 3 in both directions. Its rect is assigned by its scene-authored parent instead of relying only on inherited anchors.
- `scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn`: Hotspot instance uses layout mode 1, Full Rect preset 15, and right/bottom anchors 1. No preview interaction changed.
- `docs/uh_ext_01_testing.md`: editor and F6 verification instructions appended.
- `docs/uh_ext_01_phase5_report.md`: this correction report.

Created:

- `tests/uh_ext_01_editor_layout_test.gd` and its Godot-generated `.gd.uid`: opens the actual production scene in the editor, verifies geometry and Inspector selection, and changes spacing/ratios in memory without saving.

No changes to discovery/content/interaction scripts, historical resources, photographs, locator map, diamond, Sources, Listen, Close/reset, transitions, other hotspots, AGENTS.md, or project.godot. No @tool layout workaround added. Existing header margins (12), content gap (18), media/info ratios (.57/.43), caption gap (4), rail height (52), and takeaway margins remain intact. No fixed 1280 minimum was imposed on the embedded component.

## Editor verification

The actual edited production root is 1280×720. Discovery fills its host at 1256×602; media frame is 705×476; information column is 533×503. Header, both columns, rail, and takeaway are fully present in the rendered editor capture. Media/info/rail/takeaway are selectable in the Inspector. Main margin, column ratio, caption spacing, rail height, and takeaway spacing changes visibly affect layout in the editor.

Runtime layout code is unchanged: compact typography, gaps and ratios remain necessary below the existing 900px content breakpoint; wide values are captured from the scene and restored. Normal main margins, media-frame minimum, caption alignment/gap, rail height, stop width, and takeaway margins are preserved by the existing runtime regression checks. Rail line/selector alignment and transition logic remain unchanged. Container-owned child position/size should be edited through parent margins, separation, minimum size and stretch ratios, not by dragging a Container-managed rect.

## Validation results

- Godot 4.7.2 Compatibility.
- Actual editor-layout regression: **19 checks, 0 failures**, headless editor and rendered editor.
- Existing headless runtime suite: **1208 checks, 0 failures**.
- Existing rendered runtime suite: **1227 checks, 0 failures**; 18 state/size/parent captures plus Sources and scrolled HISTORY.
- 1280×720: PASS, full and 5% inset parents, PLACE/HISTORY/TODAY.
- 960×540: PASS, full and 5% inset parents, PLACE/HISTORY/TODAY.
- 854×480: PASS, full and 5% inset parents, PLACE/HISTORY/TODAY. HISTORY retains local scrolling.
- Mouse, keyboard, touch-drag simulation, rapid selection, Sources focus, disabled Listen, Close/reset/reopen, and Inspector-setting preservation: existing suite passes.
- Standard headless editor import: exit 0; no project parse/resource errors.
- Warning/error qualifications: Windows reports `Failed to read the root certificate store.` The custom editor-as-SceneTree probe also emits editor shutdown RID/ObjectDB diagnostics in headless mode and `current_window` progress-dialog diagnostics in rendered mode. These diagnostics existed before the scene change; runtime checks report no project errors. This is not a claim of globally warning-free Godot output.
- `git diff --check`: exit 0. Git prints existing CRLF-to-LF notices, not whitespace failures.
- `project.godot`: unchanged; no serialization diff.
- No staging, commit or push. Existing dirty/deleted/untracked files retained.

Artifacts: `%TEMP%/akar_uh_ext_01_editor_rect/` (logs and editor.png); runtime PNGs: `%TEMP%/akar_uh_ext_01_editor/`.

## Manual check

Open `res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn` directly and select the 2D workspace. Select Hotspot and frame the selection (F) or zoom to fit. The full header, media/info columns, discovery rail and takeaway should be visible without running. Expand Content/Discovery (Editable Children is already enabled) and select MediaColumn, InfoScroll, MediaFrame, DiscoveryRail or TakeawayMargin; use their Container properties to edit layout.

For runtime, open `res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn` and press **F6**. After Close, select **OPEN UH-EXT-01 PREVIEW** to reopen at PLACE. Check all three states and Sources at 1280×720, 960×540 and 854×480. The harness defaults to 5% inset; the automated suite additionally checks full-parent mode. Do not run the production component directly as an F6 harness.

## Final git status --short

```text
 D assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.jpeg
 D assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.jpeg.import
 M data/landmarks/urduja_house/uh_end_01.tres
 M data/landmarks/urduja_house/uh_ent_01.tres
 M data/landmarks/urduja_house/uh_ext_01.tres
 M data/landmarks/urduja_house/uh_ext_02.tres
 M data/landmarks/urduja_house/uh_ext_03.tres
 M data/landmarks/urduja_house/uh_int_01.tres
 M data/landmarks/urduja_house/uh_int_02.tres
 M data/landmarks/urduja_house/uh_int_03.tres
 M data/landmarks/urduja_house/uh_int_04.tres
 M docs/uh_end_01_testing.md
 M docs/uh_ent_01_testing.md
 M docs/uh_ext_01_testing.md
 M docs/uh_ext_02_testing.md
 M docs/uh_ext_03_testing.md
 M docs/uh_int_01_testing.md
 M docs/uh_int_02_testing.md
 M docs/uh_int_03_testing.md
 M docs/uh_int_04_testing.md
 M scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn
 M scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn
 M scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_01.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_02.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_03.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_04.tscn
 M scenes/landmarks/urduja_house/summary/uh_end_01.tscn
 M scenes/landmarks/urduja_house/supporting/uh_ent_01.tscn
 M scripts/components/interactive_timeline.gd
 M tests/cr_ext_01_test.gd
?? assets/landmarks/urduja_house/audio/uh_end_01_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_end_01_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_02_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_02_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.JPG
?? assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.JPG.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png.import
?? data/landmarks/urduja_house/revision/
?? data/landmarks/urduja_house/uh_ext_01_theme.tres
?? docs/specifications/urduja_house/revision_2026_10_02.md
?? docs/uh_ext_01_phase5_report.md
?? docs/urduja_house_media_credits.md
?? docs/urduja_house_revision_report.md
?? scenes/landmarks/urduja_house/components/
?? scripts/landmarks/urduja_house/uh_embedded_video.gd
?? scripts/landmarks/urduja_house/uh_embedded_video.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_discovery.gd
?? scripts/landmarks/urduja_house/uh_ext_01_discovery.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_discovery_content.gd
?? scripts/landmarks/urduja_house/uh_ext_01_discovery_content.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_editor_content.gd
?? scripts/landmarks/urduja_house/uh_ext_01_editor_content.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_hotspot.gd
?? scripts/landmarks/urduja_house/uh_ext_01_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_hotspot.gd
?? scripts/landmarks/urduja_house/uh_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd.uid
?? scripts/landmarks/urduja_house/uh_preview.gd
?? scripts/landmarks/urduja_house/uh_preview.gd.uid
?? scripts/landmarks/urduja_house/uh_revision_content.gd
?? scripts/landmarks/urduja_house/uh_revision_content.gd.uid
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd.uid
?? tests/uh_ext_01_editor_layout_test.gd
?? tests/uh_ext_01_editor_layout_test.gd.uid
?? tests/uh_ext_01_phase5_test.gd
?? tests/uh_ext_01_phase5_test.gd.uid
?? tests/uh_revision_render_test.gd
?? tests/uh_revision_render_test.gd.uid
?? tests/uh_revision_test.gd
?? tests/uh_revision_test.gd.uid
```

---

The earlier implementation report below is retained as historical context; the correction and validation above supersede its editor-layout claims.

# UH-EXT-01 — Technical Cleanup and Visual Editability

Updated 3 October 2026. Existing report updated in place. Approved Phase 5 content/design and interaction remain intact.

## 1. Exact warning source

`scripts/components/interactive_timeline.gd`, original line 16: `@onready var _main: PanelContainer = $Main`. Repository search found no use of `_main` beyond this declaration. It was a shared timeline script, not the discovery script.

## 2. Exact fix

Removed only that dead declaration/onready assignment. The Main node remains and no timeline behavior changed. This is the sole shared-component change, specifically required by the requested warning fix.

## 3. Warning suppression

None. No @warning_ignore added and no global warning setting changed.

## 4. Files modified / created

Modified in this technical-cleanup pass:

- `docs/uh_ext_01_phase5_report.md`
- `docs/uh_ext_01_testing.md`
- `scenes/landmarks/urduja_house/components/uh_ext_01.tscn`
- `scenes/landmarks/urduja_house/components/uh_ext_01_discovery.tscn`
- `scripts/components/interactive_timeline.gd`
- `scripts/landmarks/urduja_house/uh_ext_01_discovery.gd`
- `tests/uh_ext_01_phase5_test.gd`

Created:

- `data/landmarks/urduja_house/uh_ext_01_theme.tres`
- `scripts/landmarks/urduja_house/uh_ext_01_editor_content.gd`
- `scripts/landmarks/urduja_house/uh_ext_01_editor_content.gd.uid`
- `scripts/landmarks/urduja_house/uh_ext_01_hotspot.gd`
- `scripts/landmarks/urduja_house/uh_ext_01_hotspot.gd.uid`

No media or historical content resource was modified. The F6 harness and previous hotspot work retain their baseline bytes.

## 5. Scene architecture

The existing production wrapper → discovery instance → F6 harness relationship remains. Presentation ownership changed: the wrapper and discovery scenes now own the UI. A scoped wrapper-binding script inherits the existing behavior without invoking its runtime UI factory/legacy adapter. The discovery script keeps its selection/drag/fade/reset methods and binds scene nodes.

## 6. UI moved from script to scene

Header/title/subtitle/actions; dark panel StyleBox and margins; content Containers; media frame/texture/caption; interpretation scroll/labels/history sections/Look Closer; rail HBox/spacers/stops/node circles/diamond; takeaway padding/label; Sources overlay/scroll/close; AudioStreamPlayer. Stable styling is in an EXT-01-owned Theme resource copied from the existing visual values. No redesign.

A small @tool content helper is necessary for meaningful editor content without duplicating approved copy in .tscn. It only binds resource data and aligns rail decoration; it creates no UI or layout styling. Pre-save/post-save clears/restores preview text and derived media accessibility text so scene saves retain the resource as source of truth.

## 7. PRODUCTION SCENE TO INSTANTIATE

`res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn`

## 8. VISUAL EDITING SCENE

`res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn` — same as production. Discovery has Editable Children enabled. For focused body layout editing, open `res://scenes/landmarks/urduja_house/components/uh_ext_01_discovery.tscn` directly.

## 9. F6 TEST SCENE

`res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn`

## 10. Preview button

OPEN UH-EXT-01 PREVIEW remains only in the unchanged F6 harness. Production has no preview/reopen button.

## 11. Editable Inspector nodes

Production exposes 64 Control nodes. `Panel/MainMargin/MainVBox`: padding, main spacing, Header/title/action layout. `Content/Discovery/Layout/ContentRow`: media/text proportions, frame minima, image fit, caption spacing/alignment, interpretation scroll and typography. `DiscoveryRail/Stops`: button minima and spacer sizing; `Selector/Diamond`: polygon/color. `TakeawayMargin/Takeaway`: wrapping, padding and typography. Sources overlay and theme StyleBoxes are scene/resource-owned. Actual editor-mode verification selected MediaFrame in Inspector successfully.

## 12. Runtime-controlled properties

State text/media/caption, HISTORY/body visibility, Sources/hotspot visibility, audio/focus, local scroll resets, tween opacity and selector position. Rail endpoints derive from scene-managed stops. Compact mode (default below 900px available width) changes heading/body fonts, column/text separation and media/text proportions. Compact settings are exported on Discovery under Responsive compact layout. Wide mode restores scene-authored values captured at startup.

## 13. Inspector overwrite check

Passed simulated Inspector edits before startup: main/takeaway margins, media-caption gap/alignment, rail height, stop width, media-frame minimum, header spacing and wide typography/separation persist across compact/wide resize. The old legacy adapter no longer normalizes this component’s margins. Containers still control child positions normally; resize them through their documented Inspector properties.

## 14. PLACE result

Passed. Existing locator map, approved copy, caption and default/reopen selection preserved. Resource-backed PLACE content is visible in the editor before F6.

## 15. HISTORY result

Passed. Both 1953/Construction Begins and 1982/An Earlier View sections, approved fact/photo explanation, September 1982 caption and optional LOOK CLOSER remain unchanged. Compact scrolling retained.

## 16. TODAY result

Passed. Present-day photo, caption, official-residence copy and supporting line unchanged. No new historical content.

## 17. Drag / tap result

Passed mouse/direct selection and synthetic touch/drag regression, nearest-stop snapping, horizontal clamp and latest requested selection. The marker and rail now follow scene-authored Container positions.

## 18. Keyboard result

Passed Tab/Shift+Tab, Enter/Space, focused Left/Right without wrapping, Escape/Backspace, Sources focus containment and reset behavior.

## 19. 1280×720 result

Passed full and inset render/layout checks for all three states. Representative screenshots inspected; approved layout retained.

## 20. 960×540 result

Passed full and inset checks. Compact layout exports reproduce the existing proportions/type/gaps; local scrolling retained.

## 21. 854×480 result

Passed full and inset checks. Touch targets, media/captions, rail and takeaway remain within the parent. HISTORY/TODAY prose scroll locally as before.

## 22. Inset-parent result

Passed the real F6 wrapper’s 5% inset and full-parent layouts. Production does not change viewport scaling; only the unchanged standalone wrapper does so for F6 testing.

## 23. Headless test total

1,208 checks; zero failures. Existing test extended with Inspector-property preservation checks. No input/state assertion removed; the selector check now recognizes the scene-authored Polygon2D rather than a runtime draw callback.

## 24. Rendered test total

1,227 checks; zero failures. 18 state/size/frame captures plus Sources and scrolled HISTORY. Editor-mode probe additionally confirmed visible resource-backed content, 64 Controls, Inspector selection, and pre-save clearing/post-save restoration.

## 25. Godot warning/error state

Unused `_main` declaration is gone; no suppression. Normal Godot 4.7.2 headless editor import exited 0 with no project script/resource errors or new GDScript warnings. Runtime suites report no project errors. Existing host certificate-store diagnostic remains. The separate hidden programmatic editor probe logged editor progress-dialog current-window diagnostics; they did not occur in the normal editor import/runtime tests. Its earlier save-hook typed-array error was fixed and the final editor probe confirmed successful clear/restore.

## 26. Git diff --check

Passed; git diff --cached --check also passed. No staging, commit or push. AGENTS.md, project.godot, media and approved content hashes match the pre-task baseline. Shared-component delta is only the explicitly requested dead timeline declaration.

## 27. Final git status --short

This includes pre-existing modifications/untracked files preserved from earlier milestones.

```text
 D assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.jpeg
 D assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.jpeg.import
 M data/landmarks/urduja_house/uh_end_01.tres
 M data/landmarks/urduja_house/uh_ent_01.tres
 M data/landmarks/urduja_house/uh_ext_01.tres
 M data/landmarks/urduja_house/uh_ext_02.tres
 M data/landmarks/urduja_house/uh_ext_03.tres
 M data/landmarks/urduja_house/uh_int_01.tres
 M data/landmarks/urduja_house/uh_int_02.tres
 M data/landmarks/urduja_house/uh_int_03.tres
 M data/landmarks/urduja_house/uh_int_04.tres
 M docs/uh_end_01_testing.md
 M docs/uh_ent_01_testing.md
 M docs/uh_ext_01_testing.md
 M docs/uh_ext_02_testing.md
 M docs/uh_ext_03_testing.md
 M docs/uh_int_01_testing.md
 M docs/uh_int_02_testing.md
 M docs/uh_int_03_testing.md
 M docs/uh_int_04_testing.md
 M scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn
 M scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn
 M scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_01.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_02.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_03.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_04.tscn
 M scenes/landmarks/urduja_house/summary/uh_end_01.tscn
 M scenes/landmarks/urduja_house/supporting/uh_ent_01.tscn
 M scripts/components/interactive_timeline.gd
 M tests/cr_ext_01_test.gd
?? assets/landmarks/urduja_house/audio/uh_end_01_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_end_01_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_02_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_02_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.JPG
?? assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.JPG.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png.import
?? data/landmarks/urduja_house/revision/
?? data/landmarks/urduja_house/uh_ext_01_theme.tres
?? docs/specifications/urduja_house/revision_2026_10_02.md
?? docs/uh_ext_01_phase5_report.md
?? docs/urduja_house_media_credits.md
?? docs/urduja_house_revision_report.md
?? scenes/landmarks/urduja_house/components/
?? scripts/landmarks/urduja_house/uh_embedded_video.gd
?? scripts/landmarks/urduja_house/uh_embedded_video.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_discovery.gd
?? scripts/landmarks/urduja_house/uh_ext_01_discovery.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_discovery_content.gd
?? scripts/landmarks/urduja_house/uh_ext_01_discovery_content.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_editor_content.gd
?? scripts/landmarks/urduja_house/uh_ext_01_editor_content.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_hotspot.gd
?? scripts/landmarks/urduja_house/uh_ext_01_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_hotspot.gd
?? scripts/landmarks/urduja_house/uh_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd.uid
?? scripts/landmarks/urduja_house/uh_preview.gd
?? scripts/landmarks/urduja_house/uh_preview.gd.uid
?? scripts/landmarks/urduja_house/uh_revision_content.gd
?? scripts/landmarks/urduja_house/uh_revision_content.gd.uid
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd.uid
?? tests/uh_ext_01_phase5_test.gd
?? tests/uh_ext_01_phase5_test.gd.uid
?? tests/uh_revision_render_test.gd
?? tests/uh_revision_render_test.gd.uid
?? tests/uh_revision_test.gd
?? tests/uh_revision_test.gd.uid
```

## 28. Researcher visual editing steps

1. Open `res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn` in Godot and choose **2D**. Select the root and press **F** to frame it if needed.
2. Expand `Panel/MainMargin/MainVBox`. Select MainMargin/Header/MainVBox to adjust padding and spacing.
3. Expand `Content/Discovery/Layout` (Editable Children is enabled), or open the Discovery subscene directly. Select MediaFrame, MediaColumn, MediaCaption, InfoScroll/InfoColumn, DiscoveryRail and TakeawayMargin to edit layout via Inspector.
4. Keep node names/paths intact. Use Container sizing flags/minimum sizes/margins for child layout. Leave approved text in the existing content .tres, not Label Text fields.
5. Edit compact-mode options on the Discovery root if needed; wide defaults live on the relevant nodes. Save.
6. Open `res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn` and press **F6**. Recheck PLACE/HISTORY/TODAY, drag/tap, keyboard, Sources, disabled LISTEN, close/reopen and all three sizes. See `docs/uh_ext_01_testing.md` for the complete VISUAL EDITING / INTEGRATION handoff.

## 29. Virtual-environment teammate instructions

Instance `res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn` under the intended parent Control; size that parent with Containers/anchors. Do not instance the F6 harness. Call `open_interaction()` after the instance is ready. Connect `closed` to restore environment focus/overlay state or remove the instance. Close handles input before signaling, stops media and resets to PLACE. No hard-coded map navigation or viewport changes are introduced. Retain the discovery scene, theme, scripts and content/media dependencies when integrating.

## Pre-task Git state

```text
 D assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.jpeg
 D assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.jpeg.import
 M data/landmarks/urduja_house/uh_end_01.tres
 M data/landmarks/urduja_house/uh_ent_01.tres
 M data/landmarks/urduja_house/uh_ext_01.tres
 M data/landmarks/urduja_house/uh_ext_02.tres
 M data/landmarks/urduja_house/uh_ext_03.tres
 M data/landmarks/urduja_house/uh_int_01.tres
 M data/landmarks/urduja_house/uh_int_02.tres
 M data/landmarks/urduja_house/uh_int_03.tres
 M data/landmarks/urduja_house/uh_int_04.tres
 M docs/uh_end_01_testing.md
 M docs/uh_ent_01_testing.md
 M docs/uh_ext_01_testing.md
 M docs/uh_ext_02_testing.md
 M docs/uh_ext_03_testing.md
 M docs/uh_int_01_testing.md
 M docs/uh_int_02_testing.md
 M docs/uh_int_03_testing.md
 M docs/uh_int_04_testing.md
 M scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn
 M scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn
 M scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_01.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_02.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_03.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_04.tscn
 M scenes/landmarks/urduja_house/summary/uh_end_01.tscn
 M scenes/landmarks/urduja_house/supporting/uh_ent_01.tscn
 M tests/cr_ext_01_test.gd
?? assets/landmarks/urduja_house/audio/uh_end_01_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_end_01_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_02_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_02_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.JPG
?? assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.JPG.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png.import
?? data/landmarks/urduja_house/revision/
?? docs/specifications/urduja_house/revision_2026_10_02.md
?? docs/uh_ext_01_phase5_report.md
?? docs/urduja_house_media_credits.md
?? docs/urduja_house_revision_report.md
?? scenes/landmarks/urduja_house/components/
?? scripts/landmarks/urduja_house/uh_embedded_video.gd
?? scripts/landmarks/urduja_house/uh_embedded_video.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_discovery.gd
?? scripts/landmarks/urduja_house/uh_ext_01_discovery.gd.uid
?? scripts/landmarks/urduja_house/uh_ext_01_discovery_content.gd
?? scripts/landmarks/urduja_house/uh_ext_01_discovery_content.gd.uid
?? scripts/landmarks/urduja_house/uh_hotspot.gd
?? scripts/landmarks/urduja_house/uh_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd.uid
?? scripts/landmarks/urduja_house/uh_preview.gd
?? scripts/landmarks/urduja_house/uh_preview.gd.uid
?? scripts/landmarks/urduja_house/uh_revision_content.gd
?? scripts/landmarks/urduja_house/uh_revision_content.gd.uid
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd.uid
?? tests/uh_ext_01_phase5_test.gd
?? tests/uh_ext_01_phase5_test.gd.uid
?? tests/uh_revision_render_test.gd
?? tests/uh_revision_render_test.gd.uid
?? tests/uh_revision_test.gd
?? tests/uh_revision_test.gd.uid
```

UH-EXT-01 ONLY — NO COMMIT / NO PUSH
