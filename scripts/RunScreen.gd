extends Control

const CARD_WIDGET_SCENE := preload("res://scenes/CardWidget.tscn")
const HAND_SIZE := 5
const ENERGY_PER_TURN := 3

@onready var story_label: Label = %StoryLabel
@onready var progress_label: Label = %ProgressLabel
@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var enemy_hp_label: Label = %EnemyHpLabel
@onready var enemy_desc_label: Label = %EnemyDescLabel
@onready var player_hp_label: Label = %PlayerHpLabel
@onready var player_block_label: Label = %PlayerBlockLabel
@onready var energy_label: Label = %EnergyLabel
@onready var draw_label: Label = %DrawLabel
@onready var discard_label: Label = %DiscardLabel
@onready var result_label: Label = %ResultLabel
@onready var hand_container: HBoxContainer = %HandContainer
@onready var end_turn_button: Button = %EndTurnButton
@onready var next_button: Button = %NextButton
@onready var back_button: Button = %BackButton

var draw_pile: Array = []
var hand: Array = []
var discard_pile: Array = []
var player_block := 0
var energy := 0

var enemy_data := {}
var enemy_hp := 0
var combat_over := false
var run_complete := false

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
	enemy_hp_label.text = "敌人生命：%d" % enemy_hp
	enemy_desc_label.text = enemy_data.get("desc", "")
	player_hp_label.text = "生命：%d / %d" % [RunState.player_hp, RunState.player_max_hp]
	player_block_label.text = "护甲：%d" % player_block
	energy_label.text = "能量：%d" % energy
	draw_label.text = "抽牌堆：%d" % draw_pile.size()
	discard_label.text = "弃牌堆：%d" % discard_pile.size()
	end_turn_button.disabled = combat_over
	next_button.visible = combat_over
	if combat_over:
		next_button.text = "返回主菜单" if run_complete else "继续攀登"
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
		enemy_hp = max(enemy_hp - damage, 0)
		result_label.text = "你对魔物造成%d点伤害。" % damage
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
	var enemy_attack: int = int(enemy_data.get("attack", 0))
	if enemy_attack <= 0:
		result_label.text = "魔物踌躇不前。"
		return
	var blocked: int = int(min(enemy_attack, player_block))
	var damage: int = enemy_attack - blocked
	player_block = max(player_block - enemy_attack, 0)
	if damage > 0:
		RunState.player_hp = max(RunState.player_hp - damage, 0)
		result_label.text = "魔物反击，造成%d点伤害。" % damage
	else:
		result_label.text = "你挡下了魔物的攻击。"
	if RunState.player_hp <= 0:
		combat_over = true
		run_complete = true
		result_label.text = "你在山道上倒下，征途告终。"

func _check_enemy_defeat() -> void:
	if enemy_hp <= 0:
		combat_over = true
		run_complete = RunState.complete_encounter()
		if run_complete:
			result_label.text = "你征服了 %s，登顶通关！" % GameData.MOUNTAIN_NAME
		else:
			result_label.text = "你击退了魔物，继续向山顶攀登。"

func _on_next_pressed() -> void:
	if not combat_over:
		return
	if run_complete:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		return
	_start_encounter()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
