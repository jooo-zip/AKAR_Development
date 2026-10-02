# Provincial Capitol editor-visible production hotspots

Branch: `fix/editor-visible-hotspots`. Scope: Pangasinan Provincial Capitol only. Godot 4.7.2, GDScript, Compatibility renderer, landscape Web target.

## A–C. Discovery and architecture

The starting working tree was clean at `a2ef807`; branch and `git diff --check` matched the requested starting point. Five production scenes and five matching previews exist. No additional Capitol hotspot was found or invented. All five previously displayed the inherited default shell in the 2D editor; none was already representative.

Paths in this table are relative to `res://scenes/landmarks/pangasinan_provincial_capitol/`. Each production scene has a sibling `<id>_preview.tscn`. Each controller is `res://scripts/landmarks/pangasinan_provincial_capitol/<id>.gd`; each authoritative content Resource is `res://data/landmarks/pangasinan_provincial_capitol/<id>.tres`.

| Production integration target | Interaction family | Supporting script in the Capitol scripts directory |
| --- | --- | --- |
| `exterior/ppc_ext_01.tscn` | Three parallel orientation views and photograph Explore View | `ppc_ext_01_view.gd` Resource entry |
| `exterior/ppc_ext_02.tscn` | Architecture modes, symmetry reveal, feature/climate annotations, documentary details | `ppc_ext_02_canvas.gd` |
| `interior/ppc_int_01.tscn` | Direct-access chronology, historical comparison and source viewer | `ppc_int_01_canvas.gd` |
| `interior/ppc_int_02.tscn` | Civic relationship diagram, institutional topics, comparison and documentary spaces | `ppc_int_02_canvas.gd` |
| `summary/ppc_end_01.tscn` | Five-theme synthesis and optional local reflection | `ppc_end_01_canvas.gd` |

All inherit `scenes/components/conference_room_interaction.tscn` and its `ConferenceRoomInteraction` controller, including the Sources overlay and narration lifecycle. Content uses `ConferenceRoomContent` and `ConferenceRoomConceptEntry`; EXT-01 adds its existing view-entry schema. The four canvas-based interfaces share layout/construction conventions but retain their distinct interactions. Their sibling preview controllers remain isolated F6 harnesses. There was no pre-existing Capitol editor helper.

## D–G. Changes and representative states

All five controllers were adapted. No production hotspot was deferred or left without an editor view. Production and preview scene files remain unchanged.

| Hotspot | Stable editor state |
| --- | --- |
| PPC-EXT-01 | THE CAPITOL selected; documentary photograph, focus frame, caption, context, approved introduction and takeaway; three view selectors; Explore View closed |
| PPC-EXT-02 | Full façade overview with READ THE FAÇADE hint, approved overview and three architecture selectors; detail viewer closed |
| PPC-INT-01 | Initial overview with present-day contextual photograph, caption, approved interpretation and five-date rail; comparison and historical-source viewer inactive |
| PPC-INT-02 | Initial PUBLIC LOBBY relationship diagram, executive/legislative labels, schematic disclaimer, approved introduction and four civic choices; documentary viewer closed |
| PPC-END-01 | Summary overview photograph, caption, approved synthesis, five themes and YOUR REFLECTION; reflection closed with no choice selected |

EXT-02's actual runtime overview does not draw feature brackets: these appear only after selecting the relevant architecture mode. The editor preserves that default rather than adding markers from another state. INT-02's default is a conceptual civic relationship diagram, not a documentary photograph or physical floor plan. Observation labels in EXT-01 follow the current Resource, including the pre-existing missing data described below.

Every view shows its existing title, subtitle, Sources, idle Listen and Close. Approved copy, captions, image metadata and interpretation still come from the existing Resources. Sources remain in their normal closed state; source credits are available through the runtime Sources interaction.

New support: `scripts/landmarks/pangasinan_provincial_capitol/ppc_editor_presentation.gd`.

The four existing canvas scripts now permit their static drawing/layout code in the editor. Architecture and history canvas input/reveal entry points are guarded. The civic canvas skips visitor signal wiring in the editor; its node allocation occurs at construction. The summary canvas is already passive and only needs tool execution for static rendering.

## H. Implementation and safety boundary

Each controller has an early editor-only `_ready()` branch and a **Refresh Editor Preview** inspector action. The common helper creates an unowned `_CapitolEditorPresentation` shell, removes its runtime script and narration player, and binds visual references to that temporary shell. The original authored children are not modified.

The controllers reuse their existing layout builders against either the runtime production root or the temporary editor shell. Generated Control allocation moved out of member initializers into the builder, avoiding orphan allocations during script loading. Refresh replaces the old temporary branch and clears arrays/dictionaries of generated controls. Root resize wiring is connected once.

Small default-state adapters render approved Resource content without invoking public open/reset methods. Nested concept arrays and EXT-01's packed observation labels are read through the Resource property interface. No Resource values are written. No approved text is duplicated into a scene or editor-specific script.

Visitor signal connections and runtime entry points are blocked in the editor. The temporary branch is recursively unowned, unfocusable, mouse-ignoring and disabled for processing/input. Layout/resize callbacks remain available to arrange the static display. No editor narration, media playback, timers, tweens, focus grabs, navigation or runtime lifecycle signals occur.

The editor presentation is visually representative and inspectable; it is not a permanent authored-node migration. Use Refresh Editor Preview after changing an approved Resource. F6 provides the complete interaction. At compact sizes, existing local text/date/theme scrolling is represented statically, with the normal initial scroll position.

## I. Runtime preservation

Runtime still calls the original base initialization, constructs the same interface, wires visitor controls, and uses the established open/reset/close, narration, Sources, image viewer, comparison and reflection paths. Tool branches do not run at runtime. The existing five runtime suites were left unchanged.

The regression gate is **not wholly green**: EXT-01's pre-existing missing observation labels produce the same 30 assertion failures before and after this batch. No new failure was found. This is a preservation result, not a claim that all Capitol content requirements pass.

Historical facts, chronology, titles, narration/audio, media, captions, sources, Resource schemas and `.tres` files are unchanged. No game features or new educational claims were introduced.

## J. Future integration contract

| Production hotspot | Public host API | Host notification | Generic-host result |
| --- | --- | --- | --- |
| PPC-EXT-01 | `open_hotspot()` / `open_interaction()`, `reset_hotspot()`, `close_hotspot()` / `close_interaction()` | `opened`, `closed` | Pass at all three sizes |
| PPC-EXT-02 | Same | `opened`, `closed` | Pass at all three sizes |
| PPC-INT-01 | Same | `opened`, `closed` | Pass at all three sizes |
| PPC-INT-02 | Same | `opened`, `closed` | Pass at all three sizes |
| PPC-END-01 | Same | `opened`, `closed` | Pass at all three sizes |

Existing Sources/narration signals and hotspot-specific selection APIs remain available. The test host instances each production scene independently beneath a generic `CanvasLayer/Control`, waits for it to remain hidden, then opens/resets/closes it through public API and observes close notifications. The host Control is inset inside a deliberately larger viewport; each hotspot follows the host dimensions at 1280×720, 960×540 and 854×480. No internal UI lookup is needed to drive the host lifecycle.

The environment developer owns triggers, player/environment suspension, collision and post-close behavior. The hotspot owns interpretation, multimedia and internal UI state. There are no new player dependencies, hard-coded environment paths, scene switches, master-layout dependencies or completion gates.

**Instance the production scene from the inventory above. Its preview is a test/F6 harness only.** No Capitol environment, PPC-ENT insertion or other landmark work was performed.

## K–L. Validation

New fixtures:

- `tests/ppc_capitol_editor_test.gd` and `.tscn`
- `tests/ppc_capitol_integration_test.gd`

The editor fixture is inert without its explicit command-line test flag. It validates three construction cycles, all three sizes, repeated refresh, controller script reload, Resource identity, authored serialization snapshots, TEMP save/reinstantiation, actual production scenes opened/reloaded in the 2D editor, node ownership, button/resize signal wiring, absence of playback/focus/tweens/runtime signals, default content and header geometry.

| Check | Result |
| --- | --- |
| Headless editor lifecycle | 65,190 checks, 0 failures |
| Compatibility editor lifecycle | 65,210 checks, 0 failures, including 20 image saves |
| Generic CanvasLayer/Control integration | 145 checks, 0 failures |
| Language-server diagnostics | 12 changed/new scripts: empty diagnostic lists; 9 corresponding HEAD scripts: empty diagnostic lists |
| Direct production and preview launches | All 10 Compatibility launches exit 0; no implementation errors/warnings |
| Final editor import | Exit 0; only the existing certificate-store diagnostic |
| Whitespace and scope | `git diff --check` passes; nine scoped existing files changed, eight new files, index empty |

The 20 editor images include all five hotspots at three sizes and one actual 2D-editor viewport capture per production scene. Reference-size and 854×480 views were visually inspected for every hotspot, with actual-editor viewport samples inspected as well. Actual editor captures retain the editor's current zoom/pan; fixture images show the whole component.

| Existing runtime suite | Before batch, headless checks / failures | After batch, headless checks / failures | After batch, Compatibility checks / failures |
| --- | --- | --- | --- |
| PPC-EXT-01 | 2,439 / 30 | 2,439 / 30 | 2,466 / 30 |
| PPC-EXT-02 | 1,975 / 0 | 1,975 / 0 | 2,008 / 0 |
| PPC-INT-01 | 1,963 / 0 | 1,963 / 0 | 2,005 / 0 |
| PPC-INT-02 | 2,065 / 0 | 2,065 / 0 | 2,110 / 0 |
| PPC-END-01 | 5,437 / 0 | 5,437 / 0 | 5,473 / 0 |

These suites exercise the established primary states, rapid switching, touch/mouse/keyboard, Sources, narration continuity and stopping, reset/reopen, Escape hierarchy and responsive layouts. The rendered suites retain their existing screenshot checks. Direct scene launches use `--quit-after 90` as smoke checks; complete suites quit on their own without a frame cap.

### Reproduction

From the repository root, use the installed Godot 4.7.2 console executable as `$godot`:

```powershell
& $godot --headless --editor --path . --import --quit
& $godot --headless --editor --path . res://tests/ppc_capitol_editor_test.tscn -- --capitol-editor-test
& $godot --editor --rendering-method gl_compatibility --path . res://tests/ppc_capitol_editor_test.tscn -- --capitol-editor-test --capture
& $godot --headless --path . --script res://tests/ppc_capitol_integration_test.gd
& $godot --headless --path . --script res://tests/ppc_ext_01_test.gd
& $godot --headless --path . --script res://tests/ppc_ext_02_test.gd
& $godot --headless --path . --script res://tests/ppc_int_01_test.gd
& $godot --headless --path . --script res://tests/ppc_int_02_test.gd
& $godot --headless --path . --script res://tests/ppc_end_01_test.gd
git diff --check
```

For rendered runtime suites, replace `--headless` with `--rendering-method gl_compatibility` and append `-- --capture`. Use an isolated process-local APPDATA/LOCALAPPDATA for automated editor runs. Logs, captures and roundtrip files are in TEMP with `akar_capitol_*` and `*_capitol_editor_*` names. Language-server messages and reports are `akar_capitol_lsp_messages.json` and `akar_capitol_diagnostics.json`; Windows URI escaping was normalized when reading the diagnostic responses.

### Manual Godot review

1. Open every listed production scene directly in the 2D editor without F6. Frame/zoom the root and confirm the default state.
2. Select the root and repeatedly click Refresh Editor Preview. Reload its script, close/reopen its tab, and confirm no duplicate interface, sound, animation or focus capture.
3. Save/reopen and inspect the scene diff: no temporary presentation should serialize.
4. Run the sibling preview with F6. Exercise its primary choices, Sources, Listen, Close/reopen, Escape and rapid selection.
5. Check 1280×720, 960×540 and 854×480. Confirm local scrolling and compact layouts. Physical tablet touch remains a separate device acceptance pass.
6. For future integration, instance the production scene under a sized Control/HotspotLayer, call `open_hotspot()` and resume the host on `closed`.

CLI launches and automated input checks do not substitute for researcher F6 acceptance. Browser export and physical-device acceptance were not performed; renderer/stretch settings were preserved.

## M–O. Diagnostics and limitations

**New implementation warnings/errors:** none in completed editor, integration, language-server and direct-launch checks. **Editor crashes:** none observed in this batch.

**Pre-existing environment diagnostic:** Godot reports `Failed to read the root certificate store` on startup, including baseline runs.

**Pre-existing EXT-01 content/test mismatch:** the current `ppc_ext_01.tres` omits `observation_labels` for Civic Setting and Government Today. Their schema defaults are empty. The unchanged regression expects three Civic Setting labels and one Government Today label, producing 30 `Exact observational labels` failures across its repeated interactions and sizes.

Git history establishes that commit `0c6cb47` removed those two packed-array assignments from the Resource. Original feature commit `7bf56a0` contained them. The reason for their removal is not established. The pre-change headless run and adapted run produce identical assertion counts/failures, and the rendered run reports the same 30 failures. No Resource content was restored or inferred, and no existing assertion was weakened.

## P–R. Scope, deferrals and recommendation

Modified tracked files:

```text
scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_01.gd
scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_02.gd
scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_02_canvas.gd
scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01.gd
scripts/landmarks/pangasinan_provincial_capitol/ppc_int_01_canvas.gd
scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02.gd
scripts/landmarks/pangasinan_provincial_capitol/ppc_int_02_canvas.gd
scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01.gd
scripts/landmarks/pangasinan_provincial_capitol/ppc_end_01_canvas.gd
```

New files:

```text
scripts/landmarks/pangasinan_provincial_capitol/ppc_editor_presentation.gd
scripts/landmarks/pangasinan_provincial_capitol/ppc_editor_presentation.gd.uid
tests/ppc_capitol_editor_test.gd
tests/ppc_capitol_editor_test.gd.uid
tests/ppc_capitol_editor_test.tscn
tests/ppc_capitol_integration_test.gd
tests/ppc_capitol_integration_test.gd.uid
docs/pangasinan_provincial_capitol_editor_visibility.md
```

The tracked diff is 879 insertions and 238 deletions across nine files; ordinary `git diff --stat` excludes the eight new untracked files. The baseline contains 798 pre-existing files. SHA-256 comparison finds exactly the nine scoped scripts changed; the other 789 files are byte-for-byte unchanged, including production/preview scenes, Resources, assets, existing tests, other landmarks and `project.godot`. `git diff --check` and an explicit whitespace check including new files pass. The index is empty.

No high-risk rewrite was required or deferred. The EXT-01 observation-label repair is a separate content task. The Capitol master environment and other landmark batches remain outside scope.

**Recommendation: safe to commit with documented limitation** for this isolated editor-visibility batch. The complete Capitol runtime gate remains red because of the pre-existing EXT-01 missing Resource data. Browser export and physical-touch acceptance remain unvalidated.

Nothing staged. No commit. No push. Stop after Provincial Capitol.
