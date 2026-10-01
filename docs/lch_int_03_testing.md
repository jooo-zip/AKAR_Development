# LCH-INT-03 — From Escape Route to Heritage Destination

## Sources overlay finalized - 2026-10-01

This Sources-only revision supersedes older pending-reference/portrait-provenance
notes below. The header and narration assignments from the prior revision remain
unchanged. Visitor layout is **SOURCES**, **HISTORICAL REFERENCES**, then
**MEDIA CREDITS**, with fixed title/Close and an internally scrolling text region.
The Label-based overlay has no clickable-link support. Canonical historical URLs
are retained in the content Resource's `historical_source_urls` metadata; INT-02
portrait webpage URLs use each person Resource's `source_url` metadata.

### Historical References and canonical URLs

Austria, H. (2018).
Limahong Channel Tourism Center to Be Built This Year.
Philippine News Agency.
Canonical URL: https://www.pna.gov.ph/articles/1029395

Austria, H. (2019).
Limahong Channel Tourism Center in Pangasinan Groundbreaks.
Philippine News Agency.
Canonical URL: https://www.pna.gov.ph/articles/1071673

Municipality of Lingayen. (2020).
Limahong Channel Tourism Center Soon to Be Operational.
Canonical URL: https://www.lingayen.gov.ph/limahong-channel-tourism-center-soon-to-be-operational/

Municipality of Lingayen. (2025).
Bidding Documents for the Construction of a Multi-Purpose Building in the Limahong Tourism Center, Barangay Pangapisan North, Lingayen, Pangasinan.
Canonical URL: https://www.lingayen.gov.ph/wp-content/uploads/INVITATION-TO-BID-_CONSTRUCTION-OF-MULTI-PURPOSE-BUILDING-SENIOR-CITIZEN-BUILDING-IN-LIMAHONG-TOURSIM-CENTER-BARANGAY-PANGAPISAN-NORTH.pdf

Pasiliao, J. J. (2020).
Limahong Channel Hub to Boost Tourism, Jobs in Pangasinan Town.
Philippine News Agency.
Canonical URL: https://www.pna.gov.ph/articles/1091355

### Media Credits and provenance

Credits and known metadata are listed below. PNA and Municipality of Lingayen reuse permissions remain pending. The present-site image is research-team captured and authorized for AKAR use; its individual photographer remains pending. Its embedded EXIF capture timestamp is recorded in the media metadata, with no timezone supplied.

2019 GROUNDBREAKING: Liwayway Yparraguirre / Philippine News Agency.
Photographer: Liwayway Yparraguirre. Article author: Hilda Austria.
Date: June 2019. Source: Philippine News Agency.

LEOPOLDO N. BATAOIL: Municipality of Lingayen.
Source: Municipality of Lingayen official website.
Page context: Official page identifying Hon. Leopoldo Bataoil.

PRESENT-SITE PHOTO: AKAR research team.
Source: AKAR research team.
Date: 2026-07-18 11:44:09 (embedded EXIF DateTimeOriginal; timezone unspecified).
Permission/reuse: Research-team captured / authorized for AKAR use.

All existing media fields and their source_text() output are preserved verbatim,
including known locations, event/type metadata and existing pending fields.
External reuse permissions are not inferred from citation. Individual project
photographer attribution remains unspecified as before.

Citations identify supporting information or image provenance; they do not by
themselves establish ownership, license or permission. Only the researcher-supplied
AKAR-created/captured media is credited to the project. No new author, photographer,
license, permission, publisher or ownership was inferred. The internal validation
sheet is not listed as a visitor-facing historical reference.

### Sources verification

Sources passes at 1280x720, 960x540 and 854x480: bounded overlay, wrapped titles,
20 px compact / 22 px wide text, fixed reachable 48 px Close control, no horizontal
scrolling, internal mouse-wheel / synthetic-touch swipe / keyboard scrolling.
Tab stays within Sources; Home/PageDown/End work. Escape closes Sources first and
returns focus to its header button. Each selected hotspot state survives the round
trip; audio continues without changing stream or restarting. Source opening starts
at the historical references. Existing content, interactions and narration remain
unchanged. See [the complete Sources report](lch_sources_testing.md) for regression
totals, the full file inventory, repository preservation checks and F6 instructions.

Manual F6: open this hotspot's existing preview at all three target sizes, select a
non-default state, start Listen, open Sources, read/scroll to Media Credits, then
close with Escape or Close Sources. Check state/audio continuity and the unchanged
SOURCES / LISTEN / CLOSE header. No commit or push; researcher visual review pending.


## LIMAHONG SHARED HEADER STANDARD - 2026-09-30

LIMAHONG GLOBAL HEADER: title/context on the left; **SOURCES | LISTEN | CLOSE**
on the right. The shared speaker remains `res://assets/ui/icons/speaker.svg`.
All controls have matching heritage styling and 56 px (wide) / 48 px (compact)
heights. Narration status sits beneath HeaderActions with reserved geometry.

Current LCH-INT-03 narration is assigned through
`data/landmarks/limahong_channel/lch_int_03.tres` to
`res://assets/landmarks/limahong_channel/audio/lch_int_03_narration.ogg`.
**LISTEN is enabled and Narration pending is hidden.** Earlier pending-audio
notes in this document describe the previous milestone state. Generic null-audio
fallback remains tested: visible disabled LISTEN and right-aligned Narration pending.

The seven currently supplied Limahong narration files have identical binary
content. The researcher explicitly authorized their temporary use for their
respective hotspots. Replace the corresponding files later if distinct final
recordings are produced; each hotspot retains its own matching resource path.
No audio was copied, renamed, moved, or recreated during this revision.

The existing hotspot regression suite passes at 1280x720, 960x540, and 854x480.
The cross-hotspot `tests/lch_header_test.gd` covers layout, assigned OGG playback,
no autoplay, repeated Listen activation, state changes, Sources preservation,
mouse/keyboard/synthetic touch, Escape, close/reopen, and null-audio fallback.
Historical wording, sources, transcripts, media and content interactions are unchanged.

See [the complete header report](lch_header_testing.md) for all seven mappings,
file inventory, verification results, preserved Git state, and F6 review instructions.
F6 review: open this hotspot's existing preview, confirm SOURCES / LISTEN / CLOSE
at all three sizes, play narration, change content, open Sources, press Escape
twice, then reopen. Expect preserved state through Sources and stopped audio
after close/reopen. No commit or push; stop for researcher visual review.


Implemented 2026-09-24 in Godot 4.7.2, Compatibility renderer, GDScript only.
Status: implementation and automated checks complete; awaiting researcher F6/manual visual review.

## Targeted Stage 03 visual revision — 2026-09-24

The right information panel now groups the stage title, body, WHY IT MATTERS
and qualification at the top. Stage 03's short body ScrollContainer uses
content height with vertical expansion disabled; the qualification stays outside
the scroll area immediately below it. Stages 01/02 retain their original expanding
information scroll. There are no new interactions or structural stage changes.

The present-site photograph has a larger display height, preserving its original
4:3 aspect ratio and full image with centered fit/linear filtering. The caption
remains PRESENT-SITE CONTEXT · AKAR research team. The facility grid keeps its
existing 3/2-column arrangement, card sizes and internal scrolling; all nine
cards are individually reachable in full, including their ORIGINAL PLAN labels.

| Viewport | Previous photo display | Revised photo display | Body → WHY IT MATTERS gap | Result |
| --- | --- | --- | --- | --- |
| 1280 × 720 | approximately 170.7 × 128 px | 240 × 180 px | 10 px | PASS |
| 960 × 540 | approximately 101.3 × 76 px | approximately 149.3 × 112 px | 6 px | PASS |
| 854 × 480 | approximately 101.3 × 76 px | approximately 133.3 × 100 px | 6 px | PASS |

Photo display heights increase by approximately 41%, 47% and 32%, respectively.
The enlarged image occupies less than 40% of the visual-board height. The
qualification remains fully visible, and the facility area retains at least
one complete card row. Partial rows are clipped only by the intended grid
scroll viewport; scrolling reveals each complete card. No text overlaps.

No historical wording was refined: the existing body already states phased
development and the qualification explicitly distinguishes original plans from
completed facilities. All nine statuses remain ORIGINAL PLAN. No photo is
treated as evidence of completion. The content Resource and media are unchanged.

This revision modifies exactly these existing INT-03 files, creating none:

```text
scripts/landmarks/limahong_channel/lch_int_03.gd
tests/lch_int_03_test.gd
docs/lch_int_03_testing.md
```

Fresh pre-revision audit: **4 staged, 15 unstaged, 36 untracked files** (320
tracked/nonignored untracked file hashes). Baseline status, index entries, HEAD,
file hashes and the three original files are recorded in
`%TEMP%/akar-int03-stage03-revision-20260924-091958/`. After revision, Git status
has the same counts and paths, since these INT-03 files were already untracked.
Only the three intended file hashes differ; the other **317 files**, including
`project.godot`, other hotspots and all supplied images/import files, remain
byte-identical. The staged index and HEAD are unchanged. No staging, commit,
amendment or push occurred.

Revised native Compatibility suite: **1,859 checks, 0 failures**, exit 0.
All three rendered sizes were inspected. Tests now measure compact body/WHY
spacing, at least 30% larger photo display height, preserved aspect ratio,
photo/grid balance, visible qualification, each complete reachable facility
card, and restoration of the original Stage 01/02 scrolling behavior. Existing
mouse, keyboard, synthetic touch, Sources preservation, Escape hierarchy, rapid
switching, narration and close/reopen tests also pass. Removed-feature absence
checks still pass. No parser/runtime errors or leak warnings; the known sandbox
certificate-store startup message and intentional missing-image warnings remain.

The revision test log is `%TEMP%/lch-int03-stage03-revision-test.log`; captures
use the existing `%TEMP%/lch-int-03-{width}x{height}-{state}.png` paths. Whitespace
checks pass for tracked/staged changes and the three revised untracked files.
Other-hotspot regression results below are from the initial implementation;
their files were verified unchanged in this targeted revision.

F6 review: open the existing INT-03 preview, choose DEVELOPMENT, and review the
larger contextual photo and compact right-panel text stack. Scroll the facility
grid through all nine cards, open/close Sources, then close and reopen. Review
the three target-size captures for layout. Browser/physical-touchscreen review
and researcher approval remain pending. No other hotspot or master scene work
was undertaken. Stop here for researcher visual review.

## Educational objective and scope

Present the channel's modern heritage context through the 2019 groundbreaking,
historical memory/education/tourism interpretation, and the original development
plan. Distinguish planned facilities from confirmed completion. This supports
the existing museum walkthrough and acceptability scope; it does not claim a
measured improvement in learning effectiveness. No game mechanics, progress
tracking, accounts, CMS, or analytics were added.

Only INT-03 was implemented. END-01, ENT-01 and the Limahong master scene were not
started. Earlier hotspots and shared components were inspected but not edited.
No commit, amendment, push, staging, unstaging, reset or restore was performed.

## Initial implementation audit and preservation

The fresh pre-edit `git status --short` inventory contained **4 staged files,
15 unstaged files and 20 untracked files**. The existing three INT-03 images and
their `.import` files account for six of those untracked files.

Baseline records (status, index entries, HEAD and SHA-256 hashes) were saved in
`%TEMP%/akar-int03-audit-20260924-065700/`. All **304** pre-existing tracked and
nonignored untracked files remain byte-identical, including `project.godot`,
AGENTS.md, the supplied images/import metadata, previous Limahong hotspots and
Urduja work. `git ls-files --stage` is unchanged. HEAD remains
`0dd7c6782d50df4f8d60687eb56f985d2b9764b9`.

Pre-existing staged files:

```text
assets/landmarks/urduja_house/icons/summary_visitor_marker.png
assets/landmarks/urduja_house/icons/summary_visitor_marker.png.import
assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg
assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg.import
```

Pre-existing unstaged files:

```text
AGENTS.md
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png.import
data/landmarks/limahong_channel/lch_ext_01.tres
data/landmarks/limahong_channel/lch_ext_01_locator_channel.tres
data/landmarks/limahong_channel/lch_ext_01_locator_lingayen.tres
data/landmarks/limahong_channel/lch_ext_01_locator_pangapisan.tres
data/landmarks/urduja_house/uh_end_01.tres
data/landmarks/urduja_house/uh_int_03.tres
data/landmarks/urduja_house/uh_int_04.tres
docs/lch_ext_01_testing.md
project.godot
scenes/landmarks/limahong_channel/exterior/lch_ext_01.tscn
scripts/landmarks/limahong_channel/lch_ext_01.gd
tests/lch_ext_01_test.gd
```

Pre-existing untracked files:

```text
assets/landmarks/limahong_channel/lch_ext_01/audio/lch_ext_01_narration.ogg
assets/landmarks/limahong_channel/lch_ext_01/audio/lch_ext_01_narration.ogg.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_location_marker.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_location_marker.png.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_movement_vessel.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_movement_vessel.png.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_route_ship.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_route_ship.png.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_settlement_icon.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_settlement_icon.png.import
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_marker.png
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_marker.png.import
assets/landmarks/limahong_channel/lch_ext_01/maps/lch_ext_02_regional_map.png
assets/landmarks/limahong_channel/lch_ext_01/maps/lch_ext_02_regional_map.png.import
assets/landmarks/limahong_channel/lch_int_03/people/lch_int_03_bataoil.png
assets/landmarks/limahong_channel/lch_int_03/people/lch_int_03_bataoil.png.import
assets/landmarks/limahong_channel/lch_int_03/photos/lch_int_03_2019_groundbreaking.jpg
assets/landmarks/limahong_channel/lch_int_03/photos/lch_int_03_2019_groundbreaking.jpg.import
assets/landmarks/limahong_channel/lch_int_03/photos/lch_int_03_present_site.jpg
assets/landmarks/limahong_channel/lch_int_03/photos/lch_int_03_present_site.jpg.import
```

Final status: **4 staged, 15 unstaged, 36 untracked files**. The increase is
exactly the 16 new INT-03 files below. No existing file was modified.

## Complete INT-03 file inventory

Created files (16, including Godot-generated script UIDs):

```text
data/landmarks/limahong_channel/lch_int_03.tres
docs/lch_int_03_testing.md
scenes/landmarks/limahong_channel/interior/lch_int_03.tscn
scenes/landmarks/limahong_channel/interior/lch_int_03_preview.tscn
scripts/landmarks/limahong_channel/lch_int_03.gd
scripts/landmarks/limahong_channel/lch_int_03.gd.uid
scripts/landmarks/limahong_channel/lch_int_03_content.gd
scripts/landmarks/limahong_channel/lch_int_03_content.gd.uid
scripts/landmarks/limahong_channel/lch_int_03_facility.gd
scripts/landmarks/limahong_channel/lch_int_03_facility.gd.uid
scripts/landmarks/limahong_channel/lch_int_03_media.gd
scripts/landmarks/limahong_channel/lch_int_03_media.gd.uid
scripts/landmarks/limahong_channel/lch_int_03_stage.gd
scripts/landmarks/limahong_channel/lch_int_03_stage.gd.uid
tests/lch_int_03_test.gd
tests/lch_int_03_test.gd.uid
```

Required supplied assets: the six INT-03 image/import paths in the untracked
inventory above. They already existed before implementation and were reused
unchanged. A future INT-03-only milestone commit would therefore include these
six asset files plus the 16 new files, subject to researcher approval. No such
commit was made in this task.

## Reused components

- `scenes/components/conference_room_interaction.tscn` and its controller supply
  the inherited interior shell, selected/focus styles, Sources overlay, input
  handling before navigation, narration player, close and return-focus behavior.
- `ConferenceRoomContent` and `ConferenceRoomConceptEntry` are extended by the
  INT-03 content/stage Resources. Historical wording, all three optional media
  references, source metadata and facility descriptions live in the `.tres`.
- The exact shared speaker asset is `assets/ui/icons/speaker.svg`. No Urduja
  narration or other hotspot audio is attached.
- Preview/test conventions follow INT-02: real inherited component, inset
  parent at 90% of viewport, opener button and restored focus. The controller
  adds INT-03-only scrolling behavior; shared scripts remain unchanged.

## Asset audit and source status

All paths below are repository-relative. All images preserve their full aspect
ratio with centered fit and linear filtering. No cropping, stretching, pixel-art
conversion, generative alteration, replacement download or renaming was done.

| Image and exact path | Dimensions | Recorded source and credit | Permission/reuse |
| --- | --- | --- | --- |
| `assets/landmarks/limahong_channel/lch_int_03/photos/lch_int_03_2019_groundbreaking.jpg` | 415 × 260 | Philippine News Agency; photograph Liwayway Yparraguirre; article author Hilda Austria; credit Liwayway Yparraguirre / Philippine News Agency | PENDING |
| `assets/landmarks/limahong_channel/lch_int_03/people/lch_int_03_bataoil.png` | 1122 × 1402 | Municipality of Lingayen official website, identifying Hon. Leopoldo Bataoil; credit Municipality of Lingayen | PENDING |
| `assets/landmarks/limahong_channel/lch_int_03/photos/lch_int_03_present_site.jpg` | 4000 × 3000 | AKAR research team; original field/site documentation photograph; credit AKAR research team | Research-team captured / authorized for AKAR use, as supplied by researcher |

Groundbreaking metadata records the event as Limahong Channel Tourism Center
groundbreaking and the date as **June 2019**. A precise June 6 date was not
assumed. Exact article title, URL and publication date are pending. The image is
low resolution in the supplied original; it is not upscaled into a new asset.

Bataoil page context is the official page identifying Hon. Leopoldo Bataoil.
The exact page URL, photographer and portrait date are not supplied. The role
statement and its House-measure citation remain researcher-supplied content
with the complete citation pending. No unrelated biography was added.

Present-site metadata records:

- Media type: Original field/site documentation photograph.
- Source/credit: AKAR research team.
- Location: Limahong Channel / Pangapisan Norte, Lingayen, Pangasinan.
- Date: `2026-07-18 11:44:09 (embedded EXIF DateTimeOriginal; timezone unspecified)`.
  This comes from the supplied JPEG's EXIF `0x9003`, not an inferred file date.
- Individual photographer: not supplied; pending researcher confirmation.
- Permission: Research-team captured / authorized for AKAR use.

The present-site image is contextual documentation, **not proof of completion**
of any listed facility. No current facility status was inferred from the image.
No signed validator approval file was identified. This is **source-backed
project content prepared for validation**; an unsigned validation-sheet copy is
not described as formal approval.

The media Resource uses an exported image file path that resolves to Texture2D
at opening time. Missing files therefore do not prevent the `.tres` from loading.
Missing assets log a warning and show a restrained documentary placeholder;
the small portrait uses `PHOTO / N/A`. Text and stage interactions remain usable.

## Exact wording and stage behavior

Visitor title: **FROM ESCAPE ROUTE TO HERITAGE DESTINATION**.
Prompt: **EXPLORE THE CHANNEL'S MODERN LEGACY**.
Exactly three direct stage controls appear below the header. No Previous, Next,
Replay, duplicate stage controls, completion counters or progress indicators.

### 01 — 2019 MILESTONE

Full title: **2019 — A NEW MILESTONE**.

> The groundbreaking of the Limahong Channel Tourism Center was held in June 2019 in Barangay Pangapisan Norte, Lingayen.

WHY IT MATTERS:

> It marked an important modern milestone in the site's heritage and tourism development.

The authentic photo is the primary default visual. Its documentary label is:

```text
JUNE 2019
LIMAHONG CHANNEL TOURISM CENTER
GROUNDBREAKING
```

Secondary contributor: **LEOPOLDO N. BATAOIL**.
Role: **MODERN HERITAGE DEVELOPMENT**.

> Former representative Leopoldo N. Bataoil promoted the Limahong Channel Tourism Center, authored the House measure identifying the channel as a tourist spot, and co-led its 2019 groundbreaking.

The contributor card starts collapsed: MODERN CONTRIBUTOR, name, VIEW ROLE.
Click, tap or Space/Enter toggles the explanation directly below it. There is no
modal or full-screen profile. It resets collapsed when leaving Stage 01. The
portrait remains a documentary photo. The expanded heading changes to dark text
on the muted-gold selection. At the smallest size the expanded header uses two
lines and a 60 px target to keep the complete role text and a smaller photo
visible; the default collapsed view gives the groundbreaking photo more space.
No statement implies the whole tourism center was completed in 2019.

### 02 — PRESERVING THE STORY

> The Limahong Channel preserves local memory of the 1575 Pangasinan campaign and Limahong's escape.
>
> Its historical association also supports heritage education and tourism initiatives.

WHY IT MATTERS:

> Modern heritage efforts give visitors another way to encounter and learn about the history remembered at the site.

Three passive Godot PanelContainer nodes show HISTORICAL MEMORY above HERITAGE
EDUCATION and TOURISM INITIATIVES. Two Godot Line2D branches connect the upper
node to the lower pair. Positions derive from the visual board dimensions.
Captions use two lines so their hidden initial layout cannot grow vertically
from a zero-width wrapped label.

Entry animation: upper node fades in for **150 ms**, lines reveal for **250 ms**,
both lower nodes fade in together for **200 ms**: **600 ms total**, once per
entry. It is an interpretation diagram with no click actions, tactical imagery,
strict causal claim, looping, pulsing or unlock behavior. No external diagram
image or line PNG is used.

### 03 — DEVELOPMENT IN PHASES

> The Limahong Channel Tourism Center has been developed as a phased tourism project at the site.

The supplied qualification is used under WHY IT MATTERS, outside the
information ScrollContainer, directly following the main body and fully visible
at all tested sizes:

> Development has proceeded in phases. Facilities listed in the original development plan should not automatically be interpreted as completed facilities.

The visual area has the contextual present-site photograph, its research-team
caption, ORIGINAL DEVELOPMENT PLAN heading and a passive text-card grid. Only
the grid scrolls on that side; neither photo nor qualification scrolls away.
The full facility list is not duplicated in the information panel.

Exactly nine categories are displayed:

1. Limahong Park and Marker
2. Pavilion
3. Artifact Display Area
4. River-Cruise Facilities
5. Sunset Garden
6. Mini-Forest
7. Eco-Park
8. Paved Activity Areas
9. Improved Access Roads

`FacilityStatus` contains ORIGINAL_PLAN, EXISTING and PHASED, with labels
ORIGINAL PLAN, EXISTING and PHASED / UNDER DEVELOPMENT. All nine default to
**ORIGINAL_PLAN** because no researcher-approved current-status evidence was
provided. The Resource also records `Listed in the original development plan.`
No cards are buttons or focus targets. The optional stagger was omitted; the
ordinary stage crossfade reveals the board without construction symbolism.
Full development-plan citation and supported current statuses remain pending.

## State, transitions, Sources and narration

`HeritageStage` contains MILESTONE_2019, PRESERVATION and DEVELOPMENT.
`current_stage` defaults to MILESTONE_2019; `contributor_expanded` defaults false.
The shared `_selected` value is synchronized for inherited Sources/rendering;
it is not an independent stage-selection path. Every stage control and arrow
action routes through `select_stage`.

Crossfade: **200 ms**, sine ease in/out, no slide or overshoot. Old Tweens are
killed and opacity/scale are normalized before the requested stage is shown.
During crossfade the outgoing visual is inert; inactive contributor input and
facility scrolling/focus are disabled. At rest exactly one view and one selected
stage remain. A repeated selection of the current stage settles it without
replaying the interpretation. Resize, close and Sources safely cancel transient
animation/drag state. No accumulated transforms or stale callbacks remain.

Sources uses the shared modal shell and focus trap. Categories: 2019 MILESTONE,
MODERN CONTRIBUTOR, HERITAGE SIGNIFICANCE, DEVELOPMENT PLAN and MEDIA CREDITS.
All known media metadata and pending items are displayed. Sources preserves
stage, contributor expansion, facility scroll and narration playback. Escape
closes Sources first; a subsequent Escape closes the hotspot. Input is handled
before inherited navigation/close signals fire.

There is one overall narration stream slot and the supplied transcript in the
content Resource. No correct INT-03 audio exists yet. LISTEN and the shared
speaker icon remain visible, disabled, with Narration pending. No autoplay and
no other hotspot's audio. An in-memory synthetic audio fixture verifies that
stage/contributor/Sources actions do not restart playback; closing stops it.

Closing/reopening returns to Stage 01, collapsed contributor, facility scroll
at top, closed Sources, stopped narration and cancelled Tweens. Opener keyboard
focus is restored on close. No stale development view survives reopening.

No earlier/before image, comparison Resource fields, divider, comparison slider,
micro-video, video Resource fields, playback control or empty reserved space was
implemented. Tests only assert absence of removed controls; there are no removed
feature interaction tests.

## Responsive and input results

Native Compatibility rendering was inspected through captured frames in the
real 90%-inset preview. The automated test uses actual parent dimensions rather
than relying on reference-viewport scaling.

| Viewport | Embedded component | Result |
| --- | --- | --- |
| 1280 × 720 | 1152 × 648 | PASS; approximately 64% visual / 36% information, full stage labels, 56 px controls, 3-column facility grid with internal scroll |
| 960 × 540 | 864 × 486 | PASS; full stage labels, 52 px controls, 3-column grid with internal scroll |
| 854 × 480 | 768.6 × 432 | PASS; 2019 / PRESERVATION / DEVELOPMENT labels, approximately 57% / 43% split, 52 px controls, 2-column internally scrolling grid |

Full stage titles remain in the information panel. Header controls do not
overlap; documentary aspect ratios remain intact; contributor content and
diagram stay inside the visual area; qualification stays fully visible. The
whole hotspot never scrolls. Long stage prose uses the established internal
information scroll at compact sizes, independently from the facility grid.

Mouse: direct selection, contributor toggle, Sources/close and grid wheel scroll
pass. Keyboard: Tab/Shift+Tab traversal, distinct shared focus border, Left/Right
stage selection without wrapping, Enter/Space activation and Up/Down,
PageUp/PageDown, Home/End scrolling pass. Synthetic touch: stage/contributor/
Sources/close taps and facility dragging pass. Scroll dragging is explicitly
handled within INT-03 so desktop synthetic events behave deterministically as
well as touchscreen events. No hover-only content.

## Automated validation

Godot 4.7.2 executable used:
`C:/Users/Admin/OneDrive/Documents/Godot Files/Godot_v4.7.2-stable_win64_console.exe`.
Editor import completed successfully and generated the new script `.uid` files.

INT-03 native rendered suite after the targeted revision: **1,859 checks, 0 failures**, exit 0.
Coverage includes exact wording, media dimensions/fallbacks, nine ORIGINAL PLAN
items, visible qualification, passive cards/nodes, 200 ms crossfade, sequential
diagram reveal, rapid input, focus, three input methods, Sources preservation,
overall audio continuity, no autoplay, and deterministic close/reopen reset.

Both required rapid sequences pass at every target size:

- 2019 → Development → Preservation → 2019 → Development.
- Preservation → Development → 2019.

Regression results (existing suites, headless, no modifications):

| Suite | Result |
| --- | --- |
| LCH-EXT-01 | All three sizes pass; 0 failures; exit 0 |
| LCH-EXT-02 | All three sizes pass; 0 failures; exit 0 |
| LCH-EXT-03 | All three sizes pass; 0 failures; exit 0 |
| LCH-INT-01 | 594 checks, 0 failures; exit 0 |
| LCH-INT-02 | 2,663 checks, 0 failures; exit 0 |

No GDScript parser/runtime errors remain in the final INT-03 run. The sandboxed
Godot process logs `Failed to read the root certificate store` at startup in
both new and existing suites; no network access is used. Three intentional
missing-image warnings come from the negative asset test. EXT-01 reports its
existing two ObjectDB instances at shutdown. The final INT-03 run has no leak
warning. These messages are distinguished from test failures.

`git diff --check`, `git diff --cached --check` and no-index whitespace checks
on all 16 new files pass. The new files are untracked, so the no-index checks
are necessary to include them without staging anything.

Reproduce the native INT-03 suite from the repository root:

```powershell
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/lch_int_03_test.gd -- --capture
```

For regressions, run the same executable with `--headless --path . --script`
and each `res://tests/lch_ext_01_test.gd`, `lch_ext_02_test.gd`,
`lch_ext_03_test.gd`, `lch_int_01_test.gd`, `lch_int_02_test.gd` path.
Captured frames are `%TEMP%/lch-int-03-{width}x{height}-{state}.png`.
Logs are `%TEMP%/lch-int03-test.log`, `lch-int03-import.log`, and
`lch-int03-regression-{ext_01,ext_02,ext_03,int_01,int_02}.log`.

Browser export and physical touchscreen hardware were not exercised; synthetic
touch and native Compatibility rendering were exercised. This is not a claim
of final researcher visual approval or browser/device certification.

## Researcher F6/manual review and outstanding items

1. Open `scenes/landmarks/limahong_channel/interior/lch_int_03_preview.tscn`
   in Godot and press F6. Activate the opener.
2. Review the authentic groundbreaking photograph, documentary label and exact
   body/WHY IT MATTERS wording. Toggle Bataoil's role by mouse, keyboard and touch.
3. Select Preservation; confirm the single 600 ms top-node/lines/lower-node reveal
   reads as a heritage interpretation diagram.
4. Select Development; review the contextual photo, all nine ORIGINAL PLAN cards,
   and always-visible phased-development qualification. Scroll to the final row.
5. Open/close Sources from Development and from the expanded contributor view.
   Confirm preserved state, complete source/pending metadata, and Escape hierarchy.
6. Try fast stage changes, resize the preview, close mid-animation, then reopen.
   Confirm the default stage, collapsed contributor and stopped narration.
7. Review all target-size captures or run the suite above for exact unscaled
   1280×720, 960×540 and 854×480 parent layouts. Confirm compact readability on
   the intended touchscreen and later in the Web export.

Outstanding: PNA image reuse permission; Municipality of Lingayen image reuse
permission; complete PNA article/page/House-measure/development-plan citations;
portrait photographer/date if obtainable; present-site individual photographer
and EXIF timestamp/timezone confirmation; the final INT-03 narration recording;
researcher F6 visual review and subsequent target-browser/device review.

Work stops here for researcher review. No commit or push; END-01, ENT-01 and
the master scene remain untouched.
