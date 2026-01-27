extends Control

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var save_info_label: Label = $CenterContainer/VBoxContainer/SaveInfoLabel
@onready var clear_save_button: Button = $CenterContainer/VBoxContainer/ClearSaveButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	clear_save_button.pressed.connect(_on_clear_save_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_refresh_save_ui()

func _on_start_pressed() -> void:
	RunState.start_run()
	get_tree().change_scene_to_file("res://scenes/RunScreen.tscn")

func _on_continue_pressed() -> void:
	if not RunState.load_run():
		RunState.start_run()
	get_tree().change_scene_to_file("res://scenes/RunScreen.tscn")

func _on_clear_save_pressed() -> void:
	RunState.clear_save()
	_refresh_save_ui()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _refresh_save_ui() -> void:
	var summary := RunState.get_save_summary()
	var has_save := not summary.is_empty()
	continue_button.visible = has_save and bool(summary.get("run_active", false))
	clear_save_button.visible = has_save
	if not has_save:
		save_info_label.text = "暂无存档。"
		return
	var progress := "%d / %d" % [summary.get("encounters_completed", 0), summary.get("max_encounters", 0)]
	var hp := "%d / %d" % [summary.get("player_hp", 0), summary.get("player_max_hp", 0)]
	var last_event: String = str(summary.get("last_event", ""))
	save_info_label.text = "存档进度：%s  生命：%s" % [progress, hp]
	if not last_event.is_empty():
		save_info_label.text += "\\n最近记录：%s" % last_event
