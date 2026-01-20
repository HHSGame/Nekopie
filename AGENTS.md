# Collaboration Notes

## Project Constraints
- Engine version: Godot 4.2.
- Theme and goal: isekai adventure, climb a monster-filled mountain and reach the summit.
- Card art stays as placeholder blocks for now.

## Delivery Rules
- After each task, update `PROJECT.md` with current status and next plan.
- Log each change in `CHANGELOG.md`.
- Summarize and commit changes to Git after completion.

## Code Structure
- Keep the current scene/script split: Main / DeckBuilder / RunScreen / CardWidget.
- `GameData` and `RunState` remain autoload singletons for card and run data.
