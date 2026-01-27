class_name CombatEventBus
extends Node

signal phase_started(phase: String, payload: Dictionary)
signal phase_completed(phase: String, payload: Dictionary)

func start_phase(phase: String, payload: Dictionary = {}) -> void:
	phase_started.emit(phase, payload)

func end_phase(phase: String, payload: Dictionary = {}) -> void:
	phase_completed.emit(phase, payload)
