extends Control

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var leaderboard_empty_label: Label = $CenterContainer/VBoxContainer/LeaderboardPanel/LeaderboardMargin/LeaderboardVBox/LeaderboardEmptyLabel
@onready var leaderboard_list: VBoxContainer = $CenterContainer/VBoxContainer/LeaderboardPanel/LeaderboardMargin/LeaderboardVBox/LeaderboardScroll/LeaderboardList
@onready var leaderboard_overlay: Control = $LeaderboardOverlay
@onready var leaderboard_detail_info: Label = $LeaderboardOverlay/CenterContainer/LeaderboardDetailPanel/LeaderboardDetailMargin/LeaderboardDetailVBox/LeaderboardDetailInfo
@onready var leaderboard_detail_list: VBoxContainer = $LeaderboardOverlay/CenterContainer/LeaderboardDetailPanel/LeaderboardDetailMargin/LeaderboardDetailVBox/LeaderboardDetailScroll/LeaderboardDetailList
@onready var leaderboard_detail_close: Button = $LeaderboardOverlay/CenterContainer/LeaderboardDetailPanel/LeaderboardDetailMargin/LeaderboardDetailVBox/LeaderboardDetailClose
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

var leaderboard_entries: Array = []

func _ready() -> void:
	RunState.load_run()
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	leaderboard_detail_close.pressed.connect(_on_leaderboard_close_pressed)
	leaderboard_overlay.visible = false
	_refresh_menu_ui()

func _on_start_pressed() -> void:
	RunState.start_run()
	get_tree().change_scene_to_file("res://scenes/RunScreen.tscn")

func _on_continue_pressed() -> void:
	if not RunState.load_run():
		RunState.start_run()
	get_tree().change_scene_to_file("res://scenes/RunScreen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _refresh_menu_ui() -> void:
	continue_button.visible = RunState.run_active
	_refresh_leaderboard_ui()

func _refresh_leaderboard_ui() -> void:
	leaderboard_entries = RunState.leaderboard.duplicate(true)
	_clear_container(leaderboard_list)
	if leaderboard_entries.is_empty():
		leaderboard_empty_label.visible = true
		return
	leaderboard_empty_label.visible = false
	for index in leaderboard_entries.size():
		var entry: Dictionary = leaderboard_entries[index]
		var score_value := int(entry.get("score", 0))
		var time_text := str(entry.get("time", ""))
		var button := Button.new()
		button.text = "%d. %d 分 %s" % [index + 1, score_value, time_text]
		button.pressed.connect(_on_leaderboard_entry_pressed.bind(index))
		leaderboard_list.add_child(button)

func _on_leaderboard_entry_pressed(index: int) -> void:
	if index < 0 or index >= leaderboard_entries.size():
		return
	var entry: Dictionary = leaderboard_entries[index]
	var score_value := int(entry.get("score", 0))
	var time_text := str(entry.get("time", ""))
	leaderboard_detail_info.text = "得分：%d  时间：%s" % [score_value, time_text]
	_clear_container(leaderboard_detail_list)
	var deck: Array = Array(entry.get("deck", []))
	if deck.is_empty():
		var empty_label := Label.new()
		empty_label.text = "未记录卡组。"
		leaderboard_detail_list.add_child(empty_label)
	else:
		for card_entry in deck:
			var card_id := RunState.get_card_id(card_entry)
			var upgrade_level := RunState.get_card_upgrade_level(card_entry)
			var card_data := GameData.get_card_data(card_id, upgrade_level)
			var card_name := str(card_data.get("name", card_id))
			if upgrade_level > 0:
				card_name += "+%d" % upgrade_level
			var label := Label.new()
			label.text = card_name
			leaderboard_detail_list.add_child(label)
	leaderboard_overlay.visible = true

func _on_leaderboard_close_pressed() -> void:
	leaderboard_overlay.visible = false

func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()
