# UH-EXT-03 — Balinese-Inspired Architecture

Standalone, development-only viewing layout. No application integration,
transitions, progression, completion tracking, or required marker selections.
The approved specification is `docs/specifications/uh_ext_03.md` and is unchanged.

## Files and structure

- `scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn`
- `data/landmarks/urduja_house/uh_ext_03.tres`
- `scenes/components/architecture_marker.tscn`
- `scripts/components/architecture_marker_layer.gd` and its Godot-generated `.uid`
- `docs/uh_ext_03_testing.md`
- Godot-generated `.import` sidecars for the five icons listed below.

```text
UH_EXT_03 (Control)
  Background (ColorRect)
  ViewingArea (centered 1280 × 720 Control)
    Exterior (TextureRect)
    Heading (Label)
    ArchitectureInformation (unchanged HistoricalHotspot instance)
      InformationPopup / NarrationPlayer (inherited)
    MarkerLayer (Control, architecture_marker_layer.gd)
      Roofline (ArchitectureMarker instance)
      MainFacade (ArchitectureMarker instance)
      Entrance (ArchitectureMarker instance)
      ExteriorForm (ArchitectureMarker instance)
      LandscapedSetting (ArchitectureMarker instance)
    MarkerInformation (one non-modal PanelContainer)
      Margin / Layout
        Text / Title, Description
        Close
    DevelopmentNote (Label)
```

The small reusable ArchitectureMarker scene supplies Button styling, icon scaling,
and a visible focus border. ArchitectureMarkerLayer connects its direct child
Buttons to one shared panel, adds the existing interact action, and handles
go_back before closing. Labels use ordinary Button text. Approved descriptions
are optional scene metadata, outside behavior code. Only Roofline has metadata.
Other markers hide and clear the description instead of retaining previous text.

Selection keeps focus on the marker, so visitors can continue tabbing. Close,
Escape, and Backspace hide the panel and restore the selected marker's focus.
Opening the introduction dismisses the marker panel without stealing popup focus.
HistoricalHotspot handles its own modal controls and deferred focus restoration.
No reusable historical component, previous hotspot, or project setting is changed.

## Exact assets

Scene context:
`res://assets/landmarks/urduja_house/exterior/uh_ext_01_pixel_art.png`

Introductory popup photograph:
`res://assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.jpeg`

| Marker | Icon |
| --- | --- |
| Roofline | `res://assets/landmarks/urduja_house/icons/uh_arch_roofline.png` |
| Main Façade | `res://assets/landmarks/urduja_house/icons/uh_arch_facade.png` |
| Entrance | `res://assets/landmarks/urduja_house/icons/uh_arch_entrance.png` |
| Exterior Form | `res://assets/landmarks/urduja_house/icons/uh_arch_exterior_form.png` |
| Landscaped Setting | `res://assets/landmarks/urduja_house/icons/uh_arch_landscape.png` |

All original images are unchanged. The reconstruction preserves aspect ratio;
its transparent outer margins extend beyond the clipped viewing area. Markers
are approximate interaction-design placements, not architectural claims. No
zoom images or placeholders are generated. Pixel art and icons use nearest
filtering. The introductory photograph uses the existing bounded popup image area.

The introduction and transcript are copied verbatim into the content resource.
Narration stays unassigned and its button hidden. Source credit stays empty and
hidden. No architectural interpretation beyond approved content is supplied.

## Exact F6 manual testing

1. Open `project.godot` in Godot 4.7 and wait for importing/scanning to finish.
   Open `scenes/landmarks/urduja_house/exterior/uh_ext_03.tscn`. Press **F6**
   (Run Current Scene), without changing the main scene. Test at **1280 × 720**.
2. Check the complete pixel-art building is visible and proportionally scaled.
   Confirm five distinct marker icons with readable labels, approximate placement
   by roof/front/entrance/overall form/landscaping, no excessive obstruction, and
   the readable **Examine the architecture** prompt. Both information panels
   start closed. The development-only note is visible.
3. Click **Examine the architecture**. Compare the title, introductory text, and
   transcript exactly with the specification. The present-day photograph should
   preserve its proportions. There must be no narration button, invented credits,
   or audio. Scroll to read the transcript. Close initially has keyboard focus.
4. Test introductory popup **Close**, **Escape**, and **Backspace**. Each must
   return focus to the introductory trigger. Reopen using **E**, **Enter**, and
   **Space**. Check Tab/Shift+Tab remains within the popup while open; tab to its
   scroll area and test arrow keys/Page Up/Page Down and the mouse wheel.
5. Click each marker and compare its icon against the table above:
   - **Roofline**: label plus exactly “One of the most visually prominent features
     of the residence’s exterior composition.” (The approved line break is retained.)
   - **Main Façade**, **Entrance**, **Exterior Form**, **Landscaped Setting**:
     their exact label only, with no explanatory text or stale Roofline description.
   The shared panel's Close control is UI, not historical content.
6. Tab from the introductory trigger through Roofline, Main Façade, Entrance,
   Exterior Form, and Landscaped Setting. With the panel open, Close is reachable
   next; with it closed, navigation returns to the introduction. Test Shift+Tab
   in reverse. Confirm visible focus borders and activate each marker using
   **E / Enter / Space**. No selection is required to reach any other control.
7. For each marker, close with **Escape**, **Backspace**, and the **Close** button.
   Focus must return to the selected marker. Test activating Close with keyboard.
   Repeated back presses with no panel open must be harmless.
8. Repeatedly select the same marker and switch between different markers. Hold E
   briefly. Only one marker panel may appear; no duplicate UI or stuck input.
   Open the introduction while a marker panel is visible: the marker panel hides,
   the popup retains focus, and closing returns to the introductory trigger.
9. Resize the window wider/taller and smaller while preserving the project's
   reference stretch behavior. Check readable text, accessible controls, sensible
   image proportions, and popup scrolling. Inspect the Debugger for missing
   resources or script errors. Visual and browser checks remain necessary even
   when headless input checks pass.
10. Press **F8** to stop. **F5** must still open the existing application foundation.
    UH-EXT-01 and UH-EXT-02 must remain unchanged. Do not integrate this scene yet.

## DEVELOPMENT TEMPLATE — not validated source data

Editable researcher reminder only; none of these placeholders are runtime credits.

```text
Exterior Photograph
Source: [Insert verified source]
Photographer/Owner: [Insert name if known]
Date: [Insert date if known]

2D Exterior Artwork / Pixel-Art Reconstruction
Created by: [Insert creator name]
Reference Source: [Insert verified source if applicable]
Date Created: [Insert date]

Architecture Marker Icons
Created by: [Insert creator name]
Date Created: [Insert date]
```

## Implementation validation

- Godot 4.7.2 imported the scene, script, and five supplied icons successfully.
- A temporary headless validation script loaded the standalone scene and content
  resource, and checked simulated marker mouse clicks, E/Enter/Space activation,
  Tab order with the shared panel open/closed, Close/Escape/Backspace, selected
  marker focus restoration, repeated selection, and switching to the introduction.
- The introductory popup's back event was dispatched through its Window input
  signal; focus restoration and hidden narration/credit fields passed.
- The final headless interaction/resource run reported **0 failures**, exit code 0.
- Exact introductory body, transcript, labels, and the sole Roofline description
  were checked against the specification. No unsupported explanation was added.
- Resource paths and whitespace checks passed. Existing tracked files remain
  unchanged, including `project.godot`; no project serialization was retained.
- Human visual checks and real desktop/browser input testing remain pending.
