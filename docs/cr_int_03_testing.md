# CR-INT-03 — People Behind Casa Real

Standalone Phase 5 implementation, 2026-09-28. This educational portrait network introduces five people through their approved Casa Real connections. It does not implement biographies, completion tracking, another hotspot, or master-layout navigation.

## Production and F6

- Production: `res://scenes/landmarks/casa_real/interior/cr_int_03.tscn`.
- F6: `res://scenes/landmarks/casa_real/interior/cr_int_03_preview.tscn`.
- The preview instantiates the production scene and supplies only standalone window sizing and a reopen button. It temporarily disables reference-canvas scaling for real resolution checks and restores the previous window setting on exit; it does not modify `project.godot`.
- The component extends `ConferenceRoomInteraction`, reusing its shell, Sources panel, audio player, close/focus-return convention, and signals. All new behavior lives in CR-INT-03 files.
- Resource content: `data/landmarks/casa_real/cr_int_03.tres`, backed by the content and personality Resources. The connection layer only draws supplied local-coordinate geometry.

## Interaction contract

`OVERVIEW` is the fresh state: five documentary portrait mounts, three period markers, and the central Casa Real anchor. Muted lines show relationships; no line is highlighted until selection. The initial keyboard focus outline is distinct from the filled selected period style.

`select_period()` clears personality selection and remains in Overview. Matching portraits retain full opacity; the others remain selectable at 0.65 opacity. No person opens automatically. `select_person()` is the sole authoritative person-selection entry point and synchronizes the period, media, approved copy, source, highlight, and connection. Invalid IDs/indices are ignored.

`PERSON_FOCUS` shows a portrait/context visual and historical interpretation. The visual occupies approximately 38% of the available columns at 1280×720 and 34% at compact sizes. The portrait rail shows all five at the reference size and about three at compact sizes. Scroll or swipe it to reach the remaining people. Full period labels remain in the interpretation, accessibility names, and period tooltips when compact controls show 1901 / RESTORATION / 2023.

The context toggle crossfades over 200 ms and changes its label to RETURN TO PORTRAIT. It preserves the person, period, and audio position. Selecting another person always returns to portrait mode. Person changes cancel the previous transition and fade details over 200 ms; the latest input wins. The selected rail portrait connects to its period and then to Casa Real. Geometry is recalculated after layout and horizontal scrolling.

VIEW ALL CONNECTIONS clears the person and period and returns to the complete overview without restarting narration. There are no Previous/Next Person buttons. At compact sizes, the contribution panel scrolls locally while all essential controls remain visible. Portrait and context images preserve their aspect ratios without cropping or modification.

## Personality and asset mappings

Portrait root: `assets/landmarks/casa_real/interior/people/portraits/`.

| ID | Name | Period ID | Date/period cue | Portrait |
| --- | --- | --- | --- | --- |
| P01_TAFT | William Howard Taft | PERIOD_CIVIL_GOVERNMENT | 1901 | cr_int_03_p01_taft.png |
| P02_SISON | Perfecto Sison | PERIOD_CIVIL_GOVERNMENT | 1901 | cr_int_03_p02_sison.jpg |
| P03_ESPINO_JR | Amado T. Espino Jr. | PERIOD_RESTORATION | RESTORATION INITIATIVE | cr_int_03_p03_espino_jr.png |
| P04_ESPINO_III | Amado I. Espino III | PERIOD_RESTORATION | 2021 | cr_int_03_p04_espino_iii.png |
| P05_GUICO | Ramon V. Guico III | PERIOD_BANAAN | 2023 | cr_int_03_p05_guico.png |

Period labels: CIVIL GOVERNMENT; RESTORATION & PRESERVATION; BANÁAN MUSEUM. Espino Jr. has no forced 2015 or 2016 badge. Full names, roles, and contributions reproduce the researcher-approved Phase 5 copy. Tests compare the five contributions against that exact supplied wording.

## Reused context images and provenance

All context paths are existing CR-EXT-03 files under `assets/landmarks/casa_real/exterior/changing_roles/`. No media was duplicated, downloaded, generated, restored, or altered.

| People | Existing file | Visitor caption | Inherited source |
| --- | --- | --- | --- |
| Taft, Sison | cr_ext_03_government_center.jpg.jpg | EARLY CASA REAL · BUILDING CONTEXT | Arabela Ventenilla Arcinue, *Lingayen: Memories of Times Past* (2021), p. 99 |
| Espino Jr. | cr_ext_03_cosme_damage.JPG | CASA REAL · RESTORATION CONTEXT | NHCP, National Registry of Historic Sites and Structures, Casa Real ng Lingayen |
| Espino III | cr_ext_03_heritage_museum.jpg | RESTORED CASA REAL · BUILDING CONTEXT | Same NHCP registry attribution recorded in CR-EXT-03 |
| Guico | cr_ext_03_banaan_identity.jpg | BANÁAN PANGASINAN PROVINCIAL MUSEUM | Banáan Pangasinan Provincial Museum official website |

The double `.jpg.jpg` suffix is the actual existing filename. The early photograph visibly bears a 1917–18 annotation: it is building context, not a photograph of the 1901 visit. The restored photograph is not independently verified here as the 2021 turnover; no caption claims that event. The selected person's approved date remains separate from the image caption. The Banáan photograph is likewise used as museum context without identifying a specific ceremony.

Inherited context references:

- NHCP: https://nhcphistoricsites.blogspot.com/2011/10/old-casa-real-and-provincial-capitol.html
- Banáan: https://banaan.seepangasinan.com/

Portrait provenance supplied by the researcher:

| Portrait | Source/reference | Permission status |
| --- | --- | --- |
| Taft | Encyclopaedia Britannica — William Howard Taft biography | Source documented; reuse permission not supplied |
| Sison | Arabela Ventenilla Arcinue — *Lingayen: Memories of Times Past*, p. 63; research-team scanned-book reference | Source documented; reuse permission not supplied |
| Espino Jr. | Inquirer.net | Source documented; reuse permission not supplied |
| Espino III | Philstar / Pilipino Star Ngayon | Source documented; reuse permission not supplied |
| Guico | Ramon Mon-Mon Guico III official Facebook page/post | Source documented; reuse permission not supplied |

Exact portrait URLs, photographers, and licenses were not supplied; those Resource fields are left empty rather than inferred. No news article headlines or unrelated article claims enter the educational content. Existing context metadata does not establish reuse permission, so the new Resource records it as unspecified. These internal permission notes are not prominent visitor text. Full historical claim-to-page citations were not supplied; approved content is attributed to the AKAR Research Team and that research-documentation limitation is retained in the personality Resources.

Sources uses the established single overlay, opened by header SOURCES; the active personality is ordered first. The redundant person-detail SOURCE button has been removed. HISTORICAL CONTENT, PORTRAIT, CASA REAL CONTEXT IMAGE, and NARRATION are distinguished. Sources traps keyboard focus and blocks underlying period/person/context/overview actions while preserving narration and selection.

The remaining context action is centered in the detail action area, retaining its measured pre-removal size: 566×52 px at 1280×720, 465×52 px at 960×540, and 397×52 px at 854×480. Integer layout margins place its center within half a pixel of the area's center. Tab moves from this action through the five portraits, then VIEW ALL CONNECTIONS and the remaining controls. Its portrait/context behavior is unchanged.

## Narration

`res://assets/landmarks/casa_real/audio/cr_int_03_narration.ogg` is the supplied, project-owned AKAR Research Team track. It is loaded and played by Godot, not replaced with a placeholder. No autoplay. LISTEN starts it, PAUSE pauses it, and RESUME continues it. Period/person/context/Sources/View All interactions never restart it. Closing or resetting stops it, clears pause state, and restores LISTEN.

Approved transcript: “Casa Real's history was shaped by personalities connected with civil government, restoration, and museum development. Their contributions reflect the building's transformation from a colonial government center into a preserved cultural institution.”

## Reset and navigation

Fresh open/reopen: `OVERVIEW`, person `-1`, empty period, `PORTRAIT`, all portraits normal, no selected period, no highlighted connection, Sources hidden, audio stopped, rail offset zero, no transition, and no retained context texture. CLOSE cancels input gestures/tweens, resets state, and emits the normal `closed` signal plus `close_requested` for future host use. The preview exposes REOPEN CR-INT-03 after closing.

Escape: close Sources first; otherwise return Person Focus (including context mode) to Overview; otherwise close the hotspot. Navigation input is marked handled before a close signal can remove the component. Hiding the component also closes it and stops audio.

## Automated verification

`tests/cr_int_03_test.gd` loads the actual F6 preview and its production component. Tests use native Godot mouse, touch, drag, and keyboard events, plus direct calls for invalid input and rapid-state tests. They verify:

- Initial overview and all period emphasis mappings without automatic personality opening.
- All five exact names/dates/contributions and portrait/context resource paths.
- Both context-toggle directions and cross-period selection while context mode is active.
- Rapid Taft → Sison → Espino Jr. → Espino III → Guico, and Civil → Restoration → Banáan → Civil.
- Shared Sources access by mouse and touch, source ordering, underlying-state blocking, Tab focus containment, touch scrolling, and Escape priority.
- Actual audio start, continuing playback position, pause/resume, no restart on exploration, stop/reset on close.
- View All, close signals, reopen button, Escape close, and complete reset.
- Rail swipe/drag without accidental selection; bounded Left/Right focus and Enter/Space activation.
- Touch targets, centered inset, visible essential controls, column proportions, connection bounds, no period overlap, no date wrapping, and contribution access through the final line.
- 1280×720, 960×540, and 854×480, including rendered overview, period emphasis, each portrait/context, Sources, and scrolled interpretation captures.

Final validation on Godot 4.7.2:

| Validation | Result |
| --- | --- |
| CR-INT-03 headless | 3,853 checks, 0 failures |
| CR-INT-03 rendered, Compatibility / Intel UHD Graphics | 3,901 checks, 0 failures; 48 captures |
| CR-EXT-01 regression | 1,983 checks, 0 failures |
| CR-EXT-02 regression | 1,897 checks, 0 failures |
| CR-EXT-03 regression | 5,431 checks, 0 failures |
| CR-INT-01 regression | 2,287 checks, 0 failures |
| CR-INT-02 regression, including real video playback | 5,232 checks, 0 failures |
| Editor import/reload and six explicit script check-only runs | No GDScript compile/parse/reload errors |
| Media/resource loading | No missing or failed resources |
| Direct standalone preview scene launch | Successful rendered launch and clean exit |
| Rendered sizes | 1280×720, 960×540, 854×480 passed; representative captures visually inspected |
| Focused resize | Selected at 1280×720, then 960×540 → 854×480 → 960×540 → 1280×720; person, context, period, visible selected rail portrait, connection, readable contribution, and usable mouse/touch controls preserved throughout |
| `git diff --check` | Passed |
| New-file whitespace checks | All 22 CR-INT-03 text/metadata files passed `git diff --no-index --check` |
| Pre-existing file preservation | SHA-256 audit: all 600 recorded files unchanged |

The 600-file audit includes all earlier hotspots and tests, the researcher's modified `project.godot`, untracked reference documents, and the supplied CR-INT-03 media. Only CR-INT-03 implementation files and Godot-generated UID/import metadata were added. Nothing was staged, committed, or pushed.

Redundant SOURCE button revision: the current CR-INT-03 totals above include exact pre-revision context-button dimensions, centered placement, removal of the lower control, and context → portrait rail → VIEW ALL CONNECTIONS Tab order. Header SOURCES passes both touch and mouse checks. The direct production preview launched successfully after the edit, and captures at all three sizes were visually inspected. Regression rows retain the earlier recorded results; this revision changes only the CR-INT-03 controller, its test, and this document.

Continuation scope: the existing implementation and scenes were retained. Only `tests/cr_int_03_test.gd` and this document changed during the continuation: the resize sequence now explicitly covers both directions, verifies synchronized selection/media/connection state, reaches the last contribution line, and activates the context controls with mouse and touch after each resize. The final suite and direct rendered preview were rerun after that test edit.

The continuation regression run of CR-EXT-02 passed all 1,897 assertions but reported four ObjectDB instances and two resources still in use during exit cleanup. An unchanged verbose rerun passed all 1,897 assertions with no such cleanup diagnostic. No earlier hotspot or test was edited. This was not a script compilation or resource-loading failure.

Rendered captures and logs are written under `%TEMP%` with the `akar_cr_int_03_` prefix, not into production assets. Examples: `akar_cr_int_03_1280_overview.png`, `akar_cr_int_03_960_person0.png`, `akar_cr_int_03_854_context4.png`, and `akar_cr_int_03_854_contribution_scrolled.png`. Actual researcher F6 keypress review, audible-device review, and physical touchscreen acceptance remain pending.

### Commands

Run from the repository using the installed Godot 4.7.2 console executable:

```powershell
$godot = 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = Join-Path $env:TEMP 'akar_cr_int_03_runtime\roaming'
$env:LOCALAPPDATA = Join-Path $env:TEMP 'akar_cr_int_03_runtime\local'
& $godot --headless --editor --path . --import --quit
& $godot --headless --path . --script res://tests/cr_int_03_test.gd
& $godot --path . --rendering-method gl_compatibility --script res://tests/cr_int_03_test.gd -- --capture
& $godot --path . res://scenes/landmarks/casa_real/interior/cr_int_03_preview.tscn --quit-after 120
foreach ($id in @('cr_ext_01', 'cr_ext_02', 'cr_ext_03', 'cr_int_01', 'cr_int_02')) {
    & $godot --headless --path . --script "res://tests/${id}_test.gd"
}
git diff --check
git status --short
```

The isolated temporary application-data directory avoids using or changing the researcher's normal Godot user data. This environment reports `Failed to read the root certificate store` at startup; it is distinct from script/resource failures. No network access is needed by this component.

## Researcher F6 matrix

Open `cr_int_03_preview.tscn` in Godot 4.7.2 and press F6. Repeat at each requested landscape size.

1. Confirm the complete network opens with no selected person and no narration autoplay.
2. Select Civil Government, Restoration & Preservation, and Banáan Museum. Confirm respectively Taft/Sison, both Espinos, and Guico are emphasized; other portraits remain usable.
3. Select each person and verify the supplied portrait, full name, role, date/period, and contribution. Espino Jr. must say RESTORATION INITIATIVE. Scroll the interpretation locally at compact sizes.
4. For every person, choose VIEW CASA REAL CONNECTION and RETURN TO PORTRAIT. Check the context mapping and that the person/period remain unchanged.
5. While viewing Taft's context, select Espino III directly. Confirm his portrait, 2021 content, restoration period, and updated connection.
6. Swipe and mouse-drag the compact rail. Dragging must not select; tapping must select. Use Left/Right to move focus without selecting, then Enter/Space to activate. Check both end bounds.
7. Open header SOURCES; read/scroll the credits. Underlying controls must be blocked. Tab remains inside Sources; Escape closes it before changing the selected person. Confirm there is no lower SOURCE button and the context action remains centered at its previous size.
8. Start narration, switch people, toggle context, open Sources, and use View All. Confirm audio continues without restarting. Check PAUSE/RESUME and audible playback quality on the researcher's device.
9. Switch people and periods rapidly. Confirm only the final input is shown, without stale images or delayed selection.
10. Check Escape from context → Overview → close. Reopen and confirm every reset condition. Close directly while narration is playing and confirm silence.

Automated rendered/native-input verification does not replace physical touchscreen, browser-export, or researcher F6 acceptance. No browser deployment was requested. Stop after standalone review; no commit, push, CR-INT-04, or master layout is part of this milestone.
