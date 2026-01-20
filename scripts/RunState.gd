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

func start_run() -> void:
	run_active = true
	encounters_completed = 0
	max_encounters = GameData.ENCOUNTERS.size()
	player_hp = player_max_hp
	next_encounter_first_strike = false
	next_encounter_first_strike_bonus = 0
	current_enemy_id = ""
	upgraded_cards.clear()

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
	return encounters_completed >= max_encounters

func is_upgraded(card_id: String) -> bool:
	return bool(upgraded_cards.get(card_id, false))

func upgrade_card(card_id: String) -> void:
	upgraded_cards[card_id] = true
