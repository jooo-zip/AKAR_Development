# Urduja House — focused INT-02 / INT-03 / INT-04 correction

4 October 2026. This completed correction section supersedes the INT-02/03/04 interaction descriptions and test totals in the retained prior Master Phase 5 snapshot below. Only these three hotspots, their tests/content and requested documentation were changed. No duplicate report was created.

## Baseline and scope

AGENTS.md, current Git status/diff, the three production scenes/scripts/resources/F6 harnesses/guides and this report were inspected before edits. The working tree already contained the legitimate modified/deleted/untracked work listed in the prior master report. Current status/diff and non-asset file hashes were recorded in `%TEMP%/akar_int_correction/status_before.txt`, `diff_before.patch`, `baseline.json`. Scene/resource snapshots also live there.

Recorded baseline: INT-02 **578 headless / 578 rendered / 14 editor**, INT-03 **409 / 409 / 14**, INT-04 **438 / 438 / 14**, all zero failures. These results were retained as the baseline rather than erasing the previous validation history.

Protected EXT-01, EXT-02, EXT-03, ENT-01, INT-01, END-01, other landmarks, all three F6 harnesses, existing shared runtime components, AGENTS.md and project.godot match the captured baseline. No shared production component was changed. The only new resource script extends the existing Phase 5 content type to hold the researcher-approved observation arrays for INT-03 and INT-04; its content stays separate from behavior. No new asset, narration, shader, autoload, application route or game mechanic.

## UH-INT-02 — 2007 office-function transfer (items 1–10)

Changed production scene: `res://scenes/landmarks/urduja_house/components/uh_int_02.tscn`.
Changed behavior: `res://scripts/landmarks/urduja_house/uh_historical_time_track.gd`.
Changed guide: `docs/uh_int_02_testing.md`. Tests/report are listed under common changes below.

The existing 1953 / BEFORE 2007 / 2007 / TODAY timeline is preserved. Its resource `data/landmarks/urduja_house/revision/uh_int_02.tres` is byte-identical to the correction baseline, including the heading/body and “began in 1953”.

The new `OfficeTransfer` subtree is authored inside MediaFrame: ResidenceEndpoint, CapitolEndpoint, OfficeLine (ColorRect), OfficeArrow / Arrowhead (Polygon2D), OfficeToken (PanelContainer / Label), ResidenceStatus and CapitolStatus. The two endpoints and building names remain stationary. Only the **GOVERNOR'S DAILY OFFICE** card moves. There are no decorative building sprites or invented historical images.

Sequence: endpoints fade in for 0.25s; the muted-gold connector/arrow reveals for 0.30s; the office-function card moves from the left endpoint to the right for 1.30s with restrained sine easing; the Capitol endpoint brightens/restores for 0.30s as both final labels appear. Total **2.15 seconds**, plus the established short mode crossfade. No bounce, particles, shake, looping effect or sound. The completed state remains visible.

Left: **URDUJA HOUSE / Official Residence**. Right: **PANGASINAN PROVINCIAL CAPITOL**. Final left: **OFFICIAL RESIDENCE REMAINS**. Final right: **DAILY OFFICE TRANSFERRED**. The right-side approved history remains:

> In 2007, Governor Amado T. Espino Jr. transferred the Governor's daily office to the Pangasinan Provincial Capitol, while Urduja House remained the official residence.

Direct reactivation of 2007 by mouse, touch or keyboard replays from the start; no additional Replay button. Pointer-release selection is synchronized without accidentally starting a second sequence or clearing the selected date. Leaving 2007 immediately kills its Tween, resets progress/status emphasis and hides the transient graphic. Rapid return starts cleanly. Sources pauses the content animation while preserving narration; closing Sources permits the sequence to continue. Full Close stops narration and resets everything to 1953 on reopen.

The old malformed arrow string was removed completely from the script. The replacement is geometry, not a Unicode arrow. UTF-8 scans found no replacement characters or mojibake patterns in INT-02 scene/script/resource. Both the function-transfer wording and the residence-retained wording remain explicit; no renovation or physical building-relocation implication.

Token travel uses the Inspector-authored endpoint anchors, so parent resizing remains proportional. The token's height is 60px and text stays readable. At 854×480 inset, hiding the redundant graphic caption prevents the final status labels from clipping; the unchanged resource and Sources retain the interpretive graphic disclosure. Other timeline states and their captions are unchanged. Full/inset 1280×720, 960×540 and 854×480 passed; the complete historical paragraph is accessible through the existing local information scroll.

Editor validation opens the actual production scene, then shows the authored OfficeTransfer subtree to inspect all seven principal Controls without running the interaction. Nodes, anchors, line/token layout, main margins, media/info ratios, date rail and takeaway remain selectable/Inspector-editable. No runtime factory or @tool layout simulation.

## UH-INT-03 — observational hall photo (items 11–19)

Changed production scene: `res://scenes/landmarks/urduja_house/components/uh_int_03.tscn`.
Changed behavior: `res://scripts/landmarks/urduja_house/uh_ceremonial_media.gd`.
Changed resource: `res://data/landmarks/urduja_house/revision/uh_int_03.tres`.
Changed guide: `docs/uh_int_03_testing.md`.

ABOUT, both event records, event ordering/images/titles/dates/credits, narration, historical references and takeaway are preserved. An explicit baseline comparison checks that the first two modes and all event arrays/media-credit metadata remain unchanged.

EXPLORE SPACE now defaults to **Explore the Ceremonial Hall** with **Select an area of the photograph to observe how the hall is arranged.** No observation starts selected. The passive “Look around…” instruction was removed. The real `uh_int_03_hall_wide.png` remains fitted at its 531:352 aspect ratio; no zoom, magnifier, panorama or artificial detail.

| Direct observation | Heading | Approved body |
|---|---|---|
| CENTRAL SPACE | Open Central Area | The hall has a broad open area running through its center, creating a clear visual path through the room. |
| SIDE SEATING | Seating Along the Hall | Rows of chairs are arranged along the sides of the room, leaving the central area open. |
| FRONT FOCAL AREA | Front of the Hall | The far end of the hall forms a strong visual focal area within the room. |

An AspectRatioContainer matches the fitted image and contains a scene-authored ObservationPlane. Marker anchors are normalized: central **(0.53, 0.80)**, side **(0.20, 0.65)**, front **(0.53, 0.45)**. They stay aligned through letterboxing/full/inset resizing. Each Button has a **52×52 practical target** and a **28px visible ring**, reducing occlusion of the low-resolution photo. Selected rings use restrained gold emphasis; other rings soften. Equivalent labeled buttons in the information column support Tab/Shift+Tab and Enter/Space, alongside keyboard focus on the markers themselves. Mouse/touch activation and rapid selection update the same single panel immediately. No modal duplication or stored completion state.

Full/inset 1280×720, 960×540 and 854×480 passed. Local information scrolling retains the approved text and text alternatives at compact sizes. Editor tests show the observation layer and select each actual marker in the Inspector, confirming authored coordinates and useful geometry. Returning to EXPLORE SPACE restores its intro; full close/reopen returns ABOUT and event 1.

## UH-INT-04 — professional room interpretation (items 20–29)

Changed production scene: `res://scenes/landmarks/urduja_house/components/uh_int_04.tscn`.
Changed behavior: `res://scripts/landmarks/urduja_house/uh_room_function.gd`.
Changed resource: `res://data/landmarks/urduja_house/revision/uh_int_04.tres`.
Changed guide: `docs/uh_int_04_testing.md`.

**“AKAR Interpretive View” is removed from the main visitor heading and caption.** EXPLORE THE SPACE defaults to **Explore the Conference Room** and **Select an area to observe how the room is arranged for meetings and continuing official use.** No observation is preselected; the former image caption is hidden. The image remains `uh_int_04_conference_room_pixel_art.png` in this mode and retains nearest filtering. The existing optional spatial outlines remain; selecting an area now supplies its approved interpretation as well.

Exact revised copy:

### MEETING TABLE — A Central Space for Discussion

The large central table provides a shared setting for formal discussions and meetings. Its central placement allows participants to gather around a common discussion area.

### SEATING ARRANGEMENT — Clearer Sightlines Around the Table

The curved arrangement of the table and surrounding seating creates clearer sightlines across the room, allowing participants to face one another more directly with less visual obstruction.

### OVERALL ROOM SETTING — A Formal Meeting Environment

The conference room combines a large central meeting table, surrounding seating, formal interior finishes, and an organized layout suited to official discussions and administrative meetings.

Supporting line: Together with the Ceremonial Hall and other reception spaces, the room helps show that Urduja House remains connected with continuing government functions.

### DOCUMENTED USE — The Conference Room in Use

An official Provincial Government photograph documents the conference-room space being used during an institutional meeting, providing visual evidence of its continuing administrative function.

### WHY IT MATTERS — A Continuing Government Function

Together with the reception and ceremonial spaces, the conference room helps demonstrate that Urduja House remains connected with continuing provincial government functions.

Takeaway remains: **Urduja House remains an active government residence rather than only a historical display.** No architect/design-intention, research-process, participant or additional event claim was added.

DOCUMENTED USE continues to display `uh_int_04_conference_room.png`. Sources credits **Provincial Government of Pangasinan**; photo courtesy **Pangasinan Polytechnic College** and **Chona C. Bugayong / PIMRO**, with the existing documented article reference/URL and unresolved capture-date/permission status retained.

The artwork's disclosure appears only in Sources/media credits: **Project-created interpretive representation / Source: AKAR Team**; it is explicitly not documentary evidence. The modes and source record distinguish it from the official photograph without a prominent main-view disclaimer. No photographer/license was invented.

All three spatial choices support mouse, touch and keyboard; selection changes heading/body/supporting line, resets local reading scroll, and updates the outline. OVERALL ROOM SETTING clears the outline. Mode reentry restores the default intro. Full/inset 1280×720, 960×540 and 854×480 passed; long interpretation and its supporting line remain accessible through local scrolling. Editor-authored headings, media, columns, focus controls, margins and spacing remain editable.

## Standalone, tests and diagnostics (items 30–32)

All three production scenes were instantiated directly under a generic Control without their F6 harness. `open_interaction()`, all internal interactions, `close_interaction()`, `closed` emission, public reset, reopen and arbitrary parent sizing passed. The F6 harnesses separately reopened the same production scenes and remain unchanged. No avatar/map/master dependency or landmark-specific parent path was introduced. SOURCES, LISTEN, CLOSE, mouse, synthetic touch, keyboard and no-autoplay behavior are preserved.

| Hotspot | Recorded baseline H/R/E | Corrected headless | Corrected rendered | Corrected editor | Failures |
|---|---|---:|---:|---:|---:|
| UH-INT-02 | 578 / 578 / 14 | 636 | 636 | 28 | 0 |
| UH-INT-03 | 409 / 409 / 14 | 495 | 495 | 20 | 0 |
| UH-INT-04 | 438 / 438 / 14 | 500 | 500 | 14 | 0 |

Dedicated checks cover animation midpoint/completion/replay/leaving/rapid return, narration/Sources/close during animation, every observation's approved text, ring alignment/touch target size, room disclosure/caption state, keyboard equivalents and default reset. A genuine compact-layout failure was fixed before final regression: both 2007 status labels clipped at 854×480 inset. The native date-button release also initially cleared the selected style; its state synchronization was corrected. Final tests retain those assertions and pass.

Final **existing nine-hotspot Urduja regression**, with protected implementations untouched:

| Hotspot | Headless | Rendered | Failures |
|---|---:|---:|---:|
| UH-EXT-01 | 1240 | 1259 | 0 |
| UH-EXT-02 | 384 | 384 | 0 |
| UH-EXT-03 | 774 | 774 | 0 |
| UH-ENT-01 | 103 | 103 | 0 |
| UH-INT-01 | 428 | 428 | 0 |
| UH-INT-02 | 636 | 636 | 0 |
| UH-INT-03 | 495 | 495 | 0 |
| UH-INT-04 | 500 | 500 | 0 |
| UH-END-01 | 684 | 684 | 0 |
| **Total** | **5244** | **5263** | **0** |

The correction's editor total is **62 checks**, zero failures. Both full/inset layouts passed at all three target resolutions. Rendered Compatibility captures were visually inspected for the animation final/midpoint states, hall markers and room interpretations. Touch automation injects Godot touch events; physical-device touch and listening remain manual checks. Approved recording/transcript equivalence is not asserted by playback-state tests.

Godot 4.7.2 Compatibility: no new script/parser errors, missing resources or null-node errors. The existing Windows root-certificate-store diagnostic persists. Custom headless editor-as-SceneTree probes can emit RID/ObjectDB shutdown leaks; these are reported, not suppressed. Headless final runtime regression uses a headless display with WASAPI audio and 60fps cap, following the established EXT-01 Dummy-driver timing qualification in the prior report. Dedicated corrected-hotspot headless tests also passed with Dummy. No warnings setting was disabled and no project.godot serialization change was retained.

Text/resource audit: INT-02 data byte-identical; “began in 1953” retained; office-transfer and residence-retained claims preserved; no malformed INT-02 text; hall About/events metadata unchanged; exact user-approved observation/spatial text stored separately from logic; 21 direct scene/resource references resolve. No unsupported symbolic or historical design-intention claims.

Evidence: `%TEMP%/akar_int_correction/*_headless.log`, `*_render.log`, `*_editor.log`, `final_<id>_<mode>.log`, baseline snapshots and changes.json. Runtime captures remain in `%TEMP%/akar_remaining_phase5/`, including `uh_int_02_office_mid_<width><inset>.png`, `uh_int_03_hall_<width><inset>_<point>.png`, `uh_int_04_room_<width><inset>_<point>.png` and the normal state captures. These are verification artifacts, not production dependencies.

## File changes and Git (items 1, 11, 20, 33–34)

Modified in this focused pass (relative to its saved baseline):

- `data/landmarks/urduja_house/revision/uh_int_03.tres`
- `data/landmarks/urduja_house/revision/uh_int_04.tres`
- `docs/uh_int_02_testing.md`
- `docs/uh_int_03_testing.md`
- `docs/uh_int_04_testing.md`
- `docs/urduja_house_remaining_hotspots_phase5_report.md`
- `scenes/landmarks/urduja_house/components/uh_int_02.tscn`
- `scenes/landmarks/urduja_house/components/uh_int_03.tscn`
- `scenes/landmarks/urduja_house/components/uh_int_04.tscn`
- `scripts/landmarks/urduja_house/uh_ceremonial_media.gd`
- `scripts/landmarks/urduja_house/uh_historical_time_track.gd`
- `scripts/landmarks/urduja_house/uh_room_function.gd`
- `tests/uh_remaining_phase5_test.gd`

Created:

- `scripts/landmarks/urduja_house/uh_observation_content.gd`
- `scripts/landmarks/urduja_house/uh_observation_content.gd.uid`

No renames. `git diff --check`: PASS. `git diff --cached --name-only`: empty. Existing CRLF-to-LF notices are normalization notices, not whitespace errors. Nothing staged, committed or pushed. No `git add .`, reset, cleanup or unrelated rewrite. Git status below includes pre-existing work and should not be read as a list of this correction's changes.

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
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo.jpg
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo.jpg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png.import
?? assets/landmarks/urduja_house/exterior/uh_ext_02_rodriguez_portrait.jpeg
?? assets/landmarks/urduja_house/exterior/uh_ext_02_rodriguez_portrait.jpeg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_03_exterior_highres.jpeg
?? assets/landmarks/urduja_house/exterior/uh_ext_03_exterior_highres.jpeg.import
?? assets/landmarks/urduja_house/interior/uh_int_02_present_exterior.jpeg
?? assets/landmarks/urduja_house/interior/uh_int_02_present_exterior.jpeg.import
?? assets/landmarks/urduja_house/interior/uh_int_03_event_2024_12_01.jpg
?? assets/landmarks/urduja_house/interior/uh_int_03_event_2024_12_01.jpg.import
?? assets/landmarks/urduja_house/interior/uh_int_03_event_2025_03_05.png
?? assets/landmarks/urduja_house/interior/uh_int_03_event_2025_03_05.png.import
?? assets/landmarks/urduja_house/interior/uh_int_03_hall_wide.png
?? assets/landmarks/urduja_house/interior/uh_int_03_hall_wide.png.import
?? assets/landmarks/urduja_house/interior/uh_int_04_conference_room.png
?? assets/landmarks/urduja_house/interior/uh_int_04_conference_room.png.import
?? data/landmarks/urduja_house/revision/
?? data/landmarks/urduja_house/uh_ext_01_theme.tres
?? docs/specifications/urduja_house/revision_2026_10_02.md
?? docs/uh_ext_01_phase5_report.md
?? docs/urduja_house_media_credits.md
?? docs/urduja_house_remaining_hotspots_phase5_report.md
?? docs/urduja_house_revision_report.md
?? scenes/landmarks/urduja_house/components/
?? scripts/landmarks/urduja_house/uh_architecture_photo.gd
?? scripts/landmarks/urduja_house/uh_architecture_photo.gd.uid
?? scripts/landmarks/urduja_house/uh_artwork_examination.gd
?? scripts/landmarks/urduja_house/uh_artwork_examination.gd.uid
?? scripts/landmarks/urduja_house/uh_ceremonial_media.gd
?? scripts/landmarks/urduja_house/uh_ceremonial_media.gd.uid
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
?? scripts/landmarks/urduja_house/uh_historical_time_track.gd
?? scripts/landmarks/urduja_house/uh_historical_time_track.gd.uid
?? scripts/landmarks/urduja_house/uh_hotspot.gd
?? scripts/landmarks/urduja_house/uh_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd.uid
?? scripts/landmarks/urduja_house/uh_observation_content.gd
?? scripts/landmarks/urduja_house/uh_observation_content.gd.uid
?? scripts/landmarks/urduja_house/uh_phase5_content.gd
?? scripts/landmarks/urduja_house/uh_phase5_content.gd.uid
?? scripts/landmarks/urduja_house/uh_phase5_content_view.gd
?? scripts/landmarks/urduja_house/uh_phase5_content_view.gd.uid
?? scripts/landmarks/urduja_house/uh_phase5_explorer.gd
?? scripts/landmarks/urduja_house/uh_phase5_explorer.gd.uid
?? scripts/landmarks/urduja_house/uh_phase5_hotspot.gd
?? scripts/landmarks/urduja_house/uh_phase5_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_preview.gd
?? scripts/landmarks/urduja_house/uh_preview.gd.uid
?? scripts/landmarks/urduja_house/uh_reflection_gallery.gd
?? scripts/landmarks/urduja_house/uh_reflection_gallery.gd.uid
?? scripts/landmarks/urduja_house/uh_revision_content.gd
?? scripts/landmarks/urduja_house/uh_revision_content.gd.uid
?? scripts/landmarks/urduja_house/uh_room_function.gd
?? scripts/landmarks/urduja_house/uh_room_function.gd.uid
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd.uid
?? tests/uh_ent_01_phase5_regression.gd
?? tests/uh_ent_01_phase5_regression.gd.uid
?? tests/uh_ext_01_editor_layout_test.gd
?? tests/uh_ext_01_editor_layout_test.gd.uid
?? tests/uh_ext_01_phase5_test.gd
?? tests/uh_ext_01_phase5_test.gd.uid
?? tests/uh_remaining_phase5_test.gd
?? tests/uh_remaining_phase5_test.gd.uid
?? tests/uh_revision_render_test.gd
?? tests/uh_revision_render_test.gd.uid
?? tests/uh_revision_test.gd
?? tests/uh_revision_test.gd.uid
```

## Exact researcher F6 retest (item 35)

1. Open `res://scenes/landmarks/urduja_house/interior/uh_int_02.tscn` in Godot and press **F6 / Run Current Scene**. Select 1953, BEFORE 2007, 2007, TODAY. At 2007 watch only the daily-office token move, then verify both final status labels. Activate 2007 again with mouse, touch and Enter/Space to replay. Leave during motion; rapidly return; resize while moving. Start LISTEN, open/close SOURCES during animation, then CLOSE mid-animation. Activate **OPEN UH-INT-02 PREVIEW** and expect 1953 with idle audio.
2. Open `res://scenes/landmarks/urduja_house/interior/uh_int_03.tscn`; press **F6**. Check ABOUT; both OFFICIAL EVENTS with Previous/Next and their retained dates/credits; then EXPLORE SPACE and its default intro. Select CENTRAL SPACE, SIDE SEATING and FRONT FOCAL AREA using rings and text buttons. Check selected emphasis, alignment, approved text, 52px touch targets, keyboard focus and rapid switching. CLOSE and **OPEN UH-INT-03 PREVIEW** must return ABOUT with the first event reset.
3. Open `res://scenes/landmarks/urduja_house/interior/uh_int_04.tscn`; press **F6**. Verify Explore the Conference Room and its intro, no prominent “AKAR Interpretive View” caption/heading, then MEETING TABLE, SEATING ARRANGEMENT and OVERALL ROOM SETTING with the exact copy above. Scroll to the supporting line and controls when needed. Check DOCUMENTED USE's real photograph/copy and WHY IT MATTERS. SOURCES must retain the artwork disclosure and official-photo credit. CLOSE and **OPEN UH-INT-04 PREVIEW** restore the default intro with no observation selected.
4. For all three, repeat **1280×720, 960×540, 854×480** with a full Control parent and the harness's **5% inset**. Test mouse, physical touch, Tab/Shift+Tab, Enter/Space, Escape/Backspace, LISTEN start/stop/replay/natural finish, Sources close, rapid input and no autoplay. Compact text must scroll locally with every button reachable.
5. Open each matching `res://scenes/landmarks/urduja_house/components/uh_int_0N.tscn` directly in the **2D editor**. Select main margins, MediaColumn/MediaFrame, InfoScroll, buttons and TakeawayMargin. For INT-02 show OfficeTransfer and hide DocumentPanel to inspect the authored animation geometry; for INT-03 enable ObservationAspect to inspect normalized marker anchors. These are preview visibility toggles, not a requirement to run F6. Restore toggles without saving unintended initial visibility. The guides explain the exact nodes. Ordinary layout edits remain Inspector-authored and are not overwritten by responsive code.

Stopped after the focused correction and regression. No other hotspot was revised.

## Prior Master Phase 5 snapshot
# Urduja House — remaining hotspots Phase 5 master report

Completed 4 October 2026. All seven target hotspots passed dedicated checkpoints and the final nine-hotspot runtime regression. No master virtual environment or application-flow integration was built. No staging, commit or push.

## 1–12. Scope, starting state and architecture

This report continues the saved implementation rather than restarting it. At the resumed checkpoint EXT-02, EXT-03, INT-01 and INT-02 were implemented; INT-03's scene, resource, script and rendered/editor results were already saved. INT-03's expanded headless checkpoint was finished before INT-04, then END-01. Completed implementations were not rebuilt.

The initial Git state was already dirty: 31 tracked-path status entries (29 modified and two deleted exterior `.jpeg`/import paths), plus pre-existing untracked assets, production scenes, revision resources, scripts, tests and reports. Those user changes were preserved. A pre-task SHA256 baseline, original diff and status live in `%TEMP%/akar_remaining_phase5/baseline.json`, `diff_before.patch`, and `status_before.txt`. File lists below describe changes relative to that master-task baseline, not every pre-existing Git delta.

The seven production scenes use scene-authored Controls, Containers, Full Rect anchors, stable margins, minimum target heights and local information ScrollContainers. Each remains separate from its unchanged F6 harness. Static layout can be selected and adjusted directly in Godot 2D; it is not constructed by a runtime UI factory. A small `@tool` content-binding helper populates approved resource text and textures only; it performs no layout simulation or runtime geometry assignment.

Shared reuse: the existing `uh_hotspot.gd` lifecycle, Sources/back-navigation/audio contract and signals; the existing revision-content resource base; the existing EXT-01 heritage Theme; unchanged preview harness code. New `uh_phase5_hotspot.gd` binds these services to scene-authored nodes without invoking the legacy runtime UI factory. New `uh_phase5_explorer.gd` supplies optional direct selection, arrows, latest-input-wins crossfades and reset. Small specialized scripts handle photo markers, painting lens, draggable timeline, event carousel, room focus and gallery image orientation. No framework, autoload, shader, new image or synthetic audio was introduced.

Intentionally unchanged: `HistoricalHotspot`, the legacy reusable artwork/timeline/hall/summary implementations, `uh_hotspot.gd`, `uh_revision_content.gd`, `uh_legacy_presentation.gd`, `uh_preview.gd`, and all F6 harnesses relative to the master baseline. The existing dirty shared `interactive_timeline.gd` change predates this task. **UH-EXT-01 and UH-ENT-01 production/data/scripts/assets/tests and existing guides remain byte-identical to baseline. AGENTS.md and project.godot are unchanged.** No project serialization change is included.

### Integration contract for all seven revised production scenes

- Instantiate the production TSCN under an arbitrary ordinary Control. Full Rect anchors follow that parent; no absolute parent path, avatar, map, environment coordinate or harness dependency.
- `open_interaction() -> bool`: opens/reset default, returns true, emits `opened`, focuses usable content, stops another hotspot's narration, never autoplays.
- `close_interaction() -> void`: handles navigation input before emitting `closed`, cancels/resets selection/transitions, stops/reset audio, hides Sources and component, restores prior focus where valid. A connected parent may safely remove it.
- `reset_interaction() -> void`: resets content and audio while keeping current open/closed visibility status. No environment navigation is performed.
- `opened` and `closed` are the established integration signals. The inherited `return_to_map_requested`/`skip_requested` signals remain declared for compatibility; these seven scene-authored interfaces expose Close, not an invented map navigation action. ENT-01 retains its existing Skip behavior.
- Content/data lives under `data/landmarks/urduja_house/revision/`. Narration resources remain assigned, non-looping, with no autoplay. Sources uses relevant historical references/media credits. Approved transcripts remain in resources; no transcript-dump page is added to the revised Sources UI.
- Do not instance an F6 harness in the future master scene. No automatic scene switch or application route was added.

Static Inspector properties remain authoritative: main margins, Content/BodyRow separation, MediaColumn and InfoScroll stretch ratios, MediaFrame, caption font/spacing, Navigation and TakeawayMargin. Automated runtime checks altered the main margin and media ratio and verified they survived all mode changes and parent resizing. Runtime owns selected states, crossfade alpha, audio, focus and local scroll. The architecture markers use scene-authored anchors inside a fitted aspect plane. The lens and room outline compute their moving image-relative rectangles; the timeline calculates nearest button; carousel/gallery choose media. These are interaction geometry, not wholesale layout overrides.

### Narration inventory and audio evidence

All seven supplied streams imported, are 21 seconds, non-looping, and have identical SHA256 `5e44adb87270f4dc7586cf026902718c597544c394376fc0fdefe1e38fa4bd44`. The researcher explicitly accepted duplicates. No audio was generated or replaced. LISTEN mouse/touch/Enter/Space, stop/reset/replay, natural finish callback, selection/Sources continuity, and close/reopen passed for every assigned stream. The seven-scene suite seeks near the end to exercise the actual finished signal; EXT-01's preserved suite waits for the entire recording. Playback-state verification is not a claim that spoken content matches the transcript. Recording creator/rights remain unresolved.

- UH-EXT-02: `res://assets/landmarks/urduja_house/audio/uh_ext_02_narration.ogg` — enabled, no autoplay; PASS.
- UH-EXT-03: `res://assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg` — enabled, no autoplay; PASS.
- UH-INT-01: `res://assets/landmarks/urduja_house/audio/uh-int-01-narration.ogg` — enabled, no autoplay; PASS.
- UH-INT-02: `res://assets/landmarks/urduja_house/audio/uh_int_02_narration.ogg` — enabled, no autoplay; PASS.
- UH-INT-03: `res://assets/landmarks/urduja_house/audio/uh_int_03_narration.ogg` — enabled, no autoplay; PASS.
- UH-INT-04: `res://assets/landmarks/urduja_house/audio/uh_int_04_narration.ogg` — enabled, no autoplay; PASS.
- UH-END-01: `res://assets/landmarks/urduja_house/audio/uh_end_01_narration.ogg` — enabled, no autoplay; PASS.

Protected EXT-01 retains `res://assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg`; its playback regression passed. Protected ENT-01 has no narration assigned and keeps LISTEN disabled. Its unverified video remains deliberately withheld; this is the preserved approved state, not a new missing-resource defect.

### Media inventory and unresolved attribution

All ten supplied images imported and source bytes stayed unchanged. Asset dimensions:

| Asset under `res://assets/landmarks/urduja_house/` | Dimensions | Use |
|---|---:|---|
| `exterior/uh_ext_01_historical_photo.jpg` | 2662×1762 | EXT-02, INT-02, END-01; explicitly September 1982 |
| `exterior/uh_ext_02_rodriguez_portrait.jpeg` | 480×445 | EXT-02 governor portrait |
| `exterior/uh_ext_03_exterior_highres.jpeg` | 4032×3024 | EXT-03, END-01; EXIF orientation 3 corrected in display only |
| `interior/uh_int_01_princess_urduja_painting.jpg` | 364×442 | INT-01, END-01; Romeo C. Mananquil painting reproduction |
| `interior/uh_int_02_present_exterior.jpeg` | 4032×3024 | INT-02 present view; END-01 architecture thumbnail |
| `interior/uh_int_03_hall_wide.png` | 531×352 | INT-03, END-01; fitted documentary view |
| `interior/uh_int_03_event_2024_12_01.jpg` | 464×347 | INT-03 scholarship event |
| `interior/uh_int_03_event_2025_03_05.png` | 450×250 | INT-03 courtesy call |
| `interior/uh_int_04_conference_room_pixel_art.png` | 1448×1086 | INT-04 only; explicitly interpretive |
| `interior/uh_int_04_conference_room.png` | 1000×667 | INT-04 official documentary photograph |

No fake 1953 photograph, new summary icons, invented documentary detail, or excessive hall-photo zoom. The pixel-art exception is only INT-04; other seven-target visuals are real supplied media or explicitly interpretive date/office-transfer graphics.

Unresolved items are explicitly recorded in each resource's media credits: historical-photo photographer/license; portrait painter, reproduction photographer and rights; painting reproduction photographer/source/rights; event exact URLs and permissions where absent; hall individual photographer/rights; room artwork individual creator/date/rights and documentary capture date/rights. AKAR Team attribution is retained for the two supplied exterior photographs. No license, URL, ownership or photographer was invented. The room's supplied repository article-list URL is retained as such, not misrepresented as an exact article permalink. Earlier archival credit documents outside this task remain unchanged; the following Phase 5 resource records are authoritative for these new presentations.

## 13–20. UH-EXT-02 — Origin Story Explorer

Production / Godot 2D editing / teammate handoff: `res://scenes/landmarks/urduja_house/components/uh_ext_02.tscn`.

F6 harness: `res://scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn`.

Data: `res://data/landmarks/urduja_house/revision/uh_ext_02.tres`. Manual guide: `docs/uh_ext_02_testing.md`.

Vertical concept relationship GOVERNOR / OFFICIAL RESIDENCE / 1953; not a chronological timeline. Portrait → September 1982 documentary view → date-only panel. The 220ms fade and restrained connector emphasis communicate selection only. Default GOVERNOR.

Final checks: **384 headless, 384 rendered, 14 editor; zero failures.** All three viewport sizes, full and 5% inset parent, standalone production handoff, Sources, narration, mouse/synthetic touch/keyboard, rapid selection and close/reopen/reset passed. Media and layout were visually inspected in Compatibility captures. Inspector node selection and complete reference geometry passed in the actual Godot editor. Integration ready under the contract above.

Sources/media record:

Portrait: Painted Portraits of Governors Gallery, Pangasinan Provincial Capitol. Painter, image photographer and permission/license undocumented.

Historical photograph: I Love Pangasinan, “Urduja House in Lingayen Pangasinan”; September 1982. Photographer and permission/license unresolved.

1953: date panel, not a historical photograph.

Narration: researcher-supplied and approved despite duplicate-file detection. Individual recording credit/rights unresolved.

## 21–27. UH-EXT-03 — Architecture Photo Explorer

Production / Godot 2D editing / teammate handoff: `res://scenes/landmarks/urduja_house/components/uh_ext_03.tscn`.

F6 harness: `res://scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn`.

Data: `res://data/landmarks/urduja_house/revision/uh_ext_03.tres`. Manual guide: `docs/uh_ext_03_testing.md`.

Five optional regions: Roofline, Main Façade, Entrance, Overall Exterior Form and Landscaped Setting. Ring buttons (52px targets) and matching text buttons select the same approved observations. A 4:3 AspectRatioContainer keeps normalized marker anchors aligned with the fitted photo, accounting for letterboxing and resize. EXIF orientation 3 is corrected with flip_h/flip_v; source bytes remain intact. Default ROOFLINE. No invented symbolism/material claims.

Final checks: **774 headless, 774 rendered, 14 editor; zero failures.** All three viewport sizes, full and 5% inset parent, standalone production handoff, Sources, narration, mouse/synthetic touch/keyboard, rapid selection and close/reopen/reset passed. Media and layout were visually inspected in Compatibility captures. Inspector node selection and complete reference geometry passed in the actual Godot editor. Integration ready under the contract above.

Sources/media record:

Exterior photograph: AKAR Team. Researcher-captured/documentary photograph. Individual photographer and capture date undocumented.

Narration: researcher-supplied and approved despite duplicate detection. Individual credit/rights unresolved.

## 28–35. UH-INT-01 — Artwork Examination

Production / Godot 2D editing / teammate handoff: `res://scenes/landmarks/urduja_house/components/uh_int_01.tscn`.

F6 harness: `res://scenes/landmarks/urduja_house/interior/uh_int_01.tscn`.

Data: `res://data/landmarks/urduja_house/revision/uh_int_01.tres`. Manual guide: `docs/uh_int_01_testing.md`.

THE ARTWORK / THE LEGEND / CULTURAL MEANING with a movable magnifier. Its AtlasTexture samples the original reproduction at 2× display scale, clamps to the fitted painting, supports mouse/touch drag and keyboard arrows, and resets to center. THE LEGEND retains the qualification that Ibn Battuta’s Tawalisi account does not conclusively identify Pangasinan; the cultural significance is not presented as settled historical identification. Default THE ARTWORK.

Final checks: **428 headless, 428 rendered, 14 editor; zero failures.** All three viewport sizes, full and 5% inset parent, standalone production handoff, Sources, narration, mouse/synthetic touch/keyboard, rapid selection and close/reopen/reset passed. Media and layout were visually inspected in Compatibility captures. Inspector node selection and complete reference geometry passed in the actual Godot editor. Integration ready under the contract above.

Sources/media record:

Artwork: Romeo C. Mananquil. Digital reproduction image: researcher-supplied repository asset. Photographer, reproduction source and permission/license undocumented.

Magnifier samples the same 364×442 image; it does not create additional detail.

Narration: researcher-supplied and approved despite duplicate detection. Individual recording credit/rights unresolved.

## 36–44. UH-INT-02 — Historical Time Track

Production / Godot 2D editing / teammate handoff: `res://scenes/landmarks/urduja_house/components/uh_int_02.tscn`.

F6 harness: `res://scenes/landmarks/urduja_house/interior/uh_int_02.tscn`.

Data: `res://data/landmarks/urduja_house/revision/uh_int_02.tres`. Manual guide: `docs/uh_int_02_testing.md`.

Four direct/drag/keyboard states: 1953, BEFORE 2007, 2007, TODAY. 1953 shows a date panel with “began in 1953”; there is no photograph falsely dated 1953. BEFORE 2007 uses the photo captioned September 1982. 2007 shows an explicitly interpretive Urduja House → Provincial Capitol office-transfer graphic, not a map, photograph or renovation claim. TODAY shows the supplied AKAR Team exterior. Drag release snaps to the nearest date and does not revert to the initially pressed button. Default 1953.

Final checks: **578 headless, 578 rendered, 14 editor; zero failures.** All three viewport sizes, full and 5% inset parent, standalone production handoff, Sources, narration, mouse/synthetic touch/keyboard, rapid selection and close/reopen/reset passed. Media and layout were visually inspected in Compatibility captures. Inspector node selection and complete reference geometry passed in the actual Godot editor. Integration ready under the contract above.

Sources/media record:

Historical photograph: I Love Pangasinan, “Urduja House in Lingayen Pangasinan”; September 1982. Photographer and permission/license unresolved.

Present-day exterior: AKAR Team; researcher-captured/documentary photograph. Individual photographer and capture date undocumented.

1953 date panel and 2007 transition: Godot UI interpretation, not historical photographs or geographic maps.

Narration: researcher-supplied and approved despite duplicate detection. Recording credit/rights unresolved.

## 45–53. UH-INT-03 — Ceremonial Hall Media Explorer

Production / Godot 2D editing / teammate handoff: `res://scenes/landmarks/urduja_house/components/uh_int_03.tscn`.

F6 harness: `res://scenes/landmarks/urduja_house/interior/uh_int_03.tscn`.

Data: `res://data/landmarks/urduja_house/revision/uh_int_03.tres`. Manual guide: `docs/uh_int_03_testing.md`.

ABOUT / OFFICIAL EVENTS / EXPLORE SPACE. ABOUT retains the approved continuing-official-functions explanation. OFFICIAL EVENTS is one two-record carousel with Previous/Next and latest-input-wins transitions. EXPLORE SPACE is a fitted documentary view; the 531×352 source does not justify meaningful high-detail zoom/pan. Default ABOUT; carousel resets to the first event. Exactly two events are present.

Final checks: **409 headless, 409 rendered, 14 editor; zero failures.** All three viewport sizes, full and 5% inset parent, standalone production handoff, Sources, narration, mouse/synthetic touch/keyboard, rapid selection and close/reopen/reset passed. Media and layout were visually inspected in Compatibility captures. Inspector node selection and complete reference geometry passed in the actual Godot editor. Integration ready under the contract above.

Sources/media record:

Hall photograph: official See Pangasinan / PTCAO tourism website, per researcher. Individual photographer and permission/license undocumented.

March 5, 2025: Courtesy Call of the Dagupan City Prosecutor’s Office and Pangasinan Provincial Prosecutor’s Office. Source: official Province of Pangasinan. Photographer, exact source URL and permission/license unresolved in available repository record.

December 1, 2024: Ceremonial Awarding of Lotte Scholarships to Pangasinan Higher Education Institutions. Photo by Ghe_Anne C. Palaganas, per researcher-supplied metadata. Exact source URL and permission/license unresolved.

Narration: researcher-supplied and approved despite duplicate detection. Recording credit/rights unresolved.

The two records are:

1. **Courtesy Call of the Dagupan City Prosecutor's Office and Pangasinan Provincial Prosecutor's Office** — March 5, 2025. Source: Province of Pangasinan. Image: `res://assets/landmarks/urduja_house/interior/uh_int_03_event_2025_03_05.png`.
2. **Ceremonial Awarding of Lotte Scholarships to Pangasinan Higher Education Institutions** — December 1, 2024. Photo by Ghe_Anne C. Palaganas. Image: `res://assets/landmarks/urduja_house/interior/uh_int_03_event_2024_12_01.jpg`.

## 54–61. UH-INT-04 — Room Function Explorer

Production / Godot 2D editing / teammate handoff: `res://scenes/landmarks/urduja_house/components/uh_int_04.tscn`.

F6 harness: `res://scenes/landmarks/urduja_house/interior/uh_int_04.tscn`.

Data: `res://data/landmarks/urduja_house/revision/uh_int_04.tres`. Manual guide: `docs/uh_int_04_testing.md`.

EXPLORE THE SPACE / DOCUMENTED USE / WHY IT MATTERS. The first mode uses nearest-filtered pixel art labeled AKAR INTERPRETIVE VIEW and optional restrained spatial outlines for meeting table/seating; overall room setting clears the outline. These identify visible areas only. DOCUMENTED USE uses the real official photograph; WHY IT MATTERS retains documentary evidence and the approved continuing-government-function text. Mode changes crossfade; no unsupported furniture interpretation. Default EXPLORE THE SPACE.

Final checks: **438 headless, 438 rendered, 14 editor; zero failures.** All three viewport sizes, full and 5% inset parent, standalone production handoff, Sources, narration, mouse/synthetic touch/keyboard, rapid selection and close/reopen/reset passed. Media and layout were visually inspected in Compatibility captures. Inspector node selection and complete reference geometry passed in the actual Godot editor. Integration ready under the contract above.

Sources/media record:

Interpretive view: AKAR-created interpretive representation; not a photograph. Individual artist, creation date and permission/license unresolved.

Documentary photograph: Province of Pangasinan, “PPC Interim Governing Board approves curricula of four academic programs”. Photo courtesy: Pangasinan Polytechnic College; Chona C. Bugayong / PIMRO. Repository source URL: https://www.pangasinan.gov.ph/author/pixelpgsnadmin/page/21/ . Capture date and permission/license unresolved.

Narration: researcher-supplied and approved despite duplicate detection. Recording credit/rights unresolved.

## 62–69. UH-END-01 — Five-Theme Reflection Gallery

Production / Godot 2D editing / teammate handoff: `res://scenes/landmarks/urduja_house/components/uh_end_01.tscn`.

F6 harness: `res://scenes/landmarks/urduja_house/summary/uh_end_01.tscn`.

Data: `res://data/landmarks/urduja_house/revision/uh_end_01.tres`. Manual guide: `docs/uh_end_01_testing.md`.

BEGINNING / CULTURAL CONNECTION / CHANGING FUNCTION / CONTINUING ROLE / ARCHITECTURAL IDENTITY. Large documentary/artwork view plus image-backed direct theme selections. Mapping: September 1982 exterior / Mananquil painting / September 1982 exterior / Ceremonial Hall / high-resolution present-day exterior. The architectural thumbnail is the other approved present-day exterior. The final reflection question is optional, with no entry field, storage, progress/visited state or completion mechanic. No old pixel-art summary icons. Default BEGINNING.

Final checks: **684 headless, 684 rendered, 14 editor; zero failures.** All three viewport sizes, full and 5% inset parent, standalone production handoff, Sources, narration, mouse/synthetic touch/keyboard, rapid selection and close/reopen/reset passed. Media and layout were visually inspected in Compatibility captures. Inspector node selection and complete reference geometry passed in the actual Godot editor. Integration ready under the contract above.

Sources/media record:

Historical photograph: I Love Pangasinan, “Urduja House in Lingayen Pangasinan”; September 1982. Photographer and permission/license unresolved.

Princess Urduja painting: Romeo C. Mananquil. Photographer, digital reproduction source and permission/license undocumented.

Hall photograph: official See Pangasinan / PTCAO tourism website, per researcher. Individual photographer and permission/license undocumented.

Present-day exterior and architectural-theme thumbnail: AKAR Team; researcher-captured/documentary photographs. Individual photographer and capture date undocumented.

Narration: researcher-supplied and approved despite duplicate detection. Recording credit/rights unresolved.

## 70–85. Final Urduja-wide regression and evidence

Dedicated saved checkpoints before the final regression: EXT-02 380/380/14; EXT-03 770/770/14; INT-01 424/424/14; INT-02 574/574/14; INT-03 405/405/14; INT-04 434/434/14; END-01 680/680/14 (headless/rendered/editor), all zero failures. The final seven-target suite adds four assertions per hotspot for Inspector setting preservation, Close Sources touch, and Backspace. Earlier successful results were retained; totals below are the final runs only, not cumulative re-runs.

| Hotspot | Headless | Rendered Compatibility | Actual editor layout | Failures |
|---|---:|---:|---:|---:|
| UH-EXT-01 | 1240 | 1259 | 19 | 0 |
| UH-EXT-02 | 384 | 384 | 14 | 0 |
| UH-EXT-03 | 774 | 774 | 14 | 0 |
| UH-ENT-01 | 103 | 103 | Protected legacy scene; not reworked | 0 |
| UH-INT-01 | 428 | 428 | 14 | 0 |
| UH-INT-02 | 578 | 578 | 14 | 0 |
| UH-INT-03 | 409 | 409 | 14 | 0 |
| UH-INT-04 | 438 | 438 | 14 | 0 |
| UH-END-01 | 684 | 684 | 14 | 0 |
| **Total** | **5038** | **5057** | **117** | **0** |

1280×720: PASS. 960×540: PASS. 854×480: PASS. Full ordinary Control parent: PASS. 5% inset parent: PASS. Resizing while open: PASS. All revised production scenes were instantiated independently before their separate F6 wrapper was tested; no master integration dependency. In compact layouts information, gallery selections or optional room controls may use local vertical scrolling. Letterboxed images remain aspect-correct; the hall view does not imply additional source detail.

Mouse clicks/drags, synthetic engine touch/touch-to-mouse events, Tab/Shift+Tab, arrows, Enter/Space and Escape/Backspace passed. The date track also supports Home/End. Every visible action category was exercised: state/theme selectors, rings, lens, date drag, event Previous/Next, room focus choices, Sources, Close Sources, Listen, Close and F6 reopen. Rapid mode/event requests cancel preceding transitions. Narration never autoplays; Sources preserves it. Close/reopen restores the first selection, opacity, scroll, audio idle and hotspot-specific state. Tests alter Inspector margin/column ratio and confirm they are not overwritten by runtime responsiveness.

ENT-01 is a protected exception to the new scene-authored architecture: it retains its existing runtime-built video/status UI, disabled unverified video/audio controls, working transcript, Skip, Sources, keyboard/back and close/reopen. It is regression-tested and unchanged, not claimed to have been converted to a new visually authored production scene. All seven requested revised scenes are visually authored and integration ready.

Prohibited visitor phrases: zero matches across the 14 revised production scene/content files for “Princess Urduja Palace”, “originally known”, “guest house”, “guesthouse”, “Conrado Estrella”, “2012 rehabilitation”, “completed in 1953”, “built in 1953”, “constructed in 1953”, “2007 renovation”. The revised 1953 state wording is “began in 1953”. No unsupported historical explanation was added. No game mechanics, visitor completion requirement or claim of learning effectiveness.

Resource audit: 35 unique direct external scene/resource references resolve, plus successful Godot imports and loads of the actual scene/script/content/media graphs. All ten images and seven assigned narration streams passed preflight. No new missing resources, parser errors or null-node runtime errors.

Environment qualifications: Godot 4.7.2 Compatibility on Intel UHD/OpenGL 3.3. Windows emits the existing `Failed to read the root certificate store` diagnostic. Custom editor-as-SceneTree runs can emit shutdown RID/ObjectDB leak diagnostics; earlier rendered editor probes can emit progress-dialog `current_window` diagnostics. These are not hidden or globally suppressed. No new project parser/runtime warnings were observed. No claim of globally warning-free engine output.

The unchanged EXT-01 headless test initially reported three end-of-audio timing failures with the Dummy driver (also after a 60fps cap). Its rendered run passed. Re-running the unchanged test with a headless display and Windows WASAPI audio passed all 1,240 checks, including the full 21-second natural finish. Final headless regression therefore uses `--display-driver headless --audio-driver WASAPI --max-fps 60`; the seven dedicated headless checkpoints also passed using Dummy. No protected code or assertion was changed to force a pass. Synthetic touch/audio-state tests are not a substitute for physical-device touch and listening review.

Test commands (use the installed Godot executable in place of `godot`):

```text
godot --display-driver headless --audio-driver WASAPI --max-fps 60 --path . --script res://tests/uh_remaining_phase5_test.gd -- uh_int_03
godot --path . --script res://tests/uh_remaining_phase5_test.gd -- uh_int_03
godot --headless --editor --path . --script res://tests/uh_remaining_phase5_test.gd -- uh_int_03
```

Replace the ID for each of the seven revised hotspots. Protected EXT-01 uses existing `tests/uh_ext_01_phase5_test.gd` and `tests/uh_ext_01_editor_layout_test.gd`; protected ENT-01 uses new regression-only `tests/uh_ent_01_phase5_regression.gd`.

Evidence: `%TEMP%/akar_remaining_phase5/final_<id>_headless.log`, `_render.log`, `_editor.log`; state captures `<id>_<width>_full_<state>.png` and `_inset_<state>.png`; event-2 and ENT captures; original checkpoint logs; `final_results.json`, `audit.json`, `master_changes.json`, `status_final.txt`. EXT-01's existing suite writes its captures to its pre-existing test output location. Temporary tools/logs are outside the repository and are not production dependencies.

## 7–9, 86–87. Exact master-task file changes and Git

Modified relative to the saved master baseline (many of these are already untracked in Git):

- `data/landmarks/urduja_house/revision/uh_end_01.tres`
- `data/landmarks/urduja_house/revision/uh_ext_02.tres`
- `data/landmarks/urduja_house/revision/uh_ext_03.tres`
- `data/landmarks/urduja_house/revision/uh_int_01.tres`
- `data/landmarks/urduja_house/revision/uh_int_02.tres`
- `data/landmarks/urduja_house/revision/uh_int_03.tres`
- `data/landmarks/urduja_house/revision/uh_int_04.tres`
- `docs/uh_end_01_testing.md`
- `docs/uh_ext_02_testing.md`
- `docs/uh_ext_03_testing.md`
- `docs/uh_int_01_testing.md`
- `docs/uh_int_02_testing.md`
- `docs/uh_int_03_testing.md`
- `docs/uh_int_04_testing.md`
- `scenes/landmarks/urduja_house/components/uh_end_01.tscn`
- `scenes/landmarks/urduja_house/components/uh_ext_02.tscn`
- `scenes/landmarks/urduja_house/components/uh_ext_03.tscn`
- `scenes/landmarks/urduja_house/components/uh_int_01.tscn`
- `scenes/landmarks/urduja_house/components/uh_int_02.tscn`
- `scenes/landmarks/urduja_house/components/uh_int_03.tscn`
- `scenes/landmarks/urduja_house/components/uh_int_04.tscn`

Created during this master task:

- `docs/urduja_house_remaining_hotspots_phase5_report.md`
- `scripts/landmarks/urduja_house/uh_architecture_photo.gd`
- `scripts/landmarks/urduja_house/uh_architecture_photo.gd.uid`
- `scripts/landmarks/urduja_house/uh_artwork_examination.gd`
- `scripts/landmarks/urduja_house/uh_artwork_examination.gd.uid`
- `scripts/landmarks/urduja_house/uh_ceremonial_media.gd`
- `scripts/landmarks/urduja_house/uh_ceremonial_media.gd.uid`
- `scripts/landmarks/urduja_house/uh_historical_time_track.gd`
- `scripts/landmarks/urduja_house/uh_historical_time_track.gd.uid`
- `scripts/landmarks/urduja_house/uh_phase5_content.gd`
- `scripts/landmarks/urduja_house/uh_phase5_content.gd.uid`
- `scripts/landmarks/urduja_house/uh_phase5_content_view.gd`
- `scripts/landmarks/urduja_house/uh_phase5_content_view.gd.uid`
- `scripts/landmarks/urduja_house/uh_phase5_explorer.gd`
- `scripts/landmarks/urduja_house/uh_phase5_explorer.gd.uid`
- `scripts/landmarks/urduja_house/uh_phase5_hotspot.gd`
- `scripts/landmarks/urduja_house/uh_phase5_hotspot.gd.uid`
- `scripts/landmarks/urduja_house/uh_reflection_gallery.gd`
- `scripts/landmarks/urduja_house/uh_reflection_gallery.gd.uid`
- `scripts/landmarks/urduja_house/uh_room_function.gd`
- `scripts/landmarks/urduja_house/uh_room_function.gd.uid`
- `tests/uh_ent_01_phase5_regression.gd`
- `tests/uh_ent_01_phase5_regression.gd.uid`
- `tests/uh_remaining_phase5_test.gd`
- `tests/uh_remaining_phase5_test.gd.uid`

Renamed: none. No source media bytes changed. No production/harness file outside the seven target components was modified by the master pass. Existing deleted/modified/untracked user work remains intact.

`git diff --check`: PASS, exit 0. Existing CRLF→LF notices are normalization notices, not whitespace failures. `git diff --cached --name-only`: empty. No staging, commit, push or `git add .`. `AGENTS.md` and `project.godot`: no diff from baseline. Protected EXT-01/ENT-01 and source assets: SHA256 unchanged.

Final `git status --short` (includes pre-existing user work):

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
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo.jpg
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo.jpg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg
?? assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo_1982.jpg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png
?? assets/landmarks/urduja_house/exterior/uh_ext_01_locator_map.png.import
?? assets/landmarks/urduja_house/exterior/uh_ext_02_rodriguez_portrait.jpeg
?? assets/landmarks/urduja_house/exterior/uh_ext_02_rodriguez_portrait.jpeg.import
?? assets/landmarks/urduja_house/exterior/uh_ext_03_exterior_highres.jpeg
?? assets/landmarks/urduja_house/exterior/uh_ext_03_exterior_highres.jpeg.import
?? assets/landmarks/urduja_house/interior/uh_int_02_present_exterior.jpeg
?? assets/landmarks/urduja_house/interior/uh_int_02_present_exterior.jpeg.import
?? assets/landmarks/urduja_house/interior/uh_int_03_event_2024_12_01.jpg
?? assets/landmarks/urduja_house/interior/uh_int_03_event_2024_12_01.jpg.import
?? assets/landmarks/urduja_house/interior/uh_int_03_event_2025_03_05.png
?? assets/landmarks/urduja_house/interior/uh_int_03_event_2025_03_05.png.import
?? assets/landmarks/urduja_house/interior/uh_int_03_hall_wide.png
?? assets/landmarks/urduja_house/interior/uh_int_03_hall_wide.png.import
?? assets/landmarks/urduja_house/interior/uh_int_04_conference_room.png
?? assets/landmarks/urduja_house/interior/uh_int_04_conference_room.png.import
?? data/landmarks/urduja_house/revision/
?? data/landmarks/urduja_house/uh_ext_01_theme.tres
?? docs/specifications/urduja_house/revision_2026_10_02.md
?? docs/uh_ext_01_phase5_report.md
?? docs/urduja_house_media_credits.md
?? docs/urduja_house_remaining_hotspots_phase5_report.md
?? docs/urduja_house_revision_report.md
?? scenes/landmarks/urduja_house/components/
?? scripts/landmarks/urduja_house/uh_architecture_photo.gd
?? scripts/landmarks/urduja_house/uh_architecture_photo.gd.uid
?? scripts/landmarks/urduja_house/uh_artwork_examination.gd
?? scripts/landmarks/urduja_house/uh_artwork_examination.gd.uid
?? scripts/landmarks/urduja_house/uh_ceremonial_media.gd
?? scripts/landmarks/urduja_house/uh_ceremonial_media.gd.uid
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
?? scripts/landmarks/urduja_house/uh_historical_time_track.gd
?? scripts/landmarks/urduja_house/uh_historical_time_track.gd.uid
?? scripts/landmarks/urduja_house/uh_hotspot.gd
?? scripts/landmarks/urduja_house/uh_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd.uid
?? scripts/landmarks/urduja_house/uh_phase5_content.gd
?? scripts/landmarks/urduja_house/uh_phase5_content.gd.uid
?? scripts/landmarks/urduja_house/uh_phase5_content_view.gd
?? scripts/landmarks/urduja_house/uh_phase5_content_view.gd.uid
?? scripts/landmarks/urduja_house/uh_phase5_explorer.gd
?? scripts/landmarks/urduja_house/uh_phase5_explorer.gd.uid
?? scripts/landmarks/urduja_house/uh_phase5_hotspot.gd
?? scripts/landmarks/urduja_house/uh_phase5_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_preview.gd
?? scripts/landmarks/urduja_house/uh_preview.gd.uid
?? scripts/landmarks/urduja_house/uh_reflection_gallery.gd
?? scripts/landmarks/urduja_house/uh_reflection_gallery.gd.uid
?? scripts/landmarks/urduja_house/uh_revision_content.gd
?? scripts/landmarks/urduja_house/uh_revision_content.gd.uid
?? scripts/landmarks/urduja_house/uh_room_function.gd
?? scripts/landmarks/urduja_house/uh_room_function.gd.uid
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd.uid
?? tests/uh_ent_01_phase5_regression.gd
?? tests/uh_ent_01_phase5_regression.gd.uid
?? tests/uh_ext_01_editor_layout_test.gd
?? tests/uh_ext_01_editor_layout_test.gd.uid
?? tests/uh_ext_01_phase5_test.gd
?? tests/uh_ext_01_phase5_test.gd.uid
?? tests/uh_remaining_phase5_test.gd
?? tests/uh_remaining_phase5_test.gd.uid
?? tests/uh_revision_render_test.gd
?? tests/uh_revision_render_test.gd.uid
?? tests/uh_revision_test.gd
?? tests/uh_revision_test.gd.uid
```

## 88–90. Exact manual F6 sequence and teammate handoff

For each row below: open the listed F6 scene in Godot FileSystem, press **F6 / Run Current Scene**, select every listed state with mouse/touch/keyboard, open and close Sources, start/stop/replay Listen where enabled, close during playback, then activate the exact OPEN preview button. Repeat at 1280×720, 960×540, 854×480 and full/inset parents. The component supplied to the teammate is always the production path above, never the harness. Each of the seven uses the same public lifecycle/signals contract documented above. EXT-01/ENT-01 retain their established contracts.

| ID | Exact F6 scene | Default and sequence | Reopen button |
|---|---|---|---|
| UH-EXT-01 | `res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn` | PLACE → HISTORY → TODAY; drag diamond; Sources/Listen/Close | OPEN UH-EXT-01 PREVIEW |
| UH-EXT-02 | `res://scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn` | GOVERNOR → OFFICIAL RESIDENCE → 1953 | OPEN UH-EXT-02 PREVIEW |
| UH-EXT-03 | `res://scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn` | ROOFLINE → FAÇADE → ENTRANCE → EXTERIOR FORM → LANDSCAPED SETTING | OPEN UH-EXT-03 PREVIEW |
| UH-ENT-01 | `res://scenes/landmarks/urduja_house/supporting/uh_ent_01.tscn` | Withheld-video status → TRANSCRIPT → back; Sources/Close/Skip. Video/audio remain disabled. | OPEN UH-ENT-01 PREVIEW |
| UH-INT-01 | `res://scenes/landmarks/urduja_house/interior/uh_int_01.tscn` | THE ARTWORK → THE LEGEND → CULTURAL MEANING | OPEN UH-INT-01 PREVIEW |
| UH-INT-02 | `res://scenes/landmarks/urduja_house/interior/uh_int_02.tscn` | 1953 → BEFORE 2007 → 2007 → TODAY | OPEN UH-INT-02 PREVIEW |
| UH-INT-03 | `res://scenes/landmarks/urduja_house/interior/uh_int_03.tscn` | ABOUT → OFFICIAL EVENTS → EXPLORE SPACE | OPEN UH-INT-03 PREVIEW |
| UH-INT-04 | `res://scenes/landmarks/urduja_house/interior/uh_int_04.tscn` | EXPLORE THE SPACE → DOCUMENTED USE → WHY IT MATTERS | OPEN UH-INT-04 PREVIEW |
| UH-END-01 | `res://scenes/landmarks/urduja_house/summary/uh_end_01.tscn` | BEGINNING → CULTURAL CONNECTION → CHANGING FUNCTION → CONTINUING ROLE → ARCHITECTURAL IDENTITY | OPEN UH-END-01 PREVIEW |

INT-01: drag the magnifier outside the image, resize, and move it with keyboard arrows; confirm clamping and center reset. INT-02: drag directly between dates and test Home/End. INT-03: test both event records with Previous/Next and rapid selection; verify dates/credits and fitted hall view. INT-04: test both spatial outlines and overall view, then distinguish artwork from the documentary photo. END-01: visit any themes in any order; verify no progress or response is stored. Detailed per-hotspot guides list the exact assets and credits to inspect.

For editor handoff, open each production TSCN directly in 2D (not F6), select main margins, media frame/column, information column, navigation and takeaway. Inspector edits are scene-authored and remain effective at runtime. Open/close through the public API from an arbitrary Control parent to reproduce the independent production tests.

Stopped after this report; no Urduja House master virtual environment integration was performed.
