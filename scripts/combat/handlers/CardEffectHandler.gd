extends Node

var bus: CombatEventBus
var executor: Node

func setup(bus_ref: CombatEventBus, executor_ref: Node) -> void:
	bus = bus_ref
	executor = executor_ref
	if bus:
		bus.phase_started.connect(_on_phase_started)

func _on_phase_started(phase: String, payload: Dictionary) -> void:
	if phase != BattlePhases.CARD_EFFECT:
		return
	if not executor:
		return
	var card_data: Dictionary = payload.get("card_data", {})
	if card_data.is_empty():
		return
	if executor.has_method("execute"):
		executor.call("execute", card_data, payload)
