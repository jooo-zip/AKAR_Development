# UH-INT-01 Phase 5 testing

Updated 4 October 2026. Supersedes the earlier revision-specific testing steps for this hotspot.

Production and visual editing: `res://scenes/landmarks/urduja_house/components/uh_int_01.tscn`.
F6 harness: `res://scenes/landmarks/urduja_house/interior/uh_int_01.tscn`.
Approved content: `res://data/landmarks/urduja_house/revision/uh_int_01.tres`.

## Exact F6 retest

1. In Godot 4.7.2, open the F6 harness above from FileSystem. Press **F6 (Run Current Scene)**. Default selection: **THE ARTWORK**. Narration is enabled but silent until requested.
2. Select each mode with mouse, touch, Tab/Shift+Tab and Enter/Space; focused mode buttons also support arrow navigation: THE ARTWORK / THE LEGEND / CULTURAL MEANING. Selection remains optional. Try repeated and rapid input.
3. Drag the magnifier with mouse or touch; use its keyboard focus and arrow keys. It must stay within the fitted painting after dragging outside the frame or resizing. The lens samples the original 364×442 reproduction; it creates no new detail. THE LEGEND includes the Tawalisi/Pangasinan historical qualification. Close/reopen restores the lens to the center.
4. Activate LISTEN: it starts at zero. Activate again to stop/reset. Replay starts at zero. Let the recording finish naturally and verify the button returns idle. Change modes and open Sources while listening: playback continues. Closing the hotspot stops/resets it.
5. Open SOURCES; inspect the relevant historical references and media credits below. Use CLOSE SOURCES, Escape, and Backspace. These close only Sources; they preserve the selected mode. The next back action closes the hotspot.
6. Close during a transition and narration. Activate **OPEN UH-INT-01 PREVIEW**. Verify default mode, fully visible image/text, initial local scroll, no stale pointer/outline/carousel state, and no autoplay.
7. Repeat at **1280×720, 960×540, 854×480**, with both a full Control parent and the harness's 5% inset parent. Resize while open. All content remains accessible; compact layouts use local information scrolling. Targets remain at least 48px tall. No whole-page scrolling or cropped controls.

## Production handoff and visual editing

Instance only the production scene under an ordinary Control; the harness is not a dependency. Call `open_interaction() -> bool`. Connect `closed`; optional `opened`. Call `close_interaction()` to close/reset, or `reset_interaction()` to reset while retaining open status. No avatar, map, master scene, autoload, or environment coordinate is required. The production component never changes the application window or viewport settings.

Open the production TSCN directly in Godot's 2D editor. Select Panel/MainMargin, MainVBox, Content, BodyRow, MediaColumn, MediaFrame, InfoScroll, Navigation and TakeawayMargin. Adjust margins, separations and column stretch ratios in the Inspector, then run and confirm they persist. Scene-authored Containers determine static geometry. The editor content-binding helper fills approved labels/textures only; it does not create a fake layout. Runtime controls selection, fade alpha, focus/local scroll and audio; hotspot-specific moving media overlays use the fitted image rectangle.

## Assets and attribution

- `res://assets/landmarks/urduja_house/interior/uh_int_01_princess_urduja_painting.jpg`

Narration: `res://assets/landmarks/urduja_house/audio/uh-int-01-narration.ogg`.

Artwork: Romeo C. Mananquil. Digital reproduction image: researcher-supplied repository asset. Photographer, reproduction source and permission/license undocumented.

Magnifier samples the same 364×442 image; it does not create additional detail.

Narration: researcher-supplied and approved despite duplicate detection. Individual recording credit/rights unresolved.

The researcher explicitly accepts the duplicate narration files. Automated checks verify playback state, reset and signals; they do not verify spoken words against the transcript. Physical-device listening and touch are manual checks. No new narration or source/permission claim was invented.

## Automated checks

Run `godot --headless --max-fps 60 --path . --script res://tests/uh_remaining_phase5_test.gd -- uh_int_01`. Omit `--headless` for Compatibility rendering and PNG captures. Add `--editor` for the actual editor-layout/Inspector check. The suite instantiates production independently, checks every mode across the six size/parent combinations, tests input/audio/Sources/close/reopen, and separately exercises the F6 harness. Final totals and environment diagnostics are in `docs/urduja_house_remaining_hotspots_phase5_report.md`.
