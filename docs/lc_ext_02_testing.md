# LC-EXT-02 — The Pagoda-Like Bell Tower

Phase 5 implementation report, 25 September 2026. Automated and rendered checks
passed; researcher F6 approval and physical-device review remain pending.

## 1. Scope

Standalone exterior architectural observation with a stable main photograph,
three directly selectable image markers, one moving focus region, detail photos
and the exact approved explanatory copy. No forced sequence, completion tracking,
master-landmark integration or later hotspot is included.

Inspected before implementation:

- `AGENTS.md` and repository status, index, working diff and last five commits.
- Shared `conference_room_interaction.tscn`/`.gd`, its content/concept resources,
  Sources modal, input consumption, focus chain and narration lifecycle.
- LC-EXT-01 component, resource, shell, finalized neutral preview, preview sizing
  script and tests.
- Limahong `lch_ext_01` component/preview/input/tween patterns and `lch_int_01`
  explorer; `interactive_artwork_viewer.gd` for non-destructive AtlasTexture use.
- Existing `architecture_marker_layer.gd` and `architecture_marker.tscn`.
  That layer owns a separate information panel and uses broad 180 px markers;
  forcing it into this shell would add coupling. Standard Godot Buttons instead
  provide small symbols, large touch areas, native keyboard focus and activation.

The component inherits `ConferenceRoomInteraction`. `_selected` remains the one
authoritative index, mapped to `Observation.OVERVIEW`, `OVERALL_FORM`,
`TIERED_SILHOUETTE`, `TOWER_AND_CHURCH`. `set_observation()` updates all presentation
from the resource. Public methods are `open_hotspot()`, `close_hotspot()`,
`reset_hotspot()`, `set_observation()` and `get_observation()`; signals include
`hotspot_closed` and `observation_changed`. Existing shared files are unmodified.

Exact authored files created:

```text
scripts/landmarks/lingayen_church/lc_ext_02.gd
scripts/landmarks/lingayen_church/lc_ext_02_content.gd
scripts/landmarks/lingayen_church/lc_ext_02_observation.gd
scenes/landmarks/lingayen_church/exterior/lc_ext_02.tscn
scenes/landmarks/lingayen_church/exterior/lc_ext_02_preview.tscn
data/landmarks/lingayen_church/lc_ext_02.tres
tests/lc_ext_02_test.gd
docs/lc_ext_02_testing.md
```

Generated sidecars created:

```text
scripts/landmarks/lingayen_church/lc_ext_02.gd.uid
scripts/landmarks/lingayen_church/lc_ext_02_content.gd.uid
scripts/landmarks/lingayen_church/lc_ext_02_observation.gd.uid
tests/lc_ext_02_test.gd.uid
```

Existing files modified: **none**. The wrapper reuses the LC-EXT-01 preview sizing
script unchanged; no redundant preview script is added.

## 2. Assets

All assets were present before implementation in
`assets/landmarks/lingayen_church/lc_ext_02/images/` and visually inspected.

| Role | Actual filename | Native dimensions |
| --- | --- | --- |
| Main | `lc_ext_02_main_overview.jpg` | 4000 × 3000 |
| Overall Form detail | `lc_ext_02_detail_overall_form.jpg` | 3072 × 4080 |
| Tiered Silhouette detail | `lc_ext_02_detail_tiered_silhouette.JPG` | 2592 × 1728 |
| Tower & Church detail | Runtime crop of main image | 2680 × 1080 |

The third filename has an uppercase `.JPG`; references match it exactly. No
renaming, image editing, additional image generation or import-setting changes.
Main image is always fully aspect-fitted at 4:3. Linear filtering is local to
documentary photo controls; pixel-art/project filtering settings are unchanged.

## 3. Photo attribution

One shared, always-visible credit below Sources applies to all photographs:
`PHOTO: AKAR Research Team, 2026`. It is separate from historical Sources and fits
one line at all three test sizes. No pending-photo-credit message is used.

## 4. Preview

F6 scene: `scenes/landmarks/lingayen_church/exterior/lc_ext_02_preview.tscn`.

Neutral gray background, centered title `The Pagoda-Like Bell Tower`,
`DEVELOPMENT PREVIEW · LC-EXT-02`, the supplied description and inset-parent note,
and `Examine the Bell Tower` launcher. The launcher calls `open_hotspot()` directly.
The component occupies a 5% inset parent; preview content hides while open and
returns on close. There is no photo background. Preview-only canvas sizing uses
the actual client dimensions and restores the host policy when removed.

## 5. Opening/reset

Every open resets to Overview, closes Sources, clears detail/focus/selection,
stops narration and cancels prior tweens. Initial keyboard focus is marker 1;
focus alone does not select it. Open fades for 180 ms and close for 160 ms.
Closing returns focus to the launcher. Reopen during closing, invalid observation
indices, reset during Sources, parent hiding and removal during a transition are
covered. Hidden/removed components stop activity safely.

## 6. Overview

All three markers visible, no selected fill, no architecture focus frame and no
detail photo. Heading, body, prompt and takeaway match the approved request
exactly. The numbered legend supplies persistent visible marker labels.

## 7. Marker 1

Overall Form selects `A Tall, Tiered Tower`, the approved body and portrait detail.
Its frame covers the tower's main vertical body. Other markers remain selectable.

## 8. Marker 2

Tiered Silhouette selects `A Pagoda-Like Profile`, the approved body and the actual
uppercase-`.JPG` upper-tower image. Its frame emphasizes upper/middle stacked tiers.
No interpretation of cultural architectural influence is added.

## 9. Marker 3

Tower & Church selects `Part of the Church's Present Form` and the approved body.
Its frame and detail crop emphasize the lower tower and adjoining church. No
visible section is dated or classified as original, surviving or reconstructed.

## 10. Direct switching

Mouse/touch sequence 1 → 3 → 2 → 1 passes at every target size. Any observation
can be activated directly. Exactly one marker has selected fill after activation;
the photograph and all controls remain available. Selecting the same marker keeps
it selected. There are no tabs, Next/Previous, Replay or completion controls.

## 11. Rapid switching

The harness makes 50 rapid observation changes and checks the final text, image,
selection and frame. A previous tween is killed before the next starts. The
current 160 ms transition fades text/detail and interpolates the single normalized
focus rectangle. Only one outgoing detail layer exists and it is hidden on
completion/cancellation. Mid-transition alpha is tested. No queued animations.

## 12. Focus overlay

Image-relative coordinates were chosen from the real main photo:

| Observation | Marker center (x, y) | Focus rect (x, y, width, height) |
| --- | --- | --- |
| Overall Form | (0.535, 0.590) | (0.390, 0.090, 0.290, 0.910) |
| Tiered Silhouette | (0.535, 0.300) | (0.415, 0.135, 0.250, 0.435) |
| Tower & Church | (0.355, 0.830) | (0.040, 0.640, 0.670, 0.360) |

The fitted viewer matches the actual image dimensions, including letterboxing
outside that viewer. Markers and frame multiply normalized values by its size,
never by screen dimensions. Live resizing recomputes geometry. No per-resolution
marker coordinates. A Godot Panel draws a 2 px muted-gold outline and faint
transparent interior; no raster overlays, glow or decorative motion.

## 13. Detail viewer

Aspect-fit TextureRects crossfade without stretching. Marker 3 uses AtlasTexture
with the original main image as atlas and pixel region `(160, 1920, 2680, 1080)`.
This is non-destructive. Detail height is 164 px at reference size, 100 px compact,
72 px at the smallest inset height. Detail remains visible at all required sizes.
The complete main photograph remains stable throughout switching.

## 14. Sources

Reuses the shared modal and focus confinement. Opening Sources settles the
current transition and preserves observation, detail texture, explanatory text
and final focus rectangle. Closing returns focus to Sources without resetting.
Escape closes Sources first; the next Escape closes the hotspot. Input is marked
handled before navigation/close can remove the screen, using the inherited path.

No LC-EXT-02 bibliography was supplied or found in inspected project metadata.
Sources therefore displays the selected heading with the explicit placeholder
`Historical source details pending researcher input.` Unrelated parish-history
citations are not presented as evidence for these architectural observations.
Researcher source metadata remains pending; no bibliographic information invented.

## 15. Narration pending

LISTEN is visible and disabled beside Close, with `Narration pending.` underneath.
No autoplay, fabricated audio, marker audio or transcript UI. The inherited single
`narration_stream` resource field and audio lifecycle accept one future narration
file without a layout redesign. Close/reset/hide/removal stop playback.

## 16. Keyboard

Tab order: Overall Form → Tiered Silhouette → Tower & Church → reading scroll →
Sources → Close, cycling in the shell. The reading-area stop permits keyboard
scrolling of long copy. Disabled LISTEN is skipped. Shift+Tab reverses order;
arrow keys move/clamp focus within markers without changing observation;
Enter/Space activate. The 56 px focus outline is distinct from the 34 px selected
badge. Sources confines focus to its scroll and Close controls.

## 17. Mouse

Native button clicks select/persist directly. Labels remain visible in the
legend; hover is not required to discover historical content. Mouse opening and
marker selection are dispatched through Godot input in the harness.

## 18. Touch

Each marker has a 34 × 34 px symbol inside a 56 × 56 px effective Button area.
Hit regions remain inside the image without overlapping at required sizes.
Synthetic touch tests cover selection and close, including taps 23 px from each
marker center, outside its visible badge but inside its effective hit target.
No drag, pinch, double tap or precise symbol-only tapping is needed. Physical
touchscreen/Web device validation remains a researcher check.

## 19. Responsive 1280×720

Two columns with 60:40 allocation, 16 px shell padding and 24 px column gap.
Title 30 px, heading 24 px, body 20 px; detail 164 px high. Main fitted photo is
approximately 612 × 459 px. Sources and credit remain outside the reading scroll.
Longer copy/takeaway may require local scrolling, without whole-panel overflow.
Headless and Compatibility-rendered checks pass; screenshots inspected.

## 20. Responsive 960×540

Two columns retained; padding reduces to 8 px and gap to 12 px. Title 22 px,
heading 20 px, body 18 px, detail 100 px. Main fitted photo approximately
433 × 325 px. Marker targets remain 56 px. No header collision; all essential
controls visible. Local reading scroll retains complete copy and takeaway.
Headless and Compatibility-rendered checks pass; screenshots inspected.

## 21. Responsive 854×480

Same two-column interaction and 18 px body text. Detail shrinks to 72 px before
reducing the main viewer or hit targets. Main fitted photo approximately
326 × 245 px; marker labels may wrap in the legend. Longer explanation and
takeaway require the internal reading scroll. Sources, credit and Close stay
visible, with no whole-screen scroll. No portrait redesign.
Headless and Compatibility-rendered checks pass; screenshots inspected.

## 22. Historical-safety checks

Historical copy lives in `data/landmarks/lingayen_church/lc_ext_02.tres`.
The harness compares every approved heading/body and takeaway verbatim and scans
displayed text for the prohibited dates and unsupported claims from the request.
No extra chronology, personalities, bell incidents or architectural interpretation
was introduced. Resource and script review confirms no game features or analytics.

## 23. Regression and technical results

Godot 4.7.2, Compatibility/OpenGL 3.3, Intel UHD Graphics for rendered checks.

| Check | Result |
| --- | --- |
| Headless project import | Passed |
| Standalone component scene load | Passed |
| Standalone preview scene load | Passed |
| LC-EXT-02 headless at all three sizes | Zero failures |
| LC-EXT-02 rendered at all three sizes | Zero failures |
| LC-EXT-02 live resize with selected observation | Passed |
| LC-EXT-01 regression at all three sizes | Zero failures |
| LCH-EXT-01 regression at all three sizes | Zero failures |
| Git/new-file whitespace checks | Passed |
| SHA-256 baseline audit of 338 existing files | All unchanged |

The live-resize check exposed a floating-point value of 56.00001 px for one
56 px marker width; its equality assertion now uses approximate Vector2 equality.
This was test precision, not a reduced hit target. Independent minimum-size and
edge-tap assertions remain in place.

Run from the project root (replace `godot` with your Godot executable):

```powershell
godot --headless --path . --editor --import --quit
godot --headless --path . res://scenes/landmarks/lingayen_church/exterior/lc_ext_02.tscn --quit-after 12
godot --headless --path . res://scenes/landmarks/lingayen_church/exterior/lc_ext_02_preview.tscn --quit-after 12
godot --headless --path . --script res://tests/lc_ext_02_test.gd
godot --path . --rendering-method gl_compatibility --script res://tests/lc_ext_02_test.gd -- --capture
godot --headless --path . --script res://tests/lc_ext_01_test.gd
godot --headless --path . --script res://tests/lch_ext_01_test.gd
git diff --check
git status --short
```

Rendered captures: Windows TEMP, `lc_ext_02_<width>_preview.png`,
`lc_ext_02_<width>_overview.png`, `lc_ext_02_<width>_observation<1-3>.png`.
Logs: TEMP `akar_lc_ext_02_import.log`, `_scene.log`, `_preview.log`, `_test.log`,
`_render.log`, `_regression_lc01.log`, `_regression_lch01.log`.

Git status before implementation (no staged files):

```text
 M project.godot
?? assets/landmarks/lingayen_church/lc_ext_02/
```

The latest existing commit was `1da9999 Add Urduja House summary cultural icon`.
All pre-existing work was preserved, including the modified project file, existing
untracked LC-EXT-02 photographs/import sidecars and committed Urduja work.

Git status after implementation:

```text
 M project.godot
?? assets/landmarks/lingayen_church/lc_ext_02/
?? data/landmarks/lingayen_church/lc_ext_02.tres
?? docs/lc_ext_02_testing.md
?? scenes/landmarks/lingayen_church/exterior/lc_ext_02.tscn
?? scenes/landmarks/lingayen_church/exterior/lc_ext_02_preview.tscn
?? scripts/landmarks/lingayen_church/lc_ext_02.gd
?? scripts/landmarks/lingayen_church/lc_ext_02.gd.uid
?? scripts/landmarks/lingayen_church/lc_ext_02_content.gd
?? scripts/landmarks/lingayen_church/lc_ext_02_content.gd.uid
?? scripts/landmarks/lingayen_church/lc_ext_02_observation.gd
?? scripts/landmarks/lingayen_church/lc_ext_02_observation.gd.uid
?? tests/lc_ext_02_test.gd
?? tests/lc_ext_02_test.gd.uid
```

No staging, commit or push occurred. Stop at LC-EXT-02 for researcher review.

## 24. Known environment warnings

Sandboxed runtime tests report inability to read the Windows root certificate
store. Rendered testing also reports that `user://` shader caching is unavailable.
These messages did not cause interaction-test failures. Import passed with normal
editor-cache access. The unchanged Limahong regression also emitted an ObjectDB
leak-at-exit warning (two instances) on its process output after zero failures.
No unrelated machine settings or project code were changed to suppress warnings.

## 25. Manual researcher F6 checklist

1. Open `scenes/landmarks/lingayen_church/exterior/lc_ext_02_preview.tscn` in Godot.
2. Press F6 and inspect the neutral preview, supplied text and large launcher.
3. Select `Examine the Bell Tower`. Confirm Overview, all three markers, no
   selected fill or focus region, disabled LISTEN, pending narration and credit.
4. Select 1 → 3 → 2 → 1. Compare detail photos, approved text and architectural
   focus regions. Scroll the reading area to the complete takeaway.
5. Rapidly alternate markers and close/reopen mid-transition. Confirm Overview
   returns with no stale image, frame, Sources panel or audio.
6. Select Tiered Silhouette, open Sources, Escape once (same observation), Escape
   again (neutral preview), then reopen (Overview). Source metadata is pending.
7. Tab/Shift+Tab through controls; use arrows within markers and Enter/Space to
   activate. Verify focus differs from selection and long copy is keyboard-scrollable.
8. Repeat at 1280 × 720, 960 × 540 and 854 × 480 client sizes, including resizing
   while an observation is selected. Use a separate run window if the editor
   embeds the game view. No project-setting changes are required.
9. Repeat one-tap marker and Close activation on a physical touchscreen when
   available. Final Web export/canvas/device validation is separate from desktop
   synthetic input and remains pending.

- [ ] Neutral F6 preview and launcher match established AKAR presentation.
- [ ] Dark heritage shell, inset border, title/subtitle, LISTEN/Close match AKAR.
- [ ] Main photograph remains complete and undistorted in every state.
- [ ] Three markers are directly selectable in any order, with one selected.
- [ ] Marker positions and focus regions follow the architecture at all sizes.
- [ ] Overall Form portrait detail and exact text are correct.
- [ ] Tiered Silhouette detail and exact text are correct.
- [ ] Tower & Church crop and exact text are correct.
- [ ] Rapid input and close/reopen are stable.
- [ ] No sequential requirement, completion tracking or game features.
- [ ] Sources preserves state and Escape closes Sources first.
- [ ] Reopening resets Overview, detail, frame, Sources and audio.
- [ ] LISTEN is disabled, pending status visible, no transcript.
- [ ] Photo credit is correct and original photographs remain unchanged.
- [ ] Mouse, keyboard and physical touch work; focus differs from selection.
- [ ] 1280 × 720 readable, controls reachable, no whole-screen scrolling.
- [ ] 960 × 540 readable, controls reachable, no whole-screen scrolling.
- [ ] 854 × 480 readable, internal text scroll usable, controls reachable.
- [ ] No unsupported historical claims or invented source metadata.
- [ ] LC-EXT-01 and Limahong remain unchanged.
- [ ] Researcher accepts focus/crop choices and compact reading layout.

Await researcher visual review and eventual explicit milestone-commit approval.
