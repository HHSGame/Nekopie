# Changelog

## 2026-01-20
- Initialized the Godot 4.2 project with main menu, deck builder, and run flow scenes.
- Added card data, starter deck, and run state management.
- Added `PROJECT.md`, `CHANGELOG.md`, `AGENTS.md`, and `.gitignore`.
- Standardized documentation language and collaboration notes.
- Implemented a basic combat loop with hand/draw/discard, energy, and enemy turns.
- Added mountain enemy roster and encounter sequencing.
- Upgraded the project config to Godot 4.3 and added 4.3 layout metadata.
- Fixed autoload singleton name conflicts and typed-variable warnings.
- Fixed UI node bindings to avoid `%` unique-name lookup errors.
- Made card widgets apply data after ready to avoid nil label errors.
- Added enemy intent behaviors with guard/charge/multi-attack/drain patterns.
- Added post-battle random events for healing, damage, or card rewards.
- Bundled Noto Sans CJK SC font and set a global theme to fix HTML5 Chinese text rendering.
- Ignored HTML5 export output directory in `.gitignore`.
- Applied the global theme on UI scenes to ensure font usage in HTML5 exports.
- Added `export_presets.cfg` to track HTML5 export settings.
- Added post-battle reward options for adding, upgrading, or removing cards.
- Moved reward selection into a modal overlay to avoid scrolling the main UI.
- Ignored `docs/*.import` metadata files from export previews.
