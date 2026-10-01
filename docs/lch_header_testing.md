# Limahong global header and narration verification

Date: 2026-09-30. Scope: the seven existing standalone Limahong hotspots only.
Status: implemented; researcher F6 visual review pending. No master scene or ENT-01 created.

## Audit and continuation

AGENTS.md was read. Repository status, diff statistics and changed filenames were
reviewed before continuation. Casa Real `cr_ext_03.gd` and `cr_end_01.gd` supplied
the visual/structural reference only. No Casa Real code or assets were changed.
The inherited ConferenceRoomInteraction component remains unchanged.

Original header-task baseline: 0 staged, 1 unstaged (`project.godot`), 11 untracked
files (seven supplied OGG recordings plus two Lingayen Church reference photographs
and their two import files). HEAD: `fe9e06b163e1b94b4e9dfaf6fca0b9de4aeb2dbf`.
Baseline status, index and SHA-256 records are under
`%TEMP%/akar-limahong-header-20260930-081910/`.

At the researcher's latest continuation brief: 0 staged, 22 unstaged and 22
untracked files. The 22 unstaged files were the seven controllers, seven resources,
seven existing tests listed below plus the unrelated pre-existing `project.godot`.
Untracked files were the seven supplied OGG files, seven new OGG import files,
header helper and UID, header test and UID, plus the four original church references.
Snapshot: `%TEMP%/akar-limahong-header-continuation-20260930/`.

After that continuation audit, the header test was corrected to call INT-03's
actual `select_stage` API and extended to check repeated activation of each supplied
recording. Seven existing testing documents were updated and this report added.
No further hotspot interaction or content changes were required.

## LIMAHONG SHARED HEADER STANDARD

LIMAHONG GLOBAL HEADER:
- Left: existing title/context.
- Right: **SOURCES | speaker + LISTEN | CLOSE**, matching visual and Tab order.
- Beneath right: reserved secondary status area. With no stream, LISTEN stays visible
  and disabled and `Narration pending` appears right-aligned. Assigned audio hides
  the text without shifting the controls.

The Limahong-only `lch_header_utilities.gd` reparents the existing controls, retaining
their signals and single AudioStreamPlayer. It centralizes styles, responsive button
sizes, status geometry and focus traversal. It does not own historical content or
modify the shared component used by other landmarks.

| Panel width | Sources | Listen | Close | Gap | Utility font | Speaker |
|---|---|---|---|---|---|---|
| >=1050 px | 110x56 | 136x56 | 100x56 | 8 px | 18 px | 24 px |
| <1050 px | 92x48 | 112x48 | 80x48 | 4 px | 16 px | 20 px |

Shared icon: `res://assets/ui/icons/speaker.svg`. Heritage dark green, cream text,
muted borders, warm pressed state and distinct focus outline reuse the existing
shell theme. Disabled style is consistent across utilities. Titles can wrap.

| Hotspot | Previous Sources position | Final Sources / Listen / Close |
|---|---|---|
| EXT-01 | Large information-area button | Header right, first / middle / rightmost |
| EXT-02 | Header after Listen | Header right, first / middle / rightmost |
| EXT-03 | Header after Listen | Header right, first / middle / rightmost |
| INT-01 | Header after Listen | Header right, first / middle / rightmost |
| INT-02 | Header after Listen | Header right, first / middle / rightmost |
| INT-03 | Header after Listen | Header right, first / middle / rightmost |
| END-01 | Header after Listen | Header right, first / middle / rightmost |

INT-02's existing code/comparison hint now sits with the title, reclaiming the
separate subtitle row so approved card/connection geometry still fits. END-01 uses
compact shell spacing (4 px vertical inset, 1 px inter-row gaps) at the smallest
size; the five cards retain their approved 3+2 layout, NONE default, reflection and
key takeaway. INT-03 keeps inactive contributor/facility controls out of focus.
The statue magnifier production code is unchanged. Its size assertion now uses
Godot's approximate-vector equality for 96.000015 px floating-point rounding;
the intended 76 px optical lens and 96x96 px target requirements remain intact.

## Narration inventory and per-hotspot verification

Canonical folder: `res://assets/landmarks/limahong_channel/audio/`. Each resource
assigns `narration_stream` after its script declaration, using its own matching
filename. Controllers contain no hardcoded recording paths. No supplied recording
was moved, renamed, copied, edited or restored. All seven existed before this work.

The seven currently supplied Limahong narration files have identical binary
content. The researcher explicitly authorized their temporary use for their
respective hotspots. They also match the known Urduja recording. This is an
acknowledged temporary content choice, not seven distinct validated recordings.
Replace each corresponding OGG later if distinct final recordings are produced.
Each supplied file is 288,586 bytes; SHA-256:
`5E44ADB87270F4DC7586CF026902718C597544C394376FC0FDEFE1E38FA4BD44`.

| Hotspot | Own narration filename | Listen / audio | 1280x720 | 960x540 | 854x480 |
|---|---|---|---|---|---|
| LCH-EXT-01 | `lch_ext_01_narration.ogg` | Enabled / playback passes | Pass | Pass | Pass |
| LCH-EXT-02 | `lch_ext_02_narration.ogg` | Enabled / playback passes | Pass | Pass | Pass |
| LCH-EXT-03 | `lch_ext_03_narration.ogg` | Enabled / playback passes | Pass | Pass | Pass |
| LCH-INT-01 | `lch_int_01_narration.ogg` | Enabled / playback passes | Pass | Pass | Pass |
| LCH-INT-02 | `lch_int_02_narration.ogg` | Enabled / playback passes | Pass | Pass | Pass |
| LCH-INT-03 | `lch_int_03_narration.ogg` | Enabled / playback passes | Pass | Pass | Pass |
| LCH-END-01 | `lch_end_01_narration.ogg` | Enabled / playback passes | Pass | Pass | Pass |

For every row, Sources / Listen / Close remain in the same ordered header group,
fit the parent without title collision, share height/styles and meet 48 px minimum
touch dimensions. Narration pending is hidden for all seven current assignments.
Null-stream fallback is exercised only on in-memory test copies.

No autoplay. Actual supplied OGG decoding and requested playback are checked.
Repeated Listen follows existing behavior: EXT-01 pauses/resumes; the other six
stop/restart. Content changes preserve the current overall stream and playback.
INT-02 prioritizes its newly assigned overall narration over optional per-person
fallback audio; the fallback remains supported when no overall clip exists.
Sources does not restart audio. Close stops it; reopening starts stopped.
Source-credit wording, including older pending-recording statements, is preserved
verbatim as requested; this technical report records the current temporary assignment.

## Validation

Godot 4.7.2 stable, Compatibility renderer. Tests use the real previews' 90-percent
inset parent, not a full-screen substitute.

| Suite | Result |
|---|---|
| `tests/lch_header_test.gd` | 3461 checks, 0 failures |
| `tests/lch_ext_01_test.gd` | 0 failures, all three sizes |
| `tests/lch_ext_02_test.gd` | 0 failures, all three sizes |
| `tests/lch_ext_03_test.gd` | 0 failures, all three sizes |
| `tests/lch_int_01_test.gd` | 594 checks, 0 failures |
| `tests/lch_int_02_test.gd` | 2663 checks, 0 failures |
| `tests/lch_int_03_test.gd` | 1859 checks, 0 failures |
| `tests/lch_end_01_test.gd` | 4865 checks, 0 failures |

The header suite covers all seven at all three sizes: mouse and synthetic touch on
Sources/Listen/Close; Tab/Shift+Tab; Enter/Space; disabled-control omission;
Sources Escape then hotspot Escape; state fingerprints before/after Sources;
rapid content changes; assigned OGG playback; repeat activation; close/reopen;
no autoplay; null-stream fallback; stable assigned/pending geometry; shared icon
and styles; one audio owner; no content-area Sources; title/button separation.
Existing suites retain content-specific coverage for locator/gallery, route, siege,
magnifier, people, heritage stages and summary. No historical interaction was rebuilt.

Headless import exits successfully. No parser, resource, invalid UID, broken audio
reference or duplicate-node errors in final validation. `git diff --check` passes.
Known environment diagnostics: Windows root-certificate-store error; existing
EXT-01/EXT-02 shutdown warnings for 2/3 ObjectDB instances. INT-03 deliberately
tests a missing-image fallback and logs its expected warning. These do not cause
assertion failures. Browser export and physical touchscreen tests were not run.

Logs: `%TEMP%/akar-header-final-<id>.log`,
`%TEMP%/akar-header-import-final.log`, `%TEMP%/akar-header-render-verified.log`.
All seven native rendered previews were inspected at all three sizes. Toolbar
border pixel positions were also checked against runtime bounds in 21 settled
review snapshots. Additional review images use
`%TEMP%/lch-global-header-review-<id>-<width>x<height>.png`.
Rendered test snapshots: `%TEMP%/lch-global-header-<id>-<width>x<height>.png`, plus
`-pending.png` null-audio compact snapshots. Screenshots wait for layout/entrance
animations to settle. Content scrolling remains internal; no whole-screen scroll
was introduced. Researcher F6 approval is still required.

Run locally (substitute the installed Godot executable):
```text
godot --headless --editor --path . --import
godot --headless --path . --script res://tests/lch_header_test.gd
godot --path . --script res://tests/lch_header_test.gd -- --capture
godot --headless --path . --script res://tests/lch_<id>_test.gd
git diff --check
```

## Complete revision file inventory

These 28 tracked files are intentionally modified; all other production
scenes, maps, photographs, source text and transcript resources remain unchanged.

| Hotspot | Controller | Content resource | Existing regression test | Testing documentation |
|---|---|---|---|---|
| LCH-EXT-01 | `scripts/landmarks/limahong_channel/lch_ext_01.gd` | `data/landmarks/limahong_channel/lch_ext_01.tres` | `tests/lch_ext_01_test.gd` | `docs/lch_ext_01_testing.md` |
| LCH-EXT-02 | `scripts/landmarks/limahong_channel/lch_ext_02.gd` | `data/landmarks/limahong_channel/lch_ext_02.tres` | `tests/lch_ext_02_test.gd` | `docs/lch_ext_02_testing.md` |
| LCH-EXT-03 | `scripts/landmarks/limahong_channel/lch_ext_03.gd` | `data/landmarks/limahong_channel/lch_ext_03.tres` | `tests/lch_ext_03_test.gd` | `docs/lch_ext_03_testing.md` |
| LCH-INT-01 | `scripts/landmarks/limahong_channel/lch_int_01.gd` | `data/landmarks/limahong_channel/lch_int_01.tres` | `tests/lch_int_01_test.gd` | `docs/lch_int_01_testing.md` |
| LCH-INT-02 | `scripts/landmarks/limahong_channel/lch_int_02.gd` | `data/landmarks/limahong_channel/lch_int_02.tres` | `tests/lch_int_02_test.gd` | `docs/lch_int_02_testing.md` |
| LCH-INT-03 | `scripts/landmarks/limahong_channel/lch_int_03.gd` | `data/landmarks/limahong_channel/lch_int_03.tres` | `tests/lch_int_03_test.gd` | `docs/lch_int_03_testing.md` |
| LCH-END-01 | `scripts/landmarks/limahong_channel/lch_end_01.gd` | `data/landmarks/limahong_channel/lch_end_01.tres` | `tests/lch_end_01_test.gd` | `docs/lch_end_01_testing.md` |

New implementation/test/documentation files:
- `scripts/landmarks/limahong_channel/lch_header_utilities.gd`
- `scripts/landmarks/limahong_channel/lch_header_utilities.gd.uid`
- `tests/lch_header_test.gd`
- `tests/lch_header_test.gd.uid`
- `docs/lch_header_testing.md`

Generated Godot import metadata for the seven pre-existing supplied OGG files:
- `assets/landmarks/limahong_channel/audio/lch_ext_01_narration.ogg.import`
- `assets/landmarks/limahong_channel/audio/lch_ext_02_narration.ogg.import`
- `assets/landmarks/limahong_channel/audio/lch_ext_03_narration.ogg.import`
- `assets/landmarks/limahong_channel/audio/lch_int_01_narration.ogg.import`
- `assets/landmarks/limahong_channel/audio/lch_int_02_narration.ogg.import`
- `assets/landmarks/limahong_channel/audio/lch_int_03_narration.ogg.import`
- `assets/landmarks/limahong_channel/audio/lch_end_01_narration.ogg.import`

The seven OGG files in the narration table remain untracked and byte-identical to
the starting snapshot. They are required along with their import metadata whenever
this revision is committed later; no staging or commit is performed now.

## Git preservation and outstanding review

Final counts: 0 staged, 29 unstaged, 23 untracked files. Of the 29 unstaged files,
28 belong to this revision and `project.godot` is the unchanged pre-existing
modification. Of the 23 untracked files, 19 are Limahong (seven original OGGs, seven
imports, helper/UID, test/UID and this report); four are unchanged church references.
The original index, HEAD, project.godot bytes, original OGG bytes, church reference
files and all unrelated tracked files are preserved. No stage, unstage, reset,
restore, commit, amend or push. Casa Real, Lingayen Church, Urduja House and shared
landmark components are unchanged. Historical content is unchanged; stripping
only the added audio reference/assignment from each .tres reproduces HEAD content.

Researcher F6 review:
1. Open each existing `lch_<id>_preview.tscn` under the Limahong exterior, interior
   or summary scene folder. Press F6 and open the hotspot.
2. At 1280x720, 960x540 and 854x480, inspect title/context and Sources / Listen /
   Close alignment. Confirm the icon, enabled Listen and no pending message.
3. Listen, activate again, change content, open Sources and return. Confirm the
   current selection/lens/route/topic remains and narration does not restart.
4. Tab and Shift+Tab through utilities and content; activate with Enter/Space.
   Escape closes Sources first, then the hotspot. Close/reopen and confirm reset
   plus stopped narration. Repeat by mouse and touchscreen if available.
5. Review INT-01 photo/detail fit, INT-02 card/connection spacing, INT-03 stages,
   and END-01 3+2 compact cards, reflection and takeaway.

Outstanding: researcher F6 visual approval; optional physical touch/browser review;
replacement recordings if distinct final narration is produced. Stop here.
