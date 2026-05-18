# =============================================================================
# Schema Consistency Validator
# Run from Godot 4.3 via: Scene > Run (as tool script), or attach to any node.
# Checks that all CombatState field names referenced in scripts exist.
# =============================================================================
extends Node

# Fields that exist in CombatState.gd (generated from class definition)
const EXPECTED_FIELDS := {
	# Actor
	"player_actor": "CombatActor",
	"enemy_actor": "CombatActor",
	# Enemy encounter data
	"enemy_data": "Dictionary",
	"enemy_attack_bonus": "int",
	"enemy_intent_card": "Dictionary",
	"enemy_power_mult": "float",
	"enemy_bleed": "int",
	"enemy_poison": "int",
	"enemy_burn": "int",
	"enemy_block_gain_reduction": "int",
	# Player statuses
	"weak_turns": "int",
	"vulnerable_turns": "int",
	"next_attack_mult": "float",
	"next_attack_bonus": "int",
	"next_attack_pierce": "bool",
	"counter_ratio": "float",
	"nullify_count": "int",
	"damage_draw": "int",
	"bleed_on_attack": "int",
	"attack_bonus_on_attack": "int",
	"damage_bonus_turn": "int",
	"block_disabled": "bool",
	"next_card_cost_delta": "int",
	"skip_enemy_turn": "bool",
	"attack_chain": "int",
	"defend_chain": "int",
	# Equipment
	"equip_attack_bonus": "int",
	"equip_damage_reduction": "int",
	"equip_attack_chain_draw": "int",
	"equip_defend_chain_block": "int",
	"equip_block_on_damage": "int",
	"equip_bleed_bonus_per_stack": "int",
	# Powers
	"power_first_attack_draw": "int",
	"power_first_damage_block": "int",
	"power_bleed_on_damage": "int",
	"power_first_attack_draw_used": "bool",
	"power_first_damage_block_used": "bool",
	# Combat flow
	"combat_over": "bool",
	"run_complete": "bool",
	"next_step": "String",
	"turn_index": "int",
	"enemy_acting": "bool",
	"turn_locked": "bool",
	"end_turn_phase_pending": "bool",
	"combat_difficulty": "String",
	"combat_damage_dealt": "int",
	"combat_damage_taken": "int",
	"combat_attack_count": "int",
	# Reward/route/overlay
	"reward_mode": "String",
	"last_reward_mode": "String",
	"reward_cards": "Array",
	"route_mode": "String",
	"supply_available": "bool",
	"shop_offer_cards": "Array",
	"shop_offer_costs": "Dictionary",
	"discard_required": "int",
	"discard_selection": "Array",
	"discard_card_widgets": "Dictionary",
	"discard_locked_indices": "Dictionary",
	# Overlay visibility
	"reward_overlay_active": "bool",
	"shop_overlay_active": "bool",
	"route_overlay_active": "bool",
	"score_overlay_active": "bool",
	"discard_overlay_active": "bool",
	"hand_slot_tweens": "Dictionary",
}

# Scripts to scan (relative to res://)
const SCRIPTS_TO_SCAN := [
	"scripts/RunScreen.gd",
	"scripts/combat/controllers/CombatFlowController.gd",
	"scripts/combat/controllers/CombatUIController.gd",
	"scripts/combat/controllers/RewardFlowController.gd",
	"scripts/combat/handlers/CardEffectExecutor.gd",
	"scripts/combat/handlers/StatusResolutionHandler.gd",
	"scripts/combat/handlers/TargetReactionHandler.gd",
]

func _ready() -> void:
	# Run as tool script
	if Engine.is_editor_hint():
		_validate_all()

func _run_validation() -> void:
	print("=" * 60)
	print("CombatState Schema Validator")
	print("=" * 60)
	var passed := true
	var state := CombatState.new()
	var old_refs := _find_old_prefix_references()
	if not old_refs.is_empty():
		passed = false
		print("❌ Found old-style field references (player_ prefix):")
		for ref in old_refs:
			print("   %s:%d  %s" % [ref.file, ref.line, ref.text])
	
	var missing := _find_missing_fields(state)
	if not missing.is_empty():
		passed = false
		print("❌ References to non-existent CombatState fields:")
		for ref in missing:
			print("   %s:%d  %s" % [ref.file, ref.line, ref.text])
	
	var new_fields := _unused := _find_unused_fields(state)
	# (info only, not failure)
	
	if passed:
		print("✅ All field references are valid!")
	else:
		print("❌ Validation failed. Fix errors above before running.")
	
	print("=" * 60)

static func validate() -> void:
	var v = preload("res://scripts/validation/SchemaValidator.gd").new()
	v._run_validation()

# ── Internals ──

func _find_old_prefix_references() -> Array:
	var results := []
	var patterns := [
		"player_weak_turns", "player_vulnerable_turns", "player_next_attack_mult",
		"player_next_attack_bonus", "player_next_attack_pierce", "player_counter_ratio",
		"player_nullify_count", "player_damage_draw", "player_bleed_on_attack",
		"player_attack_bonus_on_attack", "player_damage_bonus_turn", "player_block_disabled",
		"player_next_card_cost_delta", "player_skip_enemy_turn", "player_attack_chain",
		"player_defend_chain"
	]
	for script_path in SCRIPTS_TO_SCAN:
		var file := FileAccess.open("res://" + script_path, FileAccess.READ)
		if not file:
			continue
		var line_num := 0
		while not file.eof_reached():
			var line := file.get_line()
			line_num += 1
			for pat in patterns:
				if "combat_state." + pat in line or "state." + pat in line:
					results.append({
						"file": script_path, "line": line_num, "text": line.strip_edges()
					})
		file.close()
	return results

func _find_missing_fields(state: CombatState) -> Array:
	var results := []
	for script_path in SCRIPTS_TO_SCAN:
		var file := FileAccess.open("res://" + script_path, FileAccess.READ)
		if not file:
			continue
		var line_num := 0
		while not file.eof_reached():
			var line := file.get_line()
			line_num += 1
			# Find "combat_state.SOMETHING" or "state.SOMETHING" patterns
			var matches := []
			# Simple pattern matching
			var idx := line.find("combat_state.")
			while idx >= 0:
				var rest := line.substr(idx + 14)
				var end_idx := 0
				for c in range(rest.length()):
					var ch := rest[c]
					if ch >= 'a' and ch <= 'z' or ch >= 'A' and ch <= 'Z' or ch == '_':
						end_idx = c + 1
					else:
						break
				var field := rest.substr(0, end_idx)
				if not field.is_empty() and field not in ["player_actor", "enemy_actor"]:
					if not EXPECTED_FIELDS.has(field):
						if field not in ["get", "set", "setup"]:  # skip method calls
							matches.append(field)
				idx := line.find("combat_state.", idx + 14)
			
			idx := line.find("state.")
			while idx >= 0:
				var rest := line.substr(idx + 6)
				var end_idx := 0
				for c in range(rest.length()):
					var ch := rest[c]
					if ch >= 'a' and ch <= 'z' or ch >= 'A' and ch <= 'Z' or ch == '_':
						end_idx = c + 1
					else:
						break
				var field := rest.substr(0, end_idx)
				if not field.is_empty() and field not in ["player_actor", "enemy_actor"]:
					if not EXPECTED_FIELDS.has(field) and field != "":
						if field not in ["get", "set"]:
							matches.append(field)
				idx := line.find("state.", idx + 6)
			
			for m in matches:
				results.append({"file": script_path, "line": line_num, "text": m})
		file.close()
	return results

func _find_unused_fields(state: CombatState) -> Array:
	var used := {}
	for script_path in SCRIPTS_TO_SCAN:
		var file := FileAccess.open("res://" + script_path, FileAccess.READ)
		if not file:
			continue
		while not file.eof_reached():
			var line := file.get_line()
			for field in EXPECTED_FIELDS.keys():
				if "combat_state." + field in line or "state." + field in line:
					used[field] = true
		file.close()
	var unused := []
	for field in EXPECTED_FIELDS.keys():
		if not used.has(field):
			unused.append(field)
	if not unused.is_empty():
		print("ℹ️ Unused fields (may be valid if set only in CombatState init):")
		for f in unused:
			print("   - %s" % f)
	return unused