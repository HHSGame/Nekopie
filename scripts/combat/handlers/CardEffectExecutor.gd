extends Node

var context: Node

func setup(context_ref: Node) -> void:
	context = context_ref

func execute(card_data: Dictionary, payload: Dictionary) -> void:
	if not context:
		return
	if card_data.is_empty():
		return
	_apply_card_effect(card_data)

func _apply_card_effect(card_data: Dictionary) -> void:
	var card_name: String = str(card_data.get("name", "卡牌"))
	var is_attack := _is_attack_card(card_data)
	var is_defend := _is_defend_card(card_data)
	var attack_chain_before := context.combat_state.player_attack_chain
	if is_attack:
		context.combat_state.player_attack_chain += 1
		context.combat_state.player_defend_chain = 0
	elif is_defend:
		context.combat_state.player_defend_chain += 1
		context.combat_state.player_attack_chain = 0
	else:
		context.combat_state.player_attack_chain = 0
		context.combat_state.player_defend_chain = 0
	var damage := _calculate_attack_damage(card_data, attack_chain_before)
	var pierce := _should_pierce(card_data)
	if is_attack:
		context.combat_state.combat_attack_count += 1
	if damage > 0:
		var dealt := context._apply_player_damage(damage, pierce)
		if dealt > 0:
			var prefix := "穿刺" if pierce else ""
			context._append_battle_log("你使用【%s】->敌人：%s造成%d点伤害（敌人HP %d/%d，护甲 %d）。" % [
				card_name,
				prefix,
				dealt,
				context.combat_state.enemy_actor.hp,
				context.combat_state.enemy_actor.max_hp,
				context.combat_state.enemy_actor.block
			])
		else:
			context._append_battle_log("你使用【%s】->敌人：攻击被护甲挡住（敌人护甲 %d）。" % [card_name, context.combat_state.enemy_actor.block])
		if dealt > 0:
			var lifesteal_ratio := float(card_data.get("lifesteal_ratio", 0.0))
			if lifesteal_ratio > 0.0:
				var heal_amount := int(round(dealt * lifesteal_ratio))
				heal_amount = min(heal_amount, context.combat_state.player_actor.max_hp - context.combat_state.player_actor.hp)
				if heal_amount > 0:
					context.combat_state.player_actor.hp += heal_amount
					context._sync_player_hp()
					context._append_battle_log("【%s】吸血恢复%d点生命（HP %d/%d）。" % [
						card_name,
						heal_amount,
						context.combat_state.player_actor.hp,
						context.combat_state.player_actor.max_hp
					])
	if is_attack and context.combat_state.player_bleed_on_attack > 0:
		context.combat_state.enemy_bleed += context.combat_state.player_bleed_on_attack
		context._append_battle_log("血痕持续扩散，敌人流血+%d（%d）。" % [context.combat_state.player_bleed_on_attack, context.combat_state.enemy_bleed])
	if is_attack and context.combat_state.player_attack_bonus_on_attack > 0:
		context.combat_state.player_damage_bonus_turn += context.combat_state.player_attack_bonus_on_attack
		context._append_battle_log("嗜战叠加，攻击伤害+%d（本回合 +%d）。" % [context.combat_state.player_attack_bonus_on_attack, context.combat_state.player_damage_bonus_turn])
	if is_attack and context.combat_state.power_first_attack_draw > 0 and not context.combat_state.power_first_attack_draw_used:
		context.combat_state.power_first_attack_draw_used = true
		context._draw_cards(context.combat_state.power_first_attack_draw)
		context._append_battle_log("迅捷心法触发：抽%d张（手牌 %d）。" % [context.combat_state.power_first_attack_draw, context.combat_state.player_actor.hand.size()])
	if is_attack and context.combat_state.equip_attack_chain_draw > 0 and context.combat_state.player_attack_chain >= 2:
		context._draw_cards(context.combat_state.equip_attack_chain_draw)
		context._append_battle_log("连击腕轮触发：抽%d张（手牌 %d）。" % [context.combat_state.equip_attack_chain_draw, context.combat_state.player_actor.hand.size()])
		context.combat_state.player_attack_chain = 0
	if is_defend and context.combat_state.equip_defend_chain_block > 0 and context.combat_state.player_defend_chain >= 2:
		context._gain_player_block(context.combat_state.equip_defend_chain_block)
		context._append_battle_log("守势腰带触发：护甲+%d（护甲 %d）。" % [context.combat_state.equip_defend_chain_block, context.combat_state.player_actor.block])
		context.sfx_block.play()
		context.combat_state.player_defend_chain = 0
	var block := int(card_data.get("block", 0))
	if block > 0:
		if context._gain_player_block(block):
			context._append_battle_log("你使用【%s】->自己：护甲+%d（护甲 %d）。" % [card_name, block, context.combat_state.player_actor.block])
			context.sfx_block.play()
		else:
			context._append_battle_log("你使用【%s】->自己：护甲被封锁，无法获得护甲。" % card_name)
	var draw_count := int(card_data.get("draw", 0))
	if draw_count > 0:
		context._draw_cards(draw_count)
		context._append_battle_log("你使用【%s】->自己：抽%d张（手牌 %d，抽牌堆 %d）。" % [
			card_name,
			draw_count,
			context.combat_state.player_actor.hand.size(),
			context.combat_state.player_actor.draw_pile.size()
		])
	var heal := int(card_data.get("heal", 0))
	if heal > 0:
		var before: int = context.combat_state.player_actor.hp
		context.combat_state.player_actor.hp = min(context.combat_state.player_actor.hp + heal, context.combat_state.player_actor.max_hp)
		var healed: int = context.combat_state.player_actor.hp - before
		context._sync_player_hp()
		context._append_battle_log("你使用【%s】->自己：恢复%d点生命（HP %d/%d）。" % [
			card_name,
			healed,
			context.combat_state.player_actor.hp,
			context.combat_state.player_actor.max_hp
		])
	var apply_bleed := int(card_data.get("apply_bleed", 0))
	if apply_bleed > 0:
		context.combat_state.enemy_bleed += apply_bleed
		context._append_battle_log("你使用【%s】->敌人：流血+%d（%d）。" % [card_name, apply_bleed, context.combat_state.enemy_bleed])
	var apply_poison := int(card_data.get("apply_poison", 0))
	if apply_poison > 0:
		context.combat_state.enemy_poison += apply_poison
		context._append_battle_log("你使用【%s】->敌人：中毒+%d（%d）。" % [card_name, apply_poison, context.combat_state.enemy_poison])
	var apply_burn := int(card_data.get("apply_burn", 0))
	if apply_burn > 0:
		context.combat_state.enemy_burn += apply_burn
		context._append_battle_log("你使用【%s】->敌人：灼烧+%d（%d）。" % [card_name, apply_burn, context.combat_state.enemy_burn])
	var charge_mult := float(card_data.get("charge_mult", 0.0))
	if charge_mult > 0.0:
		context.combat_state.player_next_attack_mult = max(context.combat_state.player_next_attack_mult, charge_mult)
		context._append_battle_log("你使用【%s】->自己：蓄力x%.1f。" % [card_name, context.combat_state.player_next_attack_mult])
	if bool(card_data.get("skip_enemy_turn", false)):
		context.combat_state.player_skip_enemy_turn = true
		context._append_battle_log("你使用【%s】->敌人：进入停滞，本回合无法行动。" % card_name)
	var counter_ratio := float(card_data.get("counter_ratio", 0.0))
	if counter_ratio > 0.0:
		context.combat_state.player_counter_ratio = max(context.combat_state.player_counter_ratio, counter_ratio)
		context._append_battle_log("你使用【%s】->自己：反击比例提升至%.0f%%。" % [card_name, context.combat_state.player_counter_ratio * 100.0])
	var nullify_count := int(card_data.get("nullify_count", 0))
	if nullify_count > 0:
		context.combat_state.player_nullify_count += nullify_count
		context._append_battle_log("你使用【%s】->自己：护幕生效（%d次）。" % [card_name, context.combat_state.player_nullify_count])
	var damage_draw := int(card_data.get("damage_draw", 0))
	if damage_draw > 0:
		context.combat_state.player_damage_draw += damage_draw
		context._append_battle_log("你使用【%s】->自己：受伤抽牌+%d（本回合 %d）。" % [card_name, damage_draw, context.combat_state.player_damage_draw])
	var bleed_on_attack := int(card_data.get("bleed_on_attack", 0))
	if bleed_on_attack > 0:
		context.combat_state.player_bleed_on_attack += bleed_on_attack
		context._append_battle_log("你使用【%s】->自己：每次攻击流血+%d（本回合 %d）。" % [card_name, bleed_on_attack, context.combat_state.player_bleed_on_attack])
	var attack_bonus_on_attack := int(card_data.get("attack_bonus_on_attack", 0))
	if attack_bonus_on_attack > 0:
		context.combat_state.player_attack_bonus_on_attack += attack_bonus_on_attack
		context._append_battle_log("你使用【%s】->自己：每次攻击伤害+%d（本回合 %d）。" % [card_name, attack_bonus_on_attack, context.combat_state.player_attack_bonus_on_attack])
	var next_bonus := int(card_data.get("next_attack_bonus", 0))
	if next_bonus > 0:
		context.combat_state.player_next_attack_bonus += next_bonus
	if bool(card_data.get("next_attack_pierce", false)):
		context.combat_state.player_next_attack_pierce = true
	if next_bonus > 0 or context.combat_state.player_next_attack_pierce:
		context._append_battle_log("你使用【%s】->自己：强化下一次攻击。" % card_name)
	var enemy_block_reduce := int(card_data.get("enemy_block_gain_reduction", 0))
	if enemy_block_reduce > 0:
		context.combat_state.enemy_block_gain_reduction = max(context.combat_state.enemy_block_gain_reduction, enemy_block_reduce)
		context._append_battle_log("你使用【%s】->敌人：本回合护甲获得-%d。" % [card_name, context.combat_state.enemy_block_gain_reduction])
	var cost_delta := int(card_data.get("next_card_cost_delta", 0))
	if cost_delta != 0:
		context.combat_state.player_next_card_cost_delta += cost_delta
		context._append_battle_log("你使用【%s】->自己：下一张牌费用%+d。" % [card_name, cost_delta])
	if bool(card_data.get("block_disabled", false)):
		context.combat_state.player_block_disabled = true
		context._append_battle_log("你使用【%s】->自己：本回合无法获得护甲。" % card_name)
	var equip_attack := int(card_data.get("equip_attack_bonus", 0))
	if equip_attack > 0:
		context.combat_state.equip_attack_bonus += equip_attack
		context._append_battle_log("你装备【%s】：攻击伤害+%d（本场战斗 %d）。" % [card_name, equip_attack, context.combat_state.equip_attack_bonus])
	var equip_reduce := int(card_data.get("equip_damage_reduction", 0))
	if equip_reduce > 0:
		context.combat_state.equip_damage_reduction += equip_reduce
		context._append_battle_log("你装备【%s】：受到伤害-%d（本场战斗 %d）。" % [card_name, equip_reduce, context.combat_state.equip_damage_reduction])
	var equip_attack_draw := int(card_data.get("equip_attack_chain_draw", 0))
	if equip_attack_draw > 0:
		context.combat_state.equip_attack_chain_draw += equip_attack_draw
		context._append_battle_log("你装备【%s】：连击抽牌+%d。" % [card_name, equip_attack_draw])
	var equip_defend_block := int(card_data.get("equip_defend_chain_block", 0))
	if equip_defend_block > 0:
		context.combat_state.equip_defend_chain_block += equip_defend_block
		context._append_battle_log("你装备【%s】：守势护甲+%d。" % [card_name, equip_defend_block])
	var equip_block_on_hit := int(card_data.get("equip_block_on_damage", 0))
	if equip_block_on_hit > 0:
		context.combat_state.equip_block_on_damage += equip_block_on_hit
		context._append_battle_log("你装备【%s】：造成伤害时护甲+%d。" % [card_name, equip_block_on_hit])
	var equip_bleed_bonus := int(card_data.get("equip_bleed_bonus_per_stack", 0))
	if equip_bleed_bonus > 0:
		context.combat_state.equip_bleed_bonus_per_stack += equip_bleed_bonus
		context._append_battle_log("你装备【%s】：流血伤害提升。" % card_name)
	var power_attack_draw := int(card_data.get("power_first_attack_draw", 0))
	if power_attack_draw > 0:
		context.combat_state.power_first_attack_draw += power_attack_draw
		context._append_battle_log("你领悟【%s】：每回合首攻抽%d张。" % [card_name, power_attack_draw])
	var power_damage_block := int(card_data.get("power_first_damage_block", 0))
	if power_damage_block > 0:
		context.combat_state.power_first_damage_block += power_damage_block
		context._append_battle_log("你领悟【%s】：每回合首次受伤护甲+%d。" % [card_name, power_damage_block])
	var power_bleed := int(card_data.get("power_bleed_on_damage", 0))
	if power_bleed > 0:
		context.combat_state.power_bleed_on_damage += power_bleed
		context._append_battle_log("你领悟【%s】：伤害附加流血+%d。" % [card_name, power_bleed])
	if bool(card_data.get("initiative", false)):
		var bonus: int = int(card_data.get("initiative_bonus", 0))
		if RunState.next_encounter_first_strike:
			RunState.next_encounter_first_strike_bonus += GameData.FIRST_STRIKE_DAMAGE + bonus
		else:
			RunState.next_encounter_first_strike = true
			RunState.next_encounter_first_strike_bonus += bonus
		var strike: int = GameData.FIRST_STRIKE_DAMAGE + RunState.next_encounter_first_strike_bonus
		context._append_battle_log("你使用【%s】->下场战斗先手伤害提升至%d。" % [card_name, strike])
		RunState.log_event("踏勘山势，获得先手优势。")
	if is_attack:
		context.combat_state.player_next_attack_mult = 1.0
		context.combat_state.player_next_attack_bonus = 0
		context.combat_state.player_next_attack_pierce = false

func _is_attack_card(card_data: Dictionary) -> bool:
	if str(card_data.get("kind", "")) == "attack":
		return true
	return card_data.has("damage") or card_data.has("damage_from_block") or card_data.has("damage_from_missing_hp")

func _is_defend_card(card_data: Dictionary) -> bool:
	if str(card_data.get("kind", "")) in ["guard", "defend"]:
		return true
	return card_data.has("block") and not _is_attack_card(card_data)

func _calculate_attack_damage(card_data: Dictionary, combo_count: int) -> int:
	var base_damage := int(card_data.get("damage", 0))
	var bonus := int(card_data.get("damage_bonus", 0))
	if bool(card_data.get("damage_from_block", false)):
		bonus += context.combat_state.player_actor.block
	if bool(card_data.get("damage_from_missing_hp", false)):
		var missing := context.combat_state.player_actor.max_hp - context.combat_state.player_actor.hp
		var cap := int(card_data.get("missing_hp_cap", missing))
		bonus += min(missing, cap)
	var hp_ratio := float(card_data.get("damage_from_current_hp_ratio", 0.0))
	if hp_ratio > 0.0:
		bonus += int(round(float(context.combat_state.player_actor.hp) * hp_ratio))
	var per_combo := int(card_data.get("damage_per_attack_chain", 0))
	if per_combo > 0:
		bonus += per_combo * combo_count
	var total := base_damage + bonus + context.combat_state.equip_attack_bonus + context.combat_state.player_damage_bonus_turn + context.combat_state.player_next_attack_bonus
	var low_hp_mult := float(card_data.get("low_hp_mult", 1.0))
	if low_hp_mult > 1.0:
		var threshold := float(card_data.get("low_hp_threshold", 0.5))
		if float(context.combat_state.player_actor.hp) <= float(context.combat_state.player_actor.max_hp) * threshold:
			total = int(round(float(total) * low_hp_mult))
	var execute_threshold := float(card_data.get("execute_threshold", 0.0))
	if execute_threshold > 0.0:
		if context.combat_state.enemy_actor.max_hp > 0 and float(context.combat_state.enemy_actor.hp) <= float(context.combat_state.enemy_actor.max_hp) * execute_threshold:
			var execute_mult := float(card_data.get("execute_mult", 2.0))
			total = int(round(float(total) * execute_mult))
	if context.combat_state.player_next_attack_mult > 1.0:
		total = int(round(float(total) * context.combat_state.player_next_attack_mult))
	if context.combat_state.player_weak_turns > 0:
		total = int(round(float(total) * context.WEAK_DAMAGE_MULT))
	return max(total, 0)

func _should_pierce(card_data: Dictionary) -> bool:
	if bool(card_data.get("pierce", false)):
		return true
	var pierce_threshold := int(card_data.get("pierce_if_block", 0))
	if pierce_threshold > 0 and context.combat_state.player_actor.block >= pierce_threshold:
		return true
	if context.combat_state.player_next_attack_pierce:
		return true
	return false
