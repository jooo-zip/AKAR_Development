# AKAR Repository Instructions

## Project Identity

AKAR is a web-based 2D interactive historical walkthrough for
learning the history and cultural heritage of Lingayen, Pangasinan.

AKAR is an educational museum-support system. It is not a game.

## Technology

- Engine: Godot 4
- Programming language: GDScript only
- Renderer: Compatibility
- Target platform: Web browser
- Presentation: 2D pixel-art interactive walkthrough
- Reference viewport: 1280 x 720

## Core Visitor Flow

1. Loading Screen
2. Main Menu
3. Introduction to Lingayen
4. Overview of Lingayen
5. Visitor Avatar Selection
6. Interactive Landmark Map
7. Landmark Introduction
8. Arrival Outside Landmark
9. Exterior Exploration
10. Interior Exploration when applicable
11. Historical Hotspot Interactions
12. Summary / Reflection
13. Return to Landmark Map

## Prohibited Features

Do not introduce:

- Scores
- Rewards
- Levels
- Puzzles
- Combat
- Lives
- Rankings
- Achievements
- Multiplayer
- User accounts
- Unapproved historical facts
- C# scripts
- Godot 3 syntax

## Historical Accuracy

- Never invent historical dates, events, personalities, or quotations.
- Use only researcher-supplied and validated information.
- Use clear placeholders when validated content has not yet been supplied.
- Keep historical content separate from application logic.

## Architecture

- Use reusable components.
- Use typed GDScript where practical.
- Use signals between screens and the application controller.
- Avoid duplicated landmark-specific logic.
- Avoid unnecessary autoloads.
- Do not modify unrelated files.
- Prefer small reviewable changes.

## User Experience

- Support mouse and keyboard.
- Touch support will be added when appropriate.
- Use readable text and large controls.
- Provide visible back navigation.
- Keep the experience self-paced.
- Do not require every hotspot to be completed.
- Avoid long text blocks.

## Navigation Safety

When handling go_back or another input that causes navigation:

1. Get the viewport.
2. Mark the input as handled.
3. Then emit the navigation signal.

Do not emit navigation first if the signal may remove the current screen.

Example:

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed(&"go_back"):
        var viewport := get_viewport()
        if viewport != null:
            viewport.set_input_as_handled()

        navigation_requested.emit(TARGET_SCREEN)

## Web Requirements

- Preserve Compatibility rendering.
- Use canvas_items stretch mode.
- Use expand stretch aspect.
- Use nearest texture filtering for pixel art.
- Avoid unnecessary shaders and expensive effects.
- Optimize large multimedia assets later.

## Workflow

Before implementing a milestone:

1. Inspect the existing repository.
2. State files to be modified.
3. Make only milestone-related changes.
4. Check references and GDScript syntax.
5. Run git diff --check.
6. Provide manual Godot testing instructions.
7. Stop after the requested milestone.