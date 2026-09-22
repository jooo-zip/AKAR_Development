# LCH-EXT-02 — From Manila to Pangasinan

## Stage 3 simplification revision — 2026-09-22

This focused revision keeps the existing map-timeline architecture and approved wording while simplifying the Stage 3 presentation. The fortified settlement now uses the exact same normalized destination point as the Pangasinan marker, route endpoint, and PathFollow2D ship destination. It replaces the Pangasinan pin at that coordinate after the short arrival fade; it is no longer offset beside the destination.

The settlement is a small map symbol (44 px at the wide reference layout and 36 px at compact layouts), preserving source aspect ratio. Stage 3 keeps the Pangasinan label separate and readable. The ship fades out over 180 ms, the Pangasinan pin is hidden, and the settlement scales from 0.82 to 1.0 with one restrained 0/-3/+3/-2/+2/0 horizontal shake before becoming still. Rapid stage changes restore pin visibility, ship opacity, settlement scale and zero offset. Selecting the already active stage replays that stage’s visual behavior: Northward restarts the 2.5-second journey; Pangasinan repeats only the arrival-to-settlement replacement.

The visible `Artistic historical interpretation` label has been removed from the map and information panel. Interpretive meaning remains documented in this report and source metadata. The route notice remains unchanged.

The redundant PREVIOUS / REPLAY / NEXT controls and their container have been removed. The three direct stage buttons are now the only visible historical-stage controls. Left/Right arrows remain clamped, and Enter/Space activate the focused stage button; same-stage activation provides replay.

Final focused revision tests: **0 failures** at 1280x720, 960x540 and 854x480, including shared destination-coordinate assertions, pin replacement, small settlement sizing, ship final visibility, removed-label/control checks, same-stage replay, mouse, touch, keyboard, Sources/Escape, rapid switching and reopen reset. No new files were created, staged, committed or pushed.

## Stage 3 visual revision — 2026-09-22

This focused revision changed only Stage 3 settlement presentation in the existing EXT-02 controller, tests and this document. The approved stage wording, map/info ratio, stage controls, Sources, narration, keyboard/mouse/touch behavior, and all other stage foundations remain intact.

The settlement uses the same normalized map-relative coordinate system as the location markers. Its Sprite2D center shares the configured Pangasinan destination. The Pangasinan pin is replaced only after the arrival fade, while the separate PANGASINAN label remains readable. There is no detached far-left illustration, and no interpretation label is rendered in any layout. Stage 1 and Stage 2 hide the settlement.

On Stage 3 activation or direct jump, the route is completed and the ship is placed at Pangasinan. The ship fades out over 180 ms. The settlement then fades in while scaling from 0.82 to 1.00, followed by one restrained 5-step horizontal shake (0, -3, +3, -2, +2, 0) over approximately 520 ms total. The final settlement transform is restored exactly to its base map-relative position and scale 1.0; no loop, particles, flash, or game-like effect is used. Replay Stage 3 cancels the current transition, restores the ship at the destination, resets the settlement, and repeats only this arrival-to-establishment sequence. It never replays the full Manila-to-Pangasinan route.

Rapid stage changes kill the active route and settlement tweens, restore ship opacity and settlement scale/position, hide the appropriate overlays, and then apply the authoritative target stage. Tests verify that a Stage 3 animation interrupted by another stage cannot accumulate shake offsets or leave a stale fade callback.

The supplied assets remain unchanged and are still read from `assets/landmarks/limahong_channel/lch_ext_01/maps/route_map/`: `lch_luzon_map.png`, `location_marker.png`, `route_ship.png`, and `fortified_settlement.png`. PNG alpha was verified in the previous audit. No new files were created, staged, committed, or pushed for this revision.

Final Stage 3 revision test run: **0 failures** at 1280×720, 960×540 and 854×480. Tests cover destination placement, ship fade, settlement scale and final stillness, one-pass shake/reset, Stage 3 replay, direct Stage 1 → Stage 3 selection, interruption during settlement animation, label placement, mouse, keyboard, synthetic touch, Sources/Escape and reopen reset. The native Godot environment continues to report its unrelated root-certificate-store warning.

## Current exhibit revision — 2026-09-20

Restructured the existing embedded component into a map-led historical exhibit. Preserved the stage controller, parent sizing, shared shell/theme, Sources layer, narration, close/reset and input foundations. No EXT-03, master scene or avatar integration. Awaiting researcher F6/manual visual review.

## Audit and preservation

Read AGENTS.md and inspected the current scene, controller, content resource, tests, documentation and Limahong assets. Before editing, recorded git status, every pre-existing file hash and the complete staged index. The four staged Urduja asset files and all unrelated unstaged/untracked files remain unchanged. project.godot was not edited. Baseline status is included at the end.

Only these five pre-existing EXT-02 files changed:

- scripts/landmarks/limahong_channel/lch_ext_02.gd
- scripts/landmarks/limahong_channel/lch_ext_02_content.gd
- data/landmarks/limahong_channel/lch_ext_02.tres
- tests/lch_ext_02_test.gd
- docs/lch_ext_02_testing.md

Godot generated four new .png.import sidecars beside the new supplied assets below. No new scenes, scripts, illustrations or replacement systems were created. No asset pixels were modified. All source PNGs were already untracked before this revision.

## Actual supplied assets used

All four assets are in `assets/landmarks/limahong_channel/lch_ext_01/maps/route_map/`:

| Role | Exact repository path |
| --- | --- |
| Regional map | assets/landmarks/limahong_channel/lch_ext_01/maps/route_map/lch_luzon_map.png |
| Two location pins | assets/landmarks/limahong_channel/lch_ext_01/maps/route_map/location_marker.png |
| Symbolic route ship | assets/landmarks/limahong_channel/lch_ext_01/maps/route_map/route_ship.png |
| Fortified settlement | assets/landmarks/limahong_channel/lch_ext_01/maps/route_map/fortified_settlement.png |

Pixel alpha verification on the three 1024x1024 icons confirmed transparency: marker 931,242 fully transparent pixels, ship 925,217, settlement 828,618; each also contains partial-alpha edges. The image preview displayed transparency over gray, so alpha was verified from actual PNG pixel data rather than inferred visually. These new assets are assigned; older icon paths are unused. Runtime tests also verify alpha and assigned texture identities.

Godot Sprite2D display regions use the source image's used rectangle to omit transparent padding without editing source files. Nearest filtering preserves pixel-art edges. Map is 1024x1536 and remains aspect-fitted at 2:3, with no horizontal stretch. The map contains small pre-existing decorative symbols; interactive pins, labels and route remain separate nodes.

Exact shared narration icon remains `assets/ui/icons/speaker.svg`. No custom font was supplied; existing readable font and optional display_font slot remain.

## Layout and map configuration

At 1280x720 the map region takes approximately 64% of the content width, with 36% information. The full portrait-shaped Luzon image is fitted centrally in that region. The right panel contains stage number/date, scrollable approved title/body/takeaway and the vertical directly selectable stages. Sources sits in the header alongside the existing LISTEN and Close controls.

At 960x540 and 854x480, the same map/info split remains; the three stage buttons move to a compact horizontal bottom row. There is no separate navigation row. All primary targets are at least 48px high; header controls retain 56px. Text remains scrollable, never omitted. The component is still inside the preview's 90%-sized parent; it does not own the viewport.

Current adjustable normalized resource coordinates:

- Manila: (0.45, 0.76)
- Pangasinan: (0.30, 0.50)
- Broad schematic route: (0.45, 0.76), (0.08, 0.72), (0.08, 0.50), (0.30, 0.50)

Coordinates apply to the actual aspect-fitted image rectangle, not viewport coordinates. They indicate broad regions for researcher review, not GPS points, stopovers, an exact landing or a fort location. Labels MANILA and PANGASINAN are separate Godot Labels. A small ship display offset keeps the location pin readable; the PathFollow2D itself ends at the configured destination.

MapArea contains BaseMap, Line2D, Path2D -> PathFollow2D -> RouteShip, separate pin instances/labels and a settlement symbol centered on the Pangasinan destination. The notice stays below the map. Line2D antialiasing is disabled. Curve2D uses the same sparse points, scaled to the fitted image; its baked distances synchronize the line reveal and follower progress_ratio. Looping and automatic sprite rotation are disabled. Resize rebuilds the curve while retaining normalized progress.

## Stages, animation and replay

All three approved historical headings, dates/location label, bodies, support line, takeaway and narration transcript remain unchanged in Resource data. No EXT-03 facts or game mechanics were introduced.

- MANILA: Manila active, Pangasinan subdued, ship at origin, route hidden and settlement hidden. Replay repeats a restrained 250ms marker emphasis.
- NORTHWARD: linear 2.5-second reveal and symbolic ship travel, destination gradually emphasized, settlement hidden. Replay resets route/follower to 0 and repeats once.
- PANGASINAN: completed secondary route, follower at 1, destination active and Manila subdued. The supplied settlement symbol performs the documented ship fade, exact pin replacement, 0.82-to-1.0 scale and restrained 520ms shake sequence. Replay repeats only this arrival-to-establishment transition without restarting the journey.

Settlement is a small interpretive map symbol centered on the shared Pangasinan destination coordinate; it is not a plan, dimensioned drawing or archaeological reconstruction. Ship is symbolic, not a reconstruction of the actual vessel.

Whenever the route is visible, the notice reads exactly: `Schematic historical movement — not an exact voyage route.`

The three stage buttons are the only visible stage controls. Direct Manila -> Pangasinan immediately resolves route/follower/text and runs only the short settlement replacement. Returning to Manila resets immediately. Selecting the active Northward or Pangasinan button intentionally replays that stage. Each selection kills both active visual tweens and normalizes opacity/state before starting the requested behavior. No looping, queued stale callbacks, stranded ship or accumulated movement.

Sources preserves stage and confines keyboard focus, including exclusion of the new navigation buttons. Escape closes Sources first, then the hotspot, restoring focus appropriately. Tab/Shift+Tab, Enter/Space and clamped Left/Right remain supported. Narration remains hotspot-level, never autoplays or restarts on stage/replay; close stops it. Reopen resets to Manila with Sources hidden and no active movement.

## Validation

Final native Godot 4.7.2 Compatibility rendered suite: **0 failures** at 1280x720, 960x540 and 854x480. Rendered snapshots inspected at all three sizes. Tests use deterministic tween stepping rather than frame-perfect timing.

Coverage includes exact prose, initial marker/follower/route state, correct supplied textures and alpha, map aspect/60-66% width, responsive timeline orientation, all major touch-target bounds, partial/completed route synchronization, progressive destination emphasis, direct jumps, rapid sequences ending in Northward/Pangasinan, shared destination coordinate, pin replacement, small settlement sizing/final transform, removed UI label/controls, same-stage replay, Sources focus trap, Escape hierarchy, keyboard arrows/no wrapping, Tab/Shift+Tab/Enter/Space, mouse and synthetic touch, close/reopen, no narration autoplay, future explicit narration/stop using silent in-memory WAV, and missing-map fallback.

No GDScript parser/runtime errors in the final suite. The existing environment warning `Failed to read the root certificate store` remains unrelated to the interaction. These are native-engine synthetic input tests; physical touchscreen and exported browser tests are not claimed.

Run from the repository root:

```powershell
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --path . --script res://tests/lch_ext_02_test.gd -- --capture
```

Screenshots: `%TEMP%/lch_ext_02_1280.png`, `_960.png`, `_854.png` (Pangasinan), plus `_stage0.png` and `_stage1.png` variants for Manila and midpoint Northward.

## Researcher F6 review

1. Open `scenes/landmarks/limahong_channel/exterior/lch_ext_02_preview.tscn` and press F6; open the hotspot.
2. Check each target size: full unstretched map, broad regional pin positions, symbolic ship, small destination settlement, readable notice/text and accessible controls.
3. Select Northward twice to replay the 2.5-second route. Interrupt with direct stage buttons. Select Pangasinan twice to replay only the ship-fade/settlement replacement.
4. Check mouse, keyboard traversal/activation, clamped arrows and physical touch where available. Scroll to the supporting line/takeaway at compact sizes.
5. Open Sources during movement. Escape closes Sources first, then the hotspot. Reopen to Manila. LISTEN remains visible and disabled pending correct audio.
6. Review the map settlement replacement and approve the exhibit visually before any next milestone.

## Outstanding content

Correct LCH-EXT-02 narration is still unavailable; no Urduja audio is assigned. Bibliographic titles/editions/publication details/pages and Historical Profile/Validation Sheet identifier/date remain pending. Sources lists only researcher-supplied basis (Francisco de Sande account, Shutz academic study and project validation sheet); no details were invented. Map/artwork creator, source and permissions metadata still await researcher confirmation.

## Git status

The initial status for this focused revision already contained the unrelated staged, modified and untracked files shown below. The final status preserves those paths and the staged index; only the five EXT-02 paths listed above were intentionally edited. Four existing route-map PNG import sidecars remain untracked. No staging, commit or push occurred. No EXT-03/master scene work started.

Baseline `git status --short`:

```text
 M assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png
 M assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png.import
A  assets/landmarks/urduja_house/icons/summary_visitor_marker.png
A  assets/landmarks/urduja_house/icons/summary_visitor_marker.png.import
A  assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg
A  assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg.import
 M data/landmarks/limahong_channel/lch_ext_01_locator_channel.tres
 M data/landmarks/limahong_channel/lch_ext_01_locator_lingayen.tres
 M data/landmarks/limahong_channel/lch_ext_01_locator_pangapisan.tres
 M docs/lch_ext_01_testing.md
 M project.godot
 M scenes/landmarks/limahong_channel/exterior/lch_ext_01.tscn
 M scripts/landmarks/limahong_channel/lch_ext_01.gd
 M tests/lch_ext_01_test.gd
?? assets/landmarks/limahong_channel/lch_ext_01/audio/
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_location_marker.png
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_location_marker.png.import
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_movement_vessel.png
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_movement_vessel.png.import
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_route_ship.png
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_route_ship.png.import
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_settlement_icon.png
?? assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_settlement_icon.png.import
?? assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_marker.png
?? assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_marker.png.import
?? assets/landmarks/limahong_channel/lch_ext_01/maps/lch_ext_02_regional_map.png
?? assets/landmarks/limahong_channel/lch_ext_01/maps/lch_ext_02_regional_map.png.import
?? assets/landmarks/limahong_channel/lch_ext_01/maps/route_map/
?? data/landmarks/limahong_channel/lch_ext_02.tres
?? docs/lch_ext_02_testing.md
?? scenes/landmarks/limahong_channel/exterior/lch_ext_02.tscn
?? scenes/landmarks/limahong_channel/exterior/lch_ext_02_preview.tscn
?? scripts/landmarks/limahong_channel/lch_ext_02.gd
?? scripts/landmarks/limahong_channel/lch_ext_02.gd.uid
?? scripts/landmarks/limahong_channel/lch_ext_02_content.gd
?? scripts/landmarks/limahong_channel/lch_ext_02_content.gd.uid
?? tests/lch_ext_02_test.gd
?? tests/lch_ext_02_test.gd.uid
```
