# CR-EXT-03 — Casa Real Through Changing Roles

## Purpose and scope

Educational question: How did Casa Real's public role change over time?

This standalone Phase 5 hotspot explains one building's changing public purposes. The approved simplification groups the chronology into three chapters rather than five roles plus separate event buttons. It supports self-paced museum visits without scores, completion requirements, or claims of improved learning effectiveness. CR-ENT-01, CR-INT-01 and the Casa Real master layout are outside this milestone.

## Implementation and lifecycle

- Production: `scenes/landmarks/casa_real/exterior/cr_ext_03.tscn`.
- F6 preview: `scenes/landmarks/casa_real/exterior/cr_ext_03_preview.tscn`; instantiates the real production scene and restores the host canvas setting when it exits.
- Controller: `scripts/landmarks/casa_real/cr_ext_03.gd`.
- Historical data: `data/landmarks/casa_real/cr_ext_03.tres`.
- Three small Resource scripts: `cr_ext_03_content.gd`, `cr_ext_03_role.gd`, `cr_ext_03_photo.gd`.
- Reuses `scenes/components/conference_room_interaction.tscn`, its controller, content and concept Resources. Existing `opened`/`closed` signals are the repository's lifecycle convention; no hardcoded navigation or new autoload.
- No existing shared, CR-EXT-01, CR-EXT-02, or project configuration files are edited.

Authoritative states: OVERVIEW, GOVERNMENT_CENTER, PUBLIC_SERVICE, HERITAGE_MUSEUM. Every role activation goes through `select_role()`; every photo change goes through `show_photo()`. Role changes reset the photo index to zero, including repeated same-role activation. Milestones are labels with no input or focus.

Role fades last 350 ms (140 out / 210 in), photo fades 280 ms (120 out / 160 in); the opening reveal completes in 450 ms. Both active transitions are cancelled before replacement. Photo input during a role fade settles the current role before changing its photo, preventing callbacks from an older role restoring stale content.

Reset cancels transitions and opening reveal, restores opacity/scale, closes Sources, stops and unpauses audio, clears its playback position, restores Overview/photo zero, hides milestones and photo counter, clears selected role styling, resets reading scroll, and focuses the first role. Close cancels animations before the inherited lifecycle stops audio and emits `closed`. Escape is marked handled before dismissal; Sources closes first.

## Exact visitor copy

Title: CASA REAL THROUGH CHANGING ROLES

Subtitle: One historic building, different public purposes

### Overview

Heading: ONE BUILDING, CHANGING ROLES

Prompt: HOW DID CASA REAL'S ROLE CHANGE?

Body: Casa Real has served Pangasinan in different ways across generations. Select a period to see how its public role changed.

No historical role selected. Milestone strip hidden. One façade image; photo cycling inactive.

### Government

Period: 1840–1918

Selector: 1840–1918 / GOVERNMENT. Compact selector: 1840–18.

Heading: PROVINCIAL GOVERNMENT CENTER

Tagline: GOVERNMENT · ADMINISTRATION · JUDICIARY

Body: Constructed in 1840, Casa Real served as Pangasinan's provincial government center, housing the residence and office of the Alcalde Mayor and supporting administrative and judicial functions.

| Date | Informational milestone |
| --- | --- |
| 1840 | CONSTRUCTED / GOVERNMENT CENTER |
| 1898 | REVOLUTIONARY ATTACK |
| 1901 | TAFT COMMISSION RECEPTION |
| 1918 | END AS PRINCIPAL PROVINCIAL CAPITOL |

### Public

Period: 1919–1996

Selector: 1919–1996 / PUBLIC SERVICE. Compact selector: 1919–96.

Heading: CONTINUED PUBLIC SERVICE

Tagline: SCHOOL · COURTHOUSE · GOVERNMENT USE

Body: After the new Pangasinan Provincial Capitol opened in 1919, Casa Real continued serving the public in different ways. It was used as a school, courthouse, and government office, including wartime office use before returning to court functions after the war.

| Date | Informational milestone |
| --- | --- |
| 1919 | CHANGING PUBLIC USES |
| 1942–1945 | WARTIME OFFICE |
| POSTWAR–1996 | COURT USE |

### Heritage

Period: 2002–PRESENT

Selector: 2002–NOW / HERITAGE & MUSEUM. Compact selector: 2002–NOW.

Heading: HERITAGE & MUSEUM

Tagline: RECOGNITION · PRESERVATION · EDUCATION

Body: Casa Real entered a new chapter centered on heritage preservation. After historical recognition, typhoon damage, and restoration, the building formally opened in 2023 as the Banáan Pangasinan Provincial Museum.

| Date | Informational milestone |
| --- | --- |
| 2002 | NATIONAL HISTORICAL LANDMARK |
| 2008 | TYPHOON COSME DAMAGE |
| 2015 | RESTORATION BEGAN |
| 2021 | FORMAL TURNOVER |
| 2023 | BANÁAN MUSEUM |

## Media audit, attribution, and permission

These are the actual filenames, including the double `.jpg.jpg` government extension and uppercase Cosme `.JPG`. All images are displayed at preserved aspect ratio with contain framing and local linear filtering. No editing, restoration, cropping, redraw, fabricated content or generative media was performed.

| Photo / order | Actual repository path | Caption | Researcher-supplied attribution |
| --- | --- | --- | --- |
| facade | `assets/landmarks/casa_real/exterior/cr_ext_01_facade.png` | Casa Real — Full Façade | Province of Pangasinan — Official Website<br>LGU-P’sinan inaugurates Banaan Pangasinan Provincial Museum on Sept. 8<br>https://www.pangasinan.gov.ph/lgu-psinan-inaugurates-banaan-pangasinan-provincial-museum-on-sept-8/ |
| government | `assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_government_center.jpg.jpg` | Provincial Government Center | Arabela Ventenilla Arcinue. Lingayen: Memories of Times Past. Quezon City: Studio Graphics Corporation, 2021. p. 99. |
| public | `assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_public_service.jpg` | Continued Public Service | Arabela Ventenilla Arcinue. Lingayen: Memories of Times Past. Quezon City: Studio Graphics Corporation, 2021. p. 97. |
| secondary | `assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_public_service_secondary.jpg` | Continued Public Service — Additional View | Arabela Ventenilla Arcinue. Lingayen: Memories of Times Past. Quezon City: Studio Graphics Corporation, 2021. p. 97. |
| marker | `assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_historical_marker.jpg` | National Historical Landmark Recognition | National Historical Commission of the Philippines — National Registry of Historic Sites and Structures, Casa Real ng Lingayen<br>https://nhcphistoricsites.blogspot.com/2011/10/old-casa-real-and-provincial-capitol.html |
| cosme | `assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_cosme_damage.JPG` | Typhoon Cosme Damage — 2008 | National Historical Commission of the Philippines — National Registry of Historic Sites and Structures, Casa Real ng Lingayen<br>https://nhcphistoricsites.blogspot.com/2011/10/old-casa-real-and-provincial-capitol.html |
| restored | `assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_heritage_museum.jpg` | Restored Casa Real | National Historical Commission of the Philippines — National Registry of Historic Sites and Structures, Casa Real ng Lingayen<br>https://nhcphistoricsites.blogspot.com/2011/10/old-casa-real-and-provincial-capitol.html |
| banaan | `assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_banaan_identity.jpg` | Banáan Pangasinan Provincial Museum | Banáan Pangasinan Provincial Museum official website<br>https://banaan.seepangasinan.com/ |

**Permission / license for every listed photo: Unspecified / pending documentation.** No photographer or NHCP Photo Collection attribution was inferred. No separate permission or more complete scan-credit record was found in the repository. Attribution is not reuse authorization.

The untracked `docs/references/` scans were preserved. Their presence does not establish a reuse license. Narration is the researcher-supplied `assets/landmarks/casa_real/audio/cr_ext_03_narration.ogg`; no TTS was used. The existing speaker icon is `assets/ui/icons/speaker.svg`.

Historical wording and dates are researcher-approved in the supplied Phase 5 request. The request maps documentary sources to images, but supplies no complete claim-to-page historical citation mapping. Sources therefore keeps historical content and documentary credits separate and explicitly marks the claim citations pending. The NHCP URL returned HTTP 429 during the optional online check; the supplied credit is retained without pretending the page was verified. The official Banáan page was accessible. No additional web-derived historical wording was added.

## Narration transcript

Casa Real has served Pangasinan in different ways across generations. It began as the province's government and judicial center. After the new Capitol opened, the building continued serving the public as a school, courthouse, and government office, including wartime and postwar government use. Later, preservation efforts gave Casa Real a new role, and in 2023 it opened as the Banáan Pangasinan Provincial Museum.

Listen starts the actual imported Ogg file, Pause retains position, and Resume continues. No autoplay, seeking, or restart occurs on role/photo/Overview selection or opening Sources. Closing, resetting and reopening clear narration state.

## Input and responsive behavior

The three role buttons form the bottom ribbon. Overview is a subdued contextual control beside the photo caption. The photo frame advances on click/tap, wraps continuously, and exposes a noninteractive counter and persistent helper when multiple photos exist. Government and Overview each have one image and cannot cycle. Public Service has two; Heritage has marker → Cosme → restored → Banáan → marker. No previous/next buttons, thumbnail controls, milestone buttons or event panels exist.

Keyboard order: Government → Public Service → Heritage → Overview → photo frame (multi-photo only) → interpretation scroll → Sources → Listen → Close. Shift+Tab reverses. Left/Right on role controls moves focus without selecting. Enter/Space selects. On the photo frame, Enter/Space/Right advances and Left goes back. The interpretation pane supports Up/Down, Page Up/Down, Home/End. Its focus outline and the photo focus outline differ from the filled selected role. Sources traps focus in its reading area and Close Sources control. Escape dismisses Sources before the hotspot.

Sources preserves the active role/photo/selection/milestones/narration. It consumes background pointer input; method guards also reject background actions. A compact modal's Close Sources button may occupy the background ribbon's coordinates: a click at that location correctly closes the modal rather than activating the hidden ribbon.

Mouse wheel uses Godot's local ScrollContainer. A local native-touch handler applies and consumes drag motion in both interpretation and Sources, independently of desktop mouse emulation; keyboard scrolling works in both panes. The reading pane has a visible scroll hint when text exceeds available height. Only this pane scrolls; the image, caption, toolbar, milestones and role ribbon remain on screen. The photo occupies approximately 64% of the two-column story width.

| Viewport | Layout |
| --- | --- |
| 1280×720 | Centered 1152×648 panel (90%); full date/name role buttons; horizontal milestone dates and descriptions; 20 px body text. |
| 960×540 | Centered 96% inset; full two-line role controls; condensed milestone dates; 18 px body; subtitle on its own row. |
| 854×480 | Centered 96% inset; compact date role buttons, full selected heading in the interpretation pane; condensed milestone dates; 18 px body; useful contain-framed photograph. |

Toolbar order stays SOURCES / LISTEN / CLOSE. Primary controls are at least 56 px tall. The root remains a host-sized dimmed overlay. The production component follows the host's canvas policy; only the standalone preview disables fixed canvas sizing for real viewport checks. No portrait redesign or global settings changes were made.

## Automated validation

Validation completed on 2026-09-26 using Godot 4.7.2:

| Check | Result |
| --- | --- |
| Import / script / scene parsing | Passed; real scenes and Resources loaded without script or scene errors. |
| CR-EXT-03 headless | 5,431 checks, zero failures. |
| CR-EXT-03 rendered | 5,470 checks, zero failures; OpenGL Compatibility on Intel UHD Graphics; 39 captures. |
| 1280×720 | Passed interaction and bounds checks; representative rendered views inspected. |
| 960×540 | Passed interaction and bounds checks; representative rendered views inspected. |
| 854×480 | Passed interaction and bounds checks; representative rendered views and final Sources credit inspected. |
| Mouse / injected touch / keyboard | Passed, including native touch dragging in interpretation and Sources. |
| Role / photo / rapid-input matrix | Passed, including one-image no-op and photo wrapping. |
| Narration / Sources / reset / reopen | Passed. Audio mixer given time to release the stopped stream before test shutdown. |
| CR-EXT-01 regression | 1,983 checks, zero failures. |
| CR-EXT-02 regression | 1,897 checks, zero failures. |
| Existing files | All 482 baseline file hashes unchanged; no shared-code edits. |
| Whitespace | `git diff --check` and checks of all new CR-EXT-03 text files passed. |

The Windows sandbox emits `Failed to read the root certificate store` at engine startup in all three hotspot suites. It does not prevent import, rendering, audio or these local tests. Final CR-EXT-03 runs have no leaked-object/resource warnings or script errors. Exported browser execution and physical touchscreen behavior remain for researcher device review; native input injection does not establish those results.

The test matrix covers all twelve directed role changes, four repeated activations, all eight documentary images, one-photo no-op, forward/backward wrapping, real mouse/touch/keyboard events, focus-only movement, local reading access, invalid role rejection, rapid mixed role/photo input, Sources preservation/input guards, narration pause/resume/continuity, explicit reset, interrupted transitions, close/reopen, resize retention, host hide cleanup, and bounds/target sizes at all three viewports.

Rendered captures are written to `%TEMP%/akar_cr_ext_03_<size>_role<role>_photo<index>.png`, `%TEMP%/akar_cr_ext_03_<size>_sources<role>.png`, and `%TEMP%/akar_cr_ext_03_<size>_sources_end.png` (39 images). They are temporary verification artifacts, not production assets.

Reproduction in PowerShell (use the local Godot 4.7.2 executable):

```powershell
$godotExe = 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = Join-Path $env:TEMP 'akar_cr_ext_03_runtime\roaming'
$env:LOCALAPPDATA = Join-Path $env:TEMP 'akar_cr_ext_03_runtime\local'
New-Item -ItemType Directory -Force -Path $env:APPDATA,$env:LOCALAPPDATA | Out-Null
& $godotExe --headless --editor --path . --import --quit
& $godotExe --headless --path . --script res://tests/cr_ext_03_test.gd
& $godotExe --path . --rendering-method gl_compatibility --script res://tests/cr_ext_03_test.gd -- --capture
& $godotExe --headless --path . --script res://tests/cr_ext_01_test.gd
& $godotExe --headless --path . --script res://tests/cr_ext_02_test.gd
git diff --check
```

## Required researcher F6 review

1. Open `scenes/landmarks/casa_real/exterior/cr_ext_03_preview.tscn` and press F6. Use an external game window if the editor's embedded preview constrains resizing.
2. Check 1280×720, 960×540 and 854×480 in landscape. Confirm title/subtitle, image, body reading pane, milestone dates, helper, counter and toolbar. Read the lower interpretation by wheel/drag or focused keyboard scrolling.
3. Activate every role with mouse and touch. Check every photo in its specified order and wrap. Confirm milestone dates are informational. Return through Overview.
4. Tab/Shift+Tab through controls; distinguish selected fill from focus outline. Use Left/Right to focus roles, Enter/Space to select, and all four photo keys.
5. Start, pause and resume narration. Change roles/photos, return to Overview and open Sources while listening. Confirm it does not restart. Listen to the actual recording for intelligibility and agreement with the approved transcript.
6. Read all Sources sections, scroll to the current photo credit, close with button and Escape. Verify role/photo retention and background blocking.
7. Alternate role and photo inputs rapidly, then close during a fade. Reopen: Overview/photo zero, no selected role, no Sources, no audio.
8. Repeat in the intended exported Web build on the museum touchscreen/tablet and a landscape phone. Native injected touch events are not a substitute for physical device/browser review.

## Historical scope and remaining documentation

Only the approved public-role chronology is included. There is no bombing claim, casualty number, architecture lesson, gallery/artifact lesson, detailed restoration engineering, combat, before/after slider or game mechanic. The milestone labels do not unlock content or track completion.

Outstanding: researcher F6 visual/listening acceptance; physical touchscreen and exported-browser checks; complete historical claim citations; documented photo reuse permissions. These are recorded limitations, not invented approvals. No commit, staging, push or master-scene integration is part of this milestone.

## Repository safety

Initial state: HEAD `d675c1f`; earlier CR-EXT-01 baseline `6908e43`; nothing staged. Existing changes were `project.godot`, CR-EXT-03 narration/import, the `changing_roles/` images/imports, and `docs/references/`. Their hashes were recorded before implementation. Final preservation result: all 482 original files unchanged. The original `project.godot` diff remains untouched. All 16 newly created implementation/documentation files (including six Godot UID sidecars) are confined to CR-EXT-03. Nothing staged; HEAD unchanged; no commit or push performed.
