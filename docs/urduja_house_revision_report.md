# URDUJA HOUSE COMPLETE REVISION REPORT

## 1. Overall revision status

Continued the existing implementation; all nine standalone previews are ready for researcher F6 review. No master-scene or application-flow integration. No commit or push. Godot 4.7.2 Compatibility validation completed on 3 October 2026.

## 2. Files added

Paths are repository-relative. The eight pre-existing untracked researcher audio/import files in Git status were NOT created or modified by this revision.

- `data/landmarks/urduja_house/revision/uh_end_01.tres`
- `data/landmarks/urduja_house/revision/uh_ent_01.tres`
- `data/landmarks/urduja_house/revision/uh_ext_01.tres`
- `data/landmarks/urduja_house/revision/uh_ext_02.tres`
- `data/landmarks/urduja_house/revision/uh_ext_03.tres`
- `data/landmarks/urduja_house/revision/uh_int_01.tres`
- `data/landmarks/urduja_house/revision/uh_int_02.tres`
- `data/landmarks/urduja_house/revision/uh_int_03.tres`
- `data/landmarks/urduja_house/revision/uh_int_04.tres`
- `docs/specifications/urduja_house/revision_2026_10_02.md`
- `docs/urduja_house_media_credits.md`
- `docs/urduja_house_revision_report.md`
- `scenes/landmarks/urduja_house/components/embedded_video.tscn`
- `scenes/landmarks/urduja_house/components/uh_end_01.tscn`
- `scenes/landmarks/urduja_house/components/uh_ent_01.tscn`
- `scenes/landmarks/urduja_house/components/uh_ext_01.tscn`
- `scenes/landmarks/urduja_house/components/uh_ext_02.tscn`
- `scenes/landmarks/urduja_house/components/uh_ext_03.tscn`
- `scenes/landmarks/urduja_house/components/uh_int_01.tscn`
- `scenes/landmarks/urduja_house/components/uh_int_02.tscn`
- `scenes/landmarks/urduja_house/components/uh_int_03.tscn`
- `scenes/landmarks/urduja_house/components/uh_int_04.tscn`
- `scenes/landmarks/urduja_house/components/visual_explorer.tscn`
- `scripts/landmarks/urduja_house/uh_embedded_video.gd`
- `scripts/landmarks/urduja_house/uh_embedded_video.gd.uid`
- `scripts/landmarks/urduja_house/uh_hotspot.gd`
- `scripts/landmarks/urduja_house/uh_hotspot.gd.uid`
- `scripts/landmarks/urduja_house/uh_legacy_presentation.gd`
- `scripts/landmarks/urduja_house/uh_legacy_presentation.gd.uid`
- `scripts/landmarks/urduja_house/uh_preview.gd`
- `scripts/landmarks/urduja_house/uh_preview.gd.uid`
- `scripts/landmarks/urduja_house/uh_revision_content.gd`
- `scripts/landmarks/urduja_house/uh_revision_content.gd.uid`
- `scripts/landmarks/urduja_house/uh_visual_explorer.gd`
- `scripts/landmarks/urduja_house/uh_visual_explorer.gd.uid`
- `tests/uh_revision_render_test.gd`
- `tests/uh_revision_test.gd`
- `tests/uh_revision_test.gd.uid`

## 3. Files modified

- `data/landmarks/urduja_house/uh_end_01.tres`
- `data/landmarks/urduja_house/uh_ent_01.tres`
- `data/landmarks/urduja_house/uh_ext_01.tres`
- `data/landmarks/urduja_house/uh_ext_02.tres`
- `data/landmarks/urduja_house/uh_ext_03.tres`
- `data/landmarks/urduja_house/uh_int_01.tres`
- `data/landmarks/urduja_house/uh_int_02.tres`
- `data/landmarks/urduja_house/uh_int_03.tres`
- `data/landmarks/urduja_house/uh_int_04.tres`
- `docs/uh_end_01_testing.md`
- `docs/uh_ent_01_testing.md`
- `docs/uh_ext_01_testing.md`
- `docs/uh_ext_02_testing.md`
- `docs/uh_ext_03_testing.md`
- `docs/uh_int_01_testing.md`
- `docs/uh_int_02_testing.md`
- `docs/uh_int_03_testing.md`
- `docs/uh_int_04_testing.md`
- `scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn`
- `scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn`
- `scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn`
- `scenes/landmarks/urduja_house/interior/uh_int_01.tscn`
- `scenes/landmarks/urduja_house/interior/uh_int_02.tscn`
- `scenes/landmarks/urduja_house/interior/uh_int_03.tscn`
- `scenes/landmarks/urduja_house/interior/uh_int_04.tscn`
- `scenes/landmarks/urduja_house/summary/uh_end_01.tscn`
- `scenes/landmarks/urduja_house/supporting/uh_ent_01.tscn`
- `tests/cr_ext_01_test.gd`

## 4. Shared components reused/created

Added a Urduja-scoped composition shell, resource metadata, preview wrapper, visual explorer, video view and legacy presentation adapter. Existing artwork, timeline, ceremonial-hall and summary components are reused. Shared base components remain byte-identical. The authorized obsolete Urduja block in tests/cr_ext_01_test.gd was updated; Casa assertions and content were not changed.

## 5. UH-EXT-01 status

PLACE / 1953 / TODAY discovery rail supports direct selection, mouse/touch dragging, keyboard alternatives, snapping and latest-input-wins transitions.

## 6. UH-EXT-02 status

NEED / ESTABLISHMENT origin explorer uses the archival photograph. The researcher-supplied portrait remains deferred; see the media audit for exact paths.

## 7. UH-EXT-03 status

Five supplied-icon markers remain within the fitted image. Exact labels retained; only Roofline has explanatory text. No additional architectural claims.

## 8. UH-ENT-01 status

Parent-sized video interaction, transcript/status view and Skip/Close remain available. Playback remains unassigned pending RESEARCHER VIDEO/TRANSCRIPT VERIFICATION REQUIRED. The supplied video bytes are unchanged. No transcript of the unverified video was invented; the separate approved narration script remains available.

## 9. UH-INT-01 status

Artwork remains prominent with three interpretation sections and region inspection. Legendary/cultural association wording distinguishes tradition from verified history.

## 10. UH-INT-02 status

Existing snap timeline retained with corrected construction wording. Documentary and interpretive imagery are explicitly distinguished; the archival photograph is not assigned an unverified capture year.

## 11. UH-INT-03 status

About the Hall / Official Events / View the Space remain distinct. Existing event records and image browsing are retained. Missing source details are unresolved.

## 12. UH-INT-04 status

Room-function exploration uses three focused concepts and the room image. It is separate from ceremonial-hall event browsing.

## 13. UH-END-01 status

Existing optional five-summary navigator, supplied visitor marker, restrained shimmer, arrows and Return to Landmark Map signal retained. No completion requirement or reward semantics.

## 14. Sources behavior

SOURCES opens a parent-contained, scrollable overlay with historical references, media credits and the approved transcript. Selection is preserved; active narration continues. Tab stays within the overlay and Escape/Backspace closes it before the hotspot.

## 15. Narration status for EACH hotspot

TEMPORARY DEVELOPMENT AUDIO — FINAL RECORDING TO REPLACE SAME FILE PATH

| Hotspot | LISTEN status |
|---|---|
| UH-EXT-01 | Enabled; existing temporary recording |
| UH-EXT-02 | Enabled; existing temporary recording |
| UH-EXT-03 | Enabled; existing temporary recording |
| UH-ENT-01 | Pending; no separate narration file |
| UH-INT-01 | Enabled; existing temporary recording |
| UH-INT-02 | Enabled; existing temporary recording |
| UH-INT-03 | Enabled; existing temporary recording |
| UH-INT-04 | Enabled; existing temporary recording |
| UH-END-01 | Enabled; existing temporary recording |

Duplicate hashes are a KNOWN TEMPORARY DEVELOPMENT CONDITION, accepted by the researcher. Approved transcripts remain separate and unchanged by this continuation. Paths and media bytes are preserved. First activation plays; another stops/resets; actual natural completion returns idle. Internal selection/Sources preserve playback; close/hide/another hotspot stops prior audio. No production duration or waveform assumptions.

## 16. Historical-content scan

No removed palace-name, guest-house, first-resident or 2012 rehabilitation claims were found in visitor-facing Urduja scenes/scripts/resources. Construction statements use began in 1953; approved transcript references to establishment/since 1953 remain intact. Original archival specifications were not rewritten. No unsupported architectural explanation was added.

## 17. Media-credit status

docs/urduja_house_media_credits.md records 36 media rows, including path, hotspot, subject/type, classification, creator/source/rights, displayed credit and unresolved status. Unknown provenance is SOURCE / CREDIT UNRESOLVED. No photographer, ownership, date or license was invented.

## 18. Responsive/render results

All nine actual previews rendered using GL Compatibility at 1280×720, 960×540 and 854×480, each full and inset: 54 layouts. Rendered-header assertions: zero failures. All 27 inset layouts were visually inspected, plus artwork/event detail and Sources views. Resize redraw was corrected in the Urduja shell. Real touchscreen and browser-export review remain manual.

## 19. Automated test results

- Godot headless editor import: exit 0; no project parse/resource errors.
- Urduja regression: 1,931 checks, zero failures.
- Updated CR-EXT-01 suite: 1,983 checks, zero failures.
- Render test: 54 layouts, zero rendered-header failures.
- Additional completed suites: CR-EXT-02 1,897; CR-INT-01 2,287; CR-INT-03 3,853; CR-END-01 3,148; Church 1,887; Limahong 3,461 checks, all zero failures.
- Literal Urduja resource-path scan: zero missing resources.
- git diff --check and git diff --cached --check: passed.
- SHA-256 baseline comparison: no unintended changes; all original media, other-landmark content, shared base components, AGENTS.md and project.godot unchanged.
- Godot emits an environment root-certificate-store diagnostic; this is reported separately from project validation.

Run from repository root:

```powershell
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/uh_revision_test.gd
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/uh_revision_render_test.gd
```

The render test requires a graphics display and writes PNGs to $env:TEMP/akar_urduja_revision.

## 20. Out-of-scope/pre-existing failures

UNRELATED PRE-EXISTING / OUT-OF-SCOPE TEST FAILURE: CR-EXT-03 reports 3,167 checks / 308 failures involving missing milestone-strip children/null access. Its test and dependencies remain unchanged against the initial clean tracked baseline. No Casa content was changed to address it. CR-INT-02 broader test exceeded the external 65-second run limit; incomplete, not a passing result. Its long real-clip completion checks were not weakened.

## 21. Researcher actions still required

Replace the eight temporary narration recordings at the same paths using their approved transcripts. Verify the historical video and supply its actual validated transcript before enabling playback. Resolve media credits/permissions and final bibliographic references. Complete physical-touch and browser-export acceptance review.

For F6: open project.godot in Godot 4.7.2; open each scene below and press F6 (Run Current Scene), not F5. Test selection/rapid changes, Tab/Shift+Tab and Enter/Space, Sources, Listen, Escape/Backspace and reopen at all three sizes. END Return must emit its signal. ENT Skip/Close must work while unverified playback remains disabled. Each docs/uh_*_testing.md gives detailed expectations.

- `scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn`
- `scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn`
- `scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn`
- `scenes/landmarks/urduja_house/interior/uh_int_01.tscn`
- `scenes/landmarks/urduja_house/interior/uh_int_02.tscn`
- `scenes/landmarks/urduja_house/interior/uh_int_03.tscn`
- `scenes/landmarks/urduja_house/interior/uh_int_04.tscn`
- `scenes/landmarks/urduja_house/summary/uh_end_01.tscn`
- `scenes/landmarks/urduja_house/supporting/uh_ent_01.tscn`

## 22. Exact git status

Captured after creating this report. Nothing staged. The eight audio/import entries predate the revision and remain unchanged.

```text
 M data/landmarks/urduja_house/uh_end_01.tres
 M data/landmarks/urduja_house/uh_ent_01.tres
 M data/landmarks/urduja_house/uh_ext_01.tres
 M data/landmarks/urduja_house/uh_ext_02.tres
 M data/landmarks/urduja_house/uh_ext_03.tres
 M data/landmarks/urduja_house/uh_int_01.tres
 M data/landmarks/urduja_house/uh_int_02.tres
 M data/landmarks/urduja_house/uh_int_03.tres
 M data/landmarks/urduja_house/uh_int_04.tres
 M docs/uh_end_01_testing.md
 M docs/uh_ent_01_testing.md
 M docs/uh_ext_01_testing.md
 M docs/uh_ext_02_testing.md
 M docs/uh_ext_03_testing.md
 M docs/uh_int_01_testing.md
 M docs/uh_int_02_testing.md
 M docs/uh_int_03_testing.md
 M docs/uh_int_04_testing.md
 M scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn
 M scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn
 M scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_01.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_02.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_03.tscn
 M scenes/landmarks/urduja_house/interior/uh_int_04.tscn
 M scenes/landmarks/urduja_house/summary/uh_end_01.tscn
 M scenes/landmarks/urduja_house/supporting/uh_ent_01.tscn
 M tests/cr_ext_01_test.gd
?? assets/landmarks/urduja_house/audio/uh_end_01_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_end_01_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_02_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_02_narration.ogg.import
?? assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg
?? assets/landmarks/urduja_house/audio/uh_ext_03_narration.ogg.import
?? data/landmarks/urduja_house/revision/
?? docs/specifications/urduja_house/revision_2026_10_02.md
?? docs/urduja_house_media_credits.md
?? docs/urduja_house_revision_report.md
?? scenes/landmarks/urduja_house/components/
?? scripts/landmarks/urduja_house/uh_embedded_video.gd
?? scripts/landmarks/urduja_house/uh_embedded_video.gd.uid
?? scripts/landmarks/urduja_house/uh_hotspot.gd
?? scripts/landmarks/urduja_house/uh_hotspot.gd.uid
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd
?? scripts/landmarks/urduja_house/uh_legacy_presentation.gd.uid
?? scripts/landmarks/urduja_house/uh_preview.gd
?? scripts/landmarks/urduja_house/uh_preview.gd.uid
?? scripts/landmarks/urduja_house/uh_revision_content.gd
?? scripts/landmarks/urduja_house/uh_revision_content.gd.uid
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd
?? scripts/landmarks/urduja_house/uh_visual_explorer.gd.uid
?? tests/uh_revision_render_test.gd
?? tests/uh_revision_test.gd
?? tests/uh_revision_test.gd.uid
```

READY FOR URDUJA F6 REVIEW — NO COMMIT / NO PUSH
