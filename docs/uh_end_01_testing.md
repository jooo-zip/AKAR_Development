# UH-END-01 — Single-Summary Viewer correction

## Files modified
- scenes/components/historical_summary_interaction.tscn
- scripts/components/historical_summary_interaction.gd
- docs/specifications/urduja_house/uh_end_01.md
- docs/uh_end_01_testing.md
- scenes/landmarks/urduja_house/summary/uh_end_01.tscn

Added assets/ui/icons/summary_visitor_marker.png as a byte-identical copy of the supplied
landmark icon. Godot generated import sidecars for the source and copied marker.
Content .tres, resource scripts, five summary icons, previous hotspots and application
files retain their pre-correction contents. The preview disables DevelopmentNote autowrap.
project.godot was already modified before this correction; it is preserved byte-for-byte.

## Final interface
Header/Close and short introduction remain.
SelectedPanel now shows a 200px-wide visual area on the left and a locally scrollable
24px heading/22px explanation on the right. Only one summary is visible.
Nearest filtering and aspect-fit preserve all five supplied icons without stretching,
cropping or replacement. At tested sizes square icon rendering spans about 128–200px.
The fifth icon remains the supplied opaque JPG; no transparency has been fabricated.

The five large cards and 3+2 grid are removed. Below the content:
- 60×60 < and > buttons, accessible names Previous summary / Next summary.
- One line with exactly five numbered circular, directly selectable points: 54px circles within 64×64 touch areas.
- 56×56 supplied visitor image above the selected point.
- Always-available RETURN TO LANDMARK MAP.

Previous from first wraps to fifth; Next from fifth wraps to first.
Direct points jump to any entry. No autoplay or dragging. No viewed/completed state.
Gold fill and stronger point border indicate selection; focus has its own outline.

## Supplied marker and shimmer
Exact asset: res://assets/ui/icons/summary_visitor_marker.png.
The source was supplied under assets/landmarks/urduja_house/icons/ and copied without
changing its bytes. No artwork was generated or edited. The drawn placeholder and
its draw connection were removed.

VisitorMarker is a nearest-filtered, aspect-fit 56×56 TextureRect. An AtlasTexture
uses the image's nontransparent region so surrounding empty padding does not shrink
the person. The visible character remains about 56px high above the point.
The original 200ms gently eased slide and resize alignment remain unchanged.

A changed selection starts one 350ms muted gold shimmer. A short, low-opacity glint
travels the selected segment alongside the marker, then fades to zero after arrival.
It uses a Tween and three layered line strokes, no shaders or particles.
Same-point taps do not restart it. Rapid selection replaces the effect; resize,
close and removal clear it. No sound, loop, completion meaning or reward effects.

DevelopmentNote uses explicit line breaks with autowrap OFF in the preview.
The component's wrapping labels have a positive 1px custom minimum width while
Containers still assign their actual readable widths. This removes the autowrap
configuration-warning condition without fixing layout to viewport dimensions.

## Preserved behavior
Default is Established in 1953. All historical data and icons are unchanged.
Return consumes input and emits return_to_map_requested, without scene navigation.
The existing preview only shows DEVELOPMENT ONLY - Return to map requested.
Return works immediately, without inspecting other entries.
Close/Escape/Backspace hide and emit closed, not Return. Focus restores to Open summary.
No narration, speaker, transcript, progress, completion markers, quizzes or game mechanics.
Public methods/signals and resource structure remain unchanged.

## Exact content
Title: What Urduja House Represents
Introduction: A quick look back at what you explored.
Return label: RETURN TO LANDMARK MAP
Default: Established in 1953.

### 1. Established in 1953
Urduja House was constructed as the official residence of the Governor of Pangasinan.

Icon: res://assets/landmarks/urduja_house/icons/uh_end_01_established_icon.png

Accessibility: Pixel-art building icon representing the establishment of Urduja House.

### 2. Named for Princess Urduja
Its original name, Princess Urduja Palace, reflects the cultural importance of the legendary warrior figure associated with Pangasinan.

Icon: res://assets/landmarks/urduja_house/icons/uh_end_01_urduja_icon.png

Accessibility: Pixel-art cultural icon representing Princess Urduja.

### 3. A Changing Government Function
The building served as both residence and office until the daily Governor’s Office moved to the Provincial Capitol in 2007.

Icon: res://assets/landmarks/urduja_house/icons/uh_end_01_changing_function_icon.png

Accessibility: Pixel-art time and transition icon representing the changing government function of Urduja House.

### 4. Continuing Official Role
Urduja House remains the governor’s official residence, while the Ceremonial Hall is used for selected official events.

Icon: res://assets/landmarks/urduja_house/icons/uh_end_01_official_role_icon.png

Accessibility: Pixel-art official-function icon representing the continuing government role of Urduja House.

### 5. Cultural and Architectural Identity
Its Balinese-inspired character and association with Princess Urduja contribute to its distinctive place in Pangasinan’s heritage.

Icon: res://assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.jpg

Accessibility: Pixel-art architectural icon representing the cultural and architectural identity of Urduja House.


## Exact F6 retesting
1. Open the repository project in Godot 4.7.2 and allow imports to finish.
2. Open res://scenes/landmarks/urduja_house/summary/uh_end_01.tscn.
3. Press F6. Established opens automatically inside the inset SummaryFrame.
4. Confirm no five-card grid remains. A large icon is left; only its heading/body are
   right; arrows, five points, visitor image and Return are visible.
5. Press Return immediately. Only the development request status appears; no navigation.
6. From summary 1, click < and confirm summary 5; click > and confirm summary 1.
7. Tap each point 1–5 directly. Match icon/title/body against the exact entries above.
8. Inspect selected point and marker: marker rests above its center without hiding the
   number or target. Movement is subtle and never settles between points.
9. Rapidly alternate arrows and points; last selection wins with matching content,
   full opacity and no duplicate controls.
10. Use Tab/Shift+Tab across arrows, points, Return, text scroll and Close.
    Enter/Space activate. Escape and Backspace close safely, restore prompt focus,
    and do not emit a Return request. Open summary resets to entry 1.
11. Test actual touch activation of arrows, every point, Return and Close. No hover
    or dragging should be required.
12. Repeat at 1280×720, 960×540 and 854×480 using run-window sizing controls.
    Do not save project-setting changes.
13. For full-size comparison, in the Remote scene tree select
    UH_END_01_Preview/SummaryFrame; set Left/Top anchors to 0 and Right/Bottom to 1,
    with offsets 0. Restore 0.05/0.05/0.95/0.95 for inset testing. Remote edits are
    not saved. The external development status can overlay the full-size comparison.
14. Resize while the marker is moving; it must realign to the current point.
15. Repeat Close/reopen and Return requests. Check no stuck focus, stale content,
    duplicate UI, audio, completion states or Godot errors.

At each size check visible image quality, proportional scaling, readable text with
local scrolling where needed, all controls in the parent, and no overlap/clipping.
Confirm the visitor and soft gold glint remain restrained navigation feedback.

## Validation
Godot 4.7.2 headless runtime validation passed:
- 1280×720 full-size and 1152×648 inset parent.
- 960×540 full-size and 864×486 inset parent.
- 854×480 full-size and 768.6×432 inset parent.
- Smallest inset selected-panel/text height: 128px; icon area width 200px.
- Exact text/icon/alt mapping, one active point, no grid, nearest/aspect-fit.
- Both arrow wraps, direct points, 64px point targets and 60px arrows, keyboard and synthetic touch reopen.
- 56px marker alignment, unobscured points, rapid mixed input and resize realignment.
- Return immediately/repeatedly, separate Close/back, focus restoration and safe
  parent removal using deferred freeing.

Headless checks do not replace rendered visual inspection or physical device testing.
The supplied visitor sprite is installed; no placeholder code remains.
Resource and whitespace checks passed, including git diff --check.
Git status still includes the pre-existing project.godot modification and untracked
UH-END-01 files/assets/specification/sidecars. No new project serialization occurred.
No commit or push.


## Final marker/shimmer correction checks
- In the editor, inspect the preview and component: no configuration warnings,
  particularly on DevelopmentNote and wrapping labels.
- F6 defaults to marker above point 1; no opening shimmer.
- Use <, > and direct points: marker/image/text stay synchronized.
- During a change, a faint gold glint travels the relevant track segment and fully
  disappears after approximately 350ms. Marker arrival remains approximately 200ms.
- Tap the current point: no new shimmer. Rapidly mix arrows and points: only the
  latest effect remains, ending at the latest requested point.
- Resize during movement: marker realigns and transient shimmer clears.
- Close/reopen: no residual glint, default summary 1. Return behavior remains unchanged.
- Repeat full-size and inset tests at 1280×720, 960×540 and 854×480.
- Confirm marker texture, nearest/aspect-fit, and appearance on a physical display.

Final automated checks: Godot 4.7.2 headless import/runtime passed, zero test failures.
Verified exact asset, nonempty texture region, silent initial track, shimmer opacity
and lifecycle, same-point behavior, cancellation, marker alignment, resize, keyboard,
Return/back, label warning conditions and all six full-size/inset layout combinations.
Headless validation does not establish the rendered shimmer's subjective appearance;
use F6 to assess its visual subtlety. The editor import log reported no errors.


## Museum-touchscreen sizing correction
Only the component scene/script, this guide and the specification's sizing values changed.
No historical data, preview wrapper, navigation logic, Return behavior, media or earlier
hotspots changed. project.godot retains its pre-existing modification byte-for-byte.

Final sizes:
- VisitorMarker: noninteractive 56×56 TextureRect. Aspect-fit region preserves the
  sprite proportions, approximately 56px visible height, with nearest filtering.
- Numbered points: 64×64 hit areas; circular styles inset 5px on every side produce
  54×54 visible circles. Numbers use centered 24px text; selected gold/border and
  keyboard focus remain intact.
- Previous/Next: 60×60 buttons with centered 28px < / > glyphs; unchanged accessible names.
- Return and Close: unchanged.

The track height increases from 88 to 124px. End padding increases from 24 to 32px
so the whole 64px hit area fits at both endpoints. Marker occupies y=0..56;
point hit areas start at y=60, leaving a 4px hit-area gap (9px to the inset visible
circle). Track centerline and shimmer run at y=92. Arrows align toward the bottom
of the row beside the points. Existing 12px outer margins and 16px horizontal
navigation spacing are unchanged. No touch target is reduced at smaller sizes.
Only the height required by the larger controls is taken from the flexible content area;
the smallest inset text area remains 528×128 with local scrolling.

Retest with F6 using the existing preview instructions:
- Confirm the visitor is clear at normal tablet viewing distance, proportionate and
  neutral rather than oversized or game-like.
- Tap all five numbered circles and the outer margins of their hit areas.
- Confirm < and > are comfortable to tap and still wrap first/last.
- Confirm no overlap among marker, points, line, arrows and Return.
- Rapidly alternate < / >, then rapidly tap points: final marker and content agree.
- Confirm the original 200ms movement and 350ms low-opacity shimmer remain intact.
- Resize during movement; marker must realign and shimmer clear.
- Repeat at 1280×720, 960×540 and 854×480, full-size and inset parents.
- Verify keyboard/focus/back and Return request behavior as before.

Godot 4.7.2 headless regression passed with zero failures at all six size/frame
combinations. Checks include exact marker/arrow/hit-area sizes, 54px style bounds,
even spacing and non-overlap, marker centering, shimmer lifecycle, rapid mixed input,
all direct selections, wraps, keyboard, resize, Return and unchanged historical text.
Full-size text heights: 416 / 236 / 176px; inset text heights: 344 / 182 / 128px.
Physical viewing-distance readability and rendered appearance remain F6/manual checks.
git diff --check and separate modified-file whitespace checks passed. Git status
was reviewed; no commit or push.
