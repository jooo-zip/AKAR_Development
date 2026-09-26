# CR-EXT-02 — Architecture of the Royal House

Implemented 26 September 2026 with Godot 4.7.2, typed GDScript and Compatibility rendering. Ready for researcher F6 visual review. No CR-EXT-03, Casa Real master layout, project setting change, staging, commit or push is included.

## Purpose and educational objective

At the Casa Real exterior architectural observation point, help visitors recognize the three researcher-approved architectural features through supplied documentary photographs and concise interpretation. Visitors choose any feature directly and return to contextual Overview using Full View. The component supports the historical walkthrough and acceptability research scope without making claims of improved learning effectiveness.

Approved features are **Thick Masonry Walls**, **Wooden Balcony**, and **Piedra China Staircase**. Overview is contextual navigation, not a fourth feature. French doors and ventanillas are deliberately excluded from the educational states, as are ventilation, natural-light and other unapproved architectural explanations. No manual zoom, pan, progress counter, required sequence, completion status, scores, rewards, accounts or other game mechanics were introduced.

## Architectural basis and exact visitor wording

The researcher's Phase 5 request supplies the approved wording following Phases 1–4. All interpretation, state media, captions, transcript and source text live in `data/landmarks/casa_real/cr_ext_02.tres`. The controller selects Resources rather than supplying architectural paragraphs.

Title: **ARCHITECTURE OF THE ROYAL HOUSE**

Subtitle: **Spanish Colonial Architecture with Georgian Influence**

| State | Selector | Key | Heading | Caption |
| --- | --- | --- | --- | --- |
| `OVERVIEW` (default) | FULL VIEW, secondary context control | None | Spanish Colonial Architecture with Georgian Influence | Casa Real — Full Façade |
| `MASONRY_WALLS` | MASONRY WALLS | ADOBE · BRICK · STONE | Thick Masonry Walls | Masonry Detail |
| `WOODEN_BALCONY` | WOODEN BALCONY | FAÇADE DETAIL | Wooden Balcony | Wooden Balcony |
| `PIEDRA_CHINA` | PIEDRA CHINA STAIRCASE | GRANITE STAIRCASE | Piedra China Staircase | Piedra China Staircase |

Overview body:

> Casa Real is a two-storey stone-and-brick masonry structure. Among its documented architectural features are its thick masonry walls, wooden balcony, and piedra china staircase.

Masonry body:

> Casa Real's thick adobe and brick walls form part of its stone-and-brick masonry construction and were designed for durability.

Balcony body:

> The wooden balcony is one of Casa Real's documented architectural features and is a prominent exterior element of the building.

Piedra China body:

> Casa Real includes a piedra china staircase, a granite staircase that forms part of the building's documented architectural character.

Learning takeaway:

> Casa Real's architecture combines durable masonry construction with distinctive features such as its wooden balcony and piedra china staircase.

Narration transcript supplied by the researcher:

> Casa Real combines Spanish colonial architecture with Georgian influence. Its architectural character includes thick masonry walls designed for durability, a prominent wooden balcony, and a piedra china staircase made of granite. These features are important details to observe when examining the historic structure.

## Asset audit and source metadata

Every asset below was present before implementation. Files and existing import metadata were preserved byte for byte. The balcony composite is displayed exactly as supplied; no photograph was edited, reconstructed, cropped, filtered, replaced or generated.

| Use | Actual repository path | Credit basis |
| --- | --- | --- |
| Overview | `assets/landmarks/casa_real/exterior/cr_ext_01_facade.png` | Existing CR-EXT-01 Resource and researcher's earlier attribution: Province of Pangasinan official website |
| Masonry | `assets/landmarks/casa_real/exterior/architecture/cr_ext_02_masonry.jpg` | Researcher explicitly confirmed AKAR Research Team during this implementation |
| Balcony | `assets/landmarks/casa_real/exterior/architecture/cr_ext_02_balcony.png` | Researcher explicitly confirmed Benjie Layug / B.L.A.S.T. during this implementation |
| Piedra China | `assets/landmarks/casa_real/exterior/architecture/cr_ext_02_piedra_china.jpg` | Researcher explicitly confirmed AKAR Research Team during this implementation |
| Narration | `assets/landmarks/casa_real/audio/cr_ext_02_narration.ogg` | Researcher-supplied CR-EXT-02 audio; imported AudioStreamOggVorbis with looping disabled |
| Speaker | `assets/ui/icons/speaker.svg` | Existing AKAR shared shell asset |

Overview source: [Province of Pangasinan — LGU-P’sinan inaugurates Banaan Pangasinan Provincial Museum on Sept. 8](https://www.pangasinan.gov.ph/lgu-psinan-inaugurates-banaan-pangasinan-provincial-museum-on-sept-8/).

Balcony source: [Benjie Layug / B.L.A.S.T. — Casa Real (Lingayen, Pangasinan)](https://benjielayug.com/2023/09/casa-real-lingayen-pangasinan.html).

The supplied B.L.A.S.T. page was checked. It documents a balcony and a piedra china granite staircase; it is included as a researcher-supplied architectural reference. It is not presented as substantiating every classification, construction or durability claim. No dates or additional historical/architectural facts from that page were added to the educational states. Source dates embedded in citation URLs do not constitute extra historical lessons.

Complete bibliographic citations for the architectural classification, masonry construction and durability were not supplied or found in repository notes. Sources clearly marks these as pending researcher supply while retaining the approved interpretation.

**Permission/license status:** no third-party reuse permission or license metadata was supplied for the balcony composite or overview photo. This remains unspecified/pending documentation before public deployment. A source credit does not establish reuse permission. Team attribution is documented for masonry/staircase; no individual photographer name, license or copyright claim was inferred. Permission notes stay in this development document.

## Architecture and reuse

Production scene: `scenes/landmarks/casa_real/exterior/cr_ext_02.tscn`.

F6 preview: `scenes/landmarks/casa_real/exterior/cr_ext_02_preview.tscn`; it instantiates the actual production scene. The preview automatically opens Overview and exposes a developer Reopen button only after Close.

Reused without modifying shared files:

- `scenes/components/conference_room_interaction.tscn`: full-parent shell, header controls, Sources overlay, shared theme/focus styling, speaker icon and AudioStreamPlayer.
- `scripts/components/conference_room_interaction.gd`: button signal wiring, close/open signals, Sources dismissal, Escape hierarchy, focus restoration and audio cleanup.
- `scripts/components/conference_room_content.gd` and `conference_room_concept_entry.gd`: approved content/media structure.
- CR-EXT-01's approved inset, header, responsive focus-path rebuild and standalone F6 sizing patterns, adapted locally for the documentary detail viewer. CR-EXT-01 at commit `6908e43` remains unchanged.

Two small Resource extensions are necessary: `cr_ext_02_detail.gd` adds selector/key/caption/image/credit fields absent from the shared entry; `cr_ext_02_content.gd` adds a separate Overview Resource while the three features use the inherited `concepts` array. Overview is not inserted as an extra feature button. No new autoload or audio framework is used.

## Interaction, animation and lifecycle

`current_state: ArchitectureState` is the authoritative state. The inherited shell's `_selected` field is unused by CR-EXT-02 rendering, Sources and getters. Every selection route converges on `select_state()`; feature button indices map to states 1–3, and Full View requests state 0. Invalid requests and selection while closed or under Sources are rejected.

The current feature receives the shared muted gold selection fill. Overview leaves all three feature selectors unselected. Full View is a smaller secondary button beneath the viewer, never styled as feature completion. Keyboard focus has a separate bright outline. Arrows move focus only; Enter/Space activates.

The image, caption and interpretation fade out together for 130 ms, then the controller reads the current Resource and fades them in over 190 ms. A new request kills the old transition rather than queuing it. No stale state is captured by callbacks. Images have no scale/position animation. Opening uses the CR-EXT-01 pattern: 220 ms root reveal and viewer reveal from 150–450 ms. The viewer-level opening fade and image-level state fade do not compete for the same property.

The root fills its host and includes a dim layer. The visible Main panel stays inset, allowing a future Casa Real master environment to remain behind it. Close emits the existing shared `closed` signal; no future master navigation is hardcoded.

Every reopen restores Overview, the façade, the exact overview text, no selected feature, closed Sources, zero narration position, unpaused/stopped audio, full image/text opacity, default transform and selector focus. Closing or host hiding stops audio, cancels both Tweens, closes Sources and clears temporary opacity. Removing the component also cancels animation/audio.

### Narration

No autoplay. The actual CR-EXT-02 Ogg file is assigned to the shared AudioStreamPlayer. This request explicitly calls for **LISTEN / PAUSE / RESUME**, so a local transport override uses the same player with `stream_paused`; CR-EXT-01's LISTEN/STOP behavior is untouched. Feature changes and Full View never call play, stop or seek. Close/reset stops playback and clears pause. Natural completion returns the control to LISTEN through inherited signal wiring.

The header remains **SOURCES | LISTEN | CLOSE** (PAUSE/RESUME during playback), with narration immediately left of Close.

### Sources

The inherited opaque, root-sized overlay stays inside the hotspot. It shows the common architectural source information and the current photograph's caption and confirmed credit. Its local scroll contains long references. Opening it resolves any in-progress image transition to the current state, preserves that state/image, blocks underlying feature/Full View controls, and confines keyboard focus to the overlay. Escape closes Sources first; when Sources is closed, Escape closes the hotspot. Input is consumed before navigation/close signals can remove the component.

## Responsive results

| Viewport | Visible Main | Layout and result |
| --- | --- | --- |
| 1280×720 | 1152×648; 90% | Passed all four views. Two columns with 59% viewer / 41% interpretation; 60 px vertical selectors, full feature labels, 20 px body text. |
| 960×540 | 864×486; 90% | Passed all four views. Two columns retained; horizontal 56 px selectors with full labels. Full-width subtitle row; 18 px body text. |
| 854×480 | Approximately 820×461; 96% | Passed all four views. Horizontal MASONRY / BALCONY / PIEDRA CHINA labels; 18 px body text. Full headings and takeaway retained. |

Controls remain at least 56 px high. The long approved subtitle gets a full-width row in compact landscape mode. Full View and the photo caption share a footer beneath the consistent viewer frame. Images use `EXPAND_IGNORE_SIZE` and `KEEP_ASPECT_CENTERED`, with linear sampling local to documentary media; full source compositions remain visible with letterboxing. The façade is naturally narrower inside the short compact frame, while landscape feature images occupy more of its width. No whole-screen or interpretation scrolling, clipped controls, overlapping text or portrait-style feed was observed.

The preview temporarily removes reference-canvas scaling to test actual logical window dimensions, then restores its host window setting on exit. Production inherits its host's canvas policy. Compatibility, canvas_items stretch, expand aspect and global pixel-art filtering remain unchanged.

No CR-EXT-02 portrait UI was built. The final global rotate-device prompt is absent from the repository and is a separate integration dependency. Returning to landscape preserves view state and valid focus paths.

## Tests performed

`tests/cr_ext_02_test.gd` instantiates the real production preview. Pointer and keyboard tests inject events through `Input.parse_input_event`; touch uses `InputEventScreenTouch` with existing engine settings, not direct button-signal calls. No project input settings are changed.

At each target size the suite verifies:

- Overview defaults, no selected feature, correct initial photo/text and no autoplay.
- All 12 directed state changes plus repeated current selection, including Full View from every feature.
- Correct photograph, caption, key, heading, exact body and selection for every view.
- Rapid interrupted sequence Masonry → Piedra → Balcony → Overview → Piedra → Masonry, cancellation of previous Tweens, correct final opacity and unchanged image transforms.
- Mouse and synthetic touch for all three features, Full View, Sources, narration, Close and preview reopen; repeated/alternating taps.
- Tab and Shift+Tab across Masonry, Balcony, Piedra, Full View, Sources, Listen, Close; Enter/Space activation; arrow focus without selection.
- Actual narration import/duration, Listen/Pause/Resume, uninterrupted playback position across feature and Full View changes, paused position preservation, stop/reset on close and reopen.
- Sources state/image preservation, current-photo attribution, underlying selector/Full View shielding, local focus containment, Sources Close and Escape hierarchy.
- Close signal emitted once, close during opening/state transitions, reset while paused, reopen, host-hide cleanup and portrait-to-landscape recovery.
- Centering/inset bounds, all control/text bounds, minimum hit areas, viewer dimensions, 58–62% column ratio, photo aspect mode, header order and different selected/focus styles.

The initial strict paused-position test sampled before the mixer had consumed the pause command. The harness now waits 100 ms after pausing before checking position; production selection never touches playback. Final runs pass without relaxing the equality check.

| Validation | Result |
| --- | --- |
| CR-EXT-02 headless | **1,897 checks, zero failures**, exit 0 |
| CR-EXT-02 native rendered Compatibility | **1,921 checks, zero failures**, exit 0 |
| Rendered visual inspection | All 12 main-state screenshots inspected, plus Sources; all three target sizes pass |
| Godot editor import / script and scene validation | Passed; exit 0 |
| Unchanged CR-EXT-01 regression | **1,983 checks, zero failures**, exit 0; includes its original Urduja shared-shell checks |
| Git whitespace | `git diff --check` exit 0; all 14 new text/UID files pass separate untracked-file whitespace checks |
| Repository preservation | All 36 baseline file hashes match; staging index remains empty |

Native rendering used OpenGL 3.3 Compatibility on Intel UHD Graphics. No browser-export, physical-device touch or human listening/transcript-verification result is claimed. Godot logs the existing environment-level `Failed to read the root certificate store` diagnostic in both new and unchanged tests. No script/scene/runtime-test errors or leaked-resource diagnostics occurred in the final runs. Sandbox editor/cache paths were directed to process-local APPDATA/LOCALAPPDATA under TEMP; no global environment or project setting was changed.

## Manual F6 review and reproducible checks

1. Open `scenes/landmarks/casa_real/exterior/cr_ext_02_preview.tscn` and press **F6**. Confirm Overview, façade and no selected feature/audio. Close and use the preview's Open button to reopen.
2. Resize the detached preview to 1280×720, 960×540 and 854×480. Inspect the inset margins, all four photographs, full text, compact labels, Full View and toolbar. Check that the entire supplied balcony composite remains visible.
3. Select every feature directly in any order, repeat the current choice, and alternate rapidly. Use Full View from each feature. Confirm the image and text always agree after the fade.
4. Use Tab/Shift+Tab, Enter/Space and selector arrows. Confirm that focus alone does not select and that focus outline differs from gold selection.
5. Listen to the real narration and compare it with the approved transcript above. Pause/resume, change features and use Full View while playing/paused. Close and reopen; confirm playback is stopped and reset.
6. Open Sources from each view and scroll to its photo credit. Attempt taps on underlying selectors and Full View. Escape must dismiss Sources first and preserve the current view; a second Escape closes the hotspot.
7. Close during a fade or initial reveal, then reopen immediately. Confirm clean Overview. Repeat on the exported Web build and museum tablet/phone during deployment review.

Installed executable: `C:/Users/Admin/OneDrive/Documents/Godot Files/Godot_v4.7.2-stable_win64_console.exe`.

```powershell
$godotExe = 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe'
& $godotExe --headless --editor --path . --import --quit
& $godotExe --headless --path . --script res://tests/cr_ext_02_test.gd
& $godotExe --path . --rendering-method gl_compatibility --script res://tests/cr_ext_02_test.gd -- --capture
& $godotExe --headless --path . --script res://tests/cr_ext_01_test.gd
git diff --check
git status --short
```

Evidence: `%TEMP%/akar_cr_ext_02_headless_final.log`, `_rendered.log`, `_import.log` and `_regression.log`. Screenshots use `%TEMP%/akar_cr_ext_02_<width>x<height>_state<0–3>.png` and `_sources<0–3>.png`.

## Repository preservation and outstanding issues

Initial Git state: HEAD `6908e43`; no staged files; existing unstaged `project.godot` edits; untracked CR-EXT-02 media/import files and unrelated `docs/references/` files. Baseline paths and SHA-256 hashes were saved to `%TEMP%/akar_cr_ext_02_baseline.json`, including CR-EXT-01 and shared shell files.

Only new CR-EXT-02 scene, controller, Resource, preview, test, documentation and Godot `.uid` files are added. The supplied media/import sidecars already existed. CR-EXT-01, shared components, `project.godot` and unrelated references remain untouched. No staging, commit or push is performed.

Final status preserves the original ` M project.godot` and untracked media/references, adding only the CR-EXT-02 files listed above. All 36 baseline hashes match. The production CR-EXT-02 files were scanned for excluded architectural/historical topics with no matches; the exact approved paragraphs also pass runtime assertions.

Outstanding before final public deployment:

- Researcher F6 visual review and human narration listening review.
- Complete researcher bibliographic citations for architectural classification, masonry construction and durability.
- Documented third-party media reuse permission/license status; source attribution alone does not establish permission.
- Exported-browser and physical touchscreen checks.
- Global landscape/rotate-device handling outside CR-EXT-02.

Stop after CR-EXT-02. Do not create CR-EXT-03, integrate the master layout or make a milestone commit until separately authorized by the researcher.
