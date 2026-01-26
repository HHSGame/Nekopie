# Changelog

## 2026-01-24
- Consolidated post-battle rewards into the supply route and removed challenge rewards.
- Expanded supply rewards to include upgrade/remove, healing, and draft options.
- Removed the duplicate supply add-card button and kept a single draft option.
- Added the "恢复" card with a healing effect and new card art assets.
- Expanded the enemy roster to 12 encounters with new portraits and base scores.
- Added energy max growth every 3 encounters and updated the energy UI display.
- Added a heart-shaped supply rest icon to match the UI button style.
- Reworked enemy turns to draw from fixed decks with shared energy and enemy-only cards.
- Tuned enemy deck mixes for difficulty pacing and added weak/vulnerable debuff cards.
- Added a debuff intent icon for enemy status effects.
- Logged per-turn combat actions in the battle log, including card usage and outcome details.
- Fixed a RunScreen parse error caused by mis-indented combat completion logic.

## 2026-01-23
- Rebuilt the RunScreen combat UI into a three-column battle layout with new story/progress panels.
- Moved combat messaging into a dedicated battle log panel and reorganized enemy/player stats.
- Updated RunScreen node bindings to match the redesigned scene hierarchy.
- Trimmed combat panel/hand dock minimum sizes and spacing so the hand area stays within the viewport.
- Tightened header, portrait, and hand panel sizing to keep the hand dock within the RunScreen bounds.
- Removed the RunScreen header bar and scaled the battle layout down to keep the hand dock visible.
- Fixed hand hover tween cleanup to prevent slot callbacks from running after nodes are freed.
- Shrunk hand cards to fit the hand dock height and added a lifted hover scale animation.
- Centered the hand container layout for cleaner card alignment.
- Documented the route selection, scoring, content expansion, and leaderboard roadmap.
- Added post-combat route selection with supply rolls, difficulty choices, and supply rewards.
- Fixed supply route selection to open the supply reward overlay.
- Added run scoring, leaderboard persistence, and a score overlay shown after run completion.
- Fixed score calculation typing to avoid parser errors in RunScreen.

## 2026-01-22
- Fixed the combat hand draw loop so multiple cards populate correctly.
- Matched the RunScreen scene frame height to the main combat layout.
- Removed the extra bottom gap so the hand dock meets the viewport edge.

## 2026-01-21
- Added title banners and decorative scene frames across UI scenes.
- Added button icons for menu, combat actions, and rewards.
- Added panel styling adjustments in the deck builder.
- Added per-card art placeholders, rarity gems, and hover glow for cards.
- Added portrait frames and slash/impact hit effects in combat.
- Added reward overlay fade/scale animation.
- Added new UI/FX SVG assets for banners, gems, frames, and combat effects.
- Expanded card data with rarity and icon fields plus new art references.
- Fixed scene frame scaling to avoid oversizing the viewport.
- Reworked combat layout to dock the hand at the bottom and keep it visible.
- Tracked Godot .import metadata for new UI and FX assets.
- Reduced combat layout heights to keep enemy/status panels visible alongside the hand dock.
- Rebuilt the RunScreen layout to follow a Slay the Spire-style combat arrangement.
- Adjusted portrait frame proportions and tightened combat panel sizing.
- Rebuilt RunScreen layout to keep combat and hand panels in one main VBox.
- Added a battle spacer to separate enemy and player rows.
- Replaced the hand scroll container with a plain control to avoid hover clipping.
- Anchored the hand card container to fill its viewport to keep cards visible.
- Unified enemy/player portrait panel sizes for consistent layout.
- Added collapsed hand headers with hover expansion animation for full card preview.

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
- Fixed reward list containers to ensure upgrade/remove options render.
- Added card hover detail panel and colored intent text.
- Fixed reward list rendering indentation bug in `RunScreen`.
- Fixed card list rendering indentation errors in `RunScreen`.
- Added save/load support for run state with event logging.
- Added save summary and clear-save controls in the main menu.
- Added enemy/player HP bars and an intent color swatch in combat UI.
- Added intent icons and stat icons to the combat UI.
- Added background art, portraits, card frames, hit flashes, and basic SFX.
