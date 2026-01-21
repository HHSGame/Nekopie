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

## Scene and Script Layout
- `scenes/Main.tscn` + `scripts/Main.gd`: main menu and navigation.
- `scenes/DeckBuilder.tscn` + `scripts/DeckBuilder.gd`: deck building.
- `scenes/RunScreen.tscn` + `scripts/RunScreen.gd`: climb progress.
- `scenes/CardWidget.tscn` + `scripts/CardWidget.gd`: card UI.
- `scripts/GameData.gd`: card library, starter deck, world text.
- `scripts/RunState.gd`: deck state and encounter progress.

## Current Gaps
- No enemy intent telegraph UI beyond text labels.
- No meta progression beyond per-run rewards.
- No art/audio resources beyond placeholders.

## How to Run
Open the project in Godot 4.3 and run the main scene at `res://scenes/Main.tscn`.

## Next Implementation Plan
1. UI polish: combat UI, intent icons, card details, feedback, and animations.
2. Persistence: run logging and save/load.
