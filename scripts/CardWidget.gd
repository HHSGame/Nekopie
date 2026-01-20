extends PanelContainer
class_name CardWidget

signal clicked(card_id: String)

@export var card_id := ""

@onready var name_label: Label = $MarginContainer/VBoxContainer/Header/NameLabel
@onready var cost_label: Label = $MarginContainer/VBoxContainer/Header/CostLabel
@onready var desc_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel

var pending_card_data: Dictionary = {}

func _ready() -> void:
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

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked", card_id)
