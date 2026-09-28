# PPC-EXT-01 — Meet the Pangasinan Provincial Capitol

Implemented and revised after researcher F6 review on 28 September 2026. Standalone exterior orientation, ready for another researcher F6 review. Only PPC-EXT-01 is implemented. No Capitol master layout or PPC-EXT-02 work. Nothing staged or committed.

## Purpose and research alignment

Second F6 revision: remove the redundant VIEW LARGER button and use the documentary image itself as the authoritative Explore View control. Only `ppc_ext_01.gd`, `ppc_ext_01_test.gd` and this document change in this pass. The image is keyboard focusable, opens with Enter/Space and receives focus when Explore View closes. All three states use the same interaction. The captions, copy, observation aids, source attribution, audio and modal/reset behavior are preserved.

The researcher requested a small revision after F6: observe first, read second. That first F6 pass changed the PPC interaction script, its view Resource script, its `.tres`, its dedicated test and this document. The original shell, header controls, production/preview scenes, project settings, media, narration, source attribution and completed landmarks are preserved. Shorter supplied copy creates breathing room without reducing the established body font sizes. Visual aids and optional enlargement support observation within the same introductory historical scope.

Introduce the Capitol's identity, civic setting and continuing provincial-government role through three parallel contextual views and one optional narration. This supports the approved multimedia historical-walkthrough scope and self-paced museum use. It introduces no progression or mandatory completion. No claim of improved learning effectiveness is made; the study evaluates acceptability, selected software-quality characteristics, and educational value separately.

Historical basis is the researcher-supplied milestone copy and its identified references:

1. **AKAR Historical Information Validation Sheet — Pangasinan Provincial Capitol**: executive and legislative functions of the Provincial Government of Pangasinan.
2. **Historical Profile of Pangasinan Provincial Capitol**: identity, Lingayen location, continuing government role, government-complex setting, gardens, lawns, approaches and tree-lined avenues.

These references are attributed as supplied. No additional dates, history, bibliography, page numbers, permissions or web-derived claims were invented. The untracked `docs/references/lingayen_church/` files are unrelated and preserved.

## Files and reuse

New implementation files:

- `scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01.tscn`
- `scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01_preview.tscn`
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_01.gd`
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_01_view.gd`
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_01_preview.gd`
- `data/landmarks/pangasinan_provincial_capitol/ppc_ext_01.tres`
- `tests/ppc_ext_01_test.gd`
- `docs/ppc_ext_01_testing.md`

Generated metadata files (keep with the milestone when eventually approved for commit):

- `scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_01.gd.uid`
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_01_view.gd.uid`
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_01_preview.gd.uid`
- `tests/ppc_ext_01_test.gd.uid`
- `assets/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01/ppc_ext_01_capitol_present.JPG.import`
- `assets/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01/ppc_ext_01_civic_setting.png.import`
- `assets/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01/ppc_ext_01_government_today.jpeg.import`
- `assets/landmarks/pangasinan_provincial_capitol/audio/ppc_ext_01_narration.ogg.import`

Reused without modification:

- `scenes/components/conference_room_interaction.tscn`: heritage theme, selectors, main reading area, Sources overlay, audio player and controls.
- `scripts/components/conference_room_interaction.gd`: common signals, audio toggle/stop, Escape hierarchy, source closing, close lifecycle and return focus.
- `scripts/components/conference_room_content.gd`: title, prompt (subtitle here), concepts, narration, transcript and historical sources. Resource metadata `audio_credit` stores the supplied audio provenance.
- `scripts/components/conference_room_concept_entry.gd`: heading/body base for the small PPC view record.
- `assets/ui/icons/speaker.svg`: existing speaker icon and its existing `.import` sidecar.

The base Resources lack per-view image, caption, context, takeaway and permission fields, so `ppc_ext_01_view.gd` adds only those fields and view/selector identifiers. No new top-level content Resource class or shared component change is needed. All historical copy and provenance live in the `.tres`. Production contains only presentation and interaction logic. The preview sits beside production, following the established landmark convention, and instances that production scene directly.

## Exact visitor-facing copy

Title: **MEET THE PANGASINAN PROVINCIAL CAPITOL** (explicit line break after PANGASINAN).

Subtitle: **LINGAYEN, PANGASINAN**.

Header controls: **SOURCES | LISTEN | CLOSE**. While narration plays, LISTEN becomes STOP. Audio fallback: **Narration pending.**

The visible **HISTORICAL TAKEAWAY** heading is removed. Each state retains one short, warm-gold takeaway below its two-sentence body. Existing body font sizes remain 20 px at full size and 18 px at compact sizes.

### capitol — THE CAPITOL (default)

Context: **SEAT OF PROVINCIAL GOVERNMENT**

Heading: **The Pangasinan Provincial Capitol**

Body: The Pangasinan Provincial Capitol is the seat of the Provincial Government of Pangasinan. Located in Lingayen, it continues to serve as an active center of provincial governance.

Takeaway: A historic landmark that remains a working government center.

Caption: Present-day view of the Pangasinan Provincial Capitol, Lingayen.

### civic_setting — CIVIC SETTING

Context: **WITHIN THE GOVERNMENT COMPLEX**

Heading: **A Landmark Framed by Its Setting**

Body: The Capitol stands within a spacious government complex near Lingayen Gulf. Formal gardens, lawns, paved approaches, and tree-lined avenues frame the building.

Takeaway: Its setting strengthens its role as a civic landmark.

Caption: The Capitol within its formal government-complex setting in Lingayen.

### government_today — GOVERNMENT TODAY

Context: **CONTINUING CIVIC ROLE**

Heading: **A Working Seat of Provincial Government**

Body: The Capitol continues to serve the Provincial Government of Pangasinan while preserving its historical character. It remains both a heritage landmark and an active government building.

Takeaway: Its history and government function continue today.

Caption: The Pangasinan Provincial Capitol remains an active provincial government center.

## Documentary media and permissions

Exact existing paths, including case-sensitive extensions:

| Asset | Repository path | Credit/status |
| --- | --- | --- |
| Capitol | `assets/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01/ppc_ext_01_capitol_present.JPG` | Photographer/creator: AKAR Team. Source: AKAR Research Team. Research-team-produced documentary photograph. |
| Civic setting | `assets/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01/ppc_ext_01_civic_setting.png` | Official Province of Pangasinan website, The Province → History. Permission/reuse status: **Not separately confirmed / pending documentation.** |
| Government today | `assets/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01/ppc_ext_01_government_today.jpeg` | Photographer/creator: AKAR Team. Source: AKAR Research Team. Research-team-produced documentary photograph. |
| Narration | `assets/landmarks/pangasinan_provincial_capitol/audio/ppc_ext_01_narration.ogg` | Narration production: AKAR Team. Imported successfully; used as the sole hotspot-level audio stream. |

No source media was duplicated, generated, altered, stretched or recolored. Aspect-fit preserves the complete supplied photograph. Letterboxing is intentional, particularly for the wide civic-setting photograph. No architectural markers or reconstructed details are present. Linear filtering is local to documentary photographs; global nearest filtering for pixel art is preserved.

The official website attribution does not assert reuse permission. No Creative Commons license, copyright holder or permission letter is claimed. Reuse documentation remains outstanding. All four original media file hashes are preserved.

## Narration

Exact transcript:

> Welcome to the Pangasinan Provincial Capitol in Lingayen. The Capitol is the building where the executive and legislative functions of the Provincial Government of Pangasinan are carried out. It stands within a spacious government complex near Lingayen Gulf, framed by formal gardens, open lawns, paved approaches, and tree-lined avenues. More than a historic landmark, the Capitol continues to serve as a center of provincial governance today. Explore the views to learn about the building, its civic setting, and its continuing role.

No autoplay. LISTEN starts at zero; STOP stops and resets. Selecting views and opening/closing Sources or Explore View preserve playback. The original supplied narration and transcript are unchanged by this copy revision. Closing, reset, host hide and tree exit stop audio. Reopening starts stopped at zero. If no imported narration stream is available, LISTEN stays visible and disabled with “Narration pending.” No substitute audio is used. Automated tests verify the actual imported OGG, playback position and start-signal count; listening to its audible quality and transcript match remains part of researcher review.

## Interaction, animation and focus

`select_view(view_id)` is authoritative. Initialization, reset, inherited button activation and selector arrow navigation all route through it. Views are parallel and directly accessible in any order. Re-selecting the current view keeps it selected; invalid identifiers are ignored.

State copy, caption, image and selected styling update synchronously. A 200 ms outgoing-photo opacity fade reveals the newest image underneath. Replaced Tweens are killed and their old layer is cleared. No delayed callback changes the selected view or content. No movement, scale pop or looping effect is used. Rapid interrupted sequences ending in `capitol` settle on the default image and copy at full opacity.

- **Touch:** all selectors and header controls are native full-rectangle Buttons with 56 px minimum height; Close Sources is also 56 px. One tap activates. No hover, double-tap or long-press requirement. Compact reading and Sources use local ScrollContainers.
- **Mouse:** click follows the same Button signals. Hover changes appearance only.
- **Keyboard:** Tab / Shift+Tab cycle THE CAPITOL → CIVIC SETTING → GOVERNMENT TODAY → IMAGE → SOURCES → LISTEN → CLOSE → information scroll → THE CAPITOL. Disabled audio is skipped. Enter and Space activate. Left/Right act only in the selector group and clamp at its ends. Focus outline differs from muted-gold selected fill.
- **Escape/go_back:** the PPC handler obtains the viewport and marks input handled before closing anything. Sources closes first, then Explore View, then the hotspot. Closing the hotspot returns focus to the preview launcher.

Sources has one authoritative opener in the header. Its opaque full-panel overlay blocks pointers and background state/audio commands. Focus is trapped in Close Sources and its local scroll. It displays the supplied historical references, three documentary-media credits and permission statuses, then audio attribution. Opening Sources settles any photo transition without changing the selected view or narration. Closing it restores opener focus and the same interpretation. Sources never changes the interpretation's scroll position.

Closing immediately resets `capitol`, default photo/text, local scroll positions, Sources and Explore View visibility, narration position/pause state, active Tweens, outgoing/enlarged-image textures, observation labels/focus frame, opacity and scale. A later open focuses THE CAPITOL. Parent hide also closes and clears activity. The production component emits shared `opened`/`closed` signals for a future host.

## Responsive validation

### Guided observation and Explore View

- **THE CAPITOL:** a static, one-pixel, translucent muted-gold frame emphasizes the central building region. It follows normalized coordinates in the aspect-fitted photograph, so it stays aligned through resizing. It identifies no architectural parts and has no interaction or animation.
- **CIVIC SETTING:** exactly three passive labels beneath the photograph: **CAPITOL**, **FORMAL APPROACH**, **LANDSCAPED GROUNDS**. They use 16 px text, padded transparent containers and natural wrapping at compact sizes. Positioning them outside the photograph avoids obscuring the building or grounds. They are not focusable, do not handle input and open no cards.
- **GOVERNMENT TODAY:** one passive **ACTIVE GOVERNMENT CENTER** line sits immediately below the photograph in muted gold. There is no badge, status animation or notification behavior.

The entire documentary image is the sole control for opening Explore View in all three states. Tap or click anywhere within its large photo area, or focus it and press Enter / Space. It occupies the keyboard stop immediately before Sources. The former VIEW LARGER button is removed entirely. A pointer cursor and thin, transparent hover outline indicate interaction; keyboard focus retains the shared heritage focus outline. No suitable shared magnify/enlarge icon was found in the existing assets, so no icon was added or created. The original captions remain exact, without instructional additions.

One reusable `ExploreView` PanelContainer displays the selected photograph, its existing caption and **CLOSE VIEW**. Aspect-fit preserves the entire photograph. The near-opaque heritage backdrop dims and blocks the underlying hotspot. The enlarged view intentionally leaves the photograph free of observation overlays to maximize usable photo area. It has no pan, pinch, wheel zoom, carousel or extra controls.

Both opening and closing use 200 ms opacity fades. The modal remains blocking through its closing fade. Repeated open calls are ignored while visible; repeated close calls are ignored while closing. Opening cancels a pending photo transition, and closing cancels an incomplete opening fade. Reset kills the modal Tween, hides the modal, clears its image/caption and restores opacity. No old callback can reopen or change the selected view.

Explore View preserves primary selection, reading position and narration. Underlying selectors, Sources and narration controls are blocked while it is visible. Sources likewise prevents opening Explore View, ensuring one modal at a time. Programmatic host close/reset remains available and clears everything immediately.

Opening Explore View moves focus to its 56 px **CLOSE VIEW** control. Tab and Shift+Tab remain there. Closing returns focus to the **image** after the fade. Escape closes Sources first if present, otherwise Explore View, otherwise the hotspot. A second Escape during the closing fade continues to target Explore View and does not unexpectedly close the hotspot.

The F6 host temporarily sets its own canvas scale size to zero so window resizing exercises real logical dimensions, then restores the prior policy on exit. Production never changes the host canvas policy or `project.godot`. Compatibility, canvas_items, expand and global nearest filtering remain intact. Preview frame uses the established five-percent inset.

| Landscape viewport | Inset component | Photo/information widths | Information viewport | Result |
| --- | --- | --- | --- | --- |
| 1280 × 720 | 1152 × 648 | ~59% / 41% | 448 × 424 | Pass: all three interpretations and takeaways fit without scrolling; horizontal selectors and header controls. |
| 960 × 540 | 864 × 486 | ~55% / 45% | 372 × 298 | Pass: tighter margins/gaps, 18 px body text, 56 px controls, local scrolling. |
| 854 × 480 | 768.6 × 432 | ~55% / 45% | 329 × 244 | Pass: wrapped title, 18 px body text, 56 px controls, local scrolling, side-by-side media/information. |

Revision validation includes all three normal states and their enlarged views at each size. Labels stay at 16 px rather than shrinking; they wrap into two lines on compact screens. The unchanged caption now uses the full width beneath the image/observation labels; removing the separate button frees space for the photograph. The normal photo remains a large touch target, and each aspect-fitted enlarged photograph is at least 25% larger than its normal display. The full-size concise text fits without scrolling; compact text scrolls only when its content exceeds the available area, and the complete takeaway is reachable in every state. No labels cover documentary content.

No portrait layout is added. Global rotate-device handling remains future host work.

## Automated results and regression

Godot 4.7.2, Compatibility renderer:

- Headless editor import/parse: passed.
- Dedicated PPC-EXT-01 suite: **2,487 checks, zero failures, exit 0**.
- Rendered Compatibility suite with viewport captures: **2,514 checks, zero failures, exit 0**.
- Exact approved copy and transcript, one selected state, synchronized image/caption/context/heading/body/takeaway, superseded-Tween cancellation, mouse/touch events, Enter/Space/Tab/Shift+Tab/arrows, source modality and Escape hierarchy all covered.
- Actual narration path, no autoplay, uninterrupted state/source playback, closing/reopening reset, missing-stream fallback, host hide and canvas restoration covered.
- Full-size text fit, compact scrollability, control bounds, focus/selected style distinction and all three viewport geometries covered.

Revision tests additionally verify the exact observation labels, removal of the takeaway heading, complete takeaway reachability, absence of any VIEW LARGER button, mouse/touch activation of the photo in every state, Enter/Space activation of the focused image in every state, current enlarged image, at least 25% actual image enlargement, modal blocking, focus trapping/restoration, continued narration, one reusable overlay, interrupted open/close fades and host reset/hide. Earlier state-switching and Sources coverage remains. Final runs have zero PPC-specific failures.

Existing regression suites, unchanged:

| Suite | Result |
| --- | --- |
| CR-EXT-01 | 1,983 checks; zero failures; exit 0 |
| CR-EXT-02 | 1,897 checks; zero failures; exit 0 |
| CR-EXT-03 | 5,431 checks; zero failures; exit 0 |
| CR-INT-03 | 3,853 checks; zero failures; exit 0 |
| LC-EXT-01 | Zero failures; exit 0 |
| LCH-EXT-01 | Zero failures; exit 0; existing two-ObjectDB-instance exit warning |
| LCH-EXT-02 | Zero failures; exit 0; prior F6 revision reported three ObjectDB instances at exit; latest image-control revision has no such warning |
| LCH-EXT-03 | Zero failures; exit 0 |

Environment diagnostic: `Failed to read the root certificate store` appears at Godot startup, including the unchanged suites. It is separate from scene/script/test failures. No shared or completed-landmark file was changed to address unrelated diagnostics.

The recorded Limahong exit warnings belong to unchanged regression suites; PPC-EXT-01 reports no leak warning.

The image-control revision passed all eight regression suites again. An initial headless PPC run reached shutdown before stopped OGG playback was released by the audio mixer. The test now waits 200 ms after freeing the preview so asynchronous audio teardown completes. The final verbose headless run has zero failures and no audio-resource/leak warning; production narration code is unchanged.

Historical-safety tests compare exact supplied copy and reject later-hotspot topics: construction/inauguration chronology, property area, named architects/governors, Ionic/Neoclassical interpretation, wartime destruction, reconstruction/rehabilitation, cultural-treasure/ordinance claims, biographies and interior-room interpretation. No game progression, scores, rewards, accounts, prerequisites, locks or required completion is implemented. There is no analytics collection or CMS.

## Reproduce

From the repository root in PowerShell:

```powershell
$godot = 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = Join-Path $env:TEMP 'akar_ppc_ext_01_runtime\roaming'
$env:LOCALAPPDATA = Join-Path $env:TEMP 'akar_ppc_ext_01_runtime\local'
& $godot --headless --editor --path . --import --quit
& $godot --headless --path . --script res://tests/ppc_ext_01_test.gd
& $godot --path . --rendering-method gl_compatibility --script res://tests/ppc_ext_01_test.gd -- --capture
foreach ($id in @('cr_ext_01', 'cr_ext_02', 'cr_ext_03', 'cr_int_03', 'lc_ext_01', 'lch_ext_01', 'lch_ext_02', 'lch_ext_03')) {
    & $godot --headless --path . --script "res://tests/${id}_test.gd"
}
git diff --check
git status --short
```

Captures: `%TEMP%/ppc_ext_01_{1280,960,854}_{capitol,civic_setting,government_today,sources}.png` plus each state's `_explore.png` capture. Latest logs: `%TEMP%/ppc_image_control_headless.log`, `%TEMP%/ppc_image_control_render.log`, `%TEMP%/ppc_image_control_render_errors.log`, `%TEMP%/ppc_image_control_import.log`, `%TEMP%/ppc_image_control_regression_*.log`. Isolated process-local app-data paths preserve the researcher's usual Godot user data.

## Researcher F6 gate and outstanding work

Latest revision review: at each target size and in all three states, confirm there is no VIEW LARGER button, click/tap the photograph, then close Explore View. Tab to the image after GOVERNMENT TODAY; test Enter and Space, Escape and restored image focus. Check the subtle hover outline and pointer cursor. Confirm the unchanged Capitol caption remains “Present-day view of the Pangasinan Provincial Capitol, Lingayen.” with no appended instructions. Continue checking narration continuity and close/reopen reset. Stop for researcher review; no commit is authorized.

1. Open `scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01_preview.tscn` and press **F6**. The real production component opens on THE CAPITOL without audio.
2. Review every view at 1280 × 720, 960 × 540 and 854 × 480. Check documentary framing, selected/focus distinction, title wrapping, complete takeaways through local scrolling and caption readability.
3. Tap/click in any order, reselect the current view, then rapidly select THE CAPITOL → CIVIC SETTING → GOVERNMENT TODAY → THE CAPITOL. Confirm the last view wins and the restrained crossfade settles.
4. Test Tab / Shift+Tab, Enter / Space and clamped Left/Right. Focus the reading scroll to navigate its overflow with keyboard. Verify Sources traps focus; Escape closes Sources before the hotspot.
5. Start LISTEN and hear the supplied OGG. Change all views and open/close Sources while it plays. Confirm no restart. Test STOP, restart, CLOSE and reopening from the large launcher.
6. Scroll the information/Sources panels, close during activity, and reopen. Confirm default image/copy, top scroll, closed overlay and stopped narration at the beginning.
7. Check physical tablet/phone touch scrolling, browser audio and visual readability on deployment hardware. Automated synthetic touch events do not certify physical-device/browser behavior.
8. Record documentation for civic-setting photograph reuse permission. No permission is currently asserted.

Revision-specific review: check the shorter exact copy and absence of the takeaway heading. Review the whole-landmark frame and passive observation labels. Tap/click the photo in every state; verify the current photograph enlarges without distortion. Use CLOSE VIEW and Escape while narration plays. Try repeated opening/closing and closing during the opening fade. Confirm focus returns to the image, underlying selectors/Sources stay blocked, and closing/reopening the hotspot always returns to normal THE CAPITOL. Inspect phone-size photo visibility, wrapping and actual physical touch operation in the next F6/device review.

Researcher visual/audio/content approval and physical-device review remain outstanding. Automated captures are implementation QA, not researcher approval.

**STOP at RESEARCHER F6 REVIEW. No commit until the researcher explicitly sends: `PPC-EXT-01 — APPROVED FOR MILESTONE COMMIT ✅`.**

## Repository safety audit

Second F6 revision baseline: 658 existing tracked/untracked files; no staged files. Only the interaction script, dedicated test and this document changed. No new files were added. The other 655 baseline files, including the existing `project.godot` change, content Resource, supplied assets, scenes, shared components and metadata, remain unchanged. The short Git status is unchanged because the PPC implementation is still untracked. Nothing staged or committed.

Latest `git diff --check`: passed, exit 0. Separate whitespace checks of the three untracked revised files also emitted no diagnostics.

First F6 revision baseline: 658 existing tracked/untracked files, no staged changes, and the same pre-existing modified `project.godot`. Only these five permitted files changed:

- `scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_01.gd`
- `scripts/landmarks/pangasinan_provincial_capitol/ppc_ext_01_view.gd`
- `data/landmarks/pangasinan_provincial_capitol/ppc_ext_01.tres`
- `tests/ppc_ext_01_test.gd`
- `docs/ppc_ext_01_testing.md`

No new files or assets were added during the first F6 revision. All other baseline files, including original media, shared components, completed hotspots, scenes, UID/import metadata and project settings, retain their hashes. The short status below is unchanged because these PPC files remain untracked from the original implementation. No staging, commit or push.

Revision `git diff --check` passed (exit 0); separate checks of the five untracked revised files emitted no whitespace diagnostics. The initial implementation audit below is retained for provenance.

Before implementation: no staged files; `project.godot` unstaged; Capitol media and `docs/references/` untracked. SHA-256 baseline recorded for all 642 existing tracked/untracked files. All are unchanged after implementation. No completed hotspot, shared component, supplied media or project setting was rewritten. No staging, commit or push was performed.

`git diff --check`: passed (exit 0). All 16 new untracked milestone files were checked separately with `git diff --no-index --check` because ordinary diff does not inspect untracked files. No whitespace diagnostics were emitted; no-index exit 1 indicates the new file differs from the empty input.

Final short status:

```text
 M project.godot
?? assets/landmarks/pangasinan_provincial_capitol/
?? data/landmarks/pangasinan_provincial_capitol/
?? docs/ppc_ext_01_testing.md
?? docs/references/
?? scenes/landmarks/pangasinan_provincial_capitol/
?? scripts/landmarks/pangasinan_provincial_capitol/
?? tests/ppc_ext_01_test.gd
?? tests/ppc_ext_01_test.gd.uid
```
