# Collaboration Notes

## Project Constraints
- Engine version: Godot 4.3.
- Theme and goal: isekai adventure, climb a monster-filled mountain and reach the summit.
- Card art stays as placeholder blocks for now.
- Portraits should stay anime-styled and non-explicit; keep designs non-sexualized.

## Delivery Rules
- After each task, update `PROJECT.md` with current status and next plan.
- Log each change in `CHANGELOG.md`.
- Summarize and commit changes to Git after completion.

## Code Structure
- Keep the current scene/script split: Main / RunScreen / CardWidget.
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
- Reward selection uses a modal overlay to avoid stacking in the main UI.
- Reward list containers require a minimum height to stay visible.
- Card hover detail panel lives in `RunScreen` and uses `CardWidget` hover signals.
- Run persistence uses `RunState.save_run/load_run` and logs events to `user://savegame.json`.
- Main menu shows save summary and exposes a clear-save action.
- Combat UI uses HP bars and an intent color swatch in `RunScreen`.
- Intent/stat icons live under `icons/` and are referenced by `RunScreen`.
- Portraits, card art, and background textures live under `art/`.
- Decorative UI assets (banners, frames, glows, FX) live under `art/ui` and `art/fx`.
- Card data now includes `rarity` and `icon` fields for UI badges.
- `HandDock` lives under `MarginContainer/RootVBox` in `RunScreen`, and hand cards sit inside `HandScroll` (a plain `Control`).
- `HandContainer` is anchored to fill `HandScroll` so hand cards don't collapse to zero size.
