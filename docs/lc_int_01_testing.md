# LC-INT-01 — People Who Shaped the Parish

> Current utility/audio behavior is documented in the 2026-10-01 revision below; earlier milestone results are historical.

## A. Hotspot identity

Standalone Phase 5 interior hotspot for Lingayen Church, implemented in Godot
4.7.2 with GDScript and Compatibility rendering. Implementation and automated
validation completed on 2026-09-25. The researcher approved the portrait-wall
concept; the focused learning-clarity revision in section T awaits F6 review.
No master layout integration, LC-INT-02 or entrance video work was performed.

## B. Interaction and shared architecture

The four portrait/document cards form a 2×2 selectable wall. The whole card is
the control. No separate selector row, biography navigation, completion state,
scores or game mechanics exist. A bright inherited keyboard outline differs
from the selected card's muted gold border and background.

Inspected LC-EXT-01, LC-EXT-02, LC-EXT-03 and LCH-EXT-01, plus
`conference_room_interaction.gd`, its scene and content resource. Reused the
existing shell, header conventions, Sources overlay, narration player, focus
cycle, Escape handling and preview sizing script without editing them.

`selected_person: PersonSelection` is authoritative. `set_selected_person()`
updates every selected card, role, heading, body, parish connection, source
basis, image credit, historical anchor, narration stream, accessibility state
and reading position. The inherited concept index is unused. The card helper
only presents content; it does not own a person-selection model.

Historical anchors are passive labels with subtle connector lines. A primary
connection uses a 12 px filled gold marker; a secondary connection uses a 12 px
gold outlined marker. Neutral connections use smaller 6 px gray markers. Text
colors also distinguish all three states. Anchors never take focus or pointer input.
Only detail text fades (160 ms); old transitions are cancelled on reselection.
Opening/closing uses a restrained 160 ms fade. Cleanup precedes `close_requested`.
Reopening restores NONE, neutral anchors, overview, no Sources, no narration,
top reading position and Guerrero-card keyboard focus without selecting it.

## C. Content boundary

SOURCE-BACKED PROJECT CONTENT PREPARED FOR VALIDATION. No museum-approval or
official-validation badge or claim is shown. Historical text matches the
researcher-supplied request, including Guerrero's May 24, 1929 consecration.
No broader biographies or additional historical claims were added. Educational
acceptability is not represented as proven learning effectiveness.

## D. Four-person inventory

| Position | Person | Full role | Primary anchor | Secondary |
|---|---|---|---|---|
| Top left | Bishop César María Guerrero | First Bishop of Lingayen | 1929 | None |
| Top right | Archbishop Mariano A. Madriaga | Wartime & Postwar Leadership | WAR / POSTWAR | 1963 |
| Bottom left | Father Samuel Sheehan | Columban Missionary Service | 1933 | None |
| Bottom right | Father Dermot Feeny | Wartime Service & Recovery | WAR / POSTWAR | None |

There are exactly four person resources. No Gallagher card exists.

## E. Asset inventory and fallback

All four originally requested JPG paths were missing at the initial audit:

```text
assets/landmarks/lingayen_church/lc_int_01/images/lc_int_01_guerrero_portrait.jpg
assets/landmarks/lingayen_church/lc_int_01/images/lc_int_01_madriaga_portrait.jpg
assets/landmarks/lingayen_church/lc_int_01/images/lc_int_01_sheehan_portrait.jpg
assets/landmarks/lingayen_church/lc_int_01/images/lc_int_01_feeny_portrait.jpg
```

The user explicitly approved referencing the existing PNG portraits unchanged:

| Actual existing filename in the same images directory | Dimensions | Format |
|---|---|---|
| lc_int_01_guerrero_portrait.png | 1122×1402 | PNG |
| lc_int_01_madriaga_portrait.png | 1122×1402 | PNG |
| lc_int_01_sheehan_portrait.png | 1122×1402 | PNG |
| lc_int_01_feeny_portrait.png | 1122×1402 | PNG |

These are approximately 4:5. Their existing `.png.import` sidecars also predate
this milestone. No portrait was edited, renamed, converted, reconstructed,
colorized or replaced. UI framing contains the original aspect ratio and uses
local linear filtering; the project's pixel-art filtering remains unchanged.

When a person resource has no portrait, the card renders a neutral text-only
document frame with the full supplied display name, full role and `Portrait
source pending`. It never borrows another person's portrait. All four null
portrait cases are tested and captured at 854×480. Compact fallback text uses
13 px names and 12 px role/status text; this exceptional layout merits physical
device readability review. Normal compact cards use 15 px names/14 px roles.

## F. Exact image credits and historical source basis

Guerrero: `SOURCE: Lingayen: Memories of Times Past (2021), p. 16.`

Madriaga: `SOURCE: Lingayen: Memories of Times Past (2021), p. 17.`

Sheehan and Feeny: `IMAGE SOURCE: Missionary Society of St. Columban — Philippines`

Guerrero and Madriaga use `Archdiocese of Lingayen-Dagupan` as the historical
source basis. Sheehan and Feeny use `Epiphany of Our Lord Parish history`.
Original source-basis and image-credit metadata are retained. The detail reading
area now combines both into one compact source line, which can wrap. Full source
references remain in Sources. No attribution is represented as image permission.

## G. Rights and internal validation metadata

Sheehan and Feeny retain the supplied metadata:

> Source/identity verified by the research team. Reuse/permission status remains subject to project documentation.

Permission/reuse status remains pending documentation; no open-license claim
is made. This milestone did not independently verify permissions or identities.

Feeny's internal note is preserved only in resource/documentation metadata:

> Surname spelling should be reconfirmed using parish or Columban records.

Neither note is displayed as ordinary visitor content or a prominent badge.

## H. Responsive behavior

| Actual client viewport | Layout | Detail reading |
|---|---|---|
| 1280×720 | 2×2 wall, approximately 52% wall / 48% detail | All four selected states fit without scrolling |
| 960×540 | Same 2×2 relationship and right detail; smaller gaps and compact labels | Internal detail scrolling as needed |
| 854×480 | Approximately 44% wall / 56% detail, 2×2 retained | Internal detail scrolling; no whole-screen scrolling |

The preview uses a gray backdrop and a 5% inset heritage panel. Portrait cards
remain at least 150×90 effective pixels in tested layouts (about 276×181 at
reference size and 157×101 at the smallest size). Shared actionable controls
are at least 56 px high. The passive strip, prompt, takeaway and Sources remain
visible. No giant duplicate portrait is added to the detail area.

Compact visible labels are Bishop Guerrero / First Bishop, Archbishop Madriaga /
War & postwar, Father Sheehan / Columban mission and Father Feeny / War & recovery.
Full names and roles remain in each accessible button name; the selected detail
panel always uses the full role. Compact strings live in the resource.

## I. Keyboard behavior

Arrow keys move focus spatially through the 2×2 wall without changing selection;
outer edges clamp. Enter/Space selects. Tab proceeds through the four cards,
available LISTEN, detail scroll, Sources and Close; disabled LISTEN is skipped.
Sources traps focus within its reading area and Close Sources control. Its
closure returns focus to Sources. Hotspot closure restores the preview trigger.

Arrow keys, Page Up/Down and Home/End scroll a focused reading region. Escape
closes Sources first, then the hotspot. Input is marked handled before close
navigation is emitted, following the shared shell's safety convention.
Native assistive-technology announcement behavior still requires device review.

## J. Touch behavior

Synthetic `InputEventScreenTouch` input with Godot's mouse-from-touch support
selects all four cards, including near-corner taps. Sources, Close Sources and
Close also pass synthetic touch checks. Entire cards are targets; no drag,
long press, double tap, precision target or hover dependency exists.
Physical touchscreen and exported browser testing remain manual follow-ups;
synthetic desktop touch is not a claim of completed physical-device validation.

## K. Mouse behavior

Real dispatched mouse events select all four cards from their outer corners.
Sources, Close Sources, Close and the actual preview trigger pass. All reading
and selected state information remains available without hovering.

## L. Sources behavior

The inherited overlay contains the four supplied source groups: The Archbishops;
A Brief History of the Epiphany of Our Lord Parish; the two book portrait pages;
and the two Columban portrait/image sources. It preserves person, card state and
anchor state, traps focus, scrolls internally, and supports Escape/Close Sources.

## M. Narration status

One LISTEN control remains visible, disabled, with `Narration pending.` All four
provided person narration slots are null. No transcript UI or four-speaker row
was introduced. Future per-person `AudioStream` support was exercised using a
temporary in-memory test clip: LISTEN played the selected clip; changing person
and closing stopped it; reopening cleared it from active playback.

## N. Automated validation

The initial implementation's Godot 4.7.2 editor import completed without script,
resource or import errors. Its harness passed **3,576 headless checks, zero failures**
and **3,601 Compatibility-rendered checks, zero failures**. The extra 25 rendered
checks verify saving 21 requested-size screenshots and four fallback screenshots.
These are the original implementation results; section T records the focused
revision's current validation results and additional anchor/source checks.

Coverage: exact content and order; all overview/person states; exclusivity;
all anchor mappings; per-person sources/credits; absence of unsupported visitor
claims; spatial focus boundaries; Enter/Space/Tab; mouse/synthetic touch; Sources
preservation and Escape hierarchy; close signal; reopen/reset and close-race
cancellation; parent-hide cleanup; rapid Guerrero → Feeny → Sheehan → Madriaga →
Guerrero; null portrait safety; future narration lifecycle; layout containment,
readable bounds, hit sizes, aspect preservation and reference-size reading fit.

Run from the repository using your Godot executable:

```powershell
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --headless --path . --script res://tests/lc_int_01_test.gd
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --path . --rendering-method gl_compatibility --script res://tests/lc_int_01_test.gd -- --capture
```

Screenshots are saved to `%TEMP%/lc_int_01_<width>_<state>.png`, where width is
1280, 960 or 854 and state is preview, overview, guerrero, madriaga, sheehan,
feeny or sources. Fallbacks use `lc_int_01_854_fallback_<person>.png`.
Rendered preview, person, Sources and demanding compact/fallback captures were
visually inspected. Researcher interpretation and visual acceptance remain pending.

Final logs: `%TEMP%/akar_lc_int_01_headless_verified.log`,
`%TEMP%/akar_lc_int_01_render_verified.log` and
`%TEMP%/akar_lc_int_01_import_final.log`.

## O. Regression results

| Existing unchanged harness | Result |
|---|---|
| tests/lc_ext_01_test.gd | 0 failures |
| tests/lc_ext_02_test.gd | 0 failures |
| tests/lc_ext_03_test.gd | 0 failures |
| tests/lch_ext_01_test.gd | 0 failures |

Logs: `%TEMP%/akar_lc_int_01_regression_<hotspot_id>.log`.

## P. Environment warnings and verification limits

Sandboxed runtime checks reported `Failed to read the root certificate store.`
The rendered run additionally reported inability to create the `user://` shader
cache; rendering and screenshot capture still completed. These are environment
warnings, not test failures. The initial restricted editor import could not
write normal Godot editor/cache directories; rerunning with permitted normal
editor cache access completed cleanly. No project settings were changed to
suppress warnings. Earlier implementation defects found by tests were corrected;
the results above refer to the final passing version only.

No Web export, physical touch device test, screen-reader audit or researcher
historical validation is claimed by these desktop checks.

## Q. Exact F6 researcher review checklist

1. Open `scenes/landmarks/lingayen_church/interior/lc_int_01_preview.tscn` in Godot.
2. Press F6. For actual responsive-size checks, run in a separate game window;
   resize its client area rather than scaling the embedded preview image. No
   change to `project.godot` is required by the component.
3. At 1280×720, capture the neutral development preview. Click **Meet the People**.
4. Capture the overview: all portraits visible, no selected fill, all anchors
   neutral, disabled LISTEN, `Narration pending.` and visible Sources.
5. Capture Guerrero, Madriaga, Sheehan and Feeny in order. Check exact wording,
   source basis, image credits, documentary framing and distinct focus/selection.
6. Confirm Guerrero highlights 1929; Sheehan 1933; Feeny WAR / POSTWAR; Madriaga
   WAR / POSTWAR plus secondary 1963. The strip must not act as navigation.
7. Open and capture Sources. Escape once should restore the same selected person;
   Escape again should close. Reopen and confirm the neutral overview reset.
8. Use arrows through the four positions without selecting; select with Enter
   and Space, then Tab through controls. Check reading-scroll keyboard behavior.
9. Rapidly select Guerrero → Feeny → Sheehan → Madriaga → Guerrero. Confirm no
   stale card, source, credit, anchor or faded text remains.
10. Repeat demanding Madriaga and Guerrero states, Sources, mouse/touch selection
    and reopen at 960×540 and 854×480. Scroll only the internal detail area to see
    lower metadata. Inspect actual physical-touch comfort when a device is available.
11. Judge whether the wall reads as a museum portrait display, portraits clearly
    invite selection, names remain readable, source credits are secondary, the
    contextual strip helps explain the parish connection, and compact reading
    remains comfortable. Review all supplied documentary images and internal
    Feeny/permission notes against researcher records before content approval.

## R. Git before/after and exact file inventory

Initial status (nothing staged):

```text
 M project.godot
?? assets/landmarks/lingayen_church/lc_int_01/
?? docs/references/
```

`git diff --name-status` reported only `M project.godot` before implementation;
the cached diff was empty. Eight recent commits were inspected; HEAD was
`6ccd635 feat: implement Lingayen Church LC-EXT-03 historic bells hotspot`.

Exactly nine authored files created:

```text
data/landmarks/lingayen_church/lc_int_01.tres
scenes/landmarks/lingayen_church/interior/lc_int_01.tscn
scenes/landmarks/lingayen_church/interior/lc_int_01_preview.tscn
scripts/landmarks/lingayen_church/lc_int_01.gd
scripts/landmarks/lingayen_church/lc_int_01_content.gd
scripts/landmarks/lingayen_church/lc_int_01_person_content.gd
scripts/landmarks/lingayen_church/lc_int_01_person_card.gd
tests/lc_int_01_test.gd
docs/lc_int_01_testing.md
```

Godot generated five new `.gd.uid` sidecars, one for each of the four scripts
and one for the new test. No existing authored files were modified by this
milestone. All **386 pre-existing non-ignored tracked/untracked files** retained
their baseline SHA-256 hashes, including `project.godot`, all reference material,
all four PNG portraits and their existing import sidecars.

Final status:

```text
 M project.godot
?? assets/landmarks/lingayen_church/lc_int_01/
?? data/landmarks/lingayen_church/lc_int_01.tres
?? docs/lc_int_01_testing.md
?? docs/references/
?? scenes/landmarks/lingayen_church/interior/
?? scripts/landmarks/lingayen_church/lc_int_01.gd
?? scripts/landmarks/lingayen_church/lc_int_01.gd.uid
?? scripts/landmarks/lingayen_church/lc_int_01_content.gd
?? scripts/landmarks/lingayen_church/lc_int_01_content.gd.uid
?? scripts/landmarks/lingayen_church/lc_int_01_person_card.gd
?? scripts/landmarks/lingayen_church/lc_int_01_person_card.gd.uid
?? scripts/landmarks/lingayen_church/lc_int_01_person_content.gd
?? scripts/landmarks/lingayen_church/lc_int_01_person_content.gd.uid
?? tests/lc_int_01_test.gd
?? tests/lc_int_01_test.gd.uid
```

`git diff --check` and explicit no-index whitespace checks of all new text files
passed. No files were removed, and no unrelated untracked material was cleaned.

## S. Repository action confirmation

Nothing staged. No commit. No push. HEAD remains `6ccd635`.
Stop here for researcher visual review; this implementation does not authorize
master landmark integration or any subsequent hotspot milestone.

## T. F6 LEARNING-CLARITY REVISION

### Scope and repository safety

The portrait-wall concept remains approved. This revision fixes the visual
hierarchy of Madriaga's 1963 connection and uses the researcher's exact concise
visitor copy. It introduces no new buttons, people, interaction modes or navigation.

Before editing, AGENTS.md and current LC-INT-01 resources, scripts, tests and
documentation were inspected. `git status --short`, cached/working diff names
and eight recent commits were recorded. Nothing was staged; the only tracked
working modification was the pre-existing `project.godot`. LC-INT-01 assets and
implementation files, plus `docs/references/`, were already untracked.

The before/after status is identical to the complete final-status block in
section R. The revision changed only these five already-existing files:

```text
data/landmarks/lingayen_church/lc_int_01.tres
scripts/landmarks/lingayen_church/lc_int_01.gd
scripts/landmarks/lingayen_church/lc_int_01_person_content.gd
tests/lc_int_01_test.gd
docs/lc_int_01_testing.md
```

No files were created or removed. A SHA-256 snapshot of all 400 pre-existing
non-ignored files confirmed that the other 395 files are unchanged, including
all original portraits, their import sidecars, scenes, portrait-card helper,
UIDs, other hotspots, `project.godot` and `docs/references/`.

### Anchor fix and content changes

Madriaga's resource already specified WAR / POSTWAR as primary and 1963 as
secondary. The earlier tiny secondary dot and muted text were insufficiently
distinct. The revised passive strip uses:

| State | Marker | Text |
|---|---|---|
| Neutral | 6 px filled gray dot | Subdued gray `#8e9789` |
| Primary | 12 px filled gold circle | Stronger gold `#e2cc91` |
| Secondary | 12 px circle with a 2 px gold outline, no fill | Gold/cream `#d9c184` |

Marker geometry distinguishes secondary from primary and neutral in addition
to color. No literal PRIMARY/SECONDARY labels are displayed. Accessible anchor
names retain the connection hierarchy. All five mappings from section D remain
unchanged; NONE restores four neutral anchors. The strip is not clickable,
focusable, a progress meter or a required sequence.

All four bodies and one-sentence parish connections now match the exact revised
request. A separate `Connection to Lingayen Church` label precedes the connection.
Guerrero's May 24, 1929 date is retained. Madriaga uses the supplied concise 1963
statement. Feeny's internal surname note and both Columban rights-status fields
remain intact and outside visitor-facing copy. No biographies or facts were added.

Each selected person now has one combined provenance label:

- Guerrero: `Source: Archdiocese of Lingayen-Dagupan · Portrait: Lingayen: Memories of Times Past (2021), p. 16`
- Madriaga: `Source: Archdiocese of Lingayen-Dagupan · Portrait: Lingayen: Memories of Times Past (2021), p. 17`
- Sheehan and Feeny: `Source: Epiphany of Our Lord Parish history · Image: Missionary Society of St. Columban — Philippines`

The original full source list and original per-person credit/source metadata are
retained. Sources preserves person/card/anchor state, with the same Escape hierarchy.

The overview is now: “Bishops and missionaries helped guide Lingayen Church
through major periods of cathedral leadership, missionary service, war, and
postwar recovery.”

The takeaway is now: “Lingayen Church's history was shaped by bishops and
missionaries who guided the parish through major periods of change.”

### Responsive and input results

At 1280×720, every selected-person state fits without a detail scrollbar; the
combined source line is fully visible. The interpretation groups have 14 px
spacing, with 4 px between the connection label and its sentence. Fonts retain
the established reference-size hierarchy: 24 px heading, 19 px body, 18 px
connection and 15 px provenance. Portraits, controls, Sources and takeaway keep
their existing layout.

At 960×540 and 854×480, compact interpretation uses 18 px headings, 16 px body/
connection and 14 px role/provenance with 6 px group spacing. Internal reading
scrolling remains necessary in demanding states; all four source lines are
verified fully reachable at the bottom of that region. The revision does not
claim that all 960×540 content fits without scrolling. The 2×2 portrait wall,
historical strip, takeaway and Sources remain visible with no whole-screen
overflow. Card hit targets and shared 56 px controls are unchanged.

Mouse, spatial keyboard focus, Enter/Space, Tab, reading scroll, Sources focus,
Escape, reset/reopen, future narration cleanup, synthetic touch, missing-portrait
fallback and rapid-switch protections pass. Both the original rapid-switch
sequence and Madriaga → Guerrero → Feeny → Madriaga → Sheehan → Madriaga are tested.
The latter ends with only Madriaga selected, WAR / POSTWAR filled gold, 1963 a
gold ring, the correct concise copy/source line and no stale anchor or fade.

### Automated validation and environment

The final revised harness passed **5,065 headless checks** and **5,092
Compatibility-rendered checks**, both with **zero failures**. The 27 additional
rendered checks verify successful screenshot saves, including the two compact
source-reading captures. `git diff --check` and no-index whitespace checks of
all five changed files passed. Git status remained identical before and after,
the index remained empty, and the 395 out-of-scope files retained their hashes.
The revised harness checks actual marker size, fill, outline and text colors;
it explicitly asserts that Madriaga's 1963 color differs from neutral. It also
checks exact revised copy, one provenance label, retained full Sources, no
Gallagher content, metadata preservation, unclipped reference-size sources and
compact source reachability. All scene/resource dependencies and GDScript load
successfully in the test harness.

LC-EXT-01, LC-EXT-02, LC-EXT-03 and representative LCH-EXT-01 regressions each
completed with zero failures. Their files were not modified.

Sandboxed runs report the existing certificate-store warning; Compatibility
rendering additionally reports that the user shader-cache directory cannot be
created. Tests and screenshot captures still complete. No project settings
were changed to suppress those warnings. Physical touch, browser export and
native screen-reader validation remain outside this desktop verification.

Revision logs are `%TEMP%/akar_lc_int_01_revision_headless_final.log`,
`%TEMP%/akar_lc_int_01_revision_render_final.log`, and
`%TEMP%/akar_lc_int_01_revision_<regression_id>.log`.
The usual screenshot set from section N is refreshed; two additional captures,
`lc_int_01_960_madriaga_details.png` and `lc_int_01_854_madriaga_details.png`, show
the fully reachable compact connection and source text after internal scrolling.

### Revision checklist

Checks below record implementation/testing observations, not final researcher approval.

- [x] Madriaga WAR / POSTWAR is primary.
- [x] Madriaga 1963 is visibly secondary.
- [x] Primary and secondary states are visually distinguishable.
- [x] Neutral anchors remain visibly different.
- [x] Visitor copy shortened.
- [x] Connection statements reduced to one sentence.
- [x] Duplicate source lines replaced by one compact source label.
- [x] Full references retained in Sources.
- [x] Overview is concise.
- [x] Takeaway shortened.
- [x] No biography expansion added.
- [x] Portrait-wall interaction unchanged.
- [x] 1280 layout is less visually dense and requires no detail reading scroll.
- [x] 960 layout remains clear; internal scrolling is retained where needed.
- [x] 854 layout remains usable with internal reading scroll.
- [x] Historical facts unchanged in meaning; exact supplied revision used.
- [x] Original portrait files unchanged.
- [ ] Researcher F6 acceptance of this focused revision.

### Exact F6 revision review steps

1. Open `scenes/landmarks/lingayen_church/interior/lc_int_01_preview.tscn` and press
   F6. Set the actual client area to 1280×720 and choose **Meet the People**.
2. Confirm the short overview and takeaway, with four neutral gray anchor dots.
3. Select Madriaga. Confirm WAR / POSTWAR has a filled gold marker and 1963 has a
   clearly visible gold ring. Neither 1929 nor 1933 should look active.
4. Read the role, heading, short body, separate connection label/sentence and one
   compact source label. Confirm no ordinary detail scrollbar or clipped text.
5. Select Guerrero, Sheehan and Feeny. Check their single active anchors and exact
   concise copy; Guerrero must still show May 24, 1929.
6. Open Sources while Madriaga is selected. Verify full references; Escape once
   restores Madriaga and both active anchors, then Escape closes the hotspot.
7. Reopen to NONE. Check arrow focus versus selection, Enter/Space, mouse/touch,
   and Madriaga → Guerrero → Feeny → Madriaga → Sheehan → Madriaga.
8. Repeat at 960×540 and 854×480. Use internal scrolling to see lower connection/
   source text. Confirm portrait targets, anchors, takeaway and Sources stay visible.
9. Judge the revised information density and visual hierarchy in the museum
   context. The intended quick reading experience has not been timed or claimed
   as a measured learning outcome.

Nothing staged. No commit. No push. HEAD remains `6ccd635`. Stop for researcher
F6 review; no other hotspot or integration work is included.


## 2026-10-01 — Casa Real utility header and narration revision

**Narration is activated with researcher approval.** The identical temporary
recordings are intentional and are not a defect or activation blocker.

Current narration assets are intentionally temporary and may contain the
same recording. Each hotspot already uses its permanent hotspot-specific
audio path so that final narration can later be substituted by replacing the
corresponding .ogg file without changing code or resource mappings.

### Actual audio audit

- Hotspot: **LC-INT-01**
- Existing file: `res://assets/landmarks/lingayen_church/audio/lc_int_01_narration.ogg`
- Size: 288,586 bytes; Godot type: AudioStreamOggVorbis; duration: 21.0 seconds.
- Existing `.ogg.import` metadata is present; loop is false.
- SHA-256: `5E44ADB87270F4DC7586CF026902718C597544C394376FC0FDEFE1E38FA4BD44`.
- Assigned resource slot: `narration_stream (inherited from ConferenceRoomContent)` in `data/landmarks/lingayen_church/lc_int_01.tres`.
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

The old takeaway/Sources HBox was removed. The takeaway is a full-width direct layout child with its natural height, so the portrait wall and reading panel reclaim the fixed utility-row height.

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
