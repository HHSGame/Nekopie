class_name CombatFlowController
extends RefCounted

var context: Node
var combat_state: CombatState
var event_bus: CombatEventBus

func setup(context_ref: Node) -> void:
	context = context_ref
	combat_state = context_ref.combat_state
	event_bus = context_ref.event_bus

func sync_player_hp() -> void:
	RunState.player_hp = combat_state.player_actor.hp

func log_turn_start() -> void:
	append_log("回合%d开始：你HP %d/%d，敌人HP %d/%d" % [
		combat_state.turn_index,
		combat_state.player_actor.hp,
		combat_state.player_actor.max_hp,
		combat_state.enemy_actor.hp,
		combat_state.enemy_actor.max_hp
	])

func log_turn_end() -> void:
	var status_text := _get_ui_controller().player_status_text()
	append_log("回合%d结算：你HP %d/%d 护甲%d（%s），敌人HP %d/%d 护甲%d" % [
		combat_state.turn_index,
		combat_state.player_actor.hp,
		combat_state.player_actor.max_hp,
		combat_state.player_actor.block,
		status_text,
		combat_state.enemy_actor.hp,
		combat_state.enemy_actor.max_hp,
		combat_state.enemy_actor.block
	])

func start_encounter() -> void:
	var encounter_index: int = RunState.encounters_completed + 1
	emit_phase(BattlePhases.PRE_BATTLE, {"encounter": encounter_index})
	combat_state.combat_over = false
	combat_state.run_complete = false
	combat_state.reward_mode = "none"
	combat_state.last_reward_mode = ""
	combat_state.reward_cards.clear()
	combat_state.route_mode = "none"
	combat_state.supply_available = false
	context.card_detail_panel.visible = false
	combat_state.enemy_acting = false
	combat_state.turn_locked = false
	combat_state.discard_required = 0
	combat_state.discard_selection.clear()
	combat_state.discard_card_widgets.clear()
	combat_state.discard_locked_indices.clear()
	_get_reward_controller().set_discard_overlay_visible(false)
	combat_state.combat_damage_dealt = 0
	combat_state.combat_damage_taken = 0
	combat_state.combat_attack_count = 0
	combat_state.player_actor.setup("旅人", combat_state.player_actor.max_hp, RunState.energy_max, RunState.deck)
	combat_state.player_actor.hp = RunState.player_hp
	emit_phase_end(BattlePhases.PRE_BATTLE, {"encounter": encounter_index})
	combat_state.enemy_data = RunState.start_encounter()
	combat_state.combat_difficulty = RunState.next_difficulty
	var enemy_max: int = int(combat_state.enemy_data.get("hp", 0))
	var enemy_name: String = str(combat_state.enemy_data.get("name", "魔物"))
	combat_state.enemy_actor.setup(enemy_name, enemy_max, RunState.energy_max, Array(combat_state.enemy_data.get("deck", [])))
	emit_phase(BattlePhases.BATTLE_START, {"enemy": enemy_name, "difficulty": combat_state.combat_difficulty})
	combat_state.enemy_attack_bonus = 0
	combat_state.weak_turns = 0
	combat_state.vulnerable_turns = 0
	combat_state.next_attack_mult = 1.0
	combat_state.next_attack_bonus = 0
	combat_state.next_attack_pierce = false
	combat_state.counter_ratio = 0.0
	combat_state.nullify_count = 0
	combat_state.damage_draw = 0
	combat_state.bleed_on_attack = 0
	combat_state.attack_bonus_on_attack = 0
	combat_state.damage_bonus_turn = 0
	combat_state.block_disabled = false
	combat_state.next_card_cost_delta = 0
	combat_state.skip_enemy_turn = false
	combat_state.attack_chain = 0
	combat_state.defend_chain = 0
	combat_state.equip_attack_bonus = 0
	combat_state.equip_damage_reduction = 0
	combat_state.equip_attack_chain_draw = 0
	combat_state.equip_defend_chain_block = 0
	combat_state.equip_block_on_damage = 0
	combat_state.equip_bleed_bonus_per_stack = 0
	combat_state.power_first_attack_draw = 0
	combat_state.power_first_damage_block = 0
	combat_state.power_bleed_on_damage = 0
	combat_state.power_first_attack_draw_used = false
	combat_state.power_first_damage_block_used = false
	combat_state.enemy_bleed = 0
	combat_state.enemy_poison = 0
	combat_state.enemy_burn = 0
	combat_state.enemy_block_gain_reduction = 0
	apply_difficulty_to_enemy(RunState.next_difficulty)
	RunState.next_difficulty = "normal"
	emit_phase_end(BattlePhases.BATTLE_START, {"enemy": enemy_name, "difficulty": combat_state.combat_difficulty})
	emit_phase(BattlePhases.DECK_PREP, {"enemy_deck": combat_state.enemy_actor.draw_pile.size()})
	draw_enemy_cards(context.ENEMY_HAND_SIZE)
	refresh_enemy_intent()
	emit_phase_end(BattlePhases.DECK_PREP, {"enemy_hand": combat_state.enemy_actor.hand.size()})
	combat_state.next_step = "encounter"
	_get_ui_controller().setup_portraits(combat_state.enemy_data)
	RunState.log_event("遭遇魔物：%s" % combat_state.enemy_data.get("name", "未知魔物"))
	_get_ui_controller().reset_battle_log()
	combat_state.turn_index = 1
	append_log("遭遇魔物：%s（HP %d/%d）" % [
		combat_state.enemy_data.get("name", "未知魔物"),
		combat_state.enemy_actor.hp,
		combat_state.enemy_actor.max_hp
	])
	log_turn_start()
	if RunState.next_encounter_first_strike:
		var strike_damage := GameData.FIRST_STRIKE_DAMAGE + RunState.next_encounter_first_strike_bonus
		combat_state.enemy_actor.hp = max(combat_state.enemy_actor.hp - strike_damage, 0)
		RunState.next_encounter_first_strike = false
		RunState.next_encounter_first_strike_bonus = 0
		append_log("先手出击：造成%d点伤害（敌人HP %d/%d）。" % [
			strike_damage,
			combat_state.enemy_actor.hp,
			combat_state.enemy_actor.max_hp
		])
		RunState.log_event("先手出击造成%d点伤害。" % strike_damage)
	else:
		append_log("你稳住气息，准备战斗。")
	emit_phase(BattlePhases.DRAW_CARDS, {"count": context.HAND_DRAW_FIRST})
	draw_cards(context.HAND_DRAW_FIRST)
	emit_phase_end(BattlePhases.DRAW_CARDS, {"hand": combat_state.player_actor.hand.size()})
	emit_phase(BattlePhases.STATUS_RESOLVE, {"stage": "player_start", "turn": combat_state.turn_index})
	emit_phase_end(BattlePhases.STATUS_RESOLVE, {"stage": "player_start", "turn": combat_state.turn_index})
	_get_ui_controller().update_ui()
	RunState.save_run()

func draw_cards(count: int) -> void:
	for i in range(count):
		if combat_state.player_actor.draw_pile.is_empty():
			if combat_state.player_actor.discard_pile.is_empty():
				break
			combat_state.player_actor.draw_pile = combat_state.player_actor.discard_pile.duplicate(true)
			combat_state.player_actor.discard_pile.clear()
			combat_state.player_actor.draw_pile.shuffle()
		combat_state.player_actor.hand.append(combat_state.player_actor.draw_pile.pop_back())

func draw_enemy_cards(count: int) -> void:
	for i in range(count):
		if combat_state.enemy_actor.draw_pile.is_empty():
			if combat_state.enemy_actor.discard_pile.is_empty():
				break
			combat_state.enemy_actor.draw_pile = combat_state.enemy_actor.discard_pile.duplicate(true)
			combat_state.enemy_actor.discard_pile.clear()
			combat_state.enemy_actor.draw_pile.shuffle()
		combat_state.enemy_actor.hand.append(combat_state.enemy_actor.draw_pile.pop_back())

func on_hand_card_clicked(card_id: String, index: int) -> void:
	if combat_state.combat_over or combat_state.enemy_acting or combat_state.turn_locked or combat_state.discard_overlay_active:
		return
	if index < 0 or index >= combat_state.player_actor.hand.size():
		return
	var card_entry = combat_state.player_actor.hand[index]
	var card_instance_id := RunState.get_card_id(card_entry)
	var card_data := GameData.get_card_data(card_instance_id, RunState.get_card_upgrade_level(card_entry))
	var card_name: String = str(card_data.get("name", "卡牌"))
	if bool(card_data.get("unplayable", false)):
		append_log("【%s】无法打出。" % card_name)
		return
	var cost := int(card_data.get("cost", 0))
	if combat_state.next_card_cost_delta != 0:
		cost = max(cost + combat_state.next_card_cost_delta, 0)
	if cost > combat_state.player_actor.energy:
		append_log("能量不足，无法打出【%s】。" % card_name)
		return
	emit_phase(BattlePhases.USE_CARD, {"card": card_name, "cost": cost})
	combat_state.player_actor.energy -= cost
	combat_state.next_card_cost_delta = 0
	emit_phase(BattlePhases.CARD_EFFECT, {"card": card_name, "card_data": card_data, "source": "player"})
	emit_phase_end(BattlePhases.CARD_EFFECT, {"card": card_name})
	var removed = remove_card_from_hand(index)
	if removed != null:
		if bool(card_data.get("exhaust", false)):
			append_log("【%s】已消耗。" % card_name)
		else:
			combat_state.player_actor.discard_pile.append(removed)
	emit_phase(BattlePhases.TARGET_REACTION, {"card": card_name, "source": "player"})
	emit_phase_end(BattlePhases.TARGET_REACTION, {"card": card_name})
	emit_phase(BattlePhases.FINAL_RESOLVE, {"card": card_name})
	_get_ui_controller().update_ui()
	RunState.save_run()
	emit_phase_end(BattlePhases.FINAL_RESOLVE, {"card": card_name})
	emit_phase_end(BattlePhases.USE_CARD, {"card": card_name})
	emit_phase(BattlePhases.NEXT_CARD, {"hand": combat_state.player_actor.hand.size()})
	emit_phase_end(BattlePhases.NEXT_CARD, {"hand": combat_state.player_actor.hand.size()})

func remove_card_from_hand(index: int) -> Variant:
	if index >= 0 and index < combat_state.player_actor.hand.size():
		var removed = combat_state.player_actor.hand[index]
		combat_state.player_actor.hand.remove_at(index)
		return removed
	return null

func apply_player_damage(amount: int, pierce: bool) -> int:
	if amount <= 0:
		return 0
	var actual := amount
	if not pierce:
		var blocked: int = min(combat_state.enemy_actor.block, actual)
		combat_state.enemy_actor.block -= blocked
		actual -= blocked
	if actual > 0:
		combat_state.enemy_actor.hp = max(combat_state.enemy_actor.hp - actual, 0)
		combat_state.combat_damage_dealt += actual
		context.sfx_attack.play()
		_get_ui_controller().play_enemy_hit_effect()
		if combat_state.equip_block_on_damage > 0:
			if gain_player_block(combat_state.equip_block_on_damage):
				append_log("血纹护符触发：护甲+%d（护甲 %d）。" % [combat_state.equip_block_on_damage, combat_state.player_actor.block])
				context.sfx_block.play()
		if combat_state.power_bleed_on_damage > 0:
			combat_state.enemy_bleed += combat_state.power_bleed_on_damage
			append_log("血炼触发：流血+%d（%d）。" % [combat_state.power_bleed_on_damage, combat_state.enemy_bleed])
	return actual

func gain_player_block(amount: int) -> bool:
	if amount <= 0:
		return false
	if combat_state.block_disabled:
		return false
	combat_state.player_actor.block += amount
	return true

func apply_ethereal_cleanup() -> void:
	for index in range(combat_state.player_actor.hand.size() - 1, -1, -1):
		var card_entry = combat_state.player_actor.hand[index]
		var card_id := RunState.get_card_id(card_entry)
		var card_data := GameData.get_card_data(card_id, RunState.get_card_upgrade_level(card_entry))
		if bool(card_data.get("ethereal", false)):
			combat_state.player_actor.hand.remove_at(index)
			append_log("【%s】虚无消散。" % card_data.get("name", "卡牌"))

func on_end_turn_pressed() -> void:
	if combat_state.combat_over or combat_state.enemy_acting or combat_state.discard_overlay_active or combat_state.turn_locked:
		return
	combat_state.turn_locked = true
	if not combat_state.end_turn_phase_pending:
		combat_state.end_turn_phase_pending = true
		emit_phase(BattlePhases.END_TURN_TRIGGER, {"turn": combat_state.turn_index})
	apply_ethereal_cleanup()
	if combat_state.player_actor.hand.size() > context.HAND_LIMIT:
		_get_reward_controller().open_discard_overlay(combat_state.player_actor.hand.size() - context.HAND_LIMIT)
		return
	emit_phase_end(BattlePhases.END_TURN_TRIGGER, {"turn": combat_state.turn_index, "discard_required": 0})
	combat_state.end_turn_phase_pending = false
	await resolve_end_turn()

func resolve_end_turn() -> void:
	var resolved_turn := combat_state.turn_index
	emit_phase(BattlePhases.END_TURN_RESOLVE, {"turn": resolved_turn})
	emit_phase(BattlePhases.STATUS_RESOLVE, {"stage": "player_end", "turn": resolved_turn})
	emit_phase_end(BattlePhases.STATUS_RESOLVE, {"stage": "player_end", "turn": resolved_turn})
	await enemy_turn()
	if combat_state.combat_over:
		emit_phase_end(BattlePhases.END_TURN_RESOLVE, {"turn": resolved_turn, "combat_over": true})
		combat_state.turn_locked = false
		_get_ui_controller().update_ui()
		return
	log_turn_end()
	combat_state.player_actor.energy = RunState.energy_max
	draw_cards(context.HAND_DRAW_PER_TURN)
	combat_state.turn_index += 1
	log_turn_start()
	combat_state.turn_locked = false
	emit_phase_end(BattlePhases.END_TURN_RESOLVE, {"turn": resolved_turn})
	_get_ui_controller().update_ui()
	RunState.save_run()

func enemy_turn() -> void:
	var enemy_turn := combat_state.turn_index
	emit_phase(BattlePhases.ENEMY_TURN_START, {"turn": enemy_turn})
	combat_state.enemy_acting = true
	combat_state.enemy_actor.energy = RunState.energy_max
	_get_ui_controller().update_ui()
	if combat_state.skip_enemy_turn:
		combat_state.skip_enemy_turn = false
		append_log("停滞结界生效：魔物本回合无法行动。")
		await wait(context.ENEMY_IDLE_DELAY)
	else:
		await play_enemy_hand()
	combat_state.enemy_acting = false
	if combat_state.player_actor.hp <= 0:
		combat_state.combat_over = true
		combat_state.run_complete = true
		append_log("你在山道上倒下，征途告终。")
		RunState.log_event("你在山道上倒下。")
		RunState.finalize_run_score()
		RunState.reset_after_run()
		emit_phase_end(BattlePhases.ENEMY_TURN_START, {"turn": enemy_turn, "combat_over": true})
		return
	if not combat_state.combat_over:
		emit_phase(BattlePhases.STATUS_RESOLVE, {"stage": "enemy_end", "turn": enemy_turn})
		emit_phase_end(BattlePhases.STATUS_RESOLVE, {"stage": "enemy_end", "turn": enemy_turn})
		if combat_state.enemy_actor.hp <= 0:
			check_enemy_defeat()
			emit_phase_end(BattlePhases.ENEMY_TURN_START, {"turn": enemy_turn, "combat_over": combat_state.combat_over})
			return
	if not combat_state.combat_over:
		combat_state.enemy_actor.discard_pile.append_array(combat_state.enemy_actor.hand)
		combat_state.enemy_actor.hand.clear()
		draw_enemy_cards(context.ENEMY_HAND_SIZE)
		refresh_enemy_intent()
	emit_phase_end(BattlePhases.ENEMY_TURN_START, {"turn": enemy_turn, "combat_over": combat_state.combat_over})

func check_enemy_defeat() -> void:
	if combat_state.enemy_actor.hp <= 0:
		emit_phase(BattlePhases.BATTLE_END_TRIGGER, {"turn": combat_state.turn_index})
		combat_state.combat_over = true
		log_turn_end()
		append_log("敌人倒下，战斗结束。")
		emit_phase_end(BattlePhases.BATTLE_END_TRIGGER, {"turn": combat_state.turn_index})
		emit_phase(BattlePhases.BATTLE_END_RESOLVE, {"turn": combat_state.turn_index})
		var combat_score := calculate_combat_score()
		RunState.add_combat_score(combat_score)
		combat_state.run_complete = RunState.complete_encounter()
		if combat_state.run_complete:
			append_log("你征服了 %s，登顶通关！" % GameData.MOUNTAIN_NAME)
			RunState.log_event("登顶通关，征服 %s。" % GameData.MOUNTAIN_NAME)
			RunState.finalize_run_score()
			RunState.reset_after_run()
			emit_phase_end(BattlePhases.BATTLE_END_RESOLVE, {"turn": combat_state.turn_index, "result": "complete"})
			emit_phase(BattlePhases.BATTLE_END, {"result": "complete"})
			emit_phase_end(BattlePhases.BATTLE_END, {"result": "complete"})
		else:
			RunState.log_event("击退了 %s。" % combat_state.enemy_data.get("name", "魔物"))
			emit_phase_end(BattlePhases.BATTLE_END_RESOLVE, {"turn": combat_state.turn_index, "result": "continue"})
			_get_reward_controller().queue_post_battle_step()

func refresh_enemy_intent() -> void:
	combat_state.enemy_intent_card = get_enemy_intent_card()

func get_enemy_intent_card() -> Dictionary:
	if combat_state.enemy_actor.hand.is_empty():
		return {}
	for card_id in combat_state.enemy_actor.hand:
		var card_data := GameData.get_enemy_card_data(str(card_id))
		if int(card_data.get("cost", 0)) <= RunState.energy_max:
			return card_data
	return GameData.get_enemy_card_data(str(combat_state.enemy_actor.hand[0]))

func enemy_card_display(card_data: Dictionary) -> String:
	if card_data.is_empty():
		return "行动未知"
	var custom_text: String = str(card_data.get("text", ""))
	if not custom_text.is_empty():
		return custom_text
	var intent_type: String = str(card_data.get("type", ""))
	var name: String = str(card_data.get("name", "行动"))
	var bonus: int = combat_state.enemy_attack_bonus
	match intent_type:
		"attack":
			var damage := int(round(int(card_data.get("damage", 0)) * combat_state.enemy_power_mult))
			damage += bonus
			return "%s %d" % [name, damage]
		"multi_attack":
			var damage := int(round(int(card_data.get("damage", 0)) * combat_state.enemy_power_mult))
			var hits := int(card_data.get("hits", 1))
			var suffix := " +%d" % bonus if bonus > 0 else ""
			return "%s %d x %d%s" % [name, damage, hits, suffix]
		"guard":
			var block := int(round(int(card_data.get("block", 0)) * combat_state.enemy_power_mult))
			return "%s +%d" % [name, block]
		"charge":
			var charge := int(round(int(card_data.get("charge", 0)) * combat_state.enemy_power_mult))
			return "%s +%d" % [name, charge]
		"drain":
			var damage := int(round(int(card_data.get("damage", 0)) * combat_state.enemy_power_mult))
			damage += bonus
			return "%s %d" % [name, damage]
		"heal":
			var heal := int(round(int(card_data.get("heal", 0)) * combat_state.enemy_power_mult))
			return "%s +%d" % [name, heal]
		"debuff", "attack_debuff":
			var summary := enemy_debuff_summary(card_data)
			return "%s %s" % [name, summary]
	return name

func enemy_card_targets_player(intent_type: String) -> bool:
	return intent_type in ["attack", "multi_attack", "drain", "debuff", "attack_debuff"]

func play_enemy_hand() -> void:
	var acted := false
	for card_id in combat_state.enemy_actor.hand:
		var card_data := GameData.get_enemy_card_data(str(card_id))
		var cost := int(card_data.get("cost", 0))
		if cost > combat_state.enemy_actor.energy:
			continue
		combat_state.enemy_actor.energy -= cost
		combat_state.enemy_intent_card = card_data
		_get_ui_controller().update_ui()
		await wait(context.ENEMY_WINDUP_DELAY)
		play_enemy_action_fx(card_data)
		apply_enemy_card(card_data)
		acted = true
		_get_ui_controller().update_ui()
		if combat_state.player_actor.hp <= 0 or combat_state.enemy_actor.hp <= 0:
			break
		await wait(context.ENEMY_ACTION_DELAY)
	if not acted:
		append_log("魔物谨慎观望。")
		await wait(context.ENEMY_IDLE_DELAY)

func wait(seconds: float) -> void:
	if seconds <= 0.0:
		return
	await context.get_tree().create_timer(seconds).timeout

func play_enemy_action_fx(card_data: Dictionary) -> void:
	var intent_type: String = str(card_data.get("type", ""))
	context.enemy_portrait_panel.pulse(1.04)
	match intent_type:
		"guard", "charge":
			context.sfx_block.play()

func apply_enemy_card(card_data: Dictionary) -> void:
	if card_data.is_empty():
		return
	var intent_type: String = str(card_data.get("type", ""))
	var card_name: String = str(card_data.get("name", "行动"))
	if enemy_card_targets_player(intent_type) and combat_state.nullify_count > 0:
		combat_state.nullify_count -= 1
		append_log("护幕抵消了魔物的【%s】。" % card_name)
		return
	var damage := int(round(int(card_data.get("damage", 0)) * combat_state.enemy_power_mult))
	var block := int(round(int(card_data.get("block", 0)) * combat_state.enemy_power_mult))
	var heal := int(round(int(card_data.get("heal", 0)) * combat_state.enemy_power_mult))
	var charge := int(round(int(card_data.get("charge", 0)) * combat_state.enemy_power_mult))
	var apply_weak := int(card_data.get("apply_weak", 0))
	var apply_vulnerable := int(card_data.get("apply_vulnerable", 0))
	match intent_type:
		"attack":
			var total_damage: int = damage + combat_state.enemy_attack_bonus
			combat_state.enemy_attack_bonus = 0
			var dealt := apply_enemy_damage(total_damage)
			if dealt > 0:
				append_log("魔物使用【%s】->你：造成%d点伤害（你HP %d/%d，护甲 %d）。" % [
					card_name, dealt,
					combat_state.player_actor.hp, combat_state.player_actor.max_hp,
					combat_state.player_actor.block
				])
			else:
				append_log("魔物使用【%s】->你：攻击被护甲挡住（你护甲 %d）。" % [card_name, combat_state.player_actor.block])
		"multi_attack":
			var hits: int = int(card_data.get("hits", 1))
			var total_multi: int = (damage * hits) + combat_state.enemy_attack_bonus
			combat_state.enemy_attack_bonus = 0
			var dealt := apply_enemy_damage(total_multi)
			if dealt > 0:
				append_log("魔物使用【%s】->你：连击%d次造成%d点伤害（你HP %d/%d，护甲 %d）。" % [
					card_name, hits, dealt,
					combat_state.player_actor.hp, combat_state.player_actor.max_hp,
					combat_state.player_actor.block
				])
			else:
				append_log("魔物使用【%s】->你：连击被护甲挡住（你护甲 %d）。" % [card_name, combat_state.player_actor.block])
		"guard":
			var gain: int = int(max(block - combat_state.enemy_block_gain_reduction, 0))
			combat_state.enemy_actor.block += gain
			append_log("魔物使用【%s】->自己：护甲+%d（护甲 %d）。" % [card_name, gain, combat_state.enemy_actor.block])
		"charge":
			combat_state.enemy_attack_bonus += charge
			append_log("魔物使用【%s】->自己：蓄力+%d（下次攻击加成 %d）。" % [card_name, charge, combat_state.enemy_attack_bonus])
		"drain":
			var drain_damage: int = damage + combat_state.enemy_attack_bonus
			combat_state.enemy_attack_bonus = 0
			var dealt: int = apply_enemy_damage(drain_damage)
			if dealt > 0 and heal > 0:
				combat_state.enemy_actor.hp = min(combat_state.enemy_actor.hp + heal, combat_state.enemy_actor.max_hp)
				append_log("魔物使用【%s】->你：造成%d点伤害（你HP %d/%d）。自身恢复%d点生命（敌人HP %d/%d）。" % [
					card_name, dealt,
					combat_state.player_actor.hp, combat_state.player_actor.max_hp,
					heal, combat_state.enemy_actor.hp, combat_state.enemy_actor.max_hp
				])
			elif dealt > 0:
				append_log("魔物使用【%s】->你：造成%d点伤害（你HP %d/%d）。" % [
					card_name, dealt,
					combat_state.player_actor.hp, combat_state.player_actor.max_hp
				])
			else:
				append_log("魔物使用【%s】->你：攻击被护甲挡住（你护甲 %d）。" % [card_name, combat_state.player_actor.block])
		"heal":
			if heal > 0:
				combat_state.enemy_actor.hp = min(combat_state.enemy_actor.hp + heal, combat_state.enemy_actor.max_hp)
				append_log("魔物使用【%s】->自己：恢复%d点生命（敌人HP %d/%d）。" % [
					card_name, heal, combat_state.enemy_actor.hp, combat_state.enemy_actor.max_hp
				])
		"debuff":
			apply_enemy_debuffs(apply_weak, apply_vulnerable)
			append_log("魔物使用【%s】->你：施加%s（你状态：%s）。" % [
				card_name, enemy_debuff_summary(card_data),
				_get_ui_controller().player_status_text()
			])
		"attack_debuff":
			var debuff_damage: int = damage + combat_state.enemy_attack_bonus
			combat_state.enemy_attack_bonus = 0
			var dealt := apply_enemy_damage(debuff_damage)
			apply_enemy_debuffs(apply_weak, apply_vulnerable)
			var status_summary := enemy_debuff_summary(card_data)
			if dealt > 0:
				append_log("魔物使用【%s】->你：造成%d点伤害（你HP %d/%d），施加%s（你状态：%s）。" % [
					card_name, dealt,
					combat_state.player_actor.hp, combat_state.player_actor.max_hp,
					status_summary, _get_ui_controller().player_status_text()
				])
			else:
				append_log("魔物使用【%s】->你：攻击被护甲挡住，施加%s（你状态：%s）。" % [
					card_name, status_summary, _get_ui_controller().player_status_text()
				])
		_:
			append_log("魔物踌躇不前。")

func apply_enemy_damage(amount: int) -> int:
	if amount <= 0:
		return 0
	context.sfx_attack.play()
	var adjusted_amount := amount
	if combat_state.vulnerable_turns > 0:
		adjusted_amount = int(round(amount * context.VULNERABLE_DAMAGE_MULT))
	var blocked: int = int(min(adjusted_amount, combat_state.player_actor.block))
	var damage: int = adjusted_amount - blocked
	combat_state.player_actor.block = max(combat_state.player_actor.block - adjusted_amount, 0)
	if combat_state.equip_damage_reduction > 0:
		damage = max(damage - combat_state.equip_damage_reduction, 0)
	if damage > 0:
		combat_state.player_actor.hp = max(combat_state.player_actor.hp - damage, 0)
		sync_player_hp()
		combat_state.combat_damage_taken += damage
		_get_ui_controller().play_player_hit_effect()
		if combat_state.power_first_damage_block > 0 and not combat_state.power_first_damage_block_used:
			combat_state.power_first_damage_block_used = true
			if gain_player_block(combat_state.power_first_damage_block):
				append_log("坚毅之魂触发：护甲+%d（护甲 %d）。" % [combat_state.power_first_damage_block, combat_state.player_actor.block])
				context.sfx_block.play()
		if combat_state.counter_ratio > 0.0:
			var counter_damage := int(round(float(damage) * combat_state.counter_ratio))
			if counter_damage > 0:
				var dealt := apply_player_damage(counter_damage, false)
				if dealt > 0:
					append_log("反击造成%d点伤害（敌人HP %d/%d）。" % [dealt, combat_state.enemy_actor.hp, combat_state.enemy_actor.max_hp])
		if combat_state.damage_draw > 0:
			draw_cards(combat_state.damage_draw)
			append_log("补给回响：抽%d张（手牌 %d）。" % [combat_state.damage_draw, combat_state.player_actor.hand.size()])
	return damage

func apply_enemy_debuffs(weak_turns: int, vulnerable_turns: int) -> void:
	if weak_turns > 0:
		combat_state.weak_turns += weak_turns
	if vulnerable_turns > 0:
		combat_state.vulnerable_turns += vulnerable_turns

func enemy_debuff_summary(card_data: Dictionary) -> String:
	var parts: Array = []
	var weak_turns := int(card_data.get("apply_weak", 0))
	var vulnerable_turns := int(card_data.get("apply_vulnerable", 0))
	if weak_turns > 0:
		parts.append("弱化%d" % weak_turns)
	if vulnerable_turns > 0:
		parts.append("易伤%d" % vulnerable_turns)
	if parts.is_empty():
		return "异常"
	return "，".join(parts)

func calculate_combat_score() -> int:
	var base_score := int(combat_state.enemy_data.get("score", 0))
	var settings := RunState.get_difficulty_settings(combat_state.combat_difficulty)
	var difficulty_mult := float(settings.get("score_mult", 1.0))
	var damage_taken_cap := combat_state.player_actor.max_hp * 3
	var damage_taken_score: float = float(min(combat_state.combat_damage_taken, damage_taken_cap)) * 0.3
	var score: float = float(base_score) * difficulty_mult
	score += combat_state.combat_damage_dealt * 0.6
	score += damage_taken_score
	score += combat_state.combat_attack_count * 2
	score += combat_state.player_actor.hp * 2
	return int(round(score))

func apply_difficulty_to_enemy(difficulty: String) -> void:
	var settings := RunState.get_difficulty_settings(difficulty)
	var hp_mult := float(settings.get("hp_mult", 1.0))
	var power_mult := float(settings.get("power_mult", 1.0))
	combat_state.enemy_power_mult = power_mult
	if hp_mult != 1.0:
		combat_state.enemy_actor.hp = int(round(combat_state.enemy_actor.hp * hp_mult))
		combat_state.enemy_actor.max_hp = combat_state.enemy_actor.hp
		combat_state.enemy_data["hp"] = combat_state.enemy_actor.hp

# ── Internal helpers ──

func _get_ui_controller() -> CombatUIController:
	return context.ui_controller

func _get_reward_controller() -> RewardFlowController:
	return context.reward_flow

func append_log(msg: String) -> void:
	context.battle_log_panel.append_line(msg)

func emit_phase(phase: String, payload: Dictionary = {}) -> void:
	event_bus.start_phase(phase, payload)

func emit_phase_end(phase: String, payload: Dictionary = {}) -> void:
	event_bus.end_phase(phase, payload)