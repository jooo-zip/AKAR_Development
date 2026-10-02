# Lingayen Church editor-visible production components

Branch: `fix/editor-visible-hotspots`. Scope: Lingayen Church only. Godot 4.7.2, Compatibility renderer.

## A–B. Inventory and architecture families

Repository inventory found six production scenes and six matching preview harnesses; no additional implemented Church hotspots.

Scene paths below are relative to `res://scenes/landmarks/lingayen_church/`. Every production scene has a sibling named `<id>_preview.tscn`. Every controller is `res://scripts/landmarks/lingayen_church/<id>.gd`; its authoritative resource is `res://data/landmarks/lingayen_church/<id>.tres`.

| Production integration target | Family / runtime interaction | Resource schema and entries | Generated presentation |
| --- | --- | --- | --- |
| `exterior/lc_ext_01.tscn` | Orientation tabs | `lc_ext_01_content.gd`, `lc_ext_01_section.gd` | Media/caption, formal name, tabs, takeaway, credits, header |
| `exterior/lc_ext_02.tscn` | Image-relative tower observations | `lc_ext_02_content.gd`, `lc_ext_02_observation.gd` | Tower viewer, three markers/legend, focus region, detail photograph, text and header |
| `exterior/lc_ext_03.tscn` | Bell evidence/story points, observations, comparison, documentary modal | `lc_ext_03_content.gd`, `lc_ext_03_story_point.gd` | Media layers, story selectors, evidence cards, comparison controls, documentary overlay, header |
| `interior/lc_int_01.tscn` | Four-person portrait selection | `lc_int_01_content.gd`, `lc_int_01_person_content.gd` | Portrait wall, person detail, historical anchor strip, header |
| `interior/lc_int_02.tscn` | Eight-point chronology and optional transformation reveals | `lc_int_02_content.gd`, `lc_int_02_milestone_content.gd` | Time window, diagram, date controls, era strip, interpretation, header |
| `interior/lc_end_01.tscn` | Four-theme summary/reflection | `lc_end_01_content.gd`, `lc_end_01_theme_content.gd` | Meaning map, connecting lines, central media/context, interpretation/synthesis, header |

All six inherit `scenes/components/conference_room_interaction.tscn` and `scripts/components/conference_room_interaction.gd`. Their schemas derive from the existing conference-room resource types. All use `lc_header_utilities.gd`. The portrait, timeline, and summary families additionally use `lc_int_01_person_card.gd`, `lc_int_02_timeline_point.gd`, and `lc_end_01_theme_card.gd` respectively. Preview harnesses retain their existing `lc_ext_01_preview.gd` window-sizing adapter and open/close wiring.

Before this batch, the five remaining production scenes exposed the inherited blank/default shell in the editor. Their `_ready()` methods generated the visitor layout only at runtime, and open/selection methods populated resource text and media. The approved LC_EXT_01 pilot already had a separate editor path.

## C–F. Scope and representative states

Modified controllers: LC_EXT_02, LC_EXT_03, LC_INT_01, LC_INT_02, LC_END_01. Each now has an explicit guarded editor path and a **Refresh Editor Preview** inspector action.

LC_EXT_01 is unchanged because its approved pilot already satisfies the goal. Production and preview scenes, all content/resource schemas, media, shared base component, header/narration utility, project settings, and other landmarks are unchanged.

New Church-only shared file: `scripts/landmarks/lingayen_church/lc_editor_presentation.gd`. The three presentation-only controls listed above receive `@tool`; their existing rendering/layout behavior is unchanged. New tests are `tests/lc_church_editor_test.gd` with its `.tscn` fixture and `tests/lc_church_integration_test.gd`.

| Hotspot | Representative editor state |
| --- | --- |
| LC_EXT_01 | Existing ABOUT tab, church photograph and formal name |
| LC_EXT_02 | OVERVIEW: tower photograph, three unselected markers/legend, overview interpretation |
| LC_EXT_03 | OVERVIEW: bell display photograph, three story points, overview interpretation; comparison and documentary modal closed |
| LC_INT_01 | NONE: four supplied portraits and parish overview, neutral historical anchors |
| LC_INT_02 | NONE: church overview photograph, eight dates and four eras; no selected milestone or animated reveal |
| LC_END_01 | NONE: four unselected themes, central church image/context, overview/synthesis and reflection prompt |

The timeline intentionally retains its established runtime overview instead of selecting the first milestone. All editor views show Sources, idle Listen availability, Close, and the existing captions/credits where applicable. Existing compact reading areas remain scrollable at runtime; the static editor view shows their initial scroll position.

## G–H. Implementation and runtime boundary

The shared helper creates a temporary base-shell instance, removes its script and audio player before attaching it, copies the production panel styles, and binds the controller's visual references to that temporary shell. It recursively clears ownership and disables input/focus, including internal scrollbars. A stable branch name allows refresh after script reload without accumulating branches.

Each controller reuses its existing layout builders. Visual node allocation now occurs when building that presentation, avoiding orphan controls from merely loading a tool script. Small controller-specific adapters select the established overview and apply resource content. The interior/summary controllers extract their existing text/media application from runtime selection into a pure presentation method. No historical text is copied into scenes or new resource files.

Runtime initialization still calls the unchanged base initialization, builds the same layout against `self`, and retains narration, input, focus, transitions, responsive calculations and signals. Editor initialization skips that runtime path completely. Runtime entry points are guarded; editor construction never calls open/reset, audio initialization, animation or focus routines. Only visual layout/drawing connections are made on the temporary branch. No player, collisions, environment, navigation, analytics, timers or video behavior is added.

Generated editor nodes have no owner and are excluded from packed/saved scenes. Refresh does not hide, reparent or modify the original authored nodes. Resources remain authoritative and are never written. After editing a nested resource in the inspector, use **Refresh Editor Preview** to refresh its representative state.

## I. Integration readiness

All six production targets passed independent child-instantiation under a generic `CanvasLayer/Control` host at 1280×720, 960×540 and 854×480. The test uses a larger viewport and an inset parent to verify that the component follows its parent dimensions.

| Hotspot | Public host entry | Existing close notification | Result |
| --- | --- | --- | --- |
| LC_EXT_01 | `open_hotspot()` | `closed`, `hotspot_closed` | Pass |
| LC_EXT_02 | `open_hotspot()` | `closed`, `hotspot_closed` | Pass |
| LC_EXT_03 | `open_hotspot()` | `closed`, `hotspot_closed` | Pass |
| LC_INT_01 | `open_hotspot()` | `closed`, `close_requested` | Pass |
| LC_INT_02 | `open_hotspot()` | `closed`, `close_requested` | Pass |
| LC_END_01 | `open_hotspot()` | `closed`, `close_requested` | Pass |

All retain `opened`, `open_interaction()`, `close_interaction()`, and existing hotspot-specific selection signals/methods. The host only needs the production scene and public API/signals. It owns triggers, visitor movement suspension and post-close actions. The component waits hidden for the host to open it; direct standalone production runs retain their existing automatic opening behavior. There are no production-to-preview dependencies or environment-specific paths.

Integrate the **production `.tscn`** listed above under the future host's sized Control/HotspotLayer. The matching `_preview.tscn` is only an isolated F6 harness. No Church environment or trigger placement was built in this batch.

## J–K. Verification

Run from the repository root, using the installed Godot 4.7.2 executable:

```powershell
& $godot --headless --editor --path . --import --quit
& $godot --headless --editor --path . res://tests/lc_church_editor_test.tscn -- --church-editor-test
& $godot --editor --rendering-method gl_compatibility --path . res://tests/lc_church_editor_test.tscn -- --church-editor-test --capture
& $godot --headless --editor --path . res://tests/lc_ext_01_editor_test.tscn -- --lc-editor-test
& $godot --headless --path . --script res://tests/lc_church_integration_test.gd
& $godot --headless --path . --script res://tests/lc_ext_01_test.gd
& $godot --headless --path . --script res://tests/lc_ext_02_test.gd
& $godot --headless --path . --script res://tests/lc_ext_03_test.gd
& $godot --headless --path . --script res://tests/lc_int_01_test.gd
& $godot --headless --path . --script res://tests/lc_int_02_test.gd
& $godot --headless --path . --script res://tests/lc_end_01_test.gd
& $godot --rendering-method gl_compatibility --path . --script res://tests/lc_header_narration_test.gd -- --capture
git diff --check
```

The editor fixture is inert without its explicit test flag. It checks three construction cycles, three sizes and repeated refreshes, script reload, authored scene snapshots, TEMP-only save/reinstantiation, actual production scene opening/reload in the 2D editor, absent input/audio/tweens/runtime signals, idle header state, content and geometry. Captures and roundtrip files go to TEMP, not production assets.

Executed results:

| Validation | Result |
| --- | --- |
| Five-hotspot headless editor test | 50,875 checks, zero failures |
| Five-hotspot Compatibility editor test, actual scene reloads and captures | 50,895 checks, zero failures |
| Unchanged LC_EXT_01 editor regression | 3,388 checks, zero failures |
| LC_EXT_01 / LC_EXT_02 / LC_EXT_03 runtime suites | Zero failures at all three sizes |
| LC_INT_01 runtime | 5,065 checks, zero failures |
| LC_INT_02 runtime | 7,459 checks, zero failures |
| LC_END_01 runtime | 4,471 checks, zero failures |
| Six-hotspot header/narration | 1,887 headless / 1,923 Compatibility-rendered checks, zero failures |
| Independent production integration | 138 checks, zero failures |
| Twelve direct production/preview CLI launches | Exit 0; no warning/error output |

The existing runtime tests exercise selections, Sources, narration, close/reopen, repeated opening, keyboard/back hierarchy and responsive geometry. CLI scene launches are F6-equivalent launches; they are not a claim of manually pressing F6. Visual inspection covers the generated editor views and Compatibility captures.

Manual reviewer pass: open each production `.tscn` in 2D, select the root, refresh repeatedly, close/reopen its tab, and confirm the listed default view. Save and check that no generated branch appears in the scene diff. Run the sibling preview with F6, open it, visit its normal interaction states, test Sources/Listen/Close and Escape, then reopen. Repeat at the three landscape sizes. Use production scenes for integration.

Web export is not validated: the repository has no export preset and the installed 4.7.2 web export template is absent. Compatibility desktop rendering was validated; project renderer/stretch settings were not changed.

## L–O. Diagnostics, scope and commit recommendation

Godot 4.7.2 language-server diagnostics were collected for all Church scripts and both new test scripts. Zero new GDScript warnings or errors. Four existing warnings were confirmed by analyzing the corresponding HEAD source in the language server: LC_INT_01 integer division; LC_END_01 a `theme` parameter shadowing `Control.theme` and two mixed numeric ternary warnings. They remain outside this editor-visibility change.

The implementation modifies five controllers and adds `@tool` to three presentation-only controls; it adds one Church-only helper, two tests, the editor fixture, their generated script UIDs, and this documentation. Hash comparisons confirm no changes to tracked scenes, resources, assets, project settings, LC_EXT_01, shared base/header utility, or other landmarks. `git diff --check` passes.

Final resumed-state verification confirmed all five adapted controllers are present in both `git status --short` and `git diff --name-only`. There are **eight modified tracked files and eight new untracked files**. The tracked diff is **912 insertions and 330 deletions**; ordinary `git diff --stat` excludes the new files until staged. Nothing is staged.

Complete modified-file manifest:

```text
scripts/landmarks/lingayen_church/lc_ext_02.gd
scripts/landmarks/lingayen_church/lc_ext_03.gd
scripts/landmarks/lingayen_church/lc_int_01.gd
scripts/landmarks/lingayen_church/lc_int_02.gd
scripts/landmarks/lingayen_church/lc_end_01.gd
scripts/landmarks/lingayen_church/lc_int_01_person_card.gd
scripts/landmarks/lingayen_church/lc_int_02_timeline_point.gd
scripts/landmarks/lingayen_church/lc_end_01_theme_card.gd
```

Complete new-file manifest:

```text
scripts/landmarks/lingayen_church/lc_editor_presentation.gd
scripts/landmarks/lingayen_church/lc_editor_presentation.gd.uid
tests/lc_church_editor_test.gd
tests/lc_church_editor_test.gd.uid
tests/lc_church_editor_test.tscn
tests/lc_church_integration_test.gd
tests/lc_church_integration_test.gd.uid
docs/lingayen_church_editor_visibility.md
```

On resuming after the usage-limit interruption, the saved test logs, diagnostics and baseline hashes were inspected again. The successful Compatibility editor run includes the final test-harness capture adjustment. The earlier language-server pass covered 26 Church/test scripts and established the four pre-existing warnings against HEAD; an optional repeat language-server launch was not executed when approval review hit the usage limit. No implementation was restarted or changed during final handoff verification, and only this documentation was updated. Existing passing suites were not rerun unnecessarily.

No hotspot required a high-risk rewrite or was deferred. The complete Church batch is recommended as safe to commit based on the recorded verification, with browser export remaining unverified as noted above. No commit, staging or push is performed by this task.
