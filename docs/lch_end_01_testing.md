# LCH-END-01 — What the Limahong Channel Represents

Implementation and automated verification: 24 September 2026, Godot 4.7.2 stable, GDScript, Compatibility renderer. Researcher F6/manual visual review is pending.

## Purpose and scope

An optional, standalone Quick Heritage Summary introduces the retreat to Pangasinan, the 1575 blockade, the historical escape narrative, the present channel's traditional association, and its modern heritage value. It works as the first Limahong hotspot a visitor opens. Reading without selecting a card is valid usage; no earlier visit or completion is assumed.

This supports the project's historical-awareness and multimedia-learning objectives without making a claim about measured learning effectiveness. Reflection is an invitation to think, not an assessment. There is no answer field, submission, checking, score, completion tracking, prerequisite, unlock, or landmark-level navigation. No master scene or other hotspot was implemented or revised.

## Repository audit and preservation

Read root `AGENTS.md` and inspected all six existing Limahong components, their resource/test patterns, and the Urduja summary before implementation. No additional applicable nested instruction file was found.

The fresh END-01 baseline was taken after the separately authorized INT-03 milestone commit `66b29e36f4de23cf33243e217317853b14ed7257`. That commit preceded this task; no END-01 commit was made. The END-01 audit used `git status --short --untracked-files=all`, the complete staged index, HEAD, and SHA-256 hashes of 320 existing tracked/untracked working files.

Baseline: **4 staged, 15 unstaged, 14 untracked files**. These categories list files, not collapsed untracked directories.

Pre-existing staged files:

```text
assets/landmarks/urduja_house/icons/summary_visitor_marker.png
assets/landmarks/urduja_house/icons/summary_visitor_marker.png.import
assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg
assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg.import
```

Pre-existing unstaged files:

```text
AGENTS.md
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png.import
data/landmarks/limahong_channel/lch_ext_01.tres
data/landmarks/limahong_channel/lch_ext_01_locator_channel.tres
data/landmarks/limahong_channel/lch_ext_01_locator_lingayen.tres
data/landmarks/limahong_channel/lch_ext_01_locator_pangapisan.tres
data/landmarks/urduja_house/uh_end_01.tres
data/landmarks/urduja_house/uh_int_03.tres
data/landmarks/urduja_house/uh_int_04.tres
docs/lch_ext_01_testing.md
project.godot
scenes/landmarks/limahong_channel/exterior/lch_ext_01.tscn
scripts/landmarks/limahong_channel/lch_ext_01.gd
tests/lch_ext_01_test.gd
```

Pre-existing untracked files:

```text
assets/landmarks/limahong_channel/lch_ext_01/audio/lch_ext_01_narration.ogg
assets/landmarks/limahong_channel/lch_ext_01/audio/lch_ext_01_narration.ogg.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_location_marker.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_location_marker.png.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_movement_vessel.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_movement_vessel.png.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_route_ship.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_route_ship.png.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_settlement_icon.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_settlement_icon.png.import
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_marker.png
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_marker.png.import
assets/landmarks/limahong_channel/lch_ext_01/maps/lch_ext_02_regional_map.png
assets/landmarks/limahong_channel/lch_ext_01/maps/lch_ext_02_regional_map.png.import
```

The final comparison preserves all 320 original file hashes, index entries, and the baseline HEAD. `project.godot` remains byte-identical to its already-modified baseline. No unrelated work was staged, unstaged, restored, or reset. Final status: **4 staged, 15 unstaged, 26 untracked files**, with the same original changes plus the 12 END-01 files below.

Audit snapshots: `%TEMP%/akar-end01-audit-20260924-174333/`.

## Complete END-01 file inventory

Created:

```text
data/landmarks/limahong_channel/lch_end_01.tres
docs/lch_end_01_testing.md
scenes/landmarks/limahong_channel/summary/lch_end_01.tscn
scenes/landmarks/limahong_channel/summary/lch_end_01_preview.tscn
scripts/landmarks/limahong_channel/lch_end_01.gd
scripts/landmarks/limahong_channel/lch_end_01.gd.uid
scripts/landmarks/limahong_channel/lch_end_01_content.gd
scripts/landmarks/limahong_channel/lch_end_01_content.gd.uid
scripts/landmarks/limahong_channel/lch_end_01_topic.gd
scripts/landmarks/limahong_channel/lch_end_01_topic.gd.uid
tests/lch_end_01_test.gd
tests/lch_end_01_test.gd.uid
```

Existing files modified by END-01: **none**. No new documentary assets, import files, fonts, dependencies, autoloads, or project settings are required. The four `.uid` files were generated by Godot import.

## Reuse and implementation

The component inherits the existing `scenes/components/conference_room_interaction.tscn` / `scripts/components/conference_room_interaction.gd` shell used by the Limahong hotspots. It reuses the embedded parent-relative frame, dark surfaces, cream text, header controls, normal/hover/focus styles, default inherited font, Sources overlay, single narration player, Escape handling, Close, and return-focus behavior. The F6 preview follows the existing inset-parent/open-button convention.

The exact shared narration icon remains `assets/ui/icons/speaker.svg`. No Urduja audio or documentary imagery is attached. The Urduja `historical_summary_interaction` component was inspected only as a structural reference: its automatic first-topic selection, sequential navigation, visitor marker, and return-map presentation do not implement this brief's optional NONE state.

END-01 adds five topic resources, one main resource, and its own layout/controller. The content extends `ConferenceRoomContent` to reuse `hotspot_id`, `title`, `source_credit`, `narration_stream`, `narration_transcript`, and `learning_takeaway`. Each topic carries `topic_id`, `card_number`, compact/full labels, optional time label, short/detail wording, qualifier, and symbol type. The five-topic list is independent of the base shell's three-concept data. Historical paragraphs live in the `.tres`, not the controller.

## Exact visitor-facing wording

Title: **WHAT THE LIMAHONG CHANNEL REPRESENTS**

**AT A GLANCE**

> The Limahong Channel is a historical waterway in Pangapisan Norte, Lingayen, traditionally associated with Limahong's escape during the 1575 Pangasinan campaign.

**01 RETREAT TO PANGASINAN** — compact label **RETREAT**

Card:

> Limahong sailed to Pangasinan and established a fortified settlement.

Detail:

> After his failed attacks on Manila in late 1574, Limahong sailed to Pangasinan and established a fortified settlement.

The optional `LATE 1574` label is stored in the topic resource; it is not displayed on the card.

**02 THE 1575 BLOCKADE** — compact label **BLOCKADE**

Card:

> Juan de Salcedo led the expedition that blockaded Limahong's settlement.

Detail:

> Juan de Salcedo led the expedition against Limahong's fortified settlement in Pangasinan. Spanish and allied Luzonese forces blockaded the settlement in 1575.

**03 ESCAPE BY CHANNEL** — compact label **ESCAPE**

Card:

> Limahong's group escaped through a channel reportedly dug toward the sea.

Detail:

> During the 1575 blockade, Limahong's group escaped through a channel that official provincial history states they had dug toward the China Sea.

**04 HISTORICAL TRADITION** — compact label **TRADITION**

Persistent card qualifier: **TRADITIONAL ASSOCIATION**

Card:

> The present channel is traditionally associated with the 1575 escape route.

Detail:

> The present-day Limahong Channel is traditionally associated with the 1575 escape route. Its exact identification has not been independently established through archaeological evidence.

**05 MODERN HERITAGE VALUE** — compact label **HERITAGE**

Card:

> The channel continues to support local historical memory, heritage education, and tourism.

Detail:

> The Limahong Channel preserves local memory of the 1575 Pangasinan campaign and supports heritage education and tourism initiatives in Lingayen.

**THE STORY IN BRIEF** — NONE detail:

> The Limahong Channel connects the memory of the 1575 Pangasinan campaign with Lingayen's continuing heritage.

**THINK ABOUT IT**

> Why has the Limahong Channel remained historically significant to Lingayen?

**KEY TAKEAWAY**

> The Limahong Channel is remembered because of its traditional association with Limahong's 1575 escape from the Pangasinan blockade. That historical memory continues to contribute to Lingayen's local heritage, education, and tourism initiatives.

**Overall narration transcript** — recording pending:

> After his failed attacks on Manila in late 1574, Limahong established a fortified settlement in Pangasinan. In 1575, an expedition led by Juan de Salcedo blockaded the settlement, while Limahong's group escaped through a channel reportedly dug toward the sea. The present Limahong Channel is traditionally associated with that escape route, although its exact identification has not been independently established archaeologically. Today, the channel preserves the memory of the event as part of Lingayen's heritage.

Shell labels: **LISTEN**, **Sources**, **Close**, and **Narration pending**. All approved historical wording and the traditional-association qualification are retained.

## Selection, default presentation, and animation

- `SummaryTopic.NONE = -1` is the real initial state; no topic is preselected. Initial keyboard focus goes to Sources so no card initially resembles a selection. At a Glance, all five synopses, Story in Brief, reflection, and takeaway are available immediately.
- One authoritative `select_topic()` cancels old Tweens, normalizes appearance, toggles the selected card back to NONE, updates detail and connector emphasis, and optionally animates. Zero or one card is selected. Activating any topic never changes reflection or takeaway visibility.
- Cards and connector fade in together over 400 ms. There is no sequential reveal or forced walkthrough.
- Selection emphasizes the muted-gold card border and its connector region over 200 ms. Updated detail fades from 65% to full opacity over 180 ms. No bounce, pulse, movement, scale accumulation, reward treatment, or locked-looking dimming occurs.
- Closing, resizing, selecting rapidly, and opening Sources cancel active Tweens and normalize opacity/emphasis. Closed/reopened state is NONE, narration stopped, Sources hidden, detail scroll at the top. Parent focus is restored on close.
- There are no visited-topic variables, completion signals, progress counters, Previous, Next, Replay, Reset Detail, or prerequisite logic.

## Godot-generated storyline and symbols

The controller draws directly through Godot `Control.draw` callbacks. No connector or symbol image asset is loaded.

| Topic | Generated symbol |
| --- | --- |
| Retreat | Directional polyline with a small arrow |
| Blockade | Open enclosing arc |
| Escape | Two gently curved water lines |
| Tradition | Document outline with three text lines |
| Heritage | Open-book outline and spine |

Text remains authoritative. These symbols are conceptual interface aids, not documentary reconstructions. The neutral connector is a thin line with short stems and small topic regions; only the selected region gains muted-gold emphasis. At compact size it connects 01–02–03, then routes through the inter-row gap to 04–05 without crossing card text. This represents reading order, not geography or a tactical route. Numbering remains visible in both layouts.

## Responsive results

Native rendered screenshots and geometry/text-fit assertions were checked with the component inside the preview's 90% parent frame, rather than assuming viewport-global dimensions.

| Window | Component frame | Card layout | Result |
| --- | --- | --- | --- |
| 1280×720 | 1152×648 | Five across, about 214×168 px each; full titles | PASS: all introductory, card, detail, reflection, and takeaway content visible |
| 960×540 | 864×486 | Five across, about 160×146 px each; full titles | PASS: no header collision or clipped card/detail/reflection text |
| 854×480 | 768.6×432 | 3+2, about 245×76 / 245×84 px; compact titles | PASS: chronological connector, full selected title, full Topic 04 qualification, reflection, and takeaway visible |

At compact size, the lower information/reflection split is approximately 44%/56% to accommodate the full takeaway. Card body text is 12 px at both smaller sizes; the compact persistent qualifier is 10 px. Detail body is 13 px at the smaller sizes. These are visual-review points for the researcher, not a claim about physical-device readability. Whole-card targets exceed 56 px height at all requested sizes. No whole-page scroll is introduced; the internal detail scroll remains keyboard accessible, but the supplied detail including Topic 04 fits without scrolling at these sizes.

## Sources, narration, and input

Sources uses the shared overlay and focus trap, with END-01's full source text rather than the base shell's three-concept indexing. It preserves the selected topic, detail, and narration. Escape closes Sources first; a subsequent Escape closes the hotspot. Background topic controls cannot change selection while Sources is open.

Sources separates the five historical/content categories and explains that the historical escape account does not establish exact modern-channel identity. Existing repository source categories include Francisco de Sande's account, the Shutz academic study, provincial historical material, and the Project Historical Profile / Validation Sheet. Full bibliographic details, pages, source links, and signed validation remain pending; none were invented or downloaded.

One overall narration stream is supported through the existing player. `narration_stream` is currently unassigned: LISTEN and the exact shared speaker icon remain visible and disabled, with Narration pending shown. There is no autoplay, per-card narration, or other hotspot audio. Selection, changes, deselection, and Sources do not start or restart playback. Closing stops playback. Tests use an in-memory synthetic WAV only to exercise future single-stream continuity; no test audio asset is saved.

Mouse click and synthetic touch activate the whole card; tests cover corners as well as centers. There is no hover dependence, drag, or swipe requirement. One card is one focus stop: child labels/symbols do not intercept input or focus. Tab/Shift+Tab traverse the enabled header controls, chronological cards, and internal detail scroll; overlay focus stays within Sources. Left/Right move card focus without selecting or wrapping at endpoints. Enter and Space activate/toggle. Focus styling is distinct from muted-gold selection styling. At compact size the chronological focus order remains 01–05.

## Automated verification

| Check / suite | Result |
| --- | --- |
| LCH-END-01 | **4,865 checks, 0 failures**, all three viewports, native Compatibility rendering |
| LCH-EXT-01 | 0 failures, all three viewports |
| LCH-EXT-02 | 0 failures, all three viewports |
| LCH-EXT-03 | 0 failures, all three viewports |
| LCH-INT-01 | 594 checks, 0 failures, all three viewports |
| LCH-INT-02 | 2,663 checks, 0 failures, all three viewports |
| LCH-INT-03 | 1,859 checks, 0 failures, all three viewports |
| Final headless editor import | Exit 0; references and GDScript load successfully |
| `git diff --check` and staged whitespace check | PASS |
| Whitespace checks of all new END-01 files | PASS |
| Original files, index entries, HEAD | Unchanged from fresh END-01 baseline |

END-01 assertions cover all five exact synopses/details, default NONE, same-card deselection, persistent reflection/takeaway, qualification visibility, all card bounds, real mouse/keyboard/synthetic-touch events, focus order/endpoints, Sources blocking/preservation, Escape hierarchy, close/reopen, return focus, no autoplay, one-stream continuity, and exact symbol/resource wiring. The entrance test checks the 400 ms fade at its midpoint and completion. Rapid switching checks deterministic state, zero/one selected card, correct text/emphasis, full opacity, unit scale, and cleared Tween references.

Both requested rapid sequences are covered:

```text
RETREAT → ESCAPE → HERITAGE → BLOCKADE → TRADITION
TRADITION → TRADITION → RETREAT → RETREAT → HERITAGE
```

Static production checks cover unsupported exact-route phrases, retained traditional association and archaeological qualification, absence of completion/progress/assessment mechanics, and absence of earlier hotspot media/route/magnifier/personality/development interactions. END-01 does not repeat INT-03's facility list or biographies.

No END-01 parser errors, gameplay/script runtime errors, or leaked objects were reported in the final test. Godot logs the environment-level startup message `Failed to read the root certificate store` in this sandbox, including unchanged regression suites and headless import; no network operation is used here. EXT-01 also retains its pre-existing shutdown warning about two ObjectDB instances. INT-03 prints its expected missing-image-fixture warnings. Those existing/environment diagnostics were not changed under END-01 scope.

### Reproduction and evidence

Run from the repository using the local Godot 4.7.2 console executable:

```powershell
$godot = 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = Join-Path $env:TEMP 'akar-godot-end01'
$env:LOCALAPPDATA = $env:APPDATA
& $godot --headless --editor --path . --import
& $godot --path . --script res://tests/lch_end_01_test.gd -- --capture
& $godot --headless --path . --script res://tests/lch_ext_01_test.gd
& $godot --headless --path . --script res://tests/lch_ext_02_test.gd
& $godot --headless --path . --script res://tests/lch_ext_03_test.gd
& $godot --headless --path . --script res://tests/lch_int_01_test.gd
& $godot --headless --path . --script res://tests/lch_int_02_test.gd
& $godot --headless --path . --script res://tests/lch_int_03_test.gd
git diff --check
git status --short
```

Logs are in `%TEMP%`: `lch-end01-test.log`, `lch-end01-import.log`, and `lch-end01-regression-{ext_01,ext_02,ext_03,int_01,int_02,int_03}.log`.

Native captures are `%TEMP%/lch-end-01-{1280x720,960x540,854x480}-{none,tradition}.png`. All six captures were inspected during layout work, with the final NONE and selected-Tradition layouts rechecked after the initial-focus adjustment. These captures and logs are local verification artifacts, not repository assets.

## Researcher F6 / manual review

1. Open `scenes/landmarks/limahong_channel/summary/lch_end_01_preview.tscn` and press F6. Activate the open button; do not run a master scene. Check 1280×720, 960×540, and 854×480 using the debugger/game window size controls without changing project settings.
2. Confirm no card is selected and that At a Glance, all five synopses, Story in Brief, reflection, and takeaway are readable without interaction. Confirm the simultaneous entrance is brief, not a forced walkthrough.
3. Select each card and activate it again to return to NONE. Confirm each full detail title and exact wording. At 854×480, review compact 3+2 readability and the persistent qualifier, especially its smaller text.
4. Select Tradition. Confirm TRADITIONAL ASSOCIATION and the full archaeological qualification remain visible. Confirm nothing identifies the present channel as an archaeologically proven exact route.
5. Exercise the rapid sequences above and selection during the entrance. Check that only the latest selection remains, unselected text remains readable, and no delayed animation changes the result.
6. Use Tab, Shift+Tab, Left, Right, Enter, and Space. Check chronological focus order, endpoint behavior, one focus stop per card, and focus distinct from selection. Click/tap card edges as well as text/symbols.
7. Open Sources with Tradition selected, scroll it, and press Escape. The overlay alone should close; Tradition remains selected. Press Escape again to close the hotspot. Reopen and confirm NONE and focus behavior. Repeat Close during a selection fade.
8. Confirm LISTEN remains visible and disabled with Narration pending. No audio should autoplay or be borrowed from another hotspot.
9. Review the reflection and takeaway as reading-only content, without a response requirement or completion indicator.

## Outstanding items and final boundary

- Researcher-provided END-01 overall narration recording.
- Final bibliographic citations, source pages/links, and validation details.
- Signed historical validation: **source-backed project content prepared for validation**. Per the supplied brief, the available sheet has unchecked validation boxes and no signed overall approval. No actual signed validation file was found in the repository; formal signed approval is not claimed.
- Browser export testing, including browser text rendering and browser input behavior.
- Physical touchscreen testing; automated synthetic touch is complete.
- Researcher F6/manual visual review, particularly compact readability.

No END-01 commit, push, master scene, new landmark, or other hotspot work. Stop here for researcher review.
