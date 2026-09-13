# UH-EXT-02 — Why It Was Built

## Status
Approved implementation specification for AKAR.

Treat this file as read-only historical content.
Do not alter or expand historical claims without researcher approval.

## Hotspot ID
UH-EXT-02

## Title
Why It Was Built

## Hotspot Type
Exterior historical information hotspot.

## Placement
Near the front approach, entrance path, or an information-marker location.

## Interaction Prompt
Discover its beginning

## Educational Purpose
Explain the reason for constructing the governor’s residence.

## On-Screen Title
Establishing an Official Residence

## Approved Historical Content

The concept of establishing an official residence was introduced by
Governor Juan de Guzman Rodriguez. The residence was intended to
provide a permanent place in Lingayen for provincial governors who came
from different municipalities of Pangasinan.

Construction began in 1953, establishing an official executive residence
within the provincial government complex.

## Approved Narration Transcript

Governor Juan de Guzman Rodriguez introduced the concept of
establishing a permanent official residence for the province’s governors.
Construction began in 1953, providing the provincial chief executive with a
residence within the government complex in Lingayen.

## Required Media Assets

- Approved archival or historical photograph, when available
- Current exterior photograph showing its position within the government complex
- Optional verified portrait of Governor Juan Rodriguez
- Origin/history hotspot icon
- Narration audio
- Narration transcript
- Source-credit panel

## Current Development Rules

Narration audio may be deferred if not yet available.

Do not fabricate:
- image credits
- photographer names
- archival sources
- additional biographical details about Governor Juan Rodriguez

If no verified archival image or portrait is available, the hotspot must
still function using the current exterior image and approved historical text.

## Required Interaction Behavior

1. User approaches or selects UH-EXT-02.
2. Show the prompt:
   "Discover its beginning"
3. Activating the hotspot opens the information popup.
4. Display:
   - title
   - approved historical content
   - approved image when available
   - transcript
   - source credit when verified
   - narration control only when audio exists
5. Closing returns the user to exterior exploration.
6. Activating this hotspot must remain optional.

## Accessibility / UX

- Mouse support
- Keyboard support
- E / Enter / Space activation
- Escape / Backspace closing
- Visible close button
- Keyboard focus restoration
- Readable at 1280 x 720
- Optional media must fail safely when missing

## Implementation Rules

- Reuse the existing HistoricalHotspot component.
- Do not duplicate generic popup logic.
- Keep historical content separate from GDScript.
- Do not implement UH-EXT-03.
- Do not modify the master Urduja House scene.
- Do not modify app.tscn or main.tscn.
- Do not change the application flow.
- Do not add game mechanics.

## Completion Criteria

UH-EXT-02 is individually complete when:

- standalone scene loads without errors;
- correct approved text is shown;
- image/media paths are valid;
- hotspot activates using mouse and keyboard;
- popup closes correctly;
- focus restores correctly;
- missing optional media does not break the scene;
- no source attribution has been invented;
- scene passes manual testing before master-scene integration.