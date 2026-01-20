# Isekai Mountain Deckbuilder

## Overview
A Godot 4.3 deck-building prototype set in an isekai adventure. The main goal is to climb a monster-filled mountain and reach the summit to clear the run. Card art is intentionally left as a placeholder.

## Implemented
- Main menu with story intro and entry points.
- Deck builder scene with add/remove flow.
- Run screen that hosts a basic combat loop (draw/hand/discard, energy, enemy turns).
- Card UI widget with blank art block.
- Autoload data/state for cards, run progress, and player HP.
- Mountain enemy roster and encounter order.
- UI node bindings use explicit paths for Godot 4.3 compatibility.
- Card widgets now safely accept data before entering the scene tree.

## Scene and Script Layout
- `scenes/Main.tscn` + `scripts/Main.gd`: main menu and navigation.
- `scenes/DeckBuilder.tscn` + `scripts/DeckBuilder.gd`: deck building.
- `scenes/RunScreen.tscn` + `scripts/RunScreen.gd`: climb progress.
- `scenes/CardWidget.tscn` + `scripts/CardWidget.gd`: card UI.
- `scripts/GameData.gd`: card library, starter deck, world text.
- `scripts/RunState.gd`: deck state and encounter progress.

## Current Gaps
- No enemy intent variety beyond fixed attacks.
- No rewards, card upgrades, or meta progression.
- No art/audio resources beyond placeholders.

## How to Run
Open the project in Godot 4.3 and run the main scene at `res://scenes/Main.tscn`.

## Next Implementation Plan
1. Add encounter variety: intents, special abilities, and event nodes.
2. Rewards and deck growth: post-battle rewards and upgrades.
3. UI polish: combat UI, card details, feedback, and animations.
4. Persistence: run logging and save/load.
