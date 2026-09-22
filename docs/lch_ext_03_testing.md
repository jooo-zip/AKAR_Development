# LCH-EXT-03 — The Siege and Escape Route

Implemented 2026-09-22. Awaiting researcher F6/manual visual review.

## Objective and scope

An embedded, self-paced layered historical interpretation map explains the relationship between fortified settlement, symbolic blockade, reported passage, and escape by water. The same map remains visible throughout four directly selectable stages. The visualization does not claim exact geography, troop positions, canal geometry or archaeological reconstruction. No game mechanics, completion state, master scene, avatar/Area2D integration or EXT-04 work was added.

## Repository audit and reuse

Read AGENTS.md, the existing Limahong implementations, their Resources, tests, F6 previews, and the already reused ConferenceRoomInteraction scene/controller/content. The initial short status contained **4 staged files, 15 unstaged files, and 25 untracked entries** (some entries are directories). The full list below distinguishes the Git states. The four staged files were the Urduja summary marker and cultural architecture icon, each with its import sidecar.

Before editing, recorded SHA-256 hashes of all 254 pre-existing tracked/untracked non-ignored files and the full staged index in the local temporary audit directory. Final comparison found **zero pre-existing file changes and zero index differences**. This includes AGENTS.md, project.godot, supplied PNGs, EXT-01, EXT-02, and Urduja work. No pre-existing file was intentionally modified.

Reused the shared embedded ConferenceRoomInteraction scene, heritage theme, speaker control, narration player, Sources overlay, focus trap, Escape hierarchy, close signal and deferred return focus. EXT-02 patterns inform aspect-fitted coordinates, transparent sprite regions, direct stage replay, tween cancellation, Line2D reveal and nonlooping PathFollow2D movement. The shared opener validates exactly three concepts, so EXT-03 locally adapts its opening lifecycle for four; existing shared code is unchanged. Parent listeners can use inherited opened/closed/narration/Sources signals and stage_changed. No hotspot_completed signal exists.

## Files created

- scenes/landmarks/limahong_channel/exterior/lch_ext_03.tscn
- scenes/landmarks/limahong_channel/exterior/lch_ext_03_preview.tscn
- scripts/landmarks/limahong_channel/lch_ext_03.gd
- scripts/landmarks/limahong_channel/lch_ext_03_content.gd
- data/landmarks/limahong_channel/lch_ext_03.tres
- tests/lch_ext_03_test.gd
- docs/lch_ext_03_testing.md

Godot-generated metadata:

- scripts/landmarks/limahong_channel/lch_ext_03.gd.uid
- scripts/landmarks/limahong_channel/lch_ext_03_content.gd.uid
- tests/lch_ext_03_test.gd.uid
- assets/landmarks/limahong_channel/tactical_map/lch_ext_03_tactical_map_base.png.import
- assets/landmarks/limahong_channel/tactical_map/lch_ext_03_blockade_marker.png.import

Files modified: **none of the pre-existing files**. Both tactical PNGs were supplied and untracked before implementation; their pixels are unchanged.

## Exact assets and verification

| Role | Exact resource path |
| --- | --- |
| Tactical map | res://assets/landmarks/limahong_channel/tactical_map/lch_ext_03_tactical_map_base.png |
| Four blockade instances | res://assets/landmarks/limahong_channel/tactical_map/lch_ext_03_blockade_marker.png |
| Settlement | res://assets/landmarks/limahong_channel/lch_ext_01/maps/route_map/fortified_settlement.png |
| Vessel | res://assets/landmarks/limahong_channel/lch_ext_01/maps/route_map/route_ship.png |
| Narration icon | res://assets/ui/icons/speaker.svg |

All required visual assets exist and load. Visual inspection of the 1672×941 map confirms landscape/water only: no baked settlement, blockade markers, ship or passage overlay. Aspect ratio is preserved by TextureRect aspect fitting.

Godot pixel checks confirm alpha and transparent corner pixels for all three symbol textures. The blockade emblem is a neutral cream/brown symbol with no opaque rectangular background. Blockade texture dimensions: 1254×1254; settlement and ship: 1024×1024 each. Display regions trim fully transparent padding without editing source assets. Nearest filtering is retained. Faint source edge pixels remain intact; the wide settlement's opaque artwork reads at about 50 px, inside an 80 px fitted display region. Compact display extent is 56 px. Blockade display extents are 48/44 px, with opaque emblems about 35/32 px. Vessel extent is 40/32 px. No new historical artwork or passage PNG was created.

A missing map uses an explicitly labeled DEVELOPMENT FALLBACK and the same 16:9 schematic coordinate framework. No final visual asset is missing in the current repository. Optional blockade map-touch targets were omitted; the accessible Blockade stage button provides the interaction.

## Approved historical data

All historical prose, dates, numbered button labels, notices, disclaimers, transcript and source text live in lch_ext_03.tres. Configurable symbolic coordinates live in the content Resource exports.

| Stage | Button / date | Title and exact body |
| --- | --- | --- |
| 0 | 01 SETTLEMENT / 1575 | FORTIFIED SETTLEMENT — Limahong and his followers had established a fortified settlement in Pangasinan before the expedition against them. |
| 1 | 02 BLOCKADE / 1575 | THE BLOCKADE — Juan de Salcedo led the Spanish and allied Luzonese expedition that blockaded Limahong's settlement in 1575. |
| 2 | 03 PASSAGE / 1575 | REPORTED ESCAPE PASSAGE — During the campaign, Limahong's followers reportedly excavated a passage leading from the settlement toward the sea. |
| 3 | 04 ESCAPE / AUGUST 1575 | ESCAPE BY WATER — Limahong and many of his followers used the water route to move beyond the blockade and escape by water. |

Stage 1 notice: “Symbolic blockade representation — not exact troop positions.”

Stages 2 and 3 notice: “Interpretive escape passage — exact historical path not established.”

Full permanent disclaimer at 1280×720 and 960×540:

> Simplified historical visualization — not to scale. The present Limahong Channel is traditionally associated with the reported escape route; the exact historical path has not been independently established through archaeological evidence.

Compact disclaimer at 854×480:

> Historical interpretation — not to scale; exact escape path not established.

The full qualification and both stage notices also remain available in Sources at every stage. Four markers represent the expedition symbolically, not four units or troop counts.

## Map architecture and adjustable anchors

All overlays are children of HistoricalMap. The actual displayed rectangle is calculated from its parent bounds and the source texture aspect ratio: centered fitted rectangle, then position = fitted.position + normalized_anchor * fitted.size. No viewport-global coordinates drive the map.

| Setting | Normalized value |
| --- | --- |
| settlement_anchor | (0.39, 0.47) |
| blockade_anchors[0] | (0.18, 0.44) |
| blockade_anchors[1] | (0.35, 0.12) |
| blockade_anchors[2] | (0.60, 0.35) |
| blockade_anchors[3] | (0.53, 0.64) |
| passage_points (intermediate) | (0.43, 0.60), (0.51, 0.71) |
| water_exit_anchor | (0.66, 0.90) |

These positions are adjustable diagram composition, not verified historical positions. The four broad route points are the settlement anchor, two intermediate passage points, and water endpoint. A single Curve2D is built from these values. Both the narrower 2 px cream Line2D and EscapePath/PathFollow2D use that curve's baked distances. No duplicated vessel route is maintained. The route extends from the clearing toward the lower water area and beyond the symbolic blockade.

Resize rebuilds the curve from the newly fitted rectangle and preserves normalized passage/vessel progress. Settlement/marker animation scales their Node2D wrappers; sprite scale is reserved for image fitting. The vessel does not rotate or loop. Stage 3 ends at water_exit_anchor, stationary.

## Stage behavior and durations

| Stage | Deterministic stable layers | Selected-stage animation |
| --- | --- | --- |
| 0 Settlement | Map, settlement and label; later layers hidden | 360 ms fade 0→1 and scale 0.88→1 |
| 1 Blockade | Settlement plus exactly four markers; passage/vessel hidden | Four sequential 200 ms marker reveals; opacity 0→1 and scale 0.85→1; total 800 ms |
| 2 Passage | Settlement, four markers, full passage; vessel hidden | 1.35 s progressive Line2D reveal |
| 3 Escape | Settlement, four markers, passage and vessel at final endpoint | 2.25 s vessel progress_ratio 0→1; previous layers immediately established |

Every stage button calls the same show_stage method. Direct 0→2/3 jumps establish prior layers immediately and animate only passage/vessel respectively. Backward selection removes later layers without reversing the vessel. Selecting the current stage replays only its own animation. No Previous/Replay/Next controls exist.

Before switching, one active Tween is killed, opacity/scale/rotation/positions and route progress are normalized, the authoritative stage establishes the full layer contract, then its chosen animation starts. Tween completion returns to deterministic final transforms and clears the tween reference. No deferred fade callbacks or loops survive interruption.

Sources opened during any animation calls the same final-state normalization before showing the inherited modal layer. Closing Sources returns to the same stage. Close kills animation and stops audio; reopen starts Stage 0 and its short introduction with later layers hidden.

## Responsive and input behavior

The parent-sized panel retains approximately 65% map / 35% information width. The F6 preview provides a 90%-sized inset parent, not full-viewport assumptions.

- 1280×720: vertical stage controls, full disclaimer, approximately 50 px opaque settlement, all four symbols separated from its label.
- 960×540: reduced spacing and four horizontal stage controls; full disclaimer remains visible.
- 854×480: four horizontal stage controls, 20 px body text, compact permanent disclaimer and always-visible stage notice; full qualification in Sources.

All four stage buttons and header controls are at least 48 px in both dimensions. The information body scrolls at smaller layouts without removing text. No hover-only historical information exists. Muted gold selects the current stage; inherited focus styling stays visible.

Tab/Shift+Tab traverse controls. Enter/Space activate and replay focused stages. Left/Right select adjacent stages without wrapping or replaying at an endpoint. Escape closes Sources first, then closes the hotspot after marking input handled. Sources traps keyboard focus. Mouse and synthetic touch exercise stages, Sources, Close and future assigned narration playback.

## Narration and source status

The exact shared speaker.svg remains visible with LISTEN disabled and “Narration pending.” No EXT-03 recording was found; no other hotspot's audio is assigned and no speech was generated. The supplied recommended transcript is stored verbatim in the content Resource. Future assigned audio starts only from visitor input, continues across stage changes, and stops on close.

Sources lists only researcher-specified categories: Francisco de Sande, project Historical Profile / Validation Sheet, and Provincial Government historical material. Full titles, editions/publication dates, pages, URLs, validation identifier/date, and media creator/source/permissions remain pending. No bibliographic details or historical facts were invented.

## Validation results

Godot 4.7.2 Compatibility, native rendered EXT-03 suite: **0 failures** at all three target sizes. All four stage screenshots captured at each size; wide and compact layouts visually inspected.

Tests cover initial/replay animation, exact wording/buttons/dates, cumulative visibility, exactly four markers, sequential blockade reveal, partial/final line reveal, shared curve and vessel position, direct jumps, backward removal, all four same-stage replays, rapid interrupted sequences, killed tween validity, normalized transforms, Sources interruption at every stage, Sources qualification/focus/Escape, mouse/keyboard/synthetic touch, no wrapping, close/reopen, missing map fallback, editable anchors, resize during escape, transparent textures, target bounds, label/marker separation, responsive disclaimers, and user-initiated narration using only in-memory silence for playback testing.

Tests advance Tween time deterministically; no exact-frame timing dependency is used. Final EXT-03 run had no parser or interaction runtime errors. The native environment still emits its existing “Failed to read the root certificate store” warning.

Regression suites:
- EXT-01: 0 failures at 1280×720, 960×540, 854×480.
- EXT-02: 0 failures at the same sizes. Its unchanged headless suite reports three ObjectDB instances leaked at exit; not caused or changed by EXT-03.
- git diff --check: passed. New untracked EXT-03 text files also checked explicitly using git diff --no-index --check.

Regression runs used the headless native engine; EXT-03 used native Compatibility rendering. Exported browser and physical touchscreen verification are not claimed and remain part of researcher review.

Run from repository root (temporary APPDATA prevents test logs affecting user configuration):

```powershell
$env:APPDATA = Join-Path $env:TEMP 'akar-godot-test'
$env:LOCALAPPDATA = $env:APPDATA
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --path . --script res://tests/lch_ext_03_test.gd -- --capture
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --headless --path . --script res://tests/lch_ext_01_test.gd
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64.exe' --headless --path . --script res://tests/lch_ext_02_test.gd
```

Snapshots: %TEMP%/lch_ext_03_1280_stage0.png through stage3.png, and equivalent 960/854 files.

## Researcher F6 checklist

1. Open scenes/landmarks/limahong_channel/exterior/lch_ext_03_preview.tscn and press F6. Select “The Siege and Escape Route.”
2. At 1280×720, 960×540 and 854×480, inspect the unchanged aspect ratio, map prominence, settlement label, four blockade emblems, stage text and visible qualifications. Scroll the information panel where needed.
3. Select each stage twice. Check settlement introduction, one stationary sequential blockade reveal, passage drawing, and vessel following that passage to water and stopping.
4. Jump directly 0→2 and 0→3. Return 3→1 and 2→0. Earlier animation must not be forced; later layers must disappear on return.
5. Rapidly choose 0→1→2→3→0→3 and 3→2→1→3. Verify full opacity, normal scales, no stale movement or detached vessel.
6. Open Sources during each animation. Close it with Escape; the same stage should be fully established. Verify the full historical qualification even at compact size.
7. Test mouse, Tab/Shift+Tab, Enter/Space, clamped Left/Right, and physical touch where available. Escape then closes the hotspot and returns focus. Reopen resets to Settlement.
8. LISTEN must remain visible and disabled pending correct audio. Review schematic anchors and historical interpretation with the researcher before proceeding further.

## Git audit before implementation

```text
 M AGENTS.md
 M assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png
 M assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png.import
A  assets/landmarks/urduja_house/icons/summary_visitor_marker.png
A  assets/landmarks/urduja_house/icons/summary_visitor_marker.png.import
A  assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg
A  assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg.import
 M data/landmarks/limahong_channel/lch_ext_01.tres
 M data/landmarks/limahong_channel/lch_ext_01_locator_channel.tres
 M data/landmarks/limahong_channel/lch_ext_01_locator_lingayen.tres
 M data/landmarks/limahong_channel/lch_ext_01_locator_pangapisan.tres
 M data/landmarks/urduja_house/uh_end_01.tres
 M data/landmarks/urduja_house/uh_int_03.tres
 M data/landmarks/urduja_house/uh_int_04.tres
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
?? assets/landmarks/limahong_channel/tactical_map/
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

## Git status after implementation

All baseline staged/unstaged/untracked entries above remain. Only the 12 new EXT-03 files listed in this document were added to the working tree (untracked); the two PNGs already belonged to the baseline tactical_map directory. No files were staged or unstaged. The four staged Urduja paths and all 254 pre-existing file hashes remain identical. project.godot is still pre-existing dirty work and was not modified by this task.

No commit. No push. EXT-04 not started. Limahong master scene and avatar integration not started. Stop here for researcher F6/manual review.
