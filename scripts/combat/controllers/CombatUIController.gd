class_name CombatUIController
extends RefCounted

var context: Node
var combat_flow: CombatFlowController
var reward_flow: RewardFlowController

func setup(context_ref: Node, combat_flow_ref: CombatFlowController, reward_flow_ref: RewardFlowController) -> void:
	context = context_ref
	combat_flow = combat_flow_ref
	reward_flow = reward_flow_ref

func reset_battle_log() -> void:
	context.battle_log_panel.clear()

func append_battle_log(message: String) -> void:
	context.battle_log_panel.append_line(message)

func player_status_text() -> String:
	return _player_status_summary()

func player_status_summary() -> String:
	return _player_status_summary()

func player_buff_summary() -> String:
	return _player_buff_summary()

func enemy_status_summary() -> String:
	return _enemy_status_summary()

func update_ui() -> void:
	var state := context.combat_state
	var progress_current: int = int(min(RunState.encounters_completed + 1, RunState.max_encounters))
	context.progress_label.text = "攀登进度：%d / %d" % [progress_current, RunState.max_encounters]
	context.enemy_name_label.text = "敌人：%s" % state.enemy_data.get("name", "未知魔物")
	context.enemy_hp_label.text = "敌人生命：%d / %d" % [state.enemy_actor.hp, state.enemy_actor.max_hp]
	context.enemy_hp_bar.max_value = max(state.enemy_actor.max_hp, 1)
	context.enemy_hp_bar.value = state.enemy_actor.hp
	context.enemy_block_label.text = "敌人护甲：%d" % state.enemy_actor.block
	context.enemy_portrait_panel.set_status_text("状态：%s" % _enemy_status_summary())
	context.enemy_intent_label.text = "意图：%s" % combat_flow.enemy_card_display(state.enemy_intent_card)
	context.enemy_desc_label.text = state.enemy_data.get("desc", "")
	var intent_color := _enemy_card_color(state.enemy_intent_card)
	context.enemy_intent_label.add_theme_color_override("font_color", intent_color)
	context.enemy_intent_swatch.color = intent_color
	context.enemy_intent_icon.texture = _enemy_card_icon(state.enemy_intent_card)
	context.enemy_intent_icon.modulate = intent_color
	context.player_hp_label.text = "生命：%d / %d" % [state.player_actor.hp, state.player_actor.max_hp]
	context.player_hp_bar.max_value = max(state.player_actor.max_hp, 1)
	context.player_hp_bar.value = state.player_actor.hp
	context.player_block_label.text = "护甲：%d" % state.player_actor.block
	context.player_portrait_panel.set_status_text("状态：%s" % _player_status_summary())
	context.player_portrait_panel.set_buff_text("装备/心法：%s" % _player_buff_summary(), true)
	context.energy_label.text = "能量：%d / %d" % [state.player_actor.energy, RunState.energy_max]
	context.draw_label.text = "抽牌堆：%d" % state.player_actor.draw_pile.size()
	context.discard_label.text = "弃牌堆：%d" % state.player_actor.discard_pile.size()
	context.end_turn_button.disabled = state.combat_over or state.enemy_acting or state.turn_locked or state.discard_overlay_active
	var show_rewards := state.combat_over and not state.run_complete and state.next_step == "reward_options"
	var show_route := state.combat_over and not state.run_complete and state.next_step == "route"
	var show_shop := state.combat_over and not state.run_complete and state.next_step == "shop"
	var show_score := state.combat_over and state.run_complete
	reward_flow.set_reward_overlay_visible(show_rewards)
	reward_flow.set_route_overlay_visible(show_route)
	reward_flow.set_shop_overlay_visible(show_shop)
	reward_flow.set_score_overlay_visible(show_score)
	context.next_button.visible = state.combat_over and not show_rewards and not show_route and not show_shop
	if state.combat_over and context.next_button.visible:
		if state.run_complete:
			context.next_button.text = "返回主菜单"
		else:
			context.next_button.text = "继续攀登"
	refresh_hand()
	if show_rewards:
		reward_flow.refresh_reward_ui()
	if show_route:
		reward_flow.update_route_ui()
	if show_score:
		reward_flow.refresh_score_ui()

func refresh_hand() -> void:
	var state := context.combat_state
	for tween in state.hand_slot_tweens.values():
		if tween:
			tween.kill()
	state.hand_slot_tweens.clear()
	for child in context.hand_container.get_children():
		child.queue_free()
	for index in state.player_actor.hand.size():
		var card_entry = state.player_actor.hand[index]
		var card_id := RunState.get_card_id(card_entry)
		var card_data := GameData.get_card_data(card_id, RunState.get_card_upgrade_level(card_entry))
		var collapsed_scale := context.HAND_COLLAPSED_HEIGHT / context.HAND_CARD_SIZE.y
		var slot := Control.new()
		slot.custom_minimum_size = Vector2(context.HAND_CARD_SIZE.x * collapsed_scale, context.HAND_COLLAPSED_HEIGHT)
		slot.clip_contents = true
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		context.hand_container.add_child(slot)
		var widget: CardWidget = context.CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.scale = Vector2(collapsed_scale, collapsed_scale)
		widget.position = Vector2(0, context.HAND_COLLAPSED_HEIGHT - (context.HAND_CARD_SIZE.y * collapsed_scale))
		widget.clicked.connect(combat_flow.on_hand_card_clicked.bind(index))
		widget.hovered.connect(_on_hand_card_hovered.bind(index, slot))
		widget.unhovered.connect(_on_hand_card_unhovered.bind(slot))
		slot.add_child(widget)

func _on_hand_card_hovered(card_id: String, index: int, slot: Control) -> void:
	var upgrade_level := 0
	if index >= 0 and index < context.combat_state.player_actor.hand.size():
		upgrade_level = RunState.get_card_upgrade_level(context.combat_state.player_actor.hand[index])
	_on_card_hovered(card_id, upgrade_level)
	_set_hand_slot_expanded(slot, true)

func _on_hand_card_unhovered(slot: Control) -> void:
	_on_card_unhovered()
	_set_hand_slot_expanded(slot, false)

func _set_hand_slot_expanded(slot: Control, expanded: bool) -> void:
	if not slot:
		return
	var state := context.combat_state
	var tween: Tween = state.hand_slot_tweens.get(slot)
	if tween:
		tween.kill()
	var widget := slot.get_child(0) as Control
	if not widget:
		return
	var collapsed_scale := context.HAND_COLLAPSED_HEIGHT / context.HAND_CARD_SIZE.y
	var expanded_scale := context.HAND_EXPANDED_HEIGHT / context.HAND_CARD_SIZE.y
	var target_scale := expanded_scale if expanded else collapsed_scale
	var target_height := context.HAND_CARD_SIZE.y * target_scale
	var target_position := Vector2(0, context.HAND_COLLAPSED_HEIGHT - target_height)
	slot.clip_contents = not expanded
	tween = context.create_tween()
	tween.tween_property(widget, "scale", Vector2(target_scale, target_scale), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(widget, "position", target_position, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if expanded:
		slot.z_index = 20
	else:
		tween.tween_callback(func():
			if is_instance_valid(slot):
				slot.z_index = 0
		)
	state.hand_slot_tweens[slot] = tween

func _on_card_hovered(card_id: String, upgrade_level: int = 0) -> void:
	var card_data := GameData.get_card_data(card_id, upgrade_level)
	context.card_detail_panel.visible = true
	context.card_detail_name.text = str(card_data.get("name", "卡牌"))
	context.card_detail_cost.text = "费用：%d" % int(card_data.get("cost", 0))
	context.card_detail_desc.text = str(card_data.get("desc", ""))

func _on_card_unhovered() -> void:
	context.card_detail_panel.visible = false

func show_card_detail(card_id: String, upgrade_level: int = 0) -> void:
	_on_card_hovered(card_id, upgrade_level)

func hide_card_detail() -> void:
	_on_card_unhovered()

func play_enemy_hit_effect() -> void:
	context.enemy_portrait_panel.play_hit_fx()
	context.enemy_portrait_panel.play_hit_flash(Color(1, 0.5, 0.5, 0.5))

func play_player_hit_effect() -> void:
	context.player_portrait_panel.play_hit_fx()
	context.player_portrait_panel.play_hit_flash(Color(1, 0.3, 0.3, 0.45))

func setup_portraits(enemy_data: Dictionary) -> void:
	context.player_portrait_panel.set_portrait_texture(load(GameData.PLAYER_PORTRAIT))
	context.player_portrait_panel.set_frame_texture(context.PORTRAIT_FRAME)
	context.player_portrait_panel.set_hit_fx_texture(context.PLAYER_HIT_FX)
	var enemy_portrait_path: String = str(enemy_data.get("portrait", ""))
	if not enemy_portrait_path.is_empty():
		context.enemy_portrait_panel.set_portrait_texture(load(enemy_portrait_path))
	context.enemy_portrait_panel.set_frame_texture(context.PORTRAIT_FRAME)
	context.enemy_portrait_panel.set_hit_fx_texture(context.ENEMY_HIT_FX)
	context.enemy_portrait_panel.set_buff_text("", false)

func _player_status_summary() -> String:
	var state := context.combat_state
	var parts: Array = []
	if state.player_weak_turns > 0:
		parts.append("弱化%d" % state.player_weak_turns)
	if state.player_vulnerable_turns > 0:
		parts.append("易伤%d" % state.player_vulnerable_turns)
	if state.player_next_attack_mult > 1.0:
		parts.append("蓄力x%.1f" % state.player_next_attack_mult)
	if state.player_next_attack_bonus > 0:
		parts.append("下次攻击+%d" % state.player_next_attack_bonus)
	if state.player_next_attack_pierce:
		parts.append("下次穿刺")
	if state.player_counter_ratio > 0.0:
		parts.append("反击%d%%" % int(round(state.player_counter_ratio * 100.0)))
	if state.player_nullify_count > 0:
		parts.append("护幕%d" % state.player_nullify_count)
	if state.player_damage_draw > 0:
		parts.append("受伤抽牌+%d" % state.player_damage_draw)
	if state.player_bleed_on_attack > 0:
		parts.append("攻击叠流血+%d" % state.player_bleed_on_attack)
	if state.player_attack_bonus_on_attack > 0:
		parts.append("连击伤害+%d" % state.player_attack_bonus_on_attack)
	if state.player_damage_bonus_turn > 0:
		parts.append("本回合伤害+%d" % state.player_damage_bonus_turn)
	if state.player_block_disabled:
		parts.append("禁用护甲")
	if state.player_next_card_cost_delta != 0:
		parts.append("下一卡费用%+d" % state.player_next_card_cost_delta)
	if state.player_skip_enemy_turn:
		parts.append("停滞")
	if parts.is_empty():
		return "无"
	return "，".join(parts)

func _player_buff_summary() -> String:
	var state := context.combat_state
	var parts: Array = []
	if state.equip_attack_bonus > 0:
		parts.append("攻击+%d" % state.equip_attack_bonus)
	if state.equip_damage_reduction > 0:
		parts.append("减伤%d" % state.equip_damage_reduction)
	if state.equip_attack_chain_draw > 0:
		parts.append("连击抽牌%d" % state.equip_attack_chain_draw)
	if state.equip_defend_chain_block > 0:
		parts.append("连防护甲+%d" % state.equip_defend_chain_block)
	if state.equip_block_on_damage > 0:
		parts.append("受击护甲+%d" % state.equip_block_on_damage)
	if state.equip_bleed_bonus_per_stack > 0:
		parts.append("流血伤害+%d" % state.equip_bleed_bonus_per_stack)
	if state.power_first_attack_draw > 0:
		parts.append("首攻抽牌%d" % state.power_first_attack_draw)
	if state.power_first_damage_block > 0:
		parts.append("首伤护甲+%d" % state.power_first_damage_block)
	if state.power_bleed_on_damage > 0:
		parts.append("伤害附流血+%d" % state.power_bleed_on_damage)
	if parts.is_empty():
		return "无"
	return "，".join(parts)

func _enemy_status_summary() -> String:
	var state := context.combat_state
	var parts: Array = []
	if state.enemy_bleed > 0:
		parts.append("流血%d" % state.enemy_bleed)
	if state.enemy_poison > 0:
		parts.append("中毒%d" % state.enemy_poison)
	if state.enemy_burn > 0:
		parts.append("灼烧%d" % state.enemy_burn)
	if state.enemy_attack_bonus > 0:
		parts.append("蓄力+%d" % state.enemy_attack_bonus)
	if state.enemy_block_gain_reduction > 0:
		parts.append("护甲获得-%d" % state.enemy_block_gain_reduction)
	if parts.is_empty():
		return "无"
	return "，".join(parts)

func _enemy_card_color(card_data: Dictionary) -> Color:
	if card_data.is_empty():
		return Color(0.8, 0.8, 0.8)
	var intent_type: String = str(card_data.get("type", ""))
	match intent_type:
		"attack", "multi_attack", "drain":
			return Color(0.95, 0.4, 0.3)
		"guard", "charge":
			return Color(0.35, 0.7, 1.0)
		"heal":
			return Color(0.45, 0.9, 0.6)
		"debuff", "attack_debuff":
			return Color(0.8, 0.5, 1.0)
	return Color(0.9, 0.8, 0.6)

func _enemy_card_icon(card_data: Dictionary) -> Texture2D:
	if card_data.is_empty():
		return null
	var intent_type: String = str(card_data.get("type", ""))
	return context.INTENT_ICONS.get(intent_type, null)

func enemy_card_color(card_data: Dictionary) -> Color:
	return _enemy_card_color(card_data)

func enemy_card_icon(card_data: Dictionary) -> Texture2D:
	return _enemy_card_icon(card_data)
