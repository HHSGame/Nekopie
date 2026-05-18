class_name CombatState
extends RefCounted

# ── Actor references ──
var player_actor := CombatActor.new()
var enemy_actor := CombatActor.new()

# ── Enemy encounter data ──
var enemy_data: Dictionary = {}
var enemy_attack_bonus := 0
var enemy_intent_card: Dictionary = {}
var enemy_power_mult := 1.0
var enemy_bleed := 0
var enemy_poison := 0
var enemy_burn := 0
var enemy_block_gain_reduction := 0

# ── Player combat statuses ──
# These are per-turn/ephemeral effects applied by cards
var weak_turns := 0
var vulnerable_turns := 0
var next_attack_mult := 1.0
var next_attack_bonus := 0
var next_attack_pierce := false
var counter_ratio := 0.0
var nullify_count := 0
var damage_draw := 0
var bleed_on_attack := 0
var attack_bonus_on_attack := 0
var damage_bonus_turn := 0
var block_disabled := false
var next_card_cost_delta := 0
var skip_enemy_turn := false
var attack_chain := 0
var defend_chain := 0

# ── Equipment effects (persist per battle) ──
var equip_attack_bonus := 0
var equip_damage_reduction := 0
var equip_attack_chain_draw := 0
var equip_defend_chain_block := 0
var equip_block_on_damage := 0
var equip_bleed_bonus_per_stack := 0

# ── Power effects (persist per battle) ──
var power_first_attack_draw := 0
var power_first_damage_block := 0
var power_bleed_on_damage := 0
var power_first_attack_draw_used := false
var power_first_damage_block_used := false

# ── Combat flow state ──
var combat_over := false
var run_complete := false
var next_step := "encounter"
var turn_index := 1
var enemy_acting := false
var turn_locked := false
var end_turn_phase_pending := false
var combat_difficulty := "normal"
var combat_damage_dealt := 0
var combat_damage_taken := 0
var combat_attack_count := 0

# ── Reward / route / overlay state ──
var reward_mode := "none"
var last_reward_mode := ""
var reward_cards: Array = []
var route_mode := "none"
var supply_available := false
var shop_offer_cards: Array = []
var shop_offer_costs: Dictionary = {}
var discard_required := 0
var discard_selection: Array = []
var discard_card_widgets: Dictionary = {}
var discard_locked_indices: Dictionary = {}

# ── Overlay visibility & tweens ──
var reward_overlay_active := false
var reward_overlay_tween: Tween
var shop_overlay_active := false
var shop_overlay_tween: Tween
var route_overlay_active := false
var score_overlay_active := false
var discard_overlay_active := false
var discard_overlay_tween: Tween

# ── Hand slot tween tracking ──
var hand_slot_tweens: Dictionary = {}