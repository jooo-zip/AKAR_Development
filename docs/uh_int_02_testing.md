# UH-INT-02 Phase 5 testing

Updated 4 October 2026. Supersedes the earlier revision-specific testing steps for this hotspot.

Production and visual editing: `res://scenes/landmarks/urduja_house/components/uh_int_02.tscn`.
F6 harness: `res://scenes/landmarks/urduja_house/interior/uh_int_02.tscn`.
Approved content: `res://data/landmarks/urduja_house/revision/uh_int_02.tres`.

## Exact F6 retest

1. In Godot 4.7.2, open the F6 harness above from FileSystem. Press **F6 (Run Current Scene)**. Default selection: **1953**. Narration is enabled but silent until requested.
2. Select each mode with mouse, touch, Tab/Shift+Tab and Enter/Space; focused mode buttons also support arrow navigation: 1953 / BEFORE 2007 / 2007 / TODAY. Selection remains optional. Try repeated and rapid input.
3. Select all four dates directly, drag along the date track, and use arrows/Home/End. Releasing a drag must retain the nearest selected date. 1953 is a date panel, not an invented photograph. BEFORE 2007 uses the accurately captioned September 1982 photograph. 2007 now plays a 2.15-second office-transfer sequence: endpoints fade in (0.25s), a drawn gold line/arrow reveals (0.30s), only the GOVERNOR'S DAILY OFFICE card travels left to right (1.30s), and the Capitol endpoint briefly brightens before both final statuses remain visible (0.30s). Urduja House stays stationary and remains the official residence. The redundant graphic caption is hidden in this state to preserve compact layout space; its interpretive disclosure remains in Sources. TODAY uses the supplied present-day exterior.
4. Reselect **2007** with mouse, touch or Enter/Space to replay. Leave it during movement, then rapidly select 2007 / TODAY / 2007: only the latest state may remain, with no stranded token. Resize during movement. Final labels must read **OFFICIAL RESIDENCE REMAINS** and **DAILY OFFICE TRANSFERRED**. The original malformed arrow string has been removed; the arrow is now a scene-authored Polygon2D, not a Unicode character.
5. Activate LISTEN: it starts at zero. Activate again to stop/reset. Replay starts at zero. Let the recording finish naturally and verify the button returns idle. Change modes and open Sources while listening: playback continues. Closing the hotspot stops/resets it.
6. Open SOURCES; inspect the relevant historical references and media credits below. Use CLOSE SOURCES, Escape, and Backspace. These close only Sources; they preserve the selected mode. The next back action closes the hotspot.
7. Close during a transition and narration. Activate **OPEN UH-INT-02 PREVIEW**. Verify default mode, fully visible image/text, initial local scroll, no stale pointer/outline/carousel state, and no autoplay.
8. Repeat at **1280×720, 960×540, 854×480**, with both a full Control parent and the harness's 5% inset parent. Resize while open. All content remains accessible; compact layouts use local information scrolling. Targets remain at least 48px tall. No whole-page scrolling or cropped controls.

## Production handoff and visual editing

Instance only the production scene under an ordinary Control; the harness is not a dependency. Call `open_interaction() -> bool`. Connect `closed`; optional `opened`. Call `close_interaction()` to close/reset, or `reset_interaction()` to reset while retaining open status. No avatar, map, master scene, autoload, or environment coordinate is required. The production component never changes the application window or viewport settings.

Open the production TSCN directly in Godot's 2D editor. Select Panel/MainMargin, MainVBox, Content, BodyRow, MediaColumn, MediaFrame, InfoScroll, Navigation and TakeawayMargin. Adjust margins, separations and column stretch ratios in the Inspector, then run and confirm they persist. Scene-authored Containers determine static geometry. The editor content-binding helper fills approved labels/textures only; it does not create a fake layout. Runtime controls selection, fade alpha, focus/local scroll and audio; hotspot-specific moving media overlays use the fitted image rectangle.

## Assets and attribution

- `res://assets/landmarks/urduja_house/exterior/uh_ext_01_historical_photo.jpg`
- `res://assets/landmarks/urduja_house/interior/uh_int_02_present_exterior.jpeg`

Narration: `res://assets/landmarks/urduja_house/audio/uh_int_02_narration.ogg`.

Historical photograph: I Love Pangasinan, “Urduja House in Lingayen Pangasinan”; September 1982. Photographer and permission/license unresolved.

Present-day exterior: AKAR Team; researcher-captured/documentary photograph. Individual photographer and capture date undocumented.

1953 date panel and 2007 transition: Godot UI interpretation, not historical photographs or geographic maps.

Narration: researcher-supplied and approved despite duplicate detection. Recording credit/rights unresolved.

The researcher explicitly accepts the duplicate narration files. Automated checks verify playback state, reset and signals; they do not verify spoken words against the transcript. Physical-device listening and touch are manual checks. No new narration or source/permission claim was invented.

## Automated checks

Run `godot --headless --max-fps 60 --path . --script res://tests/uh_remaining_phase5_test.gd -- uh_int_02`. Omit `--headless` for Compatibility rendering and PNG captures. Add `--editor` for the actual editor-layout/Inspector check. The suite instantiates production independently, checks every mode across the six size/parent combinations, tests input/audio/Sources/close/reopen, and separately exercises the F6 harness. Final totals and environment diagnostics are in `docs/urduja_house_remaining_hotspots_phase5_report.md`.


## Focused correction editor check

Open the production scene in 2D. The initial 1953 view remains the default. To inspect the 2007 graphic without F6, hide `DocumentPanel` and enable `OfficeTransfer` under `Panel/MainMargin/MainVBox/Content/BodyRow/MediaColumn/MediaFrame`. Select ResidenceEndpoint, CapitolEndpoint, OfficeLine, OfficeArrow, OfficeToken, ResidenceStatus and CapitolStatus. They are real scene-authored nodes. The token travels between the two endpoint anchors, so endpoint Inspector edits remain authoritative and resizing does not strand it. Restore the preview visibility toggles without saving them as the initial runtime state. Dedicated editor automation performs this inspection without saving the scene.
