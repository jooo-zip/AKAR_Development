# LC-END-01 — What Lingayen Church Represents

> Current utility/audio behavior is documented in the 2026-10-01 revision below; earlier milestone results are historical.

## A. Component identity

Standalone Phase 5 Summary & Reflection hotspot for Lingayen Church. Implemented
and checked on 2026-09-26 using Godot 4.7.2, GDScript and Compatibility rendering.
Ready for researcher F6 visual review; that review has not yet occurred.
No master layout, LC-ENT-01, virtual candle or next milestone was implemented.

Inspected LC-EXT-01, LC-EXT-02, LC-EXT-03, LC-INT-01, LC-INT-02, LCH-EXT-01,
their relevant resources/controllers, shared shell, input/focus conventions,
preview scenes and existing tests. Reused the conference-room shell scene,
controller and content base, shared speaker icon and `lc_ext_01_preview.gd`
without modifying them. The inherited concept data/index is unused here;
the four-theme meaning map owns the interaction.

## B. Educational purpose

FACT → MEANING → REFLECTION. One stable church image connects four forms of
historical/cultural significance. Each theme pairs one supplied interpretation
with one meaning statement; the passive reflection question remains visible.
This is an intended educational presentation, not evidence of measured learning
effectiveness. The requested 8–12 second reading target has not been measured
with visitors. The study's acceptability focus remains unchanged.

## C. Content validation status

SOURCE-BACKED PROJECT CONTENT PREPARED FOR VALIDATION. No museum approval,
formal validation or final archival interpretation is claimed. Visitor copy
comes from the supplied request and lives in `lc_end_01.tres`. No additional
dates, biographies, definite parish founding year, devotional practices,
historical imagery or historical claims were invented. Bibliographic details
for historical/evangelization materials remain pending researcher documentation.

## D. Four-theme meaning model

| Position | Authoritative selection | Theme | Center context |
|---|---|---|---|
| Top left | HISTORICAL_ROOTS | Historical Roots | EARLY MISSIONARY ROOTS / LOS TRES REYES |
| Top right | CATHEDRAL_ROLE | Cathedral & Co-Cathedral | 1928 CATHEDRAL & EPISCOPAL SEAT / 1954 CO-CATHEDRAL |
| Bottom left | WAR_RECOVERY | War & Recovery | 1945 WARTIME DAMAGE / ↓ RECONSTRUCTION |
| Bottom right | LIVING_HERITAGE | Living Heritage | ACTIVE PARISH / + CO-CATHEDRAL TODAY |
| Center | NONE | Return to overview, not a fifth theme | ONE CHURCH / FOUR CONNECTED MEANINGS |

`selected_theme: ThemeSelection = ThemeSelection.NONE` is the sole authoritative
selection. `set_selected_theme()` cancels old presentation, establishes the new
state, renders final content, updates cards/connectors/context/audio/accessibility,
resets interpretation scroll, and then starts presentation. No per-card content
handlers or independently mutable connector/theme state exist.

## E. Exact visitor copy

**Title:** What Lingayen Church Represents

**Subtitle:** Summary & Reflection

**Prompt:** Select a theme to see what it reveals about Lingayen Church.

**Overview heading:** Four Meanings, One Historic Church

**Overview body:** Lingayen Church brings together centuries of religious
history, institutional change, wartime experience, and continuing community life.

**Overall synthesis (overview only):** Lingayen Church represents centuries of
religious history, institutional change, wartime experience, and continuing
community life. Its role has changed across time, but it remains an active
co-cathedral and an important part of Lingayen's heritage.

**Historical Roots — Centuries of Religious History**

Lingayen Church traces its history to early Catholic missionary activity in the
16th century and was historically known as Los Tres Reyes or the Three Kings Parish.

What it represents: A long religious history connected with the development of Lingayen.

**Cathedral & Co-Cathedral — A Changing Institutional Role**

Lingayen Church became the cathedral and episcopal seat of the Diocese of
Lingayen in 1928. After the episcopal seat moved to Dagupan in 1954, the church
retained its historical role as a co-cathedral.

What it represents: A church whose institutional role changed while its
historical significance continued.

**War & Recovery — History Marked by Wartime Change**

The church was partially destroyed during the 1945 liberation of Lingayen and
was later reconstructed. Surviving historical features continue to connect the
present church with its wartime past.

What it represents: A heritage site shaped by destruction, recovery, and
historical continuity.

**Living Heritage — A Historic Church Still in Use**

Lingayen Church is not only a historical site. It remains an active Roman
Catholic parish and co-cathedral serving the religious community of Lingayen.

What it represents: A connection between Lingayen's historical heritage and
continuing religious community life.

**Reflection:** What makes Lingayen Church both a historical landmark and a
living place of faith today?

The center contexts are exactly the words in section D; compact presentation
replaces fixed newlines with spaces and lets text wrap naturally. Compact
Cathedral card text is “Cathedral Role”; its full theme/detail wording remains.
Source basis is a compact resource field: Archdiocese historical materials and
Epiphany parish history for Roots/Cathedral; Epiphany parish history and the
established book pages 20/30 for War; Archdiocese Parishes and Epiphany parish
history for Living Heritage. Full source grouping is in the Sources overlay.

## F. Central-image reuse

The verified existing image is referenced directly:

`res://assets/landmarks/lingayen_church/lc_ext_01/images/lc_ext_01_exterior_current.jpg`

Credit: **PHOTO: AKAR Research Team, 2026**

The same photograph stays visible across every theme; no wartime-photo takeover
occurs. Display uses aspect-preserving containment and linear filtering for the
photograph only. No source file crop, recolor, conversion, duplicate or new image
directory was created. Shared pixel-art project filtering/settings are unchanged.

## G. Connector behavior

Four responsive Line2D connectors join card edges to the central control. Their
endpoints are recomputed from actual control geometry on resize. Neutral lines
use subdued heritage gray (`697261`, 1.5 px); the selected connector uses muted
gold (`dec787`, 3 px). At most one is emphasized; NONE leaves all four neutral.
Lines are supplemental: selected card, theme label, center context and meaning
statement convey the same connection. No static diagram asset was created.

## H. Theme-card behavior

Whole-card buttons remain simultaneously visible. The presentation-only helper
owns a wrapped title, normal/selected style, inherited focus ring and Button
activation. It stores no historical prose or selection model. Selection uses
muted gold fill/border/text; keyboard focus uses the separate bright outline.
There are no checkmarks, locks, stars, progress badges, glow or pulse. Existing
shared icons were inspected; none suited the four themes, so cards are text-only.

## I. Center return behavior

Click, tap, Enter or Space on the central church sets NONE. Cards/connectors
become neutral, overview interpretation/context returns, and reflection persists.
The center is not a toggle theme and retains the same media/identity frame.
Its tooltip/accessibility name is:
“Return to overview of what Lingayen Church represents”.

## J. Animation timing

All final data is rendered before animation; controls never lock.

| Presentation | Start | Duration | End |
|---|---:|---:|---:|
| Selected-card label emphasis | 0 ms | 140 ms | 140 ms |
| Selected connector emphasis | 40 ms | 200 ms | 240 ms |
| Center context fade | 80 ms | 160 ms | 240 ms |
| Incoming/outgoing interpretation crossfade | 120 ms | 200 ms | 320 ms |

Total perceived transition is **320 ms**. A clipped, noninteractive copy of the
previous interpretation fades out as new content fades in; this temporary copy
never owns historical state. It is removed at completion/cancellation. The
church image, reflection and layout geometry do not animate. Close uses the
established 160 ms fade; fresh open/reset presents overview immediately.

## K. Rapid-switch and cleanup behavior

Historical Roots → Living Heritage → War & Recovery → Cathedral Role passes:
only Cathedral card/connector, 1928/1954 context and corresponding interpretation
and meaning remain. Every selection kills/replaces the Tween and clears any old
outgoing copy. Sources opening, reset, close, parent hiding, resizing and tree
exit settle or cancel presentation. Tests also cover reopening during a close
fade, no layout movement, final opacity restoration and instant presentation.

## L. Reflection behavior

The exact passive question stays visible in the footer at all three tested
sizes. No text entry, response storage, submit control, answer checking,
prayer/intention collection or religious-data collection exists.

## M. No-completion confirmation

All four themes work immediately, in any order. No prerequisites, completion
tracking, selected-theme history, counters, unlocks, rewards or persistence were
introduced. The summary works when opened before any other hotspot.

## N. Narration

One shared LISTEN remains visible/disabled with “Narration pending.” No stream
is supplied, no autoplay occurs, and no transcript is displayed. The resource
has one optional `narration: AudioStream` for the overall summary; theme resources
contain no audio fields. Selection and close stop playback. Tests inject a
temporary in-memory stream to exercise future playback/cleanup; shipped audio
remains null.

## O. Sources

The existing AKAR overlay/focus/closing conventions are reused. Source groups
cover Historical Roots, Cathedral & Co-Cathedral, War & Recovery and Living
Heritage using established Archdiocese, Epiphany parish and book references.
The current-photo credit and pending bibliography caveat are included. No new
source URL, archival approval or license is claimed.

Sources opening settles any active crossfade and preserves theme, connector,
center, interpretation and reflection. Focus is trapped in the modal; Escape
closes Sources first and a subsequent Escape closes the hotspot. Close Sources
returns focus to its trigger. Inherited navigation marks viewport input handled
before emitting any signal that could remove the component.

## P. Mouse

Real Godot mouse events at card corners select the whole card. Center returns
to overview, Sources/Close Sources work, and reading panels support scrolling.
No historical information depends on hover. Final tests passed.

## Q. Keyboard

All 16 direction/position combinations were checked against the requested
2×2 spatial map. Arrows move focus only and clamp at edges. Enter/Space select;
Tab reaches the center, then skips disabled LISTEN to interpretation. Enter and
Space both activate overview from the center. Sources uses the inherited focus
trap and safe Escape hierarchy. Reading panels accept arrows, Page Up/Down and
Home/End. Focus remains visually distinct from selection.

## R. Synthetic touch

Synthetic InputEventScreenTouch checks passed for all four themes, center,
Sources, Close Sources and Close. Whole theme targets are at least 56 px high;
center and shared controls meet the minimum 56×56 target. No gesture beyond
single tap is required. Physical touch hardware/browser exports remain untested.

## S. Responsive results

The preview uses the existing 5% inset host, so the component is smaller than
the full test viewport. Map/interpretation stay approximately 60/40 throughout.

| Viewport | Result |
|---|---|
| 1280×720 | Four full-label cards, center photo/context, connectors, reflection and Sources fit. Overview and all four normal interpretations need no internal scroll. |
| 960×540 | Four compact cards, center and connectors remain visible. Longer interpretation uses internal scrolling. |
| 854×480 | All four 56 px-high cards and center remain accessible. Center context wraps within its frame; reflection/credit stay visible; interpretation uses internal scrolling. |

No whole-screen scrolling, tabs or carousel substitution. Missing-media states
were also checked at each viewport. Final geometry checks and representative
rendered screenshots confirm no center-context overflow or animation layout jump.

## T. Accessibility

Exact theme names are exposed as “Historical Roots — summary theme”, “Cathedral
and Co-Cathedral — summary theme”, “War and Recovery — summary theme”, and “Living
Heritage — summary theme”. Center has the return-to-overview accessible name.
Selected button state accompanies visual emphasis. Text and meaning statements
carry significance independently of connector color.

No existing reduced-motion helper was found. Local exported
`animate_transitions = false` supplies identical final content instantly without
introducing a global preference. Tests cover all five states with it disabled.
Actual screen-reader output and web accessibility need manual validation.

## U. Safe media fallback

With null center media, the center remains clickable and displays:

```text
LINGAYEN CHURCH
EPIPHANY OF OUR LORD
CO-CATHEDRAL PARISH
```

All themes/context/meaning/reflection remain functional. The unavailable-photo
credit is hidden. Fallbacks were tested through every state at all three sizes.
The real source image exists; no missing asset path remains to report.

## V. Asset provenance

Only the existing AKAR Research Team 2026 current exterior image is reused.
No source image was changed, duplicated, downloaded or generated. No additional
rights/license claim was introduced. Book references concern interpretation,
not new displayed book imagery. Optional theme icons were deliberately omitted.

## W. Automated tests and evidence

Final headless test: **4,471 checks, 0 failures**.

Final rendered Compatibility test: **4,498 checks, 0 failures**.

Counts are individual assertions across repeated states and sizes, not distinct
test cases. The rendered run adds 27 screenshot assertions: eight review states
at each viewport plus one missing-media capture per viewport. Coverage includes
exact copy, all states/media/context, exclusivity, direct switching, passive
reflection, absence of completion/input storage, real input, modal preservation,
Tween timing/crossfade cleanup, reset/reopen/hide, instant option, narration,
geometry and missing-media layout.

From the repository root, use the installed Godot executable:

```powershell
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --headless --path . --script res://tests/lc_end_01_test.gd --quit-after 9000
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --rendering-method gl_compatibility --path . --script res://tests/lc_end_01_test.gd --quit-after 9000 -- --capture
```

Logs in `C:\Users\Admin\AppData\Local\Temp`:

- `akar_lc_end_01_headless_final.log`
- `akar_lc_end_01_render_final.log`
- `akar_lc_end_01_import_final.log` (clean editor import/syntax validation)

Screenshots use `lc_end_01_<width>_<state>.png`, widths 1280/960/854, states
`preview`, `overview`, `theme_1` through `theme_4`, `center_return`, `sources`,
and `fallback`. The 1280 states, compact Cathedral/War/Living states and fallback
captures support review; screenshots do not replace researcher judgment.

## X. Regressions

| Unchanged component | Result |
|---|---|
| LC-EXT-01 | 0 failures |
| LC-EXT-02 | 0 failures |
| LC-EXT-03 | 0 failures |
| LC-INT-01 | 5,065 checks, 0 failures |
| LC-INT-02 | 7,459 checks, 0 failures |
| LCH-EXT-01 | 0 failures |

Each existing `tests/<component>_test.gd` was run headlessly. Logs are
`%TEMP%\akar_lc_end_01_regression_<component>.log`, with lowercase component
names and underscores. No regression component or test was edited.

## Y. Environment warnings

Sandboxed runtime logs report `Failed to read the root certificate store.`
Rendered runs also report `Can't create shader cache folder, no shader caching
will happen: user://`. The initial sandboxed editor import could not create its
normal Godot editor data/config/cache directories. A subsequent import with
normal cache access completed cleanly. Runtime warnings did not prevent rendering
or assertions; final logs contain no GDScript errors or object-leak diagnostics.
Project configuration was not changed to suppress these environment messages.

## Z. Exact F6 researcher review

1. Open this repository's project in Godot 4.7.2. Open
   `res://scenes/landmarks/lingayen_church/interior/lc_end_01_preview.tscn`.
   Press **F6 / Run Current Scene**, not F5. Start at a **1280×720 viewport**.
2. Review the development preview: title, LC-END-01 label, supplied description,
   inset-parent note and **Explore the Summary** button.
3. Open the component. Review overview: four neutral themes/connectors, stable
   central church, overview/synthesis, reflection, disabled LISTEN and Sources.
   Initial focus may outline Historical Roots without selecting it.
4. Select **Historical Roots**. Confirm missionary roots/Los Tres Reyes context,
   exact interpretation and meaning, with no definite founding date or timeline.
5. Select **Cathedral & Co-Cathedral**. Confirm compact 1928/1954 synthesis,
   the same photograph, and retained historical significance.
6. Select **War & Recovery**. Confirm damage/reconstruction synthesis without
   wartime-photo takeover, bell controls or dramatic effects.
7. Select **Living Heritage**. Confirm ACTIVE PARISH + CO-CATHEDRAL TODAY and
   the connection to continuing religious community life.
8. Click the **central church**. Confirm return to overview, neutral cards/lines,
   persistent reflection and unchanged photograph.
9. Select a theme, open **Sources**, scroll all groups, then close it. Confirm
   theme/context/connector/detail persist. Repeat opening Sources mid-transition.
10. Rapidly select Roots → Living Heritage → War → Cathedral. Confirm Cathedral
    alone remains selected, with its connector/context/meaning and no stale text.
11. Test arrows from each card, including clamped outer edges. Arrows move only
    focus. Enter/Space select. Tab to center and activate overview with Enter/Space.
    Escape closes Sources first and then the hotspot. Reopen: NONE must return.
12. Resize the actual game viewport to **960×540**, then **854×480**. Recheck all
    four themes, especially Cathedral's longer context, War, Living Heritage,
    reflection and Sources. Confirm central photo/cards/lines stay visible and
    only interpretation/Sources need internal scrolling. Window decorations do
    not count toward viewport dimensions; use the running-game sizing controls.
13. Optionally run `lc_end_01.tscn` directly with F6. The preview is preferred for
    repeatable responsive review because it uses the existing sizing helper.
    The local `animate_transitions` Remote-inspector option can demonstrate the
    same content without motion. Do not save unrelated project-setting changes.

Record researcher judgment on the five requested questions:

- Is ONE church connected to FOUR meanings clear before reading every paragraph?
- Does it feel like synthesis/reflection rather than an abbreviated timeline?
- Is the central church the clear anchor?
- Are connectors helpful and restrained?
- Does Living Heritage clearly express the continuing present-day role?

Stop after review; no visitor acceptance or learning result is inferred from
automated tests. Physical-device/exported-web verification remains separate.

## AA. Git status and exact inventory

Starting HEAD: `5d2085e` — `feat: implement Lingayen Church LC-INT-02 timeline hotspot`.
The index was empty. Starting status:

```text
 M project.godot
?? docs/references/
```

Exactly nine authored files were added:

```text
data/landmarks/lingayen_church/lc_end_01.tres
scenes/landmarks/lingayen_church/interior/lc_end_01.tscn
scenes/landmarks/lingayen_church/interior/lc_end_01_preview.tscn
scripts/landmarks/lingayen_church/lc_end_01.gd
scripts/landmarks/lingayen_church/lc_end_01_content.gd
scripts/landmarks/lingayen_church/lc_end_01_theme_content.gd
scripts/landmarks/lingayen_church/lc_end_01_theme_card.gd
tests/lc_end_01_test.gd
docs/lc_end_01_testing.md
```

Godot generated five `.gd.uid` sidecars for the four scripts and test. Final
status consists of these 14 new untracked files plus the two original unrelated
items. **No existing file was modified by this implementation.** All 414
pre-existing nonignored files match their SHA-256 baseline recorded in
`%TEMP%\akar_lc_end_01_baseline.json`. `git diff --check` and whitespace checks
for every new file passed. HEAD remains `5d2085e`.

## AB. Source image unchanged

The current exterior photograph and all other baseline source assets remain
byte-for-byte unchanged. No image assets or image directories were added.

## AC. Project configuration preserved

`project.godot` retains the user's original modification exactly. This milestone
did not change it. The existing `docs/references/` contents are also unchanged.

## AD. Nothing staged

`git diff --cached --name-only` is empty. No staging was performed.

## AE. No commit

No commit was made; HEAD remains the starting `5d2085e`.

## AF. No push

No push/publication was performed. Work stops here pending researcher F6 visual
review; no candle, master-layout, entrance or additional landmark work began.


## 2026-10-01 — Casa Real utility header and narration revision

**Narration is activated with researcher approval.** The identical temporary
recordings are intentional and are not a defect or activation blocker.

Current narration assets are intentionally temporary and may contain the
same recording. Each hotspot already uses its permanent hotspot-specific
audio path so that final narration can later be substituted by replacing the
corresponding .ogg file without changing code or resource mappings.

### Actual audio audit

- Hotspot: **LC-END-01**
- Existing file: `res://assets/landmarks/lingayen_church/audio/lc_end_01_narration.ogg`
- Size: 288,586 bytes; Godot type: AudioStreamOggVorbis; duration: 21.0 seconds.
- Existing `.ogg.import` metadata is present; loop is false.
- SHA-256: `5E44ADB87270F4DC7586CF026902718C597544C394376FC0FDEFE1E38FA4BD44`.
- Assigned resource slot: `narration` in `data/landmarks/lingayen_church/lc_end_01.tres`.
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

The reflection/Sources HBox was removed. Reflection is a full-width direct layout child at its natural height. The meaning map and interpretation reclaim the former utility footprint; four themes and center-return remain unchanged.

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
