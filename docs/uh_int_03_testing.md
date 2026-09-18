# UH-INT-03 — Ceremonial Hall testing

## Scope and implementation
Parent-relative room/media interaction with a standalone development preview only. No lobby, interior/master scene, app navigation, analytics, completion tracking, or other milestone changes.

Files created:
- scenes/components/ceremonial_hall_interaction.tscn
- scripts/components/ceremonial_hall_interaction.gd
- scripts/components/ceremonial_hall_content.gd
- scripts/components/ceremonial_event_entry.gd
- data/landmarks/urduja_house/uh_int_03.tres
- scenes/landmarks/urduja_house/interior/uh_int_03.tscn
- docs/uh_int_03_testing.md

Godot generates .gd.uid sidecars for the three scripts. The five supplied media files have .import sidecars. Media and approved specification are researcher-supplied; their contents are not changed.

Component tree:
- CeremonialHallInteraction (Control)
  - Main (PanelContainer) / Margin / Layout (VBoxContainer)
    - Header: Title, Close
    - Columns: Image, Information (heading/Sources, scrollable detail/body)
    - ExplorationCaption: illustrative caption, visible only in Pixel-Art View
    - Controls: Speaker, spacer, EventControls, ViewControls, exploration Sources
    - Sections: About, Events, Space
  - Sources (fills the component’s parent-assigned rectangle): title, scrollable context/credits, Close Sources
  - NarrationPlayer (one AudioStreamPlayer)

The generic component holds behavior only; historical content is in the .tres.
Public methods: open_interaction() -> bool, close_interaction(), select_section(index),
select_event(index), select_space_view(index), open_sources(), close_sources(),
toggle_narration(), stop_narration().
Signals: opened, closed, section_changed(index), event_changed(index),
space_view_changed(index), narration_started, narration_stopped, sources_opened, sources_closed.

CeremonialHallContent fields: hotspot_id, title, prompt, body, hall_image,
hall_alt_text, pixel_art_image, pixel_art_alt_text, hall_source_credit,
pixel_art_source_credit, narration_stream, narration_transcript, events.
CeremonialEventEntry fields: event_id, event_title, date_label, venue,
participating_institution, image, image_alt_text, source_credit.
Empty credits represent unverified data, not validated ownership or permission.

## Exact supplied resources
- Hall / real-photo view: res://assets/landmarks/urduja_house/interior/uh_int_03_ceremonial_hall.png
- Event 1: res://assets/landmarks/urduja_house/interior/uh_int_03_event_01.png
- Event 2: res://assets/landmarks/urduja_house/interior/uh_int_03_event_02.jpg
- Illustration: res://assets/landmarks/urduja_house/interior/uh_int_03_room_pixel_art.png
- Narration: res://assets/landmarks/urduja_house/audio/uh_int_03_narration.ogg
- Speaker: res://assets/ui/icons/speaker.svg

Hall and Event 1 were supplied as PNG, not JPG. No files were renamed or downloaded.
Photos use linear filtering and aspect-fit; the illustrative view uses nearest filtering and aspect-fit.

## Content integrity
The About body and narration transcript are copied verbatim from the blockquotes in
docs/specifications/urduja_house/uh_int_03.md. The transcript remains in the content
Resource but is not shown in the main layout; no transcript overlay was added. No historical wording or approved specification was edited.

Event 1:
- ID: UH-INT-03-EVENT-01
- Title: Courtesy Call of the Dagupan City Prosecutor’s Office and Pangasinan Provincial Prosecutor’s Office
- Date: March 5, 2025
- Venue: Ceremonial Hall, Urduja House
- Participating institutions: Dagupan City Prosecutor’s Office; Pangasinan Provincial Prosecutor’s Office
- Image description: Official gathering inside the Ceremonial Hall of Urduja House.

Event 2:
- ID: UH-INT-03-EVENT-02
- Title: Ceremonial Awarding of Lotte Scholarships to Pangasinan Higher Education Institutions
- Date: December 1, 2024
- Venue: Ceremonial Hall, Urduja House
- Participating institution: pending verification; resource empty, visitor field omitted.
- Image description: Ceremonial scholarship awarding activity held inside Urduja House.

Both events' source, photographer/creator, original publication date, and usage basis
remain pending verification. No invented names, URLs, ownership, or permission were added.
The standalone scene explicitly enables development pending notices in Sources:
“DEVELOPMENT ONLY” and “Source metadata pending verification.”
The component defaults this option off.

Pixel-art caption and Sources use only the supplied clarification:
“Pixel-art illustrative representation of the Ceremonial Hall.”
No creation method, creator, archival status, historical date, or source ownership is asserted.

### Narration integrity finding — researcher review required
The requested UH-INT-03 OGG is byte-identical to UH-INT-01 and UH-INT-02 OGG assets:
SHA256 5E44ADB87270F4DC7586CF026902718C597544C394376FC0FDEFE1E38FA4BD44.
The exact supplied UH-INT-03 file is wired without replacement or editing.
Playback behavior is tested, but matching spoken audio to the approved transcript is NOT
verified. Listen and confirm the correct recording before production use.

## Exact F6 instructions
1. Open this repository's project.godot in Godot 4.7.2 and let imports finish.
2. In the FileSystem dock open res://scenes/landmarks/urduja_house/interior/uh_int_03.tscn.
3. Press F6 (Run Current Scene), not F5.
4. Activate “Explore the Ceremonial Hall” with a click/tap, or Enter/Space while focused.
5. Confirm the upper-left title is “Ceremonial Hall”, Close is upper-right, and
   ABOUT THE HALL is selected. The hall photo and approved text appear side by side.
6. Repeat the checks below at 1280×720, 960×540, and 854×480. Use the running game's
   embedded/custom size or a resized game window; do not save project-setting changes.
   The default HotspotFrame has 5% inset anchors on each side. Its component fills
   that parent; the outer background remains visible. The frame is preview-only.
7. For a full-size F6 comparison, stop the preview, select HotspotFrame in the scene
   tree, temporarily set its Layout anchors Left/Top to 0 and Right/Bottom to 1
   (all offsets remain 0), then press F6. Restore Left/Top to 0.05 and Right/Bottom
   to 0.95 after testing. Do not change project.godot.
8. For a runtime-only parent resizing check, use the Remote scene tree during F6:
   select UH_INT_03/HotspotFrame and adjust its anchors. Confirm the child follows
   the parent rectangle without viewport positioning. Remote changes are not saved.
   Keep enough landscape room for the three readable section buttons.
9. Test both full-size and inset frames at every requested application size.
   Headless validation used actual logical canvas sizes rather than scaled screenshots.

### About the Hall
- Real hall photo preserves proportions without stretching.
- Exact approved body appears by itself; no permanent narration transcript consumes space.
- Confirm narration_transcript remains unchanged in the content .tres Inspector.
- Sources opens the current hall context with a clearly temporary pending notice.
- Gold selected state has a stronger border; keyboard focus has an additional outline.
- Panel colors, text, and controls follow the existing interior hotspot conventions.

### Official Events
- Select OFFICIAL EVENTS; Event 1 appears first after opening the hotspot.
- The compact > arrow selects Event 2; another > wraps to Event 1.
- The compact < arrow wraps in reverse. Buttons 1 and 2 select those events directly.
- Both arrows have 48×48 minimum touch targets and accessible Previous Event / Next Event names.
- Selected event title, date, venue, supplied institution, image, and Sources all agree.
- Event 2 does not invent an institution. Long titles/metadata scroll within the right panel.
- Swipe is not implemented. Visible < / > and direct buttons work without hover.
- No auto-rotation, completion state, required order, or progression mechanic exists.
- Rapidly switch events; the final selected event must match all displayed information.
- Reentering Events retains the last selected event; reopening the whole hotspot resets to Event 1.

### View the Space
- Every selection of VIEW THE SPACE defaults to FULL HALL PHOTO.
- The right information column disappears so the aspect-fit image uses the full content
  width. Compare its larger visible presentation with About; no About paragraph repeats.
- Sources sits beside the view controls below the visual. Switching back to About or
  Events restores their right information panel and Sources button.
- PIXEL-ART VIEW shows the supplied illustration with nearest filtering.
- Check crisp appearance and proportions visually; it must not be described as archival.
- Sources identifies only the illustrative representation, without a fabricated creation method.
- Switching back restores the real hall photograph and hall Sources context.
- Rapid changes must settle to the latest selection at full opacity.

### Narration
- Exactly one speaker sits below the content and above the three section buttons.
- No autoplay on initial open or reopen.
- First tap plays from the beginning; selected gold state indicates playback.
- Second tap stops and resets. Next tap begins from zero.
- Natural completion returns the speaker to inactive.
- While playing, switch all three sections, both events, and both views, and open/close
  Sources. Audio must continue without seeking, restarting, stopping, or changing stream.
- Close the whole hotspot: narration must stop/reset. Reopen: silent, About selected.
- Listen against the approved transcript, particularly because of the duplicate-file finding.
- No separate Pause/Resume/Restart buttons exist.

### Sources, keyboard, and touch
- Check Sources for About, both events, Full Hall Photo, and Pixel-Art View.
- Escape or Backspace closes Sources first, then the complete hotspot on a second press.
- Close Sources restores focus to Sources; closing the whole hotspot restores prompt focus.
- Tab and Shift+Tab reach sections, current local controls, speaker, scroll area, Sources,
  and Close. Enter/Space activate focused buttons; arrow keys scroll focused text.
- Sources confines Tab focus to its own scroll area and Close Sources.
- Tap Close, Sources, speaker, all sections, Previous/Next, direct event buttons, and both
  view controls on a real touchscreen/browser. Godot's standard button mouse/touch
  behavior is used; no essential hover interaction exists.
- All essential controls are at least 48 logical pixels high; speaker is 56×56.
- At all three sizes and in the inset parent, controls remain inside the hotspot frame.
  About/Events keep two columns and locally scrolling text. Exploration uses the full
  image row. Close, Sources, speaker, arrows and section controls must never overlap.

### Reliability and validation
- Repeatedly open/close, open Sources, toggle narration, and rapidly change every selection.
- Check for no duplicate UI, stuck focus, stale metadata, or partly transparent final state.
- Transitions cancel/replace the current tween and fade the latest content in over 180 ms.
- Godot 4.7.2 headless editor import completed successfully.
- Automated runtime checks passed at all three logical sizes: scene/resource loading,
  exact approved text/transcript, mouse activation, event wrap/direct selection, image
  selection/filter mode, source context/focus confinement, Tab/Shift+Tab/Enter/Space,
  Escape/Backspace, audio continuity/stop/restart/natural finish, close/reopen, rapid
  input, viewport bounds and minimum button sizes.
- Headless checks do not establish physical touchscreen behavior, rendered image quality,
  audible transcript accuracy, or browser export performance; perform the manual checks.
- No intentionally modified project settings or existing milestone files.

## Embedded refinement verification
Modified only:
- scenes/components/ceremonial_hall_interaction.tscn
- scripts/components/ceremonial_hall_interaction.gd
- scenes/landmarks/urduja_house/interior/uh_int_03.tscn
- docs/uh_int_03_testing.md

The component already used full-rect parent-relative anchors and Containers; there was
no viewport-size positioning to remove. Those conventions are preserved. Margins are
now 12 px. Parent size drives the layout, including the Sources overlay. get_viewport()
is used only for focus and safe input handling, not sizing or positioning.

Preview structure:
- UH_INT_03
  - Background (outer application area)
  - Margin / Layout (development note and opening prompt)
  - HotspotFrame (anchors 0.05, 0.05 to 0.95, 0.95)
    - CeremonialHallInteraction (full rect relative to HotspotFrame)

About = learn; Events = browse; View the Space = explore. The correction preserves
historical data, event metadata, media paths, credits, narration stream and transcript.
No reusable component dimensions are copied from the preview frame.

Godot 4.7.2 headless runtime regression passed with zero failures:
- 1280×720 application: full-size and 1152×648 embedded parent.
- 960×540 application: full-size and 864×486 embedded parent.
- 854×480 application: full-size and 768.6×432 embedded parent.
- Default About, exact body only, preserved transcript data, correct photographs,
  both events, wrap/direct navigation, larger exploration image area, nearest pixel
  filtering, correct Sources context, parent containment, minimum touch areas.
- Mouse, Tab/Shift+Tab/Enter/Space, Sources focus confinement, Escape/Backspace,
  audio continuity/stop/reset/natural completion, silent reopen, rapid selections.

Physical touchscreen testing, rendered image inspection, and audible transcript
verification remain manual. The previously recorded duplicate-audio finding is unchanged.

project.godot already had input-event serialization and setting-order changes when
this correction began. Its bytes were preserved; no new serialization change occurred.
Git diff --check and separate whitespace checks for the four untracked edited files pass.
Git status still shows the pre-existing modified project.godot and untracked UH-INT-03
files/assets/specification/sidecars. No commit or push was performed.
