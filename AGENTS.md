# 协作与注意事项

## 项目约定
- 引擎版本：Godot 4.2。
- 题材与主线：异世界冒险，征服隐藏魔物的山并登顶通关。
- 卡牌美术暂时保留为空白占位，不引入成品卡面。

## 交付与文档
- 每次完成任务后，更新 `PROJECT.md` 的项目状态与后续计划。
- 同步将当次改动记录到 `CHANGELOG.md`。
- 变更完成后总结并提交到 Git（单次任务对应一次提交）。

## 代码与结构
- 保持现有场景与脚本分工：Main / DeckBuilder / RunScreen / CardWidget。
- `GameData` 与 `RunState` 作为 autoload，统一维护卡池与流程状态。
