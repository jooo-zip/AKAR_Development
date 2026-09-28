# CR-END-01 — Casa Real at a Glance: Phase 5 testing

## Purpose and scope

CR-END-01 provides an optional standalone synthesis of Casa Real's government, architecture, historical change, preservation, and museum roles, followed by one optional reflection. It opens independently of earlier hotspot visits. Its educational objective is to help visitors connect these themes with heritage preservation and public service; this implementation does not claim measured learning effectiveness. AKAR's evaluation remains acceptability-oriented.

Implementation follows the researcher-approved CR-END-01 Phases 1–4 and supplied Phase 5 specification. CR-INT-04 remains deferred; master-layout construction and landmark integration are outside this milestone. There is no completion tracking, quiz, answer field, score, reward, mandatory sequence, or prerequisite.

## Implementation files

- Production: `scenes/landmarks/casa_real/end/cr_end_01.tscn`
- Real-component F6 harness: `scenes/landmarks/casa_real/end/cr_end_01_preview.tscn`
- Controller: `scripts/landmarks/casa_real/cr_end_01.gd`
- Preview controller: `scripts/landmarks/casa_real/cr_end_01_preview.gd`
- Content Resource: `data/landmarks/casa_real/cr_end_01.tres`
- Resource scripts: `scripts/landmarks/casa_real/cr_end_01_content.gd`, `scripts/landmarks/casa_real/cr_end_01_theme.gd`
- Tests: `tests/cr_end_01_test.gd`

The production scene inherits the existing shared conference-room component and Sources presentation. Historical text and media mappings live in Resources. The preview instantiates that scene and adds a reopen control; it does not duplicate the interaction.

## Source basis and pre-implementation media audit

The five visitor interpretations are the exact researcher-supplied synthesis, using the established validated Casa Real material. The documentary paths, credits, and permission status were checked against earlier Casa Real Resources and testing documents before production implementation. No external historical research, new claims, new image files, renamed copies, inferred licenses, or invented provenance were added.

Complete historical claim-to-page citations remain pending researcher documentation, as in the existing source basis. Sources explicitly distinguishes historical content from documentary image credits. The pending citation notice does not alter the locked visitor interpretation.

All five existing textures loaded successfully in Godot. All five retain the existing **Unspecified / pending documentation** reuse-permission status: attribution alone does not establish permission.

### government

- Stable ID: `&"government"`
- Card: GOVERNMENT & / CIVIC LIFE
- Compact card: GOVERNMENT
- Anchor: 1840
- Image: `res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_government_center.jpg.jpg`
- Caption: CASA REAL · c. 1917–1918 / HISTORICAL BUILDING CONTEXT
- Media credit: Arabela Ventenilla Arcinue. Lingayen: Memories of Times Past. Quezon City: Studio Graphics Corporation, 2021. p. 99.
- Permission: Unspecified / pending documentation, inherited from original asset documentation.
- Historical basis: Government & Civic Life: locked researcher-approved CR-END-01 synthesis; established CR-EXT-01 and CR-EXT-03 interpretation.

**FROM ROYAL HOUSE TO GOVERNMENT CENTER**

Casa Real was constructed in 1840 as the residence and office of the Alcalde Mayor and became an important center of provincial administration and judicial activity.

**WHY IT MATTERS**

Casa Real reflects Lingayen's long connection with provincial government and public service.

### architecture

- Stable ID: `&"architecture"`
- Card: HERITAGE / ARCHITECTURE
- Compact card: ARCHITECTURE
- Anchor: None; no architecture date invented.
- Image: `res://assets/landmarks/casa_real/exterior/cr_ext_01_facade.png`
- Caption: CASA REAL — FULL FAÇADE
- Media credit: Province of Pangasinan — Official Website — LGU-P’sinan inaugurates Banaan Pangasinan Provincial Museum on Sept. 8 — https://www.pangasinan.gov.ph/lgu-psinan-inaugurates-banaan-pangasinan-provincial-museum-on-sept-8/
- Permission: Unspecified / pending documentation, inherited from original asset documentation.
- Historical basis: Heritage Architecture: locked researcher-approved CR-END-01 synthesis; established CR-EXT-02 interpretation. Researcher-supplied reference: Benjie Layug / B.L.A.S.T., Casa Real (Lingayen, Pangasinan) — https://benjielayug.com/2023/09/casa-real-lingayen-pangasinan.html

**ARCHITECTURE THAT CARRIES HISTORY**

Casa Real's stone-and-brick masonry, wooden balcony, French doors, ventanillas, and piedra china staircase contribute to its historic architectural character.

**WHY IT MATTERS**

These features help visitors recognize Casa Real as a historic public structure as well as the present home of Banáan Museum.

### history

- Stable ID: `&"history"`
- Card: HISTORICAL / CHANGE
- Compact card: HISTORICAL CHANGE
- Anchor: ACROSS PERIODS
- Image: `res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_historical_marker.jpg`
- Caption: CASA REAL HISTORICAL MARKER
- Media credit: National Historical Commission of the Philippines — National Registry of Historic Sites and Structures, Casa Real ng Lingayen — https://nhcphistoricsites.blogspot.com/2011/10/old-casa-real-and-provincial-capitol.html
- Permission: Unspecified / pending documentation, inherited from original asset documentation.
- Historical basis: Historical Change: locked researcher-approved CR-END-01 synthesis; established CR-EXT-03 interpretation.

**A WITNESS TO CHANGING TIMES**

Casa Real witnessed revolution, political transition, wartime occupation, and changing public functions while remaining connected with Pangasinan's civic history.

**WHY IT MATTERS**

The building connects several periods of Pangasinan history within one surviving historic place.

### preservation

- Stable ID: `&"preservation"`
- Card: PRESERVATION & / RESTORATION
- Compact card: PRESERVATION
- Anchor: 2008 → 2021
- Image: `res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_cosme_damage.JPG`
- Caption: CASA REAL — BEFORE RESTORATION
- Media credit: National Historical Commission of the Philippines — National Registry of Historic Sites and Structures, Casa Real ng Lingayen — https://nhcphistoricsites.blogspot.com/2011/10/old-casa-real-and-provincial-capitol.html
- Permission: Unspecified / pending documentation, inherited from original asset documentation.
- Historical basis: Preservation & Restoration: locked researcher-approved CR-END-01 synthesis; established CR-EXT-03 and CR-INT-01 interpretation.

**PRESERVING CASA REAL**

After years of deterioration and severe damage from Typhoon Cosme in 2008, Casa Real underwent a multi-phase restoration and was formally turned over to the Provincial Government of Pangasinan in 2021.

**WHY IT MATTERS**

Preservation allowed Casa Real's historical and architectural character to remain part of public life.

### museum

- Stable ID: `&"museum"`
- Card: BANÁAN MUSEUM / TODAY
- Compact card: BANÁAN TODAY
- Anchor: 2023
- Image: `res://assets/landmarks/casa_real/exterior/changing_roles/cr_ext_03_banaan_identity.jpg`
- Caption: BANÁAN PANGASINAN PROVINCIAL MUSEUM
- Media credit: Banáan Pangasinan Provincial Museum official website — https://banaan.seepangasinan.com/
- Permission: Unspecified / pending documentation, inherited from original asset documentation.
- Historical basis: Banáan Museum Today: locked researcher-approved CR-END-01 synthesis; established CR-EXT-01, CR-EXT-03, CR-INT-01 and CR-INT-03 interpretation.

**A HISTORIC BUILDING WITH A NEW PUBLIC ROLE**

In 2023, the restored Casa Real formally opened as the Banáan Pangasinan Provincial Museum, continuing the building's public role through heritage preservation and education.

**WHY IT MATTERS**

Casa Real now provides a setting where visitors can encounter different stories of Pangasinan's history and cultural identity.

The Government image is qualified as circa 1917–1918 historical building context. Its 1840 text anchor describes the approved building history, not the photograph. The photograph is not attributed to an 1840, 1898, or 1901 event. Reflection reuses the Museum image directly, with a runtime dark overlay; the underlying asset is unchanged.

## Other exact visitor copy

Title: **CASA REAL AT A GLANCE**

Subtitle: **Key ideas to remember about this historic landmark**

Summary action: **REFLECT ON CASA REAL'S STORY**

Reflection eyebrow: **REFLECTION**

Reflection heading: **CASA REAL: A PLACE THAT CONTINUES TO SERVE**

Question:

> How can preserving a historic building like Casa Real help communities understand and pass on their heritage?

Supporting prompt:

> Think about how Casa Real changed from a government building into a museum while continuing to serve the public.

Learning takeaway:

> Casa Real shows how a historic place can change in function while continuing to connect people with the history, public life, and cultural heritage of Pangasinan.

Return control: **BACK TO SUMMARY**

Header: **SOURCES**, **LISTEN**, **CLOSE**. The narration control changes to **PAUSE** or **RESUME** according to playback state.

## Narration

Path: `res://assets/landmarks/casa_real/audio/cr_end_01_narration.ogg`

The supplied file and import sidecar existed before this implementation and are preserved. Godot imported and loaded it as an AudioStreamOggVorbis; runtime length is approximately 23.0613 seconds. No other hotspot recording is used.

Researcher-supplied transcript stored in the Resource:

> Casa Real has served Pangasinan across different historical periods. From a provincial government center, it witnessed historical change, changing public functions, deterioration, and restoration. Today, its preserved architecture houses the Banáan Pangasinan Provincial Museum, continuing Casa Real's role as a place for public heritage and education.

Playback never starts automatically. Listen starts, Pause pauses, and Resume continues the same recording. Theme changes, Reflection, Back to Summary, and Sources preserve playback or pause without restarting. Closing stops playback; reopening restores Listen with playback stopped at the beginning. Missing/invalid audio keeps Listen visible but disabled with **Narration pending.** and no substitute audio. The missing-path fallback was exercised without modifying the actual asset.

Sources credits narration to the AKAR Research Team. Automated validation checks resource loading and playback state/position; researcher listening review remains part of F6 acceptance.

## State, selection, Sources, and reset

- `ViewState.SUMMARY` and `ViewState.REFLECTION` are the only content views.
- Default is Summary, Government selected and visible, Sources closed, narration stopped, and local scroll positions at the top.
- All five themes are immediately selectable, with no numbering or completion marks.
- All selection routes through `select_theme(theme_id)`. It cancels the previous tween and synchronizes the selected card, image, caption, anchor, heading, body, and interpretation.
- The image crossfade is 200 ms. Text opacity settles alongside it. Rapid input uses the latest selection; old callbacks cannot restore stale content. There is no zoom, pulse, shake, or transform accumulation.
- Reflection is the same component and preserves the selected theme and narration state. Back to Summary restores that theme.
- One header Sources control opens the shared modal. It contains historical content by theme, five media credits, and audio credit. It preserves Summary/Reflection selection, blocks underlying activation, and traps keyboard focus.
- Escape closes Sources first; otherwise it returns Reflection to Summary; otherwise it closes the hotspot. Input is marked handled before close/navigation signals.
- Close/reopen resets Summary, Government, Sources, image, narration, and scroll positions. The preview's reopen control exercises the real reset contract.

## Responsive and input results

| Size | Theme layout | Content behavior | Result |
| --- | --- | --- | --- |
| 1280×720 | Five cards in one row | Approximately 42% image / 58% detail; all five full theme interpretations fit without detail scrolling | Pass |
| 960×540 | Five cards in one row | Smaller margins; local detail scrolling when needed; body remains 18 px | Pass |
| 854×480 | Three cards plus two | Approved compact labels; local detail/reflection scrolling; fixed header and action controls | Pass |

Theme cards retain at least 64 px height. Other interaction buttons use 52 px height. Documentary images retain their full aspect ratio using centered, uncropped presentation. Reflection uses an aspect-preserving background crop under its dark overlay. The full hotspot is never a long scrolling page.

- **Mouse:** native Godot mouse-button events activate themes, Sources, reflection/back, close/reopen. Pass.
- **Touch:** synthetic native `InputEventScreenTouch` taps and `InputEventScreenDrag` swipes exercise complete cards, Sources, reflection/back, and local reading regions. Emulated mouse events are suppressed to prevent double activation. Pass for injected events; physical tablet/browser touch awaits researcher testing.
- **Keyboard:** Tab and Shift+Tab follow header → theme cards → reflection, with a focusable reading region added for scrolling. Reflection follows header → Back → reading region. Enter/Space activate buttons; Home/End and arrow/Page keys scroll; Escape follows the required hierarchy. Pass.
- **Visual states:** muted-gold selection and a separate bright focus border. No historical information relies on hover.
- **Rapid input:** seven immediate theme selections, invalid ID rejection, and continuous resizing across all three sizes preserve the latest selection and leave no active/stale tween. Pass.
- **Reset:** closing from Summary and Reflection/Sources, including active narration, restores the fresh state on reopen. Pass.
- **Historical safety:** exact locked heading/body/interpretation/anchor/image assertions, circa-1917–1918 caption qualification, no unsupported bombing claim, no added timeline or historical dates. Pass.
- **Non-game checks:** absence of score, reward, progress, achievement, unlock, quiz, congratulation/completion wording and answer fields. Pass.

## Validation results — Godot 4.7.2

| Validation | Checks | Failures |
| --- | ---: | ---: |
| CR-END-01 headless | 3,148 | 0 |
| CR-END-01 rendered, Compatibility / Intel UHD Graphics | 3,175 | 0 |
| CR-EXT-01 regression | 1,983 | 0 |
| CR-EXT-02 regression | 1,897 | 0 |
| CR-EXT-03 regression | 5,431 | 0 |
| CR-INT-01 regression | 2,287 | 0 |
| CR-INT-02 regression | 5,232 | 0 |
| CR-INT-03 regression | 3,853 | 0 |

The rendered suite adds 27 screenshot-save checks: default, five themes, Reflection, scrolled Reflection, and Sources at each required size. Representative default, compact, theme, Reflection, and Sources captures were inspected for text wrapping, image aspect, containment, contrast, and persistent navigation. Screenshots are temporary QA evidence, not project assets.

The F6 preview scene was launched directly in Godot's Compatibility runtime and exited successfully. This is runtime preview validation, not a claim of researcher/editor F6 approval.

Final Godot editor import completed successfully. Separate check-only parses of the controller, content Resource script, theme Resource script, preview controller, and test script all returned exit code 0 with no GDScript warnings or errors.

No CR-END-01 GDScript compile/reload errors, missing-resource errors, invalid node references, texture/audio failures, or implementation warnings occurred in the passing runs. Two initial implementation errors (collision with built-in `Control.theme_changed` and inferred touch-activation type) were corrected before the final passing runs.

The environment emits the previously observed **Failed to read the root certificate store** startup diagnostic. It is separate from CR-END-01 implementation results. The first CR-EXT-02 regression passed all assertions but reported four ObjectDB instances and two resources still in use at process exit. A focused unchanged verbose rerun passed all 1,897 checks with zero failures and no exit-time leak/resource diagnostic. No earlier hotspot was edited to address that diagnostic.

Temporary evidence files:

- `%TEMP%/akar_cr_end_01_asset_audit.log`
- `%TEMP%/akar_cr_end_01_headless_retry.log`
- `%TEMP%/akar_cr_end_01_rendered.log`
- `%TEMP%/akar_cr_end_01_preview.log`
- `%TEMP%/akar_cr_end_01_final_import.log`
- `%TEMP%/akar_cr_end_01_regression_cr_*.log`
- `%TEMP%/akar_cr_end_01_{1280,960,854}_*.png`

### Reproduce automated checks

From the repository root, substitute the installed Godot console executable for `$godot`:

```powershell
& $godot --headless --path . --editor --import --quit
& $godot --headless --path . --check-only --script res://scripts/landmarks/casa_real/cr_end_01.gd
& $godot --headless --path . --script res://tests/cr_end_01_test.gd
& $godot --path . --rendering-method gl_compatibility --script res://tests/cr_end_01_test.gd -- --capture
& $godot --path . res://scenes/landmarks/casa_real/end/cr_end_01_preview.tscn
```

Regression entry points are the unchanged `tests/cr_ext_01_test.gd`, `cr_ext_02_test.gd`, `cr_ext_03_test.gd`, `cr_int_01_test.gd`, `cr_int_02_test.gd`, and `cr_int_03_test.gd`, each run with `--headless --path . --script res://tests/<name>`.

This task used temporary APPDATA/LOCALAPPDATA directories beneath `%TEMP%/akar_cr_end_01_runtime/` for engine output. Project settings were not changed.

## Researcher F6 review

1. Open `scenes/landmarks/casa_real/end/cr_end_01_preview.tscn` in Godot 4.7.2 and press F6. Confirm the real Summary opens with Government already selected and no audio.
2. At 1280×720, select every theme, checking exact copy, image, anchor, caption, gold selection, and separately visible keyboard focus.
3. Switch themes rapidly. Confirm only the latest selection remains and image/text settle without flicker or stale content.
4. Start Listen; pause/resume. Change themes, open Reflection, return, and open/close Sources. Confirm no unexpected restart and review recording clarity.
5. Select Preservation, open Reflection, then Back to Summary. Confirm Preservation remains selected. Read the whole Reflection and its takeaway.
6. Open Sources from both views; read all historical/media/audio sections. Confirm underlying controls cannot activate. Press Escape to close Sources, again to leave Reflection, and again to close Summary.
7. Use the reopen button and confirm Government, top scroll, Sources closed, and audio stopped. Repeat close/reopen during playback.
8. Repeat at 960×540 and 854×480. Confirm five themes remain available, the smaller layout uses 3+2 cards, and local detail/reflection scrolling reaches the last line without hiding navigation.
9. Test mouse, Tab/Shift+Tab, Enter/Space, Escape, and physical touch on the intended tablet/browser. No answer submission, completion requirement, or game feedback should appear.

## Outstanding work and repository safety

Researcher F6 visual/audio acceptance, physical touchscreen validation, and exported-web browser QA remain pending. Historical claim-to-page citation details and inherited documentary reuse permissions remain pending researcher documentation. These are not invented or silently treated as approved.

The SHA-256 baseline audit confirms that all 624 pre-existing tracked/untracked files are unchanged, including all six completed Casa Real hotspots, project.godot, docs/references/, and the supplied narration plus import sidecar. The only 14 newly created files are this milestone's Resource, two scenes, four scripts and their UID sidecars, test and UID sidecar, and this testing document. CR-INT-04 and master-layout files were not created. The index remains empty. git diff --check and explicit whitespace checks of the new untracked files pass.

No staging, commit, or push is part of this milestone. Stop for researcher F6 review. An isolated milestone commit may only be prepared after the exact approval **CR-END-01 — APPROVED FOR MILESTONE COMMIT ✅**.
