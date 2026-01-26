extends Node

const MOUNTAIN_NAME := "隐魔之岭"
const WORLD_TAGLINE := "异世界冒险：征服山巅，穿越魔物之影。"
const FIRST_STRIKE_DAMAGE := 4
const SUPPLY_CHANCE := 0.6
const SUPPLY_HEAL_AMOUNT := 8
const PLAYER_PORTRAIT := "res://art/portraits/player_female.svg"

const ENEMY_CARD_LIBRARY := {
	"slime_splash": {"id": "slime_splash", "name": "黏液喷吐", "type": "attack", "cost": 1, "damage": 4},
	"slime_guard": {"id": "slime_guard", "name": "黏液护体", "type": "guard", "cost": 1, "block": 4},
	"slime_charge": {"id": "slime_charge", "name": "黏液蓄势", "type": "charge", "cost": 1, "charge": 2},
	"slime_multi": {"id": "slime_multi", "name": "黏液连击", "type": "multi_attack", "cost": 2, "damage": 2, "hits": 2},
	"mist_swipe": {"id": "mist_swipe", "name": "雾爪突袭", "type": "attack", "cost": 1, "damage": 5},
	"mist_guard": {"id": "mist_guard", "name": "影雾护体", "type": "guard", "cost": 1, "block": 3},
	"mist_charge": {"id": "mist_charge", "name": "暗影蓄势", "type": "charge", "cost": 1, "charge": 2},
	"mist_burst": {"id": "mist_burst", "name": "雾影连击", "type": "multi_attack", "cost": 2, "damage": 2, "hits": 3},
	"mist_hex": {"id": "mist_hex", "name": "薄雾诅咒", "type": "debuff", "cost": 1, "apply_weak": 1},
	"goblin_stab": {"id": "goblin_stab", "name": "短刀突刺", "type": "attack", "cost": 1, "damage": 6},
	"goblin_flurry": {"id": "goblin_flurry", "name": "疾刺连击", "type": "multi_attack", "cost": 2, "damage": 3, "hits": 2},
	"goblin_guard": {"id": "goblin_guard", "name": "掠夺防御", "type": "guard", "cost": 1, "block": 4},
	"goblin_charge": {"id": "goblin_charge", "name": "嗜战蓄力", "type": "charge", "cost": 1, "charge": 3},
	"goblin_cripple": {"id": "goblin_cripple", "name": "钩刃压制", "type": "attack_debuff", "cost": 2, "damage": 4, "apply_vulnerable": 1},
	"wolf_bite": {"id": "wolf_bite", "name": "利爪撕咬", "type": "attack", "cost": 1, "damage": 6},
	"wolf_pack": {"id": "wolf_pack", "name": "群咬", "type": "multi_attack", "cost": 2, "damage": 3, "hits": 2},
	"wolf_guard": {"id": "wolf_guard", "name": "伺机防御", "type": "guard", "cost": 1, "block": 3},
	"wolf_charge": {"id": "wolf_charge", "name": "兽性蓄势", "type": "charge", "cost": 1, "charge": 2},
	"wolf_hunt": {"id": "wolf_hunt", "name": "猎杀逼迫", "type": "attack_debuff", "cost": 2, "damage": 5, "apply_vulnerable": 1},
	"sprite_hit": {"id": "sprite_hit", "name": "碎岩冲击", "type": "attack", "cost": 1, "damage": 5},
	"sprite_guard": {"id": "sprite_guard", "name": "岩壳防护", "type": "guard", "cost": 1, "block": 5},
	"sprite_charge": {"id": "sprite_charge", "name": "石屑蓄势", "type": "charge", "cost": 1, "charge": 3},
	"sprite_blast": {"id": "sprite_blast", "name": "岩尘震荡", "type": "attack_debuff", "cost": 2, "damage": 6, "apply_weak": 1},
	"wisp_bolt": {"id": "wisp_bolt", "name": "幽光震荡", "type": "attack", "cost": 1, "damage": 5},
	"wisp_guard": {"id": "wisp_guard", "name": "雾影护体", "type": "guard", "cost": 1, "block": 3},
	"wisp_drain": {"id": "wisp_drain", "name": "幽雾汲取", "type": "drain", "cost": 2, "damage": 4, "heal": 3},
	"wisp_curse": {"id": "wisp_curse", "name": "幽影诅咒", "type": "debuff", "cost": 1, "apply_vulnerable": 1},
	"bandit_attack": {"id": "bandit_attack", "name": "飞索突袭", "type": "attack", "cost": 1, "damage": 7},
	"bandit_guard": {"id": "bandit_guard", "name": "结阵防守", "type": "guard", "cost": 1, "block": 4},
	"bandit_combo": {"id": "bandit_combo", "name": "合击乱刃", "type": "multi_attack", "cost": 2, "damage": 3, "hits": 3},
	"bandit_net": {"id": "bandit_net", "name": "锁链缠制", "type": "debuff", "cost": 1, "apply_weak": 1},
	"ogre_slam": {"id": "ogre_slam", "name": "岩锤重击", "type": "attack", "cost": 2, "damage": 10},
	"ogre_guard": {"id": "ogre_guard", "name": "石肤防御", "type": "guard", "cost": 1, "block": 5},
	"ogre_charge": {"id": "ogre_charge", "name": "裂岩蓄势", "type": "charge", "cost": 1, "charge": 5},
	"ogre_roar": {"id": "ogre_roar", "name": "暴怒咆哮", "type": "debuff", "cost": 1, "apply_weak": 2},
	"ogre_crush": {"id": "ogre_crush", "name": "重压碎击", "type": "attack_debuff", "cost": 2, "damage": 8, "apply_vulnerable": 1},
	"ice_bite": {"id": "ice_bite", "name": "冰牙突咬", "type": "attack", "cost": 1, "damage": 8},
	"ice_guard": {"id": "ice_guard", "name": "冰甲凝结", "type": "guard", "cost": 1, "block": 5},
	"ice_drain": {"id": "ice_drain", "name": "霜息汲取", "type": "drain", "cost": 2, "damage": 6, "heal": 3},
	"ice_chill": {"id": "ice_chill", "name": "寒鳞冻伤", "type": "attack_debuff", "cost": 2, "damage": 5, "apply_weak": 1},
	"yak_charge": {"id": "yak_charge", "name": "雷势蓄力", "type": "charge", "cost": 1, "charge": 4},
	"yak_ram": {"id": "yak_ram", "name": "雷角冲撞", "type": "attack", "cost": 2, "damage": 10},
	"yak_stomp": {"id": "yak_stomp", "name": "连环践踏", "type": "multi_attack", "cost": 2, "damage": 4, "hits": 2},
	"yak_shock": {"id": "yak_shock", "name": "震地雷鸣", "type": "attack_debuff", "cost": 2, "damage": 6, "apply_vulnerable": 1},
	"golem_attack": {"id": "golem_attack", "name": "沉岩猛击", "type": "attack", "cost": 2, "damage": 10},
	"golem_guard": {"id": "golem_guard", "name": "石甲护壁", "type": "guard", "cost": 1, "block": 6},
	"golem_charge": {"id": "golem_charge", "name": "山势蓄力", "type": "charge", "cost": 1, "charge": 5},
	"golem_repair": {"id": "golem_repair", "name": "石核修复", "type": "heal", "cost": 2, "heal": 6},
	"golem_weight": {"id": "golem_weight", "name": "山岳重压", "type": "debuff", "cost": 1, "apply_weak": 2},
	"boss_slash": {"id": "boss_slash", "name": "魔焰斩", "type": "attack", "cost": 1, "damage": 9},
	"boss_multi": {"id": "boss_multi", "name": "魔影连击", "type": "multi_attack", "cost": 3, "damage": 4, "hits": 3},
	"boss_charge": {"id": "boss_charge", "name": "魔力蓄势", "type": "charge", "cost": 1, "charge": 6},
	"boss_drain": {"id": "boss_drain", "name": "吞噬", "type": "drain", "cost": 2, "damage": 6, "heal": 4},
	"boss_guard": {"id": "boss_guard", "name": "魔纹护壁", "type": "guard", "cost": 1, "block": 6},
	"boss_heal": {"id": "boss_heal", "name": "暗息恢复", "type": "heal", "cost": 2, "heal": 8},
	"boss_fear": {"id": "boss_fear", "name": "魔威恐惧", "type": "debuff", "cost": 1, "apply_vulnerable": 2},
	"boss_curse": {"id": "boss_curse", "name": "腐魂咒印", "type": "attack_debuff", "cost": 2, "damage": 6, "apply_weak": 2}
}

const UPGRADE_LIBRARY := {
	"strike": {"damage": 3},
	"defend": {"block": 3},
	"flare": {"damage": 4},
	"focus": {"draw": 1},
	"explore": {"initiative_bonus": 2},
	"recover": {"heal": 3}
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
	},
	"recover": {
		"id": "recover",
		"name": "恢复",
		"cost": 1,
		"heal": 6,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_recover.svg",
		"art": "res://art/cards/card_art_recover.svg",
		"desc": "恢复6点生命。"
	}
}

const STARTER_DECK := [
	"strike",
	"strike",
	"strike",
	"defend",
	"defend",
	"explore",
	"recover"
]

const ENEMY_LIBRARY := {
	"slime": {
		"id": "slime",
		"name": "雾泽史莱姆",
		"hp": 18,
		"attack": 4,
		"score": 40,
		"portrait": "res://art/portraits/enemy_slime.svg",
		"desc": "黏液喷吐，拖慢你的步伐。",
		"deck": [
			"slime_splash",
			"slime_splash",
			"slime_guard",
			"slime_guard",
			"slime_charge",
			"slime_multi"
		]
	},
	"goblin": {
		"id": "goblin",
		"name": "山道哥布林",
		"hp": 22,
		"attack": 6,
		"score": 60,
		"portrait": "res://art/portraits/enemy_goblin.svg",
		"desc": "埋伏在林间的劫掠者。",
		"deck": [
			"goblin_stab",
			"goblin_stab",
			"goblin_flurry",
			"goblin_guard",
			"goblin_charge",
			"goblin_cripple",
			"goblin_guard"
		]
	},
	"mist_imp": {
		"id": "mist_imp",
		"name": "雾影小妖",
		"hp": 18,
		"attack": 5,
		"score": 50,
		"portrait": "res://art/portraits/enemy_mist_imp.svg",
		"desc": "藏身薄雾的狡黠小妖。",
		"deck": [
			"mist_swipe",
			"mist_guard",
			"mist_hex",
			"mist_swipe",
			"mist_charge",
			"mist_burst",
			"mist_guard"
		]
	},
	"slope_wolf": {
		"id": "slope_wolf",
		"name": "山坡野狼",
		"hp": 20,
		"attack": 6,
		"score": 65,
		"portrait": "res://art/portraits/enemy_slope_wolf.svg",
		"desc": "在乱石间游走的饥饿猛兽。",
		"deck": [
			"wolf_bite",
			"wolf_bite",
			"wolf_pack",
			"wolf_guard",
			"wolf_charge",
			"wolf_hunt",
			"wolf_guard"
		]
	},
	"rock_sprite": {
		"id": "rock_sprite",
		"name": "碎岩精",
		"hp": 24,
		"attack": 5,
		"score": 68,
		"portrait": "res://art/portraits/enemy_rock_sprite.svg",
		"desc": "碎石凝形的精怪。",
		"deck": [
			"sprite_hit",
			"sprite_guard",
			"sprite_charge",
			"sprite_guard",
			"sprite_blast",
			"sprite_guard",
			"sprite_hit"
		]
	},
	"wisp": {
		"id": "wisp",
		"name": "幽雾之灵",
		"hp": 20,
		"attack": 7,
		"score": 70,
		"portrait": "res://art/portraits/enemy_wisp.svg",
		"desc": "飘忽的幽光，擅长扰乱心神。",
		"deck": [
			"wisp_bolt",
			"wisp_guard",
			"wisp_drain",
			"wisp_curse",
			"wisp_bolt",
			"wisp_guard",
			"wisp_drain"
		]
	},
	"cliff_bandits": {
		"id": "cliff_bandits",
		"name": "断崖盗团",
		"hp": 26,
		"attack": 7,
		"score": 80,
		"portrait": "res://art/portraits/enemy_cliff_bandits.svg",
		"desc": "驾轻就熟的山崖掠夺者。",
		"deck": [
			"bandit_attack",
			"bandit_combo",
			"bandit_guard",
			"bandit_net",
			"bandit_attack",
			"bandit_combo",
			"bandit_guard"
		]
	},
	"ogre": {
		"id": "ogre",
		"name": "裂岩巨魔",
		"hp": 30,
		"attack": 9,
		"score": 90,
		"portrait": "res://art/portraits/enemy_ogre.svg",
		"desc": "手持岩锤，守护山腰。",
		"deck": [
			"ogre_charge",
			"ogre_slam",
			"ogre_guard",
			"ogre_roar",
			"ogre_slam",
			"ogre_crush",
			"ogre_guard"
		]
	},
	"ice_lizard": {
		"id": "ice_lizard",
		"name": "冰霜巨蜥",
		"hp": 30,
		"attack": 8,
		"score": 100,
		"portrait": "res://art/portraits/enemy_ice_lizard.svg",
		"desc": "寒气缠身的巨蜥，鳞甲锋利。",
		"deck": [
			"ice_bite",
			"ice_guard",
			"ice_drain",
			"ice_chill",
			"ice_bite",
			"ice_guard",
			"ice_drain"
		]
	},
	"thunder_yak": {
		"id": "thunder_yak",
		"name": "雷鸣野牦",
		"hp": 32,
		"attack": 9,
		"score": 110,
		"portrait": "res://art/portraits/enemy_thunder_yak.svg",
		"desc": "披着雷霆之势的巨牦。",
		"deck": [
			"yak_charge",
			"yak_ram",
			"yak_stomp",
			"yak_shock",
			"yak_ram",
			"yak_charge",
			"yak_stomp"
		]
	},
	"stone_golem": {
		"id": "stone_golem",
		"name": "石甲魔像",
		"hp": 36,
		"attack": 10,
		"score": 120,
		"portrait": "res://art/portraits/enemy_stone_golem.svg",
		"desc": "沉稳厚重的石甲守卫。",
		"deck": [
			"golem_guard",
			"golem_charge",
			"golem_attack",
			"golem_repair",
			"golem_weight",
			"golem_guard",
			"golem_attack"
		]
	},
	"summit_lord": {
		"id": "summit_lord",
		"name": "山巅魔王",
		"hp": 38,
		"attack": 11,
		"score": 140,
		"portrait": "res://art/portraits/enemy_boss.svg",
		"desc": "盘踞山巅的魔物首领。",
		"deck": [
			"boss_slash",
			"boss_multi",
			"boss_charge",
			"boss_drain",
			"boss_guard",
			"boss_heal",
			"boss_fear",
			"boss_slash",
			"boss_curse",
			"boss_multi"
		]
	}
}

const ENCOUNTERS := [
	"slime",
	"mist_imp",
	"goblin",
	"slope_wolf",
	"rock_sprite",
	"wisp",
	"cliff_bandits",
	"ogre",
	"ice_lizard",
	"thunder_yak",
	"stone_golem",
	"summit_lord"
]

static func get_card(card_id: String) -> Dictionary:
	return CARD_LIBRARY.get(card_id, {})

static func all_cards() -> Array:
	return CARD_LIBRARY.values()

static func all_card_ids() -> Array:
	return CARD_LIBRARY.keys()

static func get_enemy(enemy_id: String) -> Dictionary:
	return ENEMY_LIBRARY.get(enemy_id, {})

static func get_enemy_card_data(card_id: String) -> Dictionary:
	return ENEMY_CARD_LIBRARY.get(card_id, {}).duplicate(true)

static func get_card_data(card_id: String, upgraded: bool = false) -> Dictionary:
	var base: Dictionary = CARD_LIBRARY.get(card_id, {}).duplicate(true)
	if base.is_empty():
		return {}
	if upgraded:
		var upgrade: Dictionary = UPGRADE_LIBRARY.get(card_id, {})
		for key in upgrade.keys():
			match String(key):
				"damage", "block", "draw", "heal":
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
	if card_data.has("heal"):
		parts.append("恢复%d点生命。" % int(card_data.get("heal", 0)))
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
