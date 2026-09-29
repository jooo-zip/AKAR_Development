# PPC-END-01 — What the Pangasinan Provincial Capitol Represents

## Purpose and scope

This standalone final summary synthesizes five approved themes: Origins,
Architecture, Resilience, Public Service and Heritage. It adds an optional,
non-scored reflection rather than another full historical lesson. It is available
immediately, including to a visitor who has opened none of the earlier Capitol
hotspots. It has no prerequisites, unlocks, visit markers or completion tracking.

Only researcher-supplied Phase 5 wording and already established source metadata
are used. This supports the project's museum-learning and acceptability scope;
no learning-effectiveness claim is made. PPC-ENT-01 video insertion and the Capitol
master layout remain outside this milestone.

## Files and architecture

Created files:

- `data/landmarks/pangasinan_provincial_capitol/ppc_end_01.tres`
- `scenes/landmarks/pangasinan_provincial_capitol/summary/ppc_end_01.tscn`
- `scenes/landmarks/pangasinan_provincial_capitol/summary/ppc_end_01_preview.tscn`
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01.gd`
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01_canvas.gd`
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01_preview.gd`
- `tests/ppc_end_01_test.gd`
- `docs/ppc_end_01_testing.md`

The `summary/` scene folder follows the existing Urduja House and Limahong Channel
END convention. Godot-generated script UID sidecars accompany the new scripts.
The narration and its import sidecar were already present before implementation.

The component inherits the shared `ConferenceRoomInteraction` shell and uses the
existing `ConferenceRoomContent` / `ConferenceRoomConceptEntry` resources. Approved
copy, captions, static cues, reflection responses and credits remain in the resource.
The passive canvas aspect-fits one or two original images and crossfades compositions.
The preview instantiates the actual production scene; it changes viewport sizing
only within the standalone preview, without editing project settings.

The existing Capitol components and Casa Real END component were inspected for
header, Sources, narration, focus, reset, resource, preview and test patterns.
No existing shared component, completed hotspot or previous test was changed.

## Reused media audit

All paths are exact repository-relative paths. **No duplicate image files were
created.** Every existing image is referenced directly, unchanged: no copy, rename,
conversion, recompression, retouching or image generation. Aspect ratios remain intact.
All images load through their existing Godot imports. Documentary rendering uses
linear filtering locally; project pixel-art texture settings remain unchanged.

| Theme | Exact reused path | Dimensions | Bytes |
| --- | --- | --- | --- |
| Overview / Origins | `assets/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01/ppc_ext_01_government_today.jpeg` | 4032×2055 | 2,065,719 |
| Architecture | `assets/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_02/ppc_ext_02_detail_facade_rhythm.JPG` | 2592×1728 | 957,862 |
| Resilience | `assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01/ppc_int_01_1945_damage.png` | 711×376 | 261,977 |
| Public Service — Executive | `assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02/ppc_int_02_governor_office.png` | 678×448 | 551,319 |
| Public Service — Legislative | `assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02/ppc_int_02_session_hall.jpeg` | 4032×3024 | 3,625,822 |
| Heritage | `assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01/ppc_int_01_2018_heritage_protection.png` | 691×1068 | 510,818 |

### Inherited credits and rights

| Media | Established credit | Inherited rights status |
| --- | --- | --- |
| Present-day Capitol | PPC-EXT-01: Photographer/creator: AKAR Team; Source: AKAR Research Team | Research-team-produced documentary photograph. |
| Façade rhythm | PPC-EXT-02: Photo: AKAR Research Team | Research-team-produced documentary photograph. |
| 1945 wartime damage | PPC-INT-01: Researcher-supplied historical photograph. Creator not identified in available source. | External media permission/license status was not supplied. |
| Governor's Office | PPC-INT-02: Victory Liner · The Provincial Capitol of Pangasinan | External source — reuse/permission documentation pending. |
| Session Hall | PPC-INT-02: Photo: AKAR Research Team | Research-team-produced documentary photograph. |
| 2018 certification | PPC-INT-01: Office of the Sangguniang Panlalawigan Secretary, Province of Pangasinan; researcher-supplied documentary copy | External media permission/license status was not supplied. |

Sources groups Historical Development, Architecture, Recognition & Preservation,
and Documentary Media. It inherits the historical validation sheet, historical
profile, approved architectural interpretation, recognition and ordinance references.
It preserves the Governor's Office physical-access qualification. No blanket external
media ownership or permission is asserted. Unresolved rights remain unresolved.

## Narration audit

- Exact path: `assets/landmarks/pangasinan_provincial_capitol/audio/ppc_end_01_narration.ogg`
- Format: OGG Vorbis; file size: **292,954 bytes**.
- Godot stream duration: **33.0453338623047 seconds**.
- Supplied OGG and existing `.import` sidecar preserved byte-for-byte.
- Imports and plays locally; there is no conversion, normalization, re-encoding or BGM.
- No autoplay. LISTEN starts playback; STOP stops it. Themes, reflection, choices,
  BACK TO SUMMARY and Sources never seek, stop or restart narration.
- Full hotspot closure stops/resets playback; reopening starts stopped.

The OGG comment metadata was inspected. It contains encoder/container metadata and
an undefined language tag, but no transcript. No configured transcript was supplied
for PPC-END-01. Audio wording therefore cannot be automatically compared with the
approved copy from this metadata; researcher listening review remains necessary
unless separately confirmed. Earlier narration approvals are not assumed to cover
this new recording. The source recording is never silently altered.

## Five themes and historical safety

Overview starts at **More Than a Historic Building**, with no selected theme and an
immediately available YOUR REFLECTION action. The passive photograph is not a control.

- **Origins:** approved 1917–1918 construction, Daniel Maramba, Ralph Harrington Doane
  and Casa Real transition wording. A separate 1917 → 1918 synthesis cue accompanies
  a photograph explicitly captioned **Present-day view**. The cue's word “COMPLETED”
  refers only to construction in 1918, as explicitly requested; it is never a visitor
  completion state.
- **Architecture:** approved neoclassical/climate synthesis with static BALANCE,
  IONIC COLUMNS and VENTILATION & PROTECTION cues. No slider, markers or climate overlays.
- **Resilience:** approved damage, rebuilding and renewal synthesis with a static
  1945 → 1949 → 2008 cue. The image caption identifies **1945 wartime damage only**;
  it is not presented as a reconstruction or refurbishment photograph.
- **Public Service:** static, approximately equal Executive / Governor's Office and
  Legislative / Session Hall image areas. No institutional subtopics, simulated work,
  officeholder profiles or comparison controls.
- **Heritage:** approved recognition and heritage-site preservation wording with
  Provincial Ordinance No. 220-2018. Sources describes the ordinance as declaring the
  Capitol a heritage site in the Province of Pangasinan and providing funds for its
  preservation. The excluded designation is absent from production copy.

`select_meaning_theme(theme_id)` owns the theme state. Each selection updates visual,
heading, body, takeaway and selected control together. Visual crossfades take 200 ms;
text fades take 180 ms. New input cancels stale transitions. There is no documentary,
ordinance, zoom or architecture-detail viewer in this summary.

## Optional reflection

Reflection is available from Overview and every theme without prior exploration.
It asks **What Stands Out to You?** with the four approved choices:

- ITS HISTORY (`history`)
- ITS ARCHITECTURE (`architecture`)
- ITS CONTINUING PUBLIC ROLE (`public_role`)
- ITS PRESERVATION (`preservation`)

`open_reflection()` stores `reflection_origin_theme` and retains that theme's visual
under a runtime shade. `select_reflection(choice_id)` immediately changes the approved
response; choices can be changed freely. The common closing synthesis appears after
a choice is selected. There is no submission, evaluation, ranking, saved profile or
data collection. The interface neither grades nor records visitor performance.

BACK TO SUMMARY returns to the exact origin and restores focus to YOUR REFLECTION.
The choice survives returns and theme changes within the open hotspot only. Reflection
opens/closes over 220 ms; responses fade over 170 ms. Sources is available from both
summary and reflection and preserves theme, choice, origin and playback.

During a closing reflection fade, underlying themes stay blocked. A newer Sources
request cancels that pending return and preserves reflection beneath Sources. Sources
blocks all underlying controls and traps focus until closed.

## Input and responsive behavior

Touch and mouse activate the same controls. Native BaseButton touch avoids duplicate
activation. Targets remain at least 48 px; reflection choices are 52 px high in a 2×2
grid. Theme controls retain a minimum width of 168 px and scroll horizontally where
needed. A touch drag on the rail cancels a pending tap. Interpretation, reflection
response and Sources scrollers support local touch dragging, native wheel scrolling
and keyboard reading. Hover adds only restrained visual feedback and a pointer cursor.

Summary keyboard order: Origins → Architecture → Resilience → Public Service →
Heritage → Your Reflection → Sources → Listen → Close. Reflection begins with the
four choices → Back to Summary, followed by the shared header controls. A local
reading scroller joins the order only when its contents overflow. Tab and Shift+Tab
loop within the active context; Enter and Space activate. Cream focus outlines differ
from muted-gold selection. No image or cue is a hidden focus target.

Escape closes Sources first, then reflection to its origin, then a selected theme
to Overview, then the hotspot to its host. Leaving reflection does not erase its
choice. Navigation input is handled before closure signals can remove the component.

| Viewport | Summary behavior | Reflection behavior |
| --- | --- | --- |
| 1280×720 | About 62% visual / 38% synthesis, five-theme rail, separate reflection action | 2×2 choices, retained subdued visual, concise response and synthesis |
| 960×540 | Reduced margins and spacing, readable body and full touch targets | Same structure with compact spacing and local reading scroll if needed |
| 854×480 | Visual above local synthesis, horizontal rail, reflection action below; compact title and one-line heritage cue preserve image space | 2×2 choices and reachable Back; response scrolls locally where necessary |

The image caption stays visually separate from history cues. Both Public Service
images preserve their native aspect ratios in equal allocated areas. All photos and
the certification remain complete; the heritage image is contextual at compact size,
with its approved meaning supplied in readable text. No portrait redesign or global
page scrolling is introduced.

## Reset contract

Full close resets selected theme to Overview; reflection closes, choice clears and
origin returns to Overview; Sources closes; narration stops/resets; all local scrolls
return to the start; active Tweens and touch gestures are cancelled. Host focus is
restored. Hiding the host also closes and cleans up the component. Reopening starts
fresh, with no selected theme, reflection choice or visitor history.

## Automated validation

`tests/ppc_end_01_test.gd` instantiates the real production preview. It checks exact
approved copy and captions, direct existing image paths, default optional access,
all five themes and four choices through mouse/touch/Enter/Space, theme and choice
memory, origin return, full focus loops, distinct selection/focus, true image fit,
equal Public Service areas, responsive bounds, source metadata, Sources isolation,
touch scrolling, narration continuity, rapid input, Escape, reset and host-hide cleanup.
It also checks excluded production features and historical wording.

Rendered Compatibility runs save screenshots for Overview, all themes, each reflection
response, empty reflection and Sources at all three viewport sizes. Test teardown
allows the asynchronous audio mixer to release the OGG; production playback is unchanged.

Commands, using the installed Godot 4 console executable:

```powershell
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/ppc_end_01_test.gd
godot --path . --rendering-method gl_compatibility --script res://tests/ppc_end_01_test.gd -- --capture
git diff --check
git status --short
```

Final Godot 4.7.2 import/parse validation exited 0 with no script/resource parse errors.
Headless PPC-END-01 validation passed **5,437 checks, zero failures**, exit 0.
Rendered Compatibility validation passed **5,473 checks, zero failures**, exit 0.
Both runs validate **1280×720, 960×540 and 854×480**. The rendered run saved 36 screenshots;
representative summary, split-image, reflection and Sources captures were visually
reviewed, including the compact Heritage layout correction. No PPC-END-01 ObjectDB
exit leak warning was reported.

All **24 established regression suites** passed, exit 0:

| Suite | Checks where reported | Failures |
| --- | --- | --- |
| PPC-EXT-01 | 2,487 | 0 |
| PPC-EXT-02 | 1,975 | 0 |
| PPC-INT-01 | 1,963 | 0 |
| PPC-INT-02 | 2,065 | 0 |
| CR-EXT-01 / 02 / 03 | 1,983 / 1,897 / 5,431 | 0 |
| CR-INT-01 / 02 / 03 | 2,287 / 5,232 / 3,853 | 0 |
| CR-END-01 | 3,148 | 0 |
| LC-EXT-01 / 02 / 03 | Suite pass | 0 |
| LC-INT-01 / 02 | 5,065 / 7,459 | 0 |
| LC-END-01 | 4,471 | 0 |
| LCH-EXT-01 / 02 / 03 | Suite pass | 0 |
| LCH-INT-01 / 02 / 03 | 594 / 2,663 / 1,859 | 0 |
| LCH-END-01 | 4,865 | 0 |

Unchanged regression suites reported exit ObjectDB warnings: CR-EXT-02 (4 instances),
LCH-END-01 (2), LCH-EXT-01 (2), LCH-EXT-02 (3). CR-EXT-02 additionally reported two
resources still in use at exit. LCH-INT-03 also exercised its intentional
missing-media fixture. These suites still reported zero failures; neither tests nor
completed production files were changed to suppress their warnings.

All existing `tests/*_test.gd` suites are included. Urduja House has no persistent
suite in that directory; its existing files are protected by the file-hash audit.

## Researcher F6 checklist

1. Open `scenes/landmarks/pangasinan_provincial_capitol/summary/ppc_end_01_preview.tscn`
   and press **F6**. Confirm Overview, no selected theme, no autoplay and immediate
   reflection access without opening any earlier Capitol hotspot.
2. Open reflection immediately. Try all four choices, change choices repeatedly and
   return. Confirm the wording is interpretive and has no required submission.
3. Explore the five themes in arbitrary order. Review the exact approved body and
   takeaway; check modern-photo and 1945 captions against their independent date cues.
4. Inspect equal Public Service image emphasis and institutional labels. Verify no
   subtopic explorer, active comparison, media viewer or new historical interaction.
5. From Architecture choose Preservation in reflection and return: Architecture and
   the choice should remain. Re-enter reflection from another theme: choice remains.
6. Start narration. Switch themes, enter reflection, change choices, return, open and
   close Sources. Listen for uninterrupted playback. Review the recording's historical
   wording against the approved synthesis; do not silently replace the source audio.
7. Inspect Sources from summary and reflection. Reach all credits by touch, wheel
   and keyboard. Verify inherited permission gaps and background-input blocking.
8. Tab/Shift+Tab through both contexts and Sources. Activate with Enter and Space;
   check distinct focus/selected styling and restoration after reflection/Sources.
9. Test the complete Escape hierarchy. Close and reopen after Heritage → Reflection
   → Preservation → narration → Sources. Confirm a fully fresh Overview and stopped audio.
10. Repeat at 1280×720, 960×540 and 854×480. Inspect image aspect, text, horizontal rail,
    local reading scrolls and all controls. Verify actual device touch comfort and Web
    browser scaling separately from synthetic desktop touch.
11. Rapidly change themes and reflection choices; close during transitions and reopen.
    Confirm latest input wins with no stale image, cue, response or focus.
12. Press **F8** to stop. Review remains uncommitted; no staging, commit or push is part
    of this milestone.

## Initial repository state

HEAD: `cb66ac1` — `feat: implement PPC-INT-02 living seat of government hotspot`.

```text
 M project.godot
?? assets/landmarks/pangasinan_provincial_capitol/audio/ppc_end_01_narration.ogg
?? assets/landmarks/pangasinan_provincial_capitol/audio/ppc_end_01_narration.ogg.import
?? docs/references/
```

All 726 pre-existing tracked/untracked files were SHA-256 baselined before creating
this milestone. The project settings modification and `docs/references/` are unrelated
pre-existing changes. No reset, restore, stage, commit or push is used.

## Known review items

- Inherited external-media creator/permission gaps remain as documented above.
- Historical images and the office photograph have limited source resolution; originals
  are preserved. The summary intentionally has no document-detail viewer.
- Narration transcript metadata is absent; researcher wording review/confirmation
  must be distinguished from technical import/playback validation.
- Physical touchscreen, Web export and final researcher F6 acceptance remain manual.
- This Windows Godot environment reports a root-certificate-store startup warning;
  local imports and playback still work. Any existing regression-suite exit warnings
  are reported separately; completed suites are not altered to silence them.

## Final repository verification

SHA-256 comparison found **zero changes across all 726 pre-existing files** after
implementation, imports and tests. PPC-EXT-01, PPC-EXT-02, PPC-INT-01, PPC-INT-02,
all completed other landmarks, shared components, supplied narration/import sidecar,
reused photographs, `project.godot` and `docs/references/` remain byte-for-byte unchanged.
No unrelated Godot serialization noise appeared. No duplicate image file was created.

`git diff --check` and whitespace checks for all 12 newly created text/source/UID
files passed. Source safety searches returned zero prohibited production matches.
The eight requested implementation files and four generated script UID sidecars are
new; the narration and its sidecar remain pre-existing untracked assets.
Nothing was staged, committed or pushed.

Final `git status --short`:

```text
 M project.godot
?? assets/landmarks/pangasinan_provincial_capitol/audio/ppc_end_01_narration.ogg
?? assets/landmarks/pangasinan_provincial_capitol/audio/ppc_end_01_narration.ogg.import
?? data/landmarks/pangasinan_provincial_capitol/ppc_end_01.tres
?? docs/ppc_end_01_testing.md
?? docs/references/
?? scenes/landmarks/pangasinan_provincial_capitol/summary/
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01.gd
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01.gd.uid
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01_canvas.gd
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01_canvas.gd.uid
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01_preview.gd
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01_preview.gd.uid
?? tests/ppc_end_01_test.gd
?? tests/ppc_end_01_test.gd.uid
```

READY FOR RESEARCHER F6 REVIEW: YES
