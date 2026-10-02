# Casa Real editor-visible production hotspots

Branch: `fix/editor-visible-hotspots`. Scope: Casa Real / Banáan Pangasinan Provincial Museum only. Godot 4.7.2, GDScript, Compatibility renderer, landscape Web target.

## A–D. Discovery, architecture families, and representative states

The initial working tree was clean, on the requested branch, with `git diff --check` passing. Seven production scenes and seven matching preview harnesses were found. No CR-INT-04 production scene exists; none was invented.

All seven previously exposed the inherited blank/default shell in the editor. Their controllers generated the visitor interface in runtime `_ready()` and populated it through open/selection methods. None was already representative enough to leave its controller unchanged.

All paths below are relative to `res://scenes/landmarks/casa_real/`. Each production scene has a sibling `<id>_preview.tscn`. Its controller is `res://scripts/landmarks/casa_real/<id>.gd` and authoritative data is `res://data/landmarks/casa_real/<id>.tres`.

| Production integration target | Architecture family / runtime behavior | Representative static editor state |
| --- | --- | --- |
| `exterior/cr_ext_01.tscn` | Identity interpretation; three selectors | Royal House selected, façade image, approved heading/body, identity controls and takeaway |
| `exterior/cr_ext_02.tscn` | Architecture overview/detail viewer | Overview façade, three feature selectors, Full View, approved overview and caption |
| `exterior/cr_ext_03.tscn` | Three-role documentary interpretation; image cycling and display-only milestones | Overview, façade, approved introduction, three role buttons; no role/photo transition |
| `interior/cr_int_01.tscn` | Transformation stages; storm, comparison and museum photo interaction | Overview, façade, approved introduction and three stage buttons; storm and comparison inactive |
| `interior/cr_int_02.tscn` | Gallery directory/trail, photo/video preview, image focus and visitor-information modal | Directory, first gallery centered, adjacent plaques, approved introduction and browsing controls; video/modal closed |
| `interior/cr_int_03.tscn` | People/period connection network and portrait detail | Unselected overview, five portraits, three periods, static connection lines and approved overview |
| `end/cr_end_01.tscn` | Five-theme summary and optional reflection | Summary with Government selected, documentary image, approved interpretation and five cards; Reflection closed |

These form three implementation groupings without merging their interactions: the exterior selector/detail layouts, the roles/transformation documentary layouts, and the gallery/network/summary layouts. They share editor-shell lifecycle and safety code, while keeping their existing layout builders and small default-state adapters.

All seven inherit the cross-landmark `scenes/components/conference_room_interaction.tscn` and `scripts/components/conference_room_interaction.gd`, including its Sources overlay, audio player and lifecycle signals. Resource schemas derive from `conference_room_content.gd` / `conference_room_concept_entry.gd`. Each sibling preview uses its existing `scripts/landmarks/casa_real/<id>_preview.gd` harness.

| Hotspot | Resource and entry scripts under scripts/landmarks/casa_real/ | Additional runtime control |
| --- | --- | --- |
| CR-EXT-01 | Shared ConferenceRoomContent; `cr_ext_01_identity.gd` | None |
| CR-EXT-02 | `cr_ext_02_content.gd`, `cr_ext_02_detail.gd` | None |
| CR-EXT-03 | `cr_ext_03_content.gd`, `cr_ext_03_role.gd`, `cr_ext_03_photo.gd` | None |
| CR-INT-01 | `cr_int_01_content.gd`, `cr_int_01_stage.gd` | `cr_int_01_comparison.gd`, `cr_int_01_storm_visual.gd` |
| CR-INT-02 | `cr_int_02_content.gd`, `cr_int_02_gallery.gd` | `cr_int_02_trail.gd` |
| CR-INT-03 | `cr_int_03_content.gd`, `cr_int_03_personality.gd` | `cr_int_03_connection_layer.gd` |
| CR-END-01 | `cr_end_01_content.gd`, `cr_end_01_theme.gd` | None |

Every view retains its existing title, subtitle/overview where applicable, Sources, idle Listen, Close, and captions/takeaways where the default runtime view contains them. The gallery directory intentionally shows plaques rather than a video or gallery photograph; the people overview intentionally shows the network rather than a selected-person detail.

## E–H. Scope and implementation

No hotspot required a high-risk runtime rewrite or was left without an editor representation.

New shared Casa Real support: `scripts/landmarks/casa_real/cr_editor_presentation.gd`.

The seven controllers now use `@tool` with an explicitly guarded editor branch and a **Refresh Editor Preview** inspector action. The shared helper creates an unowned temporary shell named `_CasaRealEditorPresentation`, removes its runtime script and narration player, binds visual references, and seals the generated branch against focus, input, and processing. It does not modify the original authored children.

Each controller reuses its existing layout construction against either the production root at runtime or the temporary shell in the editor. UI allocation moved from member initialization into presentation construction so loading/reloading scripts does not allocate orphan controls. Arrays of generated controls are cleared on refresh. Repeated refresh removes the prior temporary branch and reconnects the root resize callback only once.

Three Casa Real controls support static editor presentation:

- `cr_int_01_comparison.gd`: tool-compatible property/drawing support; editor GUI input is blocked. It remains hidden in the default transformation view.
- `cr_int_02_trail.gd`: static directory plaques; editor centering never starts a tween or emits drag signals, and input is blocked.
- `cr_int_03_connection_layer.gd`: presentation-only line drawing is enabled in the editor.

The storm visual remains a runtime script and is explicitly hidden in the editor. The temporary transformation/gallery layouts may contain idle audio/video nodes, but no streams are assigned and no playback starts. The authored narration player remains untouched with no stream.

CR-EXT-03's packed milestone arrays are read through `Resource.get()` into typed locals. The initial editor lifecycle run crashed with signal 11; its GDScript backtrace led through `_refresh_editor_preview()` and `_render()` to `_render_milestones()`, at the direct `entry.milestone_dates[i]` access. Editor placeholder/direct typed packed-array access is the observed triggering path; the underlying engine-level cause has not been established. The property-interface read avoids that path without changing Resource values or runtime milestone behavior. Both complete editor lifecycle suites subsequently passed without recurrence.

Historical text, chronology, captions, source metadata, assets, narration, Resource schemas and data files are unchanged. No text was copied into scenes. Production and preview `.tscn` files remain unchanged. The shared cross-landmark conference-room component and all Lingayen Church files remain unchanged. No master scene or trigger placement was added.

## I. Runtime boundary and preservation

Runtime still initializes the existing base component, builds the same visitor UI, connects the same interaction signals, and uses the existing open/close, Sources, narration, animation, touch, mouse and keyboard behavior. The editor branch skips runtime initialization, open/reset flow, audio/video initialization, animation, input handling, focus grabs, URLs and navigation.

Generated nodes have no owner and are excluded from packed/saved scenes. Tests compare serialized snapshots before/after refresh and script reload, then save copies to TEMP and reopen them. No generated branch is saved. The helper never writes authoritative Resources.

The editor shows one stable representative state. It does not expose all states at once or convert generated UI into permanently authored WYSIWYG nodes. After changing an approved Resource in the inspector, use Refresh Editor Preview to update the representative view.

The runtime regression is **not entirely green** because the pre-existing CR-EXT-03 milestone Resource/test mismatch described below is present in both HEAD and this batch. No new runtime regression has been identified by the completed checks.

## J. Future integration contract

Each production scene passed independent instantiation under an inset generic `CanvasLayer/Control` host at 1280×720, 960×540 and 854×480. The outer viewport was deliberately larger than the host; the hotspot followed the host dimensions.

| Hotspot | Public open API | Close API | Existing host notification | Integration result |
| --- | --- | --- | --- | --- |
| CR-EXT-01 | `open_hotspot()` / `open_interaction()` | `close_hotspot()` / `close_interaction()` | `closed` | Pass |
| CR-EXT-02 | Same | Same | `closed` | Pass |
| CR-EXT-03 | Same | Same | `closed` | Pass |
| CR-INT-01 | Same | Same | `closed` | Pass |
| CR-INT-02 | Same | Same | `closed`, `close_requested` | Pass |
| CR-INT-03 | Same | `close_interaction()` | `closed`, `close_requested` | Pass |
| CR-END-01 | Same | `close_interaction()` | `closed`, `close_requested` | Pass |

Existing `opened`, Sources/narration signals and hotspot-specific selection APIs remain available. Hosted components wait hidden until the host opens them; direct standalone production launches retain their existing opening behavior. The host needs no internal UI knowledge.

The environment developer owns trigger placement, player suspension, collisions and post-close exploration. The hotspot owns its UI, multimedia, content and internal state. Production controllers contain no dependency on their preview scene, player implementation, environment path, master layout or landmark switching.

**Instance the production scene listed above in the future environment. The matching preview is an isolated F6 harness only.**

## K–L. Testing and results

New fixtures:

- `tests/cr_casa_editor_test.gd` and `tests/cr_casa_editor_test.tscn`
- `tests/cr_casa_integration_test.gd`

The editor fixture is inert without its explicit command-line test flag. It validates three construction cycles, three landscape sizes, repeated refreshes, script reload, authored serialization snapshots, TEMP save/reinstantiation, actual production scenes opened/reloaded in Godot's 2D editor, ownership, signal connections, absence of visitor input/focus/playback/tweens, header state, Resource content and geometry.

| Check | Result |
| --- | --- |
| Seven-hotspot headless editor lifecycle | 65,436 checks, 0 failures |
| Seven-hotspot Compatibility editor lifecycle | 65,464 checks, 0 failures, including 28 image saves |
| Generic-host integration | 161 checks, 0 failures |
| Godot language-server diagnostics | 13 changed/new scripts, 0 warnings/errors; corresponding 10 HEAD scripts also 0 |
| Direct production/preview launches | All 14 Compatibility launches exit 0; no implementation warning/error |
| Final Godot editor import | Exit 0; only the existing certificate-store diagnostic |
| Whitespace/scope audit | git diff --check and explicit checks of new files pass; only the 10 scoped Casa Real scripts changed |

The 28 editor images comprise three-sized fixture captures for each hotspot and one actual 2D-editor viewport capture per production scene. All seven reference-size and 854×480 representations were visually inspected, with actual editor viewport samples also inspected. Actual editor viewport captures retain the editor's current canvas zoom/pan; fixture captures show the entire component. No portrait redesign was introduced.

Continuation verification repeated the complete Compatibility editor fixture: **65,464 checks, 0 failures**, with no recurrence of the CR-EXT-03 crash (`TEMP/akar_casa_final_editor.log`). CR-EXT-03's 1280×720 and 854×480 captures were also re-inspected and remain clear, with compact scrolling at the smaller size. An attempted external TEMP-only focused fixture did not begin assertions and was stopped; it is not counted as validation. The established in-project fixture supplied the fresh result instead.

| Runtime suite | Headless checks / failures | Compatibility checks / failures |
| --- | --- | --- |
| CR-EXT-01 | 1,983 / 0 | 1,998 / 0 |
| CR-EXT-02 | 1,897 / 0 | 1,921 / 0 |
| CR-EXT-03 | 3,167 / 308 — pre-existing mismatch | 3,206 / 308 — same mismatch |
| CR-INT-01 | 2,287 / 0 | 2,329 / 0 |
| CR-INT-02 | 5,232 / 0 — uncapped full run | 5,328 / 0 |
| CR-INT-03 | 3,853 / 0 | 3,901 / 0 |
| CR-END-01 | 3,148 / 0 | 3,175 / 0 |

These unchanged suites exercise the visitor interaction states, Sources, narration, touch/mouse/keyboard, Escape hierarchy, rapid selection, reset/reopen and all three required sizes. Gallery testing also decodes the actual clips, lets all 13 finish naturally once, and tests replay/skip. Compatibility runtime suites save their established screenshots.

### Reproduction

From the repository root, substitute the installed Godot console executable for `$godot`:

```powershell
& $godot --headless --editor --path . --import --quit
& $godot --headless --editor --path . res://tests/cr_casa_editor_test.tscn -- --casa-editor-test
& $godot --editor --rendering-method gl_compatibility --path . res://tests/cr_casa_editor_test.tscn -- --casa-editor-test --capture
& $godot --headless --path . --script res://tests/cr_casa_integration_test.gd
& $godot --headless --path . --script res://tests/cr_ext_01_test.gd
& $godot --headless --path . --script res://tests/cr_ext_02_test.gd
& $godot --headless --path . --script res://tests/cr_ext_03_test.gd
& $godot --headless --path . --script res://tests/cr_int_01_test.gd
& $godot --headless --path . --script res://tests/cr_int_02_test.gd
& $godot --headless --path . --script res://tests/cr_int_03_test.gd
& $godot --headless --path . --script res://tests/cr_end_01_test.gd
git diff --check
```

For the rendered runtime suites, replace `--headless` with `--rendering-method gl_compatibility` and append `-- --capture`. Let the gallery suite quit itself; a frame-count cap can end it before all real-time video and navigation checks finish.

Logs, screenshots, roundtrip files and the isolated baseline fixture are under TEMP using `akar_casa_*` / `*_casa_editor_*` names. Language-server reports are `akar_casa_diagnostics.json` and `akar_casa_lsp_messages.json`. These are QA evidence, not project assets.

### Manual Godot review

1. Open each production scene from the inventory directly in Godot's 2D editor, without F6. Frame/zoom the root as needed and confirm its representative state.
2. Select the root and invoke Refresh Editor Preview repeatedly. Close/reopen the tab and reload its script. Confirm no duplicate interface, animation, sound, navigation or focus capture.
3. Save/reopen and inspect the scene diff: the temporary presentation must not appear in serialized scene content.
4. Run the matching preview with F6. Test the normal states, Sources, Listen, Close/reopen, Escape and rapid selection.
5. Resize to 1280×720, 960×540 and 854×480. Verify local scrolling and the existing compact layouts; test physical touch on the intended tablet as a separate device acceptance pass.
6. For future integration, instance only the production scene beneath a sized Control/HotspotLayer, call its public open method, and resume the host on its existing close notification.

CLI production/preview launches are F6-equivalent execution, not a claim that a human F6 acceptance pass was performed.

Browser export is not validated: the repository has no export presets and the installed 4.7.2 web release template was not found. Project renderer/stretch settings are unchanged.

## M–N. Diagnostics and pre-existing limitations

**New implementation diagnostics:** none in the passing editor, integration and language-server runs. The initial packed-array editor crash was fixed and the complete editor suites subsequently passed.

**Existing environment diagnostic:** Godot emits `Failed to read the root certificate store` during startup.

**Existing CR-EXT-03 regression mismatch:** the checked-in `cr_ext_03.tres` does not specify `milestone_dates` or `milestone_labels` for its role entries; their schema defaults are empty. The unchanged `cr_ext_03_test.gd` expects 4 Government, 3 Public Service and 5 Heritage milestones. Assertions fail and the test then accesses absent label children, producing out-of-bounds/null-instance diagnostics.

To establish causality without changing production files, the exact HEAD controller and temporary copies of its production/preview scenes and test were run from TEMP against the unchanged project data. Only temporary references were redirected. **HEAD and the adapted controller both report 3,167 checks and 308 failures.** The new rendered run reports the same 308 failures. The Resource hash matches the initial baseline.

### Focused read-only CR-EXT-03 milestone investigation

**Classification: missing Resource data required by the documented runtime interaction, not a stale test.** This conclusion is supported by the current controller, schema, preview, testing document and git history:

- Original feature commit `6f27080` (`feat(casa-real): implement CR-EXT-03 changing roles hotspot`) included milestone arrays for the three roles: 4 Government, 3 Public Service and 5 Heritage entries. These match the unchanged test expectations and milestone tables in `docs/cr_ext_03_testing.md`.
- Pre-batch commit `0c6cb47` (`chore: preserve working build before editor-preview fixes`, 2026-10-01 23:39:19 +0800) removed the six `milestone_dates` / `milestone_labels` assignments from `data/landmarks/casa_real/cr_ext_03.tres`. The diff also reserialized Resource ordering, UIDs and strings. The reason for removing the arrays is not established by the repository evidence.
- The role schema still exports both packed arrays. The controller still calls `_render_milestones()` on render and resize, and provides milestone styling and layout. Its length-consistency check accepts two empty arrays, allowing the hotspot to open with the strip empty.
- The production and preview use the same Resource; the preview does not inject alternate milestone data. The existing testing document specifies display-only milestones, role-specific tables, and full/compact milestone layouts at the three reference sizes. No corresponding removal of this requirement was found.
- The controller at HEAD, role schema, existing regression test and testing document retain the original feature implementation. The isolated HEAD-controller run reproduces the same 308 failures, establishing that the missing data predates this editor-visibility batch.

No Resource or existing regression test was changed during this investigation. No historical values were inferred or restored from test constants, and no assertions were weakened. Restoring the previously documented content is a separately scoped content repair requiring researcher review; the current task authorizes investigation only. The empty milestone strip and its regression failures remain a known runtime limitation.

The first CR-INT-02 headless invocation reached its external frame cap before the suite summary and reported exit-time resource cleanup diagnostics. It is not counted as a passing suite. The uncapped rerun passed all 5,232 checks with no cleanup diagnostic; the complete rendered run also passed.

## O–Q. File inventory, deferrals, and commit recommendation

Modified tracked files:

```text
scripts/landmarks/casa_real/cr_ext_01.gd
scripts/landmarks/casa_real/cr_ext_02.gd
scripts/landmarks/casa_real/cr_ext_03.gd
scripts/landmarks/casa_real/cr_int_01.gd
scripts/landmarks/casa_real/cr_int_01_comparison.gd
scripts/landmarks/casa_real/cr_int_02.gd
scripts/landmarks/casa_real/cr_int_02_trail.gd
scripts/landmarks/casa_real/cr_int_03.gd
scripts/landmarks/casa_real/cr_int_03_connection_layer.gd
scripts/landmarks/casa_real/cr_end_01.gd
```

New files:

```text
scripts/landmarks/casa_real/cr_editor_presentation.gd
scripts/landmarks/casa_real/cr_editor_presentation.gd.uid
tests/cr_casa_editor_test.gd
tests/cr_casa_editor_test.gd.uid
tests/cr_casa_editor_test.tscn
tests/cr_casa_integration_test.gd
tests/cr_casa_integration_test.gd.uid
docs/casa_real_editor_visibility.md
```

The baseline contains 790 pre-existing files. The scope audit finds changes only in the 10 Casa Real scripts listed above. All other 780 pre-existing files, including scenes, Resources, assets, project.godot, Church, other landmarks and existing tests, remain byte-for-byte unchanged.

The tracked diff is 1,076 insertions and 297 deletions across 10 files. Eight new untracked files are listed above; ordinary git diff --stat excludes those until staged. The index is empty.

No high-risk rewrite was needed or deferred. CR-INT-04 and Casa Real master integration remain outside scope. The pre-existing CR-EXT-03 content/test mismatch is deliberately preserved and reported rather than repaired in an editor-presentation batch.

**Recommendation: safe to commit with documented pre-existing limitation**, for this isolated editor-visibility batch. The missing CR-EXT-03 milestone data predates these changes and reproduces with the HEAD controller. This is not approval of the complete Casa Real runtime regression gate: that gate remains red until the separately scoped Resource issue is resolved and revalidated. Browser export and physical-touch acceptance also remain unvalidated.

Nothing staged. No commit. No push. Stop after Casa Real.
