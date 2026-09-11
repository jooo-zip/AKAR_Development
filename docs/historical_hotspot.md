# Historical information hotspot foundation

This component is independent of the application flow. The preview contains only
test placeholders; no landmark implementation or historical information is included.

## Files and node structure

- `scripts/components/historical_hotspot_content.gd`: typed Resource for content.
- `scripts/components/historical_hotspot.gd`: reusable interaction and presentation.
- `scripts/components/historical_hotspot.gd.uid` and
  `scripts/components/historical_hotspot_content.gd.uid`: Godot-generated script IDs.
- `scenes/components/historical_hotspot.tscn`: reusable component scene.
- `scenes/components/historical_hotspot_preview.tscn`: standalone test preview.
- `docs/historical_hotspot.md`: integration contract and manual checks.

```text
HistoricalHotspot (Button, historical_hotspot.gd)
  InformationPopup (PopupPanel, modal)
    Margin (MarginContainer)
      Layout (VBoxContainer)
        Title (Label)
        Scroll (ScrollContainer, keyboard focusable)
          Content (VBoxContainer)
            Body (Label)
            Image (TextureRect, optional)
            Transcript (Label, optional)
            SourceCredit (Label, optional)
        Actions (HBoxContainer)
          Narration (Button, optional)
          Close (Button)
  NarrationPlayer (AudioStreamPlayer, no autoplay)
```

The popup requests 880 x 600 within the 1280 x 720 reference viewport and clamps
to the available viewport. Long body, transcript and credits scroll together;
Close and narration remain outside the scrolling area. The image preserves its
aspect ratio in a 220-pixel-high area. Godot's default embedded subwindows support
this popup in web exports. No global settings, autoloads or input maps are changed.

## Public API

Instance `res://scenes/components/historical_hotspot.tscn` in a future landmark UI.
The root is a Button: use its ordinary text, position, tooltip and disabled
properties for the trigger. It supports mouse click and focused E/Enter/Space
through the existing `interact` action, plus standard Godot keyboard activation.
It does not implement proximity detection or avatar movement.

Assign `content` to a `HistoricalHotspotContent` resource. It exposes `title`,
multiline `body`, optional `image: Texture2D`, optional `narration: AudioStream`,
multiline `transcript` and multiline `source_credit`. Save future validated content
as separate `.tres` files under the appropriate data directory. No resources with
historical information are supplied here. Text is plain text, not markup.

- `open_information(return_focus: Control = null) -> bool`: populate and open;
  returns false when not ready, not visible, disabled, or missing content. Repeated
  calls while open do nothing and return true. Content changes apply on next open.
  Focus starts on Close. An explicit return target takes precedence, otherwise the
  previous focused control is remembered, with this trigger as fallback.
- `close_information() -> void`: close and stop/reset narration; safe to repeat.
- `is_information_open() -> bool`: current open state.
- `toggle_narration() -> void`: play, pause, resume; no effect without audio or
  while closed. Finished audio can be replayed. Reopening starts from the beginning.
- `opened` and `closed`: no-argument signals emitted once per state transition.
  A future host can use these to suspend/resume avatar input. The component does
  not pause the scene tree or block polling of the Input singleton in host scripts.

`go_back` (Escape/Backspace) is consumed in the popup viewport before closing and
emitting `closed`. `narration_toggle` (N) is consumed there as well. Popup modality
keeps GUI focus in the popup. Closing restores focus deferred, validating that the
target still exists, is visible and enabled; otherwise it tries the trigger.
Hosts can remove the component in signal handlers. Removing it also removes its
audio player. No hard-coded navigation is performed.

## Exact manual Godot checks

1. Open this repository's `project.godot` in Godot 4.7. Let script scanning finish.
   Open `scenes/components/historical_hotspot_preview.tscn` and press **F6** (Run
   Current Scene). Do not set it as the main scene. Test at 1280 x 720.
2. Click **View information**. Check title, body, transcript and source/credit;
   no image or narration button should appear. Close must visibly have focus.
3. Press Escape. The popup closes and the trigger receives focus. Repeat using
   Backspace and the Close button. Reopen with E, Enter and Space. Hold E briefly:
   it must not create repeated popups. Closing must not immediately reopen it.
4. Use Tab/Shift+Tab within the popup. Focus must stay inside. Activate Close with
   Enter/Space. Click outside the popup and confirm background controls cannot be
   activated. The exclusive popup may require Close or go_back to dismiss.
5. Stop the preview. In its Inspector, expand the trigger's Content resource.
   Temporarily repeat the placeholder body/transcript to make several screens of
   text. Run F6; verify wrapping, mouse-wheel scrolling and keyboard scrolling
   after Tab focuses the scroll area (arrow/Page Up/Page Down keys). Close must
   stay visible. Reopen and confirm scrolling starts at the top.
6. Stop. Temporarily assign `res://icon.svg` to Content > Image as a layout-only
   placeholder. Assign a local test audio file to Narration (drag one into
   `assets/placeholders` first if needed), and label its transcript/credit as test
   content. Run F6. Confirm image proportions and no automatic audio playback.
   Click Play, Pause, Resume; also use N. Confirm pause preserves position,
   completion returns to Play, replay works, and closing stops audio. Reopen and
   play: it must start from the beginning. Remove test media afterward.
7. Temporarily duplicate the preview trigger, move it below the first and make its
   Content resource unique. Give it different test text. Verify each displays its
   own content and closing returns focus to the trigger used. Clear one Content
   resource: activating that trigger must do nothing without errors.
8. Resize the preview window smaller and larger; verify the popup remains usable,
   content scrolls and controls remain reachable. Revert temporary preview edits.
9. Press F5: the existing AKAR foundation must still run unchanged. For a browser
   check, use a disposable copy of the project with this preview as its main scene
   and a Web export preset. Serve the export over HTTP; repeat mouse, keyboard,
   scrolling and user-initiated audio checks. Do not change the real main scene.

Desktop headless loading does not replace visual, audible or browser verification.
