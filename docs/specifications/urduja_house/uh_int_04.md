# UH-INT-04 — Conference Room

## Status

Approved implementation specification for the AKAR Urduja House walkthrough.

This specification uses the validated Urduja House interactive-hotspot content
as its historical/content source of truth.

Do not add historical claims that are not contained in validated project
materials.

---

# Hotspot Identity

## Hotspot ID

UH-INT-04

## Hotspot Title

Conference Room

## Location

Inside the publicly accessible Conference Room of Urduja House.

## Interaction Prompt

Discover its continuing function

## Educational Purpose

Show that Urduja House remains an operational government facility.

---

# Core Learning Idea

UH-INT-04 should help visitors understand that Urduja House is not only a
historically important landmark.

The Conference Room reflects its continuing official function as part of an
active government residence.

This hotspot must remain:

- educational;
- concise;
- touch-friendly;
- landscape-first;
- self-paced;
- museum-friendly;
- non-game.

---

# Approved On-Screen Content

Use the following validated content without adding new historical claims:

## Conference Room

Together with the reception spaces and Ceremonial Hall, it reflects the
continuing use of Urduja House for selected government functions.

Its inclusion helps visitors understand that the building is both historically
important and presently active.

---

# Approved Narration

Use the following narration exactly unless a later validated version is
provided:

"This conference room forms part of the publicly accessible interior of
Urduja House. Together with its reception and ceremonial spaces, it reflects
the continuing official function of the residence."

---

# Learning Takeaway

Urduja House remains a functioning government residence rather than only a
historical display.

---

# Interaction Design

UH-INT-04 should be intentionally simpler than UH-INT-01, UH-INT-02, and
UH-INT-03.

Do not add complexity simply to make the hotspot appear more interactive.

Use a compact educational interaction organized around THREE selectable
concepts:

1. PUBLIC INTERIOR
2. OFFICIAL FUNCTION
3. WHY IT MATTERS

These are not new historical claims.

They divide the existing approved information into short, visitor-friendly
learning points.

The visitor may select these concepts in any order.

No selection is required for progression.

---

# Interaction Concept

The main visual remains visible while the visitor selects one of the three
concepts.

Conceptually:

-------------------------------------------------------------
| CONFERENCE ROOM                                       [X] |
|                                                           |
| ┌────────────────────────┐ ┌────────────────────────────┐ |
| │                        │ │ OFFICIAL FUNCTION          │ |
| │   PIXEL-ART            │ │                            │ |
| │   CONFERENCE ROOM      │ │ Approved explanation      │ |
| │   ILLUSTRATION         │ │                            │ |
| │                        │ │                  [Sources] │ |
| └────────────────────────┘ └────────────────────────────┘ |
|                                                           |
| [ speaker ]                                               |
|                                                           |
| [PUBLIC INTERIOR] [OFFICIAL FUNCTION] [WHY IT MATTERS]    |
-------------------------------------------------------------

This is conceptual.

Use responsive Godot Containers where practical.

Avoid fragile absolute screen positioning.

---

# Target Deployment Context

UH-INT-04 will eventually be embedded inside a larger Urduja House interior
scene.

Therefore:

- the reusable hotspot component must adapt to the rectangle assigned by its
  parent;
- it must not assume it owns the entire application viewport;
- it must not depend on a permanent 1280 × 720 full-screen rectangle;
- internal layout should use anchors and Containers where practical.

A separate standalone UH-INT-04 scene may use a 1280 × 720 development preview
for F6 testing.

The standalone scene is only a preview wrapper.

---

# Target Devices

AKAR is intended for:

- museum touchscreen tablets;
- QR-accessed phones;
- landscape orientation;
- Web/browser deployment;
- mouse during development;
- keyboard accessibility where practical.

Reference application viewport:

1280 × 720

Also validate at:

960 × 540

854 × 480

Do not create a portrait-specific hotspot layout.

---

# Visual Consistency

UH-INT-04 must belong to the same visual family as the previous Urduja House
hotspots.

Reuse established AKAR conventions where practical:

- dark historical-interface background;
- light/cream text;
- gold active/selected state;
- consistent typography;
- Close styling;
- Sources styling;
- speaker.svg;
- approximately 48–56 px touch targets;
- focus styling;
- consistent margins and spacing.

Do not modify previous hotspots to achieve this.

---

# Main Visual Asset

The primary visitor-facing visual is:

res://assets/landmarks/urduja_house/interior/uh_int_04_conference_room_pixel_art.png

The visual is a project-created pixel-art illustration of the Conference Room.

It is NOT:

- an archival photograph;
- a historical photograph;
- official documentary photography;
- a reconstruction of the room at a historical date.

It should be treated as an illustrative representation of the present-day
Conference Room based on a photographic reference.

---

# Why Pixel Art Is Used

A neutral unoccupied official photograph of the Conference Room was not
available during development.

The available photographic reference shows the room while being used for an
official meeting.

For the visitor-facing hotspot, AKAR therefore uses a clean project-created
pixel-art illustration derived from the room's visible layout.

This avoids presenting an unrelated meeting as the primary educational image
while preserving recognizable visual characteristics of the Conference Room.

---

# Pixel-Art Visual Requirements

The illustration should show the Conference Room as a clean and unoccupied
interior.

It may visually include features represented in the approved reference image,
such as:

- the central conference table;
- surrounding conference chairs;
- wood-paneled interior surfaces;
- curtained windows;
- ceiling/chandelier details;
- display/monitor at the far side of the room.

Do not attach additional historical interpretation to these visual elements.

The illustration is for spatial/contextual understanding only.

Use nearest-neighbor texture filtering where appropriate.

Preserve aspect ratio.

Do not stretch or blur the artwork.

---

# Pixel-Art Credit

Use the following internal/source metadata:

## Asset

uh_int_04_conference_room_pixel_art.png

## Description

Pixel-art illustrative representation of the Conference Room inside Urduja
House.

## Purpose

Primary visual for UH-INT-04 — Conference Room.

## Visual Reference

A Conference Room photograph published on the official Province of Pangasinan
website in connection with the article/post captioned:

"PPC Interim Governing Board approves curricula of four academic programs"

## Created For

AKAR Capstone Project

## Creation Method

AI-assisted pixel-art illustration based on a photographic visual reference.

## Historical / Media Classification

Illustrative project visual.

Not an archival or historical photograph.

## Credit Display Rule

Visitor-facing Sources may identify the visual as:

"Pixel-art illustrative representation created for the AKAR Capstone Project."

Do not imply that the Province of Pangasinan produced the pixel-art
illustration.

---

# Reference Photograph Source Record

The photographic source used to understand the room layout must be documented
separately from the final pixel-art asset.

## Reference Type

Present-day photographic visual reference.

## Image Context

The photograph shows an official meeting taking place inside the Conference
Room.

## Published Caption / Page Context

"PPC Interim Governing Board approves curricula of four academic programs"

## Publisher / Source

Province of Pangasinan — official website.

## Source Page

https://www.pangasinan.gov.ph/author/pixelpgsnadmin/page/21/

## Photographer / Creator

Not verified.

Do not invent a photographer name.

## Exact Publication Date

Not yet verified.

Do not invent a publication date.

## Usage in AKAR

Used as a visual/layout reference for creating the UH-INT-04 Conference Room
pixel-art illustration.

The reference photograph is not intended to be the primary visitor-facing
image in UH-INT-04.

## Permission / Licensing Status

Not yet verified.

Do not claim ownership, public-domain status, Creative Commons licensing, or
specific reproduction permission unless separately confirmed.

## Development Rule

Do not use wording such as:

"Credits to the rightful owner."

Use factual source attribution instead.

---

# Image Accessibility Text

Use the following accessibility/alt description for the visitor-facing
pixel-art visual:

"Pixel-art illustration of the Conference Room inside Urduja House, showing a
long central conference table surrounded by chairs, wood-paneled interior
surfaces, curtained windows, ceiling lighting, and a display screen at the far
end of the room."

Do not include unsupported historical interpretation in the accessibility text.

---

# Concept 1 — PUBLIC INTERIOR

## Visitor-Facing Heading

Public Interior

## Content

This conference room forms part of the publicly accessible interior of Urduja
House.

## Purpose

Establish that this room belongs to the publicly accessible portion represented
in the AKAR walkthrough.

## Historical Accuracy Rule

This wording comes from the approved narration.

Do not add claims about public opening hours, access policies, specific events,
or room capacity unless separately validated.

---

# Concept 2 — OFFICIAL FUNCTION

## Visitor-Facing Heading

Official Function

## Content

Together with the reception spaces and Ceremonial Hall, it reflects the
continuing use of Urduja House for selected government functions.

## Purpose

Connect the Conference Room to the continuing official role of Urduja House.

## Historical Accuracy Rule

Do not invent examples of meetings or government functions.

Do not identify officials or agencies unless separately validated for this
hotspot.

---

# Concept 3 — WHY IT MATTERS

## Visitor-Facing Heading

Why It Matters

## Content

Its inclusion helps visitors understand that the building is both historically
important and presently active.

## Supporting Learning Takeaway

Urduja House remains a functioning government residence rather than only a
historical display.

## Presentation

The learning takeaway may be visually emphasized using the existing AKAR gold
highlight or a simple takeaway panel.

Do not present it as a quiz reward, achievement, or completion message.

---

# Default State

When UH-INT-04 opens:

- PUBLIC INTERIOR is selected by default;
- the Conference Room pixel-art visual is displayed;
- the Public Interior text appears;
- speaker remains inactive;
- narration does not autoplay.

---

# Concept Selection Behavior

The visitor may tap:

PUBLIC INTERIOR

OFFICIAL FUNCTION

WHY IT MATTERS

Selecting a concept should:

- update the selected state;
- update the right-side heading;
- update the displayed explanation;
- preserve the main room visual;
- preserve narration playback if narration is already playing.

Use a short subtle transition if desired.

Recommended transition duration:

150–250 ms.

Do not use:

- bouncing;
- spinning;
- large zooms;
- flashy effects;
- game-like animation.

---

# Selected State

Only one concept should appear selected at a time.

Use established AKAR active-state styling such as:

- gold highlight;
- stronger border;
- focus indication;
- selected-button treatment.

Do not rely only on color.

---

# Narration Asset

Use:

res://assets/landmarks/urduja_house/audio/uh_int_04_narration.ogg

Only ONE narration stream is required for the whole UH-INT-04 hotspot.

Do not create separate narration files for the three concepts.

---

# Narration Behavior

Reuse the simplified narration behavior established in previous Urduja House
hotspots.

## Inactive

- speaker is visible when approved narration exists;
- tapping the speaker begins narration from the start.

## Playing

- speaker receives the established active/highlight state;
- tapping the speaker again stops narration;
- playback resets to the beginning.

## Natural Completion

- return the speaker to inactive state;
- reset playback so the next tap starts from the beginning.

Do not provide separate:

- Pause;
- Resume;
- Restart

buttons.

Narration must never autoplay.

---

# Narration and Concept Selection

Narration belongs to the WHOLE UH-INT-04 interaction.

If narration is playing and the visitor changes:

PUBLIC INTERIOR
→ OFFICIAL FUNCTION
→ WHY IT MATTERS

the narration should continue normally.

Concept changes must NOT:

- stop narration;
- restart narration;
- seek playback;
- change the narration stream;
- autoplay audio.

Opening or closing Sources must also not interrupt narration.

Closing the complete UH-INT-04 interaction must stop/reset narration.

Reopening UH-INT-04 must remain silent until the speaker is tapped.

---

# Speaker Icon

Reuse:

res://assets/ui/icons/speaker.svg

Do not create another speaker icon.

Recommended touch target:

approximately 56 × 56 logical pixels.

The visible icon may be smaller inside the touch area.

---

# Sources Behavior

Provide a touch-accessible Sources control.

Sources should reflect the currently displayed media/content.

For UH-INT-04, the main Sources panel may contain:

## Historical / Educational Content

Validated AKAR Urduja House Conference Room hotspot content.

Use exact formal citation/source information only when supplied by the project
researcher.

Do not invent bibliography entries.

## Visitor-Facing Illustration

Pixel-art illustrative representation created for the AKAR Capstone Project.

## Visual Reference

Based on a Conference Room photograph published by the Province of Pangasinan
in connection with:

"PPC Interim Governing Board approves curricula of four academic programs"

## Reference Status

Used as a visual/layout reference.

The reference photograph itself is not presented as an archival or historical
photograph.

Do not show development brackets or fake credits in production UI.

---

# Sources and go_back

When Sources is open:

go_back closes Sources first.

Otherwise:

go_back closes UH-INT-04.

Preserve safe go_back handling before signals can remove active UI.

---

# Main Layout

Use a compact two-column embedded-friendly layout.

## Left

- Conference Room pixel-art illustration.

## Right

- selected concept heading;
- selected concept text;
- optional learning takeaway when relevant;
- Sources.

## Lower Area

- speaker;
- three concept-selection controls.

The layout should remain usable when embedded inside a parent hotspot frame.

---

# Embedded Component Requirement

The reusable interaction must size itself relative to its parent.

Do not directly calculate layout from the application viewport unless absolutely
necessary.

Preferred architecture:

Parent Scene
└── HotspotFrame
    └── UH-INT-04 reusable component

The component should use:

- full-rect anchors relative to parent where appropriate;
- Containers;
- responsive margins;
- local scrolling where needed.

---

# Standalone Preview Scene

Create:

res://scenes/landmarks/urduja_house/interior/uh_int_04.tscn

The scene must run independently with F6.

The standalone scene should act as a development preview wrapper.

Recommended conceptual structure:

UH_INT_04_Preview
├── PreviewBackground
├── InteractionPrompt
└── HotspotFrame
    └── ConferenceRoomInteraction

The HotspotFrame should be inset from the full viewport so the developer can
verify how UH-INT-04 behaves when embedded in another scene.

Do NOT build the final Urduja House interior during this milestone.

---

# Reusable Architecture

Before creating new components, inspect the repository.

Do not overload unrelated components such as:

HistoricalHotspot

HistoricalVideoInteraction

InteractiveArtworkViewer

InteractiveTimeline

CeremonialHallInteraction

UH-INT-04 has a simpler continuing-function interaction.

If no appropriate reusable component exists, a small component may be created,
for example:

res://scenes/components/conference_room_interaction.tscn

res://scripts/components/conference_room_interaction.gd

res://scripts/components/conference_room_content.gd

Avoid unnecessary abstractions.

---

# Content Data Model

Historical/educational content should not be hard-coded directly into generic
behavioral GDScript.

Create:

res://data/landmarks/urduja_house/uh_int_04.tres

A simple content model may contain:

- hotspot title
- interaction prompt
- primary illustration
- illustration alt text
- narration stream
- narration transcript
- source credit
- learning takeaway
- concept entries

Each concept entry may contain:

- heading
- body
- optional emphasis/takeaway

Keep the architecture simple.

---

# Suggested Public Methods

Where consistent with repository conventions:

open_interaction()

close_interaction()

select_concept(index)

get_selected_concept()

open_sources()

close_sources()

toggle_narration()

stop_narration()

---

# Suggested Signals

Where appropriate:

signal opened

signal closed

signal concept_changed(index: int)

signal narration_started

signal narration_stopped

signal sources_opened

signal sources_closed

Do not hard-code application navigation.

---

# Touch Requirements

Important controls should provide approximately 48 px minimum interactive size
where practical:

- Close;
- Sources;
- Speaker;
- Public Interior;
- Official Function;
- Why It Matters.

Nothing essential should require hover.

---

# Keyboard Accessibility

Where practical, support:

- Tab;
- Shift+Tab;
- Enter;
- Space;
- Escape;
- Backspace / go_back.

Concept controls should be focusable.

Do not require keyboard for the visitor experience.

---

# Smaller Landscape Behavior

Validate the application at:

1280 × 720

960 × 540

854 × 480

Also validate the hotspot inside an inset parent frame.

At smaller landscape sizes:

- preserve the two-column concept where practical;
- keep the illustration visible;
- keep concept controls reachable;
- keep Close reachable;
- keep Sources reachable;
- keep Speaker reachable;
- use local scrolling for text if needed;
- avoid excessively shrinking fonts;
- do not create a portrait-specific rearrangement.

---

# Rapid Input Safety

Visitors may rapidly select the three concepts.

If transitions are used:

- cancel/replace old transitions cleanly;
- prioritize the latest selection;
- do not queue multiple animations;
- do not leave content semi-transparent;
- do not duplicate controls.

---

# Do Not Implement

Do NOT implement:

- quizzes;
- scoring;
- rewards;
- achievements;
- room-capacity information;
- meeting schedules;
- participant identification;
- government-office details not included in validated material;
- timeline/history not approved for this hotspot;
- additional photographs presented as verified room documentation;
- game mechanics;
- completion tracking;
- global lobby integration;
- Restricted Area interaction;
- UH-END-01;
- analytics;
- QR generation;
- accounts;
- database functionality;
- portrait layout.

Stop after UH-INT-04.

---

# Manual Testing Requirements

Create:

res://docs/uh_int_04_testing.md

Test:

## Initial

- standalone preview opens;
- prompt works;
- Public Interior is selected by default;
- pixel-art image appears correctly;
- no narration autoplay.

## Public Interior

- correct heading;
- approved wording;
- image remains visible;
- Sources works.

## Official Function

- selection works;
- approved wording appears;
- visual remains stable;
- narration continues if already playing.

## Why It Matters

- selection works;
- approved wording appears;
- learning takeaway is readable;
- no game-like completion treatment.

## Pixel-Art Visual

- nearest-neighbor appearance is preserved;
- image is not blurred;
- aspect ratio is preserved;
- illustration is not described as an archival/historical photograph.

## Narration

- first tap plays from beginning;
- second tap stops/reset;
- natural completion returns inactive;
- concept changes do not interrupt playback;
- Sources does not interrupt playback;
- full close stops/reset;
- reopen remains silent.

## Sources

- illustration credit is accurate;
- Province of Pangasinan reference is identified as a visual reference;
- no photographer is invented;
- no publication date is invented;
- no license/permission claim is invented;
- go_back closes Sources first.

## Touch

- Close;
- Sources;
- Speaker;
- all three concept controls.

## Keyboard

- Tab;
- Enter;
- Space;
- Escape;
- Backspace.

## Viewports

- 1280 × 720;
- 960 × 540;
- 854 × 480;
- inset/embedded parent frame.

## Reliability

- rapid concept switching;
- repeated narration play/stop;
- repeated Sources open/close;
- repeated open/close;
- no duplicate UI;
- no broken focus;
- no Godot runtime errors.

---

# Capstone Alignment

UH-INT-04 supports AKAR's design and development objective by integrating:

- validated educational content;
- a visual representation of an accessible interior space;
- touch-based content exploration;
- optional narration;
- source acknowledgment.

The hotspot helps communicate the continuing official function of Urduja House.

It does not claim to measure or prove learning effectiveness.

---

# Historical Accuracy Rule

Use only the validated Conference Room content supplied for UH-INT-04.

Do not silently add information from other Urduja House sections.

Do not use the reference photograph as evidence for additional historical
claims.

The visual reference may guide the illustration's room layout, but visual
features visible in the photograph should not automatically be converted into
historical interpretations.

---

# Final Implementation Goal

UH-INT-04 should communicate one clear idea:

Urduja House remains an active government residence.

The visitor should be able to understand that message quickly through:

- a clean Conference Room illustration;
- three concise selectable concepts;
- one narration;
- a clear learning takeaway;
- transparent source acknowledgment.

The interaction should remain compact enough to be embedded inside the future
Urduja House interior scene without behaving like a separate full-screen
application.