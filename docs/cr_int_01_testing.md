# CR-INT-01 — From Royal House to Provincial Museum

## Purpose and historical scope

Educational question: How was Casa Real preserved and given a new purpose?

The standalone Phase 5 hotspot covers damage in 2008, restoration beginning in 2015, formal turnover in 2021, museum opening in 2023, and the present educational/cultural purpose. It does not repeat Casa Real's full timeline or introduce other hotspots, galleries, artifacts, architectural feature lessons, game mechanics, completion tracking, accounts, or master-scene integration.

States: OVERVIEW, DAMAGE, RESTORATION, MUSEUM_REBIRTH. Exactly three historical selectors; Overview is contextual navigation. Historical wording, captions, helpers, credits, and audio references are Resource-driven.

## Files and reused components

- Production: `scenes/landmarks/casa_real/interior/cr_int_01.tscn`.
- F6 preview: `scenes/landmarks/casa_real/interior/cr_int_01_preview.tscn`; instantiates the production component.
- Controller: `scripts/landmarks/casa_real/cr_int_01.gd`.
- Preview controller: `scripts/landmarks/casa_real/cr_int_01_preview.gd`.
- Resource scripts: `cr_int_01_content.gd` and `cr_int_01_stage.gd` in the same script directory.
- Small local controls: `cr_int_01_comparison.gd` (56 px drag region) and `cr_int_01_storm_visual.gd` (bounded procedural drawing).
- Content: `data/landmarks/casa_real/cr_int_01.tres`.
- Tests: `tests/cr_int_01_test.gd`.

Reuses the existing `scenes/components/conference_room_interaction.tscn`, `scripts/components/conference_room_interaction.gd`, ConferenceRoomContent and ConferenceRoomConceptEntry. This supplies the Casa Real palette/theme, dim/inset convention, toolbar, Sources panel, narration player, and safe Escape lifecycle. The repository uses `opened` and `closed` signals (rather than a signal literally named close_requested); CR-INT-01 preserves those established signals. The inherited legacy selection field is unused. No shared file or completed exterior hotspot was modified.

## Exact visitor copy

Title: FROM ROYAL HOUSE TO PROVINCIAL MUSEUM

Subtitle: How Casa Real was preserved and given a new purpose

### Overview

Heading: A HISTORIC BUILDING, A NEW PURPOSE

Prompt: HOW DID CASA REAL BEGIN A NEW CHAPTER?

Body: After years of changing public use and deterioration, Casa Real underwent a major preservation effort that transformed the historic structure into the Banáan Pangasinan Provincial Museum.

Helper: SELECT A STAGE OF THE TRANSFORMATION

### Damage

Year: 2008

Selector: 2008 / DAMAGE. Compact: 2008 / DAMAGE.

Heading: TYPHOON COSME DAMAGE

Body: After decades of changing use and deterioration, Casa Real suffered severe damage during Typhoon Cosme in 2008.

### Restoration

Year: 2015–2021

Selector: 2015–2021 / RESTORATION. Compact: 15–21 / RESTORE.

Heading: PRESERVING CASA REAL

Body: A multi-phase restoration involving national and provincial government institutions sought to preserve Casa Real’s architectural and historical significance. Restoration began in 2015, and the restored structure was formally turned over to the Provincial Government of Pangasinan in 2021.

Helper: DRAG TO COMPARE

### Museum

Year: 2023

Selector: 2023 / MUSEUM REBIRTH. Compact: 2023 / MUSEUM.

Heading: A NEW PURPOSE

Body: In 2023, Casa Real formally opened as the Banáan Pangasinan Provincial Museum. The restored historic building now serves as a center for education, cultural memory, and Pangasinan identity.

Helper: TAP PHOTO TO SEE BANÁAN TODAY

Second-photo helper: TAP PHOTO TO RETURN

Informational identity label:

```text
CASA REAL
Historic Government Building
↓
BANÁAN PANGASINAN
PROVINCIAL MUSEUM
2023
```

## Asset audit and source metadata

The two supplied transformation photographs are **PNG**, despite the JPG examples in the specification. Their actual filenames are used unchanged. All four mandatory CR-INT-01 assets were present before coding; the optional restoration-work photograph is not needed.

| Use | Actual repository path | Source / permission |
| --- | --- | --- |
| Overview | `assets/landmarks/casa_real/exterior/cr_ext_01_facade.png` | Existing Province of Pangasinan official website credit; permission unspecified / pending documentation. |
| Damage and Before Restoration | `assets/landmarks/casa_real/interior/transformation/cr_int_01_cosme_damage.png` | NorthWatch, “Casa Real coming back to life,” article by Yolanda Sotelo. Photographer not identified on source page. Permission unspecified / pending documentation. |
| After Restoration | `assets/landmarks/casa_real/interior/transformation/cr_int_01_restored_2022.png` | Patrickroque01; Wikimedia Commons; 5 December 2022; CC BY-SA 4.0. |
| Museum primary | `assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_heritage_museum.jpg` | Existing NHCP National Registry credit from CR-EXT-03; permission unspecified / pending documentation. |
| Museum secondary | `assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_banaan_identity.jpg` | Existing Banáan official website credit; permission unspecified / pending documentation. |
| Narration | `assets/landmarks/casa_real/audio/cr_int_01_narration.ogg` | Researcher-supplied audio; narrator/creator not documented. Permission unspecified / pending documentation. |
| Atmosphere | `assets/landmarks/casa_real/audio/cr_int_01_storm_ambience.ogg` | Creator/source: researcher-supplied audio. License/permission unspecified unless documented; no invented creator or license. |
| Speaker | `assets/ui/icons/speaker.svg` | Existing shared AKAR icon; reused unchanged. |

References retained in Sources:

- [NorthWatch article](https://northwatch.wordpress.com/2016/06/18/casa-real-coming-back-to-life/). Yolanda Sotelo is credited as **article author**, not photographer.
- [Patrickroque01's Wikimedia Commons file](https://commons.wikimedia.org/wiki/File:Lingayen_Casa_Real_(Poblacion,_Lingayen,_Pangasinan;_12-05-2022).jpg), with [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). The supplied creator/date/license are also present on this source page.
- [NHCP National Registry — Casa Real ng Lingayen](https://nhcphistoricsites.blogspot.com/2011/10/old-casa-real-and-provincial-capitol.html).
- [Banáan Pangasinan Provincial Museum official website](https://banaan.seepangasinan.com/).
- [Province of Pangasinan façade source](https://www.pangasinan.gov.ph/lgu-psinan-inaugurates-banaan-pangasinan-provincial-museum-on-sept-8/).

Restored 2022 credit includes the required notice: **“Cropped/resized for AKAR presentation.”** The implementation performs proportional on-screen resizing only; the supplied PNG is unchanged, with no added crop, rotation, perspective warp, or reconstruction. No original photographer names or NHCP Photo Collection designation were inferred. Reused exterior photographs were referenced directly, not copied.

Historical content is the researcher's approved Phase 5 wording. The Sources overlay separates HISTORICAL CONTENT, DOCUMENTARY MEDIA, ATMOSPHERIC MEDIA and NARRATION. Complete claim-to-page historical citations remain pending researcher documentation; photo credits do not substitute for those citations.

## Overview

Opens on the façade, with no historical stage selected, no storm/audio, no comparison control and no museum toggle. Supporting text invites selection of a transformation stage. Toolbar order remains SOURCES / LISTEN / CLOSE.

## Damage: atmosphere, evidence and cancellation

Deliberate Damage activation starts a **3.0 second** sequence. Focus movement alone does not activate it. Repeated deliberate activation restarts safely; nothing loops.

| Elapsed time | Effect |
| --- | --- |
| 0.00–0.40 s | Neutral visual field darkens slightly. |
| 0.40–1.10 s | Procedural diagonal rain/wind builds. |
| 1.10–1.22 s | One low-opacity ambient flash rises to 0.12 alpha. |
| 1.22–1.44 s | Flash returns to zero. |
| 1.44–2.10 s | Brief stronger rain/wind. |
| 2.10–2.70 s | Rain and darkening fade out. |
| 2.70–3.00 s | Short settling interval, then documentary image/body revealed. |

The effect draws 56 simple rain strokes and seven wind strokes in a clipped Control. It uses no shader, particle texture, generative imagery, debris, structural animation or lightning bolt. It is confined to the visual region; header and navigation remain readable. Idle drawing stops after the storm.

During the effect, the authentic photograph and historical body are hidden; the neutral field is labelled **ATMOSPHERIC INTERPRETATION**. Afterward the supplied damage photograph appears with **DOCUMENTARY PHOTOGRAPH — 2008**. The atmosphere is not a reconstruction of the exact storm sequence or evidence of a lightning strike.

Click/tap the active visual or press Enter/Space while it has focus to skip. This immediately cancels the tween, stops ambience, clears rain/wind/darkness/flash and reveals stable Damage. Leaving Damage, closing, resetting or hiding the component also cancels the effect. Opening Sources stabilizes Damage before opening the modal. No storm remains behind Sources.

Storm audio uses the supplied Ogg on a separate AudioStreamPlayer at -18 dB, with looping disabled on a local duplicate of the stream Resource. It stops at sequence completion or cancellation. Audible narration has priority: storm sound is suppressed if narration is already playing, and starting/resuming narration during a storm immediately stops ambience while preserving the visual sequence. Paused narration permits a newly activated storm's ambience; ambience does not automatically restart mid-sequence.

## Restoration comparison audit and chosen mode

**Mode: OPACITY CROSSFADE.**

Both actual images were visually inspected before implementation. They show comparable three-quarter views, but camera position, roof/pediment geometry, framing and façade scale differ. A proportional crop/translation cannot align all architectural edges without introducing misleading jumps. True spatial split was therefore rejected under the specification's fallback rule.

Preparation: uniform contain scaling and centered placement inside the shared visual viewport. No offline asset edits, crop, x/y alignment offsets, stretching, perspective warp, generative extension or reconstruction. Each original aspect ratio remains intact; endpoint views show only the corresponding photograph. Midpoint transparency deliberately shows both perspectives instead of claiming exact spatial correspondence. The 2022 photograph is evidence of the restored building, not asserted to depict the 2021 turnover event.

Comparison starts at 0.5. A 56 px-high drag region controls visibility from Before (0.0) to After (1.0); the entire track is interactive. Mouse and native touch drag update immediately with no tween. Keyboard Left/Right changes by 0.05; Home/End choose endpoints. Values clamp to [0, 1]. No percentage or restoration-progress value is displayed.

Comparison position survives stage changes and Sources during one open session. Reopen/reset restores 0.5. Sources, stage changes and close end any active drag. Compact layouts group the two labels and DRAG TO COMPARE helper above the track and place Overview beside it, preserving more image height.

## Museum Rebirth

The main photo toggles restored Casa Real ↔ Banáan identity on click/tap or focused Enter/Space. The helper changes with the photograph. No previous/next or thumbnail controls exist. Photo selection is preserved across stage changes and Sources within the current session, then resets to the restored image on reopen. The approved identity label is informational and appears in the reading pane.

## Narration

No autoplay or TTS. The actual supplied narration file is used.

Casa Real suffered severe damage during Typhoon Cosme in 2008. Restoration began in 2015 through a multi-agency preservation effort, and the restored building was formally turned over to the Provincial Government of Pangasinan in 2021. In 2023, Casa Real formally opened as the Banáan Pangasinan Provincial Museum, giving the historic structure a new purpose in heritage preservation and public education.

Listen starts; Pause/Resume preserves position. Stage changes, comparison dragging, museum toggling, the atmospheric sequence, Overview and Sources do not restart narration. Close/reset stops playback and clears pause state. Storm audio never stops narration.

## Input, focus and responsive layout

Mouse, injected native touch and keyboard are exercised against the production scene. Focus order: three stages → active visual interaction when applicable → Overview → interpretation reading pane → Sources → Listen → Close. The reading pane is an additional focus target so its full text is accessible. Stage Left/Right changes focus without selection. Enter/Space activates; Tab/Shift+Tab traverses. Sources traps focus inside its reading area and close button.

Keyboard reading uses arrows, Page Up/Down, Home/End. Native touch dragging and mouse wheel scroll local text. The filled selected stage differs from the focus outline. Escape is consumed before closing Sources or emitting the inherited close signal.

The root remains a host-sized dim overlay. Reference panel is 90% (1152×648 at 1280×720); compact panels use 96%. The story region keeps approximately 65% visual / 35% interpretation. All primary buttons and comparison track remain at least 56 px tall. Body type is 20 px at reference size, 18 px compact. Only interpretation/Sources text scrolls; the main hotspot is not a full-screen article. No portrait redesign.

The F6 preview uses real window dimensions for responsive checks and restores the previous canvas policy when it exits. Production follows its host's canvas policy. Project Compatibility renderer, canvas_items/expand stretch, global filtering and input mappings were preserved.

## Reset and close contract

Every reopen resets to Overview, comparison 0.5, museum photo zero, no selected stage, no Sources, no narration, no storm, neutral overlays/transforms, no active drag and no live tweens. Reset restores first-stage focus. Close cancels stage/opening/storm animation, ends drag, stops both audio players, hides overlays and restores caller focus through the established shell. Host hiding follows the same cleanup.

## Validation results

Completed on 2026-09-26 with Godot 4.7.2:

| Check | Result |
| --- | --- |
| Import / GDScript / scene Resources | Passed; production and preview load without script/scene errors. |
| CR-INT-01 headless | 2,287 checks, zero failures. |
| CR-INT-01 rendered | 2,329 checks, zero failures; OpenGL Compatibility / Intel UHD Graphics. |
| 1280×720 | Interaction and bounds checks passed; representative stage/storm/comparison renders inspected. |
| 960×540 | Interaction and bounds checks passed; representative renders inspected. |
| 854×480 | Interaction and bounds checks passed; compact comparison midpoint/endpoints, Museum and Sources inspected. |
| Mouse / injected native touch / keyboard | Passed, including drag and local reading. |
| Storm / skip / cancellation | Passed, including real-time completion and Sources stabilization. |
| Comparison / Museum / rapid switching | Passed. |
| Narration / modal / reset / reopen | Passed; no leaked-object/resource warnings. |
| CR-EXT-01 regression | 1,983 checks, zero failures. |
| CR-EXT-02 regression | 1,897 checks, zero failures. |
| CR-EXT-03 regression | 5,431 checks, zero failures. |
| Repository preservation | All 506 original file hashes unchanged. |
| Whitespace | `git diff --check` and separate checks of new CR-INT-01 text files passed. |

The rendered run saves 39 distinct screenshot files (42 capture checks, with Museum captures refreshed for each input mode). Native event injection and desktop rendering do not establish physical-device or exported-Web acceptance; those remain researcher review items. The sandbox reports `Failed to read the root certificate store` at Godot startup in every suite. It does not prevent these local import, rendering, audio or input tests; no script, scene or focus warnings remain in the final CR-INT-01 runs.

Automated coverage includes all stage pairs and repeated activations; real-time automatic storm completion; mid-storm capture; pointer/keyboard skip; storm cancellation to Restoration, Museum, Sources and close; comparison mouse/touch endpoints and intermediate positions; keyboard/clamping/session retention; museum toggling; narration priority and pause continuity; modal input guards/focus; local reading; active-drag interruption; rapid mixed input; reset/reopen and host-hide cleanup.

Rendered captures are temporary files named `%TEMP%/akar_cr_int_01_<size>_<view>.png`, including stages, storm, comparison endpoints, museum toggle and Sources. These are verification artifacts, not production media.

Reproduction:

```powershell
$godotExe = 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = Join-Path $env:TEMP 'akar_cr_int_01_runtime\roaming'
$env:LOCALAPPDATA = Join-Path $env:TEMP 'akar_cr_int_01_runtime\local'
New-Item -ItemType Directory -Force -Path $env:APPDATA,$env:LOCALAPPDATA | Out-Null
& $godotExe --headless --editor --path . --import --quit
& $godotExe --headless --path . --script res://tests/cr_int_01_test.gd
& $godotExe --path . --rendering-method gl_compatibility --script res://tests/cr_int_01_test.gd -- --capture
& $godotExe --headless --path . --script res://tests/cr_ext_01_test.gd
& $godotExe --headless --path . --script res://tests/cr_ext_02_test.gd
& $godotExe --headless --path . --script res://tests/cr_ext_03_test.gd
git diff --check
```

## Researcher F6 review before milestone approval

1. Open `scenes/landmarks/casa_real/interior/cr_int_01_preview.tscn` and press F6. Use an external game window if embedded-preview sizing interferes.
2. At 1280×720, 960×540 and 854×480, check inset margins, title/subtitle, photos, stage controls, helper text, body readability and toolbar. Scroll the interpretation to read its full body and museum identity label.
3. Select Damage, watch the complete three-second atmosphere, and hear the supplied ambience. Verify a single restrained flash confined to the neutral visual area. Confirm the authentic photograph appears afterward.
4. Repeat Damage and skip using click, tap, Enter and Space. Interrupt it with Restoration, Museum, Sources and Close. Verify no remaining sound, dark overlay or rain.
5. Drag comparison with mouse and touch; use Left/Right/Home/End. Inspect both unaltered endpoint images and midpoint. Switch away/back and confirm position retention; reopen and confirm 0.5.
6. Toggle Museum images with mouse/touch/keyboard. Confirm the approved identity label and context helpers.
7. Play/pause/resume narration through all interactions. Start Damage while narration is audible, and start narration during Damage. Narration must remain intelligible and uninterrupted; storm sound must stop/suppress.
8. Read Sources to the final credits and license links. Confirm modal blocking, preserved session state and Escape hierarchy.
9. Alternate stages rapidly, close during storm or drag, and reopen. Confirm complete reset.
10. Listen to both recordings for intelligibility/content and inspect the intended exported Web build on physical museum tablets and landscape phones. Native test events do not establish physical-device/browser acceptance.

## Repository safety and remaining items

Initial HEAD: `6f27080` (completed CR-EXT-03); prior completed baselines `d675c1f` and `6908e43`. Initial work comprised modified `project.godot`, untracked CR-INT-01 photographs/audio and their import files, and `docs/references/`; nothing staged. Hashes were recorded before editing.

All 506 pre-existing file hashes remain unchanged, including all three completed hotspots, shared components, supplied media/import files, references and the existing `project.godot` modification. This milestone adds only 11 CR-INT-01 implementation/data/scene/test/documentation files and seven Godot UID sidecars. Nothing staged; HEAD remains `6f27080`. No commit or push performed.

Outstanding: researcher F6 visual/listening acceptance, exported-browser/physical-touchscreen review, complete historical claim citations, and permission/creator documentation for media whose rights remain unspecified. The restored 2022 photo retains Patrickroque01 and CC BY-SA 4.0 attribution. No authorization is inferred from a source credit.

No staging, commit, push, other hotspot or Casa Real master layout is part of this milestone.
