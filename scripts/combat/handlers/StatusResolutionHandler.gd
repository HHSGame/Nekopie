extends Node

var bus: CombatEventBus
var context: Node

func setup(bus_ref: CombatEventBus, context_ref: Node) -> void:
	bus = bus_ref
	context = context_ref
	if bus:
		bus.phase_started.connect(_on_phase_started)

func _on_phase_started(phase: String, payload: Dictionary) -> void:
	if phase != BattlePhases.STATUS_RESOLVE:
		return
	if not context:
		return
	var stage := str(payload.get("stage", ""))
	match stage:
		"player_end":
			_resolve_player_end()
		"enemy_end":
			_resolve_enemy_end()
		_:
			return

func _resolve_player_end() -> void:
	if context.player_weak_turns > 0:
		context.player_weak_turns -= 1
	context.player_bleed_on_attack = 0
	context.player_attack_bonus_on_attack = 0
	context.player_damage_bonus_turn = 0
	context.player_attack_chain = 0
	context.player_defend_chain = 0
	context.player_next_card_cost_delta = 0

func _resolve_enemy_end() -> void:
	var total_dot := 0
	if context.enemy_bleed > 0:
		var bleed_damage := context.enemy_bleed * (1 + context.equip_bleed_bonus_per_stack)
		context.enemy_actor.hp = max(context.enemy_actor.hp - bleed_damage, 0)
		context.combat_damage_dealt += bleed_damage
		total_dot += bleed_damage
		context._append_battle_log("敌人流血造成%d点伤害（流血 %d，HP %d/%d）。" % [
			bleed_damage,
			context.enemy_bleed,
			context.enemy_actor.hp,
			context.enemy_actor.max_hp
		])
	if context.enemy_poison > 0:
		var poison_damage := context.enemy_poison
		context.enemy_actor.hp = max(context.enemy_actor.hp - poison_damage, 0)
		context.combat_damage_dealt += poison_damage
		total_dot += poison_damage
		context._append_battle_log("敌人中毒造成%d点伤害（中毒 %d，HP %d/%d）。" % [
			poison_damage,
			context.enemy_poison,
			context.enemy_actor.hp,
			context.enemy_actor.max_hp
		])
		context.enemy_poison = max(context.enemy_poison - 1, 0)
	if context.enemy_burn > 0:
		var burn_damage := context.enemy_burn
		context.enemy_actor.hp = max(context.enemy_actor.hp - burn_damage, 0)
		context.combat_damage_dealt += burn_damage
		total_dot += burn_damage
		context._append_battle_log("敌人灼烧造成%d点伤害（灼烧 %d，HP %d/%d）。" % [
			burn_damage,
			context.enemy_burn,
			context.enemy_actor.hp,
			context.enemy_actor.max_hp
		])
	if total_dot > 0:
		context._play_enemy_hit_effect()
	if context.player_vulnerable_turns > 0:
		context.player_vulnerable_turns -= 1
	context.player_counter_ratio = 0.0
	context.player_nullify_count = 0
	context.player_damage_draw = 0
	context.player_block_disabled = false
	context.enemy_block_gain_reduction = 0
	context.power_first_attack_draw_used = false
	context.power_first_damage_block_used = false
	context.player_skip_enemy_turn = false
