# UH-END-01 — What Urduja House Represents

## Status

Approved implementation specification for the concluding Summary / Reflection
interaction of the AKAR Urduja House walkthrough.

UH-END-01 must summarize information already introduced through the Urduja
House experience.

It must NOT introduce new historical claims.

---

# Interaction Identity

## Interaction ID

UH-END-01

## Interaction Title

What Urduja House Represents

## Interaction Type

Summary / Reflection

## Placement

At the conclusion of the Urduja House walkthrough, after the Conference Room
experience and before returning to the landmark map.

## Educational Purpose

Help visitors recall and connect the key historical, governmental, cultural,
and architectural ideas encountered while exploring Urduja House.

---

# Final Interaction — Single-Summary Viewer

This correction supersedes the five-card grid interaction. Show one selected summary
at a time: a larger visual on the left and its title/explanation on the right.
The visitor may review the five approved ideas in any order or return immediately.
No viewed-state or completion tracking exists.

Introduction: “A quick look back at what you explored.”

## Layout
Use a parent-responsive Container layout:
- Header: What Urduja House Represents and Close.
- Short introduction.
- SelectedPanel: left visual area and right locally scrollable title/body.
- Navigation: compact < arrow, five-position review track with visitor marker, > arrow.
- RETURN TO LANDMARK MAP.

There is no five-button grid or 3+2 card arrangement. Do not display all five titles
as large controls. The track uses subtle numbers 1–5 with accessible summary names.

## Selected Visual
Reuse the five supplied icons. The visual area is 200 logical pixels wide and adapts
to the available content height; icons aspect-fit without crop/stretch. At tested
sizes the visible square icon area is approximately 128–200 px.
Use nearest filtering and preserve source padding. Do not generate replacements.
The fifth supplied icon is actually uh_end_01_cultural_architecture_icon.jpg; use
that existing file unchanged. Its opaque background remains a supplied-asset limitation.
Icons are illustrative UI assets, not historical evidence. No decorative exterior
image or Sources control is needed for this concise review.

## Navigation Arrows
Visible labels: < and >.
Accessible names: Previous summary and Next summary.
Each arrow touch target is 60×60 logical pixels. Previous from index 0 wraps to index 4;
Next from index 4 wraps to index 0. There is no autoplay or mandatory sequence.

## Five-Position Review Track
Exactly five directly selectable circular points correspond to the five entries in
their existing order (indices 0–4, visible labels 1–5). Each point has a 54px visible circle within a 64×64 touch
target and its complete summary title as its accessible name and tooltip.
A simple line connects the point centers. The selected point uses gold fill and a
stronger border; keyboard focus has a separate outline.
The track is navigation only. Do not label it progress/completion, show percentages,
or record whether an entry was viewed. No dragging is required or implemented.

## Visitor Marker — Supplied Image
Use res://assets/ui/icons/summary_visitor_marker.png, copied byte-for-byte from the
researcher-supplied assets/landmarks/urduja_house/icons/summary_visitor_marker.png.
The original file remains untouched. No generated artwork or drawn placeholder remains.

VisitorMarker is a 56×56 TextureRect with nearest filtering and aspect-fit.
An AtlasTexture region ignores transparent source padding without changing the PNG;
the visible person is approximately 56px tall. It centers above the selected point.
Its 200ms gentle slide remains navigation feedback only, with no walking loop,
bounce, jump, particles, sounds or reward effects.

## Track Shimmer
Only a changed selection triggers one 350ms Tween-driven glint. It travels along
the relevant segment with the marker's 200ms slide and fades after arrival.
Three short layered gold/cream strokes provide low-opacity softness (maximum core
opacity 0.22); there are no shaders, particles, sounds or loops. It conveys location,
never completion or reward. Same-point taps do not restart it. Rapid changes kill
and replace the previous tween; resize, close and removal clear it.

## Transitions and Resizing
Update title, body, icon and selected point together; fade the selected content in
over 200ms. Kill/replace both active movement and fade tweens on rapid input so the
latest request wins. Resizing recomputes point centers from the local track width,
cancels marker movement and snaps to the selected center. Reopening starts at index 0.
Do not use application viewport dimensions for positioning.

## Default State
Established in 1953 is selected; its exact icon/title/explanation appear. The marker
aligns above point 1. Return is available immediately. No completed state appears.

---

# Summary Card 1 — ESTABLISHED IN 1953

## Visitor-Facing Title

Established in 1953

## Approved Content

Urduja House was constructed as the official residence of the Governor of
Pangasinan.

## Icon

Use:

res://assets/landmarks/urduja_house/icons/uh_end_01_established_icon.png

If the repository uses another established Urduja House icon folder, preserve
the existing project convention.

## Learning Purpose

Reinforce the establishment and original official purpose of Urduja House.

---

# Summary Card 2 — NAMED FOR PRINCESS URDUJA

## Visitor-Facing Title

Named for Princess Urduja

## Approved Content

Its original name, Princess Urduja Palace, reflects the cultural importance of
the legendary warrior figure associated with Pangasinan.

## Icon

Use:

res://assets/landmarks/urduja_house/icons/uh_end_01_urduja_icon.png

## Learning Purpose

Connect the residence's name with the cultural figure of Princess Urduja.

## Historical Accuracy Rule

Do not present Princess Urduja's historical existence as conclusively proven.

Do not add new claims concerning Tawalisi or Ibn Battuta in this summary screen.

Those details belong to the earlier Princess Urduja hotspot.

---

# Summary Card 3 — A CHANGING GOVERNMENT FUNCTION

## Visitor-Facing Title

A Changing Government Function

## Approved Content

The building served as both residence and office until the daily Governor’s
Office moved to the Provincial Capitol in 2007.

## Icon

Use:

res://assets/landmarks/urduja_house/icons/uh_end_01_changing_function_icon.png

## Learning Purpose

Reinforce the change in the administrative function of Urduja House.

---

# Summary Card 4 — CONTINUING OFFICIAL ROLE

## Visitor-Facing Title

Continuing Official Role

## Approved Content

Urduja House remains the governor’s official residence, while the Ceremonial
Hall is used for selected official events.

## Icon

Use:

res://assets/landmarks/urduja_house/icons/uh_end_01_official_role_icon.png

## Learning Purpose

Connect the historical residence with its continuing role in provincial
government.

---

# Summary Card 5 — CULTURAL AND ARCHITECTURAL IDENTITY

## Visitor-Facing Title

Cultural and Architectural Identity

## Approved Content

Its Balinese-inspired character and association with Princess Urduja contribute
to its distinctive place in Pangasinan’s heritage.

## Icon

Use:

res://assets/landmarks/urduja_house/icons/uh_end_01_cultural_architecture_icon.png

## Learning Purpose

Connect the residence's visual identity and cultural association to its heritage
significance.

---

# Suggested Icon Accessibility Text

## Established

"Pixel-art building icon representing the establishment of Urduja House."

## Princess Urduja

"Pixel-art cultural icon representing Princess Urduja."

## Changing Government Function

"Pixel-art time and transition icon representing the changing government
function of Urduja House."

## Continuing Official Role

"Pixel-art official-function icon representing the continuing government role
of Urduja House."

## Cultural and Architectural Identity

"Pixel-art architectural icon representing the cultural and architectural
identity of Urduja House."

These descriptions are for accessibility/UI context.

They are not historical evidence.

---


# Preserved Data and Architecture
Keep res://data/landmarks/urduja_house/uh_end_01.tres unchanged. The approved five
titles, bodies, icons and icon accessibility descriptions remain separate from
generic behavior. HistoricalSummaryContent and HistoricalSummaryEntry stay unchanged.
Preserve the reusable scene and existing public methods/signals:
- open_interaction(), close_interaction(), select_summary(index), get_selected_summary(),
  request_return_to_map().
- opened, closed, summary_changed(index), return_to_map_requested.

# Embedded Use
HistoricalSummaryInteraction fills its parent rectangle using anchors and Containers.
Use 12px internal margins, readable 24px selected heading and 22px body, wrapping,
and local scrolling as needed. Keep landscape layout at 1280×720, 960×540 and 854×480.
Also validate inset frames at those application sizes. No portrait redesign.

The existing preview remains:
res://scenes/landmarks/urduja_house/summary/uh_end_01.tscn
Its SummaryFrame has 5% inset anchors, auto-opens the component for F6 and shows
a development-only Return request status. Do not build the master scene or map.

# Return, Close, and Focus
RETURN TO LANDMARK MAP remains visible and emits return_to_map_requested only.
Do not hard-code scene navigation or require visiting all summaries.
Consume input before emitting a signal that may remove the active component.
Close and go_back emit closed; they are separate from the Return intent.
Remember previous focus on open and restore it on close where valid.
Tab/Shift+Tab reach arrows, all five points, Return, scroll and Close.
Enter/Space activate focused controls; Escape/Backspace safely close.
No essential interaction depends on hover or dragging.

# Scope and Historical Safety
Preserve the five approved explanations exactly. Do not add claims about Princess
Urduja, dates, architecture, official activities or media/source provenance.
No narration, speaker, audio transcript, quizzes, typed reflection, points, scores,
lives, levels, achievements, unlocks, badges, completion markers, rewards, celebratory
effects, analytics, database, accounts, QR generation, Restricted Area or other landmarks.
This remains educational review/reflection, not a learning-effectiveness assessment.

# Validation and Manual Testing
Update docs/uh_end_01_testing.md. Verify:
- one summary only; enlarged visual; no five-card grid;
- default Established and all five exact icon/title/body mappings;
- < and > including wrap, 60px arrow targets and keyboard activation;
- exactly five directly selectable points with one active point;
- marker alignment, unobscured targets and subtle 200ms movement;
- rapid mixed arrow/point input, latest selection, full final opacity;
- resizing during movement, repeated opening/closing, safe focus/back;
- Return available immediately, signal only, separate Close intent;
- all three application sizes, full-size and inset parents;
- no historical edits, narration, completion tracking or game features;
- Godot headless/runtime checks, resource paths, git diff --check and git status.

Physical touchscreen behavior and rendered appearance require manual F6 checks.
The supplied visitor asset replaces the development placeholder. DevelopmentNote
in the standalone preview uses explicit line breaks with autowrap disabled. Do not commit or push for this correction.


## Bottom Navigation Touch Sizing
Visitor marker: 56×56 noninteractive aspect-fit area, approximately 56px visible height.
Numbered controls: 54px circular visuals inset inside 64×64 button hit areas,
with centered 24px numbers. Arrows: 60×60 buttons with 28px glyphs.
Track: 124px high with 32px endpoint padding. Marker y=0..56; hit areas y=60..124;
visible circles y=65..119; line/shimmer center y=92. Preserve the existing 200ms
marker movement, 350ms shimmer, direct selection, wrapping and Return behavior.
Margins remain unchanged. At the smallest inset size, local text space is 528×128.
