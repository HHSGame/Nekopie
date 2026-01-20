extends Node

const MOUNTAIN_NAME := "隐魔之岭"
const WORLD_TAGLINE := "异世界冒险：征服山巅，穿越魔物之影。"
const FIRST_STRIKE_DAMAGE := 4
const EVENT_CHANCE := 0.5

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
		"desc": "黏液喷吐，拖慢你的步伐。",
		"intents": [
			{"type": "attack", "value": 4, "text": "黏液喷吐"},
			{"type": "guard", "value": 4, "text": "黏液护体"}
		]
	},
	"goblin": {
		"id": "goblin",
		"name": "山道哥布林",
		"hp": 22,
		"attack": 6,
		"desc": "埋伏在林间的劫掠者。",
		"intents": [
			{"type": "attack", "value": 6, "text": "短刀突刺"},
			{"type": "multi_attack", "value": 3, "hits": 2, "text": "疾刺连击"},
			{"type": "charge", "value": 3, "text": "嗜战蓄力"}
		]
	},
	"wisp": {
		"id": "wisp",
		"name": "幽雾之灵",
		"hp": 20,
		"attack": 7,
		"desc": "飘忽的幽光，擅长扰乱心神。",
		"intents": [
			{"type": "attack", "value": 5, "text": "幽光震荡"},
			{"type": "drain", "value": 4, "heal": 3, "text": "幽雾汲取"},
			{"type": "guard", "value": 3, "text": "雾影护体"}
		]
	},
	"ogre": {
		"id": "ogre",
		"name": "裂岩巨魔",
		"hp": 30,
		"attack": 9,
		"desc": "手持岩锤，守护山腰。",
		"intents": [
			{"type": "charge", "value": 5, "text": "裂岩蓄势"},
			{"type": "attack", "value": 10, "text": "岩锤重击"},
			{"type": "guard", "value": 5, "text": "石肤防御"}
		]
	},
	"summit_lord": {
		"id": "summit_lord",
		"name": "山巅魔王",
		"hp": 38,
		"attack": 11,
		"desc": "盘踞山巅的魔物首领。",
		"intents": [
			{"type": "attack", "value": 9, "text": "魔焰斩"},
			{"type": "multi_attack", "value": 4, "hits": 3, "text": "魔影连击"},
			{"type": "charge", "value": 6, "text": "魔力蓄势"},
			{"type": "drain", "value": 6, "heal": 4, "text": "吞噬"}
		]
	}
}

const ENCOUNTERS := [
	"slime",
	"goblin",
	"wisp",
	"ogre",
	"summit_lord"
]

const EVENTS := [
	{
		"id": "healing_spring",
		"name": "清泉",
		"desc": "泉水涌动，恢复体力。",
		"effect": "heal",
		"value": 8
	},
	{
		"id": "rockfall",
		"name": "落石",
		"desc": "山路崩塌，你受到冲击。",
		"effect": "damage",
		"value": 6
	},
	{
		"id": "mystic_cache",
		"name": "遗落补给",
		"desc": "拾到未知卡牌。",
		"effect": "card",
		"value": 1
	}
]

static func get_card(card_id: String) -> Dictionary:
	return CARD_LIBRARY.get(card_id, {})

static func all_cards() -> Array:
	return CARD_LIBRARY.values()

static func get_enemy(enemy_id: String) -> Dictionary:
	return ENEMY_LIBRARY.get(enemy_id, {})

static func get_random_card_id() -> String:
	var card_ids := CARD_LIBRARY.keys()
	if card_ids.is_empty():
		return ""
	return str(card_ids.pick_random())

static func get_random_event() -> Dictionary:
	if EVENTS.is_empty():
		return {}
	return EVENTS.pick_random()
