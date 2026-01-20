# Isekai Mountain Deckbuilder

## Overview
A Godot 4.2 deck-building prototype set in an isekai adventure. The main goal is to climb a monster-filled mountain and reach the summit to clear the run. Card art is intentionally left as a placeholder.

## Implemented
- Main menu with story intro and entry points.
- Deck builder scene with add/remove flow.
- Run screen that tracks climb progress and victory.
- Card UI widget with blank art block.
- Autoload data/state for cards and run progress.

## Scene and Script Layout
- `scenes/Main.tscn` + `scripts/Main.gd`: main menu and navigation.
- `scenes/DeckBuilder.tscn` + `scripts/DeckBuilder.gd`: deck building.
- `scenes/RunScreen.tscn` + `scripts/RunScreen.gd`: climb progress.
- `scenes/CardWidget.tscn` + `scripts/CardWidget.gd`: card UI.
- `scripts/GameData.gd`: card library, starter deck, world text.
- `scripts/RunState.gd`: deck state and encounter progress.

## Current Gaps
- No combat loop (draw/hand/discard, play resolution).
- No enemy data or encounter events beyond text.
- No art/audio resources beyond placeholders.

## How to Run
Open the project in Godot 4.2 and run the main scene at `res://scenes/Main.tscn`.

## Next Implementation Plan
1. Core combat loop: draw/hand/discard and card effect resolution.
2. Enemy and encounter data: varied monsters and mountain events.
3. Rewards and deck growth: post-battle rewards and upgrades.
4. UI polish: combat UI, card details, feedback.
5. Persistence: run logging and save/load.
