# Isekai Mountain Deckbuilder

## Overview
A Godot 4.3 deck-building prototype set in an isekai adventure. The main goal is to climb a monster-filled mountain and reach the summit to clear the run. Card art is intentionally left as a placeholder.

## Implemented
- Main menu with story intro and entry points.
- Run screen that hosts a basic combat loop (draw/hand/discard, energy, enemy turns).
- Card UI widget with blank art block.
- Autoload data/state for cards, run progress, and player HP.
- Mountain enemy roster, encounter order, and intent-based behaviors.
- UI node bindings use explicit paths for Godot 4.3 compatibility.
- Card widgets now safely accept data before entering the scene tree.
- Bundled Noto Sans CJK SC font via a global theme for HTML5 Chinese rendering.
- Applied the global theme explicitly to UI scenes for HTML5 consistency.
- Export presets are tracked in `export_presets.cfg`.
- Post-battle rewards now include add, upgrade, and remove options.
- Reward selection is presented as a modal overlay (no scroll in main UI).
- Reward selection lists have fixed minimum heights to avoid collapsing.
- Card hover shows a detail panel in combat/reward screens.
- Reward selection list rendering is stabilized for upgrade/add flows.
- Persistence: save/load run state and log key events to `user://savegame.json`.
- Main menu now focuses on run start/continue plus the leaderboard.
- Combat UI includes HP bars and intent color swatches.
- Intent icons and stat icons are integrated into the combat UI.
- Added illustrated portraits, card frames, and background art.
- Added hit flash animations and basic sound effects.
- Added scene frame overlays, title banners, and button icons.
- Added per-card art placeholders, rarity gems, and hover glow effects.
- Added new placeholder card art for expanded cards plus status/equipment/power/curse icons.
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
- Anchored the hand card container to fill its viewport so cards render reliably.
- Unified enemy/player portrait panel sizes for consistent layout.
- Collapsed hand cards to headers with hover expansion for full preview.
- Fixed hand draw loop so combat hands populate correctly.
- Aligned the RunScreen scene frame with the main combat layout and removed the bottom hand gap.
- Rebuilt the RunScreen battle UI into a three-column layout with dedicated battle log and stat panels.
- Grouped story/progress and combat messaging into panel headers to reduce layout overlap.
- Reduced combat panel and hand dock minimum sizes to keep the hand area within the RunScreen bounds.
- Further tightened header, battle, and hand spacing so the hand panel fits inside the visible frame.
- Removed the RunScreen header bar and scaled the battle panel layout down to fit the hand dock in view.
- Stabilized hand card hover tweens to avoid errors when hand slots are refreshed.
- Scaled hand cards to the hand dock height and animate a lifted, enlarged hover preview.
- Centered the hand container layout so cards align in the middle of the dock.
- Added post-combat route selection with a supply roll, difficulty picker, and supply reward flow.
- Ensured supply route selections reliably open the supply reward overlay.
- Added run scoring, leaderboard persistence, and a post-run score overlay in the combat flow.
- Fixed scoring calculation typing to satisfy Godot's parser.
- Fixed GDScript type inference warnings to keep strict parsing clean.
- Consolidated post-battle rewards into the supply route (challenge routes continue without rewards).
- Expanded supply rewards to include upgrade/remove, healing, and card draft choices.
- Added the "恢复" card with a healing effect.
- Added a heart icon for the supply rest button to match the UI style.
- Increased encounter count to 12 with new monster portraits and base scores.
- Added energy max growth every 3 encounters and display energy as current/max.
- Enemies now draw from fixed decks with shared energy and enemy-only skill cards.
- Enemy decks now include debuff cards (弱化/易伤) and tuned cost curves for pacing.
- Battle log now records per-turn card usage, targets, and resulting HP/block values.
- Fixed RunScreen combat completion logic to keep the battle log stable.
- Battle log display is capped to a 12-line panel with scrolling for overflow.
- Enemy turns now pace each card play with delays, portrait pulses, and audio cues.
- Player/enemy block persists across turns until consumed or combat ends.
- "踏勘" now stacks its next-encounter bonus per use.
- Card upgrades now apply per individual card copy instead of all copies.
- Hand flow now draws 5 on turn 1, draws 3 thereafter, and keeps up to 5 cards.
- Added an end-turn discard selection overlay when hand size exceeds 5.
- Expanded the player card pool with pierce, charge, lifesteal, DOT statuses, and skip-turn tools.
- Added per-battle equipment and power effects (combo draws, damage reduction, bleed boosts).
- Added retain/ethereal/exhaust handling for card persistence and removal.
- Starter deck now uses 15 cards to support the larger card pool.
- Battle UI now shows player/enemy status effects plus active equipment and power buffs.
- Moved status/buff readouts onto portrait overlays to avoid squeezing the hand dock.
- Added a post-battle score shop to buy new unowned cards with a paid refresh.
- Runs now reset to the starter deck after victory or defeat for permanent roguelike progression.
- Main menu shows the leaderboard and lets players inspect historical decks.
- Fixed dynamic shop card slots to set separation via theme overrides safely.

## Scene and Script Layout
- `scenes/Main.tscn` + `scripts/Main.gd`: main menu and navigation.
- `scenes/RunScreen.tscn` + `scripts/RunScreen.gd`: climb progress.
- `scenes/CardWidget.tscn` + `scripts/CardWidget.gd`: card UI.
- `scripts/GameData.gd`: card library, starter deck, world text.
- `scripts/RunState.gd`: deck state and encounter progress.

## Current Gaps
- No meta progression beyond per-run rewards.
- Art and audio still rely on placeholder assets.
- No advanced status effects or skill keywords beyond the basic card set.

## Expansion Roadmap (Routes, Score, Content)
### Route Selection
- After each combat, roll for a supply node; supply is not guaranteed.
- If supply appears: player chooses between `补给` and `继续挑战`.
- If supply does not appear: only `继续挑战` is available.
- `继续挑战` opens a difficulty choice: `普通` / `困难` / `精英` (affects enemy stats, rewards, and score multiplier).
- `补给` route rewards: healing, card upgrade, card removal, or a small card draft.

### Scoring & Leaderboard
- Track per-combat metrics: attack_count, damage_dealt, damage_taken, final_hp, max_hp.
- Each monster has a base score by tier; difficulty adds a multiplier.
- Combat score formula (tunable, monotonic with damage/HP):
  - `combat_score = monster_base * difficulty_mult`
  - `+ damage_dealt * 0.6`
  - `+ min(damage_taken, max_hp * 3) * 0.3`
  - `+ attack_count * 2`
  - `+ final_hp * 2`
- Route bonus: `补给` grants a small support bonus; `继续挑战` grants a full combat bonus.
- Run total = sum of combat scores + route bonuses; store top 10 in leaderboard.

### Card Types & Effects
- Card types: Attack, Guard, Skill, Power, Curse (rarity + icon required).
- New effect families:
  - Multi-hit, bleed/poison, lifesteal, splash.
  - Barrier, reflect, temporary shield, block scaling.
  - Draw/energy engines, discard synergies, retain.
  - Vulnerable/Weak, Strength, Regeneration, Thorns.
  - Charge/Overload (bigger next attack, then exhaust).

### Monster Expansion
- Current roster covers 12 encounters with tiered base scores and new portraits.
- Enemy actions are now deck-driven with bespoke cards for multi-hit, charge, drain, heal, and debuffs.
- Next wave targets: 风暴翔禽、深谷咒师、山巅古龙等进阶魔物。
- New intents: debuff (Vulnerable/Weak), regen, split, summon, enrage.

## Expanded Card Set (Implemented)
### Keywords/Statuses
- `穿刺`: 无视护甲，造成绝对伤害。
- `蓄力xN`: 下一次攻击伤害 * N，触发后清空。
- `停滞`: 跳过敌人本回合（消耗）。
- `反击`: 本回合受到伤害时按比例反击。
- `护幕`: 本回合下一张针对自己的敌方卡牌失效。
- `战利吸收`: 本回合受伤时抽牌补给。
- `流血/中毒/灼烧`: 敌人回合结算时持续掉血（中毒会衰减）。
- `装备/心法`: 装备或心法在本场战斗持续生效。
- `吸血`: 造成伤害后恢复等量/比例生命。
- `保留/消耗/虚无`: 保留留手、消耗移除、虚无未打出会消耗。
- `多段强化`: 部分卡牌支持两次强化（如蓄力、迅读、反击姿态）。

### Starter Deck (15 Cards)
- 斩击 x5
- 格挡 x4
- 穿刺 x2
- 蓄力 x1
- 专注 x1
- 恢复 x1
- 踏勘 x1

### Card Pool (New Additions)
- Attack: 穿刺、破甲突击、血噬斩、护甲猛击、破军、毒刃、烈焰斩、连斩、斩杀、戒备突刺
- Skill: 蓄力、迅读、停滞结界、精准校准、失衡打击、影步
- Status: 反击姿态、护幕、补给回响、血痕标记、嗜战
- Equipment: 研锋之刃、缓冲披风、连击腕轮、守势腰带、血纹护符、猎杀徽记
- Power: 迅捷心法、坚毅之魂、血炼
- Curse: 疲惫、迟滞

## How to Run
Open the project in Godot 4.3 and run the main scene at `res://scenes/Main.tscn`.

## Next Implementation Plan
1. Balance the expanded card pool and starter deck (costs, upgrade values, reward odds).
2. Add UI indicators for bleed/poison/burn and active equipment/power buffs.
3. Tune enemy deck pacing to account for the new status/equipment cards.
