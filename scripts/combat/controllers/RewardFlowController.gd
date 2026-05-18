class_name RewardFlowController
extends RefCounted

var context: Node
var ui: CombatUIController
var combat_flow: CombatFlowController
var combat_state: CombatState

func setup(context_ref: Node, ui_ref: CombatUIController, combat_flow_ref: CombatFlowController) -> void:
	context = context_ref
	ui = ui_ref
	combat_flow = combat_flow_ref
	combat_state = context_ref.combat_state

func queue_post_battle_step() -> void:
	combat_flow.emit_phase(BattlePhases.REWARD_EVENT, {"type": "shop"})
	combat_state.next_step = "shop"
	enter_shop()
	combat_flow.emit_phase_end(BattlePhases.REWARD_EVENT, {"type": "shop"})
	combat_flow.emit_phase(BattlePhases.BATTLE_END, {"result": "continue"})
	combat_flow.emit_phase_end(BattlePhases.BATTLE_END, {"result": "continue"})

func enter_shop() -> void:
	combat_state.next_step = "shop"
	refresh_shop_offers()
	set_shop_overlay_visible(true)
	ui.append_battle_log("战后商店开启：可以用积分购买新卡牌。")

func refresh_shop_offers() -> void:
	var pool: Array = build_shop_pool()
	combat_state.shop_offer_cards.clear()
	combat_state.shop_offer_costs.clear()
	if pool.is_empty():
		refresh_shop_ui()
		return
	pool.shuffle()
	var offer_count: int = int(min(context.SHOP_OFFER_COUNT, pool.size()))
	for i in range(offer_count):
		var card_id: String = str(pool[i])
		var card_data: Dictionary = GameData.get_card_data(card_id, 0)
		combat_state.shop_offer_cards.append(card_id)
		combat_state.shop_offer_costs[card_id] = calculate_shop_cost(card_data)
	refresh_shop_ui()

func build_shop_pool() -> Array:
	var owned: Dictionary = {}
	for entry in RunState.deck:
		var owned_id: String = RunState.get_card_id(entry)
		if not owned_id.is_empty():
			owned[owned_id] = true
	var pool: Array = []
	for card_ids():]
	for card_id in GameData.all_card_ids():
		var entry_id: String = str(card_id)
		if owned.has(entry_id):
			continue
		var data: Dictionary = GameData.get_card(entry_id)
		if data.is_empty():
			continue
		if str(data.get("kind", "")) == "curse":
			continue
		pool.append(entry_id)
	return pool

func refresh_shop_ui() -> void:
	context.shop_points_label.text = "当前积分：%d" % RunState.run_score_total
	context.shop_refresh_button.text = "刷新商品 (-%d)" % context.SHOP_REFRESH_COST
	var has_pool: bool = not build_shop_pool().is_empty()
	context.shop_refresh_button.disabled = RunState.run_score_total < context.SHOP_REFRESH_COST or not has_pool
	if combat_state.shop_offer_cards.is_empty():
		_clear_container(context.shop_choice_container)
		var label := Label.new()
		label.text = "没有可购买的新卡牌。"
		context.shop_choice_container.add_child(label)
		return
	_populate_shop_cards()

func _populate_shop_cards() -> void:
	_clear_container(context.shop_choice_container)
	for card_id in combat_state.shop_offer_cards:
		var card_data := GameData.get_card_data(card_id, 0)
		var card_name: String = str(card_data.get("name", "卡牌"))
		var slot := VBoxContainer.new()
		slot.custom_minimum_size = Vector2(220, 300)
		var widget: CardWidget = context.CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.hovered.connect(_on_card_hovered)
		widget.unhovered.connect(_on_card_unhovered)
		slot.add_child(widget)
		var cost := int(combat_state.shop_offer_costs.get(card_id, 0))
		var buy_button := Button.new()
		buy_button.text = "购买 -%d" % cost
		buy_button.disabled = RunState.run_score_total < cost
		buy_button.pressed.connect(on_shop_buy_pressed.bind(card_id))
		slot.add_child(buy_button)
		context.shop_choice_container.add_child(slot)
		var detail := Label.new()
		detail.text = "%s" % card_name
		detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.add_child(detail)

func calculate_shop_cost(card_data: Dictionary) -> int:
	var value: float = 0.0
	var damage: int = int(card_data.get("damage", 0))
	var block: int = int(card_data.get("block", 0))
	var draw: int = int(card_data.get("draw", 0))
	var heal: int = int(card_data.get("heal", 0))
	var bleed: int = int(card_data.get("apply_bleed", 0))
	var poison: int = int(card_data.get("apply_poison", 0))
	var burn: int = int(card_data.get("apply_burn", 0))
	var damage_bonus: int = int(card_data.get("damage_bonus", 0))
	var bleed_on_attack: int = int(card_data.get("bleed_on_attack", 0))
	var cost_delta: int = int(card_data.get("next_card_cost_delta", 0))
	var equip_attack: int = int(card_data.get("equip_attack_bonus", 0))
	var equip_reduction: int = int(card_data.get("equip_damage_reduction", 0))
	var equip_chain_draw: int = int(card_data.get("equip_attack_chain_draw", 0))
	var equip_defend_block: int = int(card_data.get("equip_defend_chain_block", 0))
	var equip_block_on_damage: int = int(card_data.get("equip_block_on_damage", 0))
	var equip_bleed_bonus: int = int(card_data.get("equip_bleed_bonus_per_stack", 0))
	var power_first_attack: int = int(card_data.get("power_first_attack_draw", 0))
	var power_first_damage: int = int(card_data.get("power_first_damage_block", 0))
	var power_bleed_on_damage: int = int(card_data.get("power_bleed_on_damage", 0))
	var cost: int = int(card_data.get("cost", 0))
	var kind: String = str(card_data.get("kind", ""))
	var rarity: String = str(card_data.get("rarity", "common"))
	value += float(damage) * 3.0
	value += float(block) * 2.5
	value += float(draw) * 12.0
	value += float(heal) * 3.5
	value += float(damage_bonus) * 6.0
	value += float(bleed) * 4.0
	value += float(poison) * 4.5
	value += float(burn) * 4.5
	value += float(bleed_on_attack) * 8.0
	if cost_delta != 0:
		value += -8.0 * float(cost_delta)
	value += float(equip_attack) * 14.0
	value += float(equip_reduction) * 12.0
	value += float(equip_chain_draw) * 12.0
	value += float(equip_defend_block) * 6.0
	value += float(equip_block_on_damage) * 8.0
	value += float(equip_bleed_bonus) * 10.0
	value += float(power_first_attack) * 12.0
	value += float(power_first_damage) * 10.0
	value += float(power_bleed_on_damage) * 8.0
	if bool(card_data.get("pierce", false)):
		value += 12.0
	if int(card_data.get("pierce_if_block", 0)) > 0:
		value += 8.0
	if bool(card_data.get("damage_from_block", false)):
		value += 10.0
	if bool(card_data.get("damage_from_missing_hp", false)):
		value += 14.0
	if float(card_data.get("execute_threshold", 0.0)) > 0.0:
		value += 12.0
	if bool(card_data.get("next_attack_pierce", false)):
		value += 10.0
	if bool(card_data.get("skip_enemy_turn", false)):
		value += 20.0
	if bool(card_data.get("block_disabled", false)):
		value -= 6.0
	var attack_bonus_on_attack: int = int(card_data.get("attack_bonus_on_attack", 0))
	if attack_bonus_on_attack > 0:
		value += 12.0 * float(attack_bonus_on_attack)
	var charge_mult: float = float(card_data.get("charge_mult", 0.0))
	if charge_mult > 0.0:
		value += 12.0 * charge_mult
	var next_attack_bonus: int = int(card_data.get("next_attack_bonus", 0))
	if next_attack_bonus > 0:
		value += 6.0 * float(next_attack_bonus)
		value += 10.0
	var block_gain_reduction: int = int(card_data.get("enemy_block_gain_reduction", 0))
	if block_gain_reduction > 0:
		value += 6.0 * float(block_gain_reduction)
	if kind == "equipment" or kind == "power":
		value += 25.0
	elif kind == "status":
		value += 10.0
	if cost == 0:
		value += 18.0
	match rarity:
		"rare":
			value *= 1.35
		"epic":
			value *= 1.6
	return max(int(round(value)), 10)

func set_shop_overlay_visible(active: bool) -> void:
	if active == combat_state.shop_overlay_active:
		return
	combat_state.shop_overlay_active = active
	if combat_state.shop_overlay_tween:
		combat_state.shop_overlay_tween.kill()
	if active:
		context.shop_overlay.visible = true
		context.shop_panel.scale = Vector2(0.9, 0.9)
		combat_state.shop_overlay_tween = context.create_tween()
		combat_state.shop_overlay_tween.tween_property(context.shop_overlay, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		combat_state.shop_overlay_tween.tween_property(context.shop_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		combat_state.shop_overlay_tween = context.create_tween()
		combat_state.shop_overlay_tween.tween_property(context.shop_overlay, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		combat_state.shop_overlay_tween.tween_callback(func(): context.shop_overlay.visible = false)

func on_shop_refresh_pressed() -> void:
	if RunState.run_score_total < context.SHOP_REFRESH_COST:
		return
	RunState.run_score_total -= context.SHOP_REFRESH_COST
	refresh_shop_offers()
	ui.append_battle_log("刷新了商店。")
	RunState.save_run()

func on_shop_skip_pressed() -> void:
	set_shop_overlay_visible(false)
	enter_route_selection()

func on_shop_buy_pressed(card_id: String) -> void:
	var cost := int(combat_state.shop_offer_costs.get(card_id, 0))
	if RunState.run_score_total < cost:
		return
	RunState.run_score_total -= cost
	RunState.add_card(card_id)
	combat_state.shop_offer_cards.erase(card_id)
	var card_name: String = str(GameData.get_card_data(card_id, false).get("name", "新卡牌"))
	ui.append_battle_log("购买卡牌：%s（-%d 积分）。" % [card_name, cost])
	RunState.log_event("购买卡牌：%s。" % card_name)
	refresh_shop_ui()
	ui.update_ui()
	RunState.save_run()

func enter_route_selection() -> void:
	combat_state.next_step = "route"
	combat_state.route_mode = "none"
	combat_state.supply_available = RunState.roll_supply_available()
	update_route_ui()
	set_route_overlay_visible(true)

func update_route_ui() -> void:
	if combat_state.supply_available:
		context.route_info_label.text = "前方出现补给点，你想要前往补给还是继续挑战？"
		context.route_supply_button.disabled = false
	else:
		context.route_info_label.text = "前方没有补给点，只能继续挑战。"
		context.route_supply_button.disabled = true
	context.difficulty_panel.visible = combat_state.route_mode == "challenge"

func on_route_supply_pressed() -> void:
	if not combat_state.supply_available:
		return
	combat_state.route_mode = "supply"
	set_route_overlay_visible(false)
	enter_supply_options()

func on_route_challenge_pressed() -> void:
	combat_state.route_mode = "challenge"
	update_route_ui()

func on_difficulty_selected(difficulty: String) -> void:
	RunState.next_difficulty = difficulty
	ui.append_battle_log("你选择了%s挑战。" % difficulty_display(difficulty))
	RunState.log_event("选择%s挑战。" % difficulty)
	set_route_overlay_visible(false)
	combat_flow.start_encounter()

func difficulty_display(difficulty: String) -> String:
	match difficulty:
		"hard": return "困难"
		"elite": return "精英"
	return "普通"

func enter_supply_options() -> void:
	combat_state.next_step = "reward_options"
	combat_state.reward_mode = "none"
	combat_state.last_reward_mode = ""
	refresh_reward_ui()
	set_reward_overlay_visible(true)

func refresh_reward_ui() -> void:
	context.reward_choice_label.text = ""
	context.reward_choice_scroll.visible = false
	context.reward_deck_scroll.visible = false
	context.reward_options.visible = true
	context.reward_upgrade_button.disabled = RunState.deck.is_empty()
	context.reward_remove_button.disabled = RunState.deck.is_empty()
	context.reward_heal_button.disabled = combat_state.player_actor.hp >= combat_state.player_actor.max_hp
	if combat_state.reward_mode == "upgrade":
		context.reward_choice_label.text = "选择要强化的卡牌："
		context.reward_choice_scroll.visible = true
		context.reward_deck_scroll.visible = true
		context.reward_options.visible = false
		_populate_reward_deck()
	elif combat_state.reward_mode == "remove":
		context.reward_choice_label.text = "选择要移除的卡牌："
		context.reward_choice_scroll.visible = true
		context.reward_deck_scroll.visible = true
		context.reward_options.visible = false
		_populate_reward_deck()
	elif combat_state.reward_mode == "supply_draft":
		context.reward_choice_label.text = "选择一张补给卡："
		context.reward_choice_scroll.visible = true
		context.reward_options.visible = false
		populate_supply_cards()

func set_reward_overlay_visible(active: bool) -> void:
	if active == combat_state.reward_overlay_active:
		return
	combat_state.reward_overlay_active = active
	if combat_state.reward_overlay_tween:
		combat_state.reward_overlay_tween.kill()
	if active:
		context.reward_overlay.visible = true
		context.reward_panel.scale = Vector2(0.9, 0.9)
		combat_state.reward_overlay_tween = context.create_tween()
		combat_state.reward_overlay_tween.tween_property(context.reward_overlay, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		combat_state.reward_overlay_tween.tween_property(context.reward_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		combat_state.reward_overlay_tween = context.create_tween()
		combat_state.reward_overlay_tween.tween_property(context.reward_overlay, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		combat_state.reward_overlay_tween.tween_callback(func(): context.reward_overlay.visible = false)

func set_discard_overlay_visible(active: bool) -> void:
	if active == combat_state.discard_overlay_active:
		return
	combat_state.discard_overlay_active = active
	if combat_state.discard_overlay_tween:
		combat_state.discard_overlay_tween.kill()
	if active:
		context.discard_overlay.visible = true
		context.discard_panel.scale = Vector2(0.9, 0.9)
		combat_state.discard_overlay_tween = context.create_tween()
		combat_state.discard_overlay_tween.tween_property(context.discard_overlay, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		combat_state.discard_overlay_tween.tween_property(context.discard_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		combat_state.discard_overlay_tween = context.create_tween()
		combat_state.discard_overlay_tween.tween_property(context.discard_overlay, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		combat_state.discard_overlay_tween.tween_callback(func(): context.discard_overlay.visible = false)

func open_discard_overlay(required: int) -> void:
	combat_state.discard_required = required
	combat_state.discard_selection.clear()
	_build_discard_locks()
	_refresh_discard_ui()
	set_discard_overlay_visible(true)

func _build_discard_locks() -> void:
	combat_state.discard_locked_indices.clear()
	for index in combat_state.player_actor.hand.size():
		var card_entry = combat_state.player_actor.hand[index]
		var card_id := RunState.get_card_id(card_entry)
		var card_data := GameData.get_card_data(card_id, RunState.get_card_upgrade_level(card_entry))
		if bool(card_data.get("retain", false)):
			combat_state.discard_locked_indices[index] = true

func _refresh_discard_ui() -> void:
	context.discard_info_label.text = "请选择要弃置的卡牌（%d/%d）" % [
		combat_state.discard_selection.size(),
		combat_state.discard_required
	]
	context.discard_confirm_button.disabled = combat_state.discard_selection.size() != combat_state.discard_required
	_populate_discard_cards()

func _populate_discard_cards() -> void:
	_clear_container(context.discard_choice_container)
	combat_state.discard_card_widgets.clear()
	for index in combat_state.player_actor.hand.size():
		var card_entry = combat_state.player_actor.hand[index]
		var card_id := RunState.get_card_id(card_entry)
		var card_data := GameData.get_card_data(card_id, RunState.get_card_upgrade_level(card_entry))
		var widget: CardWidget = context.CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.clicked.connect(_on_discard_card_clicked.bind(index, widget))
		widget.hovered.connect(_on_discard_card_hovered.bind(index))
		widget.unhovered.connect(_on_card_unhovered)
		context.discard_choice_container.add_child(widget)
		combat_state.discard_card_widgets[index] = widget

func _on_discard_card_clicked(card_id: String, index: int, widget: CardWidget) -> void:
	if combat_state.discard_required <= 0:
		return
	if combat_state.discard_locked_indices.get(index, false):
		return
	if combat_state.discard_selection.has(index):
		combat_state.discard_selection.erase(index)
		if widget:
			widget.modulate = Color(1, 1, 1, 1)
	elif combat_state.discard_selection.size() < combat_state.discard_required:
		combat_state.discard_selection.append(index)
		if widget:
			widget.modulate = Color(0.9, 0.9, 0.9, 1)
	_refresh_discard_ui()

func _on_discard_card_hovered(card_id: String, index: int) -> void:
	var upgrade_level := 0
	if index >= 0 and index < combat_state.player_actor.hand.size():
		upgrade_level = RunState.get_card_upgrade_level(combat_state.player_actor.hand[index])
	ui.show_card_detail(card_id, upgrade_level)

func _on_discard_confirm_pressed() -> void:
	if combat_state.discard_selection.size() != combat_state.discard_required:
		return
	var discard_count := combat_state.discard_required
	combat_flow.emit_phase(BattlePhases.DISCARD, {"count": discard_count})
	_apply_discard_selection()
	combat_flow.emit_phase_end(BattlePhases.DISCARD, {"remaining": combat_state.player_actor.hand.size()})
	if combat_state.end_turn_phase_pending:
		combat_flow.emit_phase_end(BattlePhases.END_TURN_TRIGGER, {"turn": combat_state.turn_index, "discard_required": discard_count})
		combat_state.end_turn_phase_pending = false
	set_discard_overlay_visible(false)
	ui.refresh_hand()
	await combat_flow.resolve_end_turn()

func _apply_discard_selection() -> void:
	combat_state.discard_selection.sort()
	for i in range(combat_state.discard_selection.size() - 1, -1, -1):
		var index: int = combat_state.discard_selection[i]
		if index >= 0 and index < combat_state.player_actor.hand.size():
			var card_entry = combat_state.player_actor.hand[index]
			var card_id := RunState.get_card_id(card_entry)
			var card_data := GameData.get_card_data(card_id, RunState.get_card_upgrade_level(card_entry))
			if bool(card_data.get("ethereal", false)) or bool(card_data.get("exhaust", false)):
				ui.append_battle_log("【%s】已消耗。" % card_data.get("name", "卡牌"))
			else:
				combat_state.player_actor.discard_pile.append(card_entry)
			combat_state.player_actor.hand.remove_at(index)
	combat_state.discard_selection.clear()
	combat_state.discard_required = 0
	combat_state.discard_locked_indices.clear()

func _on_reward_deck_card_hovered(card_id: String, index: int) -> void:
	var upgrade_level := 0
	if index >= 0 and index < RunState.deck.size():
		upgrade_level = RunState.get_card_upgrade_level(RunState.deck[index])
	ui.show_card_detail(card_id, upgrade_level)

func set_route_overlay_visible(active: bool) -> void:
	if active == combat_state.route_overlay_active:
		return
	combat_state.route_overlay_active = active
	context.route_overlay.visible = active

func set_score_overlay_visible(active: bool) -> void:
	if active == combat_state.score_overlay_active:
		return
	combat_state.score_overlay_active = active
	context.score_overlay.visible = active

func refresh_score_ui() -> void:
	context.score_summary_label.text = "最终得分：%d" % RunState.run_score_total
	var rank_text: String = str(RunState.get_current_leaderboard_rank_text())
	context.score_rank_label.text = "排名：%s" % rank_text
	_clear_container(context.score_list)
	for index in RunState.leaderboard.size():
		var entry: Dictionary = RunState.leaderboard[index]
		var score_value := int(entry.get("score", 0))
		var time_text := str(entry.get("time", ""))
		var label := Label.new()
		label.text = "%d. %d 分 %s" % [index + 1, score_value, time_text]
		context.score_list.add_child(label)

func on_score_continue_pressed() -> void:
	context.get_tree().change_scene_to_file("res://scenes/Main.tscn")

func populate_supply_cards() -> void:
	_clear_container(context.reward_choice_container)
	combat_state.reward_cards = _roll_reward_cards(2)
	for card_id in combat_state.reward_cards:
		var card_data := GameData.get_card_data(card_id, false)
		var widget: CardWidget = context.CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.clicked.connect(_on_reward_card_selected)
		widget.hovered.connect(_on_card_hovered)
		widget.unhovered.connect(_on_card_unhovered)
		context.reward_choice_container.add_child(widget)

func _roll_reward_cards(count: int = 3) -> Array:
	var card_ids: Array = []
	for card_id in GameData.all_card_ids():
		var data := GameData.get_card_data(str(card_id), 0)
		if str(data.get("kind", "")) == "curse":
			continue
		card_ids.append(str(card_id))
	card_ids.shuffle()
	var result: Array = []
	for i in min(count, card_ids.size()):
		result.append(str(card_ids[i]))
	return result

func _populate_reward_deck() -> void:
	_clear_container(context.reward_deck_list)
	for index in RunState.deck.size():
		var card_entry = RunState.deck[index]
		var card_id := RunState.get_card_id(card_entry)
		var upgrade_level := RunState.get_card_upgrade_level(card_entry)
		var card_data := GameData.get_card_data(card_id, upgrade_level)
		var widget: CardWidget = context.CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.clicked.connect(_on_reward_deck_card_selected.bind(index))
		widget.hovered.connect(_on_reward_deck_card_hovered.bind(index))
		widget.unhovered.connect(_on_card_unhovered)
		context.reward_deck_list.add_child(widget)

func _on_reward_upgrade_pressed() -> void:
	combat_state.reward_mode = "upgrade"
	combat_state.last_reward_mode = ""
	refresh_reward_ui()

func _on_reward_remove_pressed() -> void:
	combat_state.reward_mode = "remove"
	combat_state.last_reward_mode = ""
	refresh_reward_ui()

func _on_reward_skip_pressed() -> void:
	ui.append_battle_log("你放弃了补给。")
	RunState.log_event("放弃了补给。")
	context.sfx_reward.play()
	combat_flow.start_encounter()

func _on_reward_heal_pressed() -> void:
	var before: int = combat_state.player_actor.hp
	combat_state.player_actor.hp = min(combat_state.player_actor.hp + GameData.SUPPLY_HEAL_AMOUNT, combat_state.player_actor.max_hp)
	var healed: int = combat_state.player_actor.hp - before
	combat_flow.sync_player_hp()
	ui.append_battle_log("补给休整，恢复%d点生命（HP %d/%d）。" % [healed, combat_state.player_actor.hp, combat_state.player_actor.max_hp])
	RunState.log_event("补给休整恢复%d点生命。" % healed)
	context.sfx_reward.play()
	combat_flow.start_encounter()

func _on_reward_draft_pressed() -> void:
	combat_state.reward_mode = "supply_draft"
	combat_state.last_reward_mode = ""
	refresh_reward_ui()

func _on_reward_card_selected(card_id: String) -> void:
	RunState.add_card(card_id)
	var card_name: String = str(GameData.get_card_data(card_id, false).get("name", "新卡牌"))
	ui.append_battle_log("补给中获得一张卡牌：%s。" % card_name)
	RunState.log_event("补给获得卡牌：%s：%s。" % card_name)
	context.sfx_reward.play()
	combat_flow.start_encounter()

func _on_reward_deck_card_selected(card_id: String, index: int) -> void:
	if combat_state.reward_mode == "upgrade":
		var upgrade_level := RunState.get_card_upgrade_level(RunState.deck[index])
		RunState.set_card_upgrade_level(RunState.deck[index], upgrade_level + 1)
		var upgraded_name: String = str(GameData.get_card_data(card_id, upgrade_level + 1).get("name", "卡牌"))
		ui.append_battle_log("已强化卡牌：%s。" % upgraded_name)
		RunState.log_event("强化卡牌：%s。" % upgraded_name)
		context.sfx_reward.play()
		combat_flow.start_encounter()
		return
	if combat_state.reward_mode == "remove":
		var removed: Variant = RunState.deck.pop_at(index)
		if removed != null:
			var removed_name: String = str(GameData.get_card_data(card_id, 0).get("name", "卡牌"))
			ui.append_battle_log("已移除卡牌：%s。" % removed_name)
			RunState.log_event("移除卡牌：%s。" % removed_name)
		context.sfx_reward.play()
		combat_flow.start_encounter()

func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

func _on_card_hovered(card_id: String, upgrade_level: int = 0) -> void:
	ui.show_card_detail(card_id, upgrade_level)

func _on_card_unhovered() -> void:
	ui.hide_card_detail()