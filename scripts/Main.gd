extends Control

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var deck_button: Button = $CenterContainer/VBoxContainer/DeckButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	deck_button.pressed.connect(_on_deck_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	continue_button.visible = RunState.has_save()

func _on_start_pressed() -> void:
	RunState.start_run()
	get_tree().change_scene_to_file("res://scenes/RunScreen.tscn")

func _on_continue_pressed() -> void:
	if not RunState.load_run():
		RunState.start_run()
	get_tree().change_scene_to_file("res://scenes/RunScreen.tscn")

func _on_deck_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/DeckBuilder.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
