# UH-EXT-03 Phase 5 testing

Updated 4 October 2026. This guide replaces earlier interaction/media requirements with the researcher's locked Phase 1–4 content.

Production and visual editing scene: `res://scenes/landmarks/urduja_house/components/uh_ext_03.tscn`.
F6 harness: `res://scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn`.
Content: `res://data/landmarks/urduja_house/revision/uh_ext_03.tres`.

Instantiate only the production scene under an ordinary Control. Call `open_interaction()`; connect `closed`. `close_interaction()` closes/resets; `reset_interaction()` resets while retaining open/closed status. No avatar, map, master environment or harness is required. Do not use the harness in production.

Open production in 2D: select Panel/MainMargin/MainVBox, Content, BodyRow, MediaColumn, MediaFrame, InfoScroll, Navigation and TakeawayMargin. Use margins, separations, stretch ratios and minimum sizes. Content binding fills labels/media only; static layout is scene-authored. Runtime owns selection, crossfade alpha, audio, local scroll and focus. No global/window resizing is performed by production.

## F6 sequence

1. Open the harness above and press F6. Expect **ROOFLINE**, enabled LISTEN and no autoplay.
2. Select each concept: ROOFLINE, FAÇADE, ENTRANCE, EXTERIOR FORM, LANDSCAPED SETTING. Use mouse, touch, Tab/Shift+Tab, Enter/Space and arrow keys. Every choice is optional and directly accessible. Repeated/rapid choices must settle on the latest input.
3. LISTEN starts at zero, a second activation stops/resets, natural finish returns idle, and replay starts at zero. Selection and Sources must preserve playback. Physical-device listening/touch remain manual checks; automation uses engine input events.
4. Open Sources: check relevant historical references/media credits. Escape closes Sources only; the next Escape closes the hotspot.
5. Close mid-transition/playback, use OPEN PREVIEW, and check the default state, full opacity, initial media, reset local scroll and silent idle narration.
6. Repeat at 1280×720, 960×540, 854×480; full parent and 5% inset. Resize the ordinary parent during use. Ensure targets stay at least 48px tall and all text remains accessible through local scrolling.

Assets:
- `res://assets/landmarks/urduja_house/exterior/uh_ext_03_exterior_highres.jpeg`

Narration: `res://assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg`. Supplied recording accepted despite identical hashes. No speech/transcript equivalence is asserted by automated playback checks.

Credits: Exterior photograph: AKAR Team. Researcher-captured/documentary photograph. Individual photographer and capture date undocumented.

Narration: researcher-supplied and approved despite duplicate detection. Individual credit/rights unresolved.

Architecture Photo Explorer: ROOFLINE defaults selected. Five numbered 52px rings have explicit accessible labels and matching textual controls in the interpretation scroll. The scene-authored 4:3 AspectRatioContainer matches the fit/letterbox of the photograph. Normalized anchors are editable interaction placements, not new historical claims. The JPEG has EXIF orientation 3: Media flip_h/flip_v correct display orientation without editing source bytes. No synthetic detail or pixel-art markers.

Automated checkpoint: `godot --headless --path . --script res://tests/uh_remaining_phase5_test.gd -- uh_ext_03`. Omit --headless for Compatibility captures; add --editor for actual editor-layout checks. Results in the consolidated remaining-hotspots report.
