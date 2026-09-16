# UH-ENT-01 — The Story of Urduja House

## Status
Approved implementation specification for AKAR.

This file is the development source of truth for the Urduja House
entrance historical-video interaction.

Do not change historical content or introduce unsupported facts.

## Interaction ID
UH-ENT-01

## Title
The Story of Urduja House

## Interaction Type
Entrance historical-video interaction.

This is not one of the seven primary informational hotspots.
It is a supporting interaction placed between exterior exploration
and entry into the virtual lobby.

## Placement
Immediately before entering the virtual lobby.

## Interaction Prompt
Watch: The Story of Urduja House

## Target Duration
Approximately 60–90 seconds.

## Purpose
Provide the visitor with the main historical overview of Urduja House
before beginning interior exploration.

## Required User Controls

- Watch
- Play without sound
- Read transcript
- Skip for now
- Replay
- Close

## Required Behavior

### Watch
Starts the historical video with its normal audio.

### Play Without Sound
Starts or continues the historical video with the video audio muted.

This must not permanently change the application's global audio setting.

### Read Transcript
Displays the approved transcript in a readable panel.

The visitor must be able to read the transcript without being required
to play the video.

### Skip for Now
Allows the visitor to proceed without watching the historical video.

Watching the video must remain optional.

### Replay
Restarts the video from the beginning after it has played or been stopped.

### Close
Closes the video interaction safely.

## Educational / UX Rules

- Keep the interaction self-paced.
- Do not force the visitor to watch the complete video.
- Do not lock interior exploration behind video completion.
- Provide readable controls suitable for museum visitors.
- Support mouse and keyboard.
- Provide visible focus states where practical.
- Keep the transcript readable at the project's 1280 x 720 viewport.
- Avoid excessive decorative effects.
- Do not introduce game mechanics.

## Accessibility

The video interaction should support:

- mouse controls;
- keyboard navigation;
- visible Play / Replay / Close controls;
- mute / play-without-sound option;
- transcript access;
- skip option;
- Escape / Backspace through the existing go_back action where appropriate.

Video information must not be available only through audio.

## Development Architecture

UH-ENT-01 is different from HistoricalHotspot.

Do not modify HistoricalHotspot merely to turn it into a video player.

If a reusable historical-video component is needed, create a small
generic component suitable for later landmark videos.

Possible structure:

HistoricalVideoInteraction
├── Video Display
├── Title
├── Controls
│   ├── Watch / Play
│   ├── Play Without Sound / Mute
│   ├── Transcript
│   ├── Replay
│   ├── Skip
│   └── Close
└── Transcript Panel

Keep the component simple and reusable.

## Video Content

Use only the researcher-approved final historical video and transcript.

Do not generate historical narration or add new historical statements.

If the final video asset is not yet available, do not create a fake
historical video.

A clearly identified development placeholder may be used only to test
video-control behavior.

## Source / Credit

Do not invent:

- video creator;
- photographer;
- source organization;
- music credit;
- archival source;
- copyright statement.

Use verified attribution only.

## Capstone Alignment

This interaction supports the multimedia component of AKAR's
web-based interactive historical walkthrough.

It should supplement the visitor's understanding of the landmark
before interior exploration.

It must remain an educational interaction rather than a game mechanic.

## Do Not Implement

Do not implement:

- UH-INT-01
- UH-INT-02
- UH-INT-03
- UH-INT-04
- Restricted Area interaction
- UH-END-01
- Urduja House master scene
- global application integration

Stop after UH-ENT-01 is independently testable.

## Completion Criteria

UH-ENT-01 is individually complete when:

- standalone scene loads without errors;
- approved video loads correctly;
- Watch works;
- play-without-sound works;
- transcript can be opened and closed;
- Skip for now works without requiring video completion;
- Replay restarts the video;
- Close works safely;
- keyboard focus works;
- go_back behavior is safe;
- no unverified historical content or credits are introduced;
- scene passes manual testing before master-scene integration.