# UH-INT-04 — Conference Room testing

## Scope
Standalone educational concept interaction and inset development preview only.
No master interior integration, previous-hotspot changes, event carousel, timeline,
progression, completion tracking, game mechanics, analytics, or unsupported history.

## Files
Created:
- scenes/components/conference_room_interaction.tscn
- scripts/components/conference_room_interaction.gd
- scripts/components/conference_room_content.gd
- scripts/components/conference_room_concept_entry.gd
- data/landmarks/urduja_house/uh_int_04.tres
- scenes/landmarks/urduja_house/interior/uh_int_04.tscn
- docs/uh_int_04_testing.md

Godot generates .gd.uid sidecars for the three scripts and .import sidecars for
the supplied illustration, narration, and reference image. The reference photograph
is not assigned to the visitor component or content resource. No media was created,
downloaded, replaced, or renamed.

## Architecture
ConferenceRoomInteraction:
- Main / Margin / Layout
  - Header: Title, Close
  - Columns
    - Image (stable aspect-fit illustration)
    - Information: Heading, local Scroll/Text (Body, Takeaway), SourcesButton
  - Controls: Speaker
  - Sections: PublicInterior, OfficialFunction, WhyItMatters
- Sources: parent-sized overlay, title, scrollable source context, Close Sources
- NarrationPlayer: one AudioStreamPlayer

Preview:
- UH_INT_04_Preview
  - Background
  - Margin / Layout: title, development note, opening prompt
  - HotspotFrame: 5% inset on each side
    - ConferenceRoomInteraction: fills parent rectangle

The reusable component uses full-rect anchors, Containers, 12px margins and local
scrolling. It never positions from viewport dimensions. Viewport access is only
for focus and safe input handling. Illustration filtering is nearest; TextureRect
uses aspect-fit with no stretching, cropping, or artificial zoom.

Public methods:
open_interaction() -> bool, close_interaction(), select_concept(index),
get_selected_concept() -> int, open_sources(), close_sources(),
toggle_narration(), stop_narration().

Signals:
opened, closed, concept_changed(index), narration_started, narration_stopped,
sources_opened, sources_closed.

ConferenceRoomContent:
hotspot_id, title, prompt, illustration, illustration_alt_text, narration_stream,
narration_transcript, learning_takeaway, source_credit, concepts.
ConferenceRoomConceptEntry:
heading, body, show_takeaway.

Historical content is stored in the .tres, not generic behavioral GDScript.
The transcript is preserved in data and is not permanently displayed in the panel.

## Exact media and accessibility
Illustration:
res://assets/landmarks/urduja_house/interior/uh_int_04_conference_room_pixel_art.png

Narration:
res://assets/landmarks/urduja_house/audio/uh_int_04_narration.ogg

Speaker:
res://assets/ui/icons/speaker.svg

Exact accessibility description:
“Pixel-art illustration of the Conference Room inside Urduja House, showing a long central conference table surrounded by chairs, wood-paneled interior surfaces, curtained windows, ceiling lighting, and a display screen at the far end of the room.”

## Approved concept content
PUBLIC INTERIOR / Public Interior:
“This conference room forms part of the publicly accessible interior of Urduja House.”

OFFICIAL FUNCTION / Official Function:
“Together with the reception spaces and Ceremonial Hall, it reflects the continuing use of Urduja House for selected government functions.”

WHY IT MATTERS / Why It Matters:
“Its inclusion helps visitors understand that the building is both historically important and presently active.”

Only Why It Matters displays the supporting takeaway in gold text:
“Urduja House remains a functioning government residence rather than only a historical display.”

No reward, completion or required sequence is associated with this emphasis.
Only one concept button is pressed at a time; selected styling combines gold and a
stronger border. Keyboard focus has an additional outline. Text changes fade in
over 180ms, canceling the previous tween; the illustration stays stable.

## Exact source-credit wording
Historical / Educational Content
Validated AKAR Urduja House Conference Room hotspot content.

Visitor-Facing Illustration
Pixel-art illustrative representation created for the AKAR Capstone Project.

Visual Reference
Based on a Conference Room photograph published by the Province of Pangasinan in connection with:

"PPC Interim Governing Board approves curricula of four academic programs"

Reference Status
Used as a visual/layout reference.

Sources prefixes this shared credit with the selected concept heading.
This identifies the Province as publisher of the photographic reference, not creator
of the pixel-art illustration. No photographer, publication date, copyright owner,
license, permission, archival status, or historical year is asserted.
The researcher-supplied reference page is recorded in the approved specification:
https://www.pangasinan.gov.ph/author/pixelpgsnadmin/page/21/
No additional facts were retrieved from the website or inferred from the image.

## Narration verification limitation
The supplied UH-INT-04 OGG is byte-identical to UH-INT-01, UH-INT-02 and UH-INT-03:
SHA256 5E44ADB87270F4DC7586CF026902718C597544C394376FC0FDEFE1E38FA4BD44.
Playback success does not verify its spoken content. Manual listening is REQUIRED.
The requested file was retained unchanged; no speech was generated or transcribed.

Compare the complete recording against this approved transcript:
“This conference room forms part of the publicly accessible interior of Urduja House. Together with its reception and ceremonial spaces, it reflects the continuing official function of the residence.”

## Exact F6 instructions
1. Open this repository's project.godot in Godot 4.7.2; let imports finish.
2. Open res://scenes/landmarks/urduja_house/interior/uh_int_04.tscn.
3. Press F6 (Run Current Scene).
4. Click/tap “Discover its continuing function”, or activate the focused prompt
   using Enter/Space.
5. Confirm Conference Room is upper-left, Close upper-right, PUBLIC INTERIOR is
   selected, illustration appears, and narration is silent.
6. Repeat the checks below at application sizes 1280×720, 960×540 and 854×480.
   Use the embedded game sizing controls or a resized run window without saving
   project-setting changes.
7. The default parent is inset by 5% on each side. In the Remote scene tree select
   UH_INT_04_Preview/HotspotFrame. To compare full-size layout, temporarily set
   anchors Left/Top to 0 and Right/Bottom to 1, keeping offsets 0. Restore anchors
   to 0.05/0.05/0.95/0.95 for embedded checks. Remote changes are not saved.
8. The headless tests also used actual logical canvas sizes, not just scaled screenshots.

## Manual checklist
### Concepts and image
- Public Interior: exact heading/body above, default on every open, Sources works.
- Official Function: exact heading/body; illustration remains unchanged.
- Why It Matters: exact heading/body plus the approved takeaway; no achievement cue.
- Freely switch in any order; exactly one button selected, no progress tracking.
- Check illustration aspect ratio and crisp pixels visually at each size.
- No archival label, room-object markers, reference photograph or extra interpretations.
- Right text scrolls locally when needed; fonts remain readable.

### Narration
- Listen to the full recording and compare against the approved transcript above.
- No autoplay; one speaker only, reusing speaker.svg.
- Tap once: starts at zero, active gold state. Tap again: stops/reset.
- Natural completion: inactive; next play begins at zero.
- Switch all concepts during playback: stream, position and playback continue.
- Open/close Sources during playback: audio continues.
- Close complete interaction: audio stops/reset; reopen: silent, Public Interior selected.
- No Pause/Resume/Restart controls.

### Sources and back
- Sources includes current concept heading and the exact shared source text above.
- Pixel-art credit and photographic reference are clearly separate.
- No invented photographer/date/license or bracket placeholder.
- Escape or Backspace closes Sources first; a second closes the interaction.
- Close Sources returns focus to Sources; complete close returns focus to the prompt.
- Close remains at the upper-right; Sources stays in the right content region.

### Keyboard and touch
- Tab/Shift+Tab traverse concept controls, speaker, scroll area, Sources and Close.
- Enter/Space activate focused buttons. Focus outline remains visible.
- Sources confines Tab focus to its scroll and Close Sources.
- Escape/Backspace consume input before closing signals.
- Tap every control on an actual museum tablet/phone browser; no hover dependency.
- Close, Sources, concepts and Close Sources have at least 48px targets; speaker 56×56.

### Layout and reliability
- Test all concepts and Sources at all three application sizes, full-size and inset.
- Illustration remains visible, columns do not overlap, controls fit the parent.
- Headings, body and takeaway remain readable; scroll to see any overflow.
- Rapidly select concepts: last selection wins, final opacity returns to 1.
- Repeatedly open/close Sources, play/stop narration, and open/close the hotspot.
- No duplicate UI, stuck focus, stale content, Godot errors or unintended navigation.

## Validation results
Godot 4.7.2 headless editor import and runtime tests passed with zero failures.
- 1280×720: full-size and 1152×648 inset parent passed.
- 960×540: full-size and 864×486 inset parent passed.
- 854×480: full-size and 768.6×432 inset parent passed.
- Exact concept text, transcript, takeaway and alt text checked against specification.
- Mouse, keyboard and synthetic touch activation passed.
- Audio continuity, stop/reset, natural completion and silent reopen passed.
- Parent sizing, control bounds, column non-overlap, local scroll space, 48px targets,
  56px speaker, focus/back, source context and rapid selection passed.

These checks do not establish audible transcript accuracy, physical touchscreen
behavior, rendered image quality or Web export performance. Perform the manual checks.
Resource paths, git diff --check and separate new-file whitespace checks passed.
All pre-existing files retain their pre-edit hashes, including project.godot,
previous hotspots and the already modified docs/specifications/uh_ext_03.md.
No project serialization changes occurred. Git status contains the pre-existing
exterior-specification change and supplied UH-INT-04 files, plus this milestone's
new implementation/data/docs and generated import/UID sidecars. No commit or push.
