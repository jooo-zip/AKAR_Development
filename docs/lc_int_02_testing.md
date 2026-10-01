# LC-INT-02 — Lingayen Church Through Time

> Current utility/audio behavior is documented in the 2026-10-01 revision below; earlier milestone results are historical.

## A. Component identity

Standalone Phase 5 interior hotspot, implemented and checked on 2026-09-25
with Godot 4.7.2, typed GDScript and Compatibility rendering. Ready for
researcher F6 visual review; that review has not yet occurred. No master
landmark integration, LC-END-01 or LC-ENT-01 implementation was performed.

Inspected LC-EXT-01, LC-EXT-02, LC-EXT-03, LC-INT-01 and representative
Limahong LCH-EXT-01, their resource/scene/test conventions, and the shared
conference-room shell. Reused `conference_room_interaction.gd`, its scene,
`conference_room_content.gd`, `speaker.svg`, and `lc_ext_01_preview.gd`
without editing them. Navigation retains the inherited viewport-before-signal
input handling and Sources focus behavior.

## B. Educational purpose

The selected year, passive era strip, staged transformation and supporting
evidence communicate what changed before visitors need to read every sentence.
The experience is self-paced, with no required sequence, completion tracking,
scores or other game mechanics. This is a design intention awaiting researcher
review, not a claim of measured learning effectiveness.

## C. Content validation status

SOURCE-BACKED PROJECT CONTENT PREPARED FOR VALIDATION. Historical content is
separate from application logic in `data/landmarks/lingayen_church/lc_int_02.tres`.
Text follows the researcher-supplied implementation request. No historical facts,
dates, quotations, personalities, reconstructed imagery or source URLs were
invented. No museum approval or official historical validation is claimed.
Full bibliographic details for the historical/evangelization materials remain
pending researcher documentation, as stated in Sources.

## D. Eight milestones

| Timeline | Detail date | Heading | Transformation |
|---|---|---|---|
| 1500s | 16th Century | Early Missionary Activity | Early Catholic mission → Augustinian missionaries → later Dominican administration |
| 1898 | 1898 | Transition in Parish Administration | Dominican administration → transition toward → Filipino diocesan clergy |
| 1928 | 1928 | Cathedral and Episcopal Seat | Parish church → cathedral + episcopal seat |
| 1933 | 1933 | Columban Missionary Service Begins | Parish administration → Columban missionary service begins |
| 1945 | 1945 | Wartime Destruction | Prewar church → 1945 wartime damage |
| 1954 | 1954 | Co-Cathedral Transition | Episcopal seat in Lingayen → seat transferred to Dagupan; Lingayen remains co-cathedral |
| 1963 | 1963 | Metropolitan Archdiocese | Diocese of Lingayen-Dagupan → metropolitan archdiocese |
| 1981 | 1981 | Filipino Diocesan Leadership Continues | Columban administration → Filipino diocesan leadership continues |

The explanation retains May 19, 1928; January 9, 1945; and February 16, 1963
exactly as supplied. No exact day/month was added for 1954. The 1898 display
uses “transition toward” to preserve the supplied account's gradual transition.
The 1954 retained co-cathedral status is a separate result, without an arrow
suggesting another transfer. The 1928 additional role uses a plus connector.

## E. Supplementary 1710 treatment

1710 is not a timeline point, selectable state or founding claim. Only the
Early Mission detail shows the supplementary Historical Note:

> 1710 is traditionally associated with the historic church structure, but it should not be treated as a confirmed parish founding date.

The note disappears immediately on every other selection and on reset.

## F. Era mapping

| Era | Milestones |
|---|---|
| Missionary Foundations | 1500s, 1898 |
| Cathedral Development | 1928, 1933 |
| War & Institutional Change | 1945, 1954 |
| Continuing Leadership | 1963, 1981 |

The strip is passive, never a second navigation system. The active era has a
gold border/text and distinct background; overview leaves all four neutral.
Era is derived from the selected resource, not separately mutable state.

## G. Interaction model

`selected_timeline_state: TimelineState` is authoritative. The enum has NONE
plus the eight milestones. `set_timeline_state()` cancels the previous reveal,
stops narration and updates all markers, era, date, title, transformation,
media, captions, credits, explanation, note, source basis, narration stream,
accessibility state and detail reading position before animating presentation.

Eight evenly spaced whole-point buttons sit over one connected horizontal
ribbon. All dates remain visible. There are no Previous/Next buttons, carousel,
automatic progression, hidden milestones or secondary navigation cards.
The timeline-point helper owns presentation only. The inherited concept index
does not drive this interaction. `milestone_selected` and `close_requested`
signals are available to a future host.

## H. Educational animation model

A selection shows context first, then a connector and the changed role, then
any additional/retained role, then supporting explanation and source basis.
Final labels remain visible. The current selected state is already valid while
the reveal runs, and controls remain usable throughout.

Connectors animate their drawing child inside a fixed layout space, so Godot
Container layout cannot reset their reveal scale. Only line scale and opacity
change; there is no layout movement, camera movement, dramatic damage effect,
fake building reconstruction or decorative historical simulation.

## I. Exact animation durations

Times below are seconds from selection; all reveals finish by 1.00 second.

| Element | Start | Duration | End |
|---|---:|---:|---:|
| Selected marker opacity | 0.00 | 0.12 | 0.12 |
| Active era opacity | 0.00 | 0.15 | 0.15 |
| Context label opacity | 0.00 | 0.14 | 0.14 |
| First connector, two-label transformation | 0.14 | 0.30 | 0.44 |
| Change label, two-label transformation | 0.44 | 0.18 | 0.62 |
| First connector, three-label transformation | 0.14 | 0.20 | 0.34 |
| Change label, three-label transformation | 0.34 | 0.18 | 0.52 |
| Second connector/spacing, three-label transformation | 0.52 | 0.12 | 0.64 |
| Additional/retained result | 0.64 | 0.18 | 0.82 |
| Incoming documentary photo | 0.00 | 0.20 | 0.20 |
| Incoming contextual portrait | 0.62 | 0.20 | 0.82 |
| Outgoing media, when switching to actual media | 0.00 | 0.20 | 0.20 |
| Explanation and source basis | 0.78 | 0.16 | 0.94 |
| Early Mission Historical Note | 0.84 | 0.16 | 1.00 |

The second connector is a plus for 1928, an arrow for Early Mission, and an
undrawn space for the retained/qualified results in 1898 and 1954. Outgoing
media clears immediately when entering a transformation-only state. Shell
opening/closing uses a separate restrained 160 ms fade.

## J. Cancellation and rapid switching

Every selection kills the preceding Tween and restores opacity/scale before
starting the latest reveal. Completion callbacks cannot overwrite selection.
Reset, close, parent hiding, tree exit and opening Sources also settle or cancel
active presentation. Rapid 1928 → 1945 → 1981 → 1933 → 1954 switching was checked
for exactly one selected marker, correct era, latest media/content/note,
stopped narration and killed prior tweens. All checks passed.

## K. Transformation-only states

Early Mission, 1898, 1954 and 1981 intentionally use the full visual stage for
their diagrams. They show no image slot, “image pending” message, fabricated
photo or portrait. Historical explanation remains in the adjacent detail area.

## L. Contextual portrait states

1928 uses Guerrero, 1933 uses Sheehan, and 1963 uses Madriaga. Their existing PNGs
are referenced directly. The portrait area takes approximately 30% of the
visual stage; the institutional transformation remains primary. Images use
aspect-preserving containment with captions and exact source credits below.
No portrait biography wall or photo of an unsupplied historical event was added.

## M. 1945 documentary-photo state

The existing wartime/postwar damage photograph is contained without cropping or
distortion in approximately 65% of the stage. Its 200 ms fade accompanies the
restrained prewar → wartime damage diagram. No explosions, flashes, destruction
simulation or fabricated before-photo was introduced. The supplied explanation
retains the distinct residence damage, partial church destruction and fallen
bells; the photo's caption remains wartime/postwar rather than claiming it
depicts the exact January 9 event.

## N. Existing reused assets

All paths below are existing repository assets; none were copied or rewritten.

| Use | Repository path |
|---|---|
| Overview | `assets/landmarks/lingayen_church/lc_ext_01/images/lc_ext_01_exterior_current.jpg` |
| 1928 | `assets/landmarks/lingayen_church/lc_int_01/images/lc_int_01_guerrero_portrait.png` |
| 1933 | `assets/landmarks/lingayen_church/lc_int_01/images/lc_int_01_sheehan_portrait.png` |
| 1945 | `assets/landmarks/lingayen_church/lc_ext_03/images/lc_ext_03_church_postwar_damage.jpg` |
| 1963 | `assets/landmarks/lingayen_church/lc_int_01/images/lc_int_01_madriaga_portrait.png` |

No LC-INT-02 image directory or duplicate asset was created. All five resource
references load. Runtime null-media checks preserve a safe detail/diagram and
show “DOCUMENTARY IMAGE / SOURCE UNAVAILABLE” only when expected media is absent.

## O. Exact asset credits

| Use | Displayed credit |
|---|---|
| Overview | PHOTO: AKAR Research Team, 2026 |
| 1928 | SOURCE: Lingayen: Memories of Times Past (2021), p. 16. |
| 1933 | IMAGE SOURCE: Missionary Society of St. Columban — Philippines |
| 1945 | SOURCE: Lingayen: Memories of Times Past (2021), p. 20. |
| 1963 | SOURCE: Lingayen: Memories of Times Past (2021), p. 17. |

## P. Rights and provenance

Credits and supplied provenance are carried forward without claiming a new
license or permission. The Sheehan resource retains: “Source/identity verified
by the research team. Reuse/permission status remains subject to project
documentation.” Existing book-page references remain pages 16, 17 and 20.
No external image acquisition or AI image generation occurred.

## Q. Narration

LISTEN is visible, disabled, and accompanied by “Narration pending.” Every
supplied narration resource is null; no transcript, recording or generated voice
was added. The optional resource field and inherited player remain usable for
future authorized audio. Tests temporarily inject an in-memory stream to verify
that selection changes and closing stop playback; the shipped resource stays null.

## R. Sources

The inherited overlay displays supplied source groups and bibliographic caveat.
Opening it settles the reveal and preserves selected year, era, media and
interpretation. Keyboard focus stays within the overlay; Escape closes Sources
first, then the hotspot on a later press. Closing Sources returns focus to its
trigger. No new modal framework or external link behavior was introduced.

## S. Reset and reopen

Fresh open/reset restores NONE, neutral markers/eras, the present-day exterior
overview, overview heading/body/credit, no Historical Note, closed Sources,
stopped audio and top reading position. Focus starts at the first timeline point
without selecting it. Active tweens are killed and opacity/scale restored.
Reopening during a close fade and hiding the parent were tested.

## T. Mouse

Whole timeline-point hit regions, including their corners, select the matching
state. Sources, Close Sources and Close work. Internal reading panels handle
wheel input. No input lock exists during reveal; rapid switching passed.

## U. Keyboard

Tab/Shift+Tab follow the shared focus cycle and skip disabled LISTEN. Left/Right
move timeline focus without selecting or wrapping past either end. Enter/Space
select the focused point. Focus has a bright outline distinct from the gold
selected year/dot. Reading areas support keyboard scrolling. Sources traps focus;
Escape follows the safe modal-first, hotspot-second close behavior.

## V. Touch

Synthetic Godot touch events exercised all eight dates, Sources, Close Sources
and Close successfully at all three test sizes. Timeline and main controls keep
at least 56 px height. Physical touch devices and exported browser input have
not been tested in this implementation pass.

## W. Responsive behavior

| Viewport | Result |
|---|---|
| 1280×720 | All dates and full normal interpretations, including the Early Mission note, fit; no whole-screen scroll or animation layout jump. |
| 960×540 | All eight dates and transformations remain visible; compact labels fit; longer detail text uses internal scrolling. |
| 854×480 | Whole-point targets remain usable; diagrams remain visible, photos/portraits preserve aspect, captions/credits fit; longer interpretation uses internal scrolling. |

The standalone preview uses the existing 5% inset host pattern, so layout checks
exercise a component smaller than the full viewport. The visual/detail split
stays approximately 60/40. Compact diagram labels wrap to available width;
fixed print line breaks are removed only in compact presentation. Sources has
its own internal scroll. Pixel-art project/stretch/render settings are untouched.

## X. Accessibility

Accessible names describe each date/milestone and media; selected state and
focus remain distinct. Transformation words and detail-era text accompany color
changes, so color alone does not convey historical change. Controls remain
available during animation and final information persists indefinitely.

No existing reduced-motion helper was found. The local exported
`animate_reveals = false` host option presents identical final content immediately
without introducing a global preference. Tests cover every state with this option.
Actual screen-reader output and browser accessibility remain manual validation.

## Y. Automated tests

Final results after the connector-layout correction:

- Headless: **7,459 checks, 0 failures**.
- Rendered Compatibility: **7,500 checks, 0 failures**.
- Rendered run additionally wrote 41 captures: preview, overview, eight states
  and Sources at each of three sizes; three 1954 animation stages; five missing
  media cases. Counts are assertions across repeated states, not distinct tests.

Coverage includes exact researcher copy, enums/state/era mappings, resource
paths/credits, sole selection authority, eight whole-point buttons, all three
media modes, 1710 exclusivity, Sources preservation during reveal, focus/input,
synthetic touch, viewport bounds, text/diagram containment, portrait allocation,
photo aspect, real Tween staged timing, cancellation, stable ribbon geometry,
reset, parent hide, close/reopen, instant-reveal option and narration cleanup.

Run from repository root with the Godot 4.7.2 executable:

```powershell
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --headless --path . --script res://tests/lc_int_02_test.gd --quit-after 9000
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --rendering-method gl_compatibility --path . --script res://tests/lc_int_02_test.gd --quit-after 9000 -- --capture
```

Evidence in `C:\Users\Admin\AppData\Local\Temp`:

- `akar_lc_int_02_headless_final.log`
- `akar_lc_int_02_render_final.log`
- `akar_lc_int_02_import_final.log` (clean import/reference/syntax pass)
- `lc_int_02_<width>_<state>.png`, widths 1280/960/854, states preview, overview,
  1500s, 1898, 1928, 1933, 1945, 1954, 1963, 1981, sources.
- `lc_int_02_1280_1954_reveal_context.png`, `_change.png`, `_final.png`.
- `lc_int_02_1280_fallback_0.png`, `_3.png`, `_4.png`, `_5.png`, `_7.png`.

Representative final and intermediate captures were visually inspected in
addition to automated geometry checks. Desktop checks do not replace researcher
F6 review or an exported-web/physical-device test.

## Z. Regression results

| Unchanged component | Result |
|---|---|
| LC-EXT-01 | 0 failures |
| LC-EXT-02 | 0 failures |
| LC-EXT-03 | 0 failures |
| LC-INT-01 | 5,065 checks, 0 failures |
| LCH-EXT-01 (representative Limahong) | 0 failures |

Logs use `%TEMP%\akar_lc_int_02_regression_<component>.log` with lowercase
component names and underscores. No regression component or test was edited.

## AA. Environment warnings

Sandboxed runs reported `Failed to read the root certificate store.` The
rendered run also reported `Can't create shader cache folder, no shader caching
will happen: user://`. These environment messages did not fail assertions or
prevent rendering. Final logs contain no GDScript parse/runtime errors or leaked
object diagnostics. No project setting was changed to suppress the warnings.

## AB. Exact F6 researcher checklist

1. Open this existing project in Godot 4.7.2. Open
   `res://scenes/landmarks/lingayen_church/interior/lc_int_02_preview.tscn`.
   Press **F6** (Run Current Scene), not F5. Use a 1280×720 viewport.
2. Review the neutral development preview, then click **Explore the Timeline**.
   Confirm current-photo overview, all eight dates, neutral eras, disabled
   LISTEN/Narration pending, Sources and Close. No year should be selected.
3. Select **1500s**. Confirm **16th Century** detail, stepped early mission →
   Augustinian → later Dominican succession, and the supplementary 1710 note.
4. Select **1898**. Confirm the qualified transition toward Filipino diocesan
   clergy; no direct claim of an immediate transfer and no 1710 note.
5. Select **1928**. Judge whether parish church → cathedral **plus episcopal
   seat** reads clearly before all prose; Guerrero is supporting context.
6. Select **1933**. Confirm Columban service begins, contextual Sheehan portrait,
   caption and exact image credit.
7. Select **1945**. Confirm respectful documentary treatment, intact image
   aspect, prewar → wartime damage, and supplied damage wording/credit.
8. Select **1954**. Confirm both seat transfer to Dagupan and Lingayen's
   retained co-cathedral role remain visually clear and visible together.
9. Select **1963**. Confirm diocese → metropolitan archdiocese is primary and
   Madriaga's portrait is supporting evidence.
10. Select **1981**. Confirm Columban administration → continuing Filipino
    diocesan leadership without an invented portrait/photo.
11. Open **Sources**, scroll through all supplied groups, close it and confirm
    the selected date, era and content persist. Repeat while a reveal is running.
12. Rapidly select 1928 → 1945 → 1981 → 1933 → 1954. Confirm newest state wins,
    no stale portrait/note remains and input is never blocked.
13. Tab through controls; move focus with Left/Right; select with Enter/Space.
    Confirm focus differs from selection. Escape closes Sources before the
    hotspot. Close and reopen: overview/neutral states must return.
14. Resize the running preview viewport to **960×540**, then **854×480**.
    Repeat Early Mission, 1928, 1933, 1945, 1954, 1963 and Sources. Confirm
    diagrams/dates/credits fit, controls remain usable, and only internal
    interpretation/Sources scrolling is needed. Verify viewport dimensions in
    the editor's running-game controls; window decorations are not viewport size.
15. Optionally run the component scene directly with F6, and temporarily disable
    `animate_reveals` on the selected component in the Remote inspector to review
    instant final content. Do not save unrelated project setting changes.

Central review question: **Can a visitor understand WHAT CHANGED from selected
year, active era, transformation animation and documentary/contextual evidence
before reading every sentence?** Record researcher observations; do not substitute
passing layout assertions for this judgment. No visitor timing or learning gain
was measured. Stop at this review; do not begin the next milestone.

## AC. Git status before and after

Before implementation, HEAD was `65f8804` (`feat: implement Lingayen Church
LC-INT-01 people hotspot`) and the index was empty:

```text
 M project.godot
?? docs/references/
```

Exactly nine authored files were added:

```text
data/landmarks/lingayen_church/lc_int_02.tres
scenes/landmarks/lingayen_church/interior/lc_int_02.tscn
scenes/landmarks/lingayen_church/interior/lc_int_02_preview.tscn
scripts/landmarks/lingayen_church/lc_int_02.gd
scripts/landmarks/lingayen_church/lc_int_02_content.gd
scripts/landmarks/lingayen_church/lc_int_02_milestone_content.gd
scripts/landmarks/lingayen_church/lc_int_02_timeline_point.gd
tests/lc_int_02_test.gd
docs/lc_int_02_testing.md
```

Godot also generated five corresponding `.gd.uid` sidecars for the four new
scripts and the test. After implementation, these 14 new files are untracked;
the pre-existing `project.godot` modification and `docs/references/` remain.
No pre-existing file was modified by this implementation. A SHA-256 baseline
of all 400 pre-existing nonignored files is retained in
`%TEMP%\akar_lc_int_02_baseline.json`; final comparison found zero changes.
`git diff --check` and whitespace checks on each new file passed.

## AD. Source images and project settings unchanged

All five reused images and every other baseline file remain byte-for-byte
unchanged. No image duplication, conversion, editing or generation occurred.
`project.godot` retains the user's pre-existing modification exactly; this
implementation did not touch it. `docs/references/` was also preserved exactly.

## AE. Nothing staged

`git diff --cached --name-only` is empty. No staging was performed.

## AF. No commit

No commit was made. HEAD remains `65f8804`.

## AG. No push

No push or other repository publication was performed. Implementation stops
here pending researcher F6 visual review.


## 2026-10-01 — Casa Real utility header and narration revision

**Narration is activated with researcher approval.** The identical temporary
recordings are intentional and are not a defect or activation blocker.

Current narration assets are intentionally temporary and may contain the
same recording. Each hotspot already uses its permanent hotspot-specific
audio path so that final narration can later be substituted by replacing the
corresponding .ogg file without changing code or resource mappings.

### Actual audio audit

- Hotspot: **LC-INT-02**
- Existing file: `res://assets/landmarks/lingayen_church/audio/lc_int_02_narration.ogg`
- Size: 288,586 bytes; Godot type: AudioStreamOggVorbis; duration: 21.0 seconds.
- Existing `.ogg.import` metadata is present; loop is false.
- SHA-256: `5E44ADB87270F4DC7586CF026902718C597544C394376FC0FDEFE1E38FA4BD44`.
- Assigned resource slot: `narration_stream (inherited from ConferenceRoomContent)` in `data/landmarks/lingayen_church/lc_int_02.tres`.
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

The old takeaway/Sources HBox was removed. The full-width takeaway uses its natural height, allowing the Time Window and interpretation to expand without moving the era strip or eight-point timeline.

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
