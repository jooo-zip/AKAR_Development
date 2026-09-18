# UH-INT-02 — Urduja House Through Time

## Status

Approved implementation specification for the AKAR Urduja House walkthrough.

This specification uses the validated Urduja House interactive-hotspot content
as its historical source of truth.

Do not add historical claims that are not contained in validated project
materials.

---

## Hotspot ID

UH-INT-02

## Hotspot Title

Urduja House Through Time

## Location

Virtual Lobby — information desk.

## Interaction Prompt

Explore the timeline

## Educational Purpose

Allow the visitor to experience the historical development and changing
function of Urduja House through an interactive chronological timeline.

---

# Core Interaction Concept

UH-INT-02 must be an interactive TOUCH-DRIVEN SNAP TIMELINE.

Do NOT implement the timeline as:
- static text;
- four ordinary information cards;
- Previous / Next buttons;
- mandatory linear progression.

The visitor should physically interact with the timeline by:

- dragging a time-marker handle along the timeline;
- releasing the handle near a milestone;
- having the marker snap to the nearest approved milestone;
- tapping a milestone directly to move to it;
- viewing the corresponding image and historical information;
- optionally listening to narration for the selected milestone.

The visitor may select milestones in any order.

No milestone is required for progression.

---

# Target Visitor Experience

AKAR is designed for:

- museum touchscreen tablets;
- QR-accessed phones;
- landscape orientation;
- mouse during development;
- keyboard accessibility where practical.

Reference viewport:

1280 × 720

Also support smaller landscape configurations such as:

960 × 540
854 × 480

The interaction must be:

- touch-first;
- landscape-first;
- readable;
- self-paced;
- museum-friendly;
- usable without hover.

Do not create a portrait-specific layout.

---

# Visual Consistency With Existing AKAR Hotspots

UH-INT-02 must visually belong to the same interface family as UH-INT-01 and
the other implemented Urduja House hotspots.

Reuse established AKAR conventions where practical:

- overall popup/panel styling;
- typography;
- gold active/highlight state;
- button shapes;
- Close button styling;
- Sources button styling;
- approximately 48–56 px touch controls;
- speaker.svg narration icon;
- spacing and margins;
- dark/brown historical-interface palette;
- focus styling;
- source/credit overlay behavior.

Consistency does NOT require copying the exact UH-INT-01 layout.

UH-INT-02 has its own timeline interaction, but its visual language should feel
like the same AKAR application.

Do not modify UH-INT-01 to achieve this.

---

# Overall Landscape Layout

Recommended structure:

---------------------------------------------------------------
| URDUJA HOUSE THROUGH TIME                              [X] |
|                                                             |
| ┌──────────────────────┐   ┌──────────────────────────────┐ |
| │                      │   │ 1953 — ESTABLISHMENT         │ |
| │   EVENT IMAGE        │   │                              │ |
| │                      │   │ Approved historical          │ |
| │                      │   │ explanation                  │ |
| │                      │   │                              │ |
| └──────────────────────┘   │                    [Sources] │ |
|                            └──────────────────────────────┘ |
|                                                             |
| [speaker icon]                                              |
|                                                             |
| 1953       1953–2007          2007              PRESENT     |
|  ●────────────●────────────────●──────────────────●          |
|             draggable time-marker handle                    |
---------------------------------------------------------------

This is conceptual.

Use Godot Containers where practical.

Avoid fragile absolute positioning.

---

# Main Content Area

Use a two-column presentation similar in visual balance to UH-INT-01.

LEFT:
- selected milestone image.

RIGHT:
- selected date / period;
- event title;
- approved explanation;
- Sources control.

The timeline occupies the lower area of the interaction.

The image and content should update when the selected milestone changes.

---

# Timeline Milestones

Implement exactly FOUR approved milestone states.

Do not add additional dates without separate validation.

---

## TIMELINE 1

### Date

1953

### Event Title

Establishment

### Approved Content

Construction of the official governor’s residence began, and the building was
originally named Princess Urduja Palace.

---

## TIMELINE 2

### Date

1953–2007

### Event Title

Residence and Office

### Approved Content

Urduja House served as both the Governor’s Residence and the Governor’s Office.

---

## TIMELINE 3

### Date

2007

### Event Title

Transfer of the Daily Office

### Approved Content

During the administration of Governor Amado T. Espino Jr., the Governor’s
daily office was transferred to the Pangasinan Provincial Capitol.

---

## TIMELINE 4

### Date

Present

### Event Title

Continuing Official Role

### Approved Content

Urduja House remains the official residence of the Governor of Pangasinan.
Its Ceremonial Hall continues to serve as a venue for selected official
functions.

---

# Timeline Slider

The timeline should behave as a discrete educational timeline, not a normal
continuous numeric slider.

There are exactly four selectable states:

0 = 1953
1 = 1953–2007
2 = 2007
3 = Present

The timeline may internally use numeric indexes, but visitor-facing labels must
use the approved dates/periods.

The milestones should be visually distributed clearly across the timeline.

This is an educational navigation timeline.

It does NOT need to represent exact proportional calendar distance between
milestones.

---

# Snap Slider Behavior

The slider should contain:

- timeline track;
- four visible milestone nodes;
- four visible date labels;
- draggable time-marker handle.

The visitor may:

1. drag the marker;
2. release it;
3. marker snaps to the nearest milestone.

The visitor may also tap/click any milestone node or its date label.

When directly selected:

- move the handle to that milestone;
- update selected state;
- update image;
- update date/title;
- update approved historical text;
- update event narration reference;
- update source information.

The selected milestone must remain visibly identifiable.

---

# Time-Marker Handle

Use a compact time-related visual for the draggable handle.

Preferred concept:

- clock/time icon inside a circular marker.

The handle must:

- remain easy to see;
- have a comfortable touch hit area;
- visually belong to the AKAR interface;
- not look like a game collectible.

Recommended interactive area:

approximately 48 × 48 to 56 × 56 logical pixels.

If an appropriate time/clock UI icon already exists, reuse it.

Otherwise a simple local SVG may be created, consistent with the existing
speaker.svg style.

Suggested path if a new icon is needed:

res://assets/ui/icons/timeline_clock.svg

Do not use external web resources.

---

# Direct Milestone Selection

Dragging must NOT be the only way to navigate.

Each milestone/date must also be tappable.

This is required for:

- accessibility;
- phones;
- visitors who find dragging difficult.

A visitor should be able to tap:

1953

or:

2007

and immediately move to that timeline state.

---

# Selected Milestone State

The selected milestone should use the same AKAR active visual language used in
previous interactions.

For example:

- gold highlight;
- stronger border;
- highlighted date;
- brighter milestone node.

Only one milestone should appear selected at a time.

---

# Speaker Icon Placement

Use the SAME speaker icon visual language established in UH-INT-01.

Reuse:

res://assets/ui/icons/speaker.svg

The speaker control must be located:

DIRECTLY ABOVE THE SNAP TIMELINE SLIDER

and:

LEFT-ALIGNED WITH THE BEGINNING OF THE TIMELINE.

Do NOT place the speaker beside the event title.

Do NOT place separate Listen / Pause / Restart buttons.

Conceptually:

[speaker icon]

1953       1953–2007       2007       Present
 ●────────────●──────────────●────────────●
              time handle

The speaker visually belongs to the selected timeline narration.

---

# Narration Concept

UH-INT-02 uses ONE narration audio file for the entire timeline interaction.

The narration provides a short overall spoken summary of the historical
development of Urduja House represented by the four approved milestones.

The narration does NOT belong to an individual milestone.

Narration is optional and must never autoplay.

---

# Narration Asset

Use:

res://assets/landmarks/urduja_house/audio/uh_int_02_narration.ogg

Do not create separate narration files for:

- 1953;
- 1953–2007;
- 2007;
- Present.

If the approved narration audio is unavailable:

- do not synthesize narration;
- do not use text-to-speech;
- do not fabricate an audio file;
- production may hide the speaker control;
- development may show a clearly disabled audio-pending state.

---

# Speaker Button Behavior

Use the same simplified speaker behavior established in UH-INT-01.

INACTIVE:

- speaker icon is visible when approved narration audio exists;
- tapping it starts the complete UH-INT-02 narration from the beginning.

PLAYING:

- speaker receives a visible active/highlight state;
- tapping it again stops narration;
- playback resets to the beginning.

FINISHED:

- speaker returns to its inactive state;
- the next tap starts narration from the beginning.

Do not expose separate:

- Pause;
- Resume;
- Restart

controls.

---

# Narration and Timeline Interaction

The narration and the snap timeline operate independently.

If narration is playing while the visitor:

- drags the timeline;
- snaps to another milestone;
- taps another milestone;
- changes from 1953 to Present;
- revisits a previous milestone;
- opens or closes Sources;

the narration should continue normally.

Changing the selected timeline milestone must NOT:

- stop narration;
- restart narration;
- change the audio stream;
- autoplay narration;
- seek to another audio position.

Only closing the complete UH-INT-02 interaction should stop and reset the
narration.

When UH-INT-02 is reopened, narration must remain stopped until the visitor
taps the speaker again.

---

# Narration Transcript

Use one transcript corresponding exactly to:

uh_int_02_narration.ogg

Do not create separate transcripts for individual milestones unless the audio
design is formally revised later.

Do not invent narration wording.

The transcript must match the final researcher-approved recording.

# Timeline Images

UH-INT-02 intentionally uses different image availability across milestones.

## 1953 — Establishment

No image is assigned.

Display a deliberate neutral no-image state.

Suggested visitor-facing treatment:

- timeline/clock visual;
- clean historical-media placeholder area.

Do not show a broken-image icon.

Do not generate or fabricate an archival photograph.

---

## 1953–2007 — Residence and Office

Use:

res://assets/landmarks/urduja_house/interior/uh_int_02_historical.jpg

---

## 2007 — Transfer of the Daily Office

Use the SAME approved historical image:

res://assets/landmarks/urduja_house/interior/uh_int_02_historical.jpg

Do not imply that the photograph was specifically taken in 2007 unless this is
confirmed by the verified source information.

---

## Present — Continuing Official Role

Use:

res://assets/landmarks/urduja_house/interior/uh_int_02_present.jpg

---

All images must preserve their aspect ratio.

Do not generate archival photographs.

Do not present AI-generated imagery as historical documentation.

# Source Acknowledgment

The approved hotspot requires source acknowledgment for each selection.

Each milestone should support its own image/content source field.

Provide a touch-accessible:

Sources

button.

The Sources panel should reflect the CURRENTLY SELECTED milestone.

Only verified source information may be displayed.

If source metadata has not yet been supplied:

- keep the field empty;
- do not invent photographer names;
- do not invent archive names;
- do not invent URLs;
- do not use "Credits to the rightful owner."

Development placeholders may exist in documentation but should not appear as
fake production credits.

---

# Smooth Timeline Transition

Changing milestones should feel polished but remain fast.

Use a short smooth transition.

Recommended behavior:

1. visitor selects/drags to another milestone;
2. handle snaps smoothly to selected milestone;
3. outgoing image/content subtly fades;
4. selected content updates;
5. incoming image/content fades in.

Keep total interaction transition short.

Suggested range:

approximately 150–250 milliseconds.

Do not use long cinematic animations.

Do not use bouncing, spinning, flashy zooming, or game-like effects.

---

# Transition Safety

Avoid overlapping tweens.

If the visitor changes milestones rapidly:

- stop or replace the current transition cleanly;
- show the latest requested milestone;
- do not queue multiple long animations;
- do not leave content semi-transparent;
- do not produce duplicate UI.

---

# Touch Dragging

Dragging should work naturally on the museum tablet.

However:

dragging is an enhancement, not the only navigation method.

Provide milestone tapping as an accessible alternative.

Do not disable normal touch interaction elsewhere in the panel.

Do not require pixel-perfect dragging.

---

# Historical Sequence

The timeline visually communicates movement through the changing function of
Urduja House:

1953
→ establishment

1953–2007
→ residence and office

2007
→ daily office transfer

Present
→ continuing official residence and ceremonial role

Do not imply that these are the only events in the complete history of Urduja
House.

They are the selected milestones approved for this hotspot.

---

# No Forced Progression

The visitor may:

- drag from 1953 directly to Present;
- tap 2007 first;
- return to 1953;
- revisit milestones repeatedly.

Do not require chronological completion.

Do not record:
- timeline completion percentage;
- rewards;
- achievements;
- unlocked milestones.

---

# Reusable Architecture

Before coding, inspect the repository.

Do not overload:

HistoricalHotspot

HistoricalVideoInteraction

InteractiveArtworkViewer

UH-INT-02 has a distinct timeline interaction.

If no appropriate timeline component exists, create a small reusable component
such as:

res://scenes/components/interactive_timeline.tscn

res://scripts/components/interactive_timeline.gd

and, if useful:

res://scripts/components/interactive_timeline_content.gd

Keep the component generic enough for future AKAR historical timelines.

Do not place Urduja House-specific historical paragraphs in generic behavioral
GDScript.

---

# Suggested Timeline Data Model

Each timeline entry may contain:

- date_label
- event_title
- body
- image
- image_alt_text
- narration_stream
- narration_transcript
- source_credit

UH-INT-02 data should live in:

res://data/landmarks/urduja_house/uh_int_02.tres

Avoid unnecessary complexity.

---

# Suggested Component Responsibilities

InteractiveTimeline may handle:

- opening/closing;
- timeline state;
- slider dragging;
- snapping;
- direct milestone selection;
- selected milestone styling;
- content/image updates;
- short transitions;
- optional narration;
- source overlay;
- go_back;
- focus restoration.

It must NOT contain historical facts directly.

---

# Public Signals

Where appropriate use signals such as:

signal opened
signal closed
signal milestone_changed(index: int)
signal narration_started(index: int)
signal narration_stopped(index: int)
signal sources_opened
signal sources_closed

Names may follow existing repository conventions.

Do not hard-code application navigation.

---

# Standalone Scene

Create:

res://scenes/landmarks/urduja_house/interior/uh_int_02.tscn

The scene must be independently runnable with F6.

It should demonstrate:

- interaction prompt;
- timeline;
- dragging;
- snapping;
- milestone taps;
- smooth transitions;
- images/placeholders;
- speaker behavior;
- Sources;
- Close/back behavior.

Do not build the complete lobby.

---

# Focus / Back Behavior

On opening:
focus a sensible timeline control.

If Sources is open:
go_back closes Sources first.

Otherwise:
go_back closes UH-INT-02.

If narration is playing when the full viewer closes:
stop/reset narration.

Restore previous focus owner where practical.

---

# Touch Target Requirements

Important controls should use approximately 48 px minimum interactive size where
practical:

- timeline handle;
- milestone controls;
- speaker;
- Sources;
- Close.

Date text may visually be smaller, but its associated touch target should be
comfortably sized.

---

# Accessibility

Provide readable event headings and body text.

Do not rely only on color to identify the selected timeline point.

Use selected state plus another cue such as:
- border;
- node size;
- focus style.

Images should support short descriptive alt/accessibility text without
unsupported historical interpretation.

---

# Smaller Landscape Behavior

At 1280 × 720:
show the complete intended timeline experience.

At 960 × 540 and 854 × 480:

- maintain landscape presentation;
- timeline remains fully visible;
- milestone labels remain readable;
- speaker remains above the left side of the timeline;
- Close remains reachable;
- Sources remains reachable;
- image and text do not overlap;
- allow content-panel scrolling if required;
- do not make fonts excessively small.

Do not introduce portrait stacking.

---

# Development Placeholders

If milestone images, audio, or source credits are not yet supplied:

use clearly identified development-only placeholders.

Do NOT fabricate historical assets.

A placeholder must not look like an authenticated archival image.

---

# Do Not Implement

Do NOT implement:

- Previous / Next buttons;
- quiz questions;
- scoring;
- achievements;
- locked dates;
- forced progression;
- timeline completion tracking;
- global lobby integration;
- UH-INT-03;
- UH-INT-04;
- restricted-area interaction;
- UH-END-01;
- QR implementation;
- analytics;
- portrait layout.

Stop after UH-INT-02.

---

# Capstone Alignment

UH-INT-02 supports AKAR's design and development objective by integrating:

- validated historical content;
- chronological interaction;
- approved visual media;
- optional narration;
- source acknowledgment.

The slider is an educational navigation mechanism.

It is not a game mechanic.

Do not claim that the timeline proves improvement in learning effectiveness.

---

# Manual Testing Requirements

Test at:

1280 × 720
960 × 540
854 × 480

Verify:

- scene fits;
- prompt works;
- 1953 is default;
- slider drag works;
- release snaps to nearest milestone;
- direct milestone tap works;
- user may jump to any milestone;
- selected state is obvious;
- all four approved texts are correct;
- image changes correctly;
- transitions are smooth;
- rapid selection does not break transitions;
- speaker sits above the left side of timeline;
- speaker controls selected milestone narration only;
- timeline change stops old narration;
- new timeline selection does not autoplay;
- Sources reflect current milestone;
- no fabricated source appears;
- go_back works;
- touchscreen targets are comfortable;
- no hover-only behavior;
- no game mechanic;
- no Godot errors.

---

# Historical Accuracy Rule

Use only the four approved timeline milestones:

1953 — Establishment

1953–2007 — Residence and Office

2007 — Transfer of the Daily Office

Present — Continuing Official Role

Do not silently add events from other historical-profile sections.

Additional dates require separate approval before inclusion.