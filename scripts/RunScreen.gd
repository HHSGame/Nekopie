extends Control

const CARD_WIDGET_SCENE := preload("res://scenes/CardWidget.tscn")
const HAND_DRAW_FIRST := 5
const HAND_DRAW_PER_TURN := 3
const HAND_LIMIT := 5
const ENEMY_HAND_SIZE := 3
const MAX_BATTLE_LOG_LINES := 40
const WEAK_DAMAGE_MULT := 0.75
const VULNERABLE_DAMAGE_MULT := 1.5
const HAND_CARD_SIZE := Vector2(220, 260)
const HAND_COLLAPSED_HEIGHT := 72.0
const HAND_EXPANDED_HEIGHT := 200.0
const ENEMY_WINDUP_DELAY := 0.25
const ENEMY_ACTION_DELAY := 0.35
const ENEMY_IDLE_DELAY := 0.2
const SHOP_OFFER_COUNT := 3
const SHOP_REFRESH_COST := 40
const INTENT_ICONS := {
	"attack": preload("res://icons/intent_attack.svg"),
	"multi_attack": preload("res://icons/intent_multi.svg"),
	"guard": preload("res://icons/intent_guard.svg"),
	"charge": preload("res://icons/intent_charge.svg"),
	"drain": preload("res://icons/intent_drain.svg"),
	"heal": preload("res://icons/intent_heal.svg"),
	"debuff": preload("res://icons/intent_debuff.svg"),
	"attack_debuff": preload("res://icons/intent_debuff.svg")
}

@onready var story_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/BattleCenterColumn/StoryPanel/StoryMargin/StoryLabel
@onready var progress_label: Label = $MarginContainer/RootVBox/HandDock/HandMargin/HandVBox/Actions/ProgressPanel/ProgressMargin/ProgressLabel
@onready var enemy_name_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyNameLabel
@onready var enemy_hp_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyStatsPanel/EnemyStatsMargin/EnemyStatsVBox/EnemyHpRow/EnemyHpLabel
@onready var enemy_hp_bar: ProgressBar = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyStatsPanel/EnemyStatsMargin/EnemyStatsVBox/EnemyHpBar
@onready var enemy_block_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyStatsPanel/EnemyStatsMargin/EnemyStatsVBox/EnemyBlockRow/EnemyBlockLabel
@onready var enemy_status_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyPortraitPanel/EnemyStatusOverlay/EnemyStatusLabel
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
@onready var player_status_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerPortraitPanel/PlayerStatusOverlay/PlayerStatusLabel
@onready var player_buff_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerPortraitPanel/PlayerStatusOverlay/PlayerBuffLabel
@onready var energy_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerEnergyRow/EnergyLabel
@onready var draw_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerDeckRow/DrawLabel
@onready var discard_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerDeckRow/DiscardLabel
@onready var player_hp_bar: ProgressBar = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerHpBar
@onready var result_label: RichTextLabel = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/BattleCenterColumn/BattleLogPanel/BattleLogMargin/ResultLabel
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
@onready var shop_overlay: Control = $ShopOverlay
@onready var shop_points_label: Label = $ShopOverlay/CenterContainer/ShopPanel/ShopMargin/ShopVBox/ShopPointsLabel
@onready var shop_info_label: Label = $ShopOverlay/CenterContainer/ShopPanel/ShopMargin/ShopVBox/ShopInfoLabel
@onready var shop_choice_scroll: ScrollContainer = $ShopOverlay/CenterContainer/ShopPanel/ShopMargin/ShopVBox/ShopChoiceScroll
@onready var shop_choice_container: HBoxContainer = $ShopOverlay/CenterContainer/ShopPanel/ShopMargin/ShopVBox/ShopChoiceScroll/ShopChoiceContainer
@onready var shop_refresh_button: Button = $ShopOverlay/CenterContainer/ShopPanel/ShopMargin/ShopVBox/ShopActions/ShopRefreshButton
@onready var shop_skip_button: Button = $ShopOverlay/CenterContainer/ShopPanel/ShopMargin/ShopVBox/ShopActions/ShopSkipButton
@onready var shop_panel: PanelContainer = $ShopOverlay/CenterContainer/ShopPanel
@onready var discard_overlay: Control = $DiscardOverlay
@onready var discard_info_label: Label = $DiscardOverlay/CenterContainer/DiscardPanel/DiscardMargin/DiscardVBox/DiscardInfoLabel
@onready var discard_choice_scroll: ScrollContainer = $DiscardOverlay/CenterContainer/DiscardPanel/DiscardMargin/DiscardVBox/DiscardChoiceScroll
@onready var discard_choice_container: HBoxContainer = $DiscardOverlay/CenterContainer/DiscardPanel/DiscardMargin/DiscardVBox/DiscardChoiceScroll/DiscardChoiceContainer
@onready var discard_confirm_button: Button = $DiscardOverlay/CenterContainer/DiscardPanel/DiscardMargin/DiscardVBox/DiscardActions/DiscardConfirmButton
@onready var discard_panel: PanelContainer = $DiscardOverlay/CenterContainer/DiscardPanel
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
var enemy_draw_pile: Array = []
var enemy_hand: Array = []
var enemy_discard_pile: Array = []
var enemy_energy := 0
var enemy_intent_card: Dictionary = {}
var enemy_power_mult := 1.0
var player_weak_turns := 0
var player_vulnerable_turns := 0
var player_next_attack_mult := 1.0
var player_next_attack_bonus := 0
var player_next_attack_pierce := false
var player_counter_ratio := 0.0
var player_nullify_count := 0
var player_damage_draw := 0
var player_bleed_on_attack := 0
var player_attack_bonus_on_attack := 0
var player_damage_bonus_turn := 0
var player_block_disabled := false
var player_next_card_cost_delta := 0
var player_skip_enemy_turn := false
var player_attack_chain := 0
var player_defend_chain := 0
var power_first_attack_draw := 0
var power_first_damage_block := 0
var power_bleed_on_damage := 0
var power_first_attack_draw_used := false
var power_first_damage_block_used := false
var equip_attack_bonus := 0
var equip_damage_reduction := 0
var equip_attack_chain_draw := 0
var equip_defend_chain_block := 0
var equip_block_on_damage := 0
var equip_bleed_bonus_per_stack := 0
var enemy_bleed := 0
var enemy_poison := 0
var enemy_burn := 0
var enemy_block_gain_reduction := 0
var combat_over := false
var run_complete := false
var next_step := "encounter"
var reward_mode := "none"
var last_reward_mode := ""
var reward_cards: Array = []
var reward_overlay_active := false
var reward_overlay_tween: Tween
var shop_overlay_active := false
var shop_overlay_tween: Tween
var shop_offer_cards: Array = []
var shop_offer_costs: Dictionary = {}
var battle_log: Array = []
var turn_index := 1
var hand_slot_tweens: Dictionary = {}
var route_overlay_active := false
var supply_available := false
var route_mode := "none"
var score_overlay_active := false
var combat_damage_dealt := 0
var combat_damage_taken := 0
var combat_attack_count := 0
var combat_difficulty := "normal"
var enemy_acting := false
var turn_locked := false
var discard_overlay_active := false
var discard_required := 0
var discard_selection: Array = []
var discard_overlay_tween: Tween
var discard_card_widgets: Dictionary = {}
var discard_locked_indices: Dictionary = {}

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
	shop_refresh_button.pressed.connect(_on_shop_refresh_pressed)
	shop_skip_button.pressed.connect(_on_shop_skip_pressed)
	discard_confirm_button.pressed.connect(_on_discard_confirm_pressed)
	route_supply_button.pressed.connect(_on_route_supply_pressed)
	route_challenge_button.pressed.connect(_on_route_challenge_pressed)
	difficulty_normal_button.pressed.connect(_on_difficulty_selected.bind("normal"))
	difficulty_hard_button.pressed.connect(_on_difficulty_selected.bind("hard"))
	difficulty_elite_button.pressed.connect(_on_difficulty_selected.bind("elite"))
	score_continue_button.pressed.connect(_on_score_continue_pressed)
	card_detail_panel.visible = false
	reward_overlay.modulate.a = 0.0
	reward_overlay_active = reward_overlay.visible
	shop_overlay.visible = false
	shop_overlay.modulate.a = 0.0
	shop_overlay_active = shop_overlay.visible
	discard_overlay.visible = false
	discard_overlay.modulate.a = 0.0
	discard_overlay_active = discard_overlay.visible
	route_overlay.visible = false
	route_overlay_active = route_overlay.visible
	score_overlay.visible = false
	score_overlay_active = score_overlay.visible
	_start_encounter()

func _reset_battle_log() -> void:
	battle_log.clear()
	result_label.text = ""
	_scroll_battle_log_to_bottom()

func _append_battle_log(message: String) -> void:
	if message.is_empty():
		return
	battle_log.append(message)
	if battle_log.size() > MAX_BATTLE_LOG_LINES:
		battle_log = battle_log.slice(battle_log.size() - MAX_BATTLE_LOG_LINES, MAX_BATTLE_LOG_LINES)
	result_label.text = "\n".join(battle_log)
	_scroll_battle_log_to_bottom()

func _scroll_battle_log_to_bottom() -> void:
	if not result_label:
		return
	var line_count := result_label.get_line_count()
	result_label.call_deferred("scroll_to_line", max(line_count - 1, 0))

func _player_status_text() -> String:
	return _player_status_summary()

func _player_status_summary() -> String:
	var parts: Array = []
	if player_weak_turns > 0:
		parts.append("弱化%d" % player_weak_turns)
	if player_vulnerable_turns > 0:
		parts.append("易伤%d" % player_vulnerable_turns)
	if player_next_attack_mult > 1.0:
		parts.append("蓄力x%.1f" % player_next_attack_mult)
	if player_next_attack_bonus > 0:
		parts.append("下次攻击+%d" % player_next_attack_bonus)
	if player_next_attack_pierce:
		parts.append("下次穿刺")
	if player_counter_ratio > 0.0:
		parts.append("反击%d%%" % int(round(player_counter_ratio * 100.0)))
	if player_nullify_count > 0:
		parts.append("护幕%d" % player_nullify_count)
	if player_damage_draw > 0:
		parts.append("受伤抽牌+%d" % player_damage_draw)
	if player_bleed_on_attack > 0:
		parts.append("攻击叠流血+%d" % player_bleed_on_attack)
	if player_attack_bonus_on_attack > 0:
		parts.append("连击伤害+%d" % player_attack_bonus_on_attack)
	if player_damage_bonus_turn > 0:
		parts.append("本回合伤害+%d" % player_damage_bonus_turn)
	if player_block_disabled:
		parts.append("禁用护甲")
	if player_next_card_cost_delta != 0:
		parts.append("下一卡费用%+d" % player_next_card_cost_delta)
	if player_skip_enemy_turn:
		parts.append("停滞")
	if parts.is_empty():
		return "无"
	return "，".join(parts)

func _player_buff_summary() -> String:
	var parts: Array = []
	if equip_attack_bonus > 0:
		parts.append("攻击+%d" % equip_attack_bonus)
	if equip_damage_reduction > 0:
		parts.append("减伤%d" % equip_damage_reduction)
	if equip_attack_chain_draw > 0:
		parts.append("连击抽牌%d" % equip_attack_chain_draw)
	if equip_defend_chain_block > 0:
		parts.append("连防护甲+%d" % equip_defend_chain_block)
	if equip_block_on_damage > 0:
		parts.append("受击护甲+%d" % equip_block_on_damage)
	if equip_bleed_bonus_per_stack > 0:
		parts.append("流血伤害+%d" % equip_bleed_bonus_per_stack)
	if power_first_attack_draw > 0:
		parts.append("首攻抽牌%d" % power_first_attack_draw)
	if power_first_damage_block > 0:
		parts.append("首伤护甲+%d" % power_first_damage_block)
	if power_bleed_on_damage > 0:
		parts.append("伤害附流血+%d" % power_bleed_on_damage)
	if parts.is_empty():
		return "无"
	return "，".join(parts)

func _enemy_status_summary() -> String:
	var parts: Array = []
	if enemy_bleed > 0:
		parts.append("流血%d" % enemy_bleed)
	if enemy_poison > 0:
		parts.append("中毒%d" % enemy_poison)
	if enemy_burn > 0:
		parts.append("灼烧%d" % enemy_burn)
	if enemy_attack_bonus > 0:
		parts.append("蓄力+%d" % enemy_attack_bonus)
	if enemy_block_gain_reduction > 0:
		parts.append("护甲获得-%d" % enemy_block_gain_reduction)
	if parts.is_empty():
		return "无"
	return "，".join(parts)

func _log_turn_start() -> void:
	_append_battle_log("回合%d开始：你HP %d/%d，敌人HP %d/%d" % [
		turn_index,
		RunState.player_hp,
		RunState.player_max_hp,
		enemy_hp,
		enemy_max_hp
	])

func _log_turn_end() -> void:
	_append_battle_log("回合%d结算：你HP %d/%d 护甲%d（%s），敌人HP %d/%d 护甲%d" % [
		turn_index,
		RunState.player_hp,
		RunState.player_max_hp,
		player_block,
		_player_status_text(),
		enemy_hp,
		enemy_max_hp,
		enemy_block
	])

func _start_encounter() -> void:
	combat_over = false
	run_complete = false
	reward_mode = "none"
	last_reward_mode = ""
	reward_cards.clear()
	route_mode = "none"
	supply_available = false
	card_detail_panel.visible = false
	enemy_acting = false
	turn_locked = false
	discard_required = 0
	discard_selection.clear()
	discard_card_widgets.clear()
	discard_locked_indices.clear()
	_set_discard_overlay_visible(false)
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
	player_weak_turns = 0
	player_vulnerable_turns = 0
	player_next_attack_mult = 1.0
	player_next_attack_bonus = 0
	player_next_attack_pierce = false
	player_counter_ratio = 0.0
	player_nullify_count = 0
	player_damage_draw = 0
	player_bleed_on_attack = 0
	player_attack_bonus_on_attack = 0
	player_damage_bonus_turn = 0
	player_block_disabled = false
	player_next_card_cost_delta = 0
	player_skip_enemy_turn = false
	player_attack_chain = 0
	player_defend_chain = 0
	power_first_attack_draw = 0
	power_first_damage_block = 0
	power_bleed_on_damage = 0
	power_first_attack_draw_used = false
	power_first_damage_block_used = false
	equip_attack_bonus = 0
	equip_damage_reduction = 0
	equip_attack_chain_draw = 0
	equip_defend_chain_block = 0
	equip_block_on_damage = 0
	equip_bleed_bonus_per_stack = 0
	enemy_bleed = 0
	enemy_poison = 0
	enemy_burn = 0
	enemy_block_gain_reduction = 0
	_apply_difficulty_to_enemy(RunState.next_difficulty)
	RunState.next_difficulty = "normal"
	enemy_draw_pile = Array(enemy_data.get("deck", [])).duplicate(true)
	enemy_draw_pile.shuffle()
	enemy_hand.clear()
	enemy_discard_pile.clear()
	_draw_enemy_cards(ENEMY_HAND_SIZE)
	_refresh_enemy_intent()
	next_step = "encounter"
	player_portrait.texture = load(GameData.PLAYER_PORTRAIT)
	var enemy_portrait_path: String = str(enemy_data.get("portrait", ""))
	if not enemy_portrait_path.is_empty():
		enemy_portrait.texture = load(enemy_portrait_path)
	RunState.log_event("遭遇魔物：%s" % enemy_data.get("name", "未知魔物"))
	_reset_battle_log()
	turn_index = 1
	_append_battle_log("遭遇魔物：%s（HP %d/%d）" % [
		enemy_data.get("name", "未知魔物"),
		enemy_hp,
		enemy_max_hp
	])
	_log_turn_start()
	if RunState.next_encounter_first_strike:
		var strike_damage := GameData.FIRST_STRIKE_DAMAGE + RunState.next_encounter_first_strike_bonus
		enemy_hp = max(enemy_hp - strike_damage, 0)
		RunState.next_encounter_first_strike = false
		RunState.next_encounter_first_strike_bonus = 0
		_append_battle_log("先手出击：造成%d点伤害（敌人HP %d/%d）。" % [
			strike_damage,
			enemy_hp,
			enemy_max_hp
		])
		RunState.log_event("先手出击造成%d点伤害。" % strike_damage)
	else:
		_append_battle_log("你稳住气息，准备战斗。")
	_draw_cards(HAND_DRAW_FIRST)
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
	enemy_status_label.text = "状态：%s" % _enemy_status_summary()
	enemy_intent_label.text = "意图：%s" % _enemy_card_display(enemy_intent_card)
	enemy_desc_label.text = enemy_data.get("desc", "")
	var intent_color := _enemy_card_color(enemy_intent_card)
	enemy_intent_label.add_theme_color_override("font_color", intent_color)
	enemy_intent_swatch.color = intent_color
	enemy_intent_icon.texture = _enemy_card_icon(enemy_intent_card)
	enemy_intent_icon.modulate = intent_color
	player_hp_label.text = "生命：%d / %d" % [RunState.player_hp, RunState.player_max_hp]
	player_hp_bar.max_value = max(RunState.player_max_hp, 1)
	player_hp_bar.value = RunState.player_hp
	player_block_label.text = "护甲：%d" % player_block
	player_status_label.text = "状态：%s" % _player_status_summary()
	player_buff_label.text = "装备/心法：%s" % _player_buff_summary()
	energy_label.text = "能量：%d / %d" % [energy, RunState.energy_max]
	draw_label.text = "抽牌堆：%d" % draw_pile.size()
	discard_label.text = "弃牌堆：%d" % discard_pile.size()
	end_turn_button.disabled = combat_over or enemy_acting or turn_locked or discard_overlay_active
	var show_rewards := combat_over and not run_complete and next_step == "reward_options"
	var show_route := combat_over and not run_complete and next_step == "route"
	var show_shop := combat_over and not run_complete and next_step == "shop"
	var show_score := combat_over and run_complete
	_set_reward_overlay_visible(show_rewards)
	_set_route_overlay_visible(show_route)
	_set_shop_overlay_visible(show_shop)
	_set_score_overlay_visible(show_score)
	next_button.visible = combat_over and not show_rewards and not show_route and not show_shop
	if combat_over and next_button.visible:
		if run_complete:
			next_button.text = "返回主菜单"
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
		var card_entry = hand[index]
		var card_id := RunState.get_card_id(card_entry)
		var card_data := GameData.get_card_data(card_id, RunState.get_card_upgrade_level(card_entry))
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
		widget.hovered.connect(_on_hand_card_hovered.bind(index, slot))
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

func _draw_enemy_cards(count: int) -> void:
	for i in range(count):
		if enemy_draw_pile.is_empty():
			if enemy_discard_pile.is_empty():
				break
			enemy_draw_pile = enemy_discard_pile.duplicate(true)
			enemy_discard_pile.clear()
			enemy_draw_pile.shuffle()
		enemy_hand.append(enemy_draw_pile.pop_back())

func _on_hand_card_hovered(card_id: String, index: int, slot: Control) -> void:
	var upgrade_level := 0
	if index >= 0 and index < hand.size():
		upgrade_level = RunState.get_card_upgrade_level(hand[index])
	_on_card_hovered(card_id, upgrade_level)
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
	if combat_over or enemy_acting or turn_locked or discard_overlay_active:
		return
	if index < 0 or index >= hand.size():
		return
	var card_entry = hand[index]
	var card_instance_id := RunState.get_card_id(card_entry)
	var card_data := GameData.get_card_data(card_instance_id, RunState.get_card_upgrade_level(card_entry))
	if bool(card_data.get("unplayable", false)):
		_append_battle_log("【%s】无法打出。" % card_data.get("name", "卡牌"))
		return
	var cost := int(card_data.get("cost", 0))
	if player_next_card_cost_delta != 0:
		cost = max(cost + player_next_card_cost_delta, 0)
	if cost > energy:
		_append_battle_log("能量不足，无法打出【%s】。" % card_data.get("name", "卡牌"))
		return
	energy -= cost
	player_next_card_cost_delta = 0
	_apply_card_effect(card_data)
	var removed = _remove_card_from_hand(index)
	if removed != null:
		if bool(card_data.get("exhaust", false)):
			_append_battle_log("【%s】已消耗。" % card_data.get("name", "卡牌"))
		else:
			discard_pile.append(removed)
	_check_enemy_defeat()
	_update_ui()
	RunState.save_run()

func _apply_card_effect(card_data: Dictionary) -> void:
	var card_name: String = str(card_data.get("name", "卡牌"))
	var is_attack := _is_attack_card(card_data)
	var is_defend := _is_defend_card(card_data)
	var attack_chain_before := player_attack_chain
	if is_attack:
		player_attack_chain += 1
		player_defend_chain = 0
	elif is_defend:
		player_defend_chain += 1
		player_attack_chain = 0
	else:
		player_attack_chain = 0
		player_defend_chain = 0
	var damage := _calculate_attack_damage(card_data, attack_chain_before)
	var pierce := _should_pierce(card_data)
	if is_attack:
		combat_attack_count += 1
	if damage > 0:
		var dealt := _apply_player_damage(damage, pierce)
		if dealt > 0:
			var prefix := "穿刺" if pierce else ""
			_append_battle_log("你使用【%s】->敌人：%s造成%d点伤害（敌人HP %d/%d，护甲 %d）。" % [
				card_name,
				prefix,
				dealt,
				enemy_hp,
				enemy_max_hp,
				enemy_block
			])
		else:
			_append_battle_log("你使用【%s】->敌人：攻击被护甲挡住（敌人护甲 %d）。" % [card_name, enemy_block])
		if dealt > 0:
			var lifesteal_ratio := float(card_data.get("lifesteal_ratio", 0.0))
			if lifesteal_ratio > 0.0:
				var heal_amount := int(round(dealt * lifesteal_ratio))
				heal_amount = min(heal_amount, RunState.player_max_hp - RunState.player_hp)
				if heal_amount > 0:
					RunState.player_hp += heal_amount
					_append_battle_log("【%s】吸血恢复%d点生命（HP %d/%d）。" % [
						card_name,
						heal_amount,
						RunState.player_hp,
						RunState.player_max_hp
					])
	if is_attack and player_bleed_on_attack > 0:
		enemy_bleed += player_bleed_on_attack
		_append_battle_log("血痕持续扩散，敌人流血+%d（%d）。" % [player_bleed_on_attack, enemy_bleed])
	if is_attack and player_attack_bonus_on_attack > 0:
		player_damage_bonus_turn += player_attack_bonus_on_attack
		_append_battle_log("嗜战叠加，攻击伤害+%d（本回合 +%d）。" % [player_attack_bonus_on_attack, player_damage_bonus_turn])
	if is_attack and power_first_attack_draw > 0 and not power_first_attack_draw_used:
		power_first_attack_draw_used = true
		_draw_cards(power_first_attack_draw)
		_append_battle_log("迅捷心法触发：抽%d张（手牌 %d）。" % [power_first_attack_draw, hand.size()])
	if is_attack and equip_attack_chain_draw > 0 and player_attack_chain >= 2:
		_draw_cards(equip_attack_chain_draw)
		_append_battle_log("连击腕轮触发：抽%d张（手牌 %d）。" % [equip_attack_chain_draw, hand.size()])
		player_attack_chain = 0
	if is_defend and equip_defend_chain_block > 0 and player_defend_chain >= 2:
		_gain_player_block(equip_defend_chain_block)
		_append_battle_log("守势腰带触发：护甲+%d（护甲 %d）。" % [equip_defend_chain_block, player_block])
		sfx_block.play()
		player_defend_chain = 0
	var block := int(card_data.get("block", 0))
	if block > 0:
		if _gain_player_block(block):
			_append_battle_log("你使用【%s】->自己：护甲+%d（护甲 %d）。" % [card_name, block, player_block])
			sfx_block.play()
		else:
			_append_battle_log("你使用【%s】->自己：护甲被封锁，无法获得护甲。" % card_name)
	var draw_count := int(card_data.get("draw", 0))
	if draw_count > 0:
		_draw_cards(draw_count)
		_append_battle_log("你使用【%s】->自己：抽%d张（手牌 %d，抽牌堆 %d）。" % [
			card_name,
			draw_count,
			hand.size(),
			draw_pile.size()
		])
	var heal := int(card_data.get("heal", 0))
	if heal > 0:
		var before: int = RunState.player_hp
		RunState.player_hp = min(RunState.player_hp + heal, RunState.player_max_hp)
		var healed: int = RunState.player_hp - before
		_append_battle_log("你使用【%s】->自己：恢复%d点生命（HP %d/%d）。" % [
			card_name,
			healed,
			RunState.player_hp,
			RunState.player_max_hp
		])
	var apply_bleed := int(card_data.get("apply_bleed", 0))
	if apply_bleed > 0:
		enemy_bleed += apply_bleed
		_append_battle_log("你使用【%s】->敌人：流血+%d（%d）。" % [card_name, apply_bleed, enemy_bleed])
	var apply_poison := int(card_data.get("apply_poison", 0))
	if apply_poison > 0:
		enemy_poison += apply_poison
		_append_battle_log("你使用【%s】->敌人：中毒+%d（%d）。" % [card_name, apply_poison, enemy_poison])
	var apply_burn := int(card_data.get("apply_burn", 0))
	if apply_burn > 0:
		enemy_burn += apply_burn
		_append_battle_log("你使用【%s】->敌人：灼烧+%d（%d）。" % [card_name, apply_burn, enemy_burn])
	var charge_mult := float(card_data.get("charge_mult", 0.0))
	if charge_mult > 0.0:
		player_next_attack_mult = max(player_next_attack_mult, charge_mult)
		_append_battle_log("你使用【%s】->自己：蓄力x%.1f。" % [card_name, player_next_attack_mult])
	if bool(card_data.get("skip_enemy_turn", false)):
		player_skip_enemy_turn = true
		_append_battle_log("你使用【%s】->敌人：进入停滞，本回合无法行动。" % card_name)
	var counter_ratio := float(card_data.get("counter_ratio", 0.0))
	if counter_ratio > 0.0:
		player_counter_ratio = max(player_counter_ratio, counter_ratio)
		_append_battle_log("你使用【%s】->自己：反击比例提升至%.0f%%。" % [card_name, player_counter_ratio * 100.0])
	var nullify_count := int(card_data.get("nullify_count", 0))
	if nullify_count > 0:
		player_nullify_count += nullify_count
		_append_battle_log("你使用【%s】->自己：护幕生效（%d次）。" % [card_name, player_nullify_count])
	var damage_draw := int(card_data.get("damage_draw", 0))
	if damage_draw > 0:
		player_damage_draw += damage_draw
		_append_battle_log("你使用【%s】->自己：受伤抽牌+%d（本回合 %d）。" % [card_name, damage_draw, player_damage_draw])
	var bleed_on_attack := int(card_data.get("bleed_on_attack", 0))
	if bleed_on_attack > 0:
		player_bleed_on_attack += bleed_on_attack
		_append_battle_log("你使用【%s】->自己：每次攻击流血+%d（本回合 %d）。" % [card_name, bleed_on_attack, player_bleed_on_attack])
	var attack_bonus_on_attack := int(card_data.get("attack_bonus_on_attack", 0))
	if attack_bonus_on_attack > 0:
		player_attack_bonus_on_attack += attack_bonus_on_attack
		_append_battle_log("你使用【%s】->自己：每次攻击伤害+%d（本回合 %d）。" % [card_name, attack_bonus_on_attack, player_attack_bonus_on_attack])
	var next_bonus := int(card_data.get("next_attack_bonus", 0))
	if next_bonus > 0:
		player_next_attack_bonus += next_bonus
	if bool(card_data.get("next_attack_pierce", false)):
		player_next_attack_pierce = true
	if next_bonus > 0 or player_next_attack_pierce:
		_append_battle_log("你使用【%s】->自己：强化下一次攻击。" % card_name)
	var enemy_block_reduce := int(card_data.get("enemy_block_gain_reduction", 0))
	if enemy_block_reduce > 0:
		enemy_block_gain_reduction = max(enemy_block_gain_reduction, enemy_block_reduce)
		_append_battle_log("你使用【%s】->敌人：本回合护甲获得-%d。" % [card_name, enemy_block_gain_reduction])
	var cost_delta := int(card_data.get("next_card_cost_delta", 0))
	if cost_delta != 0:
		player_next_card_cost_delta += cost_delta
		_append_battle_log("你使用【%s】->自己：下一张牌费用%+d。" % [card_name, cost_delta])
	if bool(card_data.get("block_disabled", false)):
		player_block_disabled = true
		_append_battle_log("你使用【%s】->自己：本回合无法获得护甲。" % card_name)
	var equip_attack := int(card_data.get("equip_attack_bonus", 0))
	if equip_attack > 0:
		equip_attack_bonus += equip_attack
		_append_battle_log("你装备【%s】：攻击伤害+%d（本场战斗 %d）。" % [card_name, equip_attack, equip_attack_bonus])
	var equip_reduce := int(card_data.get("equip_damage_reduction", 0))
	if equip_reduce > 0:
		equip_damage_reduction += equip_reduce
		_append_battle_log("你装备【%s】：受到伤害-%d（本场战斗 %d）。" % [card_name, equip_reduce, equip_damage_reduction])
	var equip_attack_draw := int(card_data.get("equip_attack_chain_draw", 0))
	if equip_attack_draw > 0:
		equip_attack_chain_draw += equip_attack_draw
		_append_battle_log("你装备【%s】：连击抽牌+%d。" % [card_name, equip_attack_draw])
	var equip_defend_block := int(card_data.get("equip_defend_chain_block", 0))
	if equip_defend_block > 0:
		equip_defend_chain_block += equip_defend_block
		_append_battle_log("你装备【%s】：守势护甲+%d。" % [card_name, equip_defend_block])
	var equip_block_on_hit := int(card_data.get("equip_block_on_damage", 0))
	if equip_block_on_hit > 0:
		equip_block_on_damage += equip_block_on_hit
		_append_battle_log("你装备【%s】：造成伤害时护甲+%d。" % [card_name, equip_block_on_hit])
	var equip_bleed_bonus := int(card_data.get("equip_bleed_bonus_per_stack", 0))
	if equip_bleed_bonus > 0:
		equip_bleed_bonus_per_stack += equip_bleed_bonus
		_append_battle_log("你装备【%s】：流血伤害提升。" % card_name)
	var power_attack_draw := int(card_data.get("power_first_attack_draw", 0))
	if power_attack_draw > 0:
		power_first_attack_draw += power_attack_draw
		_append_battle_log("你领悟【%s】：每回合首攻抽%d张。" % [card_name, power_attack_draw])
	var power_damage_block := int(card_data.get("power_first_damage_block", 0))
	if power_damage_block > 0:
		power_first_damage_block += power_damage_block
		_append_battle_log("你领悟【%s】：每回合首次受伤护甲+%d。" % [card_name, power_damage_block])
	var power_bleed := int(card_data.get("power_bleed_on_damage", 0))
	if power_bleed > 0:
		power_bleed_on_damage += power_bleed
		_append_battle_log("你领悟【%s】：伤害附加流血+%d。" % [card_name, power_bleed])
	if bool(card_data.get("initiative", false)):
		var bonus: int = int(card_data.get("initiative_bonus", 0))
		if RunState.next_encounter_first_strike:
			RunState.next_encounter_first_strike_bonus += GameData.FIRST_STRIKE_DAMAGE + bonus
		else:
			RunState.next_encounter_first_strike = true
			RunState.next_encounter_first_strike_bonus += bonus
		var strike: int = GameData.FIRST_STRIKE_DAMAGE + RunState.next_encounter_first_strike_bonus
		_append_battle_log("你使用【%s】->下场战斗先手伤害提升至%d。" % [card_name, strike])
		RunState.log_event("踏勘山势，获得先手优势。")
	if is_attack:
		player_next_attack_mult = 1.0
		player_next_attack_bonus = 0
		player_next_attack_pierce = false

func _remove_card_from_hand(index: int) -> Variant:
	if index >= 0 and index < hand.size():
		var removed = hand[index]
		hand.remove_at(index)
		return removed
	return null

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
		bonus += player_block
	if bool(card_data.get("damage_from_missing_hp", false)):
		var missing := RunState.player_max_hp - RunState.player_hp
		var cap := int(card_data.get("missing_hp_cap", missing))
		bonus += min(missing, cap)
	var hp_ratio := float(card_data.get("damage_from_current_hp_ratio", 0.0))
	if hp_ratio > 0.0:
		bonus += int(round(float(RunState.player_hp) * hp_ratio))
	var per_combo := int(card_data.get("damage_per_attack_chain", 0))
	if per_combo > 0:
		bonus += per_combo * combo_count
	var total := base_damage + bonus + equip_attack_bonus + player_damage_bonus_turn + player_next_attack_bonus
	var low_hp_mult := float(card_data.get("low_hp_mult", 1.0))
	if low_hp_mult > 1.0:
		var threshold := float(card_data.get("low_hp_threshold", 0.5))
		if float(RunState.player_hp) <= float(RunState.player_max_hp) * threshold:
			total = int(round(float(total) * low_hp_mult))
	var execute_threshold := float(card_data.get("execute_threshold", 0.0))
	if execute_threshold > 0.0:
		if enemy_max_hp > 0 and float(enemy_hp) <= float(enemy_max_hp) * execute_threshold:
			var execute_mult := float(card_data.get("execute_mult", 2.0))
			total = int(round(float(total) * execute_mult))
	if player_next_attack_mult > 1.0:
		total = int(round(float(total) * player_next_attack_mult))
	if player_weak_turns > 0:
		total = int(round(float(total) * WEAK_DAMAGE_MULT))
	return max(total, 0)

func _should_pierce(card_data: Dictionary) -> bool:
	if bool(card_data.get("pierce", false)):
		return true
	var pierce_threshold := int(card_data.get("pierce_if_block", 0))
	if pierce_threshold > 0 and player_block >= pierce_threshold:
		return true
	if player_next_attack_pierce:
		return true
	return false

func _apply_player_damage(amount: int, pierce: bool) -> int:
	if amount <= 0:
		return 0
	var actual := amount
	if not pierce:
		var blocked: int = min(enemy_block, actual)
		enemy_block -= blocked
		actual -= blocked
	if actual > 0:
		enemy_hp = max(enemy_hp - actual, 0)
		combat_damage_dealt += actual
		sfx_attack.play()
		_play_enemy_hit_effect()
		if equip_block_on_damage > 0:
			if _gain_player_block(equip_block_on_damage):
				_append_battle_log("血纹护符触发：护甲+%d（护甲 %d）。" % [equip_block_on_damage, player_block])
				sfx_block.play()
		if power_bleed_on_damage > 0:
			enemy_bleed += power_bleed_on_damage
			_append_battle_log("血炼触发：流血+%d（%d）。" % [power_bleed_on_damage, enemy_bleed])
	return actual

func _gain_player_block(amount: int) -> bool:
	if amount <= 0:
		return false
	if player_block_disabled:
		return false
	player_block += amount
	return true

func _apply_ethereal_cleanup() -> void:
	for index in range(hand.size() - 1, -1, -1):
		var card_entry = hand[index]
		var card_id := RunState.get_card_id(card_entry)
		var card_data := GameData.get_card_data(card_id, RunState.get_card_upgrade_level(card_entry))
		if bool(card_data.get("ethereal", false)):
			hand.remove_at(index)
			_append_battle_log("【%s】虚无消散。" % card_data.get("name", "卡牌"))

func _on_end_turn_pressed() -> void:
	if combat_over or enemy_acting or discard_overlay_active or turn_locked:
		return
	turn_locked = true
	_apply_ethereal_cleanup()
	if hand.size() > HAND_LIMIT:
		_open_discard_overlay(hand.size() - HAND_LIMIT)
		return
	await _resolve_end_turn()

func _resolve_end_turn() -> void:
	_tick_player_end_turn()
	await _enemy_turn()
	if combat_over:
		turn_locked = false
		_update_ui()
		return
	_log_turn_end()
	energy = RunState.energy_max
	_draw_cards(HAND_DRAW_PER_TURN)
	turn_index += 1
	_log_turn_start()
	turn_locked = false
	_update_ui()
	RunState.save_run()

func _enemy_turn() -> void:
	enemy_acting = true
	enemy_energy = RunState.energy_max
	_update_ui()
	if player_skip_enemy_turn:
		player_skip_enemy_turn = false
		_append_battle_log("停滞结界生效：魔物本回合无法行动。")
		await _wait(ENEMY_IDLE_DELAY)
	else:
		await _play_enemy_hand()
	enemy_acting = false
	if RunState.player_hp <= 0:
		combat_over = true
		run_complete = true
		_append_battle_log("你在山道上倒下，征途告终。")
		RunState.log_event("你在山道上倒下。")
		RunState.finalize_run_score()
		RunState.run_active = false
		RunState.save_run()
		return
	if not combat_over:
		_apply_enemy_end_turn_effects()
		if enemy_hp <= 0:
			_check_enemy_defeat()
			return
	if not combat_over:
		if player_vulnerable_turns > 0:
			player_vulnerable_turns -= 1
		_clear_round_effects()
		enemy_discard_pile.append_array(enemy_hand)
		enemy_hand.clear()
		_draw_enemy_cards(ENEMY_HAND_SIZE)
		_refresh_enemy_intent()

func _check_enemy_defeat() -> void:
	if enemy_hp <= 0:
		combat_over = true
		_log_turn_end()
		_append_battle_log("敌人倒下，战斗结束。")
		var combat_score := _calculate_combat_score()
		RunState.add_combat_score(combat_score)
		run_complete = RunState.complete_encounter()
		if run_complete:
			_append_battle_log("你征服了 %s，登顶通关！" % GameData.MOUNTAIN_NAME)
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
	_start_encounter()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _refresh_enemy_intent() -> void:
	enemy_intent_card = _get_enemy_intent_card()

func _get_enemy_intent_card() -> Dictionary:
	if enemy_hand.is_empty():
		return {}
	for card_id in enemy_hand:
		var card_data := GameData.get_enemy_card_data(str(card_id))
		if int(card_data.get("cost", 0)) <= RunState.energy_max:
			return card_data
	return GameData.get_enemy_card_data(str(enemy_hand[0]))

func _enemy_card_display(card_data: Dictionary) -> String:
	if card_data.is_empty():
		return "行动未知"
	var custom_text: String = str(card_data.get("text", ""))
	if not custom_text.is_empty():
		return custom_text
	var intent_type: String = str(card_data.get("type", ""))
	var name: String = str(card_data.get("name", "行动"))
	var bonus: int = enemy_attack_bonus
	match intent_type:
		"attack":
			var damage := int(round(int(card_data.get("damage", 0)) * enemy_power_mult))
			damage += bonus
			return "%s %d" % [name, damage]
		"multi_attack":
			var damage := int(round(int(card_data.get("damage", 0)) * enemy_power_mult))
			var hits := int(card_data.get("hits", 1))
			var suffix := " +%d" % bonus if bonus > 0 else ""
			return "%s %d x %d%s" % [name, damage, hits, suffix]
		"guard":
			var block := int(round(int(card_data.get("block", 0)) * enemy_power_mult))
			return "%s +%d" % [name, block]
		"charge":
			var charge := int(round(int(card_data.get("charge", 0)) * enemy_power_mult))
			return "%s +%d" % [name, charge]
		"drain":
			var damage := int(round(int(card_data.get("damage", 0)) * enemy_power_mult))
			damage += bonus
			return "%s %d" % [name, damage]
		"heal":
			var heal := int(round(int(card_data.get("heal", 0)) * enemy_power_mult))
			return "%s +%d" % [name, heal]
		"debuff", "attack_debuff":
			var summary := _enemy_debuff_summary(card_data)
			return "%s %s" % [name, summary]
	return name

func _enemy_card_targets_player(intent_type: String) -> bool:
	return intent_type in ["attack", "multi_attack", "drain", "debuff", "attack_debuff"]

func _play_enemy_hand() -> void:
	var acted := false
	for card_id in enemy_hand:
		var card_data := GameData.get_enemy_card_data(str(card_id))
		var cost := int(card_data.get("cost", 0))
		if cost > enemy_energy:
			continue
		enemy_energy -= cost
		enemy_intent_card = card_data
		_update_ui()
		await _wait(ENEMY_WINDUP_DELAY)
		_play_enemy_action_fx(card_data)
		_apply_enemy_card(card_data)
		acted = true
		_update_ui()
		if RunState.player_hp <= 0 or enemy_hp <= 0:
			break
		await _wait(ENEMY_ACTION_DELAY)
	if not acted:
		_append_battle_log("魔物谨慎观望。")
		await _wait(ENEMY_IDLE_DELAY)

func _wait(seconds: float) -> void:
	if seconds <= 0.0:
		return
	await get_tree().create_timer(seconds).timeout

func _play_enemy_action_fx(card_data: Dictionary) -> void:
	var intent_type: String = str(card_data.get("type", ""))
	_pulse_node(enemy_portrait, 1.04)
	match intent_type:
		"guard", "charge":
			sfx_block.play()

func _apply_enemy_card(card_data: Dictionary) -> void:
	if card_data.is_empty():
		return
	var intent_type: String = str(card_data.get("type", ""))
	var card_name: String = str(card_data.get("name", "行动"))
	if _enemy_card_targets_player(intent_type) and player_nullify_count > 0:
		player_nullify_count -= 1
		_append_battle_log("护幕抵消了魔物的【%s】。" % card_name)
		return
	var damage := int(round(int(card_data.get("damage", 0)) * enemy_power_mult))
	var block := int(round(int(card_data.get("block", 0)) * enemy_power_mult))
	var heal := int(round(int(card_data.get("heal", 0)) * enemy_power_mult))
	var charge := int(round(int(card_data.get("charge", 0)) * enemy_power_mult))
	var apply_weak := int(card_data.get("apply_weak", 0))
	var apply_vulnerable := int(card_data.get("apply_vulnerable", 0))
	match intent_type:
		"attack":
			var total_damage: int = damage + enemy_attack_bonus
			enemy_attack_bonus = 0
			var dealt := _apply_enemy_damage(total_damage)
			if dealt > 0:
				_append_battle_log("魔物使用【%s】->你：造成%d点伤害（你HP %d/%d，护甲 %d）。" % [
					card_name,
					dealt,
					RunState.player_hp,
					RunState.player_max_hp,
					player_block
				])
			else:
				_append_battle_log("魔物使用【%s】->你：攻击被护甲挡住（你护甲 %d）。" % [card_name, player_block])
		"multi_attack":
			var hits: int = int(card_data.get("hits", 1))
			var total_multi: int = (damage * hits) + enemy_attack_bonus
			enemy_attack_bonus = 0
			var dealt := _apply_enemy_damage(total_multi)
			if dealt > 0:
				_append_battle_log("魔物使用【%s】->你：连击%d次造成%d点伤害（你HP %d/%d，护甲 %d）。" % [
					card_name,
					hits,
					dealt,
					RunState.player_hp,
					RunState.player_max_hp,
					player_block
				])
			else:
				_append_battle_log("魔物使用【%s】->你：连击被护甲挡住（你护甲 %d）。" % [card_name, player_block])
		"guard":
			var gain: int = int(max(block - enemy_block_gain_reduction, 0))
			enemy_block += gain
			if enemy_block_gain_reduction > 0:
				_append_battle_log("魔物使用【%s】->自己：护甲+%d（被削减 %d，护甲 %d）。" % [
					card_name,
					gain,
					enemy_block_gain_reduction,
					enemy_block
				])
			else:
				_append_battle_log("魔物使用【%s】->自己：护甲+%d（护甲 %d）。" % [card_name, gain, enemy_block])
		"charge":
			enemy_attack_bonus += charge
			_append_battle_log("魔物使用【%s】->自己：蓄力+%d（下次攻击加成 %d）。" % [
				card_name,
				charge,
				enemy_attack_bonus
			])
		"drain":
			var drain_damage: int = damage + enemy_attack_bonus
			enemy_attack_bonus = 0
			var dealt: int = _apply_enemy_damage(drain_damage)
			if dealt > 0 and heal > 0:
				enemy_hp = min(enemy_hp + heal, enemy_max_hp)
				_append_battle_log("魔物使用【%s】->你：造成%d点伤害（你HP %d/%d）。自身恢复%d点生命（敌人HP %d/%d）。" % [
					card_name,
					dealt,
					RunState.player_hp,
					RunState.player_max_hp,
					heal,
					enemy_hp,
					enemy_max_hp
				])
			elif dealt > 0:
				_append_battle_log("魔物使用【%s】->你：造成%d点伤害（你HP %d/%d）。" % [
					card_name,
					dealt,
					RunState.player_hp,
					RunState.player_max_hp
				])
			else:
				_append_battle_log("魔物使用【%s】->你：攻击被护甲挡住（你护甲 %d）。" % [card_name, player_block])
		"heal":
			if heal > 0:
				enemy_hp = min(enemy_hp + heal, enemy_max_hp)
				_append_battle_log("魔物使用【%s】->自己：恢复%d点生命（敌人HP %d/%d）。" % [
					card_name,
					heal,
					enemy_hp,
					enemy_max_hp
				])
		"debuff":
			_apply_enemy_debuffs(apply_weak, apply_vulnerable)
			_append_battle_log("魔物使用【%s】->你：施加%s（你状态：%s）。" % [
				card_name,
				_enemy_debuff_summary(card_data),
				_player_status_text()
			])
		"attack_debuff":
			var debuff_damage: int = damage + enemy_attack_bonus
			enemy_attack_bonus = 0
			var dealt := _apply_enemy_damage(debuff_damage)
			_apply_enemy_debuffs(apply_weak, apply_vulnerable)
			var status_summary := _enemy_debuff_summary(card_data)
			if dealt > 0:
				_append_battle_log("魔物使用【%s】->你：造成%d点伤害（你HP %d/%d），施加%s（你状态：%s）。" % [
					card_name,
					dealt,
					RunState.player_hp,
					RunState.player_max_hp,
					status_summary,
					_player_status_text()
				])
			else:
				_append_battle_log("魔物使用【%s】->你：攻击被护甲挡住，施加%s（你状态：%s）。" % [
					card_name,
					status_summary,
					_player_status_text()
				])
		_:
			_append_battle_log("魔物踌躇不前。")

func _apply_enemy_damage(amount: int) -> int:
	if amount <= 0:
		return 0
	sfx_attack.play()
	var adjusted_amount := amount
	if player_vulnerable_turns > 0:
		adjusted_amount = int(round(amount * VULNERABLE_DAMAGE_MULT))
	var blocked: int = int(min(adjusted_amount, player_block))
	var damage: int = adjusted_amount - blocked
	player_block = max(player_block - adjusted_amount, 0)
	if equip_damage_reduction > 0:
		damage = max(damage - equip_damage_reduction, 0)
	if damage > 0:
		RunState.player_hp = max(RunState.player_hp - damage, 0)
		combat_damage_taken += damage
		_play_player_hit_effect()
		if power_first_damage_block > 0 and not power_first_damage_block_used:
			power_first_damage_block_used = true
			if _gain_player_block(power_first_damage_block):
				_append_battle_log("坚毅之魂触发：护甲+%d（护甲 %d）。" % [power_first_damage_block, player_block])
				sfx_block.play()
		if player_counter_ratio > 0.0:
			var counter_damage := int(round(float(damage) * player_counter_ratio))
			if counter_damage > 0:
				var dealt := _apply_player_damage(counter_damage, false)
				if dealt > 0:
					_append_battle_log("反击造成%d点伤害（敌人HP %d/%d）。" % [
						dealt,
						enemy_hp,
						enemy_max_hp
					])
		if player_damage_draw > 0:
			_draw_cards(player_damage_draw)
			_append_battle_log("补给回响：抽%d张（手牌 %d）。" % [player_damage_draw, hand.size()])
	return damage

func _apply_enemy_debuffs(weak_turns: int, vulnerable_turns: int) -> void:
	if weak_turns > 0:
		player_weak_turns += weak_turns
	if vulnerable_turns > 0:
		player_vulnerable_turns += vulnerable_turns

func _enemy_debuff_summary(card_data: Dictionary) -> String:
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

func _apply_enemy_end_turn_effects() -> void:
	var total_dot := 0
	if enemy_bleed > 0:
		var bleed_damage := enemy_bleed * (1 + equip_bleed_bonus_per_stack)
		enemy_hp = max(enemy_hp - bleed_damage, 0)
		combat_damage_dealt += bleed_damage
		total_dot += bleed_damage
		_append_battle_log("敌人流血造成%d点伤害（流血 %d，HP %d/%d）。" % [
			bleed_damage,
			enemy_bleed,
			enemy_hp,
			enemy_max_hp
		])
	if enemy_poison > 0:
		var poison_damage := enemy_poison
		enemy_hp = max(enemy_hp - poison_damage, 0)
		combat_damage_dealt += poison_damage
		total_dot += poison_damage
		_append_battle_log("敌人中毒造成%d点伤害（中毒 %d，HP %d/%d）。" % [
			poison_damage,
			enemy_poison,
			enemy_hp,
			enemy_max_hp
		])
		enemy_poison = max(enemy_poison - 1, 0)
	if enemy_burn > 0:
		var burn_damage := enemy_burn
		enemy_hp = max(enemy_hp - burn_damage, 0)
		combat_damage_dealt += burn_damage
		total_dot += burn_damage
		_append_battle_log("敌人灼烧造成%d点伤害（灼烧 %d，HP %d/%d）。" % [
			burn_damage,
			enemy_burn,
			enemy_hp,
			enemy_max_hp
		])
	if total_dot > 0:
		_play_enemy_hit_effect()

func _clear_round_effects() -> void:
	player_counter_ratio = 0.0
	player_nullify_count = 0
	player_damage_draw = 0
	player_block_disabled = false
	enemy_block_gain_reduction = 0
	power_first_attack_draw_used = false
	power_first_damage_block_used = false
	player_skip_enemy_turn = false

func _tick_player_end_turn() -> void:
	if player_weak_turns > 0:
		player_weak_turns -= 1
	player_bleed_on_attack = 0
	player_attack_bonus_on_attack = 0
	player_damage_bonus_turn = 0
	player_attack_chain = 0
	player_defend_chain = 0
	player_next_card_cost_delta = 0

func _queue_post_battle_step() -> void:
	next_step = "shop"
	_enter_shop()

func _enter_shop() -> void:
	next_step = "shop"
	_refresh_shop_offers()
	_set_shop_overlay_visible(true)
	_append_battle_log("战后商店开启：可以用积分购买新卡牌。")

func _refresh_shop_offers() -> void:
	var pool: Array = _build_shop_pool()
	shop_offer_cards.clear()
	shop_offer_costs.clear()
	if pool.is_empty():
		_refresh_shop_ui()
		return
	pool.shuffle()
	var offer_count: int = int(min(SHOP_OFFER_COUNT, pool.size()))
	for i in range(offer_count):
		var card_id: String = str(pool[i])
		var card_data: Dictionary = GameData.get_card_data(card_id, 0)
		shop_offer_cards.append(card_id)
		shop_offer_costs[card_id] = _calculate_shop_cost(card_data)
	_refresh_shop_ui()

func _build_shop_pool() -> Array:
	var owned: Dictionary = {}
	for entry in RunState.deck:
		var owned_id: String = RunState.get_card_id(entry)
		if not owned_id.is_empty():
			owned[owned_id] = true
	var pool: Array = []
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

func _refresh_shop_ui() -> void:
	shop_points_label.text = "当前积分：%d" % RunState.run_score_total
	shop_refresh_button.text = "刷新商品 (-%d)" % SHOP_REFRESH_COST
	var has_pool: bool = not _build_shop_pool().is_empty()
	shop_refresh_button.disabled = RunState.run_score_total < SHOP_REFRESH_COST or not has_pool
	if shop_offer_cards.is_empty():
		if has_pool:
			shop_info_label.text = "本轮商品已购完，可刷新商品继续购买。"
		else:
			shop_info_label.text = "已拥有全部可购买的卡牌。"
		shop_choice_scroll.visible = false
	else:
		shop_info_label.text = "使用积分购买新卡牌。"
		shop_choice_scroll.visible = true
	_populate_shop_cards()

func _populate_shop_cards() -> void:
	_clear_container(shop_choice_container)
	for card_id in shop_offer_cards:
		var cost: int = int(shop_offer_costs.get(card_id, 0))
		var card_data: Dictionary = GameData.get_card_data(card_id, 0)
		var slot := VBoxContainer.new()
		slot.theme_override_constants.separation = 4
		shop_choice_container.add_child(slot)
		var widget: CardWidget = CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.hovered.connect(_on_card_hovered)
		widget.unhovered.connect(_on_card_unhovered)
		slot.add_child(widget)
		var buy_button := Button.new()
		buy_button.text = "购买 %d" % cost
		buy_button.disabled = RunState.run_score_total < cost
		buy_button.pressed.connect(_on_shop_buy_pressed.bind(card_id))
		slot.add_child(buy_button)

func _calculate_shop_cost(card_data: Dictionary) -> int:
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
		value += 18.0
	var lifesteal_ratio: float = float(card_data.get("lifesteal_ratio", 0.0))
	if lifesteal_ratio > 0.0:
		value += 20.0 * lifesteal_ratio
	if bool(card_data.get("skip_enemy_turn", false)):
		value += 35.0
	var counter_ratio: float = float(card_data.get("counter_ratio", 0.0))
	if counter_ratio > 0.0:
		value += 20.0 * counter_ratio
	var nullify_count: int = int(card_data.get("nullify_count", 0))
	if nullify_count > 0:
		value += 16.0 * float(nullify_count)
	var damage_draw: int = int(card_data.get("damage_draw", 0))
	if damage_draw > 0:
		value += 10.0 * float(damage_draw)
	var attack_bonus_on_attack: int = int(card_data.get("attack_bonus_on_attack", 0))
	if attack_bonus_on_attack > 0:
		value += 12.0 * float(attack_bonus_on_attack)
	var charge_mult: float = float(card_data.get("charge_mult", 0.0))
	if charge_mult > 0.0:
		value += 12.0 * charge_mult
	var next_attack_bonus: int = int(card_data.get("next_attack_bonus", 0))
	if next_attack_bonus > 0:
		value += 6.0 * float(next_attack_bonus)
	if bool(card_data.get("next_attack_pierce", false)):
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
	elif cost >= 2:
		value += 4.0 * float(cost)
	var rarity_mult := 1.0
	match rarity:
		"uncommon":
			rarity_mult = 1.15
		"rare":
			rarity_mult = 1.35
		_:
			rarity_mult = 1.0
	value = max(value, 12.0) * rarity_mult + 8.0
	var price: int = int(round(value))
	price = int(round(float(price) / 5.0)) * 5
	return max(price, 20)

func _set_shop_overlay_visible(active: bool) -> void:
	if active == shop_overlay_active:
		return
	shop_overlay_active = active
	if shop_overlay_tween:
		shop_overlay_tween.kill()
	if active:
		shop_overlay.visible = true
		shop_overlay.modulate.a = 0.0
		shop_panel.scale = Vector2(0.96, 0.96)
		shop_overlay_tween = create_tween()
		shop_overlay_tween.tween_property(shop_overlay, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		shop_overlay_tween.tween_property(shop_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		shop_overlay_tween = create_tween()
		shop_overlay_tween.tween_property(shop_overlay, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		shop_overlay_tween.tween_callback(func(): shop_overlay.visible = false)

func _on_shop_refresh_pressed() -> void:
	if RunState.run_score_total < SHOP_REFRESH_COST:
		return
	RunState.run_score_total = max(RunState.run_score_total - SHOP_REFRESH_COST, 0)
	RunState.log_event("积分刷新商店：-%d 分。" % SHOP_REFRESH_COST)
	_refresh_shop_offers()
	RunState.save_run()

func _on_shop_skip_pressed() -> void:
	_set_shop_overlay_visible(false)
	_enter_route_selection()

func _on_shop_buy_pressed(card_id: String) -> void:
	var cost: int = int(shop_offer_costs.get(card_id, 0))
	if cost <= 0:
		return
	if RunState.run_score_total < cost:
		return
	RunState.run_score_total = max(RunState.run_score_total - cost, 0)
	RunState.add_card(card_id)
	var card_name: String = str(GameData.get_card_data(card_id, 0).get("name", "卡牌"))
	RunState.log_event("积分购买卡牌：%s（-%d 分）。" % [card_name, cost])
	_append_battle_log("购买卡牌：%s（-%d 积分）。" % [card_name, cost])
	shop_offer_cards.erase(card_id)
	shop_offer_costs.erase(card_id)
	_refresh_shop_ui()
	RunState.save_run()

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
	_append_battle_log("你选择了%s挑战。" % _difficulty_display(difficulty))
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

func _set_discard_overlay_visible(active: bool) -> void:
	if active == discard_overlay_active:
		return
	discard_overlay_active = active
	if discard_overlay_tween:
		discard_overlay_tween.kill()
	if active:
		discard_overlay.visible = true
		discard_overlay.modulate.a = 0.0
		discard_panel.scale = Vector2(0.96, 0.96)
		discard_overlay_tween = create_tween()
		discard_overlay_tween.tween_property(discard_overlay, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		discard_overlay_tween.tween_property(discard_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		discard_overlay_tween = create_tween()
		discard_overlay_tween.tween_property(discard_overlay, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		discard_overlay_tween.tween_callback(func(): discard_overlay.visible = false)

func _open_discard_overlay(required: int) -> void:
	discard_required = max(required, 0)
	discard_selection.clear()
	discard_locked_indices.clear()
	_build_discard_locks()
	_populate_discard_cards()
	_refresh_discard_ui()
	_set_discard_overlay_visible(true)

func _build_discard_locks() -> void:
	var retain_indices: Array = []
	var non_retain_count := 0
	for index in hand.size():
		var card_entry = hand[index]
		var card_id := RunState.get_card_id(card_entry)
		var card_data := GameData.get_card_data(card_id, RunState.get_card_upgrade_level(card_entry))
		if bool(card_data.get("retain", false)):
			retain_indices.append(index)
		else:
			non_retain_count += 1
	if non_retain_count >= discard_required:
		for index in retain_indices:
			discard_locked_indices[index] = true

func _refresh_discard_ui() -> void:
	discard_info_label.text = "需要弃置%d张（已选择%d）。" % [discard_required, discard_selection.size()]
	discard_confirm_button.disabled = discard_selection.size() != discard_required

func _populate_discard_cards() -> void:
	_clear_container(discard_choice_container)
	discard_card_widgets.clear()
	for index in hand.size():
		var card_entry = hand[index]
		var card_id := RunState.get_card_id(card_entry)
		var card_data := GameData.get_card_data(card_id, RunState.get_card_upgrade_level(card_entry))
		var widget: CardWidget = CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.scale = Vector2(0.85, 0.85)
		if discard_locked_indices.get(index, false):
			widget.mouse_filter = Control.MOUSE_FILTER_IGNORE
			widget.modulate = Color(0.75, 0.75, 0.75, 1)
		else:
			widget.clicked.connect(_on_discard_card_clicked.bind(index, widget))
		widget.hovered.connect(_on_discard_card_hovered.bind(index))
		widget.unhovered.connect(_on_card_unhovered)
		discard_choice_container.add_child(widget)
		discard_card_widgets[index] = widget

func _on_discard_card_clicked(card_id: String, index: int, widget: CardWidget) -> void:
	if discard_required <= 0:
		return
	if discard_locked_indices.get(index, false):
		return
	if discard_selection.has(index):
		discard_selection.erase(index)
		if widget:
			widget.modulate = Color(1, 1, 1, 1)
	elif discard_selection.size() < discard_required:
		discard_selection.append(index)
		if widget:
			widget.modulate = Color(0.9, 0.9, 0.9, 1)
	_refresh_discard_ui()

func _on_discard_card_hovered(card_id: String, index: int) -> void:
	var upgrade_level := 0
	if index >= 0 and index < hand.size():
		upgrade_level = RunState.get_card_upgrade_level(hand[index])
	_on_card_hovered(card_id, upgrade_level)

func _on_discard_confirm_pressed() -> void:
	if discard_selection.size() != discard_required:
		return
	_apply_discard_selection()
	_set_discard_overlay_visible(false)
	_refresh_hand()
	await _resolve_end_turn()

func _apply_discard_selection() -> void:
	discard_selection.sort()
	for i in range(discard_selection.size() - 1, -1, -1):
		var index: int = discard_selection[i]
		if index >= 0 and index < hand.size():
			var card_entry = hand[index]
			var card_id := RunState.get_card_id(card_entry)
			var card_data := GameData.get_card_data(card_id, RunState.get_card_upgrade_level(card_entry))
			if bool(card_data.get("ethereal", false)) or bool(card_data.get("exhaust", false)):
				_append_battle_log("【%s】已消耗。" % card_data.get("name", "卡牌"))
			else:
				discard_pile.append(card_entry)
			hand.remove_at(index)
	discard_selection.clear()
	discard_required = 0
	discard_locked_indices.clear()

func _on_reward_deck_card_hovered(card_id: String, index: int) -> void:
	var upgrade_level := 0
	if index >= 0 and index < RunState.deck.size():
		upgrade_level = RunState.get_card_upgrade_level(RunState.deck[index])
	_on_card_hovered(card_id, upgrade_level)

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
	enemy_power_mult = power_mult
	if hp_mult != 1.0:
		enemy_hp = int(round(enemy_hp * hp_mult))
		enemy_max_hp = enemy_hp
		enemy_data["hp"] = enemy_hp

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
	_clear_container(reward_deck_list)
	var any_available := false
	for index in RunState.deck.size():
		var card_entry = RunState.deck[index]
		var card_id := RunState.get_card_id(card_entry)
		if reward_mode == "upgrade" and RunState.get_card_upgrade_level(card_entry) >= GameData.get_max_upgrade_level(card_id):
			continue
		any_available = true
		var card_data := GameData.get_card_data(card_id, RunState.get_card_upgrade_level(card_entry))
		var widget: CardWidget = CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.clicked.connect(_on_reward_deck_card_selected.bind(index))
		widget.hovered.connect(_on_reward_deck_card_hovered.bind(index))
		widget.unhovered.connect(_on_card_unhovered)
		reward_deck_list.add_child(widget)
	if not any_available:
		if reward_mode == "upgrade":
			_append_battle_log("没有可强化的卡牌。")
		else:
			_append_battle_log("牌组为空，无法移除。")
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
	_append_battle_log("你放弃了补给。")
	RunState.log_event("放弃了补给。")
	sfx_reward.play()
	_start_encounter()

func _on_reward_heal_pressed() -> void:
	var before: int = RunState.player_hp
	RunState.player_hp = min(RunState.player_hp + GameData.SUPPLY_HEAL_AMOUNT, RunState.player_max_hp)
	var healed: int = RunState.player_hp - before
	_append_battle_log("补给休整，恢复%d点生命（HP %d/%d）。" % [healed, RunState.player_hp, RunState.player_max_hp])
	RunState.log_event("补给休整恢复%d点生命。" % healed)
	sfx_reward.play()
	_start_encounter()

func _on_reward_draft_pressed() -> void:
	reward_mode = "supply_draft"
	last_reward_mode = ""
	_refresh_reward_ui()

func _on_reward_card_selected(card_id: String) -> void:
	RunState.add_card(card_id)
	var card_name: String = str(GameData.get_card_data(card_id, false).get("name", "新卡牌"))
	_append_battle_log("补给中获得一张卡牌：%s。" % card_name)
	RunState.log_event("补给获得新卡：%s。" % card_name)
	sfx_reward.play()
	_start_encounter()

func _on_reward_deck_card_selected(card_id: String, index: int) -> void:
	if index < 0 or index >= RunState.deck.size():
		return
	var card_entry = RunState.deck[index]
	var entry_id := RunState.get_card_id(card_entry)
	var entry_level := RunState.get_card_upgrade_level(card_entry)
	if reward_mode == "remove":
		RunState.deck.remove_at(index)
		RunState.save_run()
		var card_name: String = str(GameData.get_card_data(entry_id, entry_level).get("name", "卡牌"))
		_append_battle_log("已移除卡牌：%s。" % card_name)
		RunState.log_event("移除卡牌：%s。" % card_name)
		sfx_reward.play()
		_start_encounter()
		return
	if reward_mode == "upgrade":
		RunState.upgrade_card_at(index)
		var new_level := RunState.get_card_upgrade_level(RunState.deck[index])
		var upgraded_name: String = str(GameData.get_card_data(entry_id, new_level).get("name", "卡牌"))
		_append_battle_log("已强化卡牌：%s。" % upgraded_name)
		RunState.log_event("强化卡牌：%s。" % upgraded_name)
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

func _on_card_hovered(card_id: String, upgrade_level: int = 0) -> void:
	var card_data := GameData.get_card_data(card_id, upgrade_level)
	if card_data.is_empty():
		return
	card_detail_name.text = str(card_data.get("name", "卡牌"))
	card_detail_cost.text = "费用 %s" % str(card_data.get("cost", 0))
	card_detail_desc.text = str(card_data.get("desc", ""))
	card_detail_panel.visible = true

func _on_card_unhovered() -> void:
	card_detail_panel.visible = false

func _enemy_card_color(card_data: Dictionary) -> Color:
	var intent_type: String = str(card_data.get("type", ""))
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
		"heal":
			return Color(0.55, 0.85, 0.6)
		"debuff", "attack_debuff":
			return Color(0.85, 0.55, 0.95)
	return Color(1, 1, 1)

func _enemy_card_icon(card_data: Dictionary) -> Texture2D:
	var intent_type: String = str(card_data.get("type", "attack"))
	return INTENT_ICONS.get(intent_type, INTENT_ICONS["attack"])
