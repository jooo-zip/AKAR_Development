# LC-EXT-01 — Meet Lingayen Church

> Current utility/audio behavior is documented in the 2026-10-01 revision below; earlier milestone results are historical.

Phase 5 implementation only. Stop for researcher F6 review. No milestone commit,
push, LC-EXT-02, master layout, navigation integration, completion tracking or
game mechanics are included.

## Content and asset status

The three headings, bodies and takeaways are the researcher-supplied orientation
copy: source-backed project content prepared for historical validation. No visitor
claim of formal validation or approval is displayed. Historical copy is in
`data/landmarks/lingayen_church/lc_ext_01.tres` and can be revised independently.

The original supplied photograph is used unchanged:
`assets/landmarks/lingayen_church/lc_ext_01/images/lc_ext_01_exterior_current.jpg`.
It is a 4080 × 3072 landscape JPEG (85:64, approximately 1.328:1), suitable for
the left-side documentary image. TextureRect aspect-fit shows the complete photo
without stretching or display cropping. Historical Name and Present Role fall
back to the same image. No image was downloaded, generated, copied or edited.
The original `.import` sidecar is also unchanged.

The researcher identifies this image as an original field photograph personally
captured by the AKAR Research Team in 2026. The information column displays
`PHOTO: AKAR Research Team, 2026`. No LC-EXT-01 narration exists locally;
LISTEN uses the inherited `assets/ui/icons/speaker.svg`, is visible and disabled,
and is accompanied by `Narration pending.` No transcript UI or state was added.

Sources uses exactly the source names supplied in the request:

| Section | Source |
| --- | --- |
| About the Church | Archdiocese of Lingayen-Dagupan — Parishes |
| Historical Name | Epiphany of the Lord Parish — historical account |
| Present Role | Archdiocese of Lingayen-Dagupan — Parishes |

Full bibliographic details were not found in the local project materials.
`Full bibliographic details pending researcher input.` is explicit in each Sources
entry; no URL, author, publication date or access date was invented. Image credit
is kept separate from these historical citations. Researcher follow-up: supply
full citations and approved narration when ready.

### Original photograph metadata

| Field | Value |
| --- | --- |
| Asset | `lc_ext_01_exterior_current.jpg` |
| Creator | AKAR Research Team |
| Year | 2026 |
| Source type | Original field photograph |
| Usage | LC-EXT-01 — Meet Lingayen Church |

Attribution is researcher-supplied. The original JPEG and its import sidecar remain
unchanged. This production year is photo metadata, separate from historical copy.

## Files and reuse

Created:

- `scripts/landmarks/lingayen_church/lc_ext_01.gd`
- `scripts/landmarks/lingayen_church/lc_ext_01_content.gd`
- `scripts/landmarks/lingayen_church/lc_ext_01_section.gd`
- `scripts/landmarks/lingayen_church/lc_ext_01_preview.gd`
- `scenes/landmarks/lingayen_church/exterior/lc_ext_01.tscn`
- `scenes/landmarks/lingayen_church/exterior/lc_ext_01_preview.tscn`
- `data/landmarks/lingayen_church/lc_ext_01.tres`
- `tests/lc_ext_01_test.gd`
- `docs/lc_ext_01_testing.md`
- Godot-generated `.gd.uid` sidecars for the new scripts.

Existing files modified: none.

The component inherits `conference_room_interaction.tscn` and
`ConferenceRoomInteraction`, as the Limahong hotspots do. It reuses the shared
heritage theme, selected/focus styles, header/Close, speaker control, audio player,
Sources overlay, focus confinement/restoration, Escape handling and text fade
cancellation. Two small resource extensions add formal-name metadata and the
per-section tab label, takeaway, photograph, caption, credit and source fields to
the existing ConferenceRoomContent/ConferenceRoomConceptEntry model. No universal
framework or shared component edits were needed.

`scripts/core/app_controller.gd` does not exist in this checkout. The current
`scenes/core/app.tscn` is a foundation screen and remains untouched.

## API, input and layout

Embed `lc_ext_01.tscn` under a sized parent Control. Focus the host's opening
control, then call `open_hotspot() -> bool`. `close_hotspot()` closes with a
160 ms fade and emits `hotspot_closed` when finished. `reset_hotspot()` immediately
restores About, closes Sources, stops/resets audio and cancels pending tweens.
The inherited opened/closed signals and interaction API remain available.
The future host should suspend its own background interactions while open.
This component owns no landmark navigation.

`select_section(index, animate = true)` is the single section-update method;
the authoritative state is the inherited `_selected` index. Invalid indices fall
back to About. It updates content, selected tabs, image, caption, source context
and credit together. Opening fades in over 180 ms; section content fades over
160 ms. Rapid selection replaces its previous tween. Reopening during a close
cancels the stale close; completed closes emit once. Parent hide/removal stops
activity. Missing optional images use the main photo; missing captions hide.

The media/content split is 46:54 at all three sizes. Only the information area
scrolls when necessary. Tabs remain outside that scroll; compact labels wrap
without truncation. Close, Sources, LISTEN and tabs are at least 56 logical px
high. All text stays readable at the compact layout; body text is 18 px compact
and 20 px wide. The shared focus outline is separate from the gold selected fill.

Tab/Shift+Tab traverse About → Historical Name → Present Role → reading area →
Sources → Close. Disabled LISTEN is correctly skipped; if approved audio is
assigned later, the inherited focus order includes it before the reading area.
The reading area is focusable to allow keyboard scrolling. Enter/Space activate
buttons. Left/Right only select sections while a tab has focus, with clamped ends.
Sources traps focus in its scroll/Close controls, preserves the selected section,
and restores Sources-button focus on close. Escape closes Sources first, then
the hotspot, consuming input before any close signal.

## Automated validation

Godot version: 4.7.2 stable; Compatibility renderer retained.

- Headless project import: passed. The first sandboxed editor attempt could not
  access Godot's normal cache/settings directories. Re-running with approved
  directory access completed without script/resource errors.
- Standalone component scene launch/parse/load: passed.
- `tests/lc_ext_01_test.gd`: zero failures at 1280 × 720, 960 × 540 and 854 × 480.
- The same harness with Compatibility/OpenGL rendering: zero failures; captures
  generated for every section at all three sizes. Representative wide/compact
  captures inspected for fit and readability. Longer compact text uses local
  scrolling; Sources and tabs remain accessible.
- Existing `tests/lch_ext_01_test.gd`: zero failures at its three inset sizes.
- Exact supplied historical bodies/headings/takeaways and exclusion scan checked.
- `git diff --check`: passed; new text files also checked separately.
- SHA-256 audit: all 11 pre-existing staged/unstaged/untracked files unchanged,
  including project.godot, the photograph and its import sidecar.

The harness dispatches mouse/touch and keyboard events; checks column allocation,
minimum control sizes and containment; exercises source mapping, focus confinement,
Escape hierarchy, direct/rapid switching, invalid indices, close cancellation,
reset, hidden-parent cleanup, missing optional captions and silent narration.
It also verifies that the F6 preview switches to actual window-sized logical
layout and restores the prior canvas policy when removed.

Environment messages: sandboxed runtime tests emit a Windows root-certificate
store error. The rendered run also reports unavailable `user://` shader caching.
Neither caused test failures; no network feature is used. These environment
issues were not hidden by changing unrelated project code.

Run from the project root (substitute your Godot executable):

```powershell
godot --headless --path . --editor --import --quit
godot --headless --path . res://scenes/landmarks/lingayen_church/exterior/lc_ext_01.tscn --quit-after 12
godot --headless --path . --script res://tests/lc_ext_01_test.gd
godot --headless --path . --script res://tests/lch_ext_01_test.gd
git diff --check
git status --short
```

For screenshot checks, omit `--headless` from the new harness command and append
`-- --capture`. Captures are written to Windows TEMP as
`lc_ext_01_<width>_section<index>.png`.

## Exact manual F6 procedure

1. Open `scenes/landmarks/lingayen_church/exterior/lc_ext_01_preview.tscn` in Godot.
2. Press F6. The neutral gray development preview appears with the panel closed.
3. Activate `Meet Lingayen Church` by mouse, touch, or focused Enter/Space.
   Check About first and confirm `PHOTO: AKAR Research Team, 2026` below Sources.
4. Select all three tabs directly, then switch rapidly and close/reopen mid-fade.
5. Open Sources in each section. Verify the correct supplied source name. Press
   Escape once to return to Sources-button focus, and again to close the hotspot.
6. Repeat at 1280 × 720, 960 × 540 and 854 × 480 landscape. Use a separate run
   window for actual client-size resizing if the editor embeds the game view.
   The preview-only script disables fixed reference-canvas scaling for this run,
   so resizing exercises responsive layout. It does not edit project.godot or
   change the embedded component's future host policy.
7. Scroll the information area where needed to read its final takeaway. Check all
   essential controls remain visible and the photo remains undistorted.
8. Complete the checklist below. Physical touchscreen behavior and final Web
   canvas scaling remain researcher/device checks; synthetic input is not a
   substitute for those checks.

F6 on `lc_ext_01.tscn` itself opens the component directly for a quick inspection;
use the preview scene above for repeatable closed/open/reopen and resizing tests.

### General

- [ ] Scene runs independently with F6.
- [ ] Hotspot opens; About is selected by default.
- [ ] Close works; reopening resets correctly.

### Sections

- [ ] About works.
- [ ] Historical Name works.
- [ ] Present Role works.
- [ ] Direct switching works with no prerequisite or completion status.
- [ ] Rapid switching is stable; selected state is obvious.

### Historical safety

- [ ] No 1587 or 1710 appears in the component.
- [ ] No unsupported historical or architectural claims appear.
- [ ] Los Tres Reyes wording matches the supplied content.
- [ ] Present-role wording matches the supplied content.

### Media

- [ ] Photo preserves aspect ratio with no distortion or cropped subject.
- [ ] Caption is readable; `PHOTO: AKAR Research Team, 2026` is visible.
- [ ] LISTEN is visible and disabled; `Narration pending.` is visible.
- [ ] No transcript button or panel exists.

### Sources

- [ ] Sources opens and contains the appropriate section's source.
- [ ] Selected tab is preserved; image credit stays separate.
- [ ] Escape closes Sources before closing the hotspot.
- [ ] Closing Sources restores focus safely.

### Input

- [ ] Mouse click behavior works.
- [ ] Keyboard Tab/Shift+Tab and clamped Left/Right work.
- [ ] Touch targets work on a physical touchscreen.
- [ ] Focus is visible and distinct from selected state.
- [ ] Enter/Space activate focused controls.
- [ ] Escape hierarchy and return-to-trigger focus work.

### Responsive

- [ ] 1280 × 720: two columns, photo left, content right.
- [ ] 960 × 540: readable, all three tabs visible.
- [ ] 854 × 480: two columns and reachable internal reading area.
- [ ] No unacceptable clipping or tiny touch controls.
- [ ] No whole-screen scrolling.

### Reset

- [ ] Reopen returns to About and restores its photo/content.
- [ ] Sources is closed.
- [ ] Audio is stopped with its playback position reset.
- [ ] No stale animations remain after rapid switching/close/reopen.

## Git safety record

Before implementation:

```text
 M AGENTS.md
A  assets/landmarks/urduja_house/icons/summary_visitor_marker.png
A  assets/landmarks/urduja_house/icons/summary_visitor_marker.png.import
A  assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg
A  assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg.import
 M data/landmarks/urduja_house/uh_end_01.tres
 M data/landmarks/urduja_house/uh_int_03.tres
 M data/landmarks/urduja_house/uh_int_04.tres
 M project.godot
?? assets/landmarks/lingayen_church/
```

Final status retains every entry above and adds only these untracked paths:

```text
?? data/landmarks/lingayen_church/
?? docs/lc_ext_01_testing.md
?? scenes/landmarks/lingayen_church/
?? scripts/landmarks/lingayen_church/
?? tests/lc_ext_01_test.gd
?? tests/lc_ext_01_test.gd.uid
```

No staging, commit or push was performed. Stop here for researcher review.

## VISUAL SHELL CONSISTENCY REVISION

Earlier revision record: its photo-background preview and pending-credit status
are superseded by the standalone-preview/credit revision below. The hotspot shell
and interaction changes described here remain in place.

This presentation-only revision aligns LC-EXT-01 with the current Limahong
exterior shell. The three-tab interaction, historical text, section-state methods,
reset/reopen behavior, Sources logic, input handling and animations are unchanged.
The entire historical `.tres`, photo and photo import sidecar are byte-identical
to the revision baseline, verified by SHA-256. No new files were created.

Exact files modified in this revision:

- `scripts/landmarks/lingayen_church/lc_ext_01.gd`
- `scenes/landmarks/lingayen_church/exterior/lc_ext_01.tscn`
- `scenes/landmarks/lingayen_church/exterior/lc_ext_01_preview.tscn`
- `tests/lc_ext_01_test.gd`
- `docs/lc_ext_01_testing.md`

Inspected references: `lch_ext_01.tscn`, `lch_ext_01_preview.tscn`,
`lch_ext_01.gd`, and the shared `conference_room_interaction.tscn`/script.
Shared source code and Limahong files were not modified.

Presentation changes:

- The preview uses Limahong's outer gray `Color(0.16, 0.18, 0.2, 1)` and
  5% inset on each edge. The inner heritage surface retains its dark green
  background with Limahong's square 2 px border, color `(0.46, 0.40, 0.25, 1)`.
  Sources receives the same frame. While open, the preview's contextual photo and
  trigger hide so only gray appears around the panel; both return on close.
- LISTEN is in the top-right header beside the inherited `Close` control.
  Its disabled background, border, font/icon colors, 24 px speaker icon,
  18 px button text and minimum 136 × 56 footprint match Limahong.
  `Narration pending.` is grouped immediately beneath it. Close uses 80 × 56
  minimum size and the shared styles. No audio control remains in the footer.
- Sources uses its original shared information-column placement and theme,
  spans that column beneath the reading area, and is 56 px high. Image credit
  sits below it in secondary 14 px text. The empty footer row is hidden.
- Tabs retain the shared dark normal fill, muted-gold selected fill, 1/2 px
  normal/selected borders and distinct 3 px focus outline. They are 56 px high,
  with 18 px wide / 16 px compact labels. All three stay in one row.
- Title is 30/24 px wide/compact; subtitle is secondary 18 px; heading 24/20 px;
  body 20/18 px; takeaway 18 px with subdued color. Gold accents its label rather
  than the full takeaway paragraph. Margins use Limahong's 16/8 px, column gaps
  24/12 px, and layout/information gaps 8/4 px wide/compact.
- Photo presentation remains full aspect-fit with no crop or distortion.
  The 46:54 media/information relationship and exact caption are preserved.

Focus remains About → Historical Name → Present Role → reading area → Sources →
Close; the additional reading-area stop preserves keyboard access to scrolled
copy. Disabled LISTEN is skipped. Sources focus confinement and Escape hierarchy
remain inherited. No transcript, navigation or later hotspot work was added.

Validation results:

| Check | Result |
| --- | --- |
| Godot 4.7.2 headless import | Passed |
| Standalone component scene load | Passed |
| Headless LC-EXT-01, all three sizes | Zero failures |
| Compatibility/OpenGL rendered LC-EXT-01, all three sizes | Zero failures |
| Existing LCH-EXT-01 regression, all three sizes | Zero failures |
| Git and modified-file whitespace checks | Passed |
| Historical resource and original photo hashes | Unchanged |
| Repository file-hash comparison | Only the five listed files changed |

The existing behavior checks remain; additional assertions cover gray outer
margin, 5% inset, heritage border, header control placement/non-overlap,
pending status below LISTEN, full-width Sources below the scroll, credit below
Sources, secondary typography, 56 px controls and preview restoration on close.
Rendered screenshots for every section were generated at 1280 × 720, 960 × 540
and 854 × 480; representative screenshots at each size were inspected. Longer
compact content still scrolls internally; controls stay outside that scroll.

The existing certificate-store and unavailable `user://` shader-cache messages
remain non-failing environment issues in sandboxed runtime/rendered checks.
The unchanged Limahong regression harness also reported two ObjectDB instances
leaked at exit after printing zero failures; no Limahong code was altered.
Import completed with normal editor-cache access. No unrelated workaround was
added. Narration, full bibliography, image credit/rights and physical-device
review remain pending as before.

Researcher visual checklist (manual approval remains pending):

- [ ] Gray outer AKAR viewport matches established shell.
- [ ] Inner panel has shared heritage border treatment.
- [ ] Title/subtitle hierarchy matches Limahong standard.
- [ ] LISTEN moved to top-right header.
- [ ] Close uses shared Limahong-style control.
- [ ] Narration pending appears with LISTEN.
- [ ] No LISTEN control remains in footer.
- [ ] Sources matches shared visual treatment.
- [ ] Tabs use shared AKAR button styling.
- [ ] Keyboard focus differs from selected state.
- [ ] Body typography is consistent with AKAR hierarchy.
- [ ] Takeaway is visually secondary to main content.
- [ ] Photograph remains undistorted.
- [ ] Image credit remains visible.
- [ ] No historical content changed.
- [ ] No transcript added.
- [ ] Responsive checks pass at all three sizes.

Exact F6 review: open
`scenes/landmarks/lingayen_church/exterior/lc_ext_01_preview.tscn`, press F6 and
activate OPEN. Inspect the gray surround and bordered panel, header LISTEN/Close,
all three tabs, full-width Sources and image credit at 1280 × 720, 960 × 540
and 854 × 480. Use a separate run window if needed to resize the client area;
the existing preview-only canvas sizing remains unchanged. Scroll the longer
compact sections to their takeaway. Tab through controls; open Sources and press
Escape twice; reopen and confirm About plus the preview photo/trigger lifecycle.
Rapidly switch tabs and close/reopen during a fade. Check physical touch when
available. The earlier full interaction checklist remains applicable.

Before and after this revision, `git status --short` is identical because all
five revised files were already untracked. Staged: four Urduja image/import files.
Unstaged: AGENTS.md, three Urduja `.tres` files and project.godot. Untracked:
the existing LC-EXT-01 assets/data/scenes/scripts, testing document and test/UID.

```text
 M AGENTS.md
A  assets/landmarks/urduja_house/icons/summary_visitor_marker.png
A  assets/landmarks/urduja_house/icons/summary_visitor_marker.png.import
A  assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg
A  assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg.import
 M data/landmarks/urduja_house/uh_end_01.tres
 M data/landmarks/urduja_house/uh_int_03.tres
 M data/landmarks/urduja_house/uh_int_04.tres
 M project.godot
?? assets/landmarks/lingayen_church/
?? data/landmarks/lingayen_church/
?? docs/lc_ext_01_testing.md
?? scenes/landmarks/lingayen_church/
?? scripts/landmarks/lingayen_church/
?? tests/lc_ext_01_test.gd
?? tests/lc_ext_01_test.gd.uid
```

No staging, commit or push. Stop for researcher F6 review; do not start LC-EXT-02.

## STANDALONE PREVIEW CONSISTENCY

This final revision changes only the F6 wrapper, its test coverage/documentation,
and the resource's `image_credit` field. It does not change the component scene,
component/preview scripts, historical copy, historical sources, photograph, fit
mode, three-tab interaction, Sources, LISTEN, Close or animation behavior.

Reference inspected:
`scenes/landmarks/limahong_channel/exterior/lch_ext_01_preview.tscn`.
LC now uses the same dark gray background, full-size MarginContainer with 24 px
side margins, vertically centered VBox with 24 px separation, centered 28 px title,
22 px three-line development note and centered 480 × 64 minimum launcher.
The existing 5% inset parent frame and standalone canvas-sizing script are retained.
The same default preview button styling is used, without a new theme or component.

The exact preview text is:

```text
Meet Lingayen Church

DEVELOPMENT PREVIEW · LC-EXT-01
Explore the church's identity, historical name and present-day role
Inset parent frame · No master landmark integration

[ Meet Lingayen Church ]
```

The photograph TextureRect/resource reference was removed from the wrapper only.
The launcher still directly calls `open_hotspot()`. The preview's centered content
hides while the hotspot is open and returns when it closes; focus returns to the
launcher. The church photograph remains inside the hotspot in every section.

Exact modified files (no files created):

- `scenes/landmarks/lingayen_church/exterior/lc_ext_01_preview.tscn`
- `data/landmarks/lingayen_church/lc_ext_01.tres` — `image_credit` only
- `tests/lc_ext_01_test.gd`
- `docs/lc_ext_01_testing.md`

Automated and rendered results:

| Check | Result |
| --- | --- |
| Godot 4.7.2 project import | Passed |
| Standalone preview scene load | Passed |
| Standalone component scene load | Passed |
| Preview and hotspot headless checks, all three sizes | Zero failures |
| Preview and hotspot Compatibility/OpenGL checks, all three sizes | Zero failures |
| Existing Limahong LCH-EXT-01 regression | Zero failures |
| Git diff and modified-file whitespace checks | Passed |
| Original photo/import hash verification | Unchanged |
| Historical resource comparison | Only photo-credit field changed |

The neutral preview was captured and visually inspected at 1280 × 720,
960 × 540 and 854 × 480: centered readable content, large launcher, no overlap,
clipping or scrolling. Existing opened-hotspot checks/captures also pass at all
three sizes; the new credit stays on one line without changing the layout.
The test launches through mouse at 1280, synthetic touch at 960, and Enter at 854.
Existing keyboard, tabs, Sources/Escape, rapid-switching and reset checks remain.
Preview captures are saved to TEMP as `lc_ext_01_<width>_preview.png` alongside
the existing per-section captures when the harness runs with `-- --capture`.

The sandboxed runtime/rendered runs still report the Windows certificate-store
and unavailable shader-cache messages without test failures. No unrelated fixes
were made. This Limahong regression run did not report the earlier ObjectDB leak.
Full historical citations and narration remain pending; photo credit is resolved.

Manual researcher checklist:

- [ ] Preview matches Limahong development-preview structure.
- [ ] Neutral gray preview background.
- [ ] No church-photo preview background.
- [ ] Meet Lingayen Church title visible.
- [ ] DEVELOPMENT PREVIEW · LC-EXT-01 visible.
- [ ] Description visible.
- [ ] No master landmark integration note visible.
- [ ] Launcher button says Meet Lingayen Church.
- [ ] Launcher opens existing hotspot.
- [ ] Preview responsive at 1280 × 720.
- [ ] Preview responsive at 960 × 540.
- [ ] Preview responsive at 854 × 480.

### PHOTO CREDIT

- [ ] Visitor-facing credit says PHOTO: AKAR Research Team, 2026.
- [ ] Original image file remains unchanged.
- [ ] No invented image attribution.

### REGRESSION

- [ ] Three tabs unchanged.
- [ ] Sources unchanged.
- [ ] LISTEN remains disabled.
- [ ] Narration pending remains.
- [ ] No transcript.
- [ ] Historical content unchanged.
- [ ] Reset/reopen unchanged.

F6 review: open `scenes/landmarks/lingayen_church/exterior/lc_ext_01_preview.tscn`
and press F6. Inspect the neutral closed preview at the three target sizes, then
activate `Meet Lingayen Church`. Confirm the photo is inside the hotspot and the
credit reads `PHOTO: AKAR Research Team, 2026` for all tabs. Open Sources, press
Escape twice and confirm the neutral preview/launcher return. Reopen and verify
About plus the existing reset behavior. Use a separate run window for resizing
if needed; no project-setting changes are required.

Git before and after this revision: identical to the complete short-status block
in the preceding revision record (four staged Urduja asset/import files, five
unstaged files, and existing untracked LC-EXT-01 paths). All revised files were
already untracked. File-hash comparison identifies only the four listed files
as changed; unrelated work and the hotspot's scene/scripts remain untouched.
No staging, commit or push. Stop for researcher review; no LC-EXT-02 work.


## 2026-10-01 — Casa Real utility header and narration revision

**Narration is activated with researcher approval.** The identical temporary
recordings are intentional and are not a defect or activation blocker.

Current narration assets are intentionally temporary and may contain the
same recording. Each hotspot already uses its permanent hotspot-specific
audio path so that final narration can later be substituted by replacing the
corresponding .ogg file without changing code or resource mappings.

### Actual audio audit

- Hotspot: **LC-EXT-01**
- Existing file: `res://assets/landmarks/lingayen_church/audio/lc_ext_01_narration.ogg`
- Size: 288,586 bytes; Godot type: AudioStreamOggVorbis; duration: 21.0 seconds.
- Existing `.ogg.import` metadata is present; loop is false.
- SHA-256: `5E44ADB87270F4DC7586CF026902718C597544C394376FC0FDEFE1E38FA4BD44`.
- Assigned resource slot: `narration_stream (inherited from ConferenceRoomContent)` in `data/landmarks/lingayen_church/lc_ext_01.tres`.
- Delivered LISTEN: visible and enabled; “Narration pending.” is hidden.
- Playback through the saved resource mapping: passed start, advancing
  playback position, pause/resume, actual completion, close and stopped reopen.
- No autoplay. No new player. No audio conversion, generation, copy, rename or move.
- Nonzero decoded PCM was verified. Human audibility/content listening remains
  researcher review; this agent's tools do not support hearing the audio.

### Exact UI reference and reuse

Reference: `scenes/landmarks/casa_real/end/cr_end_01.tscn` and
`scripts/landmarks/casa_real/cr_end_01.gd`, with CR-EXT-01/CR-INT-03 inspected for
comparison. No Casa Real-only reusable toolbar exists. The actual reusable
`scenes/components/conference_room_interaction.tscn` Theme/StyleBoxes are inherited
unchanged, rather than copying colors from screenshots. The Church-only adapter
is `scripts/landmarks/lingayen_church/lc_header_utilities.gd`; Casa Real, Limahong
and the shared shell were not edited.

Header actions are one HBox: **SOURCES → speaker + LISTEN → CLOSE**. The existing
buttons retain their signals. Target height is CR-END-01's 52 px; fonts are
18 px wide / 16 px compact; icon is the same 22 px
`res://assets/ui/icons/speaker.svg`. Normal, hover, pressed, hover-pressed, focus
and disabled StyleBoxes are the same shared resources as the actual Casa Real
instance. A calculated minimum width preserves the icon beside LISTEN/PAUSE/RESUME.
There is exactly one Sources control. Sources stays at the top at every size.

The existing Sources button was reparented out of the interpretation VBox. Its 56 px row and following separation no longer consume reading space. The photo credit remains under the reading area.

### Behavior and validation

Casa Real CR-END-01 playback semantics are used: LISTEN starts at zero; PAUSE
holds position; RESUME continues; natural completion returns to LISTEN. Sources
preserves selection and ongoing narration, and traps focus. Overall hotspot
narration continues across educational selections; reset/close/hide/removal stop
it. Opening/playing another Church hotspot prevents overlapping narration.
Missing/null audio retains a disabled button and collapsible pending label.

The utility focus order is Sources → Listen → Close, skipping unavailable audio.
Mouse, Enter/Space, Tab/Escape and synthetic-touch checks passed. Existing
educational selection, sources wording, media, credits and close signals remain.
At 1280×720, 960×540 and 854×480, utilities remain grouped/unclipped and the old
Sources footprint is removed. Existing internal scrolling remains available;
no whole-screen scroll or new interaction was introduced.

The shared revision suite verifies the saved permanent audio mapping before
playback, without injecting the stream. A separate null-stream check exercises
the safe missing-audio fallback, then restores the supplied stream in memory. See [revision audit](lingayen_church_shared_header_narration_revision.md)
for final test totals, all six mappings, Git boundaries, environment warnings and
before/after captures. Earlier disabled-only/per-person/per-milestone audio test
expectations have been updated for the one-stream-per-hotspot contract.

### F6 review for this revision

Open this hotspot's existing preview scene and press F6. Open the actual hotspot,
then inspect the top SOURCES/LISTEN/CLOSE row and the former Sources position.
Check that no blank utility-sized hole remains, credits retain their placement,
and the educational interaction is unchanged. Repeat at 960×540 and 854×480.
Sources must preserve selection and Escape must close Sources first. LISTEN is enabled and the pending label is absent. Listen to the beginning;
verify audibility, pause, resume, completion, immediate stop on Close and stopped
reopen. The shared temporary recording is approved; final narration replacement
only requires replacing the matching .ogg at its existing path and normal Godot
reimport. No code, scene, player or resource-mapping edits are needed.

### Authorized temporary narration activation — 2026-10-01

Retested the saved resource mapping at 1280×720, 960×540 and 854×480.
LISTEN enabled, pending label hidden, correct path, no autoplay, start/pause/
resume, completion, immediate Close stop, stopped reopen, replay from zero,
Sources state preservation and cross-hotspot non-overlap all pass. Mouse,
keyboard and synthetic touch pass; the Casa Real header remains unchanged.

Shared activation suite: **1,887 headless checks and 1,923 rendered checks,
0 failures**. All six existing educational regression suites pass. Final logs:
`C:\Users\Admin\AppData\Local\Temp\akar_lc_activation_<id>.log`;
rendered log: `akar_lc_activation_render.log`. Saved-resource screenshots are
`lc_header_after_<id>_<width>.png` in the same directory; these now show enabled
LISTEN. Human audio review is the next F6 step, not a prerequisite to activation.


## 2026-10-02 — LC_EXT_01 editor-visibility pilot

### Root cause and scope

The production scene already assigns `lc_ext_01.tres`. The previous controller
built/reparented the Church presentation in runtime `_ready()` and populated
historical fields on open/render; neither ran in the 2D editor. The preview
scene only supplies its launch button, inset parent and F6 sizing policy.

Only LC_EXT_01 gains editor execution. No production/preview scene, `.tres`,
image, audio, resource schema, base controller or project setting was changed.
Historical content remains authoritative in the original content resource.

### Implementation and exact files

- `scripts/landmarks/lingayen_church/lc_ext_01.gd`: the sole production `@tool`
  annotation. Separates `_ensure_presentation()`, `_apply_presentation(index)`,
  `_resize_layout()` and `_initialize_runtime()`. Editor refresh uses ABOUT and
  the same presentation/layout code without invoking runtime open/reset/render.
- `scripts/landmarks/lingayen_church/lc_header_utilities.gd`: extracts static
  `build_presentation()` and `resize_presentation()` from the existing constructor
  and resize method. Runtime constructor/signals/audio/focus retain their behavior.
  This avoids marking the helper `@tool` or copying its styling into another implementation.
- `tests/lc_ext_01_editor_test.gd` and its `.uid`: editor-specific verification.
- `tests/lc_ext_01_editor_test.tscn`: a normal editor test fixture, not a plugin
  and not a replacement for the production or F6 preview scene.
- `docs/lc_ext_01_testing.md`: this audit, evidence and review procedure.

Actual editor-mode probes confirmed the existing four resource-schema scripts
and `conference_room_interaction.gd` work without changes or `@tool` annotations.
The static helper functions are callable in editor mode without constructing
its runtime RefCounted instance. No custom editor plugin was introduced.

### Editor representation and isolation

The production root receives one temporary `_LC_EXT_01_EditorPresentation`
branch. It is instantiated from the existing shared shell; its runtime script
and audio player are removed before presentation setup. It retains the exact
production panel StyleBox references and builds the existing Church layout.

All generated descendants have no scene owner. Authored nodes are never hidden,
reparented or edited by the editor path; the temporary presentation draws over
the authored empty shell. Thus generated structure and displayed historical
text cannot become unintended saved scene overrides. Runtime still uses the
original nodes and adds no editor presentation branch.

Refresh removes only the old temporary branch, rebuilds it once and reconnects
resize only when needed. It handles the existing branch by name after script
reload, rather than depending solely on member references. Generated Controls,
including internal scrollbars, ignore input and have no keyboard focus.

No editor path opens/closes the hotspot, changes narration state, assigns an
audio stream to the authored player, emits visitor signals, registers narration
groups, grabs focus, creates tweens/timers or changes project settings.
Idle LISTEN availability is displayed directly from the content resource.

An Inspector **Refresh Editor Preview** button is available on the production
root. Use it after editing nested resource properties or reloading scripts.
Continuous nested-resource change tracking is deliberately outside this pilot.
The component uses its editor dimensions; an unsized root previews at 1280×720.
The fallback only sizes the temporary branch and does not impose a runtime minimum.

### Shared-file consumers

All known runtime consumers of the changed header helper are LC-EXT-01,
LC-EXT-02, LC-EXT-03, LC-INT-01, LC-INT-02 and LC-END-01. No other landmark uses
this Church helper. Its constructor remains backward compatible. The shared
conference-room base and its other landmark consumers are unchanged.

### Verification procedure

Run the fixture only in a disposable test editor process with the explicit
`--lc-editor-test` flag. Without that flag the fixture is inert, so merely opening
it cannot execute the suite or close the editor.

```powershell
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --editor --rendering-method gl_compatibility --path . res://tests/lc_ext_01_editor_test.tscn -- --lc-editor-test --capture
```

The suite checks resource-driven ABOUT content, caption/credit/image and header;
all three dimensions; repeated refresh; one resize connection; no focus/audio/
visitor signals/runtime state; controller script reload; three fresh scene
instances; and packed scene equality before/after refresh and reload. It saves
a roundtrip scene only to TEMP and verifies the generated branch is absent.
It also opens the actual production scene through EditorInterface and checks
that the 2D editor displays the presentation without F6.

### Researcher visual review

1. Open `scenes/landmarks/lingayen_church/exterior/lc_ext_01.tscn` in Godot 4.7.2.
   Switch to **2D**; do not press F6. Frame/zoom the component to view its full area.
2. Confirm the title, formal name, photograph, three tabs with ABOUT selected,
   heading, body, KEY TAKEAWAY, takeaway, caption, credit and header utilities.
3. Select the production root and use **Refresh Editor Preview** repeatedly.
   Close/reopen the scene and reload the controller. The view must remain complete.
4. Inspect temporary component dimensions at 1280×720, 960×540 and 854×480;
   do not save review-only size changes. Generated nodes must not appear in saved
   production scene data.
5. Run the unchanged `lc_ext_01_preview.tscn` with F6. Exercise all three sections,
   mouse/keyboard/touch, Sources/Escape, LISTEN/PAUSE/RESUME, Close and reopening.
   Run the production scene directly with F6 as well. Its full-parent size differs
   from the preview's 5% inset; compare at equal component sizes.

The approach is suitable for evaluating the remaining hotspots after visual
approval, but is not a blanket rollout: each controller's generated layout and
runtime side effects must be separated and checked individually. No propagation,
staging, commit or push is included in this pilot.
