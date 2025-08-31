# Media Mode Wiring

This document outlines how the Mission Pinball Framework (MPF) integrates with the Godot Media Controller (GMC) for this project.

## Overview
- Purpose: Describe the wiring between MPF events/variables and Godot scenes/slides.
- Scope: High-level guidance for developers setting up or modifying media behavior.

## MPF → Godot
- Events: MPF posts events (e.g., `mode_attract_started`) consumed by Godot scenes to show/hide slides.
- Variables: MPF exposes variables (e.g., `credits_string`, `player*_score`) read by Godot via GMC nodes.
- Carousel: Attract carousel items map to nodes by name in the `Attract` scene.

## Godot → MPF
- Actions: Button presses or selections may emit GMC events back to MPF (e.g., `location_selected`).
- Conventions: Use lowercase snake_case for event names and node names that correspond to MPF items.

## File Conventions
- Scenes live in `slides/` and should be `Control`-based for overlays.
- Scripts live under `slides/scripts/` and should extend the node type they control.
- Reusable overlays live under `slides/overlays/`.

## Troubleshooting
- If a slide does not appear, confirm the MPF event name matches the expected scene/slide name.
- Verify variables exist in MPF and are spelled identically in Godot variable readers.
- Check the Godot console for missing resource/script paths.

