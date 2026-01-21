extends PanelContainer
class_name CardWidget

signal clicked(card_id: String)
signal hovered(card_id: String)
signal unhovered()

const DEFAULT_ART := preload("res://art/cards/card_art_placeholder.svg")

@export var card_id := ""

@onready var name_label: Label = $MarginContainer/VBoxContainer/Header/NameLabel
@onready var cost_label: Label = $MarginContainer/VBoxContainer/Header/CostLabel
@onready var desc_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var art_texture: TextureRect = $MarginContainer/VBoxContainer/ArtTexture

var pending_card_data: Dictionary = {}

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	if not pending_card_data.is_empty():
		_apply_card_data(pending_card_data)

func set_card(card_data: Dictionary) -> void:
	pending_card_data = card_data
	if is_node_ready():
		_apply_card_data(card_data)

func _apply_card_data(card_data: Dictionary) -> void:
	card_id = card_data.get("id", "")
	name_label.text = card_data.get("name", "未知卡牌")
	cost_label.text = "费用 %s" % str(card_data.get("cost", 0))
	desc_label.text = card_data.get("desc", "")
	var art_path: String = str(card_data.get("art", ""))
	if art_path.is_empty():
		art_texture.texture = DEFAULT_ART
	else:
		var loaded: Texture2D = load(art_path)
		art_texture.texture = loaded if loaded else DEFAULT_ART

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked", card_id)

func _on_mouse_entered() -> void:
	emit_signal("hovered", card_id)

func _on_mouse_exited() -> void:
	emit_signal("unhovered")
