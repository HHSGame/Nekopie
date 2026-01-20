extends Node
class_name RunState

var deck: Array = []
var encounters_completed := 0
var max_encounters := 5
var run_active := false

func _ready() -> void:
	if deck.is_empty():
		reset_run()

func reset_run() -> void:
	deck = GameData.STARTER_DECK.duplicate(true)
	encounters_completed = 0
	run_active = false

func start_run() -> void:
	run_active = true
	encounters_completed = 0

func advance_encounter() -> bool:
	if encounters_completed < max_encounters:
		encounters_completed += 1
	return encounters_completed >= max_encounters
