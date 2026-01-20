extends Control

const CARD_WIDGET_SCENE := preload("res://scenes/CardWidget.tscn")

@onready var library_list: VBoxContainer = %LibraryList
@onready var deck_list: VBoxContainer = %DeckList
@onready var deck_count_label: Label = %DeckCountLabel
@onready var back_button: Button = %BackButton
@onready var story_label: Label = %StoryLabel

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	story_label.text = "%s\\n在 %s 的山脚下，你可以整理卡组迎战。" % [GameData.WORLD_TAGLINE, GameData.MOUNTAIN_NAME]
	_refresh_lists()

func _refresh_lists() -> void:
	_clear_container(library_list)
	_clear_container(deck_list)

	for card_data in GameData.all_cards():
		var widget: CardWidget = CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.clicked.connect(_on_library_card_clicked)
		library_list.add_child(widget)

	for card_id in RunState.deck:
		var card_data := GameData.get_card(card_id)
		var widget: CardWidget = CARD_WIDGET_SCENE.instantiate()
		widget.set_card(card_data)
		widget.clicked.connect(_on_deck_card_clicked)
		deck_list.add_child(widget)

	deck_count_label.text = "牌组数量：%d" % RunState.deck.size()

func _clear_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

func _on_library_card_clicked(card_id: String) -> void:
	if card_id.is_empty():
		return
	RunState.deck.append(card_id)
	_refresh_lists()

func _on_deck_card_clicked(card_id: String) -> void:
	var index := RunState.deck.find(card_id)
	if index >= 0:
		RunState.deck.remove_at(index)
		_refresh_lists()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
