# UH-INT-02 — control layout and 1953 visual correction

This correction changes only control placement and the 1953 illustrative visual.
The four approved historical bodies, dates/titles, narration behavior, shared
historical image, present-day image, and standalone scope are unchanged. No lobby,
other milestone, game mechanic, or additional historical claim is implemented.

## Files modified

- `scenes/components/interactive_timeline.tscn`
- `scripts/components/interactive_timeline.gd`
- `scripts/components/interactive_timeline_entry.gd`
- `data/landmarks/urduja_house/uh_int_02.tres`
- `docs/uh_int_02_testing.md`

No new repository files are required. The entry resource gains a `pixel_art`
boolean to choose local nearest-neighbor filtering without identifying a landmark
or date in generic behavior. Photographs continue using linear filtering.
The existing AGENTS.md and project.godot working-tree changes predate this
correction and must remain untouched. No commit or push.

## Exact layout

```text
Main / Margin / Layout
  Header: Title (expands), Close (96 × 48, upper right)
  Columns
    Media: Image / generic NoImage fallback (unused by UH-INT-02)
    ContentFrame (subtle border/background matching AKAR palette)
      Margin (12 px) / Content
        Meta: Date (expands), Sources (120 × 48, right)
        Heading
        Scroll / Body
  TimelineArea (VBox, 4 px separation)
    AudioMargin (52 px left inset) / AudioRow / Speaker (56 × 56)
    Track (104 px high)
      Four dates, four nodes, draggable clock handle
```

Close stays vertically aligned with the title in the top-right header.
Sources is now within the right content panel's date row, aligned to the same
12-pixel content inset as the heading/body. It no longer occupies the bottom of
the expanding text column.

The speaker center aligns with the first milestone/track start at x=80 inside
TimelineArea: 52-pixel inset plus half the 56-pixel button. Its row is immediately
above the dates with a 4-pixel gap. It remains outside the historical text panel.

The four milestone centers remain evenly distributed from x=80 to width−80.
Date buttons are 152 × 48 at y=0. Track center is y=76; 56 × 56 node/handle targets
start at y=48, directly below the labels, and end at y=104. Dates, nodes, and handle
share identical horizontal centers. No scattered rows or smaller hit targets.

## 1953 visual and historical safety

Exact existing asset:
`res://assets/landmarks/urduja_house/exterior/uh_ext_01_pixel_art.png`

1953 now assigns this approved pixel-art image, preserves its full aspect ratio,
and uses nearest-neighbor filtering. The old large centered placeholder message
is removed from UH-INT-02's content resource and hidden in the main display.
No main-panel caption is used.

The accessible image description reads:
“Illustrative pixel-art view of Urduja House.”

1953 Sources now explains:
“The displayed pixel-art image is an illustrative project visual. No verified
historical photograph is assigned to this milestone.”

This is a media-type clarification, not an invented photographer, owner, date,
archive, or provenance claim. It does not identify the image as documentation of
1953. No image asset is generated, modified, renamed, or duplicated.

The earlier specification's 1953 no-image direction is superseded by this explicit
correction request; the specification file itself remains unchanged. Approved
historical paragraphs remain verbatim. All other milestones retain:

- 1953–2007 and 2007: the same
  `res://assets/landmarks/urduja_house/interior/uh_int_02_historical.jpg`.
- Present: `res://assets/landmarks/urduja_house/interior/uh_int_02_present.JPG`.

## Preserved behavior and resources

The reusable component API remains `open_interaction`, `close_interaction`,
`is_interaction_open`, `get_selected_index`, `select_milestone`, `open_sources`,
`close_sources`, `toggle_narration`, and `stop_narration`.
Signals remain opened/closed, milestone_changed(index), narration_started/stopped,
and sources_opened/closed. Historical content remains in resource data.

Mouse/native-touch dragging stays constrained to the track. Release snaps to the
nearest approved index over 200 ms. Each date and node also supports direct tap.
The 80 ms outgoing / 120 ms incoming fade and replacement of active tweens are
unchanged. No forced order, Previous/Next controls, or completion tracking.

Clock: `res://assets/ui/icons/timeline_clock.png`, using its existing AtlasTexture.
Speaker: `res://assets/ui/icons/speaker.svg`.
Overall narration: `res://assets/landmarks/urduja_house/audio/uh_int_02_narration.ogg`.

One narration stream belongs to the whole hotspot. Tap speaker to play from zero;
tap again to stop/reset. Natural finish clears active styling. Milestone changes,
dragging, and Sources do not seek, restart, or stop narration. Full close stops/reset;
reopening never autoplays. Null-audio handling remains safe.

Transcript remains pending/empty. Sources for the other three milestones remains
explicitly development-pending; no credit data has been invented. Earlier
per-milestone-audio bullets in the specification are superseded by the explicit
whole-hotspot narration requirement from the implementation request.

## Exact F6 retest

1. Open the existing project in Godot 4.7.2 and let imports finish. Open
   `res://scenes/landmarks/urduja_house/interior/uh_int_02.tscn` in FileSystem.
   Press **F6 — Run Current Scene**, then click/tap **Explore the timeline**.
2. At **1280 × 720**, confirm the initial 1953 selection shows the pixel-art house
   in the left panel, with correct proportions and crisp filtering. The old large
   no-image message must not appear. Compare the historical text with the approved
   specification: it must be unchanged.
3. Inspect control balance: Close is upper-right beside the title; Sources is
   clearly inside the right content header; speaker is directly above the first
   milestone area; four dates are evenly aligned with their nodes and the track.
   Nothing overlaps and controls remain comfortably sized.
4. Open 1953 Sources. Confirm the illustrative-project-visual clarification and
   absence of fabricated image credits. Close Sources using its button and Escape.
5. Select every date and node in arbitrary order. Confirm 1953–2007 and 2007 still
   share the historical photograph and Present uses the distinct present image.
   All images preserve proportions; photo filtering returns to linear. Check all
   titles and historical paragraphs against the specification.
6. Drag the clock in both directions and beyond either endpoint, then release.
   It clamps and snaps to the nearest milestone. Tap dates quickly during fades:
   the final selection wins, opacity returns to normal, and no UI duplicates.
7. Tap speaker: narration starts at the beginning and shows active gold styling.
   Drag/select dates and open/close Sources while it plays: playback continues.
   Tap again to stop/reset; tap again to replay. Let the recording finish, then
   replay. Close the full viewer while playing, reopen, and confirm silence.
8. Test Tab/Shift+Tab, Enter/Space on dates and speaker, and body scrolling.
   Sources traps focus while open. Escape/Backspace closes Sources first, then the
   viewer; opener focus returns. No new shortcuts or narration controls appear.
9. Repeat at **960 × 540** and **854 × 480**. Check image/text proportions, readable
   scrolling content, Sources inside its panel, accessible upper-right Close,
   speaker near the first milestone, one aligned date row, no overlap, and no
   horizontal overflow. Buttons remain at least 48 px high; speaker/handle 56 px.
10. On real tablet/phone landscape touchscreens, test dragging and direct taps
    without hovering. Confirm understandable controls and comfortable physical
    hit targets after browser scaling. Repeated open/close should show no missing
    resources, stuck focus, duplicate controls, or Godot errors. Press **F8** to stop.

## Validation

Headless runtime checks cover scene/resource loading, 1953 pixel-art assignment,
nearest filtering, hidden placeholder, image aspect mode, content-panel Sources
placement, speaker alignment, all milestone taps, drag/snap, native touch capture,
rapid fades, keyboard/back/focus, playback continuity, stop/reset/natural finish,
null audio, and bounds at all three requested logical sizes.

Rendered visual balance, full audible recording review, Web export, and physical
touch comfort remain manual F6/device checks.

### Continuation results

The five correction files listed above were already updated before continuation.
Their implementation was preserved. This continuation changed only this testing
guide in the repository and corrected a temporary test's alignment tolerance:
Godot pixel-snaps a 31-pixel label within a 48-pixel button row, producing an
expected half-pixel difference between their geometric centers.

Godot 4.7.2 headless runtime validation passed with **0 failures**, exit code 0,
at **1280 × 720**, **960 × 540**, and **854 × 480**. All four approved historical
bodies/date labels/titles and the narration reference match the pre-correction
content. The shared historical photograph and Present assignment remain intact.
Resource-path checks, `git diff --check`, and whitespace checks on the five
untracked correction files passed.

No new repository files were created during the correction or continuation.
AGENTS.md and project.godot already had tracked local modifications; their hashes
were unchanged during continuation and runtime validation. UH-INT-02 files remain
untracked. No additional project serialization, commit, or push occurred.
