# CR-EXT-01 — Meet Casa Real

Implemented on 26 September 2026 using Godot 4.7.2, GDScript and Compatibility rendering. Standalone implementation ready for researcher F6 review; historical bibliographic citations and deployment-device review remain pending. No master layout, later hotspot, project setting, shared code, staging, commit or push is part of this change.

## Visual revision — centered inset Main panel (26 September 2026)

The visible `Main` PanelContainer now sits centered inside the full-parent CR-EXT-01 root instead of occupying nearly the whole screen. Responsive anchors provide 90% width and height at the reference viewport. Below 900 px root width, the panel uses 96% to preserve readable content and comfortable controls while retaining a visible surrounding margin.

| Viewport | Main panel size | Left/right margin | Top/bottom margin | Result |
| --- | --- | --- | --- | --- |
| 1280×720 | 1152×648 (90%) | 64 px | 36 px | Passed; original vertical selectors |
| 960×540 | 864×486 (90%) | 48 px | 27 px | Passed; existing horizontal selector variant |
| 854×480 | 819.84×460.8 (96%, approximately 820×461) | 17.08 px | 9.6 px | Passed; existing horizontal selectors, takeaway wraps to two lines |

Only decorative padding and gaps were reduced: main padding is 16 px at reference size and 8 px in compact mode. Existing font sizes, 60/56 px selector heights, 56 px toolbar targets, two-column proportions, and photograph aspect handling are unchanged. Responsive decisions now use the available inset panel dimensions.

A translucent black `DimLayer` fills the root behind Main. The F6 preview's neutral surrounding area remains visible. No background artwork or fake master layout was introduced. The root still fills its host and intercepts overlay input; a future Casa Real master environment can remain underneath it. Close continues to use the existing shared lifecycle and signals, with no hardcoded navigation. Sources retains its existing root-sized modal overlay and behavior.

The three identity states, Royal House default, approved historical content, all assets, narration, Sources, Escape hierarchy, mouse/keyboard/touch routes, transitions and reset behavior are unchanged. Production changes are confined to the scene's outer presentation and `_resize_layout()`.

Revision validation:

- Godot 4.7.2 headless: **1,983 checks, zero failures, exit 0**.
- Native OpenGL Compatibility rendered run: **1,998 checks, zero failures, exit 0**.
- All three states visually inspected at each of the three target sizes, with no clipping or overlap. Full Government Center label and takeaway retained. Photo remains uncropped and undistorted.
- Existing input, rapid switching, narration continuity/stop/reset, Sources shielding/focus/Escape, close/reopen and Urduja shared-shell checks passed.
- Layout assertions now verify the visible Main bounds, exact responsive dimensions, centering, all four margins, and root-sized dim layer. All nine state layouts are checked explicitly.
- Godot editor import and script/scene validation passed. The existing sandbox root-certificate-store diagnostic remains; no script, scene, resource-leak or test failures occurred.
- `git diff --check` and whitespace checks against saved pre-revision copies passed. The existing empty staging index and all files outside the four-file revision scope were preserved.

Changed files: `scenes/landmarks/casa_real/exterior/cr_ext_01.tscn`, `scripts/landmarks/casa_real/cr_ext_01.gd`, `tests/cr_ext_01_test.gd`, and this document. The revision baseline is `%TEMP%/akar_cr_ext_01_inset_baseline.json`; logs use `%TEMP%/akar_cr_ext_01_inset_*.log`. Existing screenshot paths below contain the revised renders. Earlier implementation test counts below are retained as the original validation record.

For researcher review, open `scenes/landmarks/casa_real/exterior/cr_ext_01_preview.tscn` and press **F6**. Inspect the margins and centered panel at all three sizes, switch through the identities, and close/reopen. The implementation remains ready for later master-layout overlay integration. Await researcher visual review; no commit or push is performed.

## Purpose and educational objective

Introduce Casa Real at the exterior arrival point: what it is, its original public role, and its present museum role. One documentary façade photograph remains visible across three directly selectable identities. The visitor can explore in any order without completion requirements. This supports the approved historical walkthrough scope and acceptability evaluation; no learning-effectiveness claim is made.

## Content basis and exact visitor wording

The researcher supplied the approved Phase 5 implementation specification after approval of Phases 1–4. Its interpretation and narration are stored in `data/landmarks/casa_real/cr_ext_01.tres`, using `ConferenceRoomContent` and a small `ConferenceRoomConceptEntry` extension for selector/key labels. No historical wording is embedded in the production controller.

Title: **MEET CASA REAL**

Subtitle: **The Royal House of Pangasinan**

| State | Selector | Key | Heading |
| --- | --- | --- | --- |
| `ROYAL_HOUSE` (default) | ROYAL HOUSE | 1840 | The Royal House |
| `GOVERNMENT_CENTER` | GOVERNMENT CENTER | PROVINCIAL GOVERNMENT | Residence and Office of the Alcalde Mayor |
| `BANAAN_TODAY` | BANÁAN TODAY | PRESENT DAY | Banáan Pangasinan Provincial Museum |

Royal House body:

> Casa Real, meaning “Royal House,” was constructed in 1840 during the Spanish colonial period.

Government Center body:

> Casa Real served as the residence and office of the Alcalde Mayor and supported Pangasinan's provincial administrative and judicial functions.

Banáan Today body:

> Today, the restored Casa Real houses the Banáan Pangasinan Provincial Museum, continuing its public role through heritage preservation and education.

Persistent learning takeaway:

> Casa Real's public role evolved from provincial government to heritage preservation and education.

Approved narration transcript:

> Casa Real, meaning “Royal House,” was constructed in 1840. It served as the residence and office of the Alcalde Mayor and supported the administration and judicial functions of Pangasinan during the Spanish colonial period. Today, this historic building is home to the Banáan Pangasinan Provincial Museum.

### Sources and media provenance

The researcher explicitly supplied this façade source during implementation:

[Province of Pangasinan — LGU-P’sinan inaugurates Banaan Pangasinan Provincial Museum on Sept. 8](https://www.pangasinan.gov.ph/lgu-psinan-inaugurates-banaan-pangasinan-provincial-museum-on-sept-8/).

The page was checked and the source title, institution and URL are included in Sources. No photographer or permission/license attribution was inferred. The article's historical details were not added to the approved interpretation. The link was supplied as a photo credit; it is not presented as substantiating every historical statement.

Historical bibliographic citations for the Royal House meaning, 1840, Alcalde Mayor, administration, judicial functions and current museum role were not present in the repository or supplied in the follow-up. Sources explicitly marks these citations as pending researcher supply. This must be resolved before final visitor deployment.

## Asset audit

| Asset | Actual repository path | Use |
| --- | --- | --- |
| Researcher façade | `assets/landmarks/casa_real/exterior/cr_ext_01_facade.png` | Unmodified documentary photograph; KEEP_ASPECT_CENTERED; linear sampling local to this photograph |
| Researcher narration | `assets/landmarks/casa_real/audio/cr_ext_01_narration.ogg` | Imported AudioStreamOggVorbis, non-looping |
| Existing speaker | `assets/ui/icons/speaker.svg` | Shared header Listen/Stop control |
| Shared shell | `scenes/components/conference_room_interaction.tscn` | Header controls, illustration, theme, Sources overlay, audio player |
| Shared behavior | `scripts/components/conference_room_interaction.gd` | Narration, close/open signals, Escape handling, focus restoration, Sources close |
| Shared Resource types | `scripts/components/conference_room_content.gd`, `scripts/components/conference_room_concept_entry.gd` | Historical content and media |

Both source media files existed before implementation and their SHA-256 hashes were preserved. Godot generated their new `.import` sidecars. No substitute or generated media was used.

## Interaction and lifecycle

- `current_state: IdentityState` is authoritative. The inherited shell's legacy `_selected` storage is unused by Casa Real selection, rendering, getters or Sources.
- Mouse, native GUI touch and keyboard activation converge on `select_state()`. It rejects invalid states and selection while Sources is open or the hotspot is closed.
- The selected card uses the shared muted gold fill. Keyboard focus uses the shared bright outline without changing the selected identity. All cards are fully tappable.
- A new selection kills the prior Tween, updates selection, fades outgoing interpretation for 130 ms, reads the current Resource entry, then fades in for 180 ms. No queued transitions, cumulative movement, or stale captured state.
- Opening reveals the main panel over 220 ms and photo from 150–450 ms. Interaction remains available throughout. No looping animation.
- Toolbar order is always **SOURCES | LISTEN | CLOSE**. LISTEN becomes STOP during playback and remains immediately left of CLOSE.
- Narration never autoplays. Identity selection neither restarts it nor seeks. Shared Listen starts at zero; Stop and Close stop it. Reopen resets playback and paused state.
- Sources uses the original opaque, parent-filling overlay with local scrolling and focus containment. It preserves the identity, blocks underlying selectors, and resets its scroll on open. Escape closes Sources first, then the hotspot on a second press. The inherited navigation handler consumes input before closing/emitting.
- The unchanged shared `opened` and `closed` signals form the host contract. There is no navigation to a master layout.
- Reopen resets to Royal House, hides Sources, stops audio at zero, cancels animations and restores opacity and default focus. External host hiding also closes and cleans up. Node removal cancels active animations/audio.

## Responsive behavior

| Resolution | Layout and visual result |
| --- | --- |
| 1280×720 | Passed native runtime and screenshot inspection for all states. Two columns, 59% photo region / 41% interpretation region; three 60 px vertical selectors. 22 px body text. |
| 960×540 | Passed native runtime and screenshot inspection for all states. Horizontal 56 px selectors above the same two columns; 18 px body text; reduced margins/spacing. |
| 854×480 | Passed native runtime and screenshot inspection for all states. Same compact landscape layout. Full GOVERNMENT CENTER label fits. No body clipping, overlap or whole-screen scrolling. |

Header and Sources Close targets are at least 56 px high. The complete photograph fits inside its region with natural letterboxing; the photo is never cropped or distorted. The main interpretation displays only the current key, heading and body. The takeaway remains below the columns.

The preview sets its own runtime canvas sizing so resizing tests real logical layouts instead of merely shrinking a 1280×720 canvas. This setting is restored when the preview leaves the tree; `project.godot` is unchanged. Production instances follow their host's canvas policy.

Portrait is unsupported and no special portrait UI was added. Inspection found no existing global “Please rotate your device to landscape.” behavior in the current repository. That is an outstanding global integration dependency outside this standalone change. Returning from portrait dimensions to landscape is covered by the runtime test.

## Automated verification

`tests/cr_ext_01_test.gd` instantiates the real F6 preview and production component. GUI pointer/key events are injected through `Input.parse_input_event`; touch checks use `InputEventScreenTouch` with the project's existing default behavior, without changing project settings or enabling emulation in the test.

Verified at all three target sizes:

- Exact default content, no autoplay, no open Sources.
- All six directed state transitions, repeated selection, invalid requests and rapid interrupted transitions.
- Every selector and toolbar control with mouse and synthetic touch, including alternating/repeated taps.
- Tab/Shift+Tab order: Royal, Government, Banáan, Sources, Listen, Close; Enter/Space activation; arrows move focus only.
- Sources shielding, local focus containment, mouse/touch dismissal and Escape hierarchy.
- Correct façade/audio/icon resources; actual imported narration duration and playback state; uninterrupted narration position during selection.
- Reopen/reset, Close during selection/reveal, absence of stale Tweens/opacity and exactly one close signal per close.
- Text bounds, touch target dimensions, photo-region ratio, header order and separate focus/selection style resources.
- Additional host-hide cleanup and landscape recovery after portrait sizing.

Initial test identified stale relative keyboard focus paths after selector reparenting on resize. The local responsive method now rebuilds the focus paths; the corrected rendered run passed.

| Check | Result |
| --- | --- |
| Native Compatibility rendered CR-EXT-01 suite | 1,519 checks, zero failures; all nine state screenshots inspected, plus Sources |
| Final extended headless CR-EXT-01 suite | 1,568 checks, zero failures, exit 0; includes landscape recovery and original Urduja shared-shell consumer; no resource/ObjectDB leak diagnostics |
| Godot editor import / script and scene load | Passed after directing process-local editor data/cache to Windows TEMP |
| CR-EXT-01 F6 preview headless startup | Passed |
| Existing LCH-EXT-01 suite | Zero failures at all three sizes |
| Existing LC-EXT-01 suite | Zero failures at all three sizes |
| Original UH-INT-04 shared shell | Open, three concepts, Sources, narration and Close checked in extended suite |
| Git whitespace and baseline preservation | `git diff --check` exit 0; new-file whitespace checks clean; all seven baseline files unchanged; index remains empty |

Native rendering used OpenGL 3.3 Compatibility on Intel UHD Graphics. No browser-export or physical touch-device test is claimed. Playback state and position were checked using the real Ogg asset; human listening/transcript verification remains part of researcher review.

The sandbox logs `Failed to read the root certificate store` for both new and unchanged suites. Initial runs also reported unwritable default user/editor cache paths; subsequent import and headless checks used process-local APPDATA/LOCALAPPDATA in TEMP. No global environment or project configuration was modified.

## Reproduce and manually review in Godot

Installed executable: `C:/Users/Admin/OneDrive/Documents/Godot Files/Godot_v4.7.2-stable_win64_console.exe`.

From the repository in PowerShell:

```powershell
$godotExe = 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe'
& $godotExe --headless --editor --path . --import --quit
& $godotExe --headless --path . --script res://tests/cr_ext_01_test.gd
& $godotExe --path . --rendering-method gl_compatibility --script res://tests/cr_ext_01_test.gd -- --capture
& $godotExe --headless --path . --script res://tests/lch_ext_01_test.gd
& $godotExe --headless --path . --script res://tests/lc_ext_01_test.gd
git diff --check
git status --short
```

Screenshots: `%TEMP%/akar_cr_ext_01_<width>x<height>_state<0–2>.png` and corresponding `_sources.png`. Logs from implementation use `%TEMP%/akar_cr_ext_01_*.log` and `%TEMP%/akar_cr_regression_*.log`.

1. Open `scenes/landmarks/casa_real/exterior/cr_ext_01_preview.tscn` and press **F6**. The actual hotspot opens in Royal House. After Close, use the preview's Open button to reopen.
2. Resize the detached preview to 1280×720, 960×540 and 854×480. Inspect each state for readable wording, clean wrapping, natural photo aspect and usable controls. Confirm the full Government Center label and immediate Listen/Close adjacency.
3. Click and tap all three cards in any order, repeat the selected card and alternate rapidly. Finish on Banáan; confirm correct text, selection and full opacity.
4. Tab and Shift+Tab through the six controls; use arrows on cards without activation, then Enter/Space. Confirm focus outline differs from gold selection.
5. Play and listen to the supplied narration. Change identities while it plays; verify uninterrupted audio. Stop, restart, Close during playback, and reopen; verify no autoplay or retained position.
6. Open Sources from Government or Banáan. Scroll to the complete photo URL, attempt taps beneath the overlay, and use Escape. Confirm the previous identity remains selected. A second Escape closes the hotspot.
7. Close while a selection or initial reveal is fading; reopen immediately. Confirm Royal House, full opacity and no stale overlays or audio.
8. Repeat on the museum tablet and exported Web build. Check touchscreen operation, browser audio after an explicit Listen gesture, and orientation handling once the global rotation guard is integrated. These deployment checks remain pending.

## Historical boundary

Exact approved text includes 1840, Royal House, Alcalde Mayor, provincial administrative and judicial functions, and Banáan Pangasinan Provincial Museum. No new historical facts were inferred. Production Casa Real files were scanned for prohibited later material: no 1898 attack, Katipuneros, Taft Commission, Capitol-transfer dates, WWII, Japanese occupation, Typhoon Cosme, 2015 restoration, Georgian explanation, architecture markers, personalities or gallery directory. No game mechanics, analytics, accounts or CMS were introduced.

## Repository preservation and outstanding items

Before implementation: no staged files; `project.godot` had existing unstaged serialization edits. The façade/audio and four files under `docs/references/lingayen_church/` (two images and their import sidecars) were untracked. Their paths and SHA-256 hashes were recorded in `%TEMP%/akar_cr_ext_01_baseline.json`.

Only new CR-EXT-01 scene/script/Resource/test/document files and relevant Godot-generated `.uid`/asset `.import` sidecars were added. No shared component was modified. All original file hashes and the empty index are checked at completion. `git diff --check` is run along with whitespace checks of new, untracked text files; nothing is staged.

Final validation: all seven original file hashes match, including the pre-existing `project.godot` edits, both Casa Real assets and the four unrelated reference files. No tracked file was modified by this implementation. The only tracked status entry remains the user's original ` M project.godot`; new CR-EXT-01 work and the original assets/references remain untracked. No commit or push was performed.

Outstanding before final visitor deployment:

- Researcher-supplied historical bibliographic citations; current Sources marks them pending.
- Researcher F6 visual review and human narration listening review.
- Exported browser and physical museum tablet/phone checks.
- The global landscape rotation prompt is absent from this repository and needs separate integration.

Stop after CR-EXT-01. No milestone commit is authorized until the researcher explicitly approves it.
