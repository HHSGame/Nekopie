extends Node

var deck: Array = []
var encounters_completed := 0
var max_encounters := 0
var run_active := false
var player_max_hp := 40
var player_hp := 40
var energy_max := 3
var next_encounter_first_strike := false
var next_encounter_first_strike_bonus := 0
var current_enemy_id := ""
var upgraded_cards: Dictionary = {}
var run_log: Array = []
var next_difficulty := "normal"
var run_score_total := 0
var run_score_finalized := false
var last_run_score := 0
var last_run_rank := 0
var leaderboard: Array = []

const SAVE_PATH := "user://savegame.json"
const LEADERBOARD_MAX := 10
const STARTING_ENERGY := 3
const CARD_ENTRY_ID := "id"
const CARD_ENTRY_UPGRADE := "upgrade"
const DIFFICULTY_SETTINGS := {
	"normal": {"label": "普通", "hp_mult": 1.0, "power_mult": 1.0, "score_mult": 1.0},
	"hard": {"label": "困难", "hp_mult": 1.2, "power_mult": 1.15, "score_mult": 1.25},
	"elite": {"label": "精英", "hp_mult": 1.4, "power_mult": 1.3, "score_mult": 1.5}
}

func _ready() -> void:
	if deck.is_empty():
		reset_run()

func reset_run() -> void:
	deck = _build_starting_deck()
	encounters_completed = 0
	max_encounters = GameData.ENCOUNTERS.size()
	run_active = false
	player_hp = player_max_hp
	energy_max = STARTING_ENERGY
	next_encounter_first_strike = false
	next_encounter_first_strike_bonus = 0
	current_enemy_id = ""
	upgraded_cards.clear()
	run_log.clear()
	next_difficulty = "normal"
	run_score_total = 0
	run_score_finalized = false
	last_run_score = 0
	last_run_rank = 0
	save_run()

func start_run() -> void:
	run_active = true
	encounters_completed = 0
	max_encounters = GameData.ENCOUNTERS.size()
	player_hp = player_max_hp
	energy_max = STARTING_ENERGY
	next_encounter_first_strike = false
	next_encounter_first_strike_bonus = 0
	current_enemy_id = ""
	upgraded_cards.clear()
	run_log.clear()
	next_difficulty = "normal"
	run_score_total = 0
	run_score_finalized = false
	last_run_score = 0
	last_run_rank = 0
	log_event("旅程开始。")
	save_run()

func reset_after_run() -> void:
	deck = _build_starting_deck()
	encounters_completed = 0
	max_encounters = GameData.ENCOUNTERS.size()
	run_active = false
	player_hp = player_max_hp
	energy_max = STARTING_ENERGY
	next_encounter_first_strike = false
	next_encounter_first_strike_bonus = 0
	current_enemy_id = ""
	upgraded_cards.clear()
	next_difficulty = "normal"
	run_score_total = 0
	run_score_finalized = false
	save_run()

func get_current_enemy_id() -> String:
	if encounters_completed < max_encounters:
		return GameData.ENCOUNTERS[encounters_completed]
	return ""

func start_encounter() -> Dictionary:
	current_enemy_id = get_current_enemy_id()
	return GameData.get_enemy(current_enemy_id).duplicate(true)

func complete_encounter() -> bool:
	if encounters_completed < max_encounters:
		encounters_completed += 1
		if encounters_completed % 3 == 0:
			energy_max += 1
	current_enemy_id = ""
	save_run()
	return encounters_completed >= max_encounters

func make_card(card_id: String, upgrade_level: int = 0) -> Dictionary:
	return {CARD_ENTRY_ID: card_id, CARD_ENTRY_UPGRADE: upgrade_level}

func get_card_id(card_entry: Variant) -> String:
	if typeof(card_entry) == TYPE_DICTIONARY:
		return str(card_entry.get(CARD_ENTRY_ID, ""))
	return str(card_entry)

func get_card_upgrade_level(card_entry: Variant) -> int:
	if typeof(card_entry) == TYPE_DICTIONARY:
		if card_entry.has(CARD_ENTRY_UPGRADE):
			return int(card_entry.get(CARD_ENTRY_UPGRADE, 0))
		if card_entry.has("upgraded"):
			return 1 if bool(card_entry.get("upgraded", false)) else 0
	return 1 if bool(upgraded_cards.get(str(card_entry), false)) else 0

func is_card_upgraded(card_entry: Variant) -> bool:
	return get_card_upgrade_level(card_entry) > 0

func is_upgraded(card_entry: Variant) -> bool:
	return is_card_upgraded(card_entry)

func upgrade_card_at(index: int) -> void:
	if index < 0 or index >= deck.size():
		return
	if typeof(deck[index]) == TYPE_DICTIONARY:
		var card_id := get_card_id(deck[index])
		var current := get_card_upgrade_level(deck[index])
		var max_level := GameData.get_max_upgrade_level(card_id)
		if current >= max_level:
			return
		deck[index][CARD_ENTRY_UPGRADE] = current + 1
	else:
		var card_id := str(deck[index])
		var max_level := GameData.get_max_upgrade_level(card_id)
		if max_level <= 0:
			return
		deck[index] = make_card(card_id, 1)
	save_run()

func upgrade_card(card_id: String) -> void:
	for index in deck.size():
		var entry = deck[index]
		if get_card_id(entry) == card_id and get_card_upgrade_level(entry) < GameData.get_max_upgrade_level(card_id):
			upgrade_card_at(index)
			return

func add_card(card_id: String) -> void:
	deck.append(make_card(card_id, 0))
	save_run()

func log_event(message: String) -> void:
	run_log.append({
		"time": Time.get_datetime_string_from_system(),
		"message": message
	})
	save_run()

func get_difficulty_settings(difficulty: String) -> Dictionary:
	return DIFFICULTY_SETTINGS.get(difficulty, DIFFICULTY_SETTINGS["normal"])

func add_combat_score(score: int) -> void:
	run_score_total += score
	save_run()

func roll_supply_available() -> bool:
	return randf() < GameData.SUPPLY_CHANCE

func set_card_upgrade_level(card_entry: Variant, level: int) -> void:
	if typeof(card_entry) == TYPE_DICTIONARY:
		card_entry["upgrade"] = level
	else:
		upgraded_cards[str(card_entry)] = level > 0

func get_current_leaderboard_rank_text() -> String:
	if leaderboard.is_empty():
		return "无记录"
	if last_run_rank > 0:
		return "第%d名" % last_run_rank
	return "未上榜"

func finalize_run_score() -> void:
	if run_score_finalized:
		return
	run_score_finalized = true
	last_run_score = run_score_total
	var entry := {
		"score": last_run_score,
		"time": Time.get_datetime_string_from_system(),
		"deck": deck.duplicate(true)
	}
	leaderboard.append(entry)
	leaderboard.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("score", 0)) > int(b.get("score", 0))
	)
	if leaderboard.size() > LEADERBOARD_MAX:
		leaderboard.resize(LEADERBOARD_MAX)
	last_run_rank = 0
	for index in leaderboard.size():
		var item: Dictionary = leaderboard[index]
		if item.get("score") == entry.get("score") and item.get("time") == entry.get("time"):
			last_run_rank = index + 1
			break
	save_run()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func get_save_summary() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var data: Dictionary = parsed
	var log_entries: Array = Array(data.get("run_log", []))
	var last_message := ""
	if not log_entries.is_empty():
		var last_entry: Dictionary = log_entries.back()
		last_message = str(last_entry.get("message", ""))
	return {
		"run_active": bool(data.get("run_active", false)),
		"encounters_completed": int(data.get("encounters_completed", 0)),
		"max_encounters": int(data.get("max_encounters", 0)),
		"player_hp": int(data.get("player_hp", 0)),
		"player_max_hp": int(data.get("player_max_hp", 0)),
		"last_event": last_message
	}

func save_run() -> void:
	_normalize_deck()
	var data := {
		"deck": deck,
		"encounters_completed": encounters_completed,
		"max_encounters": max_encounters,
		"run_active": run_active,
		"player_max_hp": player_max_hp,
		"player_hp": player_hp,
		"energy_max": energy_max,
		"next_encounter_first_strike": next_encounter_first_strike,
		"next_encounter_first_strike_bonus": next_encounter_first_strike_bonus,
		"current_enemy_id": current_enemy_id,
		"upgraded_cards": upgraded_cards,
		"run_log": run_log,
		"next_difficulty": next_difficulty,
		"run_score_total": run_score_total,
		"run_score_finalized": run_score_finalized,
		"last_run_score": last_run_score,
		"last_run_rank": last_run_rank,
		"leaderboard": leaderboard
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_run() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var data: Dictionary = parsed
	var deck_data: Array = Array(data.get("deck", []))
	encounters_completed = int(data.get("encounters_completed", 0))
	max_encounters = int(data.get("max_encounters", GameData.ENCOUNTERS.size()))
	run_active = bool(data.get("run_active", false))
	player_max_hp = int(data.get("player_max_hp", player_max_hp))
	player_hp = int(data.get("player_hp", player_max_hp))
	energy_max = int(data.get("energy_max", STARTING_ENERGY))
	next_encounter_first_strike = bool(data.get("next_encounter_first_strike", false))
	next_encounter_first_strike_bonus = int(data.get("next_encounter_first_strike_bonus", 0))
	current_enemy_id = str(data.get("current_enemy_id", ""))
	upgraded_cards = {}
	var legacy_upgraded: Dictionary = data.get("upgraded_cards", {})
	deck = []
	for entry in deck_data:
		if typeof(entry) == TYPE_DICTIONARY:
			var card_id := str(entry.get(CARD_ENTRY_ID, ""))
			var level := 0
			if entry.has(CARD_ENTRY_UPGRADE):
				level = int(entry.get(CARD_ENTRY_UPGRADE, 0))
			elif entry.has("upgraded"):
				level = 1 if bool(entry.get("upgraded", false)) else 0
			elif legacy_upgraded.get(card_id, false):
				level = 1
			deck.append(make_card(card_id, level))
		else:
			var card_id := str(entry)
			var level := 1 if bool(legacy_upgraded.get(card_id, false)) else 0
			deck.append(make_card(card_id, level))
	run_log = Array(data.get("run_log", []))
	next_difficulty = str(data.get("next_difficulty", "normal"))
	run_score_total = int(data.get("run_score_total", 0))
	run_score_finalized = bool(data.get("run_score_finalized", false))
	last_run_score = int(data.get("last_run_score", 0))
	last_run_rank = int(data.get("last_run_rank", 0))
	leaderboard = Array(data.get("leaderboard", []))
	return true

func clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _build_starting_deck() -> Array:
	var result: Array = []
	for card_id in GameData.STARTER_DECK:
		result.append(make_card(str(card_id), 0))
	return result

func _normalize_deck() -> void:
	var normalized: Array = []
	for entry in deck:
		if typeof(entry) == TYPE_DICTIONARY and entry.has(CARD_ENTRY_ID):
			var card_id := str(entry.get(CARD_ENTRY_ID, ""))
			var level := get_card_upgrade_level(entry)
			normalized.append(make_card(card_id, level))
		else:
			var card_id := str(entry)
			var level := 1 if bool(upgraded_cards.get(card_id, false)) else 0
			normalized.append(make_card(card_id, level))
	deck = normalized
