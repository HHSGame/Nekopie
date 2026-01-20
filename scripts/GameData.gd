extends Node

const MOUNTAIN_NAME := "隐魔之岭"
const WORLD_TAGLINE := "异世界冒险：征服山巅，穿越魔物之影。"
const FIRST_STRIKE_DAMAGE := 4

const CARD_LIBRARY := {
	"strike": {
		"id": "strike",
		"name": "斩击",
		"cost": 1,
		"damage": 6,
		"desc": "造成6点伤害。"
	},
	"defend": {
		"id": "defend",
		"name": "格挡",
		"cost": 1,
		"block": 5,
		"desc": "获得5点护甲。"
	},
	"flare": {
		"id": "flare",
		"name": "星火",
		"cost": 2,
		"damage": 10,
		"desc": "造成10点伤害。"
	},
	"focus": {
		"id": "focus",
		"name": "专注",
		"cost": 1,
		"draw": 2,
		"desc": "抽2张牌。"
	},
	"explore": {
		"id": "explore",
		"name": "踏勘",
		"cost": 1,
		"initiative": true,
		"desc": "查看山势，下场战斗先手造成%d点伤害。" % FIRST_STRIKE_DAMAGE
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

const ENEMY_LIBRARY := {
	"slime": {
		"id": "slime",
		"name": "雾泽史莱姆",
		"hp": 18,
		"attack": 4,
		"desc": "黏液喷吐，拖慢你的步伐。"
	},
	"goblin": {
		"id": "goblin",
		"name": "山道哥布林",
		"hp": 22,
		"attack": 6,
		"desc": "埋伏在林间的劫掠者。"
	},
	"wisp": {
		"id": "wisp",
		"name": "幽雾之灵",
		"hp": 20,
		"attack": 7,
		"desc": "飘忽的幽光，擅长扰乱心神。"
	},
	"ogre": {
		"id": "ogre",
		"name": "裂岩巨魔",
		"hp": 30,
		"attack": 9,
		"desc": "手持岩锤，守护山腰。"
	},
	"summit_lord": {
		"id": "summit_lord",
		"name": "山巅魔王",
		"hp": 38,
		"attack": 11,
		"desc": "盘踞山巅的魔物首领。"
	}
}

const ENCOUNTERS := [
	"slime",
	"goblin",
	"wisp",
	"ogre",
	"summit_lord"
]

static func get_card(card_id: String) -> Dictionary:
	return CARD_LIBRARY.get(card_id, {})

static func all_cards() -> Array:
	return CARD_LIBRARY.values()

static func get_enemy(enemy_id: String) -> Dictionary:
	return ENEMY_LIBRARY.get(enemy_id, {})
