extends Node

var bus: CombatEventBus
var context: Node

func setup(bus_ref: CombatEventBus, context_ref: Node) -> void:
	bus = bus_ref
	context = context_ref
	if bus:
		bus.phase_started.connect(_on_phase_started)

func _on_phase_started(phase: String, payload: Dictionary) -> void:
	if phase != BattlePhases.TARGET_REACTION:
		return
	if context and true:
		context.combat_flow.check_enemy_defeat()
