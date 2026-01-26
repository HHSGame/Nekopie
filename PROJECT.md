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

## Planned Card Set (vNext)
### New Keywords/Statuses
- `穿刺`: 无视护甲，造成绝对伤害。
- `蓄力xN`: 下一次攻击伤害 * N，触发后清空。
- `停滞`: 跳过敌人本回合（稀有，通常消耗）。
- `反击`: 本回合受到伤害时按比例反击。
- `无效化`: 本回合下一张针对自己的敌方卡牌失效。
- `战利吸收`: 本回合受到伤害时从抽牌堆抽取卡牌补给。
- `流血`: 敌人回合结束时受到固定伤害，可叠加。
- `装备`: 装配后在该场战斗持续生效。
- `吸血`: 造成伤害后恢复等量/比例生命。
- `失衡`: 敌人本回合护甲获得量降低。
- `保留`: 回合结束后保留在手牌。
- `消耗`: 打出后移出本场战斗（消耗牌堆）。
- `虚无`: 回合结束未打出则消耗。
- `连击`: 本回合累计攻击次数触发额外效果。
- `中毒`: 敌人回合开始受到层数伤害，随后层数-1。
- `灼烧`: 敌人回合结束受到层数伤害，层数不衰减。

### Starter Deck (15 Cards)
- 斩击 x5
- 格挡 x4
- 穿刺 x2
- 蓄力 x1
- 专注 x1
- 恢复 x1
- 踏勘 x1

### Proposed Card Types & Examples
- Attack
  - 穿刺（1费）：穿刺6伤害。升级：+2伤害。
  - 破甲突击（2费）：穿刺10伤害。升级：+3伤害。
  - 血噬斩（2费）：造成8伤害，吸血50%。升级：伤害+3。
  - 护甲猛击（1费）：造成等同当前护甲的伤害。升级：+3额外伤害。
  - 破军（2费）：造成等同已损失生命值的伤害（上限20）。升级：上限+6。
  - 逆境斩（1费）：自身生命低于50%时伤害翻倍。升级：基础伤害+2。
  - 戒备突刺（1费）：护甲≥8时穿刺伤害。升级：触发阈值-2。
  - 连斩（1费）：造成4伤害，本回合每打出一张攻击牌伤害+2。
  - 斩杀（2费）：若敌人生命≤30%，直接造成双倍伤害。
  - 毒刃（1费）：造成4伤害，施加中毒3层。
  - 烈焰斩（2费）：造成7伤害，施加灼烧2层。
- Skill
  - 蓄力（1费）：获得蓄力x2。强化1：蓄力x3；强化2：蓄力x4。
  - 迅读（0费）：抽2张。强化1：抽3张；强化2：抽4张。
  - 停滞结界（0费，稀有）：跳过敌人本回合，消耗。
  - 失衡打击（1费）：本回合敌人护甲获得量-3。升级：-5。
  - 精准校准（1费）：本回合下一张攻击牌必定穿刺。升级：额外+2伤害。
  - 影步（0费，保留）：本回合下一张攻击牌费用-1。
  - 蓄谋（1费）：查看并调整抽牌堆顶3张顺序，抽1张。
  - 归阵（1费）：将弃牌堆顶2张加入手牌。
- Status (临时，当前回合)
  - 反击姿态（1费）：本回合受伤时反击所受伤害的70%。强化1：140%；强化2：210%。
  - 护幕（1费）：本回合下一张针对自己的敌方卡牌失效。
  - 补给回响（1费）：本回合受伤时抽2张牌作为补给。
  - 血痕标记（1费）：给敌人施加流血2层；本回合每次攻击额外+1层。
  - 嗜战（1费）：本回合每打出一张攻击牌，获得+1伤害（可叠加）。
- Power (战斗持续)
  - 迅捷心法（2费）：每回合首次打出攻击牌时抽1张。
  - 坚毅之魂（2费）：每回合首次受到伤害时获得2点护甲。
  - 血炼（2费）：造成伤害时额外施加1层流血。
- Equipment (战斗持续)
  - 研锋之刃（2费）：本场战斗你的攻击伤害+1。
  - 缓冲披风（2费）：本场战斗受到伤害-1（最低为0）。
  - 连击腕轮（2费）：每回合当你连续打出2张攻击牌，抽1张。
  - 守势腰带（2费）：每回合当你连续打出2张防御牌，获得2点护甲。
  - 血纹护符（2费）：本场战斗每次造成伤害获得1点护甲。
  - 猎杀徽记（2费）：本场战斗敌人每层流血额外+1伤害。
- Curse (负面牌)
  - 疲惫（0费，虚无）：本回合无法获得护甲。
  - 迟滞（0费，虚无）：本回合打出的第一张牌费用+1。

## How to Run
Open the project in Godot 4.3 and run the main scene at `res://scenes/Main.tscn`.

## Next Implementation Plan
1. Tune pacing for the new hand retention/block persistence (enemy stats, score scaling, supply frequency).
2. Add richer enemy action feedback (extra SFX, intent animations) and polish discard overlay UX.
3. Expand player card effects and enemy deck variety alongside new status keywords.
