extends Control

const CARD_WIDGET_SCENE := preload("res://scenes/CardWidget.tscn")
const HAND_SIZE := 5
const HAND_CARD_SIZE := Vector2(220, 260)
const HAND_COLLAPSED_HEIGHT := 72.0
const HAND_EXPANDED_HEIGHT := 200.0
const INTENT_ICONS := {
	"attack": preload("res://icons/intent_attack.svg"),
	"multi_attack": preload("res://icons/intent_multi.svg"),
	"guard": preload("res://icons/intent_guard.svg"),
	"charge": preload("res://icons/intent_charge.svg"),
	"drain": preload("res://icons/intent_drain.svg")
}

@onready var story_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/BattleCenterColumn/StoryPanel/StoryMargin/StoryLabel
@onready var progress_label: Label = $MarginContainer/RootVBox/HandDock/HandMargin/HandVBox/Actions/ProgressPanel/ProgressMargin/ProgressLabel
@onready var enemy_name_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyNameLabel
@onready var enemy_hp_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyStatsPanel/EnemyStatsMargin/EnemyStatsVBox/EnemyHpRow/EnemyHpLabel
@onready var enemy_hp_bar: ProgressBar = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyStatsPanel/EnemyStatsMargin/EnemyStatsVBox/EnemyHpBar
@onready var enemy_block_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyStatsPanel/EnemyStatsMargin/EnemyStatsVBox/EnemyBlockRow/EnemyBlockLabel
@onready var enemy_intent_swatch: ColorRect = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyStatsPanel/EnemyStatsMargin/EnemyStatsVBox/EnemyIntentSwatch
@onready var enemy_intent_icon: TextureRect = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyStatsPanel/EnemyStatsMargin/EnemyStatsVBox/EnemyIntentRow/EnemyIntentIcon
@onready var enemy_intent_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyStatsPanel/EnemyStatsMargin/EnemyStatsVBox/EnemyIntentRow/EnemyIntentLabel
@onready var enemy_desc_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyStatsPanel/EnemyStatsMargin/EnemyStatsVBox/EnemyDescLabel
@onready var player_portrait: TextureRect = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerPortraitPanel/PlayerPortrait
@onready var enemy_portrait: TextureRect = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyPortraitPanel/EnemyPortrait
@onready var player_hit_flash: ColorRect = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerPortraitPanel/PlayerHitFlash
@onready var player_hit_fx: TextureRect = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerPortraitPanel/PlayerFxCenter/PlayerHitFx
@onready var enemy_hit_flash: ColorRect = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyPortraitPanel/EnemyHitFlash
@onready var enemy_hit_fx: TextureRect = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyPortraitPanel/EnemyFxCenter/EnemyHitFx
@onready var player_hp_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerHpRow/PlayerHpLabel
@onready var player_block_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerBlockRow/PlayerBlockLabel
@onready var energy_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerEnergyRow/EnergyLabel
@onready var draw_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerDeckRow/DrawLabel
@onready var discard_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerDeckRow/DiscardLabel
@onready var player_hp_bar: ProgressBar = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerHpBar
@onready var result_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/BattleCenterColumn/BattleLogPanel/BattleLogMargin/ResultLabel
@onready var hand_container: HBoxContainer = $MarginContainer/RootVBox/HandDock/HandMargin/HandVBox/HandScroll/HandContainer
@onready var end_turn_button: Button = $MarginContainer/RootVBox/HandDock/HandMargin/HandVBox/Actions/EndTurnButton
@onready var next_button: Button = $MarginContainer/RootVBox/HandDock/HandMargin/HandVBox/Actions/NextButton
@onready var back_button: Button = $MarginContainer/RootVBox/HandDock/HandMargin/HandVBox/Actions/BackButton
@onready var route_overlay: Control = $RouteOverlay
@onready var route_info_label: Label = $RouteOverlay/CenterContainer/RoutePanel/RouteMargin/RouteVBox/RouteInfoLabel
@onready var route_supply_button: Button = $RouteOverlay/CenterContainer/RoutePanel/RouteMargin/RouteVBox/RouteButtons/RouteSupplyButton
@onready var route_challenge_button: Button = $RouteOverlay/CenterContainer/RoutePanel/RouteMargin/RouteVBox/RouteButtons/RouteChallengeButton
@onready var difficulty_panel: VBoxContainer = $RouteOverlay/CenterContainer/RoutePanel/RouteMargin/RouteVBox/DifficultyPanel
@onready var difficulty_normal_button: Button = $RouteOverlay/CenterContainer/RoutePanel/RouteMargin/RouteVBox/DifficultyPanel/DifficultyButtons/DifficultyNormalButton
@onready var difficulty_hard_button: Button = $RouteOverlay/CenterContainer/RoutePanel/RouteMargin/RouteVBox/DifficultyPanel/DifficultyButtons/DifficultyHardButton
@onready var difficulty_elite_button: Button = $RouteOverlay/CenterContainer/RoutePanel/RouteMargin/RouteVBox/DifficultyPanel/DifficultyButtons/DifficultyEliteButton
@onready var reward_overlay: Control = $RewardOverlay
@onready var reward_options: HBoxContainer = $RewardOverlay/CenterContainer/RewardPanel/RewardMargin/RewardVBox/RewardOptions
@onready var reward_upgrade_button: Button = $RewardOverlay/CenterContainer/RewardPanel/RewardMargin/RewardVBox/RewardOptions/RewardUpgradeButton
@onready var reward_remove_button: Button = $RewardOverlay/CenterContainer/RewardPanel/RewardMargin/RewardVBox/RewardOptions/RewardRemoveButton
@onready var reward_heal_button: Button = $RewardOverlay/CenterContainer/RewardPanel/RewardMargin/RewardVBox/RewardOptions/RewardHealButton
@onready var reward_draft_button: Button = $RewardOverlay/CenterContainer/RewardPanel/RewardMargin/RewardVBox/RewardOptions/RewardDraftButton
@onready var reward_skip_button: Button = $RewardOverlay/CenterContainer/RewardPanel/RewardMargin/RewardVBox/RewardOptions/RewardSkipButton
@onready var reward_choice_label: Label = $RewardOverlay/CenterContainer/RewardPanel/RewardMargin/RewardVBox/RewardChoiceLabel
@onready var reward_choice_scroll: ScrollContainer = $RewardOverlay/CenterContainer/RewardPanel/RewardMargin/RewardVBox/RewardChoiceScroll
@onready var reward_choice_container: HBoxContainer = $RewardOverlay/CenterContainer/RewardPanel/RewardMargin/RewardVBox/RewardChoiceScroll/RewardChoiceContainer
@onready var reward_deck_scroll: ScrollContainer = $RewardOverlay/CenterContainer/RewardPanel/RewardMargin/RewardVBox/RewardDeckScroll
@onready var reward_deck_list: VBoxContainer = $RewardOverlay/CenterContainer/RewardPanel/RewardMargin/RewardVBox/RewardDeckScroll/RewardDeckList
@onready var reward_panel: PanelContainer = $RewardOverlay/CenterContainer/RewardPanel
@onready var score_overlay: Control = $ScoreOverlay
@onready var score_summary_label: Label = $ScoreOverlay/CenterContainer/ScorePanel/ScoreMargin/ScoreVBox/ScoreSummaryLabel
@onready var score_rank_label: Label = $ScoreOverlay/CenterContainer/ScorePanel/ScoreMargin/ScoreVBox/ScoreRankLabel
@onready var score_list: VBoxContainer = $ScoreOverlay/CenterContainer/ScorePanel/ScoreMargin/ScoreVBox/ScoreList
@onready var score_continue_button: Button = $ScoreOverlay/CenterContainer/ScorePanel/ScoreMargin/ScoreVBox/ScoreContinueButton
@onready var card_detail_panel: PanelContainer = $CardDetailPanel
@onready var card_detail_name: Label = $CardDetailPanel/CardDetailMargin/CardDetailVBox/CardDetailName
@onready var card_detail_cost: Label = $CardDetailPanel/CardDetailMargin/CardDetailVBox/CardDetailCost
@onready var card_detail_desc: Label = $CardDetailPanel/CardDetailMargin/CardDetailVBox/CardDetailDesc
@onready var sfx_attack: AudioStreamPlayer = $SfxAttack
@onready var sfx_block: AudioStreamPlayer = $SfxBlock
@onready var sfx_reward: AudioStreamPlayer = $SfxReward

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
var reward_mode := "none"
var last_reward_mode := ""
var reward_cards: Array = []
var reward_overlay_active := false
var reward_overlay_tween: Tween
var hand_slot_tweens: Dictionary = {}
var route_overlay_active := false
var supply_available := false
var route_mode := "none"
var score_overlay_active := false
var combat_damage_dealt := 0
var combat_damage_taken := 0
var combat_attack_count := 0
var combat_difficulty := "normal"

func _ready() -> void:
	story_label.text = "你踏上 %s 的山道，魔物在雾中伺机。" % GameData.MOUNTAIN_NAME
	back_button.pressed.connect(_on_back_pressed)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	next_button.pressed.connect(_on_next_pressed)
	reward_upgrade_button.pressed.connect(_on_reward_upgrade_pressed)
	reward_remove_button.pressed.connect(_on_reward_remove_pressed)
	reward_heal_button.pressed.connect(_on_reward_heal_pressed)
	reward_draft_button.pressed.connect(_on_reward_draft_pressed)
	reward_skip_button.pressed.connect(_on_reward_skip_pressed)
	route_supply_button.pressed.connect(_on_route_supply_pressed)
	route_challenge_button.pressed.connect(_on_route_challenge_pressed)
	difficulty_normal_button.pressed.connect(_on_difficulty_selected.bind("normal"))
	difficulty_hard_button.pressed.connect(_on_difficulty_selected.bind("hard"))
	difficulty_elite_button.pressed.connect(_on_difficulty_selected.bind("elite"))
	score_continue_button.pressed.connect(_on_score_continue_pressed)
	card_detail_panel.visible = false
	reward_overlay.modulate.a = 0.0
	reward_overlay_active = reward_overlay.visible
	route_overlay.visible = false
	route_overlay_active = route_overlay.visible
	score_overlay.visible = false
	score_overlay_active = score_overlay.visible
	_start_encounter()

func _start_encounter() -> void:
	combat_over = false
	run_complete = false
	reward_mode = "none"
	last_reward_mode = ""
	reward_cards.clear()
	route_mode = "none"
	supply_available = false
	card_detail_panel.visible = false
	combat_damage_dealt = 0
	combat_damage_taken = 0
	combat_attack_count = 0
	player_block = 0
	energy = RunState.energy_max
	draw_pile = RunState.deck.duplicate(true)
	draw_pile.shuffle()
	hand.clear()
	discard_pile.clear()
	enemy_data = RunState.start_encounter()
	combat_difficulty = RunState.next_difficulty
	enemy_hp = enemy_data.get("hp", 0)
	enemy_max_hp = enemy_hp
	enemy_block = 0
	enemy_attack_bonus = 0
	_apply_difficulty_to_enemy(RunState.next_difficulty)
	RunState.next_difficulty = "normal"
	enemy_intents = enemy_data.get("intents", [])
	if enemy_intents.is_empty():
		enemy_intents = [
			{"type": "attack", "value": int(enemy_data.get("attack", 0)), "text": "攻击"}
		]
	intent_index = 0
	_set_next_intent()
	pending_event = {}
	next_step = "encounter"
	player_portrait.texture = load(GameData.PLAYER_PORTRAIT)
	var enemy_portrait_path: String = str(enemy_data.get("portrait", ""))
	if not enemy_portrait_path.is_empty():
		enemy_portrait.texture = load(enemy_portrait_path)
	RunState.log_event("遭遇魔物：%s" % enemy_data.get("name", "未知魔物"))
	if RunState.next_encounter_first_strike:
		var strike_damage := GameData.FIRST_STRIKE_DAMAGE + RunState.next_encounter_first_strike_bonus
		enemy_hp = max(enemy_hp - strike_damage, 0)
		RunState.next_encounter_first_strike = false
		RunState.next_encounter_first_strike_bonus = 0
		result_label.text = "你先手出击，对魔物造成%d点伤害。" % strike_damage
		RunState.log_event("先手出击造成%d点伤害。" % strike_damage)
	else:
		result_label.text = "遭遇了新的魔物，准备战斗。"
	_draw_cards(HAND_SIZE)
	_update_ui()
	RunState.save_run()

func _update_ui() -> void:
	var progress_current: int = int(min(RunState.encounters_completed + 1, RunState.max_encounters))
	progress_label.text = "攀登进度：%d / %d" % [progress_current, RunState.max_encounters]
	enemy_name_label.text = "敌人：%s" % enemy_data.get("name", "未知魔物")
	enemy_hp_label.text = "敌人生命：%d / %d" % [enemy_hp, enemy_max_hp]
	enemy_hp_bar.max_value = max(enemy_max_hp, 1)
	enemy_hp_bar.value = enemy_hp
	enemy_block_label.text = "敌人护甲：%d" % enemy_block
	enemy_intent_label.text = "意图：%s" % _intent_display(current_intent)
	enemy_desc_label.text = enemy_data.get("desc", "")
	var intent_color := _intent_color(current_intent)
	enemy_intent_label.add_theme_color_override("font_color", intent_color)
	enemy_intent_swatch.color = intent_color
	enemy_intent_icon.texture = _intent_icon(current_intent)
	enemy_intent_icon.modulate = intent_color
	player_hp_label.text = "生命：%d / %d" % [RunState.player_hp, RunState.player_max_hp]
	player_hp_bar.max_value = max(RunState.player_max_hp, 1)
	player_hp_bar.value = RunState.player_hp
	player_block_label.text = "护甲：%d" % player_block
	energy_label.text = "能量：%d / %d" % [energy, RunState.energy_max]
	draw_label.text = "抽牌堆：%d" % draw_pile.size()
	discard_label.text = "弃牌堆：%d" % discard_pile.size()
	end_turn_button.disabled = combat_over
	var show_rewards := combat_over and not run_complete and next_step == "reward_options"
	var show_route := combat_over and not run_complete and next_step == "route"
	var show_score := combat_over and run_complete
	_set_reward_overlay_visible(show_rewards)
	_set_route_overlay_visible(show_route)
	_set_score_overlay_visible(show_score)
	next_button.visible = combat_over and not show_rewards and not show_route
	if combat_over and next_button.visible:
		if run_complete:
			next_button.text = "返回主菜单"
		elif next_step == "event":
			next_button.text = "处理事件"
		else:
			next_button.text = "继续攀登"
	_refresh_hand()
	if show_rewards:
		_refresh_reward_ui()
	if show_route:
		_update_route_ui()
	if show_score:
		_refresh_score_ui()

func _refresh_hand() -> void:
	for tween in hand_slot_tweens.values():
		if tween:
			tween.kill()
	hand_slot_tweens.clear()
	for child in hand_container.get_children():
		child.queue_free()
	for index in hand.size():
		var card_id: String = hand[index]
		var card_data := GameData.get_card_data(card_id, RunState.is_upgraded(card_id))
		var collapsed_scale := HAND_COLLAPSED_HEIGHT / HAND_CARD_SIZE.y
		var slot := Control.new()
		slot.custom_minimum_size = Vector2(HAND_CARD_SIZE.x * collapsed_scale, HAND_COLLAPSED_HEIGHT)
		slot.clip_contents = true
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hand_container.add_child(slot)
		var widget: CardWidget = CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.scale = Vector2(collapsed_scale, collapsed_scale)
		widget.position = Vector2(0, HAND_COLLAPSED_HEIGHT - (HAND_CARD_SIZE.y * collapsed_scale))
		widget.clicked.connect(_on_hand_card_clicked.bind(index))
		widget.hovered.connect(_on_hand_card_hovered.bind(slot))
		widget.unhovered.connect(_on_hand_card_unhovered.bind(slot))
		slot.add_child(widget)

func _draw_cards(count: int) -> void:
	for i in range(count):
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile.duplicate(true)
			discard_pile.clear()
			draw_pile.shuffle()
		hand.append(draw_pile.pop_back())

func _on_hand_card_hovered(card_id: String, slot: Control) -> void:
	_on_card_hovered(card_id)
	_set_hand_slot_expanded(slot, true)

func _on_hand_card_unhovered(slot: Control) -> void:
	_on_card_unhovered()
	_set_hand_slot_expanded(slot, false)

func _set_hand_slot_expanded(slot: Control, expanded: bool) -> void:
	if not slot:
		return
	var tween: Tween = hand_slot_tweens.get(slot)
	if tween:
		tween.kill()
	var widget := slot.get_child(0) as Control
	if not widget:
		return
	var collapsed_scale := HAND_COLLAPSED_HEIGHT / HAND_CARD_SIZE.y
	var expanded_scale := HAND_EXPANDED_HEIGHT / HAND_CARD_SIZE.y
	var target_scale := expanded_scale if expanded else collapsed_scale
	var target_height := HAND_CARD_SIZE.y * target_scale
	var target_position := Vector2(0, HAND_COLLAPSED_HEIGHT - target_height)
	slot.clip_contents = not expanded
	tween = create_tween()
	tween.tween_property(widget, "scale", Vector2(target_scale, target_scale), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(widget, "position", target_position, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if expanded:
		slot.z_index = 20
	else:
		tween.tween_callback(func():
			if is_instance_valid(slot):
				slot.z_index = 0
		)
	hand_slot_tweens[slot] = tween

func _on_hand_card_clicked(card_id: String, index: int) -> void:
	if combat_over:
		return
	var card_data := GameData.get_card_data(card_id, RunState.is_upgraded(card_id))
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
	RunState.save_run()

func _apply_card_effect(card_data: Dictionary) -> void:
	var damage := int(card_data.get("damage", 0))
	if damage > 0:
		combat_attack_count += 1
		var blocked: int = min(enemy_block, damage)
		enemy_block -= blocked
		var actual_damage: int = damage - blocked
		if actual_damage > 0:
			enemy_hp = max(enemy_hp - actual_damage, 0)
			combat_damage_dealt += actual_damage
			result_label.text = "你对魔物造成%d点伤害。" % actual_damage
			sfx_attack.play()
			_play_enemy_hit_effect()
		else:
			result_label.text = "敌人的护甲挡住了攻击。"
	var block := int(card_data.get("block", 0))
	if block > 0:
		player_block += block
		result_label.text = "你获得%d点护甲。" % block
		sfx_block.play()
	var draw_count := int(card_data.get("draw", 0))
	if draw_count > 0:
		_draw_cards(draw_count)
		result_label.text = "你抽了%d张牌。" % draw_count
	var heal := int(card_data.get("heal", 0))
	if heal > 0:
		var before: int = RunState.player_hp
		RunState.player_hp = min(RunState.player_hp + heal, RunState.player_max_hp)
		var healed: int = RunState.player_hp - before
		result_label.text = "你恢复了%d点生命。" % healed
	if bool(card_data.get("initiative", false)):
		RunState.next_encounter_first_strike = true
		RunState.next_encounter_first_strike_bonus += int(card_data.get("initiative_bonus", 0))
		result_label.text = "你踏勘山势，下场战斗将先手出击。"
		RunState.log_event("踏勘山势，获得先手优势。")

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
	energy = RunState.energy_max
	_draw_cards(HAND_SIZE)
	result_label.text = "魔物行动结束，你继续攀登。"
	_update_ui()
	RunState.save_run()

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
		RunState.log_event("你在山道上倒下。")
		RunState.finalize_run_score()
		RunState.run_active = false
		RunState.save_run()
		return
	if not combat_over:
		_set_next_intent()

func _check_enemy_defeat() -> void:
	if enemy_hp <= 0:
		combat_over = true
		var combat_score := _calculate_combat_score()
		RunState.add_combat_score(combat_score)
		run_complete = RunState.complete_encounter()
		if run_complete:
			result_label.text = "你征服了 %s，登顶通关！" % GameData.MOUNTAIN_NAME
			RunState.log_event("登顶通关，征服 %s。" % GameData.MOUNTAIN_NAME)
			RunState.finalize_run_score()
			RunState.run_active = false
			RunState.save_run()
		else:
			RunState.log_event("击退了 %s。" % enemy_data.get("name", "魔物"))
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
			_enter_route_selection()
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
		combat_damage_taken += damage
		result_label.text = text_template % damage
		sfx_attack.play()
		_play_player_hit_effect()
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
		_enter_route_selection()
		return
	next_step = "event"
	result_label.text = "遭遇事件：%s - %s" % [
		pending_event.get("name", "事件"),
		pending_event.get("desc", "")
	]
	RunState.log_event("触发事件：%s。" % pending_event.get("name", "事件"))

func _apply_event(event_data: Dictionary) -> void:
	var effect: String = str(event_data.get("effect", ""))
	var value: int = int(event_data.get("value", 0))
	match effect:
		"heal":
			var before: int = RunState.player_hp
			RunState.player_hp = min(RunState.player_hp + value, RunState.player_max_hp)
			var healed: int = RunState.player_hp - before
			result_label.text = "你恢复了%d点生命。" % healed
			RunState.log_event("事件恢复生命 %d。" % healed)
		"damage":
			RunState.player_hp = max(RunState.player_hp - value, 0)
			result_label.text = "你受到%d点伤害。" % value
			RunState.log_event("事件受到伤害 %d。" % value)
			if RunState.player_hp <= 0:
				run_complete = true
				result_label.text = "你在山道上倒下，征途告终。"
				RunState.log_event("事件中倒下。")
		"card":
			var card_id: String = GameData.get_random_card_id()
			if card_id.is_empty():
				result_label.text = "你未能找到合适的补给。"
			else:
				RunState.deck.append(card_id)
				var card_name: String = str(GameData.get_card_data(card_id, false).get("name", "新卡牌"))
				result_label.text = "你获得了一张卡牌：%s。" % card_name
				RunState.log_event("事件获得卡牌：%s。" % card_name)
		_:
			result_label.text = "事件无事发生。"
			RunState.log_event("事件无事发生。")
	if RunState.player_hp > 0 and not run_complete:
		_enter_route_selection()

func _enter_route_selection() -> void:
	next_step = "route"
	route_mode = "route"
	supply_available = randf() <= GameData.SUPPLY_CHANCE
	if supply_available:
		route_info_label.text = "你发现一处补给点，选择前进路线。"
	else:
		route_info_label.text = "补给点未出现，只能继续挑战。"
	route_supply_button.visible = supply_available
	route_supply_button.disabled = not supply_available
	_update_route_ui()
	_set_route_overlay_visible(true)

func _update_route_ui() -> void:
	difficulty_panel.visible = route_mode == "difficulty"

func _on_route_supply_pressed() -> void:
	if not supply_available:
		return
	route_mode = "supply"
	_set_route_overlay_visible(false)
	_enter_supply_options()

func _on_route_challenge_pressed() -> void:
	route_mode = "difficulty"
	route_info_label.text = "请选择挑战难度。"
	_update_route_ui()

func _on_difficulty_selected(difficulty: String) -> void:
	RunState.next_difficulty = difficulty
	RunState.save_run()
	route_mode = "none"
	_set_route_overlay_visible(false)
	result_label.text = "你选择了%s挑战。" % _difficulty_display(difficulty)
	RunState.log_event("选择挑战难度：%s。" % _difficulty_display(difficulty))
	_start_encounter()

func _difficulty_display(difficulty: String) -> String:
	var settings := RunState.get_difficulty_settings(difficulty)
	return str(settings.get("label", "普通"))

func _enter_supply_options() -> void:
	next_step = "reward_options"
	reward_mode = "supply"
	last_reward_mode = ""
	reward_cards.clear()
	_refresh_reward_ui()
	_set_route_overlay_visible(false)
	_set_reward_overlay_visible(true)
	RunState.save_run()

func _refresh_reward_ui() -> void:
	reward_options.visible = reward_mode == "supply"
	reward_upgrade_button.visible = reward_mode == "supply"
	reward_remove_button.visible = reward_mode == "supply"
	reward_heal_button.visible = reward_mode == "supply"
	reward_draft_button.visible = reward_mode == "supply"
	reward_skip_button.visible = reward_mode == "supply"
	var show_choices := reward_mode in ["upgrade", "remove", "supply_draft"]
	reward_choice_label.visible = show_choices
	reward_choice_scroll.visible = reward_mode == "supply_draft"
	reward_deck_scroll.visible = reward_mode in ["upgrade", "remove"]
	match reward_mode:
		"upgrade":
			reward_choice_label.text = "选择一张卡牌强化"
		"remove":
			reward_choice_label.text = "选择一张卡牌移除"
		"supply_draft":
			reward_choice_label.text = "选择一张补给卡牌"
		_:
			reward_choice_label.text = ""
	if reward_mode != last_reward_mode:
		if reward_mode in ["upgrade", "remove"]:
			_populate_reward_deck()
		elif reward_mode == "supply_draft":
			_populate_supply_cards()
		last_reward_mode = reward_mode

func _set_reward_overlay_visible(active: bool) -> void:
	if active == reward_overlay_active:
		return
	reward_overlay_active = active
	if reward_overlay_tween:
		reward_overlay_tween.kill()
	if active:
		reward_overlay.visible = true
		reward_overlay.modulate.a = 0.0
		reward_panel.scale = Vector2(0.96, 0.96)
		reward_overlay_tween = create_tween()
		reward_overlay_tween.tween_property(reward_overlay, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		reward_overlay_tween.tween_property(reward_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		reward_overlay_tween = create_tween()
		reward_overlay_tween.tween_property(reward_overlay, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		reward_overlay_tween.tween_callback(func(): reward_overlay.visible = false)

func _set_route_overlay_visible(active: bool) -> void:
	if active == route_overlay_active:
		return
	route_overlay_active = active
	route_overlay.visible = active

func _set_score_overlay_visible(active: bool) -> void:
	if active == score_overlay_active:
		return
	score_overlay_active = active
	score_overlay.visible = active

func _refresh_score_ui() -> void:
	score_summary_label.text = "本次得分：%d" % RunState.last_run_score
	if RunState.last_run_rank > 0:
		score_rank_label.text = "当前排名：第%d名" % RunState.last_run_rank
	else:
		score_rank_label.text = "当前排名：-"
	_clear_container(score_list)
	for index in RunState.leaderboard.size():
		var entry: Dictionary = RunState.leaderboard[index]
		var score_value := int(entry.get("score", 0))
		var time_text := str(entry.get("time", ""))
		var label := Label.new()
		label.text = "%d. %d 分 %s" % [index + 1, score_value, time_text]
		score_list.add_child(label)

func _on_score_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _calculate_combat_score() -> int:
	var base_score := int(enemy_data.get("score", 0))
	var settings := RunState.get_difficulty_settings(combat_difficulty)
	var difficulty_mult := float(settings.get("score_mult", 1.0))
	var damage_taken_cap := RunState.player_max_hp * 3
	var damage_taken_score: float = float(min(combat_damage_taken, damage_taken_cap)) * 0.3
	var score: float = float(base_score) * difficulty_mult
	score += combat_damage_dealt * 0.6
	score += damage_taken_score
	score += combat_attack_count * 2
	score += RunState.player_hp * 2
	return int(round(score))

func _apply_difficulty_to_enemy(difficulty: String) -> void:
	var settings := RunState.get_difficulty_settings(difficulty)
	var hp_mult := float(settings.get("hp_mult", 1.0))
	var power_mult := float(settings.get("power_mult", 1.0))
	if hp_mult != 1.0:
		enemy_hp = int(round(enemy_hp * hp_mult))
		enemy_max_hp = enemy_hp
		enemy_data["hp"] = enemy_hp
	if enemy_data.has("attack"):
		enemy_data["attack"] = int(round(int(enemy_data.get("attack", 0)) * power_mult))
	var intents: Array = enemy_data.get("intents", [])
	for index in intents.size():
		var intent: Dictionary = intents[index]
		if intent.has("value"):
			intent["value"] = int(round(int(intent.get("value", 0)) * power_mult))
		if intent.has("heal"):
			intent["heal"] = int(round(int(intent.get("heal", 0)) * power_mult))
		intents[index] = intent
	enemy_data["intents"] = intents

func _populate_supply_cards() -> void:
	_clear_container(reward_choice_container)
	reward_cards = _roll_reward_cards(2)
	for card_id in reward_cards:
		var card_data := GameData.get_card_data(card_id, false)
		var widget: CardWidget = CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.clicked.connect(_on_reward_card_selected)
		widget.hovered.connect(_on_card_hovered)
		widget.unhovered.connect(_on_card_unhovered)
		reward_choice_container.add_child(widget)

func _roll_reward_cards(count: int = 3) -> Array:
	var card_ids: Array = GameData.all_card_ids()
	card_ids.shuffle()
	var result: Array = []
	for i in min(count, card_ids.size()):
		result.append(str(card_ids[i]))
	return result

func _populate_reward_deck() -> void:
	_clear_container(reward_deck_list)
	var any_available := false
	for index in RunState.deck.size():
		var card_id: String = RunState.deck[index]
		if reward_mode == "upgrade" and RunState.is_upgraded(card_id):
			continue
		any_available = true
		var card_data := GameData.get_card_data(card_id, RunState.is_upgraded(card_id))
		var widget: CardWidget = CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.clicked.connect(_on_reward_deck_card_selected.bind(index))
		widget.hovered.connect(_on_card_hovered)
		widget.unhovered.connect(_on_card_unhovered)
		reward_deck_list.add_child(widget)
	if not any_available:
		if reward_mode == "upgrade":
			result_label.text = "没有可强化的卡牌。"
		else:
			result_label.text = "牌组为空，无法移除。"
		reward_mode = "supply"
		last_reward_mode = ""
		_refresh_reward_ui()

func _on_reward_upgrade_pressed() -> void:
	reward_mode = "upgrade"
	last_reward_mode = ""
	_refresh_reward_ui()

func _on_reward_remove_pressed() -> void:
	reward_mode = "remove"
	last_reward_mode = ""
	_refresh_reward_ui()

func _on_reward_skip_pressed() -> void:
	result_label.text = "你放弃了补给。"
	RunState.log_event("放弃了补给。")
	sfx_reward.play()
	_start_encounter()

func _on_reward_heal_pressed() -> void:
	var before: int = RunState.player_hp
	RunState.player_hp = min(RunState.player_hp + GameData.SUPPLY_HEAL_AMOUNT, RunState.player_max_hp)
	var healed: int = RunState.player_hp - before
	result_label.text = "补给休整，恢复%d点生命。" % healed
	RunState.log_event("补给休整恢复%d点生命。" % healed)
	sfx_reward.play()
	_start_encounter()

func _on_reward_draft_pressed() -> void:
	reward_mode = "supply_draft"
	last_reward_mode = ""
	_refresh_reward_ui()

func _on_reward_card_selected(card_id: String) -> void:
	RunState.deck.append(card_id)
	var card_name: String = str(GameData.get_card_data(card_id, false).get("name", "新卡牌"))
	result_label.text = "补给中获得一张卡牌：%s。" % card_name
	RunState.log_event("补给获得新卡：%s。" % card_name)
	sfx_reward.play()
	_start_encounter()

func _on_reward_deck_card_selected(card_id: String, index: int) -> void:
	if reward_mode == "remove":
		if index >= 0 and index < RunState.deck.size():
			RunState.deck.remove_at(index)
		var card_name: String = str(GameData.get_card_data(card_id, RunState.is_upgraded(card_id)).get("name", "卡牌"))
		result_label.text = "已移除卡牌：%s。" % card_name
		RunState.log_event("移除卡牌：%s。" % card_name)
		sfx_reward.play()
		_start_encounter()
		return
	if reward_mode == "upgrade":
		RunState.upgrade_card(card_id)
		var card_name: String = str(GameData.get_card_data(card_id, true).get("name", "卡牌"))
		result_label.text = "已强化卡牌：%s。" % card_name
		RunState.log_event("强化卡牌：%s。" % card_name)
		sfx_reward.play()
		_start_encounter()
		return

func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

func _play_enemy_hit_effect() -> void:
	_flash_rect(enemy_hit_flash, Color(1, 0.3, 0.3, 0.6))
	_pulse_node(enemy_portrait, 1.05)
	_play_hit_fx(enemy_hit_fx)

func _play_player_hit_effect() -> void:
	_flash_rect(player_hit_flash, Color(1, 0.4, 0.4, 0.6))
	_pulse_node(player_portrait, 1.05)
	_play_hit_fx(player_hit_fx)

func _pulse_node(node: CanvasItem, scale_factor: float) -> void:
	var tween := create_tween()
	tween.tween_property(node, "scale", Vector2(scale_factor, scale_factor), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _flash_rect(rect: ColorRect, color: Color) -> void:
	rect.color = color
	rect.visible = true
	var tween := create_tween()
	tween.tween_property(rect, "color:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): rect.visible = false)

func _play_hit_fx(fx: TextureRect) -> void:
	if not fx:
		return
	fx.visible = true
	fx.modulate.a = 0.0
	fx.scale = Vector2(0.8, 0.8)
	fx.rotation = randf_range(-0.2, 0.2)
	var tween := create_tween()
	tween.tween_property(fx, "modulate:a", 1.0, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(fx, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(fx, "modulate:a", 0.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): fx.visible = false)

func _on_card_hovered(card_id: String) -> void:
	var card_data := GameData.get_card_data(card_id, RunState.is_upgraded(card_id))
	if card_data.is_empty():
		return
	card_detail_name.text = str(card_data.get("name", "卡牌"))
	card_detail_cost.text = "费用 %s" % str(card_data.get("cost", 0))
	card_detail_desc.text = str(card_data.get("desc", ""))
	card_detail_panel.visible = true

func _on_card_unhovered() -> void:
	card_detail_panel.visible = false

func _intent_color(intent: Dictionary) -> Color:
	var intent_type: String = str(intent.get("type", ""))
	match intent_type:
		"attack":
			return Color(0.9, 0.35, 0.35)
		"multi_attack":
			return Color(0.95, 0.55, 0.2)
		"guard":
			return Color(0.4, 0.7, 0.95)
		"charge":
			return Color(0.95, 0.85, 0.3)
		"drain":
			return Color(0.75, 0.5, 0.95)
	return Color(1, 1, 1)

func _intent_icon(intent: Dictionary) -> Texture2D:
	var intent_type: String = str(intent.get("type", "attack"))
	return INTENT_ICONS.get(intent_type, INTENT_ICONS["attack"])
