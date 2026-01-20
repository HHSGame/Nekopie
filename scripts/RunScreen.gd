extends Control

@onready var story_label: Label = %StoryLabel
@onready var progress_label: Label = %ProgressLabel
@onready var deck_label: Label = %DeckLabel
@onready var result_label: Label = %ResultLabel
@onready var next_button: Button = %NextButton
@onready var back_button: Button = %BackButton

var completed := false

func _ready() -> void:
	story_label.text = "你踏上 %s 的山道，魔物在雾中伺机。" % GameData.MOUNTAIN_NAME
	back_button.pressed.connect(_on_back_pressed)
	next_button.pressed.connect(_on_next_pressed)
	_update_ui()

func _update_ui() -> void:
	progress_label.text = "攀登进度：%d / %d" % [RunState.encounters_completed, RunState.max_encounters]
	deck_label.text = "当前卡组：%d 张牌" % RunState.deck.size()
	if completed:
		next_button.text = "返回主菜单"
	else:
		next_button.text = "继续攀登"

func _on_next_pressed() -> void:
	if completed:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		return
	var reached_peak := RunState.advance_encounter()
	if reached_peak:
		completed = true
		result_label.text = "你征服了 %s，登顶通关！" % GameData.MOUNTAIN_NAME
	else:
		result_label.text = "你击退了一批魔物，继续向上。"
	_update_ui()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
