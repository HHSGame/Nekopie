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
const PORTRAIT_FRAME := preload("res://art/ui/portrait_frame.svg")
const ENEMY_HIT_FX := preload("res://art/fx/slash.svg")
const PLAYER_HIT_FX := preload("res://art/fx/impact.svg")
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

# ── Node references ──
@onready var story_label: Label = %StoryLabel
@onready var progress_label: Label = %ProgressLabel
@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var enemy_hp_label: Label = %EnemyHpLabel
@onready var enemy_hp_bar: ProgressBar = %EnemyHpBar
@onready var enemy_block_label: Label = %EnemyBlockLabel
@onready var enemy_intent_swatch: ColorRect = %EnemyIntentSwatch
@onready var enemy_intent_icon: TextureRect = %EnemyIntentIcon
@onready var enemy_intent_label: Label = %EnemyIntentLabel
@onready var enemy_desc_label: Label = %EnemyDescLabel
@onready var player_portrait_panel: PortraitPanel = %PlayerPortraitPanel
@onready var enemy_portrait_panel: PortraitPanel = %EnemyPortraitPanel
@onready var player_hp_label: Label = %PlayerHpLabel
@onready var player_block_label: Label = %PlayerBlockLabel
@onready var energy_label: Label = %EnergyLabel
@onready var draw_label: Label = %DrawLabel
@onready var discard_label: Label = %DiscardLabel
@onready var player_hp_bar: ProgressBar = %PlayerHpBar
@onready var battle_log_panel: BattleLogPanel = %BattleLogPanel
@onready var hand_container: HBoxContainer = %HandContainer
@onready var end_turn_button: Button = %EndTurnButton
@onready var next_button: Button = %NextButton
@onready var back_button: Button = %BackButton
@onready var route_overlay: Control = %RouteOverlay
@onready var route_info_label: Label = %RouteInfoLabel
@onready var route_supply_button: Button = %RouteSupplyButton
@onready var route_challenge_button: Button = %RouteChallengeButton
@onready var difficulty_panel: VBoxContainer = %DifficultyPanel
@onready var difficulty_normal_button: Button = %DifficultyNormalButton
@onready var difficulty_hard_button: Button = %DifficultyHardButton
@onready var difficulty_elite_button: Button = %DifficultyEliteButton
@onready var reward_overlay: Control = %RewardOverlay
@onready var reward_options: HBoxContainer = %RewardOptions
@onready var reward_upgrade_button: Button = %RewardUpgradeButton
@onready var reward_remove_button: Button = %RewardRemoveButton
@onready var reward_heal_button: Button = %RewardHealButton
@onready var reward_draft_button: Button = %RewardDraftButton
@onready var reward_skip_button: Button = %RewardSkipButton
@onready var reward_choice_label: Label = %RewardChoiceLabel
@onready var reward_choice_scroll: ScrollContainer = %RewardChoiceScroll
@onready var reward_choice_container: HBoxContainer = %RewardChoiceContainer
@onready var reward_deck_scroll: ScrollContainer = %RewardDeckScroll
@onready var reward_deck_list: VBoxContainer = %RewardDeckList
@onready var reward_panel: PanelContainer = %RewardPanel
@onready var shop_overlay: Control = %ShopOverlay
@onready var shop_points_label: Label = %ShopPointsLabel
@onready var shop_info_label: Label = %ShopInfoLabel
@onready var shop_choice_scroll: ScrollContainer = %ShopChoiceScroll
@onready var shop_choice_container: HBoxContainer = %ShopChoiceContainer
@onready var shop_refresh_button: Button = %ShopRefreshButton
@onready var shop_skip_button: Button = %ShopSkipButton
@onready var shop_panel: PanelContainer = %ShopPanel
@onready var discard_overlay: Control = %DiscardOverlay
@onready var discard_info_label: Label = %DiscardInfoLabel
@onready var discard_choice_scroll: ScrollContainer = %DiscardChoiceScroll
@onready var discard_choice_container: HBoxContainer = %DiscardChoiceContainer
@onready var discard_confirm_button: Button = %DiscardConfirmButton
@onready var discard_panel: PanelContainer = %DiscardPanel
@onready var score_overlay: Control = %ScoreOverlay
@onready var score_summary_label: Label = %ScoreSummaryLabel
@onready var score_rank_label: Label = %ScoreRankLabel
@onready var score_list: VBoxContainer = %ScoreList
@onready var score_continue_button: Button = %ScoreContinueButton
@onready var card_detail_panel: PanelContainer = %CardDetailPanel
@onready var card_detail_name: Label = %CardDetailName
@onready var card_detail_cost: Label = %CardDetailCost
@onready var card_detail_desc: Label = %CardDetailDesc
@onready var sfx_attack: AudioStreamPlayer = %SfxAttack
@onready var sfx_block: AudioStreamPlayer = %SfxBlock
@onready var sfx_reward: AudioStreamPlayer = %SfxReward

# ── Controllers & handlers ──
var event_bus := CombatEventBus.new()
var current_phase := ""
var combat_state := CombatState.new()
var ui_controller := CombatUIController.new()
var combat_flow := CombatFlowController.new()
var reward_flow := RewardFlowController.new()

func _ready() -> void:
	event_bus.name = "CombatEventBus"
	add_child(event_bus)
	
	# Wire controllers
	ui_controller.setup(self, combat_flow)
	reward_flow.setup(self, ui_controller, combat_flow)
	combat_flow.setup(self)
	
	_verify_handlers()
	story_label.text = "你踏上 %s 的山道，魔物在雾中伺机。" % GameData.MOUNTAIN_NAME
	
	# Connect UI signals
	back_button.pressed.connect(_on_back_pressed)
	end_turn_button.pressed.connect(combat_flow.on_end_turn_pressed)
	next_button.pressed.connect(_on_next_pressed)
	reward_upgrade_button.pressed.connect(reward_flow._on_reward_upgrade_pressed)
	reward_remove_button.pressed.connect(reward_flow._on_reward_remove_pressed)
	reward_heal_button.pressed.connect(reward_flow._on_reward_heal_pressed)
	reward_draft_button.pressed.connect(reward_flow._on_reward_draft_pressed)
	reward_skip_button.pressed.connect(reward_flow._on_reward_skip_pressed)
	shop_refresh_button.pressed.connect(reward_flow.on_shop_refresh_pressed)
	shop_skip_button.pressed.connect(reward_flow.on_shop_skip_pressed)
	discard_confirm_button.pressed.connect(reward_flow._on_discard_confirm_pressed)
	route_supply_button.pressed.connect(reward_flow.on_route_supply_pressed)
	route_challenge_button.pressed.connect(reward_flow.on_route_challenge_pressed)
	difficulty_normal_button.pressed.connect(reward_flow.on_difficulty_selected.bind("normal"))
	difficulty_hard_button.pressed.connect(reward_flow.on_difficulty_selected.bind("hard"))
	difficulty_elite_button.pressed.connect(reward_flow.on_difficulty_selected.bind("elite"))
	score_continue_button.pressed.connect(reward_flow.on_score_continue_pressed)
	
	# Init UI state
	card_detail_panel.visible = false
	battle_log_panel.set_max_lines(MAX_BATTLE_LOG_LINES)
	
	# Overlays start hidden (scene handles visible=false)
	combat_state.reward_overlay_active = false
	combat_state.shop_overlay_active = false
	combat_state.discard_overlay_active = false
	combat_state.route_overlay_active = false
	combat_state.score_overlay_active = false
	
	combat_flow.start_encounter()

func _verify_handlers() -> void:
	var h := $CombatPipeline
	if h.has_node("StatusResolutionHandler"):
		h.get_node("StatusResolutionHandler").setup(event_bus, self)
	if h.has_node("CardEffectExecutor"):
		h.get_node("CardEffectExecutor").setup(self)
	if h.has_node("CardEffectHandler"):
		h.get_node("CardEffectHandler").setup(event_bus, h.get_node("CardEffectExecutor"))
	if h.has_node("TargetReactionHandler"):
		h.get_node("TargetReactionHandler").setup(event_bus, self)

func _on_next_pressed() -> void:
	if not combat_state.combat_over:
		return
	if combat_state.run_complete:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		return
	combat_flow.start_encounter()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")