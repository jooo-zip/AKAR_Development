# UH-INT-01 correction testing

This corrects the existing standalone InteractiveArtworkViewer. No lobby, master
scene, navigation, analytics, completion tracking, or other milestone is added.
The specification's UX sections are amended by explicit researcher instruction;
its educational purpose, historical sections, transcript, and credits are unchanged.

## Changed files

- `scenes/components/interactive_artwork_viewer.tscn`
- `scripts/components/interactive_artwork_viewer.gd`
- `scripts/components/interactive_artwork_content.gd`
- `data/landmarks/urduja_house/uh_int_01.tres`
- `scenes/landmarks/urduja_house/interior/uh_int_01.tscn`
- `docs/specifications/urduja_house/uh_int_01.md`
- `docs/uh_int_01_testing.md`

New icon: `assets/ui/icons/speaker.svg` and its Godot-generated `.import` file.
No second component, new script, cropped image file, or audio file is created.
AGENTS.md and project.godot had existing local changes before this correction;
those changes are preserved rather than attributed to this milestone.

## Artwork modes and crops

Full Artwork opens selected, using the existing contrasting gold pressed style.
A ButtonGroup prevents deselecting the active mode through repeated activation.
Only Full Artwork or Inspect Artwork is selected at a time. Returning from
inspection selects and focuses Full Artwork again.

The existing Detail overlay now presents Inspect Artwork. Internal node names
and `show_detail_view()` / `close_detail_view()` remain for compatibility.
`artwork_view_changed` now reports `full` or `inspect`.

The overlay contains a crop viewport, four region buttons in two rows, a neutral
Viewing label, the currently selected educational heading and scrollable body,
Sources, and Back to Full Artwork. Educational wording is read from the same
content resource. Region selection never changes the learning section or its
scroll position. Returning to Full Artwork and changing a section preserves the
last crop when inspection is reopened. Closing the whole viewer resets its next
opening to the first section and region.

Only this approved source painting is used:
`res://assets/landmarks/urduja_house/interior/uh_int_01_princess_urduja_painting.jpg`

It is 364 × 442 pixels. Full Artwork preserves the entire image, fitting at no
more than native size and 360 logical pixels high. Each inspection region is a
runtime AtlasTexture referencing that same texture. Normalized rectangles live
in the content resource; they are spatial interaction choices, not historical
interpretations:

| Exact label | x | y | width | height |
| --- | --- | --- | --- | --- |
| Central Figure | 0.28 | 0.08 | 0.48 | 0.84 |
| Left-side Scene | 0 | 0.12 | 0.36 | 0.88 |
| Right-side Scene | 0.64 | 0.12 | 0.36 | 0.88 |
| Lower Details | 0 | 0.67 | 1 | 0.33 |

Crops preserve aspect ratio and fit the available viewport at no more than 1.25×
the crop's native dimensions. No arbitrary zoom, new artwork, object descriptions,
or historical overlay labels are added. Linear filtering remains local to the
painting. Existing pixel-art project settings are untouched.

## Narration

The repository now contains the researcher-supplied UH-INT-01 narration:
`res://assets/landmarks/urduja_house/audio/uh-int-01-narration.ogg`

The existing resource, narration reference, approved transcript, painting, and
crop coordinates are unchanged. No audio is converted, generated, or substituted.

One icon-only SpeakerButton replaces the Listen/Pause/Restart visitor controls.
Its layout path inside the viewer is:
`Main/Margin/Layout/Columns/Artwork/AudioRow/SpeakerButton`.
The AudioRow sits below ImageArea and above Views (Full Artwork / Inspect Artwork).
Containers keep the button left-aligned at 56 × 56 logical pixels. Its local
32 × 32 monochrome SVG depicts a speaker with sound waves; it has no external
resource dependencies. The active gold background and dark icon provide visible
feedback without hover or animation. Tooltips/accessibility names change between
Play narration and Stop narration. Tab/Enter/Space and touch/mouse work.

Tap inactive: play from the beginning. Tap active: stop and reset. Natural finish:
reset and clear the active state. The next tap starts at the beginning. Narration
never autoplays, continues across sections/crops/artwork modes/Sources, and stops
only when requested with the speaker or when the full viewer closes. Closing a
nested panel preserves playback. Reopening the viewer does not autoplay.
The speaker is on the main artwork view; return from nested panels to stop it.

The public `listen()`, `pause_narration()`, and `restart_narration()` methods are
retained for compatibility, with no pause/resume/restart controls in visitor UI.
The speaker uses `toggle_narration()` and natural finish uses `stop_narration()`.

Without a stream, production hides AudioRow. With the standalone scene's
`show_development_audio_pending` flag, it instead shows a disabled speaker and
DEVELOPMENT ONLY: Approved narration audio has not yet been assigned.
No enabled no-op playback control is shown. Assigning the original stream again
restores the normal speaker on the next opening.

## Exact F6 retesting

1. Open the existing project in Godot 4.7.2 and let imports finish. In FileSystem,
   open `res://scenes/landmarks/urduja_house/interior/uh_int_01.tscn`. Press **F6**
   (Run Current Scene), not F5. Start at **1280 × 720**.
2. Tap/click **Discover the story behind the name**. Check the complete painting,
   proportions, readable text, initially selected THE ARTWORK, and visibly gold
   **Full Artwork** button. **Inspect Artwork** is unselected. Click Full Artwork
   repeatedly: it stays visibly selected and the entire painting stays visible.
3. Select **THE LEGEND**, then open **Inspect Artwork**. Confirm inspection opens
   and The Legend remains readable beside the image. The first crop and highlighted
   control are **Central Figure**. Compare the text to the approved specification,
   including its unchanged historical-uncertainty wording.
4. Tap **Left-side Scene**, **Right-side Scene**, **Lower Details**, and **Central
   Figure**, repeatedly and out of order. Check each crop changes in place, only
   one region button is selected, and Viewing matches it. Only the original painting
   is shown. There must be no object interpretation, description, reward, or counter.
5. Tap **Back to Full Artwork**. Check complete image restoration, Full Artwork
   selected, Inspect Artwork unselected, and keyboard focus on Full Artwork.
   Select CULTURAL SIGNIFICANCE, then reopen inspection. The last region remains
   selected and the new educational text appears. Repeat for all three sections.
6. In inspection, open **Sources / Artwork Credit**. Check the unchanged artist
   and researcher-validated content credit. Press Escape: only Sources closes and
   focus returns to its inspection button. Press Backspace: inspection closes and
   Full Artwork is selected/focused. Press Escape: the viewer closes and focus
   returns to the opener. Repeat using the visible close/back buttons.
7. Retest narration on a device with sound:
   - **Initial:** one speaker is visible below the painting, above the mode row,
     aligned left. No Listen, Pause, Resume, or Restart buttons appear. No autoplay.
   - **Play:** tap the speaker; narration starts at the beginning, with gold active
     styling and Stop narration accessibility text.
   - **Explore:** switch THE ARTWORK / THE LEGEND / CULTURAL SIGNIFICANCE; enter
     Inspect Artwork, select all four crops, and open/close Sources. Narration
     continues without restarting. Nested back also preserves narration.
   - **Stop:** return to Full Artwork, tap the active speaker; playback stops,
     position resets, and the active style disappears.
   - **Replay:** tap again; confirm the opening narration is heard again.
   - **Natural completion:** let the whole recording finish. The speaker becomes
     inactive; the next tap starts at the beginning.
   - **Close:** play narration, close the full viewer, and confirm sound stops.
     Reopen and confirm no autoplay and inactive styling.
8. In a disposable copy, clear `narration_stream` with the development flag enabled.
   F6 and open: a disabled speaker and explicit development pending message appear.
   Disable the flag and reopen: speaker and pending status disappear. Restore the
   supplied stream and reopen: the enabled speaker returns. Do not save temporary
   test settings into the actual milestone resource or generate test audio.
9. Test Tab and Shift+Tab through every active layer. Enter/Space activate focused
   controls; each region receives visible focus. Tab must not reach covered main
   controls while inspection or Sources is open. Focus the educational scroll area
   to scroll using arrows/Page Up/Page Down. All close controls remain reachable.
10. Tap the speaker, every region, and close/back controls without hovering.
    Confirm the speaker is recognizable and its 56-pixel square is easy to tap.
    Region buttons are at least 48 logical pixels high, with 8-pixel separation.
    Confirm comfortable physical targets and touch scrolling on the actual museum
    tablet and landscape phone. No action requires hover or completing other actions.
11. Repeat at **960 × 540** and **854 × 480**, including the missing-audio state.
    Check the speaker does not overlap the painting or mode buttons. Check the
    overlay fits, four region buttons stay readable in two rows, Close
    and Back remain reachable, and no horizontal overflow/overlap occurs. Content
    scrolls without reducing the 22-pixel body font; controls remain 20 pixels.
    Browser/window scaling can affect physical target size, so assess it on-device.
12. Repeatedly open/close, change sections, inspect all regions, and open Sources.
    Check no duplicate UI, stuck focus, missing resources, or Godot errors. Press
    **F8** to stop. No master-scene or application setting change is required.

## Validation

Runtime validation uses real mouse and keyboard events and touch-to-mouse input,
plus state/resource checks at true 1280 × 720, 960 × 540, and 854 × 480 logical
viewport sizes. It checks crop source/rectangles/aspect/scale, exclusive selection,
independent educational content, nested back and focus, playback state, null-audio
fallback, optional production hiding, and control bounds/48-pixel heights.

Rendered appearance, audible content, physical touchscreen comfort, and browser
export testing remain manual checks; headless validation cannot establish those.

Godot 4.7.2 headless import and runtime speaker validation passed (exit 0), with
**0 failures** at 1280 × 720, 960 × 540, and 854 × 480. Tests include 56 × 56 speaker
bounds/placement, actual natural-finish callback after seeking near the supplied
recording's end, stop/reset/replay, active/accessibility state, continuity across
sections/crops/Sources/nested back, full-close cleanup, mouse/keyboard/touch input,
and hidden-production/disabled-development missing-audio behavior.

Only the four existing files listed above changed in this refinement. Hash checks
confirm the content resource, narration, painting, crop configuration, standalone
scene, AGENTS.md, project.godot, and all other pre-existing non-import files are
unchanged. No additional project.godot serialization occurred. Resource paths,
exact approved historical text, `git diff --check`, and whitespace checks for
untracked changed/new files passed. Existing local modifications and untracked
milestone files remain; the speaker SVG and its import file are newly untracked.
No commit or push was performed.
