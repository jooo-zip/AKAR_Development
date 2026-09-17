# UH-INT-01 — Princess Urduja Painting

## Status

Approved implementation specification for the AKAR Urduja House walkthrough.

This specification uses the validated Urduja House interactive-hotspot content
as its historical source of truth.

Do not add historical claims that are not contained in the validated project
materials.

---

## Hotspot ID

UH-INT-01

## Hotspot Title

Princess Urduja Painting

## Location

Virtual Lobby — directly on or near the Princess Urduja painting.

## Interaction Prompt

Discover the story behind the name

## Educational Purpose

Explain why the residence was named after Princess Urduja while distinguishing
cultural tradition from historical certainty.

The interaction should encourage visitors to inspect the artwork and choose
which aspect of its historical and cultural meaning they want to explore.

---

# Interaction Design

UH-INT-01 must be an interactive artwork exploration experience.

It must NOT be implemented as only a static text popup.

The visitor should be able to:

- open the painting interaction;
- inspect the full artwork;
- switch to a controlled artwork inspection;
- choose among three educational sections;
- change sections without closing the interaction;
- optionally listen to narration;
- open source / artwork-credit information;
- close the interaction at any time.

No section is required for progression.

Do not add:
- points;
- scores;
- rewards;
- achievements;
- completion requirements;
- quizzes;
- locked sections;
- game mechanics.

---

# Target Device Experience

AKAR is intended primarily for touchscreen tablets and later for phone access
through a QR code.

The intended orientation is LANDSCAPE.

Reference development viewport:

1280 × 720

The interface must be:

- touch-first;
- landscape-first;
- suitable for museum tablets;
- usable on smaller phone screens in landscape;
- readable without requiring a keyboard;
- usable without hover;
- responsive when the landscape browser window becomes smaller.

Do not create a separate portrait version of UH-INT-01.

Portrait orientation handling will be implemented separately at the application
level.

All important controls must remain visible and tappable in landscape mode.

Use comfortably sized touch targets. Prefer approximately 44–48 px minimum
interactive dimensions where practical.

---

# Main Layout

Use a two-column landscape composition.

LEFT SIDE:
- artwork image;
- one compact speaker button below the image and above the artwork-mode row;
- artwork-view controls.

RIGHT SIDE:
- selected educational section title;
- selected educational content;
- source / artwork-credit control.

The three learning-section controls should remain prominent and easy to tap.

Suggested visual structure:

---------------------------------------------------------------
| Princess Urduja Painting                               [X] |
|                                                             |
|  ARTWORK IMAGE               SELECTED SECTION               |
|  ARTWORK IMAGE               Educational content            |
|  ARTWORK IMAGE                                              |
|                                                             |
|  [SPEAKER]                                                  |
|  [FULL ARTWORK] [INSPECT ARTWORK]     [THE ARTWORK]                  |
|                              [THE LEGEND]                   |
|                              [CULTURAL SIGNIFICANCE]        |
|                                                             |
|                              [Sources / Artwork Credit]    |
---------------------------------------------------------------

The exact visual styling may follow established AKAR UI conventions.

---

# Artwork Asset

Primary image:

res://assets/landmarks/urduja_house/interior/uh_int_01_princess_urduja_painting.jpg

This is the approved primary image supplied for UH-INT-01.

Do not alter the historical content of the artwork.

Do not generate a replacement painting.

Do not use an AI reconstruction in place of the approved painting.

The image should preserve its aspect ratio.

Do not stretch or distort it.

---

# Artwork Inspection

## Full Artwork

Default artwork mode. Display the complete approved painting without cropping,
preserve its aspect ratio, and visibly select Full Artwork. Repeated activation
retains the selected state. Full Artwork and Inspect Artwork are mutually
exclusive modes.

## Inspect Artwork

Open an inspection panel using only the approved primary painting. Provide four
large, selectable neutral spatial controls with exactly these labels:

- Central Figure
- Left-side Scene
- Right-side Scene
- Lower Details

Use resource-defined normalized crop rectangles or Godot-native AtlasTexture
regions. Do not create duplicate cropped image files or a replacement painting.
Selecting a region updates the crop and its selected state in place. A neutral
“Viewing: …” label may identify the selection. Do not add interpretations or
historical descriptions of objects in the painting.

Keep educational section selection and region selection independent; changing
one must not reset the other. The selected educational content can remain readable
inside inspection. No region or section is required.

Respect the supplied image's limited resolution: use conservative enlargement,
no unrestricted zoom, pinch zoom, wheel zoom, or arbitrary magnification.

Provide Back to Full Artwork. Returning restores the complete painting, Full
Artwork's selected state, and sensible keyboard focus. Nested back priority is
Sources, then Inspect Artwork, then the entire interaction. Consume go_back before
emitting signals that could remove the UI.

Use controls at least roughly 48 logical pixels high, visible selected states,
and readable text at 1280 × 720, 960 × 540, and 854 × 480. Two rows of region
controls and scrolling educational text may be used. Avoid horizontal overflow.

---

# Learning Sections

Use exactly THREE selectable educational sections:

1. THE ARTWORK
2. THE LEGEND
3. CULTURAL SIGNIFICANCE

The visitor may select the sections in any order.

The selected section must be visually identifiable.

Changing sections should update the content panel without closing the hotspot.

A subtle transition is allowed.

Do not use distracting animation.

Optional touchscreen swipe navigation may be supported as a secondary feature,
but visible buttons must remain the primary navigation method.

The interaction must never depend on swipe gestures alone.

---

# SECTION 1 — THE ARTWORK

## Display Title

Princess Urduja Painting

## Approved Content

A painting of Princess Urduja by Romeo Mananquil is displayed near the
entrance of Urduja House. Its placement connects the residence with the
cultural figure after whom it was named.

Do not expand this text with unsupported information about:
- artistic style;
- symbolism;
- painting date;
- dimensions;
- materials;
- commission history;
- ownership;
- individual objects depicted in the artwork.

Those details require separate validation.

---

# SECTION 2 — THE LEGEND

## Display Title

The Legend

## Approved Content

Princess Urduja is described as a legendary warrior figure associated with
Pangasinan. Accounts connected with the fourteenth-century travels of Ibn
Battuta describe a warrior princess in the kingdom of Tawalisi.

Historians continue to debate whether Princess Urduja was an actual historical
person or a legendary heroine.

## Historical Presentation Rule

The interface must preserve the uncertainty expressed in the approved content.

Do NOT present Princess Urduja's historical existence as definitively proven.

Do NOT state that Tawalisi has been conclusively identified as Pangasinan.

The distinction between cultural tradition and historical certainty is a core
educational purpose of this hotspot.

---

# SECTION 3 — CULTURAL SIGNIFICANCE

## Display Title

Cultural Significance

## Approved Content

Despite the continuing historical debate, Princess Urduja remains an important
cultural symbol associated with courage, wisdom, leadership, and Pangasinan
identity.

Do not convert this section into an unsupported historical biography.

Its purpose is cultural significance.

---

# Narration

## Approved Narration Text

Urduja House was named after Princess Urduja, a legendary warrior figure
associated with Pangasinan. Although historians continue to debate her
historical existence and the location of Tawalisi, she remains an important
cultural symbol. A painting by Romeo Mananquil near the entrance reflects this
lasting connection between the residence and Pangasinan’s cultural identity.

## Narration Behavior

Narration is optional.

The visitor must be able to read and explore UH-INT-01 without listening.

Use one recognizable speaker icon button, approximately 48–56 logical pixels
square, left-aligned below the painting and above Full Artwork / Inspect Artwork.
Use Containers for responsive placement. No separate text playback controls or
pause/resume workflow appear in the visitor UI.

Tap while inactive to play the assigned narration from the beginning. Tap while
playing to stop and reset playback. Show a clear active background while playing;
return to inactive on stop or natural completion. The next tap always starts from
the beginning. Provide Play narration / Stop narration accessibility descriptions.
Do not rely on hover or animation to communicate the control's purpose or state.

Narration must never autoplay or block exploration. It continues during section
changes, Full Artwork / Inspect Artwork, crop selection, and opening/closing
Sources. Closing a nested panel does not stop or restart it. Closing the entire
viewer stops and resets narration and the speaker state. Reopening never autoplays.
Narration is not required before closing or continuing.

When no stream is assigned, hide the speaker in production. The standalone
development scene may instead show a disabled speaker with clearly marked audio
pending status. Never generate substitute audio.

Do not generate replacement narration wording.

---

# Artwork Attribution

Validated project material identifies:

Artist:
Romeo C. Mananquil

Do not automatically treat "Princess Urduja Painting" as the formal catalog
title unless the museum or another validated source confirms that title.

For visitor-facing implementation, "Princess Urduja Painting" may be used as
the hotspot/interface label.

Formal artwork metadata remains pending unless separately validated.

---

# Source / Artwork Credit Panel

Provide a small optional source / artwork-credit panel.

The main educational content should remain uncluttered.

The panel may contain verified information only.

Current safe development information:

Artist:
Romeo C. Mananquil

Historical Content:
Based on researcher-validated AKAR Urduja House materials.

Do NOT invent:
- painting owner;
- formal title;
- creation date;
- collection name;
- photographer;
- copyright holder;
- image-source URL;
- acquisition information.

Use placeholders in DEVELOPMENT documentation if those details are still
pending.

Do not show fake placeholder credits as production visitor content.

---

# Touch Interaction Requirements

Every important function must work through touch.

Required touch-accessible controls:

- open hotspot;
- Full Artwork;
- Inspect Artwork;
- The Artwork;
- The Legend;
- Cultural Significance;
- speaker play/stop button if audio exists;
- Sources / Artwork Credit;
- Close.

Do not use hover as the only method of discovering or activating anything.

Buttons must provide visible pressed/selected feedback.

The currently selected learning section must remain visibly selected.

---

# Keyboard Support

Retain keyboard support for development and accessibility.

Support where consistent with AKAR:

- Tab;
- Enter;
- Space;
- Escape;
- Backspace / go_back.

Keyboard support is secondary to touchscreen interaction.

When opening the interaction:
focus a sensible primary control.

When closing:
restore focus to the original hotspot where practical.

If a secondary panel such as Sources is open, go_back should close that panel
first before closing the entire hotspot.

Consume go_back input safely before emitting signals that may remove the UI.

---

# Accessibility

Use readable text suitable for museum viewing.

Avoid very small fonts.

Maintain sufficient separation between touch controls.

Provide meaningful accessibility labels.

Painting alternative text should remain descriptive rather than historically
speculative.

Suggested development alt text:

"Painting depicting Princess Urduja surrounded by scenes and objects associated
with Pangasinan."

Do not convert visual interpretation into historical fact.

---

# Responsive Landscape Behavior

At 1280 × 720:
use the full intended two-column layout.

At smaller landscape phone dimensions:
- retain the two-column concept where readable;
- allow proportional reduction of artwork area;
- keep educational text readable;
- preserve large touch controls;
- use ScrollContainer for educational content when necessary;
- do not shrink text excessively;
- do not permit controls to overlap;
- do not introduce horizontal page scrolling.

The artwork and educational content should remain usable without requiring a
portrait layout.

---

# Reusable Architecture

Before implementing, inspect whether an existing reusable component can support
this interaction cleanly.

HistoricalHotspot should NOT be overloaded if doing so would complicate its
existing single-content behavior.

If a new reusable component is appropriate, use a generic educational media
interaction rather than a component named specifically for Princess Urduja.

Possible conceptual component:

InteractiveArtworkViewer

Responsibilities may include:
- image display;
- Full Artwork / Inspect Artwork modes;
- selectable educational sections;
- selected-section state;
- optional narration;
- optional source panel;
- close/back behavior.

Keep historical content in Resource/data files rather than behavioral scripts.

Do not create unnecessary abstraction.

---

# Possible Data Structure

A separate Resource may hold:

- hotspot title;
- prompt;
- primary artwork;
- neutral inspection labels and normalized crop rectangles in the primary artwork;
- section titles;
- section bodies;
- narration stream;
- narration transcript;
- source / credit information.

Suggested project content resource:

res://data/landmarks/urduja_house/uh_int_01.tres

Do not hard-code validated historical paragraphs directly into reusable
behavioral GDScript if they can cleanly live in data.

---

# Standalone Development Scene

Create UH-INT-01 as an independently testable hotspot before integrating the
Urduja House lobby.

Expected future scene path:

res://scenes/landmarks/urduja_house/interior/uh_int_01.tscn

The standalone scene should allow UH-INT-01 to be opened and tested without the
complete Urduja House master scene.

Do NOT implement the complete lobby during this milestone.

---

# Do Not Implement During UH-INT-01

Do not implement:

- UH-INT-02;
- UH-INT-03;
- UH-INT-04;
- restricted-area interaction;
- summary/reflection;
- master Urduja House scene;
- final lobby integration;
- global orientation system;
- global QR system;
- analytics;
- quizzes;
- scoring;
- achievements;
- mandatory viewing;
- completion tracking.

Stop after UH-INT-01.

---

# Manual Test Requirements

Test at the 1280 × 720 reference viewport.

Also test a smaller landscape browser/window configuration.

Verify:

Hotspot opens through touch/click.

Painting keeps correct proportions.

Full Artwork works.

Inspect Artwork works.

All three sections can be selected in any order.

Selected section receives visible state feedback.

Content changes without reopening the popup.

Historical uncertainty wording remains unchanged.

Touch targets are comfortable.

No essential hover-only behavior exists.

Narration does not autoplay.

Narration is optional.

Sources panel opens and closes safely.

Close works.

Back closes secondary panels before the main interaction.

Repeated opening and closing does not duplicate UI.

No text overlaps.

No controls disappear at smaller landscape dimensions.

No fabricated historical facts appear.

No fabricated artwork metadata appears.

No Godot errors occur.

---

# Historical Accuracy Rule

The following distinction must remain clearly represented:

Princess Urduja is an important cultural figure associated with Pangasinan.

Her historical existence and the identification of Tawalisi remain subjects of
historical debate.

The AKAR interface must not resolve that debate on behalf of the visitor.

---

# Capstone Alignment

UH-INT-01 supports AKAR's objective of providing an interactive historical
walkthrough integrating multimedia resources.

The interaction promotes visitor exploration through artwork inspection,
selectable historical information, optional narration, and source access.

It remains an educational interaction.

It is not a game.

It should not claim that the hotspot proves improved learning effectiveness.
## Development Narration State

Preserve the approved narration AudioStream. A real stream enables the single
speaker play/stop control with no autoplay. If audio is unassigned, the standalone
development scene may show the disabled speaker and an explicitly development-only
message: “Approved narration audio has not yet been assigned.”
The reusable viewer must allow this pending UI to be hidden for production.
Assigning a stream replaces the pending state on the next opening. Never generate
or synthesize substitute narration.
