# UH-EXT-02 — Why It Was Built

This development-only standalone front-approach composition uses the UH-EXT-01
pattern. It has no navigation integration, walking transitions, completion
requirement, or connection to another hotspot. Information remains optional.

## Files and structure

- `scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn`
- `data/landmarks/urduja_house/uh_ext_02.tres`
- `docs/uh_ext_02_testing.md`
- `assets/landmarks/urduja_house/icons/uh_origin_hotspot.png.import` (Godot-generated)
- `assets/landmarks/urduja_house/exterior/uh_ext_02_archival_photo.jpg.import` (Godot-generated)
- `assets/landmarks/urduja_house/exterior/uh_ext_02_governor_rodriguez_portrait.jpg.import` (Godot-generated)

```text
UH_EXT_02 (Control)
  Background (ColorRect)
  Exterior (TextureRect)
  Heading (Label)
  OriginInformation (HistoricalHotspot instance)
    InformationPopup (inherited modal popup)
    NarrationPlayer (inherited, audio unassigned)
  KeyboardHelp (Label)
  DevelopmentNote (Label)
```

HistoricalHotspot is reused unchanged. The scene assigns its separate content
resource, icon, prompt, and position. The ready signal gives the trigger initial
focus. The component supplies mouse and keyboard activation, scrolling, Close,
go_back handling, and deferred focus restoration. No new GDScript is needed.

## Asset discovery and content

- Scene context: `res://assets/landmarks/urduja_house/exterior/uh_ext_01_pixel_art.png`.
- Popup image: `res://assets/landmarks/urduja_house/exterior/uh_ext_02_archival_photo.jpg`.
- History icon: `res://assets/landmarks/urduja_house/icons/uh_origin_hotspot.png`.
- The researcher-supplied archival/historical photograph is now the popup image.
  The existing popup preserves aspect ratio in a 220-pixel-high area; no original
  image was edited. The scene's pixel-art exterior context remains unchanged.
- Verified Governor Juan de Guzman Rodriguez portrait:
  `res://assets/landmarks/urduja_house/exterior/uh_ext_02_governor_rodriguez_portrait.jpg`.
  This researcher-supplied portrait is available for a future supplementary-media
  enhancement but remains unused and deferred. No component modification or
  custom multi-image system is added.
- The audio directory contains no narration. Narration stays unassigned as its
  intentional development placeholder; the narration button is hidden.
- Source credit stays empty and hidden because no verified credit was supplied.
- The approved historical body and narration transcript are copied verbatim,
  including paragraph and line breaks, from the read-only UH-EXT-02 specification.
  The transcript remains assigned and displayed even without narration audio.

## Exact Godot F6 manual testing

1. Open this repository's `project.godot` in Godot 4.7 and allow asset import to
   finish. Open `scenes/landmarks/urduja_house/exterior/uh_ext_02.tscn` and press
   **F6** (Run Current Scene). Do not change the main scene. Use 1280 × 720.
2. Verify the exterior reconstruction loads, exactly one origin/history icon is
   visible, **Discover its beginning** is readable, and the development-only
   layout note fits the screen. The popup starts closed and remains optional.
3. Click the hotspot. Verify **Establishing an Official Residence**, the exact
   approved historical text, archival/historical photograph, and approved transcript
   against `docs/specifications/urduja_house/uh_ext_02.md`. Scroll as needed.
   Compare the displayed image with `uh_ext_02_archival_photo.jpg`; the current
   exterior photograph and governor portrait must not appear in the popup.
   Check that the archival image preserves its proportions. No narration button
   or source credit should appear; no sound should play.
4. Press **Escape** and check that focus returns visibly to the hotspot. Reopen
   with **E**, then close with **Backspace**. Repeat opening with **Enter** and
   **Space**, and close using the visible **Close** button. Verify each closing
   method restores focus appropriately. Close initially receives popup focus.
5. Test **Tab / Shift+Tab**. Popup focus must stay inside the modal window. Tab
   to the scroll area, use arrow keys / Page Down / Page Up, and test mouse-wheel
   scrolling. Close must remain visible. Activate Close with Enter or Space.
6. Repeatedly open and close using mouse and keyboard, including holding E
   briefly. There must be no duplicate popup, immediate reopening after closing,
   stuck input, or missing-resource error. Reopening resets the scroll position.
   Pressing N without assigned narration must be harmless.
7. Check readable text and unstretched images at 1280 × 720 and after resizing.
   The popup must scroll when necessary and the controls must remain reachable.
   Inspect the Godot Debugger for errors.
8. Press **F8** to stop. Press **F5** to confirm the existing application foundation
   remains unchanged. UH-EXT-01 and application navigation must not be altered.

Manual visual, input, and browser checks are required before master-scene
integration. Headless loading alone does not verify these. For browser testing,
use a disposable project copy with UH-EXT-02 as its main scene, export for Web,
serve over HTTP, and repeat the checks without changing the actual project.

## DEVELOPMENT TEMPLATE — not validated content

Editable researcher reminder only. These placeholders are not runtime credits.

```text
Current Exterior Photo
Source: [Insert verified source]
Photographer/Owner: [Insert name if known]
Date: [Insert date if known]

Archival/Historical Photo
Source/Archive: [Insert verified source]
Photographer/Creator: [Insert name if known]
Date: [Insert date/year if known]

Portrait of Gov. Juan de Guzman Rodriguez
Source/Collection: [Insert verified source]
Photographer/Creator: [Insert name if known]
Date: [Insert date/year if known]
```

## Implementation validation results

- Godot 4.7.2 headless editor import: exit code 0, no reported errors.
- UH-EXT-02 headless standalone startup: exit code 0, no reported errors.
- External scene/content resource paths all exist; Godot loaded them successfully.
- Historical body and transcript match the specification exactly, with line
  endings normalized for comparison.
- Narration and source credit retain their unassigned/empty resource defaults.
- No tracked files changed, including the reusable component, UH-EXT-01,
  application scenes, and `project.godot`. No project serialization occurred.
- The specification and origin icon were already untracked researcher-supplied
  files before this milestone; they were not created or edited by implementation.
- The archival-photo correction changes only the UH-EXT-02 image reference and
  this guide, plus Godot-generated import settings for the two supplied images.
  The supplied portrait remains unreferenced by the scene and content resource.
- Manual visual, mouse/keyboard, focus, and browser checks remain pending.
