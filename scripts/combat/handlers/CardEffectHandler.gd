extends Node

var bus: CombatEventBus
var context: Node

func setup(bus_ref: CombatEventBus, context_ref: Node) -> void:
	bus = bus_ref
	context = context_ref
	if bus:
		bus.phase_started.connect(_on_phase_started)

func _on_phase_started(phase: String, payload: Dictionary) -> void:
	if phase != BattlePhases.CARD_EFFECT:
		return
	if not context:
		return
	var card_data: Dictionary = payload.get("card_data", {})
	if card_data.is_empty():
		return
	if context.has_method("_handle_card_effect"):
		context.call("_handle_card_effect", card_data, payload)
