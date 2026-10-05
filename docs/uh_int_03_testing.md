# UH-INT-03 Phase 5 testing

Updated 4 October 2026. Supersedes the earlier revision-specific testing steps for this hotspot.

Production and visual editing: `res://scenes/landmarks/urduja_house/components/uh_int_03.tscn`.
F6 harness: `res://scenes/landmarks/urduja_house/interior/uh_int_03.tscn`.
Approved content: `res://data/landmarks/urduja_house/revision/uh_int_03.tres`.

## Exact F6 retest

1. In Godot 4.7.2, open the F6 harness above from FileSystem. Press **F6 (Run Current Scene)**. Default selection: **ABOUT**. Narration is enabled but silent until requested.
2. Select each mode with mouse, touch, Tab/Shift+Tab and Enter/Space; focused mode buttons also support arrow navigation: ABOUT / OFFICIAL EVENTS / EXPLORE SPACE. Selection remains optional. Try repeated and rapid input.
3. ABOUT shows the fitted hall photograph and approved explanation. OFFICIAL EVENTS starts at the March 5, 2025 courtesy call: Source: Province of Pangasinan. NEXT shows the December 1, 2024 Lotte scholarship awarding: Photo by Ghe_Anne C. Palaganas. PREVIOUS returns; rapid navigation must leave only the latest event visible. There are exactly two events. EXPLORE SPACE starts with “Explore the Ceremonial Hall” and “Select an area of the photograph to observe how the hall is arranged.” Select CENTRAL SPACE, SIDE SEATING and FRONT FOCAL AREA using the photo rings or their text buttons. Verify the approved observation heading/body each time. The 531×352 photograph remains fitted with no zoom, magnifier or artificial panning. The former passive instruction is removed. Reopen returns to ABOUT and resets the carousel.
4. Activate LISTEN: it starts at zero. Activate again to stop/reset. Replay starts at zero. Let the recording finish naturally and verify the button returns idle. Change modes and open Sources while listening: playback continues. Closing the hotspot stops/resets it.
5. Open SOURCES; inspect the relevant historical references and media credits below. Use CLOSE SOURCES, Escape, and Backspace. These close only Sources; they preserve the selected mode. The next back action closes the hotspot.
6. Close during a transition and narration. Activate **OPEN UH-INT-03 PREVIEW**. Verify default mode, fully visible image/text, initial local scroll, no stale pointer/outline/carousel state, and no autoplay.
7. Repeat at **1280×720, 960×540, 854×480**, with both a full Control parent and the harness's 5% inset parent. Resize while open. All content remains accessible; compact layouts use local information scrolling. Targets remain at least 48px tall. No whole-page scrolling or cropped controls.

## Production handoff and visual editing

Instance only the production scene under an ordinary Control; the harness is not a dependency. Call `open_interaction() -> bool`. Connect `closed`; optional `opened`. Call `close_interaction()` to close/reset, or `reset_interaction()` to reset while retaining open status. No avatar, map, master scene, autoload, or environment coordinate is required. The production component never changes the application window or viewport settings.

Open the production TSCN directly in Godot's 2D editor. Select Panel/MainMargin, MainVBox, Content, BodyRow, MediaColumn, MediaFrame, InfoScroll, Navigation and TakeawayMargin. Adjust margins, separations and column stretch ratios in the Inspector, then run and confirm they persist. Scene-authored Containers determine static geometry. The editor content-binding helper fills approved labels/textures only; it does not create a fake layout. Runtime controls selection, fade alpha, focus/local scroll and audio; hotspot-specific moving media overlays use the fitted image rectangle.

## Assets and attribution

- `res://assets/landmarks/urduja_house/interior/uh_int_03_hall_wide.png`
- `res://assets/landmarks/urduja_house/interior/uh_int_03_event_2025_03_05.png`
- `res://assets/landmarks/urduja_house/interior/uh_int_03_event_2024_12_01.jpg`

Narration: `res://assets/landmarks/urduja_house/audio/uh_int_03_narration.ogg`.

Hall photograph: official See Pangasinan / PTCAO tourism website, per researcher. Individual photographer and permission/license undocumented.

March 5, 2025: Courtesy Call of the Dagupan City Prosecutor’s Office and Pangasinan Provincial Prosecutor’s Office. Source: official Province of Pangasinan. Photographer, exact source URL and permission/license unresolved in available repository record.

December 1, 2024: Ceremonial Awarding of Lotte Scholarships to Pangasinan Higher Education Institutions. Photo by Ghe_Anne C. Palaganas, per researcher-supplied metadata. Exact source URL and permission/license unresolved.

Narration: researcher-supplied and approved despite duplicate detection. Recording credit/rights unresolved.

The researcher explicitly accepts the duplicate narration files. Automated checks verify playback state, reset and signals; they do not verify spoken words against the transcript. Physical-device listening and touch are manual checks. No new narration or source/permission claim was invented.

## Automated checks

Run `godot --headless --max-fps 60 --path . --script res://tests/uh_remaining_phase5_test.gd -- uh_int_03`. Omit `--headless` for Compatibility rendering and PNG captures. Add `--editor` for the actual editor-layout/Inspector check. The suite instantiates production independently, checks every mode across the six size/parent combinations, tests input/audio/Sources/close/reopen, and separately exercises the F6 harness. Final totals and environment diagnostics are in `docs/urduja_house_remaining_hotspots_phase5_report.md`.


## Focused observation checks

- CENTRAL SPACE: **Open Central Area** — The hall has a broad open area running through its center, creating a clear visual path through the room.
- SIDE SEATING: **Seating Along the Hall** — Rows of chairs are arranged along the sides of the room, leaving the central area open.
- FRONT FOCAL AREA: **Front of the Hall** — The far end of the hall forms a strong visual focal area within the room.

Each marker has a 52×52 touch/focus target and a restrained 28px visible ring. Selected rings brighten; others soften. Check repeated/rapid selections, Tab/Shift+Tab and Enter/Space on both markers and text alternatives. Returning to EXPLORE SPACE restores the introductory state, without selecting a point automatically. Returning to ABOUT and both official events must preserve the established content and credits.

Editor: open the production scene directly in 2D, enable `ObservationAspect` under MediaFrame to inspect the overlay, and select ObservationPlane / ObservationMarker0–2 / Ring. Anchors are normalized to an AspectRatioContainer with the photo's 531:352 ratio, accounting for letterboxing at every parent size. Enable ObservationChoices to inspect its three scene-authored text buttons. Restore preview visibility before saving. Runtime changes only visibility, selection and text, not marker coordinates or sizes. No architectural or ceremonial symbolism is asserted.
