extends Node

var bus: CombatEventBus
var context: Node

func setup(bus_ref: CombatEventBus, context_ref: Node) -> void:
	bus = bus_ref
	context = context_ref
	if bus:
		bus.phase_started.connect(_on_phase_started)

func _on_phase_started(phase: String, payload: Dictionary) -> void:
	if phase != BattlePhases.STATUS_RESOLVE:
		return
	if context and context.has_method("_handle_status_resolution"):
		context.call("_handle_status_resolution", payload)
