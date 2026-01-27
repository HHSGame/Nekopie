class_name BattlePhases
extends RefCounted

const PRE_BATTLE := "pre_battle"
const BATTLE_START := "battle_start"
const DECK_PREP := "deck_prepare"
const DRAW_CARDS := "draw_cards"
const STATUS_RESOLVE := "status_resolve"
const USE_CARD := "use_card"
const CARD_EFFECT := "card_effect"
const TARGET_REACTION := "target_reaction"
const FINAL_RESOLVE := "final_resolve"
const NEXT_CARD := "next_card"
const END_TURN_TRIGGER := "end_turn_trigger"
const DISCARD := "discard"
const END_TURN_RESOLVE := "end_turn_resolve"
const ENEMY_TURN_START := "enemy_turn_start"
const BATTLE_END_TRIGGER := "battle_end_trigger"
const BATTLE_END_RESOLVE := "battle_end_resolve"
const REWARD_EVENT := "reward_event"
const BATTLE_END := "battle_end"

const ORDER := [
	PRE_BATTLE,
	BATTLE_START,
	DECK_PREP,
	DRAW_CARDS,
	STATUS_RESOLVE,
	USE_CARD,
	CARD_EFFECT,
	TARGET_REACTION,
	FINAL_RESOLVE,
	NEXT_CARD,
	END_TURN_TRIGGER,
	DISCARD,
	END_TURN_RESOLVE,
	ENEMY_TURN_START,
	BATTLE_END_TRIGGER,
	BATTLE_END_RESOLVE,
	REWARD_EVENT,
	BATTLE_END
]
