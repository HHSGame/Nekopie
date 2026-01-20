extends Control

const CARD_WIDGET_SCENE := preload("res://scenes/CardWidget.tscn")
const HAND_SIZE := 5
const ENERGY_PER_TURN := 3

@onready var story_label: Label = $MarginContainer/VBoxContainer/StoryLabel
@onready var progress_label: Label = $MarginContainer/VBoxContainer/ProgressLabel
@onready var enemy_name_label: Label = $MarginContainer/VBoxContainer/EnemyPanel/EnemyNameLabel
@onready var enemy_hp_label: Label = $MarginContainer/VBoxContainer/EnemyPanel/EnemyHpLabel
@onready var enemy_block_label: Label = $MarginContainer/VBoxContainer/EnemyPanel/EnemyBlockLabel
@onready var enemy_intent_label: Label = $MarginContainer/VBoxContainer/EnemyPanel/EnemyIntentLabel
@onready var enemy_desc_label: Label = $MarginContainer/VBoxContainer/EnemyPanel/EnemyDescLabel
@onready var player_hp_label: Label = $MarginContainer/VBoxContainer/PlayerPanel/PlayerHpLabel
@onready var player_block_label: Label = $MarginContainer/VBoxContainer/PlayerPanel/PlayerBlockLabel
@onready var energy_label: Label = $MarginContainer/VBoxContainer/PlayerPanel/EnergyLabel
@onready var draw_label: Label = $MarginContainer/VBoxContainer/PlayerPanel/DrawLabel
@onready var discard_label: Label = $MarginContainer/VBoxContainer/PlayerPanel/DiscardLabel
@onready var result_label: Label = $MarginContainer/VBoxContainer/ResultLabel
@onready var hand_container: HBoxContainer = $MarginContainer/VBoxContainer/HandScroll/HandContainer
@onready var end_turn_button: Button = $MarginContainer/VBoxContainer/Actions/EndTurnButton
@onready var next_button: Button = $MarginContainer/VBoxContainer/Actions/NextButton
@onready var back_button: Button = $MarginContainer/VBoxContainer/Header/BackButton

var draw_pile: Array = []
var hand: Array = []
var discard_pile: Array = []
var player_block := 0
var energy := 0

var enemy_data := {}
var enemy_hp := 0
var enemy_max_hp := 0
var enemy_block := 0
var enemy_attack_bonus := 0
var enemy_intents: Array = []
var intent_index := 0
var current_intent: Dictionary = {}
var combat_over := false
var run_complete := false
var pending_event: Dictionary = {}
var next_step := "encounter"

func _ready() -> void:
	story_label.text = "你踏上 %s 的山道，魔物在雾中伺机。" % GameData.MOUNTAIN_NAME
	back_button.pressed.connect(_on_back_pressed)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	next_button.pressed.connect(_on_next_pressed)
	_start_encounter()

func _start_encounter() -> void:
	combat_over = false
	run_complete = false
	player_block = 0
	energy = ENERGY_PER_TURN
	draw_pile = RunState.deck.duplicate(true)
	draw_pile.shuffle()
	hand.clear()
	discard_pile.clear()
	enemy_data = RunState.start_encounter()
	enemy_hp = enemy_data.get("hp", 0)
	enemy_max_hp = enemy_hp
	enemy_block = 0
	enemy_attack_bonus = 0
	enemy_intents = enemy_data.get("intents", [])
	if enemy_intents.is_empty():
		enemy_intents = [
			{"type": "attack", "value": int(enemy_data.get("attack", 0)), "text": "攻击"}
		]
	intent_index = 0
	_set_next_intent()
	pending_event = {}
	next_step = "encounter"
	if RunState.next_encounter_first_strike:
		var strike_damage := GameData.FIRST_STRIKE_DAMAGE
		enemy_hp = max(enemy_hp - strike_damage, 0)
		RunState.next_encounter_first_strike = false
		result_label.text = "你先手出击，对魔物造成%d点伤害。" % strike_damage
	else:
		result_label.text = "遭遇了新的魔物，准备战斗。"
	_draw_cards(HAND_SIZE)
	_update_ui()

func _update_ui() -> void:
	var progress_current: int = int(min(RunState.encounters_completed + 1, RunState.max_encounters))
	progress_label.text = "攀登进度：%d / %d" % [progress_current, RunState.max_encounters]
	enemy_name_label.text = "敌人：%s" % enemy_data.get("name", "未知魔物")
	enemy_hp_label.text = "敌人生命：%d / %d" % [enemy_hp, enemy_max_hp]
	enemy_block_label.text = "敌人护甲：%d" % enemy_block
	enemy_intent_label.text = "意图：%s" % _intent_display(current_intent)
	enemy_desc_label.text = enemy_data.get("desc", "")
	player_hp_label.text = "生命：%d / %d" % [RunState.player_hp, RunState.player_max_hp]
	player_block_label.text = "护甲：%d" % player_block
	energy_label.text = "能量：%d" % energy
	draw_label.text = "抽牌堆：%d" % draw_pile.size()
	discard_label.text = "弃牌堆：%d" % discard_pile.size()
	end_turn_button.disabled = combat_over
	next_button.visible = combat_over
	if combat_over:
		if run_complete:
			next_button.text = "返回主菜单"
		elif next_step == "event":
			next_button.text = "处理事件"
		else:
			next_button.text = "继续攀登"
	_refresh_hand()

func _refresh_hand() -> void:
	for child in hand_container.get_children():
		child.queue_free()
	for index in hand.size():
		var card_id: String = hand[index]
		var card_data := GameData.get_card(card_id)
		var widget: CardWidget = CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.clicked.connect(_on_hand_card_clicked.bind(index))
		hand_container.add_child(widget)

func _draw_cards(count: int) -> void:
	for i in count:
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile.duplicate(true)
			discard_pile.clear()
			draw_pile.shuffle()
		hand.append(draw_pile.pop_back())

func _on_hand_card_clicked(card_id: String, index: int) -> void:
	if combat_over:
		return
	var card_data := GameData.get_card(card_id)
	var cost := int(card_data.get("cost", 0))
	if cost > energy:
		result_label.text = "能量不足，无法打出 %s。" % card_data.get("name", "卡牌")
		return
	energy -= cost
	_apply_card_effect(card_data)
	_remove_card_from_hand(card_id, index)
	discard_pile.append(card_id)
	_check_enemy_defeat()
	_update_ui()

func _apply_card_effect(card_data: Dictionary) -> void:
	var damage := int(card_data.get("damage", 0))
	if damage > 0:
		var blocked: int = min(enemy_block, damage)
		enemy_block -= blocked
		var actual_damage: int = damage - blocked
		if actual_damage > 0:
			enemy_hp = max(enemy_hp - actual_damage, 0)
			result_label.text = "你对魔物造成%d点伤害。" % actual_damage
		else:
			result_label.text = "敌人的护甲挡住了攻击。"
	var block := int(card_data.get("block", 0))
	if block > 0:
		player_block += block
		result_label.text = "你获得%d点护甲。" % block
	var draw_count := int(card_data.get("draw", 0))
	if draw_count > 0:
		_draw_cards(draw_count)
		result_label.text = "你抽了%d张牌。" % draw_count
	if bool(card_data.get("initiative", false)):
		RunState.next_encounter_first_strike = true
		result_label.text = "你踏勘山势，下场战斗将先手出击。"

func _remove_card_from_hand(card_id: String, index: int) -> void:
	if index >= 0 and index < hand.size() and hand[index] == card_id:
		hand.remove_at(index)
		return
	var fallback_index := hand.find(card_id)
	if fallback_index >= 0:
		hand.remove_at(fallback_index)

func _on_end_turn_pressed() -> void:
	if combat_over:
		return
	_discard_hand()
	_enemy_turn()
	if combat_over:
		_update_ui()
		return
	player_block = 0
	energy = ENERGY_PER_TURN
	_draw_cards(HAND_SIZE)
	result_label.text = "魔物行动结束，你继续攀登。"
	_update_ui()

func _discard_hand() -> void:
	for card_id in hand:
		discard_pile.append(card_id)
	hand.clear()

func _enemy_turn() -> void:
	enemy_block = 0
	_execute_intent(current_intent)
	if RunState.player_hp <= 0:
		combat_over = true
		run_complete = true
		result_label.text = "你在山道上倒下，征途告终。"
		return
	if not combat_over:
		_set_next_intent()

func _check_enemy_defeat() -> void:
	if enemy_hp <= 0:
		combat_over = true
		run_complete = RunState.complete_encounter()
		if run_complete:
			result_label.text = "你征服了 %s，登顶通关！" % GameData.MOUNTAIN_NAME
		else:
			_queue_post_battle_step()

func _on_next_pressed() -> void:
	if not combat_over:
		return
	if run_complete:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		return
	if next_step == "event":
		_apply_event(pending_event)
		pending_event = {}
		if not run_complete:
			next_step = "event_result"
		_update_ui()
		return
	_start_encounter()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _set_next_intent() -> void:
	if enemy_intents.is_empty():
		current_intent = {}
		return
	current_intent = enemy_intents[intent_index % enemy_intents.size()]
	intent_index += 1

func _intent_display(intent: Dictionary) -> String:
	var intent_type: String = str(intent.get("type", ""))
	var custom_text: String = str(intent.get("text", ""))
	if not custom_text.is_empty():
		return custom_text
	match intent_type:
		"attack":
			return "攻击 %d" % int(intent.get("value", 0))
		"multi_attack":
			return "连击 %d x %d" % [int(intent.get("value", 0)), int(intent.get("hits", 1))]
		"guard":
			return "护甲 +%d" % int(intent.get("value", 0))
		"charge":
			return "蓄力 +%d" % int(intent.get("value", 0))
		"drain":
			return "汲取 %d" % int(intent.get("value", 0))
	return "行动未知"

func _execute_intent(intent: Dictionary) -> void:
	if intent.is_empty():
		result_label.text = "魔物踌躇不前。"
		return
	var intent_type: String = str(intent.get("type", ""))
	match intent_type:
		"attack":
			var damage_value: int = int(intent.get("value", 0)) + enemy_attack_bonus
			enemy_attack_bonus = 0
			_apply_enemy_damage(damage_value)
		"multi_attack":
			var hits: int = int(intent.get("hits", 1))
			var per_hit: int = int(intent.get("value", 0))
			var total_damage: int = (per_hit * hits) + enemy_attack_bonus
			enemy_attack_bonus = 0
			_apply_enemy_damage(total_damage, "魔物连击，造成%d点伤害。")
		"guard":
			var guard_value: int = int(intent.get("value", 0))
			enemy_block += guard_value
			result_label.text = "魔物筑起护甲，获得%d点护甲。" % guard_value
		"charge":
			var charge_value: int = int(intent.get("value", 0))
			enemy_attack_bonus += charge_value
			result_label.text = "魔物蓄力，下一次攻击+%d。" % charge_value
		"drain":
			var drain_damage: int = int(intent.get("value", 0)) + enemy_attack_bonus
			var drain_heal: int = int(intent.get("heal", 0))
			enemy_attack_bonus = 0
			var dealt: int = _apply_enemy_damage(drain_damage, "魔物汲取，造成%d点伤害。")
			if dealt > 0 and drain_heal > 0:
				enemy_hp = min(enemy_hp + drain_heal, enemy_max_hp)
				result_label.text += " 魔物恢复%d点生命。" % drain_heal
		_:
			result_label.text = "魔物踌躇不前。"

func _apply_enemy_damage(amount: int, text_template: String = "魔物反击，造成%d点伤害。") -> int:
	if amount <= 0:
		result_label.text = "魔物踌躇不前。"
		return 0
	var blocked: int = int(min(amount, player_block))
	var damage: int = amount - blocked
	player_block = max(player_block - amount, 0)
	if damage > 0:
		RunState.player_hp = max(RunState.player_hp - damage, 0)
		result_label.text = text_template % damage
	else:
		result_label.text = "你挡下了魔物的攻击。"
	return damage

func _queue_post_battle_step() -> void:
	pending_event = {}
	next_step = "encounter"
	var roll: float = randf()
	if roll <= GameData.EVENT_CHANCE:
		pending_event = GameData.get_random_event()
	if pending_event.is_empty():
		result_label.text = "你击退了魔物，继续向山顶攀登。"
		return
	next_step = "event"
	result_label.text = "遭遇事件：%s - %s" % [
		pending_event.get("name", "事件"),
		pending_event.get("desc", "")
	]

func _apply_event(event_data: Dictionary) -> void:
	var effect: String = str(event_data.get("effect", ""))
	var value: int = int(event_data.get("value", 0))
	match effect:
		"heal":
			var before: int = RunState.player_hp
			RunState.player_hp = min(RunState.player_hp + value, RunState.player_max_hp)
			var healed: int = RunState.player_hp - before
			result_label.text = "你恢复了%d点生命。" % healed
		"damage":
			RunState.player_hp = max(RunState.player_hp - value, 0)
			result_label.text = "你受到%d点伤害。" % value
			if RunState.player_hp <= 0:
				run_complete = true
				result_label.text = "你在山道上倒下，征途告终。"
		"card":
			var card_id: String = GameData.get_random_card_id()
			if card_id.is_empty():
				result_label.text = "你未能找到合适的补给。"
			else:
				RunState.deck.append(card_id)
				var card_name: String = str(GameData.get_card(card_id).get("name", "新卡牌"))
				result_label.text = "你获得了一张卡牌：%s。" % card_name
		_:
			result_label.text = "事件无事发生。"
