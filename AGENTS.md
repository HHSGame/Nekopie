# Collaboration Notes

## Project Constraints
- Engine version: Godot 4.3.
- Theme and goal: isekai adventure, climb a monster-filled mountain and reach the summit.
- Card art stays as placeholder blocks for now.

## Delivery Rules
- After each task, update `PROJECT.md` with current status and next plan.
- Log each change in `CHANGELOG.md`.
- Summarize and commit changes to Git after completion.

## Code Structure
- Keep the current scene/script split: Main / DeckBuilder / RunScreen / CardWidget.
- `GameData` and `RunState` remain autoload singletons for card and run data.
- Combat loop lives in `RunScreen` and uses hand/draw/discard plus energy each turn.
- Enemy roster and encounter order are defined in `GameData`.
- Avoid `class_name` on autoload scripts to prevent singleton name conflicts.
- Use explicit `$` node paths unless nodes are marked as unique names for `%` access.
- `CardWidget` caches card data until ready so it can be populated before adding to the tree.
- Enemy intents and event definitions live in `GameData`, with combat execution in `RunScreen`.
- Keep the bundled Noto Sans CJK SC font and global theme for HTML5 Chinese text rendering.
- UI scene roots explicitly reference the global theme for export reliability.
- Track `export_presets.cfg` in Git to share HTML5 export settings.
- Card upgrades are tracked per card id in `RunState` and apply to all copies.
