# UH-EXT-01 — Testing and Visual Editing

This guide supersedes the EXT-01 section of the previous all-hotspot revision report.
Only UH-EXT-01 changes in this phase. The reusable shared header/Sources shell and
other hotspots remain unchanged. The F6 wrapper still instances the real component.

## Exact F6 steps

1. Open this repository's `project.godot` in Godot 4.7.x (validated with 4.7.2).
2. In FileSystem, open `res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn`.
3. Press **F6 / Run Current Scene**, not F5. The real component opens in a 5% inset frame.
4. Repeat the checks below at actual window sizes **1280×720**, **960×540**, **854×480**.
   The standalone wrapper disables design-resolution scaling; test actual layout sizes.
5. Close the hotspot, activate OPEN UH-EXT-01 PREVIEW, and confirm the locator map returns.
6. For a separate parent check, instance `res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn`
   inside a Control with its own size/anchors and call `open_interaction()`. It must respect
   that Control, without using the global viewport or changing application navigation.

## Approved three-perspective discovery rail

The labels are **PLACE → HISTORY → TODAY**. This is neither a timeline nor progress.

| State | Context / heading | Visual / caption |
|---|---|---|
| PLACE | WHERE IS IT? / Within Lingayen's Provincial Government Complex | Supplied locator map; URDUJA HOUSE • LINGAYEN, PANGASINAN |
| HISTORY | HISTORICAL VIEW / The Residence Takes Shape | Historical photograph; Historical view of Urduja House • September 1982 |
| TODAY | TODAY / Still an Official Residence | Current AKAR photograph; Present-day view of Urduja House |

PLACE text: Urduja House stands within the provincial government complex in Lingayen, Pangasinan.

HISTORY text: Construction of the governor's official residence began in 1953.
HISTORY now uses two separate micro-sections:

- **1953 — Construction Begins:** Construction of the governor's official residence began in 1953.
- **1982 — An Earlier View:** This September 1982 photograph provides a historical view of Urduja House during an earlier period.
- **LOOK CLOSER:** Compare this historical view with TODAY to see the residence in the present.

This is an optional observation cue, with no completion tracking or required visit to TODAY.
Scroll the local interpretation area at compact sizes to read all sections; the photo,
caption, rail and takeaway stay visible. The photograph does not depict construction
or claim to show the original appearance.

TODAY text: Urduja House remains the official residence of the Governor of Pangasinan.
Its continuing role connects the historic residence with present-day provincial governance.

The permanent takeaway below the rail reads:
Urduja House is a historic government landmark that continues to serve as the official residence of the Governor of Pangasinan.

Header: MEET URDUJA HOUSE; Official Residence of the Governor of Pangasinan.
SOURCES, LISTEN and CLOSE remain visible.

## Mouse / touch / keyboard

- Click/tap every stop and its label. Exactly one gold selected state must remain.
- Drag the simple muted-gold diamond (52px hit target) in both directions. Its vertical
  position stays fixed, its horizontal position clamps to the rail, and content changes
  only on release. Release between stops to verify nearest-stop snapping.
- Repeat with touch. No hover, long press, double-click, swipe or pinch is required.
- Tab / Shift+Tab must reach active controls. Enter / Space activate the focused stop.
- Left / Right on a focused stop select the adjacent perspective without wrapping.
- Verify the selected fill and focus border are visually distinct.
- Rapidly select PLACE, TODAY, HISTORY, TODAY. After 220ms the final marker, image,
  heading, context and caption must all be TODAY and fully opaque.
- Resize during a slide; the selector must align with the latest selected stop.
- Media and interpretation fade out/in together in 220ms; the selector slides in 220ms.
  No bounce, rewards, completion tracking, particles, sound effects or optional glint added.

## Sources / narration / closing

- Sources preserves selection, image and selector position. Tab stays in the overlay.
- Escape closes Sources first; another Escape closes the hotspot. Backspace also closes.
- Narration is supplied/enabled: `res://assets/landmarks/urduja_house/audio/uh_ext_01_narration.ogg` (21 seconds, non-looping).
- Researcher explicitly approved use of the supplied UH-EXT-01 narration file despite duplicate-file detection. The audio was not replaced, synthesized or edited. Its spoken words were not independently transcribed; the exact file is accepted on researcher approval.
- LISTEN is enabled, has the accessible name LISTEN, and uses the existing pressed styling while playing. Its description explains play or stop/reset without requiring hover.
- Activate LISTEN to play from zero; activate again to stop/reset. Natural finish returns to idle and the next activation starts at zero.
- PLACE/HISTORY/TODAY and Sources do not stop, restart or seek narration. Full Close stops/resets; reopen is enabled and idle. No autoplay.
- The approved narration transcript remains unchanged and independently available in Sources.
- Close while media is fading or the selector is dragging. Reopen must show PLACE with
  full opacity, map, initial caption, reset local scroll and no stale pointer/transition.
- CLOSE dismisses this component and emits the existing close signal; it does not navigate
  directly to the landmark map.

## Actual assets / credits

All paths are under `res://assets/landmarks/urduja_house/`:

- `exterior/uh_ext_01_locator_map.png`: AKAR locator composition, displayed unchanged.
  The supplied image contains satellite/base-map imagery. Its underlying attribution/license
  still needs verification; no invented geography or overlay labels were added.
- `exterior/uh_ext_01_historical_photo_1982.jpg`: September 1982; researcher identifies
  I Love Pangasinan — “Urduja House in Lingayen Pangasinan”, which cites Wikipedia.
  **SOURCE IDENTIFIED — CREATOR/LICENSE VERIFICATION PENDING**. Publisher is not credited
  as photographer. No URL or original license was invented.
- `exterior/uh_ext_01_exterior_photo.JPG`: current photo, source AKAR per researcher;
  individual photographer and capture date remain undocumented.
- The former information/emblem graphic is no longer used by this rail. A simple UI-drawn
  muted-gold diamond replaces it; all image assets remain preserved on disk.

No files renamed/deleted and no image/audio bytes edited. Existing pixel art is preserved.
See `docs/urduja_house_media_credits.md` for the updated EXT-01 register entries.
The pre-existing deletion of the old `.jpeg` image is preserved; any other hotspot's old
reference is outside this phase and is reported rather than silently changed.

## Responsive review

At each size verify: contained two-column view, aspect-preserved image with readable caption,
visible takeaway, comfortable rail/header targets, distinct focus, and no clipping/overflow.
Photo captions sit directly beneath the media frame. The unchanged takeaway has 18px
internal horizontal padding and 6px vertical spacing, word wrapping, and 16px type.
At compact sizes it wraps to two lines; it remains outside the prose scroll.
Photos and the supplied satellite-map composite use linear filtering; the diamond selector
is drawn without a texture. Fonts come from the existing AKAR theme; no external fonts added.
Read the full heading/body using local scrolling where necessary at compact sizes.

## Automated checks

From the repository root:

```powershell
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/uh_ext_01_phase5_test.gd
& 'C:\Users\Admin\OneDrive\Documents\Godot Files\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/uh_ext_01_phase5_test.gd
```

The graphics-enabled run additionally captures all three states at all three sizes,
full and inset, to `$env:TEMP/akar_uh_ext_01_editor`. It checks real rendered header pixels.
Physical tablet/phone touch and browser-export acceptance remain researcher manual checks.
The previous all-hotspot regression still assumes EXT-01 temporary audio is enabled; use
this Phase 5 test for the updated contract. Other-hotspot tests/content were not rewritten.

## VISUAL EDITING / INTEGRATION

**PRODUCTION SCENE TO INSTANTIATE:** `res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn`

**VISUAL EDITING SCENE:** the same production scene. Its Discovery instance has Editable Children enabled.
For focused body editing, open `res://scenes/landmarks/urduja_house/components/uh_ext_01_discovery.tscn` directly.

**F6 TEST SCENE:** `res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn`.
OPEN UH-EXT-01 PREVIEW belongs only to that unchanged reset/integration harness.

### Researcher: ordinary Inspector edits

1. Open the production scene above and choose **2D**. Select the root and press **F** to frame it if needed. PLACE/map and resource-backed labels appear without F6.
2. Expand `Panel/MainMargin/MainVBox`. Select `MainMargin` for panel padding, `MainVBox` for vertical
   gaps, and `Header` for action/title spacing. Edit the root's Theme resource for button/focus styling.
3. Expand `Content/Discovery/Layout` (Editable Children is already enabled). Select `ContentRow`
   for column separation; `MediaColumn` for media proportion/caption gap; `MediaFrame` for minimum
   size and sizing flags; `MediaTexture` for aspect-fit presentation; `MediaCaption` for alignment/type.
4. Select `InfoScroll` for text-column proportion and scrolling, `InfoColumn` for text spacing,
   and its labels/HistorySections for ordinary typography and subsection spacing.
5. Select `DiscoveryRail` for minimum height and placement within Layout. Its `Stops` HBox and spacer
   Controls manage the three stop positions. Button minimum sizes, circle styles and the simple
   `Selector/Diamond` polygon are scene-authored and editable. Keep touch targets at least 48px.
6. Select `TakeawayMargin` for padding and its `Takeaway` Label for wrapping/type. These values are
   no longer overwritten by the legacy runtime adapter.
7. Save, then use the unchanged F6 harness and all three sizes to check your edits. Container-managed
   positions are adjusted through margins/minimum sizes/size flags, not by dragging children against
   their Container. Keep node names/paths and content bindings intact.

A small `@tool` helper populates editor text from the existing `.tres` so approved historical
copy is not duplicated in the scene. It creates no UI and changes no margins/fonts/styles.
Its editor pre-save/post-save handling clears/restores preview text to keep scene saves data-free.
Do not edit label Text fields as historical content: edit the approved resource only with researcher approval.

### Exactly what remains runtime-controlled

- Selected content, image, caption, accessibility text and HISTORY/body visibility.
- Sources/whole-hotspot visibility, audio availability, focus, input and close/reset state.
- Selector position/tween and rail line endpoints, derived from the scene-authored stop Containers.
- Opacity during the existing 220ms transition and local scroll resets.
- Below the available-width breakpoint (default 900px), heading/body font sizes, column/text gaps
  and media/text stretch proportions. These compact settings are exported on the Discovery root
  under **Responsive compact layout** and are editable in Inspector.
- Above that breakpoint, the values originally authored on the corresponding scene nodes are restored.
  Main margins, caption gap/alignment, rail minimum height, button sizes, media-frame minimum size,
  takeaway padding and header spacing are not hard-reset by scripts.

### Virtual-environment teammate

Instance the production scene under the intended parent Control. Fill or size that parent using
normal anchors/Containers; do not instance the F6 harness. The component starts closed at runtime.
Call `open_interaction()` to show it. Connect `closed` to your environment's focus/overlay handling.
The component emits its close signal after handling navigation input and stopping/resetting media;
it does not hard-code map navigation. Parent code may remove it in response to the close signal.
No global viewport settings are changed by the production component.

### Editor-edit regression coverage

The existing regression now applies simulated Inspector edits before startup, opens the component,
resizes compact/wide, and verifies that margins, caption gap/alignment, rail height, stop width,
media minimum size, header gap and wide-mode typography/separation survive.


## Editor rect regression — 3 October 2026

Open `res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn` directly in 2D. Select Hotspot and frame the selection (F), or zoom to fit. Expect a complete 1280×720 reference layout: header, media left, interpretation right, discovery rail and takeaway. Content is a MarginContainer and its Discovery child expands/fills both axes; do not replace Container layout with saved compact offsets.

With Editable Children enabled, select MediaColumn, InfoScroll, MediaFrame, DiscoveryRail and TakeawayMargin. Adjust parent margins, media/info stretch ratios, caption separation, rail minimum height and takeaway margins. Confirm visible editor changes; undo experimental edits. Runtime retains those values except the documented compact typography/gaps/column ratios below the breakpoint, restoring scene-defined wide values afterward.

Run the actual editor regression with Godot:

```text
godot --headless --editor --path . --script res://tests/uh_ext_01_editor_layout_test.gd
```

It makes only in-memory edits; no scene is saved. Omit `--headless` to capture the editor viewport. Run existing runtime checks with `--script res://tests/uh_ext_01_phase5_test.gd`, headless and rendered.

For F6: open `res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn`, press F6, close the hotspot, then use OPEN UH-EXT-01 PREVIEW. Verify PLACE reset, HISTORY/TODAY, mouse and keyboard, Sources, enabled Listen, and rapid navigation at 1280×720, 960×540 and 854×480. The harness has 5% inset; automated tests also exercise full parent. Preserve the Hotspot instance's Full Rect anchors (right/bottom 1); a top-left preset with zero offsets collapses its rect.


## Final narration F6 retest

1. Open `res://scenes/landmarks/urduja_house/exterior/uh_ext_01.tscn` and press **F6**. Expect PLACE, enabled LISTEN and silence (no autoplay).
2. Click LISTEN: audio starts at the beginning and the button uses the existing active style. Click again: stop/reset. Click again: replay from the beginning.
3. While playing, select HISTORY, TODAY and PLACE, then open/close Sources. Audio must continue without restarting.
4. Let the 21-second file finish naturally. LISTEN returns idle; activate it to replay from the beginning.
5. Close during playback. Audio stops. Use OPEN UH-EXT-01 PREVIEW: PLACE resets, LISTEN remains enabled and audio stays idle.
6. Use Tab to reach LISTEN; Enter starts and Space stops. Repeat via mouse and a touch-capable browser/device. Automated tests simulate touch-to-mouse input; physical touchscreen listening remains a manual check.
7. Repeat at 1280×720, 960×540 and 854×480. Inspect the production scene directly in 2D to confirm the header, columns, rail and takeaway remain editable.

Final automated results: 1240 headless runtime checks, 1259 Compatibility-rendered runtime checks, and 19 editor-layout checks; zero failures. No audible transcript verification is claimed by these playback-state tests.
