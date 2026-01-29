class_name CombatActor
extends RefCounted

const STATUS_WEAK := "weak"
const STATUS_VULNERABLE := "vulnerable"
const STATUS_CHARGE_MULT := "charge_mult"
const STATUS_NEXT_ATTACK_BONUS := "next_attack_bonus"
const STATUS_NEXT_ATTACK_PIERCE := "next_attack_pierce"
const STATUS_COUNTER_RATIO := "counter_ratio"
const STATUS_NULLIFY := "nullify"
const STATUS_DAMAGE_DRAW := "damage_draw"
const STATUS_BLEED_ON_ATTACK := "bleed_on_attack"
const STATUS_ATTACK_BONUS_ON_ATTACK := "attack_bonus_on_attack"
const STATUS_DAMAGE_BONUS_TURN := "damage_bonus_turn"
const STATUS_BLOCK_DISABLED := "block_disabled"
const STATUS_NEXT_CARD_COST_DELTA := "next_card_cost_delta"
const STATUS_SKIP_ENEMY_TURN := "skip_enemy_turn"
const STATUS_ATTACK_CHAIN := "attack_chain"
const STATUS_DEFEND_CHAIN := "defend_chain"
const STATUS_FIRST_ATTACK_DRAW_USED := "first_attack_draw_used"
const STATUS_FIRST_DAMAGE_BLOCK_USED := "first_damage_block_used"
const STATUS_BLEED := "bleed"
const STATUS_POISON := "poison"
const STATUS_BURN := "burn"
const STATUS_ENEMY_ATTACK_BONUS := "enemy_attack_bonus"
const STATUS_ENEMY_BLOCK_GAIN_REDUCTION := "enemy_block_gain_reduction"

const EQUIP_ATTACK_BONUS := "equip_attack_bonus"
const EQUIP_DAMAGE_REDUCTION := "equip_damage_reduction"
const EQUIP_ATTACK_CHAIN_DRAW := "equip_attack_chain_draw"
const EQUIP_DEFEND_CHAIN_BLOCK := "equip_defend_chain_block"
const EQUIP_BLOCK_ON_DAMAGE := "equip_block_on_damage"
const EQUIP_BLEED_BONUS_PER_STACK := "equip_bleed_bonus_per_stack"

const POWER_FIRST_ATTACK_DRAW := "power_first_attack_draw"
const POWER_FIRST_DAMAGE_BLOCK := "power_first_damage_block"
const POWER_BLEED_ON_DAMAGE := "power_bleed_on_damage"

var name: String = ""
var hp: int = 0
var max_hp: int = 0
var block: int = 0
var energy: int = 0
var draw_pile: Array = []
var hand: Array = []
var discard_pile: Array = []
var statuses: Dictionary = {}
var equipment: Dictionary = {}
var powers: Dictionary = {}
var metadata: Dictionary = {}

func setup(actor_name: String, max_health: int, energy_max: int, deck: Array) -> void:
	name = actor_name
	max_hp = max_health
	hp = max_health
	energy = energy_max
	draw_pile = deck.duplicate(true)
	draw_pile.shuffle()
	hand.clear()
	discard_pile.clear()
	block = 0
	statuses.clear()
	equipment.clear()
	powers.clear()

func reset_turn_energy(energy_max: int) -> void:
	energy = energy_max

func get_status(key: String, default_value: Variant) -> Variant:
	return statuses.get(key, default_value)

func set_status(key: String, value: Variant) -> void:
	statuses[key] = value

func add_status(key: String, delta: Variant) -> void:
	var current: Variant = statuses.get(key, 0)
	if typeof(current) == TYPE_FLOAT or typeof(delta) == TYPE_FLOAT:
		statuses[key] = float(current) + float(delta)
	else:
		statuses[key] = int(current) + int(delta)

func clear_status(key: String) -> void:
	statuses.erase(key)

func draw_cards(count: int) -> void:
	for i in range(count):
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile.duplicate(true)
			discard_pile.clear()
			draw_pile.shuffle()
		hand.append(draw_pile.pop_back())

func discard_hand() -> void:
	discard_pile.append_array(hand)
	hand.clear()

func remove_card_from_hand(index: int) -> Variant:
	if index < 0 or index >= hand.size():
		return null
	return hand.pop_at(index)

func gain_block(amount: int, block_disabled: bool) -> bool:
	if amount <= 0:
		return false
	if block_disabled:
		return false
	block += amount
	return true

func take_damage(amount: int, pierce: bool) -> int:
	if amount <= 0:
		return 0
	var actual := amount
	if not pierce:
		var blocked: int = min(block, actual)
		block -= blocked
		actual -= blocked
	if actual > 0:
		hp = max(hp - actual, 0)
	return actual
