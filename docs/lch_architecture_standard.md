# Limahong Channel architecture-standard batch

Validation date: 2026-10-05. Godot 4.7.2, GDScript, Compatibility renderer.

**Recommendation: ACCEPT WITH LIMITATIONS.** Six production scenes now contain their persistent visual hierarchy. EXT-03 deliberately retains its tested tactical runtime builder. Approved Resources, media, narration, interaction identities and previews are unchanged. This is a local, uncommitted batch awaiting researcher review.

## A. Preflight branch and status

- Branch: `feat/limahong-hotspot-standard`.
- Clean starting tree: zero staged, unstaged or untracked files.
- Starting HEAD: `190129dcc85ba204a7b17ea0cea77a57dbced8a3`, identical to `fix/editor-visible-hotspots`.
- Starting recent commits: `190129d` Provincial Capitol editor visibility; `a2ef807` Casa Real editor visibility; `f0a4298` Lingayen Church editor visibility.
- Initial `git diff --check` passed. HEAD and the index remain unchanged.
- The continuation resumed the existing migration at final validation; it did not restart or discard implementation work.

## B. Limahong inventory

Paths below are relative to `scenes/landmarks/limahong_channel/`. Every production scene has a sibling `<id>_preview.tscn`. Each controller is `scripts/landmarks/limahong_channel/<id>.gd`; its authoritative primary Resource is `data/landmarks/limahong_channel/<id>.tres`.

| Hotspot | Production scene | Interaction |
| --- | --- | --- |
| LCH-EXT-01 | `exterior/lch_ext_01.tscn` | Geographic orientation, historical qualification, site photographs |
| LCH-EXT-02 | `exterior/lch_ext_02.tscn` | Manila–Pangasinan route and settlement sequence |
| LCH-EXT-03 | `exterior/lch_ext_03.tscn` | Settlement, Blockade, Passage, Escape |
| LCH-INT-01 | `interior/lch_int_01.tscn` | Statue photograph and draggable magnifier |
| LCH-INT-02 | `interior/lch_int_02.tscn` | Three-person campaign diagram |
| LCH-INT-03 | `interior/lch_int_03.tscn` | Milestone, preservation and development views |
| LCH-END-01 | `summary/lch_end_01.tscn` | Optional five-topic summary and reflection |

Existing supporting Resources include EXT-01's introduction, qualification, locator and photograph entries; EXT-02/03 content types; INT-01 statue content; INT-02 person entries; INT-03 stage, media and facility entries; and END-01 topic entries. These were not rewritten. Existing assets and their imports remain in `assets/landmarks/limahong_channel/`. All seven matching narration OGG files remain assigned and usable, including the duplicate recordings explicitly authorized by the researcher.

Shared support remains the cross-landmark `ConferenceRoomInteraction` behavior, existing AKAR speaker icon, and Limahong header/Sources helpers. No cross-landmark shared file was edited.

## C. Complete changed-file inventory

Modified production scenes:

```text
scenes/landmarks/limahong_channel/exterior/lch_ext_01.tscn
scenes/landmarks/limahong_channel/exterior/lch_ext_02.tscn
scenes/landmarks/limahong_channel/interior/lch_int_01.tscn
scenes/landmarks/limahong_channel/interior/lch_int_02.tscn
scenes/landmarks/limahong_channel/interior/lch_int_03.tscn
scenes/landmarks/limahong_channel/summary/lch_end_01.tscn
```

Modified controllers/helpers:

```text
scripts/landmarks/limahong_channel/lch_ext_01.gd
scripts/landmarks/limahong_channel/lch_ext_02.gd
scripts/landmarks/limahong_channel/lch_ext_03.gd
scripts/landmarks/limahong_channel/lch_int_01.gd
scripts/landmarks/limahong_channel/lch_int_01_magnifier.gd
scripts/landmarks/limahong_channel/lch_int_02.gd
scripts/landmarks/limahong_channel/lch_int_03.gd
scripts/landmarks/limahong_channel/lch_end_01.gd
scripts/landmarks/limahong_channel/lch_header_utilities.gd
```

New files:

```text
scenes/landmarks/limahong_channel/interior/lch_int_03_facility_card.tscn
scripts/landmarks/limahong_channel/lch_lifecycle.gd
scripts/landmarks/limahong_channel/lch_lifecycle.gd.uid
tests/lch_architecture_test.gd
tests/lch_architecture_test.gd.uid
docs/lch_architecture_standard.md
```

Total: 15 modified tracked files and 6 new files. No asset, content Resource, preview, existing test, other-landmark file, shared cross-landmark component, or `project.godot` change.

## D–F. Per-hotspot architecture, authored structure and retained behavior

| Hotspot | Before | Persistent structure now | Runtime deliberately retained |
| --- | --- | --- | --- |
| EXT-01 | Inherited shell plus runtime reparenting/header and outgoing locator creation | Final header, visual/information columns, locator frame and both image layers, captions, qualification control, media navigation, section controls, margins and scroll regions; 58 scene node records | Locator progression, image fitting, zoom/fade cancellation, section/media selection, expanded note, focus and narration |
| EXT-02 | Inherited shell with runtime map, markers, timeline and header | Header, map region, map area, route/path/follower/ship nodes, destination markers, settlement nodes, information/timeline and navigation; 54 scene node records | Map-relative fitting, curve/line coordinates, route reveal, ship travel, destination fade/replacement, settlement shake, replay, breakpoint reparenting and interruption |
| INT-01 | Runtime photo explorer, magnifier and information controls | Explorer/photo frame, lens target, detail frame/texture, hint, information controls, header and scroll region; 49 scene node records | Circular lens drawing, same-photo atlas sampling, drag, keyboard movement, clamping, side switching, responsive correction and Sources interruption |
| INT-02 | Runtime diagram and portrait-card construction | Diagram, three portrait cards and labels, connection lines, campaign panel, information and utility header; 70 scene node records | Resource binding, selected styles, connection endpoints, triangle/row fitting, selection transitions and input |
| INT-03 | Runtime view/card/panel construction | Three view containers, photo regions, contributor card/details, preservation nodes/lines, development scroll/grid, information and utility controls; 80 root-scene node records plus facility-item descendants | Resource-dependent facility collection, responsive story geometry, view transition cancellation, contributor state, notice placement and scrolling |
| END-01 | Runtime summary shell and topic-card construction | Header, intro, five cards, information, reflection and scroll structures; 89 scene node records | NONE/default state, optional topic selection, compact 3+2 layout, connection/symbol drawing, emphasis and entrance transitions |
| EXT-03 | Inherited shell with tactical runtime builder | Existing production scene retained without a structural rewrite | Entire tested tactical builder, four blockade markers, cumulative layering, passage reveal, escape PathFollow movement, direct/replay/backward behavior and Sources interruption |

The header helper binds the authored `TitleArea`, `HeaderUtilityArea`, `HeaderActions` and `NarrationStatusSlot` in the six migrated scenes. Its construction fallback remains only for EXT-03. Utility state, responsive button styling and focus behavior remain shared.

INT-03's facility-card scene is used by its authored default slots. Runtime binding adds matching item instances for additional Resource entries and removes surplus slots; names and status text still come from facility Resources.

EXT-03's allocation fix only moves its initially unparented node allocations into `_ready()`. Comparing function bodies with HEAD confirms `_ready()` is the only changed existing function. The only added function is the reset wrapper. Tactical rendering, geometry, animation, cancellation and input functions are unchanged.

## G. Resource and content ownership

All existing `.tres` files and content scripts are unchanged. Runtime binding reads those Resources; historical paragraphs, citations, credits, qualifiers and transcripts were not copied into scenes as a second authority. Scenes contain neutral editor placeholders plus existing utility/static labels. Media and narration assignments are unchanged.

The architecture test snapshots exported Resource values before interaction and compares them after state changes, reset, close and reopen. All comparisons pass. Mutable selected-card styles are duplicated per instance rather than modifying the shared scene's style Resource.

## H. Public API and lifecycle helper

Every root exposes `open_interaction() -> bool`, `reset_interaction() -> void`, `close_interaction() -> void`, and inherited `opened` / `closed` signals. `closed` is the preferred host-facing closure notification. Existing selection methods, inherited APIs and signals remain available.

| Hotspot | Default after reset/reopen | Existing selection API |
| --- | --- | --- |
| EXT-01 | First section, Lingayen locator, first site photo, note collapsed | `select_concept`, `select_locator`, `change_media` |
| EXT-02 | Manila; route progress reset | `show_stage`, `select_concept` |
| EXT-03 | Settlement; later cumulative layers removed | `show_stage`, `select_concept` |
| INT-01 | Resource default section and lens position | `select_section`, `select_concept` |
| INT-02 | Resource default person, Salcedo in current content | `select_person`, `select_concept` |
| INT-03 | Milestone; contributor collapsed and scroll reset | `select_stage`, `select_concept`, `toggle_contributor` |
| END-01 | NONE; reflection remains available | `select_topic`, `select_concept` |

The existing `close_requested` compatibility signals on INT-01, INT-02, INT-03 and END-01 are preserved. Hosts should choose one closure notification, preferably `closed`, rather than handling both as separate closures.

`lch_lifecycle.gd` is a stateless `RefCounted` helper exposing `static reset(panel: ConferenceRoomInteraction) -> void`. All seven root wrappers call it. It:

1. Returns before readiness.
2. Records the open state, signal-blocking state and stored return-focus reference.
3. Temporarily blocks the panel's signals and invokes its existing close/open paths.
4. Closes again if it started closed, then restores the saved references/blocking state.

Reset therefore restores default state, stops narration and dismisses Sources. An open component remains open; a closed component remains closed. **Reset does not emit `closed`, `opened`, or the compatibility closure signal to the host.** It does not add gating, completion state or navigation ownership. Repeated open/close, active reset, closed reset and reuse pass for all seven. A reset may restart the component's ordinary default-state entrance animation.

The helper has no mutable global state, registry, autoload or reference to another hotspot. It couples callers only to their existing `ConferenceRoomInteraction` lifecycle contract; it introduces no shared visitor state across hotspots.

### INT-01 magnifier verification

The magnifier script now resolves its authored lens, detail frame, detail texture, fallback and hint with `@onready` references. `configure()` binds the photo, atlas behavior and input/draw/resize signals, including the existing accessible lens instruction. This prevents a second runtime-created lens/detail subtree after moving those nodes into the production scene.

Only `configure()` changed among its existing function bodies. Lens drawing, sampling, dragging, clamping, side switching, input and cleanup functions are unchanged. The 76 px lens, 96 px target, roughly 2× detail, no full-image zoom/pan, and absence of Examine/reset/zoom controls remain covered by 594 passing checks in both headless and native Compatibility runs.

## I. Preview/production separation

All seven previews remain unchanged test-only harnesses. They instance the production scene and offer an opener/backdrop; no preview supplies required content, repairs signals, or constructs production layout. None of the migrated production scenes references a preview. Generic-host testing instantiates production directly without any preview node.

## J. Environment independence

All roots remain parent-sized Controls. Ordinary full and 5% inset Control hosts pass without a player, avatar, trigger, collision system, landmark map or master environment. Controllers do not manipulate those systems or global Window settings. No master scene, new hotspot or integration gate was built.

## K. Visual editability

All six migrated saved scenes were rendered with their runtime scripts removed from the test instances before entering the tree. Their actual header, panels, cards, media regions and controls remain present. This confirms persistent authored nodes rather than a generated editor-only substitute.

The real `.tscn` hierarchy and native properties expose containers, anchors, margins, minimum sizes, stretch ratios, separations and scroll regions. Hidden alternative views can be selected in the scene tree. INT-01 retains one hidden inherited compatibility button; old inherited identifiers on some selectors remain to avoid changing the shared base controller.

No `@tool` presentation builder or second editor behavior was added. Neutral placeholders intentionally do not show the complete historical content or all media while scripts are disabled. Runtime geometry, the magnifier's drawn ring and dynamic symbols still require F6 to see their final appearance. Responsive calculations can override properties at their established breakpoints; those calculation rules remain in the controllers.

EXT-03's editor shows its inherited shell, not a fully authored tactical map. This is its explicit accepted exception, not a claim of full visual editability.

## L. Responsive inspection

| Viewport | Full host | 5% inset host | Rendered inspection |
| --- | --- | --- | --- |
| 1280×720 | All seven pass | All seven pass, 1152×648 content | All seven inset captures inspected |
| 960×540 | All seven pass | All seven pass, 864×486 content | All seven inset captures inspected |
| 854×480 | All seven pass | All seven pass, approximately 768.6×432 content | All seven inset captures inspected |

The native run generated 42 default-state screenshots. Headers and essential controls remain reachable, media retains aspect ratio, and longer interpretation uses existing scrolling. EXT-02/03 timeline placement, INT-02's compact row and END-01's 3+2 card arrangement remain distinct. END-01 retains its previously approved small compact typography; this migration does not redesign it. Resize while active and while transitions are interrupted passes.

## M. Runtime regressions after the EXT-03 allocation fix

| Suite | Result |
| --- | --- |
| `lch_ext_01_test.gd` | 0 failures; all three sizes |
| `lch_ext_02_test.gd` | 0 failures; all three sizes |
| `lch_ext_03_test.gd` | 0 failures headless and native Compatibility; all three sizes |
| `lch_int_01_test.gd` | 594 checks, 0 failures headless and native Compatibility |
| `lch_int_02_test.gd` | 2,663 checks, 0 failures |
| `lch_int_03_test.gd` | 1,859 checks, 0 failures |
| `lch_end_01_test.gd` | 4,865 checks, 0 failures |
| `lch_header_test.gd` | 3,461 checks, 0 failures |
| `lch_sources_test.gd` | 4,599 checks, 0 failures |
| `lch_architecture_test.gd` | 3,260 checks, 0 failures headless and native Compatibility |

Existing suites were not weakened or rewritten. They cover locator/photo states, route and settlement replay/interruption, all four tactical stages and cumulative layers, exactly four blockade markers, reported passage and PathFollow escape, magnifier interaction, person/heritage states, optional summary/reflection, mouse, keyboard, synthetic touch, Sources and narration. Physical touchscreen hardware and a browser export were not tested in this batch.

## N. Generic-host results

The new suite tests production independently in 42 host/size combinations. It verifies open/reset/close/reopen, harmless repeated close, default state, unchanged Resource values, stable node counts, Sources-first Escape hierarchy, mouse/touch Sources, keyboard Listen, actual assigned audio playback, stopped audio on close/reset, rapid selections and active resize. It also verifies no change to global Window dimensions or content scaling. All pass.

## O. Editor, save/reopen and serialization

Production scenes are instantiated with editor scene state without running `_ready()`. Authored descendants are owned nodes; engine-internal scrollbars are correctly excluded from that ownership requirement. Each production is packed, saved to an isolated temporary `.tscn`, reloaded and compared for matching node count. All seven round trips pass; no temporary editor-presentation branch is serialized.

Godot editor loading/import and direct scene-open smoke checks were also run. The saved-layout screenshots use the actual production scene nodes, with no runtime reconstruction. The scene save/reopen verification is programmatic Godot serialization, not a claim of manually clicking Save in the editor. Researcher F6 review remains the final visual approval step.

## P. Warnings, errors and crashes

- No native Godot crash, script parse error, missing required production Resource, or failing final assertion was observed.
- Godot reports failure to read the system root certificate store in this environment, also present in the starting baseline.
- Initial editor runs could not write normal user configuration/cache folders under the sandbox. Validation used a temporary self-contained copy of the existing Godot binary, without installing software or changing project settings.
- Optional `user://` profiler/cache access and native shader-cache creation warnings remain in this environment. Compatibility rendering completed successfully on Intel UHD Graphics/OpenGL 3.3.
- Early short editor smoke runs reported scan cancellation at intentional shutdown; longer confirmation runs allow editor layout loading to finish.
- INT-03's existing deliberate missing-image fixture emits its expected warning.
- Some individual test invocations report small ObjectDB teardown warnings (two instances in the final EXT-01 and END-01 logs; EXT-02 also reported three in an earlier invocation). These are reported rather than treating every harness as warning-free. The final combined architecture runs have no RID/ObjectDB leak warning after the EXT-03 allocation fix.

## Q. Pre-existing failures and validation corrections

No failing historical-content assertion or approved-content mismatch was found. EXT-01's initial baseline suite passed before migration. No content was changed to satisfy a test.

The new ownership assertion initially included Godot's private ScrollContainer children and was corrected to traverse non-internal children, consistent with serialization. The unparented EXT-03 allocations exposed by loading/freeing a scene outside the tree were fixed by moving construction into `_ready()`. Neither correction changes the tactical interaction or hides an application assertion failure.

## R–S. Architectural compromises and final classification

| Hotspot | Classification | Deliberate limit |
| --- | --- | --- |
| EXT-01 | **FULL STANDARD** | Image fitting, transitions and responsive overrides remain ordinary runtime behavior; editor text is neutral |
| EXT-02 | **STANDARD WITH DYNAMIC-GEOMETRY EXCEPTION** | Map fitting, route/path coordinates and responsive stage placement remain runtime |
| INT-01 | **STANDARD WITH DYNAMIC-GEOMETRY EXCEPTION** | Lens drawing/sampling/position and detail-side selection remain runtime |
| INT-02 | **STANDARD WITH DYNAMIC-GEOMETRY EXCEPTION** | Diagram arrangement and connection endpoints remain runtime |
| INT-03 | **STANDARD WITH DYNAMIC-GEOMETRY EXCEPTION** | Story geometry, data-dependent facilities, transition and scroll layout remain runtime |
| END-01 | **STANDARD WITH DYNAMIC-GEOMETRY EXCEPTION** | Topic positions, compact arrangement and custom symbols/connections remain runtime |
| EXT-03 | **ACCEPTABLE LEGACY SPECIAL CASE** | Tactical layout remains runtime-generated; editor representation is the inherited shell |

## T. Recommendation and teammate handoff

**ACCEPT WITH LIMITATIONS**, subject to researcher F6 review. The limits are the intentional EXT-03 exception, runtime geometry/responsive rules, neutral editor content, and the stated environment/test coverage limitations. No further architectural expansion is recommended in this batch.

For integration:

1. Choose a production path from section B; never instance a `_preview.tscn` as production.
2. Instance it below an ordinary sized Control owned by the future environment. The production root fills that parent.
3. After readiness, connect `closed` once to the host's resume/cleanup handler and call `open_interaction()`, checking its boolean result.
4. Use `reset_interaction()` to restore local defaults without notifying the host of closure. Use `close_interaction()` for an actual closure, then reuse with `open_interaction()`.
5. The environment owns triggers, avatar suspension, collision, host layering and navigation. The hotspot owns its UI, media, Sources, focus and local lifecycle.
6. Edit historical material in existing Resources, stable layout in the production scene, and dynamic geometry/interaction in its controller.

Suggested researcher check: open each production scene in the 2D editor, inspect actual nodes, then F6 its sibling preview at 1280×720, 960×540 and 854×480. Exercise each hotspot's distinct states, Listen, Sources/Escape, rapid changes, resize and reopen. For EXT-03, use F6 to inspect the tactical sequence; do not expect a fully authored tactical editor view.

Reproduce automated checks with Godot's `--headless --path . --script tests/lch_architecture_test.gd`. Omit `--headless`, select `--rendering-method gl_compatibility`, and append `-- --capture` for rendered architecture validation. Run the nine existing suites listed in section M for detailed interaction coverage.

Final scope: every changed/new repository file is inside the permitted Limahong scene/script/test/documentation paths. `project.godot`, all other landmarks, assets, historical Resources, previews and cross-landmark components are unchanged. Git index and HEAD are unchanged. Nothing was staged, committed, amended or pushed.
