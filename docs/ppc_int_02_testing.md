# PPC-INT-02 — A Living Seat of Government

## Purpose and scope

Educational question: **How does the historic Capitol continue to serve Pangasinan today?**
This standalone civic-function explorer uses only the researcher-approved Phase 5
interpretation. The second-floor public lobby, Governor's Office and Session Hall
introduce institutional functions. It provides no office directory, physical route,
service transaction, officeholder profile, political advocacy or completion tracking.
It does not claim improved learning effectiveness; the project's evaluation remains
acceptability-focused. No master Capitol layout or PPC-END-01 is implemented.

## Implementation files

- `data/landmarks/pangasinan_provincial_capitol/ppc_int_02.tres`: approved copy, media and credits.
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02.gd`: authoritative civic state, topic memory, input and modal lifecycle.
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02_canvas.gd`: schematic civic relationships, fitted photographs and equal comparison columns.
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02_preview.gd`: standalone preview sizing only.
- `scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02.tscn`: production component inheriting the existing shared interaction shell.
- `scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02_preview.tscn`: F6 scene instantiating the real production component.
- `tests/ppc_int_02_test.gd`: production runtime, input and responsive assertions.
- `docs/ppc_int_02_testing.md`: this guide.

Godot-generated `.uid` and supplied-media `.import` sidecars accompany the new files.
No completed hotspot or shared component is modified.

## Asset audit

All paths below are relative to the repository. Supplied originals remain unchanged;
there is no crop, conversion, re-encoding, image generation or retouching. Documentary
photographs use linear sampling and keep their complete aspect ratio; project pixel-art
filtering remains unchanged.

| Asset | Exact path | Format | Dimensions | Aspect ratio | File size |
| --- | --- | --- | --- | --- | --- |
| Lobby | `assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02/ppc_int_02_lobby.png` | PNG | 391 × 393 | 0.994911:1 | 189,659 bytes |
| Governor's Office | `assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02/ppc_int_02_governor_office.png` | PNG | 678 × 448 | 1.513393:1 | 551,319 bytes |
| Session Hall | `assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02/ppc_int_02_session_hall.jpeg` | JPEG | 4032 × 3024 | 4:3 | 3,625,822 bytes |
| Narration | `assets/landmarks/pangasinan_provincial_capitol/audio/ppc_int_02_narration.ogg` | OGG Vorbis | Not applicable | Not applicable | 296,847 bytes |

All four import in Godot 4.7.2. The audio stream reports approximately 32.555 seconds.
The lobby photograph is low resolution and visibly soft. The office photograph has
moderate resolution; the Session Hall photograph provides ample detail. The viewer
preserves the supplied evidence and does not imply that enlarging creates new detail.

### Label decision and provenance

The Governor's Office photograph visibly shows the furnished **office interior**, with
a desk, seating and upper galleries, rather than only a threshold. The heading is
**Governor's Office**; caption: **Governor's Office inside the Pangasinan Provincial Capitol.**

**Documentary view; physical access is subject to actual Capitol access and authorization.**

| Media | Documented source/credit | Ownership and rights status |
| --- | --- | --- |
| Lobby | ARKITHIRD / MAG-ARCHISTORY, Department of Architecture, University of Pangasinan-PEN, 2013–2014, 2nd Semester. Recommended description: ARKITHIRD, MAG-ARCHISTORY: The American—Classic Style Capitol, University of Pangasinan-PEN, 2013–2014. | External media; permission/reuse documentation pending. No AKAR ownership or unrestricted license asserted. |
| Governor's Office | Victory Liner, “The Provincial Capitol of Pangasinan” | External media; permission/reuse documentation pending. No AKAR ownership or unrestricted license asserted. |
| Session Hall | Photo: AKAR Research Team | Research-team-produced documentary photograph. |
| Narration | AKAR Research Team | Researcher-supplied OGG. No additional license invented. |

Credits appear in the reusable viewer and the established Sources overlay. Sources
separates PROJECT / VALIDATED SOURCES from DOCUMENTARY MEDIA, with narration attributed
to AKAR Research Team. External rights remain unresolved for deployment/reuse review.

The researcher explicitly confirmed this narration was checked against the approved
institutional wording, including absence of current politician names, party references
and unrestricted-access claims. This is researcher confirmation, not automated audio
transcription. The original recording was not changed.

## Interaction contract

`select_civic_view(view_id)` owns the five parallel states: `overview`, `lobby`,
`executive`, `legislative`, `comparison`. Topic selectors own `executive_topic` and
`legislative_topic`, defaulting to `executive_role` and `ordinances` respectively.

- **Overview:** A Heritage Building Still in Use; three equal primary function controls
  and COMPARE FUNCTIONS. Diagram labels PUBLIC LOBBY, EXECUTIVE FUNCTION / Governor's
  Office, LEGISLATIVE FUNCTION / Session Hall. It explicitly reads **SCHEMATIC
  PUBLIC-SPACE VIEW — NOT TO SCALE**. The schematic represents conceptual relationships,
  not room positions, access routes or physical adjacency.
- **Public Lobby:** supplied lobby/reception photograph, exact caption and approved
  introduction; YOU ARE HERE / PUBLIC LOBBY hub with large Executive and Legislative
  branch controls. A cancellable 180 ms branch highlight precedes selection. VIEW LOBBY
  opens the documentary photograph.
- **Executive:** Governor's Office photograph stays stable while EXECUTIVE ROLE,
  COORDINATION or PUBLIC SERVICE updates the short interpretation. No modal per topic.
- **Legislative:** Session Hall photograph stays stable while ORDINANCES, RESOLUTIONS
  or PROVINCIAL POLICIES changes the interpretation. No members, debate or voting simulation.
- **Comparison:** equally sized columns, fitted office and Session Hall photographs,
  both approved summaries, EXPLORE EXECUTIVE and EXPLORE LEGISLATIVE. Neither side is
  ranked. Both actions preserve previously selected topics.
- **Return:** every non-overview state has ← PUBLIC SPACES. No Previous/Next sequence.

Main transitions and documentary photo crossfades last 200 ms (comparison 220 ms), topic interpretation fades last
170 ms, and the documentary viewer opens/closes over 200 ms. Latest input cancels
stale transitions, including delayed lobby branches. No movement simulation or effects.

One documentary viewer handles `lobby`, `governor_office`, `session_hall` and records
`space_view_open`, `space_media_id`, `space_origin_view`. It shows DOCUMENTARY VIEW,
CLOSE, a large complete photo, caption and source. Opening it leaves civic state,
topics and narration intact. Closing restores focus to VIEW LOBBY / VIEW SPACE.
Sources and the viewer are mutually exclusive, block background input and trap focus.
The closing fade remains modal until it finishes.

Narration never autoplays and is not restarted by view, topic, comparison, Sources
or documentary-view changes. LISTEN starts and STOP ends playback. Closing the whole
hotspot stops/resets audio. Hiding the host also cleans up active state.

## Input and responsive behavior

Mouse, native touch and Enter/Space activate the same buttons. Targets are at least
48 px high, with 52 px schematic branch targets. Pointer cursors and restrained
hover feedback add no exclusive content. Cream focus outlines differ from gold topic
selection. Native BaseButton touch handling avoids duplicate narration toggles.
Local scrollers handle touch drags even on hosts without touchscreen capability flags;
dragging a control rail cancels the pending tap. Mouse wheel and keyboard scrolling
retain native Godot behavior.

Focus order follows the requested per-view actions, followed by SOURCES, LISTEN,
CLOSE and the local interpretation scroller only when needed. Overview begins PUBLIC
LOBBY → EXECUTIVE FUNCTION → LEGISLATIVE FUNCTION → COMPARE FUNCTIONS. Lobby starts
with its Executive and Legislative branches; function views start with their three
topics; comparison starts with the two Explore controls. Modal Close receives focus
first, and modal closure restores its opener. Full closure restores the host trigger.

Escape hierarchy: Sources → close Sources; otherwise viewer → close viewer; otherwise
non-overview → overview; otherwise → close hotspot. Input is marked handled before
navigation/closure signals can remove the component.

| Viewport | Layout |
| --- | --- |
| 1280 × 720 | Large diagram/photo with interpretation on the right; function controls below. Equal comparison columns. |
| 960 × 540 | Reduced margins and fonts, photos retained as the dominant main-view content; local interpretation scrolling when needed. |
| 854 × 480 | Diagram/photo above a local interpretation strip and horizontal controls. Selected topic comes first in the strip, with the space introduction below. Comparison remains side by side with both readable summaries and actions. |

No global page scrolling or destructive image cropping. Horizontal control scrolling
is allowed when text widths require it; keyboard focus brings each control into view.

## Reset

Full close/reopen restores overview, Executive Role and Ordinances. Viewer IDs/origin
clear, Sources closes, narration stops, Tweens cancel, local scroll positions reset
and focus returns cleanly. Topic memory exists only during the current open visit.

## Validation

Tests instantiate the
real preview and production scene, dispatch real InputEvents, and cover all states,
six topics, exact copy/credits, topic memory, equal comparison, all three viewer
images/captions, modal isolation/focus, all four activation paths, Sources touch scroll,
rapid input, narration continuity, Escape hierarchy, host-hide cleanup and reset.
They validate touch-target and layout bounds at all three viewport sizes, plus
prohibited-content strings. Rendered runs additionally save screenshots to the system
temporary directory. Audio test teardown waits briefly for the asynchronous mixer;
this does not change production narration behavior.

Typical commands (use the installed Godot console executable):

```powershell
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/ppc_int_02_test.gd
godot --path . --rendering-method gl_compatibility --script res://tests/ppc_int_02_test.gd -- --capture
git diff --check
git status --short
```

All established `tests/*_test.gd` suites are included in regression validation.
Urduja House has no persistent test suite in `tests/`; its existing files are protected
by the before/after file-hash audit. No completed tests are edited.

Final Godot 4.7.2 import completed with exit 0 and no script/resource parse failures.
The headless PPC-INT-02 run passed **2,065 checks, zero failures**, covering 1280×720,
960×540 and 854×480. Rendered results are recorded at the end of this guide.

All **23 existing regression suites** passed with exit 0:

| Suite | Checks, where reported | Failures |
| --- | --- | --- |
| PPC-EXT-01 | 2,487 | 0 |
| PPC-EXT-02 | 1,975 | 0 |
| PPC-INT-01 | 1,963 | 0 |
| CR-EXT-01 / 02 / 03 | 1,983 / 1,897 / 5,431 | 0 |
| CR-INT-01 / 02 / 03 | 2,287 / 5,232 / 3,853 | 0 |
| CR-END-01 | 3,148 | 0 |
| LC-EXT-01 / 02 / 03 | Suite pass | 0 |
| LC-INT-01 / 02 | 5,065 / 7,459 | 0 |
| LC-END-01 | 4,471 | 0 |
| LCH-EXT-01 / 02 / 03 | Suite pass | 0 |
| LCH-INT-01 / 02 / 03 | 594 / 2,663 / 1,859 | 0 |
| LCH-END-01 | 4,865 | 0 |

Existing LCH-END-01 and LCH-EXT-02 tests reported 2 and 3 ObjectDB instances at exit
respectively, despite zero assertion failures. LCH-INT-03 exercised its documented
missing-media fallback. These existing suites and production files were not edited.

## Researcher F6 checklist

1. Open `scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02_preview.tscn`
   in Godot and press **F6**. This runs the real production component. Confirm overview,
   all functions available immediately, narration stopped and conceptual disclaimer visible.
2. Visit Public Lobby. Review its reception-area caption and source; tap each large
   branch, including rapidly choosing the other branch before the highlight finishes.
3. Review all Executive and Legislative topics. Confirm photo dominance, exact neutral
   wording, selected state and distinct focus outline. Verify the office interior label.
4. Select Public Service, return to Public Spaces, and re-enter Executive. Select
   Resolutions, open comparison via Public Spaces, then Explore Legislative. Confirm memory.
5. Review equal comparison emphasis and both summaries at 1280×720, 960×540 and 854×480.
6. Open each VIEW LOBBY / VIEW SPACE. Check full image, caption, source, Close focus,
   Escape closure and restoration to the opener. Try activating background controls.
7. Start narration and switch every civic view, topic, comparison and viewer. Confirm
   audible continuity and no double toggle on touch. Close/reopen: audio must be stopped.
8. Open Sources from multiple states. Scroll to all credits with mouse, keyboard and
   touch; check external permission status and that underlying state remains unchanged.
9. Tab and Shift+Tab through each state. Activate with Enter and Space. Test the complete
   Escape hierarchy and restoration to the preview launcher.
10. At all three sizes inspect text, local scrolling, full photo aspect ratios and
    reachable Close buttons. At 854×480, topic interpretation should be visible first;
    scroll its panel for the space introduction. On physical phones/tablets verify
    touch comfort and browser scaling; desktop synthetic touch is not a device review.
11. Rapidly switch Lobby → Executive → Legislative → Comparison → Executive → Lobby.
    Close while a viewer is fading and reopen. Confirm no stale images, topics or focus.
12. Press **F8** to stop. Do not stage or commit as part of this milestone review.

## Initial repository state and preservation

HEAD was `0df927b` (`feat: implement PPC-INT-01 Capitol recovery and preservation hotspot`).
Before implementation:

```text
 M project.godot
?? assets/landmarks/pangasinan_provincial_capitol/audio/ppc_int_02_narration.ogg
?? assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02/
?? docs/references/
```

`project.godot` and `docs/references/` were pre-existing unrelated changes. Original
tracked and untracked files were SHA-256 baselined before creating this milestone.
The final audit found **zero changes across all 708 pre-existing files**, including
the supplied originals, completed Capitol hotspots, all other landmarks,
`project.godot` and `docs/references/`. No unrelated Godot serialization noise occurred.
No restore, reset, staging, commit or push is part of this work.

## Outstanding review items

- Lobby and Governor's Office external-media permission/reuse documentation remains pending.
- Lobby source resolution limits detail when enlarged; original media remains unchanged.
- Physical touchscreen/Web export review and researcher F6 acceptance remain manual.
- This Windows Godot environment reports a root-certificate-store warning during local
  startup. It does not prevent importing or playing the supplied local media.
## Final verification record

Rendered Compatibility validation passed **2,110 checks, zero failures**, with exit 0.
All three viewport sizes passed. The run produced 45 screenshots covering main views,
all topics, each documentary viewer and Sources; representative captures were visually
reviewed, including compact comparison and all three supplied documentary photographs.
Headless validation also exited 0. No PPC-INT-02 ObjectDB leak warning was reported.

The additional final checks cover compact interpretation touch scrolling and removal
of stale photo textures after crossfades. Source/content safety search found no
prohibited political or feature strings. `git diff --check` and whitespace checks
for all 16 new text/source/import/UID files passed. No files are staged.

Final `git status --short`:

```text
 M project.godot
?? assets/landmarks/pangasinan_provincial_capitol/audio/ppc_int_02_narration.ogg
?? assets/landmarks/pangasinan_provincial_capitol/audio/ppc_int_02_narration.ogg.import
?? assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02/
?? data/landmarks/pangasinan_provincial_capitol/ppc_int_02.tres
?? docs/ppc_int_02_testing.md
?? docs/references/
?? scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02.tscn
?? scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02_preview.tscn
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02.gd
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02.gd.uid
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02_canvas.gd
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02_canvas.gd.uid
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02_preview.gd
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02_preview.gd.uid
?? tests/ppc_int_02_test.gd
?? tests/ppc_int_02_test.gd.uid
```

READY FOR RESEARCHER F6 REVIEW: YES
