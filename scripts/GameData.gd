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
	"strike": [{"damage": 3}],
	"defend": [{"block": 3}],
	"flare": [{"damage": 4}],
	"focus": [{"draw": 1}],
	"explore": [{"initiative_bonus": 2}],
	"recover": [{"heal": 3}],
	"pierce": [{"damage": 2}],
	"pierce_heavy": [{"damage": 3}],
	"lifesteal_slash": [{"damage": 3}],
	"block_smash": [{"damage_bonus": 2}],
	"missing_hp_slash": [{"missing_hp_cap": 6}],
	"poison_blade": [{"damage": 2, "apply_poison": 1}],
	"flame_slash": [{"damage": 2, "apply_burn": 1}],
	"combo_slash": [{"damage": 2}],
	"execute": [{"damage": 3}],
	"guard_pierce": [{"damage": 2}],
	"charge": [{"charge_mult": 1}, {"charge_mult": 1}],
	"quickdraw": [{"draw": 1}, {"draw": 1}],
	"counter_stance": [{"counter_ratio": 0.7}, {"counter_ratio": 0.7}],
	"nullify": [{"nullify_count": 1}],
	"loot_echo": [{"damage_draw": 1}],
	"blood_mark": [{"apply_bleed": 1}],
	"battle_fury": [{"attack_bonus_on_attack": 1}],
	"precision": [{"next_attack_bonus": 1}],
	"imbalance": [{"enemy_block_gain_reduction": 2}],
	"keen_blade": [{"equip_attack_bonus": 1}],
	"buffer_cloak": [{"equip_damage_reduction": 1}],
	"combo_bracer": [{"equip_attack_chain_draw": 1}],
	"guard_belt": [{"equip_defend_chain_block": 1}],
	"blood_charm": [{"equip_block_on_damage": 1}],
	"hunter_mark": [{"equip_bleed_bonus_per_stack": 1}],
	"swift_mind": [{"power_first_attack_draw": 1}],
	"steadfast_soul": [{"power_first_damage_block": 1}],
	"blood_forge": [{"power_bleed_on_damage": 1}]
}

const CARD_LIBRARY := {
	"strike": {
		"id": "strike",
		"name": "斩击",
		"kind": "attack",
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
		"kind": "guard",
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
		"kind": "attack",
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
		"kind": "skill",
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
		"kind": "skill",
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
		"kind": "skill",
		"cost": 1,
		"heal": 6,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_recover.svg",
		"art": "res://art/cards/card_art_recover.svg",
		"desc": "恢复6点生命。"
	},
	"pierce": {
		"id": "pierce",
		"name": "穿刺",
		"kind": "attack",
		"cost": 1,
		"damage": 6,
		"pierce": true,
		"rarity": "common",
		"icon": "res://art/cards/icon_strike.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"pierce_heavy": {
		"id": "pierce_heavy",
		"name": "破甲突击",
		"kind": "attack",
		"cost": 2,
		"damage": 10,
		"pierce": true,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_strike.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"lifesteal_slash": {
		"id": "lifesteal_slash",
		"name": "血噬斩",
		"kind": "attack",
		"cost": 2,
		"damage": 8,
		"lifesteal_ratio": 0.5,
		"rarity": "rare",
		"icon": "res://art/cards/icon_strike.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"block_smash": {
		"id": "block_smash",
		"name": "护甲猛击",
		"kind": "attack",
		"cost": 1,
		"damage_bonus": 2,
		"damage_from_block": true,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_strike.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"missing_hp_slash": {
		"id": "missing_hp_slash",
		"name": "破军",
		"kind": "attack",
		"cost": 2,
		"damage_from_missing_hp": true,
		"missing_hp_cap": 20,
		"rarity": "rare",
		"icon": "res://art/cards/icon_strike.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"poison_blade": {
		"id": "poison_blade",
		"name": "毒刃",
		"kind": "attack",
		"cost": 1,
		"damage": 4,
		"apply_poison": 3,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_strike.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"flame_slash": {
		"id": "flame_slash",
		"name": "烈焰斩",
		"kind": "attack",
		"cost": 2,
		"damage": 7,
		"apply_burn": 2,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_strike.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"combo_slash": {
		"id": "combo_slash",
		"name": "连斩",
		"kind": "attack",
		"cost": 1,
		"damage": 4,
		"damage_per_attack_chain": 2,
		"rarity": "common",
		"icon": "res://art/cards/icon_strike.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"execute": {
		"id": "execute",
		"name": "斩杀",
		"kind": "attack",
		"cost": 2,
		"damage": 8,
		"execute_threshold": 0.3,
		"execute_mult": 2.0,
		"rarity": "rare",
		"icon": "res://art/cards/icon_strike.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"guard_pierce": {
		"id": "guard_pierce",
		"name": "戒备突刺",
		"kind": "attack",
		"cost": 1,
		"damage": 5,
		"pierce_if_block": 8,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_strike.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"charge": {
		"id": "charge",
		"name": "蓄力",
		"kind": "skill",
		"cost": 1,
		"charge_mult": 2.0,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_focus.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"quickdraw": {
		"id": "quickdraw",
		"name": "迅读",
		"kind": "skill",
		"cost": 0,
		"draw": 2,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_focus.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"stasis": {
		"id": "stasis",
		"name": "停滞结界",
		"kind": "skill",
		"cost": 0,
		"skip_enemy_turn": true,
		"exhaust": true,
		"rarity": "rare",
		"icon": "res://art/cards/icon_focus.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"precision": {
		"id": "precision",
		"name": "精准校准",
		"kind": "skill",
		"cost": 1,
		"next_attack_pierce": true,
		"next_attack_bonus": 2,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_focus.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"imbalance": {
		"id": "imbalance",
		"name": "失衡打击",
		"kind": "skill",
		"cost": 1,
		"enemy_block_gain_reduction": 3,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_focus.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"shadowstep": {
		"id": "shadowstep",
		"name": "影步",
		"kind": "skill",
		"cost": 0,
		"retain": true,
		"next_card_cost_delta": -1,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_focus.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"counter_stance": {
		"id": "counter_stance",
		"name": "反击姿态",
		"kind": "status",
		"cost": 1,
		"counter_ratio": 0.7,
		"rarity": "rare",
		"icon": "res://art/cards/icon_explore.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"nullify": {
		"id": "nullify",
		"name": "护幕",
		"kind": "status",
		"cost": 1,
		"nullify_count": 1,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_explore.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"loot_echo": {
		"id": "loot_echo",
		"name": "补给回响",
		"kind": "status",
		"cost": 1,
		"damage_draw": 2,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_explore.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"blood_mark": {
		"id": "blood_mark",
		"name": "血痕标记",
		"kind": "status",
		"cost": 1,
		"apply_bleed": 2,
		"bleed_on_attack": 1,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_explore.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"battle_fury": {
		"id": "battle_fury",
		"name": "嗜战",
		"kind": "status",
		"cost": 1,
		"attack_bonus_on_attack": 1,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_explore.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"keen_blade": {
		"id": "keen_blade",
		"name": "研锋之刃",
		"kind": "equipment",
		"cost": 2,
		"equip_attack_bonus": 1,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_flare.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"buffer_cloak": {
		"id": "buffer_cloak",
		"name": "缓冲披风",
		"kind": "equipment",
		"cost": 2,
		"equip_damage_reduction": 1,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_flare.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"combo_bracer": {
		"id": "combo_bracer",
		"name": "连击腕轮",
		"kind": "equipment",
		"cost": 2,
		"equip_attack_chain_draw": 1,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_flare.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"guard_belt": {
		"id": "guard_belt",
		"name": "守势腰带",
		"kind": "equipment",
		"cost": 2,
		"equip_defend_chain_block": 2,
		"rarity": "uncommon",
		"icon": "res://art/cards/icon_flare.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"blood_charm": {
		"id": "blood_charm",
		"name": "血纹护符",
		"kind": "equipment",
		"cost": 2,
		"equip_block_on_damage": 1,
		"rarity": "rare",
		"icon": "res://art/cards/icon_flare.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"hunter_mark": {
		"id": "hunter_mark",
		"name": "猎杀徽记",
		"kind": "equipment",
		"cost": 2,
		"equip_bleed_bonus_per_stack": 1,
		"rarity": "rare",
		"icon": "res://art/cards/icon_flare.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"swift_mind": {
		"id": "swift_mind",
		"name": "迅捷心法",
		"kind": "power",
		"cost": 2,
		"power_first_attack_draw": 1,
		"rarity": "rare",
		"icon": "res://art/cards/icon_flare.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"steadfast_soul": {
		"id": "steadfast_soul",
		"name": "坚毅之魂",
		"kind": "power",
		"cost": 2,
		"power_first_damage_block": 2,
		"rarity": "rare",
		"icon": "res://art/cards/icon_flare.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"blood_forge": {
		"id": "blood_forge",
		"name": "血炼",
		"kind": "power",
		"cost": 2,
		"power_bleed_on_damage": 1,
		"rarity": "rare",
		"icon": "res://art/cards/icon_flare.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"fatigue": {
		"id": "fatigue",
		"name": "疲惫",
		"kind": "curse",
		"cost": 0,
		"block_disabled": true,
		"ethereal": true,
		"exhaust": true,
		"rarity": "common",
		"icon": "res://art/cards/icon_recover.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	},
	"delay": {
		"id": "delay",
		"name": "迟滞",
		"kind": "curse",
		"cost": 0,
		"next_card_cost_delta": 1,
		"ethereal": true,
		"exhaust": true,
		"rarity": "common",
		"icon": "res://art/cards/icon_recover.svg",
		"art": "res://art/cards/card_art_placeholder.svg"
	}
}

const STARTER_DECK := [
	"strike",
	"strike",
	"strike",
	"strike",
	"strike",
	"defend",
	"defend",
	"defend",
	"defend",
	"pierce",
	"pierce",
	"charge",
	"focus",
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

static func get_card_data(card_id: String, upgrade_level: Variant = 0) -> Dictionary:
	var base: Dictionary = CARD_LIBRARY.get(card_id, {}).duplicate(true)
	if base.is_empty():
		return {}
	var level := 0
	if typeof(upgrade_level) == TYPE_BOOL:
		level = 1 if bool(upgrade_level) else 0
	else:
		level = int(upgrade_level)
	if level > 0:
		var upgrades: Array = UPGRADE_LIBRARY.get(card_id, [])
		var applied := min(level, upgrades.size())
		for i in range(applied):
			var upgrade: Dictionary = upgrades[i]
			for key in upgrade.keys():
				var key_name := String(key)
				var delta = upgrade[key]
				match key_name:
					"damage", "block", "draw", "heal", "initiative_bonus", "apply_poison", "apply_burn", "apply_bleed":
						base[key_name] = int(base.get(key_name, 0)) + int(delta)
					"missing_hp_cap", "damage_bonus", "enemy_block_gain_reduction":
						base[key_name] = int(base.get(key_name, 0)) + int(delta)
					"charge_mult", "counter_ratio":
						base[key_name] = float(base.get(key_name, 0.0)) + float(delta)
					"next_attack_bonus":
						base[key_name] = int(base.get(key_name, 0)) + int(delta)
					"damage_draw":
						base[key_name] = int(base.get(key_name, 0)) + int(delta)
					"attack_bonus_on_attack":
						base[key_name] = int(base.get(key_name, 0)) + int(delta)
					"equip_attack_bonus", "equip_damage_reduction", "equip_attack_chain_draw":
						base[key_name] = int(base.get(key_name, 0)) + int(delta)
					"equip_defend_chain_block", "equip_block_on_damage", "equip_bleed_bonus_per_stack":
						base[key_name] = int(base.get(key_name, 0)) + int(delta)
					"power_first_attack_draw", "power_first_damage_block", "power_bleed_on_damage":
						base[key_name] = int(base.get(key_name, 0)) + int(delta)
					_:
						base[key_name] = delta
		base["name"] = "%s+%d" % [str(base.get("name", "")), level]
	base["desc"] = build_description(base)
	return base

static func get_max_upgrade_level(card_id: String) -> int:
	var upgrades: Array = UPGRADE_LIBRARY.get(card_id, [])
	return upgrades.size()

static func build_description(card_data: Dictionary) -> String:
	var override_desc: String = str(card_data.get("desc_override", ""))
	if not override_desc.is_empty():
		return override_desc
	var parts: Array = []
	var damage: int = int(card_data.get("damage", 0))
	var pierce := bool(card_data.get("pierce", false))
	if card_data.has("damage_from_block"):
		var bonus := int(card_data.get("damage_bonus", 0))
		if bonus > 0:
			parts.append("造成当前护甲+%d点伤害。" % bonus)
		else:
			parts.append("造成等同当前护甲的伤害。")
	elif card_data.has("damage_from_missing_hp"):
		var cap := int(card_data.get("missing_hp_cap", 0))
		if cap > 0:
			parts.append("造成等同已损失生命值的伤害（上限%d）。" % cap)
		else:
			parts.append("造成等同已损失生命值的伤害。")
	elif card_data.has("damage_from_current_hp_ratio"):
		var ratio := int(round(float(card_data.get("damage_from_current_hp_ratio", 0.0)) * 100.0))
		parts.append("造成等同当前生命%d%%的伤害。" % ratio)
	elif damage > 0:
		if pierce:
			parts.append("穿刺造成%d点伤害（无视护甲）。" % damage)
		else:
			parts.append("造成%d点伤害。" % damage)
	if card_data.has("damage_per_attack_chain"):
		parts.append("本回合每打出一张攻击牌，伤害+%d。" % int(card_data.get("damage_per_attack_chain", 0)))
	if card_data.has("pierce_if_block"):
		parts.append("护甲≥%d时穿刺。" % int(card_data.get("pierce_if_block", 0)))
	if card_data.has("execute_threshold"):
		var threshold := int(round(float(card_data.get("execute_threshold", 0.0)) * 100.0))
		parts.append("敌人生命≤%d%%时伤害翻倍。" % threshold)
	if card_data.has("block"):
		parts.append("获得%d点护甲。" % int(card_data.get("block", 0)))
	if card_data.has("draw"):
		parts.append("抽%d张牌。" % int(card_data.get("draw", 0)))
	if card_data.has("heal"):
		parts.append("恢复%d点生命。" % int(card_data.get("heal", 0)))
	var lifesteal_ratio := float(card_data.get("lifesteal_ratio", 0.0))
	if lifesteal_ratio > 0.0:
		parts.append("吸血%d%%。" % int(round(lifesteal_ratio * 100.0)))
	if card_data.has("apply_bleed"):
		parts.append("施加流血%d层。" % int(card_data.get("apply_bleed", 0)))
	if card_data.has("apply_poison"):
		parts.append("施加中毒%d层。" % int(card_data.get("apply_poison", 0)))
	if card_data.has("apply_burn"):
		parts.append("施加灼烧%d层。" % int(card_data.get("apply_burn", 0)))
	if card_data.has("bleed_on_attack"):
		parts.append("本回合每次攻击额外叠加流血%d层。" % int(card_data.get("bleed_on_attack", 0)))
	if card_data.has("counter_ratio"):
		parts.append("本回合受伤时反击所受伤害的%d%%。" % int(round(float(card_data.get("counter_ratio", 0.0)) * 100.0)))
	if card_data.has("nullify_count"):
		parts.append("本回合下一张针对你的敌方卡牌失效。")
	if card_data.has("damage_draw"):
		parts.append("本回合受伤时抽%d张。" % int(card_data.get("damage_draw", 0)))
	if card_data.has("attack_bonus_on_attack"):
		parts.append("本回合每次攻击伤害+%d。" % int(card_data.get("attack_bonus_on_attack", 0)))
	if card_data.has("charge_mult"):
		parts.append("获得蓄力x%.1f。" % float(card_data.get("charge_mult", 0.0)))
	if bool(card_data.get("skip_enemy_turn", false)):
		parts.append("跳过敌人本回合。")
	if bool(card_data.get("next_attack_pierce", false)):
		parts.append("下一次攻击必定穿刺。")
	if card_data.has("next_attack_bonus"):
		parts.append("下一次攻击伤害+%d。" % int(card_data.get("next_attack_bonus", 0)))
	if card_data.has("enemy_block_gain_reduction"):
		parts.append("本回合敌人护甲获得-%d。" % int(card_data.get("enemy_block_gain_reduction", 0)))
	if card_data.has("next_card_cost_delta"):
		var delta := int(card_data.get("next_card_cost_delta", 0))
		parts.append("下一张牌费用%+d。" % delta)
	if bool(card_data.get("block_disabled", false)):
		parts.append("本回合无法获得护甲。")
	if card_data.has("equip_attack_bonus"):
		parts.append("本场战斗攻击伤害+%d。" % int(card_data.get("equip_attack_bonus", 0)))
	if card_data.has("equip_damage_reduction"):
		parts.append("本场战斗受到伤害-%d。" % int(card_data.get("equip_damage_reduction", 0)))
	if card_data.has("equip_attack_chain_draw"):
		parts.append("每回合连续2次攻击抽%d张。" % int(card_data.get("equip_attack_chain_draw", 0)))
	if card_data.has("equip_defend_chain_block"):
		parts.append("每回合连续2次防御护甲+%d。" % int(card_data.get("equip_defend_chain_block", 0)))
	if card_data.has("equip_block_on_damage"):
		parts.append("造成伤害时护甲+%d。" % int(card_data.get("equip_block_on_damage", 0)))
	if card_data.has("equip_bleed_bonus_per_stack"):
		parts.append("流血伤害提升。")
	if card_data.has("power_first_attack_draw"):
		parts.append("每回合首次攻击抽%d张。" % int(card_data.get("power_first_attack_draw", 0)))
	if card_data.has("power_first_damage_block"):
		parts.append("每回合首次受伤护甲+%d。" % int(card_data.get("power_first_damage_block", 0)))
	if card_data.has("power_bleed_on_damage"):
		parts.append("造成伤害时附加流血+%d。" % int(card_data.get("power_bleed_on_damage", 0)))
	if bool(card_data.get("retain", false)):
		parts.append("保留。")
	if bool(card_data.get("exhaust", false)):
		parts.append("消耗。")
	if bool(card_data.get("ethereal", false)):
		parts.append("虚无。")
	if parts.is_empty():
		return str(card_data.get("desc", ""))
	return "".join(parts)

static func get_random_card_id() -> String:
	var card_ids := CARD_LIBRARY.keys()
	if card_ids.is_empty():
		return ""
	return str(card_ids.pick_random())
