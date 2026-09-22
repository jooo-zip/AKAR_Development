# LCH-INT-01 — The Limahong Statue

Implementation and verification: 2026-09-23, Godot 4.7.2 stable, Compatibility renderer.
Ready for researcher F6/manual review. No commit or push. INT-02, INT-03,
master scenes, ENT-01 video and avatar work are outside this milestone.

## Targeted visual revision — 2026-09-23

Removed all three photo markers, captions, hit targets, marker-specific layout,
focus entries and runtime selection state. The two right-side section buttons
now present the existing full approved section paragraphs. Historical wording,
photo, Sources, narration and close behavior remain unchanged.

The magnifier is now a 76px circular lens, approximately 84px across including its
ring/short diagonal handle/shadow, inside a 96 × 96px hit area. It is drawn with
Godot circles/arcs/lines: muted-gold ring, restrained shadow, light glass tint and
short rounded handle. No new image asset was created. The same-photo detail image
is now 152 × 152px to preserve 2× magnification for the larger 76px source selection.

Revision audit: read AGENTS.md and recorded `git status --short` before editing.
The existing state contained 4 staged files, 15 unstaged files and 25 untracked
short-status entries, including the already implemented INT-01 files. Snapshot:
`%TEMP%/akar-int01-revision-20260923-033506` (HEAD, index, status and hashes of all
280 pre-existing files). The revision modifies only these seven existing files:

```text
scripts/landmarks/limahong_channel/lch_int_01.gd
scripts/landmarks/limahong_channel/lch_int_01_content.gd
scripts/landmarks/limahong_channel/lch_int_01_magnifier.gd
data/landmarks/limahong_channel/lch_int_01.tres
scenes/landmarks/limahong_channel/interior/lch_int_01_preview.tscn
tests/lch_int_01_test.gd
docs/lch_int_01_testing.md
```

Created during this revision: none. All 273 other pre-existing files, the staged
index and HEAD remain unchanged. The complete short Git status is identical before
and after this revision because the seven revised INT-01 files were already
untracked. No project.godot, Urduja, EXT or shared-shell files were changed.

Revision verification: **594 checks, zero failures** in both headless and native
Compatibility-rendered runs at all three requested sizes. Screenshots were
inspected for each default layout and for left-detail placement. Tests cover the
absence of marker controls/targets, clicks/touches at former marker anchors, exact
section text, handle dragging, enlarged lens bounds, continuous sampling, hysteresis,
keyboard movement, synthetic touch, Sources preservation and close/reopen reset.
No commit or push. Waiting for researcher review.

## Educational purpose and approved content

An embedded, self-paced statue explorer introduces Limahong / Lin Feng, his
historical role and the Channel connection. It uses one authentic photographic
view, a magnifying-glass inspection tool and two sections. It does not claim measured
learning effectiveness or introduce game mechanics.

All historical prose lives in `data/landmarks/limahong_channel/lch_int_01.tres`.
Both full approved section paragraphs now use the shell's `concepts` resources;
the information panel displays the chosen section directly:

| Section | Exact body |
| --- | --- |
| WHO WAS LIMAHONG? | Limahong, also known as Lin Feng, was a Chinese pirate and military leader. After his failed attacks on Manila in late 1574, he sailed to Pangasinan and established a fortified settlement. |
| WHY THIS SITE? | During the 1575 campaign, Limahong and part of his force escaped from Pangasinan by water. The present Limahong Channel is traditionally associated with that escape route. |

The full WHY THIS SITE? section preserves: “During the 1575 campaign, Limahong
and part of his force escaped from Pangasinan by water. The present Limahong
Channel is traditionally associated with that escape route.” The presentation
does not assert archaeological proof of the exact sixteenth-century channel.
The researcher-supplied narration transcript is also stored verbatim in data.

## Original implementation audit and preservation

Read root `AGENTS.md`; searched for additional applicable instructions. Inspected
EXT-01/02/03, the shared ConferenceRoomInteraction shell, InteractiveArtworkViewer
AtlasTexture cropping, and InteractiveTimeline pointer capture before implementation.
No existing reusable always-visible lens component was found.

Initial HEAD: `c73aeb003b3f1f7c786d1d0aab2dd13d47b5a815`.
Before editing: 4 staged files, 15 unstaged files and 14 untracked entries in
`git status --short` (directory entries group their contents). Exact audit:

```text
 M AGENTS.md
 M assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png
 M assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png.import
A  assets/landmarks/urduja_house/icons/summary_visitor_marker.png
A  assets/landmarks/urduja_house/icons/summary_visitor_marker.png.import
A  assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg
A  assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg.import
 M data/landmarks/limahong_channel/lch_ext_01.tres
 M data/landmarks/limahong_channel/lch_ext_01_locator_channel.tres
 M data/landmarks/limahong_channel/lch_ext_01_locator_lingayen.tres
 M data/landmarks/limahong_channel/lch_ext_01_locator_pangapisan.tres
 M data/landmarks/urduja_house/uh_end_01.tres
 M data/landmarks/urduja_house/uh_int_03.tres
 M data/landmarks/urduja_house/uh_int_04.tres
 M docs/lch_ext_01_testing.md
 M project.godot
 M scenes/landmarks/limahong_channel/exterior/lch_ext_01.tscn
 M scripts/landmarks/limahong_channel/lch_ext_01.gd
 M tests/lch_ext_01_test.gd
?? assets/landmarks/limahong_channel/lch_ext_01/audio/
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_location_marker.png
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_location_marker.png.import
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_movement_vessel.png
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_movement_vessel.png.import
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_route_ship.png
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_route_ship.png.import
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_settlement_icon.png
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_settlement_icon.png.import
?? assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_marker.png
?? assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_marker.png.import
?? assets/landmarks/limahong_channel/lch_ext_01/maps/lch_ext_02_regional_map.png
?? assets/landmarks/limahong_channel/lch_ext_01/maps/lch_ext_02_regional_map.png.import
?? assets/landmarks/limahong_channel/lch_int_01/
```

Audit snapshots are in `%TEMP%/akar-int01-audit`: status, HEAD, complete
`git ls-files --stage` output, and SHA-256 hashes of all 267 pre-existing tracked
and nonignored untracked files. Verification after editor import and testing:
267/267 file hashes unchanged; index entries identical; HEAD unchanged.
`project.godot`, AGENTS.md, all Urduja files and all EXT files remain byte-identical
to their pre-task state. Nothing was staged, unstaged, restored or reset.

## Reused components

- Inherited `scenes/components/conference_room_interaction.tscn` and its GDScript
  controller: heritage theme, panel, Sources modal, audio lifecycle, Escape hierarchy,
  focus restoration and original controls. Reparented inherited controls locally.
- Exact shared narration asset: `assets/ui/icons/speaker.svg`.
- Existing theme's cream focus outline, neutral buttons and selected gold styling.
- Existing content-resource separation and ConferenceRoomConceptEntry resources.
- Existing Limahong inset preview and SceneTree/Input.parse_input_event test patterns.
- Existing AtlasTexture approach for cropping. Pointer capture follows the shared
  timeline's GUI-start/global-motion pattern, with native touch-id adoption added
  locally for desktop mouse emulation.

No shared component or unrelated project file was modified.

## Complete milestone file inventory (original creation)

Created (13 files):

```text
data/landmarks/limahong_channel/lch_int_01.tres
scenes/landmarks/limahong_channel/interior/lch_int_01.tscn
scenes/landmarks/limahong_channel/interior/lch_int_01_preview.tscn
scripts/landmarks/limahong_channel/lch_int_01.gd
scripts/landmarks/limahong_channel/lch_int_01.gd.uid
scripts/landmarks/limahong_channel/lch_int_01_content.gd
scripts/landmarks/limahong_channel/lch_int_01_content.gd.uid
scripts/landmarks/limahong_channel/lch_int_01_magnifier.gd
scripts/landmarks/limahong_channel/lch_int_01_magnifier.gd.uid
tests/lch_int_01_test.gd
tests/lch_int_01_test.gd.uid
docs/lch_int_01_testing.md
assets/landmarks/limahong_channel/lch_int_01/photos/lch_int_01_statue_photo.jpg.png.import
```

Existing researcher-supplied, untracked asset used without alteration:

```text
assets/landmarks/limahong_channel/lch_int_01/photos/lch_int_01_statue_photo.jpg.png
```

During original creation, no pre-existing files were modified; the seven later
revision edits are listed above. `.godot/` import caches are ignored/generated and
are not milestone source files. A later approved milestone commit should include
the supplied photo and these 13 files, while excluding unrelated work.

## Asset and Sources status

The actual supplied photo is a **1254 × 1254 PNG**, despite its `.jpg.png` filename.
It is used directly as the real statue photograph, not a development placeholder.
It was not renamed, converted, downloaded or replaced with generated imagery.
Linear filtering and aspect fitting show the entire original photographic view.
The Detail View samples that same texture; no second zoomed asset exists.

Photographer, original photo source and usage permissions remain unconfirmed.
No attribution or license has been invented. Sources lists the researcher-supplied
wording and the source categories already recorded in Limahong content: Francisco
de Sande account, Project Historical Profile / Validation Sheet, and Provincial
Government historical material. Full bibliography, page references, source links,
and validation-sheet identifier/date remain pending; this is explicitly disclosed.

No correct INT-01 audio was present. LISTEN stays visible and disabled with
“Narration pending,” using the inherited shared speaker icon. No Urduja or EXT
audio is assigned. The transcript is ready for the researcher-provided recording.

Null illustration support displays `STATUE PHOTO PENDING`, a Detail View placeholder,
and working lens geometry/sections. This fallback was tested in memory;
the supplied resource still references the real photo.

## Magnifier and Detail View

- Circular visible lens: 76px diameter, muted gold ring, lightly tinted glass,
  short diagonal handle and subtle contrast shadow. The full drawn object is
  approximately 84px across; transparent hit/focus area is 96 × 96 pixels.
- Editable default normalized position: `(0.42, 0.55)`, away from the face and
  on the lower-left statue detail in the supplied composition.
- Original TextureRect remains stationary, aspect-fitted and unscaled.
- Fitted rectangle: `fit = min(view_width/source_width, view_height/source_height)`;
  center the resulting source-sized rectangle in the TextureRect.
- Lens center maps from that rectangle to normalized coordinates, then multiplies
  by native texture dimensions. All inputs call the same normalized-position setter.
- Clamp with a 48-pixel inset from each fitted-photo edge, keeping the entire hit
  area, ring and handle on the actual photo rather than in its letterboxing.
- Crop extent in source texels: `76 / fitted_size * native_size`. AtlasTexture
  uses that region with filter clipping; a 152 × 152 detail texture gives fixed
  **2× visual magnification** without changing the main image.
- Framed Detail View is approximately 168 × 192 pixels including the label/padding.
  It stays inside the viewer's upper corner, on the opposite side of inspection.
- Side hysteresis: lens x > 0.58 moves detail left; x < 0.42 moves detail right;
  otherwise retain its current side. Resizing recomputes the actual fitted image
  and crop while preserving normalized selection, subject to edge clamping.
- No Examine/Done/Reset View/zoom/pan/rotation controls or completion mechanics.

Mouse press starts only on the lens hit area; captured movement/release continues
outside the photo, with clamped results. Native touch retains its pointer index
even if Godot emits a desktop-emulated mouse press first. A second touch cannot
take over the drag. The photo background has no historical click targets; the
lens/handle is its only input control. Sources, close, resize and window focus loss
cancel active dragging. Stale releases cannot continue a canceled drag.

Tab reaches the lens. Arrows move it 18 logical pixels; Shift+Arrow moves 36.
Space/Enter do not activate an inspection mode. Focus uses the shared visible outline.

The `DRAG TO INSPECT` hint appears on each open, holds for 2.5 seconds and fades
over 0.3 seconds. A meaningful drag (>2 pixels), or keyboard inspection, dismisses
it early. It never repeats during a visit; close/reset cancels the hint tween.

## Sections and lifecycle

No on-photo markers, captions or marker hit targets remain. The former shell's
selector row is removed from the tree. Only the two information-panel section
buttons enter the historical navigation focus order; no replacement buttons were added.

`select_section` is authoritative for content/styling. Who Was Limahong? shows both
identity and historical role; Why This Site? shows the approved escape/site connection
with “traditionally associated.” The old marker text is superseded by these existing
full section paragraphs without losing its historical information. The redundant
selected-marker label is gone. Section changes preserve lens/crop/side and narration.
They are immediate and deterministic, with no queued animation callbacks.

Sources preserves section, normalized lens, crop, detail side and narration.
It traps focus and cancels any drag. Escape closes Sources first, then closes the
hotspot; input is handled before navigation notification. Close stops narration,
cancels transient inspection work and emits `close_requested` (plus inherited
`closed`). Reopen restores the resource's defaults, correct crop/right detail side,
fresh hint, closed Sources and stopped narration. No completion signal is added.

## Responsive and input results

Actual native Compatibility-rendered inset previews were tested and screenshots
visually inspected at all three sizes. The preview component occupies 90% of its
parent, proving that it does not assume viewport-global coordinates.

| Window | Inset component | Explorer/info ratio | Result |
| --- | --- | --- | --- |
| 1280 × 720 | 1152 × 648 | about 64% / 36% | Pass: full photo, circular magnifier/handle, detail, both full section paragraphs fit |
| 960 × 540 | 864 × 486 | about 57% / 43% | Pass: two columns, WHO WAS HE?, larger magnifier/detail, readable complete content |
| 854 × 480 | 768.6 × 432 | about 57% / 43% | Pass: enlarged lens and detail stay within viewer, 20px body, full WHO paragraph accessible through existing panel scroll |

The two section controls are at least 48px high. The magnifier has a 96px target.
Main photo preserves aspect ratio. Detail remains in the viewer.
Text can scroll within the
information panel without page scrolling. Screenshots cover default, channel and
left-detail states; relevant examples are `%TEMP%/lch-int-01-854x480-detail-left.png`,
`lch-int-01-960x540-channel.png`, and `lch-int-01-1280x720-default.png`.

Mouse, keyboard and synthetic touch all pass at each size. Touch testing uses
InputEventScreenTouch and InputEventScreenDrag with pointer-index assertions,
continuous pre-release crop checks, second-pointer exclusion and all four photo
boundaries. Mouse tests cover drag/release and non-lens background exclusion.
Keyboard tests cover Tab, all four arrows, Shift movement and button activation.
Handle dragging, removal of old marker targets, rapid selection, Sources focus/Escape, stale pointer handling,
reopen and timed hint dismissal also pass.

## Automated verification

Commands run from repository root with the installed Godot console executable:

```powershell
$godot = 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = Join-Path $env:TEMP 'akar-godot-test'
$env:LOCALAPPDATA = $env:APPDATA
& $godot --headless --path . --editor --import
& $godot --headless --path . --script res://tests/lch_int_01_test.gd
& $godot --path . --script res://tests/lch_int_01_test.gd -- --capture
& $godot --headless --path . --script res://tests/lch_ext_01_test.gd
& $godot --headless --path . --script res://tests/lch_ext_02_test.gd
& $godot --headless --path . --script res://tests/lch_ext_03_test.gd
git diff --check
git diff --cached --check
git status --short
```

- Current revision: headless and native-rendered INT-01 suites each pass
  **594 checks, 0 failures**, exit 0. No project parser/runtime errors.
- Original implementation: native INT-01 passed 767 checks; EXT-01, EXT-02 and
  EXT-03 passed all three sizes with zero failures, exit 0. Editor import passed.
  EXT suites were not rerun for this local revision; their files and dependencies
  remain byte-identical to the revision audit snapshot.
- Git whitespace checks pass; new untracked text files checked separately as well.
- A temporary in-memory silent WAV checks that narration starts only on request,
  survives section/lens/Sources changes without restarting, and stops on close.
  No test audio is saved or assigned to the actual content resource.
- An in-memory 1800 × 900 texture verifies coordinate/aspect independence and
  normalized-position preservation on resize; null texture verifies the fallback.

Environment notes: Godot reports “Failed to read the root certificate store” in
this test environment. Existing EXT-01 and EXT-02 suites also report respectively
2 and 3 ObjectDB instances at shutdown. They still exit 0 with zero assertions
failed; these warnings occur in unchanged suites. INT-01 has no shutdown leak warning.
Browser export and physical touchscreen testing were not performed; the required
touch coverage is synthetic native Godot input. Researcher visual approval is pending.

## Final Git state

The original staged and unstaged entries above remain unchanged. The 13 original
milestone files remain untracked; seven were revised as listed at the top of this
report. All unrelated untracked work and the supplied photograph remain unchanged.
The revision's complete short-status listing is identical before and after editing.
No files were added to the index. `project.godot` retains only its pre-existing
modification. HEAD remains `c73aeb003b3f1f7c786d1d0aab2dd13d47b5a815`.

## Researcher F6 review checklist

1. Open `scenes/landmarks/limahong_channel/interior/lch_int_01_preview.tscn` in Godot,
   press F6, then choose The Limahong Statue. Resize to 1280×720, 960×540 and 854×480.
2. Confirm the photo has no historical markers. Check the default identity plus
   historical-role paragraph, immediately visible circular magnifier/handle and
   corresponding Detail View. Let the hint fade; reopen and drag to dismiss it early.
3. Drag the lens across the statue and all four edges. Check the detail matches the
   selected area, remains on the opposite side, and does not flicker near center.
4. Tab to the lens; test all arrows and Shift+Arrow. Confirm visible focus and bounds.
5. Select Why This Site?, then Who Was He? using mouse and keyboard. Confirm the
   complete approved paragraphs, preserved lens and “traditionally associated” wording.
   At 854×480, scroll the information panel to read the end of the WHO paragraph.
6. Open Sources after inspecting a detail and changing content. Escape closes it
   first and returns to the same state. Verify credit/citation pending notices.
7. Confirm LISTEN is visible but disabled, with the familiar shared speaker icon.
8. Close while dragging, reopen, and confirm WHO/default lens/detail/hint reset.
9. Run `tests/lch_int_01_test.gd` for synthetic touch drag coverage. If a physical
   touch device is available, repeat the lens/handle drag and section checks during review.

Outstanding researcher inputs: photo photographer/source/permissions, complete
citations and validation metadata, final INT-01 narration recording, and F6 approval.
Stop at this milestone; no subsequent hotspot or master-scene work is authorized here.
