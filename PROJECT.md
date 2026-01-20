# Isekai Mountain Deckbuilder

## 项目概览
一款基于 Godot 4.2 的卡组构筑游戏，背景为异世界冒险。玩家需要在山脚整理卡组、踏上攀登之旅，击退沿途魔物并最终登顶通关。卡牌美术目前保留为占位区域。

## 已完成内容
- 主菜单与剧情介绍，提供开始、卡组构筑与退出入口。
- 卡组构筑界面，支持从卡池添加卡牌、从牌组移除卡牌。
- 攀登流程界面，以关卡次数表示攀登进度与通关条件。
- 卡牌 UI 组件与卡池数据（基础攻击、防御、探索等）。
- GameData 与 RunState 作为自动加载，统一卡牌与流程状态。

## 场景与脚本结构
- `scenes/Main.tscn` + `scripts/Main.gd`: 主菜单与入口导航。
- `scenes/DeckBuilder.tscn` + `scripts/DeckBuilder.gd`: 卡组构筑与卡牌增删。
- `scenes/RunScreen.tscn` + `scripts/RunScreen.gd`: 攀登进度展示与通关反馈。
- `scenes/CardWidget.tscn` + `scripts/CardWidget.gd`: 卡牌 UI 组件（含空白卡面区域）。
- `scripts/GameData.gd`: 卡池、起始牌组、世界观文本。
- `scripts/RunState.gd`: 当前卡组、攀登进度状态。

## 当前限制
- 未实现回合制战斗、抽牌/弃牌/手牌等核心战斗逻辑。
- 魔物与关卡事件仅为文案与进度计数。
- 卡牌美术与音效资源为空白占位。

## 运行方式
使用 Godot 4.2 打开工程，运行默认主场景 `res://scenes/Main.tscn`。

## 接下来的实现计划
1. 战斗核心循环：抽牌/手牌/弃牌与出牌效果结算。
2. 魔物与遭遇数据：不同层级敌人与山道事件。
3. 奖励与卡组成长：战后奖励、卡牌升级/移除。
4. UI 细化：战斗界面、卡牌详情、数值反馈。
5. 持久化：局内与局外保存、战斗日志。
