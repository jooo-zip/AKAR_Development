# PPC-INT-01 — Damage, Rebuilding, and Preservation

## Scope and numbering

This milestone uses the current approved sequence: PPC-INT-01 is the historical transformation viewer, superseding older Governor's Gallery numbering. It implements no Governor's Gallery, entrance video, other hotspot, reflection screen or Capitol master layout.

The five directly accessible periods are 1945 War Damage; 1946–1949 Reconstruction; 2003 Architectural Recognition; 2008 Refurbishment; and 2018 Heritage Protection. Chronology organizes evidence without gating, completion, visited indicators, rewards or compulsory progression.

## Implementation and reuse

New files:
- data/landmarks/pangasinan_provincial_capitol/ppc_int_01.tres
- scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01.tscn
- scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01_preview.tscn
- scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01.gd
- scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01_canvas.gd
- scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01_preview.gd
- tests/ppc_int_01_test.gd
- docs/ppc_int_01_testing.md

The shared ConferenceRoomInteraction shell supplies heritage styling, Sources, narration signals/player and host focus restoration. Existing ConferenceRoomContent/ConferenceRoomConceptEntry Resource types store interpretation and media metadata. Completed Capitol production files were inspected but not modified or subclassed. The controller builds a chronology-oriented workspace with a lower date rail, separate from the earlier exterior interactions. The standalone preview instantiates the real production component and restores its host canvas policy on exit.

The Casa Real comparison control was audited for mouse/touch/keyboard input and drag cleanup. Its restoration/crossfade presentation does not fit the supplied historical viewpoints, so PPC-INT-01 has its own canvas drawing two independent frames.

## Supplied asset audit

Paths are exact repository-relative paths. All media and their .import files existed at task start. Images were visually inspected. No media was renamed, converted, cropped destructively, edited or re-encoded.

| Exact path | Format | Dimensions / duration | Aspect ratio | Bytes | Import |
| --- | --- | --- | --- | ---: | --- |
| assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01/ppc_int_01_1945_damage.png | PNG | 711×376 | 1.890957 | 261,977 | Existing sidecar; loads successfully |
| assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01/ppc_int_01_2003_recognition.png | PNG | 1894×876 | 2.162100 | 318,881 | Existing sidecar; loads successfully |
| assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01/ppc_int_01_2008_refurbished.png | PNG | 645×409 | 1.577017 | 402,893 | Existing sidecar; loads successfully |
| assets/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01/ppc_int_01_2018_heritage_protection.png | PNG | 691×1068 | 0.647004 | 510,818 | Existing sidecar; loads successfully |
| assets/landmarks/pangasinan_provincial_capitol/audio/ppc_int_01_narration.ogg | Ogg Vorbis | 40.874668 seconds | N/A | 366,588 | Existing sidecar; decodes successfully |
| assets/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01/ppc_ext_01_government_today.jpeg | JPEG | 4032×2055 | 1.962044 | 2,065,719 | Existing direct reference |

The main present-day JPEG is referenced directly for overview and reconstruction context; it is not duplicated.

### Comparison decision: dual-image comparison

The 1945 photograph is a distant waterfront view, with the damaged building occupying only part of the frame. The 2008 photograph is a much closer oblique view from the grounds, with a different perspective, coverage and aspect ratio. A true overlay reveal would imply alignment that these images cannot support.

Two independent aspect-fitted frames preserve each entire photograph. A vertical divider changes their relative widths. The left frame is 1945 — WAR DAMAGE; the right is 2008 — REFURBISHED CAPITOL. Default comparison_amount is 0.50, bounded to [0,1]. At an extreme one frame can disappear; this has no completion meaning. No mirroring, geometric warping or digital rebuilding is used.

The comparison represents long-term physical transformation to the later refurbished appearance. It does not identify the second photograph as reconstruction-era evidence. The original low resolutions limit fine detail; enlargement cannot recover detail that is absent.

### Media roles and historical limits

- 1945: supplied war-damage photograph, with the exact approved caption.
- Reconstruction: no verified reconstruction photograph was supplied. A present-day view is explicitly labeled contextual and never relabeled as historical reconstruction evidence.
- 2003: screenshot with See Pangasinan branding and recognition text; VIEW SOURCE opens it unchanged.
- 2008: supplied refurbished-building photograph; exact approved June inauguration attribution.
- 2018: supplied certification page for Provincial Ordinance No. 220-2018; VIEW DOCUMENT opens it unchanged.

The 2003 screenshot and 2018 document contain earlier historical context in their original pixels. Those supplied sources remain unedited evidence; the visitor interpretation and date rail do not add the earlier periods. The 2018 interpretation uses the locked heritage-site wording and preservation funding; it does not expand the claim based on the scanned document's title.

## Exact visitor interpretation

Title: DAMAGE, REBUILDING, AND PRESERVATION

Context: THE CAPITOL THROUGH CHANGE

### overview

Heading: FROM WARTIME RUINS TO PRESERVATION

The Pangasinan Provincial Capitol experienced wartime destruction, postwar reconstruction, later refurbishment, and formal heritage protection. Explore five moments that shaped the building after 1945.

Supporting text: SELECT A YEAR TO TRACE WHAT CHANGED.

Caption: Present-day contextual view of the Pangasinan Provincial Capitol.

Credit/source: Photo: AKAR Research Team Research-team-produced documentary photograph.

### damage_1945

Heading: THE CAPITOL IN RUINS

During the liberation of Pangasinan in January 1945, the Capitol was left in ruins. Its surviving structure later made reconstruction possible.

Caption: Pangasinan Provincial Capitol after wartime damage, 1945.

Credit/source: Researcher-supplied historical photograph. Creator not identified in available source.

### reconstruction_1946_1949

Heading: REBUILDING THE CAPITOL

Postwar rebuilding received assistance associated with the Philippine Rehabilitation Act under Governor Enrique Braganza, and the Capitol was reconstructed in 1949.

Supporting text: Reconstruction restored the Capitol while preserving its neoclassical character and its role as the province's administrative center.

Caption: Present-day contextual view; no verified reconstruction photograph was supplied.

Credit/source: Photo: AKAR Research Team Research-team-produced documentary photograph.

### recognition_2003

Heading: ARCHITECTURAL RECOGNITION

The Capitol was recognized as one of the Eight Architectural Treasures of the Philippines by Filipino Heritage Festival, Inc., an NCCA grantee.

Caption: Researcher-supplied source excerpt documenting the Capitol's architectural recognition.

Credit/source: Source shown in supplied screenshot: See Pangasinan. Creator not identified in available source.

### refurbishment_2008

Heading: A REFURBISHED CAPITOL

The refurbished Capitol building was inaugurated in June 2008 under Governor Amado T. Espino Jr.

Supporting text: Compare the wartime-damaged Capitol with its later refurbished appearance.

Caption: Refurbished Pangasinan Provincial Capitol, 2008.

Credit/source: Researcher-supplied photograph. Creator not identified in available source.

### protection_2018

Heading: HERITAGE SITE PROTECTION

Provincial Ordinance No. 220-2018 declared the Capitol a heritage site in the Province of Pangasinan and provided funds for its preservation.

Caption: Certification page for Provincial Ordinance No. 220-2018.

Credit/source: Source shown on supplied document: Office of the Sangguniang Panlalawigan Secretary, Province of Pangasinan. Researcher-supplied documentary copy.

Comparison instruction: DRAG TO COMPARE.

## Historical sources and rights

The exact supplied copy is the authority for visitor interpretation. The Sources modal categorizes HISTORICAL SOURCES and DOCUMENTARY MEDIA and references the approved AKAR Historical Information Validation Sheet and Historical Profile of Pangasinan Provincial Capitol, the researcher-approved sequence, recognition attribution and ordinance.

Recognition is attributed to Filipino Heritage Festival, Inc., an NCCA grantee. The implementation does not substitute NCCA as the recognizing organization. The 2018 body is the exact approved statement about a heritage site in the Province of Pangasinan and preservation funding.

Credits describe only what is known:
- 1945 and 2008: researcher-supplied photographs; “Creator not identified in available source.”
- 2003: See Pangasinan branding visible in the supplied screenshot; creator not identified.
- 2018: Office of the Sangguniang Panlalawigan Secretary, Province of Pangasinan, as printed on the supplied certification page.
- Present-day context: Photo: AKAR Research Team; research-team-produced documentary photograph.

No external photograph is claimed to be AKAR-owned, public domain, or licensed for reuse. External media permission/license documentation was not supplied and remains unresolved. No invented photographer, copyright owner, certificate, award art or ordinance document was created.

## Narration

The supplied OGG was preserved without conversion or re-encoding. The researcher explicitly confirmed in this chat that its narration was already checked against the approved wording. No automated speech transcription was available; the historical audio assurance is that researcher confirmation, while import, duration, decoding and production playback are checked technically.

No autoplay. LISTEN toggles STOP. Period changes, direct divider manipulation, source-viewer open/close and Sources do not restart, pause, stop or seek narration. Full hotspot close stops/resets it; reopening is silent. Missing-stream fallback leaves LISTEN visible/disabled and shows “Narration pending.”

## State, modal behavior and input

select_history_period is the sole period authority. comparison_amount remains local to the open session. media_view_open, media_id and media_origin_period describe the single source viewer. Rapid period selection cancels old Tweens; the most recent image, caption and interpretation win. No Resource is saved back to disk.

One HISTORICAL SOURCE viewer is reused for 1945, 2003 and 2018. It opens with CLOSE focused, displays the exact supplied image, title, caption and credit, and offers ENLARGE/FIT. Enlargement preserves aspect ratio and the complete source; image scrolling supports document reading. Focus stays in the viewer, and closing restores the opening button. Background period, comparison, narration-toggle and Sources actions are blocked while the viewer is open, including its closing fade. Only one modal is active at a time.

Mouse and touch directly manipulate the comparison. Its visible line is narrow, but the divider's effective region is 56px wide; the canvas also accepts broader positioning gestures. Left/Right changes the focused comparison by 0.10; Home/End chooses the bounds. No delayed slider Tween or percentage display is used.

Timeline buttons are at least 188×64px. Header/viewer/overview actions have at least 48px height. Tab/Shift+Tab moves through all periods, the comparison or relevant viewer action, overview, header controls and any local scroll area. Enter/Space activates buttons. Focus is a cream outline; selection is muted gold. No hover-only historical information.

Native touch dragging is explicitly handled for the date rail and local interpretation, Sources, image/document and credit scroll areas. The handler respects enabled axes, uses an 8px gesture threshold and cancels pending button presses when a scroll starts, so swiping does not select a date. Modal transitions and resets end active scroll gestures. This also works when the host does not advertise touchscreen availability. The cancellation convention was checked against the [Godot ScrollContainer implementation](https://github.com/godotengine/godot/blob/master/scene/gui/scroll_container.cpp).

Escape hierarchy:
1. Close Sources.
2. Close Historical Source.
3. Return a selected period to overview, retaining comparison memory.
4. Close the hotspot from overview.

The viewport input is marked handled before close/navigation signals.

Period interpretation fade: 200 ms. Historical canvas crossfade: 220 ms. Viewer opening/closing: 200 ms. Comparison: immediate. No battle simulation, effects, particles, glow loops or progression mechanics.

## Responsive and reset contracts

At 1280×720 and 960×540, historical media occupies approximately 67% of the central workspace with interpretation alongside it. At 854×480 the layout stacks media above a compact interpretation drawer and horizontally scrollable date rail. The date controls retain their touch sizes rather than shrinking to fit. Text uses local scrolling when necessary; the overall panel stays in bounds.

Photo fitting is calculated separately for each comparison frame. The divider is tied to the actual canvas and both frame boundaries, never viewport coordinates. Source images/documents remain aspect-preserving.

Full close or host hide resets selected_period=overview, comparison_amount=0.50, media IDs=none, both modals closed, narration stopped/reset, timeline/text/document scroll positions, transient crossfade images and all Tweens. No optional reconstruction expansion was added. Focus returns to the launcher; reopening begins with no selected date.

## Validation

Engine: Godot 4.7.2 stable; native Compatibility rendered tests and headless tests at 1280×720, 960×540 and 854×480. Runtime user data, logs and captures are redirected to temporary locations.

Commands:
```powershell
& $Godot --headless --path . --editor --import --quit
& $Godot --headless --path . --script res://tests/ppc_int_01_test.gd
& $Godot --path . --rendering-method gl_compatibility --script res://tests/ppc_int_01_test.gd -- --capture
git diff --check
git status --short
```

The suite dispatches mouse, native touch and keyboard input. It checks exact approved copy and media mappings, all direct-access orders, divider geometry/bounds, aspect ratios, source-viewer focus/isolation, narration continuity, rapid input, local memory, Escape, reset, visible control bounds and timeline scrolling. It scans production interpretation for unsupported claims and the obsolete heritage designation without embedding that designation literally in the test file.

Headless final result: **1,963 checks; 0 failures**, including native date-rail swiping and vertical touch panning of the enlarged ordinance at all three sizes.

Rendered final result: **2,005 checks; 0 failures**, across 1280×720, 960×540 and 854×480. This includes 42 capture checks (39 distinct PNGs; a repeated period intentionally overwrites its capture). Source-fit/enlarged views, comparison geometry, date-rail swiping and ordinance touch panning passed. Captures remain in the temporary directory as ppc_int_01_<width>_<state>.png, not production assets.

Final Godot import/parse validation: **exit 0**, no GDScript or Resource parse errors. Final git diff --check and separate whitespace checks for new untracked text files: **pass**.

| Regression suite | Result |
| --- | --- |
| PPC-EXT-01 | 2,487 checks; 0 failures; exit 0 |
| PPC-EXT-02 | 1,975 checks; 0 failures; exit 0 |
| CR-EXT-01 | 1,983 checks; 0 failures; exit 0 |
| CR-EXT-02 | 1,897 checks; 0 failures; exit 0 |
| CR-EXT-03 | 5,431 checks; 0 failures; exit 0 |
| CR-INT-01 | 2,287 checks; 0 failures; exit 0 |
| CR-INT-03 | 3,853 checks; 0 failures; exit 0 |
| LC-EXT-01 | 0 failures; exit 0 |
| LCH-EXT-01 | 0 failures; exit 0 |
| LCH-EXT-02 | 0 failures; exit 0 |
| LCH-EXT-03 | 0 failures; exit 0 |

No completed-hotspot code or tests were changed. LCH-EXT-01 and LCH-EXT-02 retain their existing exit warnings about two and three ObjectDB instances respectively. PPC-INT-01 reports no such leak warning. Test teardown waits briefly for the asynchronous audio mixer to release stopped playback.

Rendered review identified and corrected a first-selection container-reflow overflow. Geometry assertions now require the historical canvas to stay within its media container and above the chronology rail. The final layout preserves complete source images and meaningful date controls at each size.

## Manual F6 researcher review

1. Open scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01_preview.tscn and press F6. Confirm overview, no selected date and no autoplay.
2. Resize to all three target sizes. At 854×480, swipe the date rail horizontally and verify that swiping does not accidentally select a date.
3. Visit 2018 → 1945 → 2003, then 2008 → 1946–1949 → 2018. Confirm unrestricted selection and exact period attribution.
4. In 2008, drag the divider with mouse/touch; try Left/Right and Home/End. Confirm full photographs remain undistorted in independent frames and the labels identify the correct endpoints.
5. Move to another period and return. Confirm divider memory. Close and reopen; confirm midpoint reset.
6. Review the 1945 image, 2003 screenshot and 2018 document using VIEW IMAGE/SOURCE/DOCUMENT. Try ENLARGE/FIT and scroll the original evidence. Confirm captions and known credits.
7. Use Tab/Shift+Tab and Enter/Space. Verify modal focus trapping, return focus and the four-step Escape hierarchy.
8. Start narration and change dates, drag, open/close viewers and Sources. Listen for uninterrupted content; stop and close/reopen to verify reset.
9. Inspect the source documents' legibility and the supplied low-resolution photographs on the intended museum device.
10. Stop for researcher approval; no additional Capitol feature or commit is part of this milestone.

## Repository preservation and limitations

Initial git status:
```text
?? assets/landmarks/pangasinan_provincial_capitol/audio/ppc_int_01_narration.ogg
?? assets/landmarks/pangasinan_provincial_capitol/audio/ppc_int_01_narration.ogg.import
?? assets/landmarks/pangasinan_provincial_capitol/interior/
?? docs/references/
```

Every tracked and non-ignored untracked pre-existing file, including supplied media/import sidecars, was SHA-256-baselined before implementation. No unrelated Resource is intentionally saved. Final status/hash comparison guards against Godot serialization noise.

Final comparison: **zero changed or missing pre-existing files**. PPC-EXT-01, PPC-EXT-02, all completed other landmarks, shared components, project.godot, and docs/references/ are unchanged. No unrelated reserialization noise was found. No staging, commit, push, restore, reset or deletion was performed; the Git index remains empty.

Exactly 12 milestone files were added: the eight source/data/scene/test/documentation files above and four GDScript .uid sidecars. No new image/audio asset or media import sidecar was created; all supplied assets and their existing sidecars were preserved.

Final git status --short:

```text
?? assets/landmarks/pangasinan_provincial_capitol/audio/ppc_int_01_narration.ogg
?? assets/landmarks/pangasinan_provincial_capitol/audio/ppc_int_01_narration.ogg.import
?? assets/landmarks/pangasinan_provincial_capitol/interior/
?? data/landmarks/pangasinan_provincial_capitol/ppc_int_01.tres
?? docs/ppc_int_01_testing.md
?? docs/references/
?? scenes/landmarks/pangasinan_provincial_capitol/interior/
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01.gd
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01.gd.uid
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01_canvas.gd
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01_canvas.gd.uid
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01_preview.gd
?? scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01_preview.gd.uid
?? tests/ppc_int_01_test.gd
?? tests/ppc_int_01_test.gd.uid
```

Known environment diagnostic: Windows Godot reports failure reading the root certificate store; local import/playback/scene tests do not use network certificates. Browser export, physical-device behavior and subjective source legibility remain manual review items. The supplied historical photographs have limited resolution, and external media rights remain undocumented.
