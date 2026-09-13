# UH-EXT-01 standalone scene

Open `res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn` independently.
The scene is not connected to the application flow. Its arrival layout is marked
development-only; no movement, exit destination, or completion condition is added.

## Files and structure

- `scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn`: standalone presentation.
- `data/landmarks/urduja_house/uh_ext_01.tres`: approved content and photograph.
- `docs/uh_ext_01_testing.md`: this testing guide.
- Godot-generated import settings for the three supplied images:
  `assets/landmarks/urduja_house/exterior/uh_ext_01_exterior_photo.jpeg.import`,
  `assets/landmarks/urduja_house/exterior/uh_ext_01_pixel_art.png.import`, and
  `assets/landmarks/urduja_house/icons/uh_information_hotspot.png.import`.

```text
UH_EXT_01 (Control)
  Background (ColorRect)
  Exterior (TextureRect, supplied pixel-art reconstruction)
  Heading (Label)
  ArrivalInformation (instance of HistoricalHotspot, supplied icon)
    InformationPopup (inherited modal popup)
    NarrationPlayer (inherited, unassigned)
  KeyboardHelp (Label)
  DevelopmentNote (Label)
```

The trigger's Content references the separate HistoricalHotspotContent resource.
The existing component handles opening, scrolling, closing, keyboard activation,
and deferred focus restoration without modification. A ready signal gives the
trigger initial keyboard focus. The existing popup bounds its photograph to a
220-pixel-high aspect-preserving area inside its scrolling content; the original
photograph is unchanged. Pixel art uses nearest filtering.

The body and transcript retain the exact approved wording and line breaks from
`docs/specifications/urduja_house/uh_ext_01.md`, which remains read-only.
Narration is intentionally unassigned. Source credit remains empty because no
verified attribution was supplied. The component hides both unavailable fields
while keeping the transcript visible. Ambient audio is not added.

## Manual Godot 4.7 F6 checks

1. Open `project.godot` and let Godot finish importing assets. Open
   `scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn`. Press **F6** (Run
   Current Scene), keeping the main scene unchanged. Use a 1280 × 720 window.
2. Verify the supplied exterior reconstruction, one information icon, and
   **Discover this landmark** prompt are visible. The standalone development note
   must be readable. The popup must start closed; activation is optional.
3. Click the information button. Verify **Urduja House**, both approved historical
   paragraphs, the proportionally scaled exterior photograph, and the approved
   transcript (scroll down). Compare against the specification. There must be no
   narration control, source-credit field, ambient sound, or invented attribution.
4. Press **Escape**. Verify closing restores visible focus to the information
   button. Press **E** to reopen, then **Backspace** to close. Repeat with **Enter**
   and **Space**, closing each time. Hold E briefly: only one popup should open.
5. Use **Tab / Shift+Tab** to inspect keyboard focus. Inside the popup, focus must
   remain modal. Tab to the scroll area and use arrow/Page Down/Page Up keys;
   also test the mouse wheel. The Close button must remain reachable. Activate
   **Close** using Enter/Space and verify focus restoration. Reopen and confirm
   scrolling returns to the top. Pressing N with no audio must be harmless.
6. Resize the window and verify the reconstruction preserves its proportions,
   the information trigger remains usable, and popup text/media can be read by
   scrolling. Check the Debugger for script or resource errors.
7. Stop with **F8**. Press **F5** and confirm the existing foundation still opens.
   No other hotspots or application navigation are introduced by this milestone.

Headless checks do not replace visual and browser input verification. For Web QA,
use a disposable project copy with this scene as its main scene and a Web export
preset, serve over HTTP, and repeat the mouse, keyboard, scroll, and focus checks.
Do not alter the real project's main scene or export configuration for this test.

## Implementation validation

Godot 4.7.2 headless editor import and standalone scene startup completed with
exit code 0 and no reported errors. All external resource paths resolve, and the
resource body and transcript were compared exactly against the specification.
Manual visual, keyboard/focus, and browser checks remain to be performed.
