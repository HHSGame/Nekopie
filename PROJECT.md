# Isekai Mountain Deckbuilder

## Overview
A Godot 4.3 deck-building prototype set in an isekai adventure. The main goal is to climb a monster-filled mountain and reach the summit to clear the run. Card art is intentionally left as a placeholder.

## Implemented
- Main menu with story intro and entry points.
- Deck builder scene with add/remove flow.
- Run screen that hosts a basic combat loop (draw/hand/discard, energy, enemy turns).
- Card UI widget with blank art block.
- Autoload data/state for cards, run progress, and player HP.
- Mountain enemy roster, encounter order, and intent-based behaviors.
- UI node bindings use explicit paths for Godot 4.3 compatibility.
- Card widgets now safely accept data before entering the scene tree.
- Post-battle event nodes (heal, damage, or card reward).
- Bundled Noto Sans CJK SC font via a global theme for HTML5 Chinese rendering.
- Applied the global theme explicitly to UI scenes for HTML5 consistency.
- Export presets are tracked in `export_presets.cfg`.
- Post-battle rewards now include add, upgrade, and remove options.
- Reward selection is presented as a modal overlay (no scroll in main UI).
- Reward selection lists have fixed minimum heights to avoid collapsing.
- Card hover shows a detail panel in combat/reward screens.
- Reward selection list rendering is stabilized for upgrade/add flows.
- Persistence: save/load run state and log key events to `user://savegame.json`.
- Main menu shows save summary and allows clearing saves.
- Combat UI includes HP bars and intent color swatches.
- Intent icons and stat icons are integrated into the combat UI.
- Added illustrated portraits, card frames, and background art.
- Added hit flash animations and basic sound effects.
- Added scene frame overlays, title banners, and button icons.
- Added per-card art placeholders, rarity gems, and hover glow effects.
- Added portrait frames and slash/impact hit effects.
- Adjusted scene frame scaling to fit within the viewport.
- Docked the combat hand panel at the bottom to keep cards visible.
- Tracked Godot import metadata for UI and FX assets.
- Tightened RunScreen layout spacing to keep enemy and status panels visible.
- Rebuilt the combat layout to match Slay the Spire's top-center enemy and bottom hand flow.
- Squared portrait frames and resized battle panels to reduce distortion.
- Rebuilt RunScreen layout so combat and hand panels live in one main VBox.
- Added a battle spacer to keep enemy up top and player lower in the combat area.
- Replaced the hand scroll container with a plain control to avoid hover clipping.
- Collapsed hand cards to headers with hover expansion for full preview.
- Fixed hand draw loop so combat hands populate correctly.
- Aligned the RunScreen scene frame with the main combat layout and removed the bottom hand gap.

## Scene and Script Layout
- `scenes/Main.tscn` + `scripts/Main.gd`: main menu and navigation.
- `scenes/DeckBuilder.tscn` + `scripts/DeckBuilder.gd`: deck building.
- `scenes/RunScreen.tscn` + `scripts/RunScreen.gd`: climb progress.
- `scenes/CardWidget.tscn` + `scripts/CardWidget.gd`: card UI.
- `scripts/GameData.gd`: card library, starter deck, world text.
- `scripts/RunState.gd`: deck state and encounter progress.

## Current Gaps
- No meta progression beyond per-run rewards.
- Art and audio still rely on placeholder assets.
- No advanced status effects or skill keywords beyond the basic card set.

## How to Run
Open the project in Godot 4.3 and run the main scene at `res://scenes/Main.tscn`.

## Next Implementation Plan
1. Verify combat hand sizing/scroll behavior across common viewport sizes.
2. Continue UI polish: richer panel styling, feedback animation tuning, and iconography refinement.
3. Replace placeholder art/audio with open-licensed assets when available.
