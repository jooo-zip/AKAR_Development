# Lingayen Church — shared utility header and narration revision

Revision date: 2026-10-01. Scope: LC-EXT-01/02/03, LC-INT-01/02, LC-END-01.

**UI and saved narration activation are implemented.** The researcher explicitly
approved the identical temporary recordings on 2026-10-01. Their identical
hashes are intentional, not a defect. All six saved resources now use their
permanent hotspot-specific paths; LISTEN is enabled and pending text is hidden.

Current narration assets are intentionally temporary and may contain the
same recording. Each hotspot already uses its permanent hotspot-specific
audio path so that final narration can later be substituted by replacing the
corresponding .ogg file without changing code or resource mappings.

## Starting repository state

HEAD: `fe9e06b` — `feat: implement PPC-END-01 Capitol summary and reflection hotspot`.
The index was empty. Initial short status contained 51 modified entries and
13 untracked entries, including:

- `AGENTS.md` and `project.godot`;
- content resources across Casa Real, Limahong, Lingayen Church, Capitol and Urduja;
- Limahong controllers, tests, documentation and its summary preview;
- supplied Limahong/Church audio directories and `docs/references/`;
- existing untracked Limahong header/Sources helpers and tests.

The complete starting status is recorded in
`C:\Users\Admin\AppData\Local\Temp\akar_lc_header_start_status.txt`.
SHA-256 hashes of all 774 pre-existing nonignored files were recorded before
implementation in `akar_lc_header_baseline.json` in the same temporary directory.
No pre-existing Church historical content was reverted or rewritten. The later
authorized audio activation adds only an external AudioStream declaration and
the existing narration property to each of the six content resources.

## Casa Real inspection and exact reference

Inspected CR-EXT-01, CR-INT-03 and CR-END-01 scenes/controllers, plus the shared
conference-room scene/controller/content. Casa Real implementations differ:
CR-EXT-01 has older LISTEN/STOP behavior; CR-INT-03 and CR-END-01 use
LISTEN/PAUSE/RESUME. **CR-END-01 is this revision's behavioral and styling reference.**

Exact reference files:

- `scenes/landmarks/casa_real/end/cr_end_01.tscn`
- `scripts/landmarks/casa_real/cr_end_01.gd`
- `scenes/components/conference_room_interaction.tscn`
- `scripts/components/conference_room_interaction.gd`

Casa Real has no independent reusable toolbar helper: its controllers reparent
the existing buttons into the shared header. The actual reusable component is
the conference-room shell and its Theme/StyleBoxes. This revision keeps that
inheritance and introduces a Church-only adapter; no Casa Real, Limahong or
project-wide architectural change was made. The existing Limahong-only helper
was inspected but not changed or made a cross-landmark dependency.

### Hierarchy, anchors and metrics

Casa Real header: `Main/Margin/Layout/Header` (HBoxContainer) inside the shared
VBox/MarginContainer. Title expands horizontally; Sources, Speaker, Close are
container children, not separately anchored overlays. Casa Real's Main panel
uses a 5% inset, reduced to 2% in its compact layout. Church preserves its own
existing 5% preview frame instead of adding a second inset.

Church adaptation: title/subtitle remain at the left; a right-side utility VBox
contains `HeaderActions` (HBox with existing Sources/Speaker/Close) and the
missing-audio status label. Hidden status consumes no layout height. The old
ListenGroup is removed once empty. Header/action spacing inherits the same
shared/default HBox spacing (4 px). No manual anchors/offsets are required for
these container-managed actions.

CR-END-01 dimensions reused: 52 px button height; 18 px button font at wide sizes,
16 px below 1100 component pixels; 22 px speaker icon; title 28/22 px. Base
minimum widths remain 48 px for Sources/Close and 56 px for Speaker, with natural
text expansion. Speaker additionally reserves the measured width of RESUME +
22 px icon + theme separation/margins, because `expand_icon` otherwise allows
Godot to shrink the icon away. The compact title/subtitle gap is reduced from
4 to 0 px to preserve documentary-media height when the long bells title wraps.
Educational controls and their touch targets retain their existing sizes.

### Theme resources reused, not estimated

All action buttons inherit the exact shell resources also used by Casa Real:

| State | Shared resource treatment |
|---|---|
| Normal | Background `(0.12, 0.18, 0.16)`; 1 px border `(0.66, 0.70, 0.60)`; 12 px horizontal content margins |
| Hover | Background `(0.20, 0.28, 0.23)`; 1 px border `(0.94, 0.89, 0.73)`; 12 px horizontal margins |
| Pressed / hover-pressed | Background `(0.88, 0.80, 0.55)`; 2 px border `(1.0, 0.95, 0.75)` |
| Focus | No center fill; separate 3 px outline `(1.0, 0.95, 0.60)` |
| Disabled | Same resolved default disabled StyleBox as Casa Real; old Church-only pending override removed |

Shared text color is `(0.97, 0.96, 0.92)`; pressed/hover-pressed text is
`(0.06, 0.09, 0.07)`. Font family remains the existing shared/default font.
Tests compare resolved StyleBox resource identity against an actual CR-END-01
instance for all six states. The speaker icon is the unchanged
`res://assets/ui/icons/speaker.svg`.

## Audio audit and mapping evidence

Audited the actual `res://assets/landmarks/lingayen_church/audio/` recursively.
There are six OGG files and six existing `.ogg.import` files, with no nested
`narration/` directory. Each filename clearly names its corresponding hotspot.
No files were created, renamed, moved, duplicated, converted or generated.

| Hotspot | Actual supplied path | Load/duration | Delivered LISTEN | Runtime playback |
|---|---|---|---|---|
| LC-EXT-01 | `res://assets/landmarks/lingayen_church/audio/lc_ext_01_narration.ogg` | AudioStreamOggVorbis, 21.0 s | Enabled; pending hidden | Passed |
| LC-EXT-02 | `res://assets/landmarks/lingayen_church/audio/lc_ext_02_narration.ogg` | AudioStreamOggVorbis, 21.0 s | Enabled; pending hidden | Passed |
| LC-EXT-03 | `res://assets/landmarks/lingayen_church/audio/lc_ext_03_narration.ogg` | AudioStreamOggVorbis, 21.0 s | Enabled; pending hidden | Passed |
| LC-INT-01 | `res://assets/landmarks/lingayen_church/audio/lc_int_01_narration.ogg` | AudioStreamOggVorbis, 21.0 s | Enabled; pending hidden | Passed |
| LC-INT-02 | `res://assets/landmarks/lingayen_church/audio/lc_int_02_narration.ogg` | AudioStreamOggVorbis, 21.0 s | Enabled; pending hidden | Passed |
| LC-END-01 | `res://assets/landmarks/lingayen_church/audio/lc_end_01_narration.ogg` | AudioStreamOggVorbis, 21.0 s | Enabled; pending hidden | Passed |

Every file is 288,586 bytes, imported with `loop=false`, and has SHA-256:

`5E44ADB87270F4DC7586CF026902718C597544C394376FC0FDEFE1E38FA4BD44`

The filename-to-slot mapping is explicit and the identical recordings are
researcher-approved temporary content. The decoder returned nonzero PCM for
every file; runtime tests show advancing playback and natural completion after
seeking near the end. Human audibility listening remains researcher F6 review;
the agent's tools do not support hearing audio. This is not an activation blocker.

Saved resource slots: existing inherited `narration_stream: AudioStream` for
EXT-01/02/03 and INT-01/02; existing `narration: AudioStream` for END-01.
Each `.tres` contains its own `AudioStream` external resource with the exact
corresponding permanent path. No runtime Windows paths or filename-loading
callbacks were added. Replace an individual .ogg in place and let Godot perform
normal reimport to use the final recording without code or mapping changes.

## Playback and navigation behavior

Each component reuses its existing `NarrationPlayer` and signals. There is one
overall recording per hotspot; people/timeline selection no longer switches
to unassigned per-person/per-milestone slots. Those unused resource fields were
not removed, avoiding unrelated resource migration.

- LISTEN starts from zero; PAUSE holds position; RESUME continues.
- Natural completion resets label, pressed state and accessibility label.
- Valid runtime audio enables LISTEN and hides the pending line completely.
- Null audio disables LISTEN and displays “Narration pending.” without crashing.
- Sources preserves educational selection and ongoing playback, matching Casa Real.
- Education selections preserve the overall narration. Reset/Close stop it.
- Close stops immediately before the existing fade/navigation signal; reopen is stopped.
- Parent hiding and tree removal clean up audio. Opening/playing a second Church
  panel stops the previous Church narration, using a local scene-tree group
  rather than an autoload or another audio player.
- Existing Sources overlays, source wording, modal focus and Escape hierarchy remain.
- Utility Tab order is SOURCES → LISTEN → CLOSE; disabled LISTEN is skipped.
  Enter/Space, mouse and synthetic touch activate the existing button signals.

## Reflow at the old Sources location

| Hotspot | Reclaimed layout |
|---|---|
| LC-EXT-01 | Sources removed from interpretation VBox; reading area gains the row and separation. Credit stays below reading. |
| LC-EXT-02 | Sources removed from interpretation VBox; detail viewer stays intact and reading area expands; credit retained. |
| LC-EXT-03 | Sources removed from interpretation column; reading space expands without changing evidence, bell markers, comparison, documentary overlay or responsive takeaway. |
| LC-INT-01 | Takeaway/Sources HBox removed; full-width natural-height takeaway frees space for wall/detail. |
| LC-INT-02 | Takeaway/Sources HBox removed; full-width takeaway frees space for Time Window/detail, retaining era/timeline hierarchy. |
| LC-END-01 | Reflection/Sources HBox removed; natural-height full-width reflection frees map/detail space. |

No duplicate/hidden bottom Sources control, utility-only footer slot or retained
Sources minimum height remains. All historical images retain aspect and bytes;
credits, interpretations, dates, takeaways and reflection wording are unchanged.
Long text still uses existing internal reading scrolls. The compact bells title
wraps above its subtitle instead of colliding with utilities; title spacing was
adjusted to preserve its existing usable-image threshold.

## Tests and captures from the UI pass (before audio activation)

Shared revision test: `tests/lc_header_narration_test.gd`.

- Headless: **1,869 checks, 0 failures**.
- Rendered Compatibility: **1,905 checks, 0 failures** (36 capture assertions).
- All six at **1280×720, 960×540 and 854×480**: sibling utility order, exact shared
  styles, icon width, target sizes, no overlap/clipping, retained credits, modal
  state, mouse, keyboard and synthetic touch.
- Actual six supplied paths: load, positive duration, start, advancing position,
  pause/resume, selection continuity, Sources continuity, natural completion,
  immediate close stop, stopped reopen, replay from zero and missing-stream fallback.
- Two simultaneous Church panels: no overlapping narration.

Educational regression results:

| Suite | Result |
|---|---|
| LC-EXT-01 | 0 failures |
| LC-EXT-02 | 0 failures |
| LC-EXT-03 | 0 failures |
| LC-INT-01 | 5,065 checks, 0 failures |
| LC-INT-02 | 7,459 checks, 0 failures |
| LC-END-01 | 4,471 checks, 0 failures |

Assertions were updated only for requested header/audio contracts. Historical
copy, image, marker/person/timeline/theme and geometry checks remain. The END
test's existing in-memory WAV fixture was corrected to assign the resized byte
array back to the stream, so it has nonzero duration instead of an empty clip.
No placeholder narration asset was created.

From the project root, run:

```powershell
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --headless --path . --script res://tests/lc_header_narration_test.gd --quit-after 9000
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --rendering-method gl_compatibility --path . --script res://tests/lc_header_narration_test.gd --quit-after 9000 -- --capture
```

Evidence directory: `C:\Users\Admin\AppData\Local\Temp`.

- `akar_lc_header_before.log`: actual asset audit and before-layout rectangles.
- `akar_lc_header_import.log`: clean editor import with normal cache access.
- `akar_lc_header_final_lc_header_narration.log`: final headless revision suite.
- `akar_lc_header_render_final.log`: final rendered revision suite.
- `akar_lc_header_final_<id>.log`: final educational regressions, except EXT-03
  uses `akar_lc_header_regression_lc_ext_03.log` after the compact-spacing fix.
- `lc_header_before_<id>_<width>.png`: 18 original screenshots.
- `lc_header_after_<id>_<width>.png`: 18 saved-resource-state screenshots.
- `lc_header_audio_test_<id>_<width>.png`: 18 actual-stream runtime tests,
  explicitly not evidence that the unconfirmed stream is enabled in saved resources.

All six reference-size header captures and representative compact captures were
visually inspected. No physical touch-device, exported browser or human listening
approval is implied by these desktop checks.

## Documentation and file boundary of the initial UI pass

Modified six controllers:

```text
scripts/landmarks/lingayen_church/lc_ext_01.gd
scripts/landmarks/lingayen_church/lc_ext_02.gd
scripts/landmarks/lingayen_church/lc_ext_03.gd
scripts/landmarks/lingayen_church/lc_int_01.gd
scripts/landmarks/lingayen_church/lc_int_02.gd
scripts/landmarks/lingayen_church/lc_end_01.gd
```

Also modified their matching six `tests/<id>_test.gd` and six
`docs/<id>_testing.md` files. Each testing document now records its actual audio
path, approved temporary-recording status, resource slot, Casa Real reference, reflow,
input checks and F6 instructions, with a note distinguishing older milestone results.

New files:

```text
scripts/landmarks/lingayen_church/lc_header_utilities.gd
scripts/landmarks/lingayen_church/lc_header_utilities.gd.uid
tests/lc_header_narration_test.gd
docs/lingayen_church_shared_header_narration_revision.md
```

During the UI pass, no scenes, content resources, original audio/import metadata, historical images,
shared shell, other landmarks, AGENTS.md or project settings were changed by this
revision. Of the 774 baseline files, only the 18 intended controller/test/doc
files changed; all other 756 match their baseline hashes. Four new revision
files remain untracked. Ending short status contains 69 modified entries and
17 untracked entries, including the preserved pre-existing changes. Existing user modifications/untracked files persist.
`git diff --check` and new-file whitespace checks pass; the index remains empty.
HEAD remains `fe9e06b`; no staging, commit or push occurred.

## Environment messages

Sandboxed runs report `Failed to read the root certificate store.` Rendered runs
also report inability to create the `user://` shader-cache folder. These did not
prevent rendering or playback-state tests. The clean editor import used normal
Godot cache access. Final tests contain no GDScript errors or object-leak warning.
The audio-input tool explicitly reported that audio input is unsupported, which
is why human audibility/content verification is still pending.

## Exact researcher F6/audio review

Open each existing preview and press **F6**, then use its launch button:

```text
scenes/landmarks/lingayen_church/exterior/lc_ext_01_preview.tscn
scenes/landmarks/lingayen_church/exterior/lc_ext_02_preview.tscn
scenes/landmarks/lingayen_church/exterior/lc_ext_03_preview.tscn
scenes/landmarks/lingayen_church/interior/lc_int_01_preview.tscn
scenes/landmarks/lingayen_church/interior/lc_int_02_preview.tscn
scenes/landmarks/lingayen_church/interior/lc_end_01_preview.tscn
```

At 1280×720, inspect SOURCES → speaker/LISTEN → CLOSE and the old Sources location
for every component. Confirm no blank utility-sized hole, retained credits,
balanced image proportions and unchanged educational interactions. Open Sources
after making a selection; Escape must close Sources first. Check Tab order and
Enter/Space. Repeat demanding states at 960×540 and 854×480, especially the long
bells header, documentary media, timeline and meaning map.

LISTEN is now enabled in all six saved hotspots and the pending label is hidden.
Listen to the beginning of each supplied recording; the temporary shared content
is intentional. Check pause/resume, completion, immediate silence on Close and
no automatic restart on reopen. Replace each corresponding .ogg in place when
final narration is available, then allow normal Godot reimport.

No entrance video, candle, master layout or next landmark work was begun.
Stop for researcher F6/audio review; nothing was staged, committed or pushed.

## Authorized temporary narration activation — 2026-10-01

The researcher approved all six identical recordings as intentional temporary
assets. Each saved resource now references its own permanent audio path listed
in the mapping table above. LISTEN is enabled and the pending label is hidden
for all six; the existing header helper/controllers/scenes are unchanged.

### Final validation

- Saved mappings tested without initial stream injection: **1,887 headless
  checks, 0 failures**; **1,923 rendered Compatibility checks, 0 failures**.
- All six at 1280×720, 960×540, 854×480 pass layout and mouse/keyboard/synthetic
  touch checks; all six 1280 captures and representative compact states were
  visually inspected. The utility order and shared styling are unchanged.
- Start, pause, resume, natural completion, immediate stop on Close, stopped
  reopen, replay from zero, Sources state preservation, and non-overlap pass.
- Educational regressions: EXT-01/02/03 each 0 failures; INT-01 5,065 checks,
  INT-02 7,459 checks, END-01 4,471 checks, all 0 failures.
- Three older exterior assertions now check pending-label position only when
  visible. The INT-01 focus assertion now accounts for the Sources modal. No
  educational assertions were removed and no runtime behavior needed changing.
- Certificate-store and shader-cache warnings persist in this environment;
  there are no GDScript errors or leak warnings in the final test logs.
- Human listening and exported-browser testing were not performed; F6 audio
  review remains with the researcher. Identical content is approved.

Final logs are in `C:\Users\Admin\AppData\Local\Temp`:
`akar_lc_activation_lc_header_narration.log`, `akar_lc_activation_render.log`,
and `akar_lc_activation_<id>.log` for each educational regression suite.
The 18 `lc_header_after_<id>_<width>.png` captures now show saved enabled LISTEN,
and 18 `lc_header_audio_test_<id>_<width>.png` captures show active playback
from the saved mapping. They supersede the earlier pending-state captures.

### Exact files changed in the activation pass

```text
data/landmarks/lingayen_church/lc_ext_01.tres
data/landmarks/lingayen_church/lc_ext_02.tres
data/landmarks/lingayen_church/lc_ext_03.tres
data/landmarks/lingayen_church/lc_int_01.tres
data/landmarks/lingayen_church/lc_int_02.tres
data/landmarks/lingayen_church/lc_end_01.tres
tests/lc_header_narration_test.gd
tests/lc_ext_01_test.gd
tests/lc_ext_02_test.gd
tests/lc_ext_03_test.gd
tests/lc_int_01_test.gd
docs/lc_ext_01_testing.md
docs/lc_ext_02_testing.md
docs/lc_ext_03_testing.md
docs/lc_int_01_testing.md
docs/lc_int_02_testing.md
docs/lc_end_01_testing.md
docs/lingayen_church_shared_header_narration_revision.md
```

Resource changes add only the corresponding external AudioStream and existing
narration property, after the script property so Godot can deserialize it.
No audio file/import metadata, historical content, scene, runtime script,
project.godot, or other landmark was changed in this activation pass.

Activation baseline: 779 nonignored files, 69 modified and 18 untracked Git
status entries, empty index. The previously generated test UID is already part
of this baseline. Exactly the 18 files above changed; the other 761 match their
starting SHA-256 hashes. No new files were added. The six resources were already
modified at the start; their unrelated edits were preserved.

Ending Git status: 69 modified / 18 untracked entries; empty index, HEAD remains
`fe9e06b`. Git whitespace checks pass, including the untracked revision test and
audit document. Nothing staged, committed or pushed. The starting and ending
status records and file hashes use the `akar_lc_audio_activation_*` prefix in
TEMP. Stop for researcher F6/audio review using the preview paths above.
