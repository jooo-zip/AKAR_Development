# LCH-INT-02 — People Behind the 1575 Campaign

## Sources overlay finalized - 2026-10-01

This Sources-only revision supersedes older pending-reference/portrait-provenance
notes below. The header and narration assignments from the prior revision remain
unchanged. Visitor layout is **SOURCES**, **HISTORICAL REFERENCES**, then
**MEDIA CREDITS**, with fixed title/Close and an internally scrolling text region.
The Label-based overlay has no clickable-link support. Canonical historical URLs
are retained in the content Resource's `historical_source_urls` metadata; INT-02
portrait webpage URLs use each person Resource's `source_url` metadata.

### Historical References and canonical URLs

Sande, F. de. (1903).
Relation of the Filipinas Islands.
In E. H. Blair & J. A. Robertson (Eds. & Trans.),
The Philippine Islands, 1493–1803, Vol. 4, pp. 21–97.
Original work dated 1576.
Canonical URL: https://www.gutenberg.org/cache/epub/12635/pg12635-images.html

Shutz, J. T. (2019).
Limahong's Pirates, Ming Mariners, and Early Sino-Spanish Relations: The Pangasinan Campaign of 1575 and Global History from Below.
Philippine Studies: Historical and Ethnographic Viewpoints, 67(3–4), 315–342.
Canonical URL: https://doi.org/10.13185/2244-1638.1019

### Media Credits and provenance

OTHER INTERFACE MEDIA
AKAR-created personality-card framing, interface graphics, icons, decorative elements, and diagrams:
AKAR Project / AKAR Research Team.
Original project resources.

LAVEZARIS:
Kahimyang.
"Slavery Among the Natives according Guido de Lavezaris."
Canonical image-source URL: https://kahimyang.com/kauswagan/articles/1705/slavery-among-the-natives-according-guido-de-lavezaris

SALCEDO:
Jardin Solei / The Crafty Historian.
"The Love Story of Kandarapa and Juan de Salcedo: An Ill-Fated Romance."
June 7, 2020.
Canonical image-source URL: https://jardinsolei.wordpress.com/2020/06/07/the-love-story-of-kandarapa-and-juan-de-salcedo-an-ill-fated-romance/comment-page-1/

LIMAHONG:
Lingayen in Time, p. 5.
Scanned book copy used by the AKAR Research Team.

Citations identify supporting information or image provenance; they do not by
themselves establish ownership, license or permission. Only the researcher-supplied
AKAR-created/captured media is credited to the project. No new author, photographer,
license, permission, publisher or ownership was inferred. The internal validation
sheet is not listed as a visitor-facing historical reference.

### Sources verification

Sources passes at 1280x720, 960x540 and 854x480: bounded overlay, wrapped titles,
20 px compact / 22 px wide text, fixed reachable 48 px Close control, no horizontal
scrolling, internal mouse-wheel / synthetic-touch swipe / keyboard scrolling.
Tab stays within Sources; Home/PageDown/End work. Escape closes Sources first and
returns focus to its header button. Each selected hotspot state survives the round
trip; audio continues without changing stream or restarting. Source opening starts
at the historical references. Existing content, interactions and narration remain
unchanged. See [the complete Sources report](lch_sources_testing.md) for regression
totals, the full file inventory, repository preservation checks and F6 instructions.

Manual F6: open this hotspot's existing preview at all three target sizes, select a
non-default state, start Listen, open Sources, read/scroll to Media Credits, then
close with Escape or Close Sources. Check state/audio continuity and the unchanged
SOURCES / LISTEN / CLOSE header. No commit or push; researcher visual review pending.


## LIMAHONG SHARED HEADER STANDARD - 2026-09-30

LIMAHONG GLOBAL HEADER: title/context on the left; **SOURCES | LISTEN | CLOSE**
on the right. The shared speaker remains `res://assets/ui/icons/speaker.svg`.
All controls have matching heritage styling and 56 px (wide) / 48 px (compact)
heights. Narration status sits beneath HeaderActions with reserved geometry.

Current LCH-INT-02 narration is assigned through
`data/landmarks/limahong_channel/lch_int_02.tres` to
`res://assets/landmarks/limahong_channel/audio/lch_int_02_narration.ogg`.
**LISTEN is enabled and Narration pending is hidden.** Earlier pending-audio
notes in this document describe the previous milestone state. Generic null-audio
fallback remains tested: visible disabled LISTEN and right-aligned Narration pending.

The seven currently supplied Limahong narration files have identical binary
content. The researcher explicitly authorized their temporary use for their
respective hotspots. Replace the corresponding files later if distinct final
recordings are produced; each hotspot retains its own matching resource path.
No audio was copied, renamed, moved, or recreated during this revision.

The existing hotspot regression suite passes at 1280x720, 960x540, and 854x480.
The cross-hotspot `tests/lch_header_test.gd` covers layout, assigned OGG playback,
no autoplay, repeated Listen activation, state changes, Sources preservation,
mouse/keyboard/synthetic touch, Escape, close/reopen, and null-audio fallback.
Historical wording, sources, transcripts, media and content interactions are unchanged.

See [the complete header report](lch_header_testing.md) for all seven mappings,
file inventory, verification results, preserved Git state, and F6 review instructions.
F6 review: open this hotspot's existing preview, confirm SOURCES / LISTEN / CLOSE
at all three sizes, play narration, change content, open Sources, press Escape
twice, then reopen. Expect preserved state through Sources and stopped audio
after close/reopen. No commit or push; stop for researcher visual review.


Implemented 2026-09-23 for researcher F6/manual visual review. No commit or push.

## Targeted revision — portrait-only selection (2026-09-23)

Removed the redundant bottom LAVEZARIS / SALCEDO / LIMAHONG button row and its
container, spacing, button styles, signal connections, focus override, selection
array/synchronization, and unused `selector_label` resource fields. Portrait/person
cards are now the **sole direct person selectors**, including keyboard selection.
No replacement buttons, tabs, dropdown, or Previous/Next controls were added.

The existing expanding information scroll now reaches the panel bottom. Removing
the 48 px row and its container separation releases 60 px at the wide layout and
56 px at medium/compact sizes. No reserved row or empty spacer remains. At
960 × 540 the default Salcedo explanation and connection fit without scrolling;
longer content and the compact layout retain information-only scrolling.

Only these five existing INT-02 files were modified; no files were created:

```text
scripts/landmarks/limahong_channel/lch_int_02.gd
scripts/landmarks/limahong_channel/lch_int_02_person.gd
data/landmarks/limahong_channel/lch_int_02.tres
tests/lch_int_02_test.gd
docs/lch_int_02_testing.md
```

The .tres change removes only three obsolete selector-label assignments; all
historical wording, portrait references, Sources content, and audio data remain
unchanged. Card dimensions, selection/focus styling, animation, keyboard order,
Sources, narration, and reset behavior are preserved.

Fresh revision audit: **4 staged, 15 unstaged, 32 untracked files**, before and
after. All INT-02 files remain untracked pending milestone review; editing them
does not change these Git status counts. Baseline hashes cover 298 files; exactly
the five paths above changed, with the other **293 byte-identical**. Git index
entries and HEAD are unchanged. Audit files are under
`C:/Users/Admin/AppData/Local/Temp/akar-int02-portrait-only-20260923-223820/`.

Re-tested the real preview with native rendering at 1280 × 720, 960 × 540, and
854 × 480: **2663 checks, 0 failures**. Tests verify no information-panel selection
buttons or leftover bottom gap, whole-card touch outside the image, mouse/name
selection, one keyboard stop per person, arrows/Enter/Space, rapid switching,
Sources preservation, Escape hierarchy, narration, and close/reopen reset.
EXT-01, EXT-02, EXT-03, and INT-01 regression suites were rerun and passed.
`git diff --check`, cached diff checks, and changed-file whitespace checks passed.
No commit or push. Stopped for researcher F6 review.

## Scope and educational objective

An embedded, self-paced event-role explorer showing exactly Guido de Lavezaris,
Juan de Salcedo, and Limahong / Lin Feng. All three independently connect to the
permanent, passive **1575 PANGASINAN CAMPAIGN** event. Selecting a person compares
that person's role in the same campaign; it does not open a biography modal.

This supports the approved historical walkthrough scope. It introduces no game
mechanics, viewed/completed tracking, accounts, or claim of improved learning
effectiveness. INT-03, ENT-01, master/interior integration, and other hotspots
were not started or modified.

## Initial implementation audit and preservation

Read the root AGENTS.md and inspected EXT-01, EXT-02, EXT-03, INT-01, their
resources, previews, tests, and the shared ConferenceRoomInteraction shell.
Only the root AGENTS.md was found as applicable repository instructions.

Fresh audit before implementation: **4 staged files, 15 unstaged files, 17
untracked files**. Counts enumerate files, not Git's collapsed directories.
The three supplied INT-02 portraits were among the 17 untracked files.

Staged before (all additions):

```text
assets/landmarks/urduja_house/icons/summary_visitor_marker.png
assets/landmarks/urduja_house/icons/summary_visitor_marker.png.import
assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg
assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg.import
```

Unstaged before (all modifications):

```text
AGENTS.md
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_pangapisan_norte.png.import
data/landmarks/limahong_channel/lch_ext_01.tres
data/landmarks/limahong_channel/lch_ext_01_locator_channel.tres
data/landmarks/limahong_channel/lch_ext_01_locator_lingayen.tres
data/landmarks/limahong_channel/lch_ext_01_locator_pangapisan.tres
data/landmarks/urduja_house/uh_end_01.tres
data/landmarks/urduja_house/uh_int_03.tres
data/landmarks/urduja_house/uh_int_04.tres
docs/lch_ext_01_testing.md
project.godot
scenes/landmarks/limahong_channel/exterior/lch_ext_01.tscn
scripts/landmarks/limahong_channel/lch_ext_01.gd
tests/lch_ext_01_test.gd
```

Untracked before:

```text
assets/landmarks/limahong_channel/lch_ext_01/audio/lch_ext_01_narration.ogg
assets/landmarks/limahong_channel/lch_ext_01/audio/lch_ext_01_narration.ogg.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_location_marker.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_location_marker.png.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_movement_vessel.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_movement_vessel.png.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_route_ship.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_route_ship.png.import
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_settlement_icon.png
assets/landmarks/limahong_channel/lch_ext_01/icons/lch_ext_02_settlement_icon.png.import
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_marker.png
assets/landmarks/limahong_channel/lch_ext_01/images/lch_ext_01_marker.png.import
assets/landmarks/limahong_channel/lch_ext_01/maps/lch_ext_02_regional_map.png
assets/landmarks/limahong_channel/lch_ext_01/maps/lch_ext_02_regional_map.png.import
assets/landmarks/limahong_channel/lch_int_02/portraits/lch_int_02_lavezaris.png
assets/landmarks/limahong_channel/lch_int_02/portraits/lch_int_02_limahong.png
assets/landmarks/limahong_channel/lch_int_02/portraits/lch_int_02_salcedo.png
```

The baseline audit is stored locally at
`C:/Users/Admin/AppData/Local/Temp/akar-int02-audit-20260923-220306/`:
status-before.txt, status-all-before.txt, index-before.txt, head-before.txt,
hashes-before.json. All **283** pre-existing tracked and nonignored untracked
files were SHA-256 compared afterward: **zero changed or missing files**.
The complete `git ls-files --stage` listing matched the initial audit exactly.
HEAD remained `ec7d0ce1eee84e04d8795e551092f0d3855c6eae`.

Initial implementation final status: the same 4 staged and 15 unstaged files, with **32 untracked
files** (17 original + 15 created here). project.godot, the Urduja files,
EXT-01 working changes, and every unrelated asset remained byte-identical.
No staging, unstaging, reset, restore, commit, amend, or push was performed.
Ignored Godot import/editor caches are outside the source inventory.

## Complete INT-02 file inventory

Created for the initial implementation (15; no additional files in the revision):

```text
data/landmarks/limahong_channel/lch_int_02.tres
scenes/landmarks/limahong_channel/interior/lch_int_02.tscn
scenes/landmarks/limahong_channel/interior/lch_int_02_preview.tscn
scripts/landmarks/limahong_channel/lch_int_02.gd
scripts/landmarks/limahong_channel/lch_int_02.gd.uid
scripts/landmarks/limahong_channel/lch_int_02_content.gd
scripts/landmarks/limahong_channel/lch_int_02_content.gd.uid
scripts/landmarks/limahong_channel/lch_int_02_person.gd
scripts/landmarks/limahong_channel/lch_int_02_person.gd.uid
tests/lch_int_02_test.gd
tests/lch_int_02_test.gd.uid
docs/lch_int_02_testing.md
assets/landmarks/limahong_channel/lch_int_02/portraits/lch_int_02_lavezaris.png.import
assets/landmarks/limahong_channel/lch_int_02/portraits/lch_int_02_limahong.png.import
assets/landmarks/limahong_channel/lch_int_02/portraits/lch_int_02_salcedo.png.import
```

Existing files modified during the initial implementation: **none**. The targeted
revision modifies only the five INT-02 files listed above. Three supplied PNGs are
required by INT-02 and remain unchanged/untracked. Thus the complete future
milestone inventory is **18 paths**, including those PNGs. No commit is
authorized by this implementation request.

## Reused components

- Inherits `scenes/components/conference_room_interaction.tscn` and
  `scripts/components/conference_room_interaction.gd`; no shared files changed.
- Reuses the heritage palette, button/focus styles, header controls, embedded
  full-parent sizing, information scroll, Sources modal/focus trap, close and
  opener-focus behavior, and NarrationPlayer.
- Reuses the exact shared icon `assets/ui/icons/speaker.svg` in visible LISTEN.
- Follows INT-01's inset F6 preview and SceneTree/native-input test conventions.
- INT-02 content extends ConferenceRoomContent. Its three person subresources
  extend ConferenceRoomConceptEntry, reusing `heading`/`body` for name/main text.
  Historical prose, roles, connections, portraits, metadata, transcripts, and
  adjustable diagram anchors live in Resources.

## Historical wording and sources

Title: **PEOPLE BEHIND THE 1575 CAMPAIGN**.
Interaction prompt: **MEET THE PEOPLE CONNECTED WITH THE CAMPAIGN**.
Information prompt: **MEET THE PEOPLE**.
Event subtitle: **Different historical roles were connected to the same campaign.**
Connection heading: **CONNECTION TO THE 1575 CAMPAIGN**.

The resource stores the supplied wording verbatim:

| Person / role | Main body | Connection body |
| --- | --- | --- |
| GUIDO DE LAVEZARIS / EXPEDITION PREPARATION | Governor-General Guido de Lavezaris appointed Juan de Salcedo as master-of-camp and oversaw preparations for the expedition against Limahong. | His role was connected to organizing and preparing the expedition rather than leading it in the field. |
| JUAN DE SALCEDO / EXPEDITION LEADER | Juan de Salcedo led the Spanish and allied Luzonese expedition that blockaded Limahong's settlement in 1575. | He led the expedition in the field during the 1575 Pangasinan campaign. |
| LIMAHONG / LIN FENG / SETTLEMENT & ESCAPE | Limahong, also known as Lin Feng, was a Chinese pirate leader. After his failed attacks on Manila in late 1574, he sailed to Pangasinan and established a fortified settlement. | His settlement and escape in Pangasinan form the central historical narrative associated with the Limahong Channel. |

All three suggested narration transcripts are also stored verbatim in the
person resources; no generated recordings were added.

Sources uses only source categories already recorded in the project's Limahong
content: Francisco de Sande account; Project Historical Profile / Validation
Sheet; Provincial Government historical material. These are **source categories,
not complete verified bibliographic citations**. No separate validation-sheet
file or signed approval was found in this repository audit. No signed validator
approval is claimed. Full bibliographic details, page references, source links,
and validation-sheet identifier/date remain pending researcher submission.

Sources retains the qualification that the present channel is **traditionally
associated** with the escape narrative. It does not claim that archaeology has
proven the exact sixteenth-century channel. No new historical facts, image
attributions, or URLs were invented.

## Portrait audit

All three researcher-supplied PNGs were present before implementation and
visually inspected. They are used directly, unchanged, with no downloads,
generative editing, recoloring, or face reconstruction.

| Person | Exact project-relative path | Dimensions | Used image / fallback | Media type | Source / credit | Permission/license |
| --- | --- | --- | --- | --- | --- | --- |
| Limahong | assets/landmarks/limahong_channel/lch_int_02/portraits/lch_int_02_limahong.png | 1122 × 1402 | Supplied image; no active fallback | Pending | Pending researcher confirmation | Pending researcher confirmation |
| Salcedo | assets/landmarks/limahong_channel/lch_int_02/portraits/lch_int_02_salcedo.png | 1122 × 1402 | Supplied image; no active fallback | Pending | Pending researcher confirmation | Pending researcher confirmation |
| Lavezaris | assets/landmarks/limahong_channel/lch_int_02/portraits/lch_int_02_lavezaris.png | 1122 × 1402 | Supplied image; no active fallback | Pending | Pending researcher confirmation | Pending researcher confirmation |

“Supplied image” does not assert a contemporary/authentic historical likeness
or cleared reproduction rights. Optional media type, credit, source, and
permission fields remain empty until supplied. The card media label is hidden
when unspecified. Full selected-image metadata appears in Sources, with missing
fields explicitly marked pending. A null portrait produces the Godot label
`IMAGE SOURCE\nPENDING`; the whole card, line, and information remain functional.
Tests exercised all three null-image fallbacks on cloned in-memory resources.

## Diagram and responsive layout

Anchors are normalized center positions relative to RoleDiagram, bounded to
keep each element inside its parent. Person anchors are editable in the three
resource entries; event anchors are exported content-resource properties.
No global viewport coordinates are used.

| Element | Wide anchor | Medium anchor | Compact anchor |
| --- | --- | --- | --- |
| Lavezaris | (0.50, 0.22) | (0.50, 0.26) | (0.17, 0.31) |
| Salcedo | (0.19, 0.78) | (0.15, 0.73) | (0.50, 0.31) |
| Limahong | (0.81, 0.78) | (0.85, 0.73) | (0.83, 0.31) |
| Event | (0.50, 0.58) | (0.50, 0.71) | (0.50, 0.82) |

| Window | Actual inset component | Layout | Whole-card size | Portrait frame | Event size |
| --- | --- | --- | --- | --- | --- |
| 1280 × 720 | 1152 × 648 | Triangle, approximately 64% diagram / 36% information | 180 × 240 | 120 × 150 | 242 × 112 |
| 960 × 540 | 864 × 486 | Smaller triangle | 148 × 204 | 96 × 120 | 210 × 122 |
| 854 × 480 | 768.6 × 432 | Three-person row above event | 136 × 194 | 88 × 110 | 242 × 110 |

Layout thresholds use the actual component width: wide at >=1050 px, medium
at >=820 px, compact below that. The compact diagram stretch ratio is 1.55:1;
wide/medium use 1.78:1. Portraits use 4:5 covered aspect-ratio rendering with
linear texture filtering. All people remain visible and full-opacity at rest.
Only the information text scrolls; the title, selected name/role,
cards, and event remain visible. Event text uses containers to avoid title and
subtitle overlap. The shared header controls remain at least 48 px high.

Exactly three antialiased Line2D nodes independently connect the cards to the
event. No arrowheads, troop movement, chain of command, tactical map, or line
image assets. Compact connectors start at each card's bottom and end at distinct
points on the event's top, avoiding neighboring cards. Wide lower connectors
reach the event's lower edge. Inactive lines are 2 px subdued cream/brown at
0.5 alpha; the single selected line is 3.5 px muted gold at full alpha.

Neutral cards have a 1 px heritage border. Selection uses a 3 px muted-gold
border and a visible SELECTED text badge, plus the matching line.
Keyboard focus retains the shared bright focus outline, distinct from the
selection badge and muted border. Hover exposes no exclusive historical text.

## State, animation, input, and reset

`CampaignPerson { LAVEZARIS, SALCEDO, LIMAHONG }` defines navigation order.
`current_person` is authoritative; the shared shell's `_selected` is a rendered
mirror. Default SALCEDO is an initial UI choice, not a ranking. Every person
input calls `select_person`, synchronizing the card, line,
name, role, main body, connection, and narration target. Repeated selection of
the current person cannot toggle off the card or restart narration.

Selection first kills the previous tween and normalizes all cards/lines.
Only the newly selected card animates from scale 0.97 to 1, opacity 0.85 to 1,
and neutral to gold border in **200 ms**. Its line gains width/opacity in
**300 ms** with restrained sine ease-out. No loop, bounce, pulse, or game effect.
The optional comparison hint fades in 200 ms after the first meaningful change.
Rapid changes, Sources opening, resizing, hiding, closing, and freeing cancel
the active selection tween and restore stable transforms. The hint tween is
killed on close/free. There are no deferred selection callbacks.

- Mouse: entire portrait cards (including their name labels), Sources, Close, preview
  opener, and an assigned Listen stream were exercised through native events.
- Synthetic touch: all cards, including role labels below/outside the portrait
  image, Sources/open/close, hotspot Close,
  and an assigned Listen stream were exercised through InputEventScreenTouch.
- Keyboard: portrait cards are the sole direct person selectors, with exactly
  one focus stop per person. Tab/Shift+Tab, nonwrapping left/right in resource order, Enter,
  Space, Sources focus trapping, and Escape hierarchy passed.
- Sources: preserves the selected person/card/line/content and current
  narration state. It shows selected-image metadata/pending status. Escape
  closes Sources first; the next Escape closes the hotspot.
- Narration: no INT-02 audio files were found. LISTEN remains visible, disabled,
  with Narration pending. Each person has its own optional AudioStream and
  transcript. New selection stops prior narration and never autoplays. Tests
  used temporary in-memory silent WAV streams to verify available-audio cases;
  no test audio is saved or attached to content, and no Urduja audio is used.
- Close/reopen: cancels tweens, stops narration, closes Sources, restores opener
  focus, then reopens on SALCEDO with matching content/line/card, clean
  transforms, and initial hint. Minimal close_requested/person_changed signals
  supplement the inherited shell signals; there is no completion signal.

Future recordings can be assigned in the matching person resource. Requested
candidate paths, all currently absent:

```text
assets/landmarks/limahong_channel/lch_int_02/audio/lch_int_02_lavezaris_narration.ogg
assets/landmarks/limahong_channel/lch_int_02/audio/lch_int_02_salcedo_narration.ogg
assets/landmarks/limahong_channel/lch_int_02/audio/lch_int_02_limahong_narration.ogg
```

## Automated and rendered verification

Engine: Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility/OpenGL 3.3 on
Intel UHD Graphics. Tested the real preview/component at a 90% inset, not a
substitute test UI. Final revised native INT-02 run: **2663 checks, 0 failures**.

| Suite | Result |
| --- | --- |
| LCH-INT-02 native rendered, 1280 × 720 | Pass: triangle, portrait-only selection, expanded text area without row gap, whole-card inputs, Sources, reset |
| LCH-INT-02 native rendered, 960 × 540 | Pass: smaller triangle, default Salcedo text fits without scrolling, whole-card inputs/reset |
| LCH-INT-02 native rendered, 854 × 480 | Pass: compact row/event, more visible information text, whole-card touch targets, scroll/reset |
| LCH-EXT-01 existing headless suite | 0 failures at all three sizes |
| LCH-EXT-02 existing headless suite | 0 failures at all three sizes |
| LCH-EXT-03 existing headless suite | 0 failures at all three sizes |
| LCH-INT-01 existing headless suite | 594 checks, 0 failures at all three sizes |
| Initial headless editor import / script scan | Exit 0; .uid/.import metadata generated during initial implementation |
| git diff --check / git diff --cached --check | Pass |
| INT-02 file whitespace checks | Pass without staging files |

INT-02 assertions include exact historical wording, default state, all three
portrait-card controls, absence of information-panel buttons and reserved space,
whole-card touch outside the image, native same-person reselection, independent lines,
200/300 ms timing, both requested rapid sequences, cancellation, noncolor
selection cues, input focus, no autoplay, per-person audio switching, missing
images/metadata, text reachability, and deterministic reopen.

Native screenshots for default and all three selected people at each size,
plus compact missing-image fallback, were saved under the local temp directory
as `lch-int-02-<width>x<height>-default.png`, `-person0.png`, `-person1.png`,
`-person2.png`, and `lch-int-02-854x480-fallback.png`. Rendered inspection covered
all three layouts, longer selected content, portrait proportions, and fallback.
The initial implementation's event-text container layout and boundary assertions
remain unchanged in this targeted revision.

No GDScript parser or interaction runtime errors occurred in the final run.
Godot reported a Windows root-certificate-store startup error in this local
environment; no network/content lookup was needed. The unchanged EXT-01 and
EXT-02 suites reported two and three ObjectDB instances leaked at exit respectively, despite zero
test failures. These existing-suite teardown warnings were not changed by this
INT-02-only task. INT-02, EXT-03, and INT-01 had no leak warning in these runs.

Browser export and physical touchscreen testing were not performed. Synthetic
touch is verified in the native Godot runtime. Researcher F6/manual visual
approval remains pending.

Reproduce from the repository using the installed Godot console executable:

```powershell
$godotExe = 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe'
& $godotExe --path . --script res://tests/lch_int_02_test.gd -- --capture
& $godotExe --headless --path . --script res://tests/lch_ext_01_test.gd
& $godotExe --headless --path . --script res://tests/lch_ext_02_test.gd
& $godotExe --headless --path . --script res://tests/lch_ext_03_test.gd
& $godotExe --headless --path . --script res://tests/lch_int_01_test.gd
git diff --check
```

For sandboxed runs, APPDATA/LOCALAPPDATA were redirected to task-specific temp
directories so Godot could write its logs. No project setting was changed.

## Researcher F6 checklist and outstanding items

1. Open `scenes/landmarks/limahong_channel/interior/lch_int_02_preview.tscn`
   and press F6. Activate the People Behind the 1575 Campaign opener.
2. Confirm all three portraits and the passive campaign event are visible;
   Salcedo is initially selected with matching text, line, and card indicator.
3. Select every portrait card, including its name/role area outside the image.
   Confirm no bottom selector row remains. Compare the three roles. Repeatedly tap the
   selected person; it must remain selected. Watch the brief card/line emphasis.
4. Switch Salcedo → Limahong → Lavezaris → Salcedo → Limahong rapidly, then
   Lavezaris → Limahong → Salcedo. Confirm exactly one selected card/badge/line
   and no residual scale, faded card, or stale text.
5. Tab and Shift+Tab through the cards and shared controls. Use left/right at
   both endpoints, Enter, and Space. Distinguish focus outline from selection.
6. On Limahong, open Sources, inspect the pending image metadata, then close
   Sources. Confirm the same content/selection remains. Escape closes Sources
   before the hotspot. LISTEN must remain visible and disabled while pending.
7. Close during an animation and reopen using mouse/keyboard. Confirm Salcedo,
   stopped audio, closed Sources, reset hint, and stable card/line transforms.
8. Review at 1280 × 720, 960 × 540, and 854 × 480. The first two are triangular;
   the last uses a row above the event. Read full names/roles, inspect connectors
   and portraits, and scroll the information area to each connection body.
   Confirm the freed bottom space belongs to the text area and all card surfaces
   remain comfortable touch targets.
9. Confirm portrait media types, creators/credits, original sources, and
   reproduction permission/license status for all three images. Supply the
   missing historical bibliography/pages/links and validation-sheet identifier.
10. Supply the three approved narration recordings when available. Browser and
    physical-touch verification can follow with researcher review/integration.

Stop here for researcher review. No commit, push, INT-03, ENT-01, or master scene.
