# UH-INT-04 Phase 5 testing

Updated 4 October 2026. Supersedes the earlier revision-specific testing steps for this hotspot.

Production and visual editing: `res://scenes/landmarks/urduja_house/components/uh_int_04.tscn`.
F6 harness: `res://scenes/landmarks/urduja_house/interior/uh_int_04.tscn`.
Approved content: `res://data/landmarks/urduja_house/revision/uh_int_04.tres`.

## Exact F6 retest

1. In Godot 4.7.2, open the F6 harness above from FileSystem. Press **F6 (Run Current Scene)**. Default selection: **EXPLORE THE SPACE**. Narration is enabled but silent until requested.
2. Select each mode with mouse, touch, Tab/Shift+Tab and Enter/Space; focused mode buttons also support arrow navigation: EXPLORE THE SPACE / DOCUMENTED USE / WHY IT MATTERS. Selection remains optional. Try repeated and rapid input.
3. EXPLORE THE SPACE starts with “Explore the Conference Room” and “Select an area to observe how the room is arranged for meetings and continuing official use.” There is no prominent artwork disclaimer or image caption in this mode. MEETING TABLE and SEATING ARRANGEMENT show their approved interpretations and restrained spatial outlines; OVERALL ROOM SETTING removes the outline and displays its interpretation/supporting line. Resize with a focus active and check alignment. DOCUMENTED USE switches to the official photograph and supplied article/photographer metadata in Sources. WHY IT MATTERS retains documentary evidence. No historical meaning is assigned to furniture.
4. Activate LISTEN: it starts at zero. Activate again to stop/reset. Replay starts at zero. Let the recording finish naturally and verify the button returns idle. Change modes and open Sources while listening: playback continues. Closing the hotspot stops/resets it.
5. Open SOURCES; inspect the relevant historical references and media credits below. Use CLOSE SOURCES, Escape, and Backspace. These close only Sources; they preserve the selected mode. The next back action closes the hotspot.
6. Close during a transition and narration. Activate **OPEN UH-INT-04 PREVIEW**. Verify default mode, fully visible image/text, initial local scroll, no stale pointer/outline/carousel state, and no autoplay.
7. Repeat at **1280×720, 960×540, 854×480**, with both a full Control parent and the harness's 5% inset parent. Resize while open. All content remains accessible; compact layouts use local information scrolling. Targets remain at least 48px tall. No whole-page scrolling or cropped controls.

## Production handoff and visual editing

Instance only the production scene under an ordinary Control; the harness is not a dependency. Call `open_interaction() -> bool`. Connect `closed`; optional `opened`. Call `close_interaction()` to close/reset, or `reset_interaction()` to reset while retaining open status. No avatar, map, master scene, autoload, or environment coordinate is required. The production component never changes the application window or viewport settings.

Open the production TSCN directly in Godot's 2D editor. Select Panel/MainMargin, MainVBox, Content, BodyRow, MediaColumn, MediaFrame, InfoScroll, Navigation and TakeawayMargin. Adjust margins, separations and column stretch ratios in the Inspector, then run and confirm they persist. Scene-authored Containers determine static geometry. The editor content-binding helper fills approved labels/textures only; it does not create a fake layout. Runtime controls selection, fade alpha, focus/local scroll and audio; hotspot-specific moving media overlays use the fitted image rectangle.

## Assets and attribution

- `res://assets/landmarks/urduja_house/interior/uh_int_04_conference_room_pixel_art.png`
- `res://assets/landmarks/urduja_house/interior/uh_int_04_conference_room.png`

Narration: `res://assets/landmarks/urduja_house/audio/uh_int_04_narration.ogg`.

Project-created interpretive representation
Source: AKAR Team. Not documentary evidence. Individual artist, creation date and permission/license unresolved.

Documentary photograph: Provincial Government of Pangasinan, “PPC Interim Governing Board approves curricula of four academic programs”. Photo courtesy: Pangasinan Polytechnic College; Chona C. Bugayong / PIMRO. Repository source URL: https://www.pangasinan.gov.ph/author/pixelpgsnadmin/page/21/ . Capture date and permission/license unresolved.

Narration: researcher-supplied and approved despite duplicate detection. Recording credit/rights unresolved.

The researcher explicitly accepts the duplicate narration files. Automated checks verify playback state, reset and signals; they do not verify spoken words against the transcript. Physical-device listening and touch are manual checks. No new narration or source/permission claim was invented.

## Automated checks

Run `godot --headless --max-fps 60 --path . --script res://tests/uh_remaining_phase5_test.gd -- uh_int_04`. Omit `--headless` for Compatibility rendering and PNG captures. Add `--editor` for the actual editor-layout/Inspector check. The suite instantiates production independently, checks every mode across the six size/parent combinations, tests input/audio/Sources/close/reopen, and separately exercises the F6 harness. Final totals and environment diagnostics are in `docs/urduja_house_remaining_hotspots_phase5_report.md`.


## Exact corrected interpretation

**MEETING TABLE — A Central Space for Discussion**

The large central table provides a shared setting for formal discussions and meetings. Its central placement allows participants to gather around a common discussion area.

**SEATING ARRANGEMENT — Clearer Sightlines Around the Table**

The curved arrangement of the table and surrounding seating creates clearer sightlines across the room, allowing participants to face one another more directly with less visual obstruction.

**OVERALL ROOM SETTING — A Formal Meeting Environment**

The conference room combines a large central meeting table, surrounding seating, formal interior finishes, and an organized layout suited to official discussions and administrative meetings.

Supporting line: Together with the Ceremonial Hall and other reception spaces, the room helps show that Urduja House remains connected with continuing government functions.

**DOCUMENTED USE — The Conference Room in Use**

An official Provincial Government photograph documents the conference-room space being used during an institutional meeting, providing visual evidence of its continuing administrative function.

**WHY IT MATTERS — A Continuing Government Function**

Together with the reception and ceremonial spaces, the conference room helps demonstrate that Urduja House remains connected with continuing provincial government functions.

The takeaway remains unchanged. Check that “AKAR Interpretive View” is absent from the main visitor UI. Sources retains the project-created interpretive representation / AKAR Team disclosure and the official photo credit: Provincial Government of Pangasinan; photo courtesy Pangasinan Polytechnic College; Chona C. Bugayong / PIMRO. No additional participant, event, architect or historical design-intention claim is introduced. Narrow layouts use local text scrolling; verify the complete body, supporting line and all three observation buttons remain reachable. Keyboard Space/Enter and touch must select the same text as mouse activation.
