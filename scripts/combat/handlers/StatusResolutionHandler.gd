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
	if context.combat_state.weak_turns > 0:
		context.combat_state.weak_turns -= 1
	context.combat_state.bleed_on_attack = 0
	context.combat_state.attack_bonus_on_attack = 0
	context.combat_state.damage_bonus_turn = 0
	context.combat_state.attack_chain = 0
	context.combat_state.defend_chain = 0
	context.combat_state.next_card_cost_delta = 0

func _resolve_enemy_end() -> void:
	var total_dot: int = 0
	if context.combat_state.enemy_bleed > 0:
		var bleed_damage: int = int(context.combat_state.enemy_bleed) * (1 + int(context.combat_state.equip_bleed_bonus_per_stack))
		context.combat_state.enemy_actor.hp = max(context.combat_state.enemy_actor.hp - bleed_damage, 0)
		context.combat_state.combat_damage_dealt += bleed_damage
		total_dot += bleed_damage
		context.battle_log_panel.append_line("敌人流血造成%d点伤害（流血 %d，HP %d/%d）。" % [
			bleed_damage,
			context.combat_state.enemy_bleed,
			context.combat_state.enemy_actor.hp,
			context.combat_state.enemy_actor.max_hp
		])
	if context.combat_state.enemy_poison > 0:
		var poison_damage: int = int(context.combat_state.enemy_poison)
		context.combat_state.enemy_actor.hp = max(context.combat_state.enemy_actor.hp - poison_damage, 0)
		context.combat_state.combat_damage_dealt += poison_damage
		total_dot += poison_damage
		context.battle_log_panel.append_line("敌人中毒造成%d点伤害（中毒 %d，HP %d/%d）。" % [
			poison_damage,
			context.combat_state.enemy_poison,
			context.combat_state.enemy_actor.hp,
			context.combat_state.enemy_actor.max_hp
		])
		context.combat_state.enemy_poison = max(context.combat_state.enemy_poison - 1, 0)
	if context.combat_state.enemy_burn > 0:
		var burn_damage: int = int(context.combat_state.enemy_burn)
		context.combat_state.enemy_actor.hp = max(context.combat_state.enemy_actor.hp - burn_damage, 0)
		context.combat_state.combat_damage_dealt += burn_damage
		total_dot += burn_damage
		context.battle_log_panel.append_line("敌人灼烧造成%d点伤害（灼烧 %d，HP %d/%d）。" % [
			burn_damage,
			context.combat_state.enemy_burn,
			context.combat_state.enemy_actor.hp,
			context.combat_state.enemy_actor.max_hp
		])
	if total_dot > 0:
		context.ui_controller.play_enemy_hit_effect()
	if context.combat_state.vulnerable_turns > 0:
		context.combat_state.vulnerable_turns -= 1
	context.combat_state.counter_ratio = 0.0
	context.combat_state.nullify_count = 0
	context.combat_state.damage_draw = 0
	context.combat_state.block_disabled = false
	context.combat_state.enemy_block_gain_reduction = 0
	context.combat_state.power_first_attack_draw_used = false
	context.combat_state.power_first_damage_block_used = false
	context.combat_state.skip_enemy_turn = false
