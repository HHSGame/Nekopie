# V1: Display Fixes & Structural Refactoring

## Vision / 背景动机

当前项目代码已实现完整战斗流程（12 场遭遇战、卡牌池、商店、排行榜），但存在若干显示问题和架构反模式：
- Canvas 层面的显示问题（手牌溢出、卡牌详情框定位）
- 控制器使用 `extends RefCounted` 但操作场景树，不符合 Godot 惯例
- `context._method()` 回调模式违反 SOLID DIP，造成紧耦合
- `CombatState` 使用 40+ 扁平字段，缺少组织

本次任务重点修复运行时可见的显示问题，并按 Godot 标准重构架构。

## Scope / Non‑Goals

### Scope
1. **显示修复**
   - `HandScroll` 替换为 `ScrollContainer`，手牌溢出时可滚动
   - `CardDetailPanel` 改用锚点定位而非绝对偏移
   - `RewardOverlay` 在场景中默认 `visible = false`
   - `SceneFrame` 在 `RunScreen` 中设为可见
2. **控制器重构**
   - 将 `CombatFlowController`、`CombatUIController`、`RewardFlowController` 改为 `extends Node`
   - 用信号替代 `context._method()` 回调
   - 消除 `RunScreen` 中重复的方法包装层
3. **状态整理**
   - `CombatState` 内部分组（player_status、enemy_status、equipment、powers、overlay_states）
4. **代码解耦**
   - 拆分 `CardEffectExecutor._apply_card_effect()` 为按作用域组织的方法

### Non‑Goals
- 不修改游戏逻辑（回合流程、伤害计算、卡牌效果数值）
- 不修改 `GameData` 或 `RunState` 的存储/加载逻辑
- 不涉及新的 UI 元素或布局大改（滚动容器是保持功能而非改布局）
- 不修改 `Main.tscn` / `Main.gd`
- 不涉及新功能或新卡牌

## Data Model

无新数据模型，仅重组 `CombatState` 内部结构：

```
CombatState (sub-groups):
  - player: hp, max_hp, energy, hand, draw_pile, discard_pile, block
  - statuses: weak_turns, vulnerable_turns, next_attack_mult, etc.
  - equipment: attack_bonus, damage_reduction, etc.
  - powers: first_attack_draw, first_damage_block, etc.
  - enemy: actor, data, bleed, poison, burn, etc.
  - overlays: reward_active, shop_active, etc.
  - combat: turn_index, difficulty, damage_dealt, etc.
```

## UX / 流程

显示修复不影响用户操作流程，仅解决：
- 手牌 > 5 张时可通过滚动看到所有牌
- 卡牌详情框在不同分辨率下位置正确
- 补给/商店/弃牌弹窗不在开局时闪烁出现

## 依赖与边界

- 依赖 `CombatState` 的引用处：`CombatFlowController`、`CombatUIController`、`RewardFlowController`、`StatusResolutionHandler`、`CardEffectExecutor`、`TargetReactionHandler`
- 依赖 `RunScreen` 节点引用的地方：所有 `@onready` 路径
- **不影响**：`GameData`、`RunState`、`CardWidget`、`PortraitPanel`、`BattleLogPanel`

## 验收标准

1. `HandScroll` 是 `ScrollContainer`，手牌≥6张时可滚动查看
2. `CardDetailPanel` 在 1024×768 和 1920×1080 下均正确定位
3. `RewardOverlay` 启动时不显示（visible=false）
4. `SceneFrame` 在 `RunScreen` 中可见
5. 所有控制器在场景树内作为 `Node` 存在
6. `RunScreen` 不再有 `_method_name()` 包装层（信号直达控制器）
7. `CombatState` 内部字段按作用域分组
8. 游戏所有功能（战斗、商店、补给、排行榜）运行正常
9. 无运行时错误

## 风险与回退方案

- **风险**：控制器从 RefCounted 改为 Node 可能因初始化顺序不同导致 null 引用
  - **回退**：在 setup() 中添加 is_inside_tree() 检查，延迟绑定节点引用
- **风险**：信号连接可能遗漏导致某些功能无声运行
  - **回退**：每个控制器添加 assert 检查信号连接状态
- **风险**：CombatState 分组重构后字段路径改变
  - **回退**：保留旧字段的 alias getter/setter，逐步迁移

## 用例与边界条件

### 主路径：正常战斗
1. 角色打开 RunScreen，看到 Story 文本
2. 手牌显示在底部 dock 中，≤5 张不滚动
3. 打出/抽牌使手牌 > 5 张，HandScroll 出现滚动条
4. 鼠标悬停卡牌，CardDetailPanel 在右上角显示
5. 结束回合，敌人后，商店/路线/供应覆盖层正常弹出

### 边界 1：极小窗口
- 窗口缩至 800×600，CardDetailPanel 仍可见且不溢出屏幕
- HandScroll 自动适应宽度

### 边界 2：Controller 初始化顺序
- `_ready()` 中所有控制器 setup 完成前不会触发信号回调
- 未连接的信号静默忽略，不抛错