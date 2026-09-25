# LC-EXT-03 — Historic Bells and the 1945 Destruction

Phase 5 implementation report, 25 September 2026. Automated and rendered checks
passed. Researcher F6 visual review and physical-device review remain pending.

## 1. Scope

Standalone museum-oriented interpretation with three direct story points, changing
media, documentary evidence and a two-button comparison confined to the wartime
state. No general church timeline, architecture markers, forced sequence,
completion tracking, game features or master-landmark navigation.

Inspected before implementation: `AGENTS.md`; shared
`conference_room_interaction.tscn`/`.gd` and content/concept resources; LC-EXT-01
component, resource pattern, header, Sources, reset and neutral preview/sizing
script; LC-EXT-02 component, resource, scene, preview, tests and documentation;
Limahong `lch_ext_01` shell, transition/input and preview conventions.

The component inherits `ConferenceRoomInteraction` and keeps `_selected` as the
single main state, exposed by `StoryState` and `set_story_state()`:
Overview, Historic Bells, Wartime 1945, Heritage Today. `_wartime_view` is the
separate local comparison state: Postwar Damage or Present Day. The inherited
buttons become a substantial bottom story row; no tabs in the interpretation
column and no markers on the photographs. All text/media mapping is resource-driven.

Public API: `open_hotspot()`, `close_hotspot()`, `reset_hotspot()`,
`set_story_state()`, `get_story_state()`, `set_wartime_view()`, `get_wartime_view()`.
Signals: `hotspot_closed`, `story_state_changed`, `wartime_view_changed`, plus
inherited shell signals. The inherited audio field accepts one future narration.

Exact authored files created:

```text
scripts/landmarks/lingayen_church/lc_ext_03.gd
scripts/landmarks/lingayen_church/lc_ext_03_content.gd
scripts/landmarks/lingayen_church/lc_ext_03_story_point.gd
scenes/landmarks/lingayen_church/exterior/lc_ext_03.tscn
scenes/landmarks/lingayen_church/exterior/lc_ext_03_preview.tscn
data/landmarks/lingayen_church/lc_ext_03.tres
tests/lc_ext_03_test.gd
docs/lc_ext_03_testing.md
```

Generated metadata: `.gd.uid` sidecars for the three new scripts and test, and
`.import` sidecars for each of the six supplied LC-EXT-03 images listed below.
The existing LC-EXT-01 preview sizing script is reused unchanged. No existing
source, image or project files were modified. No duplicate present-day church
photograph or new audio was created.

## 2. Historical boundary

The interpretive copy preserves the researcher-approved statements: the January 9,
1945 liberation bombing greatly damaged the bishop's residence and partially
destroyed the church; accounts record that old bells fell. Current displayed
bells are not identified as proven to be those specific fallen bells. Their exact
identity and dates remain subject to historical confirmation.

No casting dates, original-Spanish-bell attribution, military unit/weapon/aircraft
details or unsupported prewar/postwar architectural identification was added.
The damage image is captioned as showing wartime/postwar damage, without claiming
it was photographed on the exact day of the bombing.

## 3. Asset inventory

All six original images existed before implementation under
`assets/landmarks/lingayen_church/lc_ext_03/images/`:

| Actual filename | Dimensions | Use |
| --- | --- | --- |
| `lc_ext_03_bells_overview.jpg.JPG` | 2592 × 1728 | Overview / Heritage Today |
| `lc_ext_03_bell_display_detail.jpg.JPG` | 2592 × 1728 | Historic Bells |
| `lc_ext_03_bells_context.jpg.JPG` | 2592 × 1728 | Supplied optional fallback, unused |
| `lc_ext_03_church_postwar_damage.jpg` | 1000 × 941 | Postwar Damage comparison |
| `lc_ext_03_book_bell_fell_crop.png` | 1087 × 1332 | Wartime documentary evidence |
| `lc_ext_03_book_bells_display_crop.png` | 1024 × 1536 | Historic Bells evidence |

Filename differences from the request: the current photographs have `.jpg.JPG`
suffixes; both book crops are `.png`. Exact on-disk capitalization is retained.
No renaming or pixel changes. All five images used here were visually inspected.

The present-day comparison directly references the existing
`assets/landmarks/lingayen_church/lc_ext_01/images/lc_ext_01_exterior_current.jpg`.
The two pre-existing reference-page JPEGs in `docs/references/lingayen_church/`
are preserved and are not loaded into the visitor component. Godot-generated
import sidecars for those reference-only pages were removed after validation;
the original reference JPEGs were not touched.

## 4. Asset-role mapping

| State/view | Main media | Supporting evidence |
| --- | --- | --- |
| Overview | Bells overview | Hidden |
| Historic Bells | Bell display detail | Book bells display crop |
| 1945 / Postwar Damage | Church postwar damage | Book bell fell crop |
| 1945 / Present Day | Existing LC-EXT-01 current exterior | Same book bell fell crop |
| Heritage Today | Bells overview | Omitted to keep the historical note clear |

Every selected story updates media and interpretation. Overview and Heritage Today
intentionally share the approved overview photo; selected stories 1, 2 and 3 have
distinct main media. All images aspect-fit; none stretch or crop destructively.

## 5. Credits and source lines

Current team photographs: `PHOTO: AKAR Research Team, 2026`.

Damage image: `SOURCE: Lingayen: Memories of Times Past (2021), p. 20.`

Both documentary crops: `SOURCE: Lingayen: Memories of Times Past (2021), p. 30.`

Full supplied bibliography retained in the resource and Sources:

Arcinue, Arabela Ventenilla (Ed.), & Sicam, Paulynn Paredes. (2021). Lingayen:
Memories of Times Past. Lingayen, Pangasinan: Arabela Ventenilla Arcinue
(Self-published).

Each main image, caption and credit crossfade as one group. The outgoing image
retains its own caption/credit until its layer disappears. Documentary support
has its own separate caption/source line in the reading area; book imagery is
never credited as an AKAR Research Team photograph.

## 6. Preview

Open `scenes/landmarks/lingayen_church/exterior/lc_ext_03_preview.tscn` and press F6.
Neutral gray wrapper, title `Historic Bells and the 1945 Destruction`, development
label, supplied description/inset note and `Explore the Historic Bells` launcher.
No photographic background. Launcher calls the real `open_hotspot()`. Its content
hides while open and returns on close. Component uses a 5% inset parent frame.
Preview-only logical sizing follows actual client dimensions and restores the
host canvas policy on removal, without editing project settings.

## 7. Opening/reset

Every open resets Overview, clears selection, support, historical note and
comparison controls, resets the internal wartime view, closes Sources, stops
audio and replaces old tweens. Marker-free story control 1 receives keyboard focus
without being selected. Open is 180 ms; close is 160 ms. Closing restores focus
to the launcher. Reopen during closing, explicit reset during Sources, parent
hiding and removal during transitions are tested.

## 8. Overview

`A Material Link to 1945`, exact approved body, `Select a story point.` prompt,
approved takeaway and bells overview photo. No selected story, comparison,
documentary support or note. The main caption reuses the approved Heritage Today
caption rather than introducing an additional historical statement.

## 9. Historic Bells

`Bells of the Earlier Church`, exact approved body, display-detail photograph,
displayed-bells book crop, and separate photo/book credits. No historical note.
No particular present bell is identified as definitively one of the fallen bells.

## 10. January 9, 1945

`Wartime Destruction`, exact approved wording, Postwar Damage on fresh entry,
and book bell-fell evidence. The state remains active while comparing images.
The main photo's safe wartime/postwar caption is preserved.

## 11. Postwar Damage / Present Day comparison

Two 52 px-high buttons below main media, visible only in 1945. Direct selection
changes image, caption and credit only; interpretation, evidence and reading
position remain intact. The existing LC-EXT-01 photo is reused. Re-selecting the
already-active 1945 story preserves the sub-view; leaving and freshly entering
1945 resets Postwar Damage. Reset/reopen also restores that internal default.
No draggable slider, morph or separate comparison canvas.

## 12. Heritage Today

`What the Bells Tell Us Today`, exact approved body and overview photo. Optional
duplicate evidence is omitted so the note and takeaway remain the reading focus.
Comparison controls and old support metadata are cleared.

## 13. Historical Note

Only Heritage Today displays `HISTORICAL NOTE` and:
`The exact identity and dates of the currently displayed bells remain subject to historical confirmation.`
Subdued heritage panel with a thin muted-gold left edge, secondary type, no warning
or error styling. The complete note is reachable through local reading scroll.

## 14. Supporting evidence images

Book crops appear after the approved body in the interpretation scroll, with their
own captions and p. 30 credit. This placement preserves the main photo and fixed
controls at compact sizes. Image height is 144 px at reference size, 100 px at
960 × 540 and 80 px at 854 × 480. Evidence is not a selectable story or a new
sequence. It remains available by scrolling, including when initially below the
reading viewport. No evidence is shown in Overview or Heritage Today.

## 15. Sources

Shared modal layout, input consumption, Close and focus confinement; the local
focus chain includes the conditional comparison controls. Opening settles any
crossfade and preserves story, comparison, main image, support and note state.
Escape closes Sources first and restores Sources-button focus. Next Escape closes
the hotspot. Sources contains the supplied full bibliography and page references.
Source opening does not reset story or comparison.

## 16. Narration pending

Top-right LISTEN remains visible and disabled with `Narration pending.` below.
No autoplay, fake audio, per-story audio or transcript UI. One inherited narration
stream can be supplied later. Close/reset/hide/removal stop playback safely.

## 17. Keyboard

Focus order: Historic Bells → January 9, 1945 → Heritage Today → comparison buttons
when visible → reading scroll → Sources → Close. Disabled LISTEN is skipped.
Tab/Shift+Tab cycle; Left/Right move/clamp story focus without selecting;
Enter/Space activate. Focus outline differs from selected fill. Sources traps
focus in its own reading/Close controls.

Local reading and Sources areas handle Up/Down, Page Up/Down, Home and End while
focused. This was added after the initial test showed that focus alone did not
scroll the shared ScrollContainer. No shared component was changed. Navigation
Escape still uses the inherited viewport-handled-before-close path.

## 18. Mouse

Click story/comparison controls directly in any order. Mouse wheel scrolls the
interpretation area. No historical content depends on hover. The harness dispatches
actual mouse-button events for opening and selection.

## 19. Touch

Story controls are 56 px high; comparison controls 52 px; Sources, LISTEN and Close
56 px. One synthetic screen tap activates and persists selection. Synthetic touch
covers all stories, both comparison views, opening and close. Physical touchscreen
and exported Web behavior remain researcher/device checks; synthetic input is not
a substitute for that review.

## 20. Responsive 1280×720

58:42 media/interpretation allocation, 16 px inner margins, 24 px column gap,
28 px title, 24 px heading and 20 px body. Main photo and metadata stay outside
the interpretation scroll; full story labels span the bottom. Support height
144 px. Reference Overview photo renders approximately 597 × 398 px; the square
damage photo is approximately 359 × 338 px with comparison controls present.
Long reading content may scroll; no whole-screen scrolling or header collision.
Headless and rendered checks pass.

## 21. Responsive 960×540

Two columns retained, 8 px inner margins, 12 px column gap, 22 px title, 20 px
heading and 18 px body. Full story labels retained, support height 100 px.
Both comparison buttons and image credit remain readable. Reading scroll exposes
all evidence/note/takeaway content. Headless and rendered checks pass.

## 22. Responsive 854×480

Two columns and readable 18 px body remain. Story labels shorten to BELLS / 1945 /
TODAY while accessible names remain full. Support height reduces to 80 px.
Main Overview image is approximately 321 × 214 px; the square wartime damage image
is smaller (approximately 168 × 158 px) to retain its full photograph, caption,
source line and 52 px comparison controls without overlap. This compact wartime
composition is specifically included in researcher F6 review. No whole-screen
scrolling; longer body, evidence, note and takeaway use the internal reading area.
Headless and rendered checks pass.

## 23. Historical-safety checks

All historical prose remains in `lc_ext_03.tres`. Tests compare the four headings
and bodies, takeaway, note, main/support captions and credits against approved
wording. Exclusion checks cover unsupported bell identity/casting claims, dates
and military detail. No source metadata was invented and no image pixels changed.

## 24. Regression and technical results

Godot 4.7.2, Compatibility/OpenGL 3.3 rendered on Intel UHD Graphics.

| Check | Result |
| --- | --- |
| Headless Godot import | Passed |
| Standalone component load | Passed |
| Standalone preview load | Passed |
| LC-EXT-03 headless at all three sizes | Zero failures |
| LC-EXT-03 rendered at all three sizes | Zero failures |
| Live resize with active Present Day comparison | Passed |
| LC-EXT-01 regression, all three sizes | Zero failures |
| LC-EXT-02 regression, all three sizes | Zero failures |
| LCH-EXT-01 regression, all three sizes | Zero failures |
| Git and new-file whitespace checks | Passed |
| SHA-256 audit of 358 pre-existing files | All unchanged |

Harness covers exact content/attribution, direct 1945 → Bells → Today → 1945 input,
40 rapid story changes, 50 rapid comparison changes, intermediate crossfade/credit
pairing, keyboard focus/scrolling, modal confinement, reset/close cancellation,
invalid selections, hidden-parent/removal cleanup and host canvas restoration.

Run from the project root (substitute your Godot executable):

```powershell
godot --headless --path . --editor --import --quit
godot --headless --path . res://scenes/landmarks/lingayen_church/exterior/lc_ext_03.tscn --quit-after 12
godot --headless --path . res://scenes/landmarks/lingayen_church/exterior/lc_ext_03_preview.tscn --quit-after 12
godot --headless --path . --script res://tests/lc_ext_03_test.gd
godot --path . --rendering-method gl_compatibility --script res://tests/lc_ext_03_test.gd -- --capture
godot --headless --path . --script res://tests/lc_ext_01_test.gd
godot --headless --path . --script res://tests/lc_ext_02_test.gd
godot --headless --path . --script res://tests/lch_ext_01_test.gd
git diff --check
git status --short
```

Logs: Windows TEMP `akar_lc_ext_03_import.log`, `_import_final.log`, `_scene.log`,
`_preview.log`, `_test.log`, `_render.log`, `_regression_lc01.log`,
`_regression_lc02.log`, `_regression_lch01.log`.
Captures: `lc_ext_03_<width>_preview.png`, `_overview.png`, `_story<1-3>.png`,
`_story<1-3>_reading.png`, `_wartime<0-1>.png`, `_sources.png` in TEMP. Captures
include all states at every target size; representative views at each size were
visually inspected, including the compact reading/Sources and preview layouts.

Git before implementation: no staged files; latest commit `8aa1231` (LC-EXT-02).

```text
 M project.godot
?? assets/landmarks/lingayen_church/lc_ext_03/
?? docs/references/
```

Git after implementation:

```text
 M project.godot
?? assets/landmarks/lingayen_church/lc_ext_03/
?? data/landmarks/lingayen_church/lc_ext_03.tres
?? docs/lc_ext_03_testing.md
?? docs/references/
?? scenes/landmarks/lingayen_church/exterior/lc_ext_03.tscn
?? scenes/landmarks/lingayen_church/exterior/lc_ext_03_preview.tscn
?? scripts/landmarks/lingayen_church/lc_ext_03.gd
?? scripts/landmarks/lingayen_church/lc_ext_03.gd.uid
?? scripts/landmarks/lingayen_church/lc_ext_03_content.gd
?? scripts/landmarks/lingayen_church/lc_ext_03_content.gd.uid
?? scripts/landmarks/lingayen_church/lc_ext_03_story_point.gd
?? scripts/landmarks/lingayen_church/lc_ext_03_story_point.gd.uid
?? tests/lc_ext_03_test.gd
?? tests/lc_ext_03_test.gd.uid
```

No staging, commit or push. Modified `project.godot`, original photographs,
reference JPEGs and all other pre-existing work are unchanged.

## 25. Known environment warnings

Sandboxed runtime checks report inability to read the Windows root certificate
store. Rendered checks also report unavailable `user://` shader caching. These
messages did not fail the interaction tests. Import used normal editor-cache
access. The unchanged Limahong harness reported two ObjectDB instances leaked at
exit after zero failures. No unrelated environment or project workarounds added.

## 26. Manual researcher F6 checklist

1. Open `scenes/landmarks/lingayen_church/exterior/lc_ext_03_preview.tscn`, press F6,
   and activate `Explore the Historic Bells`.
2. Check Overview, no selected story, no comparison/support/note, correct image,
   prompt, pending narration and photo credit.
3. Select 1945 → Bells → Today → 1945. Compare exact wording, main images and
   provenance. Scroll the interpretation area to documentary crops and credits.
4. In 1945, tap Postwar Damage / Present Day repeatedly. Confirm only main media,
   caption and credit change. Leave/re-enter 1945 and verify Postwar Damage.
5. In Heritage Today, read the complete historical note and takeaway. Verify
   nothing identifies a currently displayed bell as proven to be a fallen bell.
6. Open Sources from Present Day; Escape once preserves the comparison, Escape
   again closes the hotspot. Reopen and verify Overview and internal reset.
7. Rapidly alternate story/comparison controls and close/reopen during fades.
   Check for stale images, credits, support, note or selection.
8. Tab/Shift+Tab; use Left/Right among stories and Enter/Space to activate. Focus
   the reading area and use Up/Down, Page Up/Down, Home/End. Confirm visible focus
   differs from selected fill and Sources confines focus.
9. Repeat at 1280 × 720, 960 × 540 and 854 × 480, including live resize while
   Present Day is active. Use a separate run window if the editor embeds the view.
   Inspect the smaller compact wartime photo and scrollable support/note content.
10. Check physical touch when available; final Web export/canvas/device testing
    remains separate from desktop synthetic input.

- [ ] Neutral preview and real launcher work.
- [ ] Shared AKAR shell, header, LISTEN/Close and Sources match established style.
- [ ] Overview and all three story points show exact approved media/text.
- [ ] Free selection, no sequence, tracking or game features.
- [ ] 1945 comparison and fresh-entry default work.
- [ ] Present Day reuses the existing LC-EXT-01 image.
- [ ] Documentary evidence and p. 30 credits are readable by local scrolling.
- [ ] Main photo/source credit changes correctly, including during fades.
- [ ] Heritage Today note is complete, readable and subdued.
- [ ] No unsupported historical identity or casting-date claims.
- [ ] Sources preserves state and Escape hierarchy is correct.
- [ ] Rapid input, reset/reopen and return-to-launcher focus are stable.
- [ ] LISTEN disabled, pending status visible, no transcript.
- [ ] Mouse, keyboard and physical touch reviewed.
- [ ] 1280 × 720 accepted.
- [ ] 960 × 540 accepted.
- [ ] 854 × 480 compact media and local reading layout accepted.
- [ ] No unintended clipping, distortion or whole-screen scrolling.
- [ ] Original images and unrelated repository work preserved.

Stop for researcher F6 review. Do not start LC-EXT-04 or commit without approval.

## INTERACTIVITY REVISION

This revision supersedes the earlier presentation details above. The four story
states, historical paragraphs, comparison behavior, credits, Sources, narration,
reset/reopen and neutral preview remain intact. Researcher visual approval of this
revision is pending.

Exact files modified (no new files):

```text
scripts/landmarks/lingayen_church/lc_ext_03.gd
data/landmarks/lingayen_church/lc_ext_03.tres
tests/lc_ext_03_test.gd
docs/lc_ext_03_testing.md
```

Before editing, re-read `AGENTS.md` and inspected the shared interaction shell,
Sources/focus/input lifecycle, LC-EXT-02 normalized observation-marker pattern,
and the existing LC-EXT-03 implementation/resource/tests. Shared components,
other hotspots, scenes, preview, resource scripts and UID files are unchanged.

### Connected evidence points

The three original buttons retain their direct state mapping and 56 px hit
height. Each now displays a 24 px circular evidence point and separate label.
Two thin muted-gold connector lines are decorative, ignore pointer input and
never change color to imply progress. Selected nodes have a filled cream point
and stronger label; keyboard focus uses a separate rounded outline around the
full button. There are no numbers, completion states, locks or required order.
Compact labels are BELLS / 1945 / TODAY; accessible labels remain full.

The 1945 buttons retain their rectangular sub-control styling and now have an
explicit COMPARE label, clearly separate from the main story path.

### Direct bell observation

Historic Bells uses a cached AtlasTexture of the existing display-detail photo.
Its normalized source crop is `(0.24, 0.52, 0.76, 0.42)`: less roof and foreground,
with bells, fence and outdoor display context retained. Pixels are not edited,
objects are not removed, and no new image files are generated.

Two 32 px circular A/B symbols sit inside 56 × 56 px Button targets. A persistent
legend reads `A Bell Display` and `B Surface Details`; these full names are also
the accessible button labels. Labels do not require hover.

| Observation | Center relative to fitted crop | Focus rectangle relative to crop |
| --- | --- | --- |
| Bell Display | (0.78, 0.34) | (0.08, 0.03, 0.90, 0.91) |
| Surface Details | (0.25, 0.62) | (0.12, 0.40, 0.20, 0.51) |

One `BellObservation` enum (NONE / DISPLAY / SURFACE_DETAILS) controls selection
and the single thin gold frame. Geometry follows the aspect-fitted image, not
the screen or letterbox area. Selection changes only visual focus; no inscriptions,
dates or bell identities are interpreted. Updates are immediate and settle any
active media transition, avoiding queued observation animations.

Leaving Historic Bells resets NONE and hides the frame/markers; returning starts
at NONE. Reopen/reset also clears observation. Sources and documentary detail
preserve the current observation while preventing background input changes.

### Documentary evidence card and detail

At 1280 × 720, the card sits below the interpretation and above Sources, outside
the reading scroll. It uses a bordered heritage surface, a 128 × 156 px aspect-fit
image area, caption, original p. 30 source line and 52 px View Source Detail button.
The Historic Bells portrait renders 156 px high. This replaces the earlier tiny
preview embedded between text blocks.

The only approved content change is the Historic Bells supporting caption:

`Book source showing the historic bells on display.`

View Source Detail opens an inset-sized nested documentary overlay with a much
larger full image, caption and source credit. It introduces no page navigation.
Keyboard focus is confined to Close Detail; Escape closes this view before any
hotspot close, restoring focus to its trigger. Story, comparison and observation
states remain unchanged. Sources retains its own Sources-first Escape behavior.
Reset/close/hide clears the documentary view. Its source photograph is displayed
as supplied, without adding interpretations of visible markings.

### Reference-size readability and compact layouts

At 1280 × 720, a separate horizontal takeaway footer frees space for the card and
paragraph. The reading area uses 18 px body text and 22 px heading, tighter gaps
and a 156 px evidence preview. Historic Bells passes a visible-scrollbar assertion:
its entire heading/body fits without scrolling. The full card caption, credit,
button and takeaway remain visible, with no clipped source text. Sources and story
controls remain outside the reading area. The main media allocation stays 58:42.

At 960 × 540 and 854 × 480, the card and takeaway return to the local reading flow;
the evidence image area reduces to 80 × 120 px. View Source Detail provides the
larger documentary view. Main media and observation targets retain usable space;
no whole-screen scrolling. The 854 layout uses compact story labels. Internal
scrolling is intentional for longer compact text/card content.

### Input and validation

Focus order: story points → bell observations in Historic Bells or comparison
buttons in 1945 → reading area → View Source Detail when available → Sources →
Close. Disabled LISTEN is skipped. Left/Right move within story/observation groups
without changing selection; Enter/Space activate. The detail trigger scrolls into
view when focused in a compact reading area. Existing reading keys remain.
Mouse clicks and single screen taps activate all controls. Observation edge taps
23 px from the center verify the hit area extends beyond the visible 32 px symbol.

| Revision check | Result |
| --- | --- |
| Godot 4.7.2 import | Passed |
| Standalone component / unchanged preview load | Passed |
| LC-EXT-03 headless, all three sizes | Zero failures |
| LC-EXT-03 Compatibility-rendered, all three sizes | Zero failures |
| Historic Bells at 1280: no reading scrollbar / full card metadata | Passed |
| Normalized marker/frame alignment and non-overlapping 56 px targets | Passed |
| Both observations, keyboard activation and synthetic touch edge taps | Passed |
| Rapid observation/story changes and leave/return reset | Passed |
| Documentary detail, Escape priority, focus confinement and state preservation | Passed |
| Live resize with Surface Details active | Passed |
| LC-EXT-01 regression, all three sizes | Zero failures |
| LC-EXT-02 regression, all three sizes | Zero failures |
| Limahong LCH-EXT-01 regression, all three sizes | Zero failures |
| Git and modified-file whitespace checks | Passed |
| Resource comparison against revision baseline | Only approved caption changed |
| Original image/reference/import hashes | Unchanged |

The new tests extend the existing suite, including 30 repeated observation →
1945 → Today → Bells cycles, original rapid story/comparison tests, source-detail
opening/closing at each size, and no unsupported 1874/1881/1929/identity prose.
Original main body/headings/note/takeaway and all credits remain exact-match tests.

Run the same commands in section 24. Current revision logs are in Windows TEMP
under `akar_lc_ext_03_revision_*`. Captures retain the existing names and add
`lc_ext_03_<width>_observation<1-2>.png` and
`lc_ext_03_<width>_story<1-2>_detail.png`. Reference Historic Bells, observation
frames at all sizes, compact detail and the other story states were visually
inspected. Final physical-touch/Web review remains a device/researcher check.

Certificate-store access and unavailable `user://` shader-cache messages remain
non-failing environment warnings. This revision's Limahong regression completed
without the earlier ObjectDB warning. No environment workaround was added.

### Repository preservation

Before revision: no staged files; `project.godot` was modified; LC-EXT-03
assets/data/scenes/scripts/tests/documentation and `docs/references/` were already
untracked. The complete short-status block in section 24 is also the revision's
before/after status: it is unchanged because these four files were already
untracked. No new tracked or untracked paths were added by the revision.

SHA-256 comparison against the 378-file revision baseline identifies only the
four listed files as changed. All original photos, reference pages, import/UID
metadata, other hotspots and `project.godot` are unchanged. The `.tres` matches
the original byte-for-byte after substituting only the requested caption.
No staging, commit or push occurred.

### Researcher F6 review

1. Open `scenes/landmarks/lingayen_church/exterior/lc_ext_03_preview.tscn`, press F6
   and activate Explore the Historic Bells.
2. At 1280 × 720, select Historic Bells. Check connected story points, unchanged
   historical paragraph, readable evidence card, visible source credit/takeaway
   and no normal reading scrollbar.
3. Tap A / Bell Display and B / Surface Details on the photograph. Inspect frame
   alignment, distinct selected/focus styles and unchanged interpretive wording.
4. Open View Source Detail; check the full documentary photo and p. 30 credit.
   Escape once returns to the same state and observation. Tab to the trigger and
   use Enter/Space; repeat with mouse and touch when available.
5. Rapidly select Display → Surface Details → 1945 → Today → Bells → Display.
   On returning to Bells, confirm no previous observation remains selected.
6. Test 1945's COMPARE controls, Sources, Escape hierarchy and close/reopen. Check
   Heritage Today's historical note remains unchanged and subdued.
7. Repeat at 960 × 540 and 854 × 480; scroll to the compact evidence card and use
   View Source Detail. Resize while Surface Details is active and verify alignment.

- [ ] Story controls read visually as connected evidence points.
- [ ] Story controls do not imply completion.
- [ ] Historic Bells includes direct image observation.
- [ ] Bell Display observation works.
- [ ] Surface Details observation works.
- [ ] Observation hotspots are touch friendly.
- [ ] Observation focus resets when leaving state.
- [ ] Book documentary evidence is large enough to understand.
- [ ] Source credit remains visible.
- [ ] 1280 × 720 has no clipped source caption.
- [ ] 1280 × 720 avoids unnecessary reading scroll.
- [ ] 960 × 540 remains usable.
- [ ] 854 × 480 remains usable.
- [ ] Historical wording unchanged except the explicitly requested caption.
- [ ] No source images modified.

Stop for researcher visual review. No other hotspot work, staging, commit or push.
