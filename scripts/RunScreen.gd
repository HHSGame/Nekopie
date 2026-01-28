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
@onready var player_portrait_panel: PortraitPanel = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerPortraitPanel
@onready var enemy_portrait_panel: PortraitPanel = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/EnemyColumn/EnemyPortraitPanel
@onready var player_hp_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerHpRow/PlayerHpLabel
@onready var player_block_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerBlockRow/PlayerBlockLabel
@onready var energy_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerEnergyRow/EnergyLabel
@onready var draw_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerDeckRow/DrawLabel
@onready var discard_label: Label = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerDeckRow/DiscardLabel
@onready var player_hp_bar: ProgressBar = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/PlayerColumn/PlayerStatsPanel/PlayerStatsMargin/PlayerStatsVBox/PlayerHpBar
@onready var battle_log_panel: BattleLogPanel = $MarginContainer/RootVBox/BattlePanel/BattleMargin/BattleHBox/BattleCenterColumn/BattleLogPanel
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
@onready var status_handler: Node = $CombatPipeline/StatusResolutionHandler
@onready var card_effect_handler: Node = $CombatPipeline/CardEffectHandler
@onready var card_effect_executor: Node = $CombatPipeline/CardEffectExecutor
@onready var target_reaction_handler: Node = $CombatPipeline/TargetReactionHandler

var event_bus := CombatEventBus.new()
var current_phase := ""
var combat_state := CombatState.new()
var ui_controller := CombatUIController.new()
var combat_flow := CombatFlowController.new()
var reward_flow := RewardFlowController.new()

func _ready() -> void:
	event_bus.name = "CombatEventBus"
	add_child(event_bus)
	ui_controller.setup(self, combat_flow, reward_flow)
	reward_flow.setup(self, ui_controller, combat_flow)
	combat_flow.setup(self, ui_controller, reward_flow)
	if status_handler:
		status_handler.setup(event_bus, self)
	if card_effect_executor:
		card_effect_executor.setup(self)
	if card_effect_handler:
		card_effect_handler.setup(event_bus, card_effect_executor)
	if target_reaction_handler:
		target_reaction_handler.setup(event_bus, self)
	story_label.text = "你踏上 %s 的山道，魔物在雾中伺机。" % GameData.MOUNTAIN_NAME
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
	card_detail_panel.visible = false
	battle_log_panel.set_max_lines(MAX_BATTLE_LOG_LINES)
	reward_overlay.modulate.a = 0.0
	combat_state.reward_overlay_active = reward_overlay.visible
	shop_overlay.visible = false
	shop_overlay.modulate.a = 0.0
	combat_state.shop_overlay_active = shop_overlay.visible
	discard_overlay.visible = false
	discard_overlay.modulate.a = 0.0
	combat_state.discard_overlay_active = discard_overlay.visible
	route_overlay.visible = false
	combat_state.route_overlay_active = route_overlay.visible
	score_overlay.visible = false
	combat_state.score_overlay_active = score_overlay.visible
	combat_flow.start_encounter()

func _reset_battle_log() -> void:
	ui_controller.reset_battle_log()
func _append_battle_log(message: String) -> void:
	ui_controller.append_battle_log(message)
func _begin_phase(phase: String, payload: Dictionary = {}) -> void:
	current_phase = phase
	event_bus.start_phase(phase, payload)

func _end_phase(phase: String, payload: Dictionary = {}) -> void:
	event_bus.end_phase(phase, payload)

func _player_status_text() -> String:
	return ui_controller.player_status_text()
func _player_status_summary() -> String:
	return ui_controller.player_status_summary()
func _player_buff_summary() -> String:
	return ui_controller.player_buff_summary()
func _enemy_status_summary() -> String:
	return ui_controller.enemy_status_summary()
func _log_turn_start() -> void:
	combat_flow.log_turn_start()
func _log_turn_end() -> void:
	combat_flow.log_turn_end()
func _start_encounter() -> void:
	combat_flow.start_encounter()
func _update_ui() -> void:
	ui_controller.update_ui()
func _sync_player_hp() -> void:
	combat_flow.sync_player_hp()
func _refresh_hand() -> void:
	ui_controller.refresh_hand()
func _draw_cards(count: int) -> void:
	combat_flow.draw_cards(count)
func _draw_enemy_cards(count: int) -> void:
	combat_flow.draw_enemy_cards(count)
func _on_hand_card_hovered(card_id: String, index: int, slot: Control) -> void:
	ui_controller._on_hand_card_hovered(card_id, index, slot)
func _on_hand_card_unhovered(slot: Control) -> void:
	ui_controller._on_hand_card_unhovered(slot)
func _set_hand_slot_expanded(slot: Control, expanded: bool) -> void:
	ui_controller._set_hand_slot_expanded(slot, expanded)
func _on_hand_card_clicked(card_id: String, index: int) -> void:
	combat_flow.on_hand_card_clicked(card_id, index)
func _remove_card_from_hand(index: int) -> Variant:
	return combat_flow.remove_card_from_hand(index)
func _apply_player_damage(amount: int, pierce: bool) -> int:
	return combat_flow.apply_player_damage(amount, pierce)
func _gain_player_block(amount: int) -> bool:
	return combat_flow.gain_player_block(amount)
func _apply_ethereal_cleanup() -> void:
	combat_flow.apply_ethereal_cleanup()
func _on_end_turn_pressed() -> void:
	combat_flow.on_end_turn_pressed()
func _resolve_end_turn() -> void:
	await combat_flow.resolve_end_turn()
func _enemy_turn() -> void:
	await combat_flow.enemy_turn()
func _check_enemy_defeat() -> void:
	combat_flow.check_enemy_defeat()
func _on_next_pressed() -> void:
	if not combat_state.combat_over:
		return
	if combat_state.run_complete:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		return
	_start_encounter()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _refresh_enemy_intent() -> void:
	combat_flow.refresh_enemy_intent()
func _get_enemy_intent_card() -> Dictionary:
	return combat_flow.get_enemy_intent_card()
func _enemy_card_display(card_data: Dictionary) -> String:
	return combat_flow.enemy_card_display(card_data)
func _enemy_card_targets_player(intent_type: String) -> bool:
	return combat_flow.enemy_card_targets_player(intent_type)
func _play_enemy_hand() -> void:
	await combat_flow.play_enemy_hand()
func _wait(seconds: float) -> void:
	await combat_flow.wait(seconds)
func _play_enemy_action_fx(card_data: Dictionary) -> void:
	combat_flow.play_enemy_action_fx(card_data)
func _apply_enemy_card(card_data: Dictionary) -> void:
	combat_flow.apply_enemy_card(card_data)
func _apply_enemy_damage(amount: int) -> int:
	return combat_flow.apply_enemy_damage(amount)
func _apply_enemy_debuffs(weak_turns: int, vulnerable_turns: int) -> void:
	combat_flow.apply_enemy_debuffs(weak_turns, vulnerable_turns)
func _enemy_debuff_summary(card_data: Dictionary) -> String:
	return combat_flow.enemy_debuff_summary(card_data)
func _queue_post_battle_step() -> void:
	reward_flow.queue_post_battle_step()
func _enter_shop() -> void:
	reward_flow.enter_shop()
func _refresh_shop_offers() -> void:
	reward_flow.refresh_shop_offers()
func _build_shop_pool() -> Array:
	return reward_flow.build_shop_pool()
func _refresh_shop_ui() -> void:
	reward_flow.refresh_shop_ui()
func _populate_shop_cards() -> void:
	reward_flow._populate_shop_cards()
func _calculate_shop_cost(card_data: Dictionary) -> int:
	return reward_flow.calculate_shop_cost(card_data)
func _set_shop_overlay_visible(active: bool) -> void:
	reward_flow.set_shop_overlay_visible(active)
func _on_shop_refresh_pressed() -> void:
	reward_flow.on_shop_refresh_pressed()
func _on_shop_skip_pressed() -> void:
	reward_flow.on_shop_skip_pressed()
func _on_shop_buy_pressed(card_id: String) -> void:
	reward_flow.on_shop_buy_pressed(card_id)
func _enter_route_selection() -> void:
	reward_flow.enter_route_selection()
func _update_route_ui() -> void:
	reward_flow.update_route_ui()
func _on_route_supply_pressed() -> void:
	reward_flow.on_route_supply_pressed()
func _on_route_challenge_pressed() -> void:
	reward_flow.on_route_challenge_pressed()
func _on_difficulty_selected(difficulty: String) -> void:
	reward_flow.on_difficulty_selected(difficulty)
func _difficulty_display(difficulty: String) -> String:
	return reward_flow.difficulty_display(difficulty)
func _enter_supply_options() -> void:
	reward_flow.enter_supply_options()
func _refresh_reward_ui() -> void:
	reward_flow.refresh_reward_ui()
func _set_reward_overlay_visible(active: bool) -> void:
	reward_flow.set_reward_overlay_visible(active)
func _set_discard_overlay_visible(active: bool) -> void:
	reward_flow.set_discard_overlay_visible(active)
func _open_discard_overlay(required: int) -> void:
	reward_flow.open_discard_overlay(required)
func _build_discard_locks() -> void:
	reward_flow._build_discard_locks()
func _refresh_discard_ui() -> void:
	reward_flow._refresh_discard_ui()
func _populate_discard_cards() -> void:
	reward_flow._populate_discard_cards()
func _on_discard_card_clicked(card_id: String, index: int, widget: CardWidget) -> void:
	reward_flow._on_discard_card_clicked(card_id, index, widget)
func _on_discard_card_hovered(card_id: String, index: int) -> void:
	reward_flow._on_discard_card_hovered(card_id, index)
func _on_discard_confirm_pressed() -> void:
	await reward_flow._on_discard_confirm_pressed()
func _apply_discard_selection() -> void:
	reward_flow._apply_discard_selection()
func _on_reward_deck_card_hovered(card_id: String, index: int) -> void:
	reward_flow._on_reward_deck_card_hovered(card_id, index)
func _set_route_overlay_visible(active: bool) -> void:
	reward_flow.set_route_overlay_visible(active)
func _set_score_overlay_visible(active: bool) -> void:
	reward_flow.set_score_overlay_visible(active)
func _refresh_score_ui() -> void:
	reward_flow.refresh_score_ui()
func _on_score_continue_pressed() -> void:
	reward_flow.on_score_continue_pressed()
func _calculate_combat_score() -> int:
	return combat_flow.calculate_combat_score()
func _apply_difficulty_to_enemy(difficulty: String) -> void:
	combat_flow.apply_difficulty_to_enemy(difficulty)
func _populate_supply_cards() -> void:
	reward_flow.populate_supply_cards()
func _roll_reward_cards(count: int = 3) -> Array:
	return reward_flow._roll_reward_cards(count)
func _populate_reward_deck() -> void:
	reward_flow._populate_reward_deck()
func _on_reward_upgrade_pressed() -> void:
	reward_flow._on_reward_upgrade_pressed()
func _on_reward_remove_pressed() -> void:
	reward_flow._on_reward_remove_pressed()
func _on_reward_skip_pressed() -> void:
	reward_flow._on_reward_skip_pressed()
func _on_reward_heal_pressed() -> void:
	reward_flow._on_reward_heal_pressed()
func _on_reward_draft_pressed() -> void:
	reward_flow._on_reward_draft_pressed()
func _on_reward_card_selected(card_id: String) -> void:
	reward_flow._on_reward_card_selected(card_id)
func _on_reward_deck_card_selected(card_id: String, index: int) -> void:
	reward_flow._on_reward_deck_card_selected(card_id, index)
func _clear_container(container: Node) -> void:
	reward_flow._clear_container(container)
func _play_enemy_hit_effect() -> void:
	ui_controller.play_enemy_hit_effect()
func _play_player_hit_effect() -> void:
	ui_controller.play_player_hit_effect()
func _on_card_hovered(card_id: String, upgrade_level: int = 0) -> void:
	ui_controller.show_card_detail(card_id, upgrade_level)
func _on_card_unhovered() -> void:
	ui_controller.hide_card_detail()
func _enemy_card_color(card_data: Dictionary) -> Color:
	return ui_controller.enemy_card_color(card_data)
func _enemy_card_icon(card_data: Dictionary) -> Texture2D:
	return ui_controller.enemy_card_icon(card_data)
