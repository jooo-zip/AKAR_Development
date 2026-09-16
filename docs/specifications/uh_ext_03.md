# UH-EXT-03 — Balinese-Inspired Architecture

## Status
Approved implementation specification for AKAR.

Treat this file as read-only historical and instructional content.

Do not add architectural interpretation that has not been separately
validated by the researchers or stakeholder.

## Hotspot ID
UH-EXT-03

## Title
Balinese-Inspired Architecture

## Hotspot Type
Exterior architecture observation hotspot.

## Placement
At a viewing area where the façade and roofline are visible.

## Interaction Prompt
Examine the architecture

## Educational Purpose
Encourage users to observe the physical landmark instead of only reading
its history.

## Approved On-Screen Content

### Balinese-Inspired Architecture

Urduja House is recognized for its Balinese-inspired architectural design.
Its overall exterior character combines traditional design influence with
the practical function of an official government residence.

Observe the roofline, façade, entrance, and relationship of the building
to its landscaped surroundings.

## Approved Audio Narration Transcript

Urduja House is known for its Balinese-inspired architectural character.
Its exterior combines a distinctive traditional influence with the practical
requirements of an official government residence.

Narration audio may remain unassigned during development if it is not yet
available.

## Interactive Presentation

The user selects visual markers placed over:

1. Roofline
2. Main Façade
3. Entrance
4. Exterior Form
5. Landscaped Setting

Each marker should show only a visual label unless a more detailed
architectural interpretation has been separately validated.

Do not invent detailed descriptions.

### Approved Example Marker

Roofline

One of the most visually prominent features of the residence’s exterior
composition.

This is the only detailed example currently supplied in the approved
specification.

Do not create equivalent detailed explanations for the other four markers
unless separately validated.

## Marker Labels

Use exactly:

- Roofline
- Main Façade
- Entrance
- Exterior Form
- Landscaped Setting

## Media Assets Required

- High-resolution frontal exterior photograph
- 2D exterior artwork showing the full building
- Five interactive marker icons
- Architecture narration and transcript
- Optional zoomed images of:
  - roofline
  - façade
  - entrance
- Accessible labels for every marker

## Required Interaction Flow

1. User reaches the exterior architecture viewing area.
2. The prompt "Examine the architecture" is available.
3. Activating the main architecture interaction displays the approved
   introductory content.
4. The user may select any of the five visual markers independently.
5. Selecting a marker displays its approved label.
6. Roofline may display the approved short description.
7. The remaining markers must not display invented architectural
   explanations.
8. The user may close or leave the interaction at any time.
9. No marker is required for progression.

## Accessibility / UX

- Support mouse and keyboard.
- Markers must remain readable and distinguishable.
- Every marker requires an accessible text label.
- Do not rely only on visual placement to communicate meaning.
- Keep the interaction self-paced.
- Avoid cluttering the exterior image.
- Do not require all five markers to be selected.
- Keep text readable at the 1280 x 720 reference viewport.
- Escape / Backspace should close the active overlay through the existing
  go_back action where applicable.

## Development Architecture

UH-EXT-03 is not a simple single-popup hotspot like UH-EXT-01 or UH-EXT-02.

Prefer a small reusable architecture-marker component rather than
hard-coding five unrelated button behaviors.

Possible structure:

Architecture Interaction
├── Intro / Information Popup
├── Exterior Image / 2D Building
└── Marker Layer
    ├── Roofline Marker
    ├── Main Façade Marker
    ├── Entrance Marker
    ├── Exterior Form Marker
    └── Landscaped Setting Marker

The marker system should remain reusable for other landmarks where
appropriate.

Do not modify the existing HistoricalHotspot component merely to force it
to handle architecture markers if a separate reusable marker component is
cleaner.

## Historical / Architectural Accuracy Rules

Do not invent:
- architectural terminology;
- design influences beyond "Balinese-inspired";
- structural explanations;
- symbolic meanings;
- construction techniques;
- material descriptions;
- architect/designer information;
- claims about individual roof, façade, or entrance features.

Use only validated content.

## Narration

Narration audio may be deferred.

If narration is unavailable:
- preserve the transcript;
- do not create fake/silent audio;
- hide narration controls where appropriate.

## Source / Credit

Do not invent:
- photographer names;
- source institutions;
- dates;
- URLs.

Leave source-credit fields empty until verified.

## Do Not Implement

Do not implement:
- UH-ENT-01
- UH-INT-01
- UH-INT-02
- UH-INT-03
- UH-INT-04
- master Urduja House scene
- application-flow integration
- scoring or progression
- game mechanics

## Completion Criteria

UH-EXT-03 is individually complete when:

- standalone scene loads without errors;
- introductory architecture content is correct;
- all five markers are visible/selectable;
- marker labels match the approved specification;
- Roofline uses only the approved short description;
- no unsupported detailed descriptions are added;
- keyboard/mouse interaction works;
- focus and closing behavior work;
- optional media fails safely when absent;
- no narration or credits are fabricated;
- scene passes manual testing before master-scene integration.