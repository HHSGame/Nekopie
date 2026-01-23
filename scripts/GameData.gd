extends Node

const MOUNTAIN_NAME := "隐魔之岭"
const WORLD_TAGLINE := "异世界冒险：征服山巅，穿越魔物之影。"
const FIRST_STRIKE_DAMAGE := 4
const EVENT_CHANCE := 0.5
const SUPPLY_CHANCE := 0.6
const SUPPLY_HEAL_AMOUNT := 8
const PLAYER_PORTRAIT := "res://art/portraits/player_female.svg"

const UPGRADE_LIBRARY := {
	"strike": {"damage": 3},
	"defend": {"block": 3},
	"flare": {"damage": 4},
	"focus": {"draw": 1},
	"explore": {"initiative_bonus": 2}
}

const CARD_LIBRARY := {
	"strike": {
		"id": "strike",
		"name": "斩击",
		"cost": 1,
		"damage": 6,
		"rarity": "common",
		"icon": "res://art/cards/icon_strike.svg",
		"art": "res://art/cards/card_art_strike.svg",
		"desc": "造成6点伤害。"
	},
	"defend": {
		"id": "defend",
		"name": "格挡",
		"cost": 1,
		"block": 5,
		"rarity": "common",
		"icon": "res://art/cards/icon_defend.svg",
		"art": "res://art/cards/card_art_defend.svg",
		"desc": "获得5点护甲。"
	},
	"flare": {
		"id": "flare",
		"name": "星火",
		"cost": 2,
		"damage": 10,
		"rarity": "rare",
		"icon": "res://art/cards/icon_flare.svg",
		"art": "res://art/cards/card_art_flare.svg",
		"desc": "造成10点伤害。"
	},
	"focus": {
		"id": "focus",
		"name": "专注",
		"cost": 1,
		"draw": 2,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_focus.svg",
		"art": "res://art/cards/card_art_focus.svg",
		"desc": "抽2张牌。"
	},
	"explore": {
		"id": "explore",
		"name": "踏勘",
		"cost": 1,
		"initiative": true,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_explore.svg",
		"art": "res://art/cards/card_art_explore.svg",
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
		"portrait": "res://art/portraits/enemy_slime.svg",
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
		"portrait": "res://art/portraits/enemy_goblin.svg",
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
		"portrait": "res://art/portraits/enemy_wisp.svg",
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
		"portrait": "res://art/portraits/enemy_ogre.svg",
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
		"portrait": "res://art/portraits/enemy_boss.svg",
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

static func all_card_ids() -> Array:
	return CARD_LIBRARY.keys()

static func get_enemy(enemy_id: String) -> Dictionary:
	return ENEMY_LIBRARY.get(enemy_id, {})

static func get_card_data(card_id: String, upgraded: bool = false) -> Dictionary:
	var base: Dictionary = CARD_LIBRARY.get(card_id, {}).duplicate(true)
	if base.is_empty():
		return {}
	if upgraded:
		var upgrade: Dictionary = UPGRADE_LIBRARY.get(card_id, {})
		for key in upgrade.keys():
			match String(key):
				"damage", "block", "draw":
					base[key] = int(base.get(key, 0)) + int(upgrade[key])
				"initiative_bonus":
					base[key] = int(base.get(key, 0)) + int(upgrade[key])
		base["name"] = "%s+" % str(base.get("name", ""))
	base["desc"] = build_description(base)
	return base

static func build_description(card_data: Dictionary) -> String:
	var parts: Array = []
	if card_data.has("damage"):
		parts.append("造成%d点伤害。" % int(card_data.get("damage", 0)))
	if card_data.has("block"):
		parts.append("获得%d点护甲。" % int(card_data.get("block", 0)))
	if card_data.has("draw"):
		parts.append("抽%d张牌。" % int(card_data.get("draw", 0)))
	if bool(card_data.get("initiative", false)):
		var bonus: int = int(card_data.get("initiative_bonus", 0))
		var strike: int = FIRST_STRIKE_DAMAGE + bonus
		parts.append("查看山势，下场战斗先手造成%d点伤害。" % strike)
	if parts.is_empty():
		return str(card_data.get("desc", ""))
	return "".join(parts)

static func get_random_card_id() -> String:
	var card_ids := CARD_LIBRARY.keys()
	if card_ids.is_empty():
		return ""
	return str(card_ids.pick_random())

static func get_random_event() -> Dictionary:
	if EVENTS.is_empty():
		return {}
	return EVENTS.pick_random()
