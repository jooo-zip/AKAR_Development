# UH-EXT-01 — Meet Urduja House

## Status
Approved implementation specification for AKAR.

This document is a development source of truth.
Do not modify historical facts, dates, wording, or interpretation without
researcher approval.

## Hotspot ID
UH-EXT-01

## Title
Meet Urduja House

## Hotspot Type
Exterior historical information hotspot.

## Placement
At the gate, driveway entrance, or visitor arrival point.

## Interaction Prompt
Discover this landmark

## Educational Purpose
Introduce the building before presenting dates and detailed history.

## On-Screen Title
Urduja House

## On-Screen Historical Content

Urduja House stands within the provincial government complex in
Lingayen. Constructed in 1953 and originally known as Princess Urduja
Palace, it has served for more than seven decades as the official residence
of the Governor of Pangasinan.

Today, it remains an active government landmark connected with
provincial leadership, public service, and Pangasinan’s cultural identity.

## Audio Narration

Urduja House is the official residence of the Governor of Pangasinan.
Constructed in 1953 and originally known as Princess Urduja Palace, the
residence has remained an important symbol of provincial leadership for
more than seven decades.

## Required Media Assets

- Approved present-day exterior photograph
- 2D exterior sprite or pixel-art reconstruction
- Landmark-information hotspot icon
- Narration audio
- Narration transcript
- Image credit and source metadata

## Optional Media

- Ambient exterior audio recorded on-site

## Required Interaction Behavior

1. User approaches or selects the UH-EXT-01 information hotspot.
2. The hotspot displays the prompt:
   "Discover this landmark"
3. Activating the hotspot opens the historical information popup.
4. The popup presents:
   - title
   - approved historical text
   - approved exterior photograph when supplied
   - narration control when narration audio is supplied
   - narration transcript
   - image/source credit
   - close control
5. User may close the popup without completing any other hotspot.
6. Closing the popup returns the user to exterior exploration.

## Accessibility / UX

- Support mouse interaction.
- Support keyboard interaction.
- E / Enter / Space may activate the hotspot according to existing AKAR controls.
- Escape / Backspace should close the information popup through the existing
  go_back action.
- Text must remain readable at the project's 1280 x 720 reference viewport.
- Do not require narration to continue.
- If narration is unavailable, hide the narration control.
- If an image is unavailable, the hotspot must still work.
- Source/credit information must remain available when supplied.

## Implementation Rules

- Reuse the existing reusable historical information hotspot component.
- Do not duplicate the generic popup logic.
- Keep the approved historical content separate from GDScript behavior.
- Do not implement UH-EXT-02 or later hotspots in this milestone.
- Do not modify the application flow yet.
- Do not merge this scene into the Urduja House master scene yet.
- Placeholder media may be used only when the final asset has not been supplied.
- Placeholder media must be clearly identifiable as non-production content.
- Do not invent additional historical facts.
- Do not add game mechanics.

## Completion Criteria

UH-EXT-01 is considered individually complete when:

- the scene loads without errors;
- the hotspot can be activated by mouse and keyboard;
- the correct approved content appears;
- optional media behaves safely when absent;
- narration works when an audio asset is assigned;
- transcript and source credit display correctly;
- closing restores exploration/focus correctly;
- there are no GDScript or missing-resource errors;
- the scene can be tested independently before master-scene integration.