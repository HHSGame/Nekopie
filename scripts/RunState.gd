extends Node

var deck: Array = []
var encounters_completed := 0
var max_encounters := 0
var run_active := false
var player_max_hp := 40
var player_hp := 40
var next_encounter_first_strike := false
var next_encounter_first_strike_bonus := 0
var current_enemy_id := ""
var upgraded_cards: Dictionary = {}
var run_log: Array = []

const SAVE_PATH := "user://savegame.json"

func _ready() -> void:
	if deck.is_empty():
		reset_run()

func reset_run() -> void:
	deck = GameData.STARTER_DECK.duplicate(true)
	encounters_completed = 0
	max_encounters = GameData.ENCOUNTERS.size()
	run_active = false
	player_hp = player_max_hp
	next_encounter_first_strike = false
	next_encounter_first_strike_bonus = 0
	current_enemy_id = ""
	upgraded_cards.clear()
	run_log.clear()
	save_run()

func start_run() -> void:
	run_active = true
	encounters_completed = 0
	max_encounters = GameData.ENCOUNTERS.size()
	player_hp = player_max_hp
	next_encounter_first_strike = false
	next_encounter_first_strike_bonus = 0
	current_enemy_id = ""
	upgraded_cards.clear()
	run_log.clear()
	log_event("旅程开始。")
	save_run()

func get_current_enemy_id() -> String:
	if encounters_completed < max_encounters:
		return GameData.ENCOUNTERS[encounters_completed]
	return ""

func start_encounter() -> Dictionary:
	current_enemy_id = get_current_enemy_id()
	return GameData.get_enemy(current_enemy_id)

func complete_encounter() -> bool:
	if encounters_completed < max_encounters:
		encounters_completed += 1
	current_enemy_id = ""
	save_run()
	return encounters_completed >= max_encounters

func is_upgraded(card_id: String) -> bool:
	return bool(upgraded_cards.get(card_id, false))

func upgrade_card(card_id: String) -> void:
	upgraded_cards[card_id] = true
	save_run()

func log_event(message: String) -> void:
	run_log.append({
		"time": Time.get_datetime_string_from_system(),
		"message": message
	})
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
	var data := {
		"deck": deck,
		"encounters_completed": encounters_completed,
		"max_encounters": max_encounters,
		"run_active": run_active,
		"player_max_hp": player_max_hp,
		"player_hp": player_hp,
		"next_encounter_first_strike": next_encounter_first_strike,
		"next_encounter_first_strike_bonus": next_encounter_first_strike_bonus,
		"current_enemy_id": current_enemy_id,
		"upgraded_cards": upgraded_cards,
		"run_log": run_log
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
	deck = Array(data.get("deck", []))
	encounters_completed = int(data.get("encounters_completed", 0))
	max_encounters = int(data.get("max_encounters", GameData.ENCOUNTERS.size()))
	run_active = bool(data.get("run_active", false))
	player_max_hp = int(data.get("player_max_hp", player_max_hp))
	player_hp = int(data.get("player_hp", player_max_hp))
	next_encounter_first_strike = bool(data.get("next_encounter_first_strike", false))
	next_encounter_first_strike_bonus = int(data.get("next_encounter_first_strike_bonus", 0))
	current_enemy_id = str(data.get("current_enemy_id", ""))
	upgraded_cards = {}
	var upgraded: Dictionary = data.get("upgraded_cards", {})
	for key in upgraded.keys():
		upgraded_cards[str(key)] = bool(upgraded[key])
	run_log = Array(data.get("run_log", []))
	return true

func clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
