extends Node
class_name GameData

const MOUNTAIN_NAME := "隐魔之岭"
const WORLD_TAGLINE := "异世界冒险：征服山巅，穿越魔物之影。"

const CARD_LIBRARY := {
	"strike": {
		"id": "strike",
		"name": "斩击",
		"cost": 1,
		"desc": "造成6点伤害。"
	},
	"defend": {
		"id": "defend",
		"name": "格挡",
		"cost": 1,
		"desc": "获得5点护甲。"
	},
	"flare": {
		"id": "flare",
		"name": "星火",
		"cost": 2,
		"desc": "造成10点伤害。"
	},
	"focus": {
		"id": "focus",
		"name": "专注",
		"cost": 1,
		"desc": "抽2张牌。"
	},
	"explore": {
		"id": "explore",
		"name": "踏勘",
		"cost": 1,
		"desc": "查看山势，下一场战斗获得先手。"
	}
}

const STARTER_DECK := [
	"strike",
	"strike",
	"strike",
	"defend",
	"defend",
	"explore"
]

static func get_card(card_id: String) -> Dictionary:
	return CARD_LIBRARY.get(card_id, {})

static func all_cards() -> Array:
	return CARD_LIBRARY.values()
