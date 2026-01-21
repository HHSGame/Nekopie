extends PanelContainer
class_name CardWidget

signal clicked(card_id: String)
signal hovered(card_id: String)
signal unhovered()

const DEFAULT_ART := preload("res://art/cards/card_art_placeholder.svg")

@export var card_id := ""

@onready var name_label: Label = $MarginContainer/VBoxContainer/Header/NameLabel
@onready var cost_label: Label = $MarginContainer/VBoxContainer/Header/CostLabel
@onready var gem_icon: TextureRect = $MarginContainer/VBoxContainer/Header/GemIcon
@onready var type_icon: TextureRect = $MarginContainer/VBoxContainer/Header/TypeIcon
@onready var desc_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var art_texture: TextureRect = $MarginContainer/VBoxContainer/ArtTexture
@onready var hover_glow: TextureRect = $HoverGlow

var pending_card_data: Dictionary = {}
var hover_tween: Tween

const RARITY_COLORS := {
	"common": Color(0.8, 0.75, 0.7),
	"uncommon": Color(0.6, 0.85, 0.95),
	"rare": Color(0.95, 0.78, 0.4)
}

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
	var icon_path: String = str(card_data.get("icon", ""))
	if icon_path.is_empty():
		type_icon.visible = false
	else:
		var icon_texture: Texture2D = load(icon_path)
		type_icon.texture = icon_texture
		type_icon.visible = icon_texture != null
	var rarity: String = str(card_data.get("rarity", "common"))
	gem_icon.modulate = RARITY_COLORS.get(rarity, RARITY_COLORS["common"])

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("clicked", card_id)

func _on_mouse_entered() -> void:
	emit_signal("hovered", card_id)
	_set_hovered(true)

func _on_mouse_exited() -> void:
	emit_signal("unhovered")
	_set_hovered(false)

func _set_hovered(active: bool) -> void:
	if hover_tween:
		hover_tween.kill()
	if active:
		hover_glow.visible = true
		hover_glow.modulate.a = 0.0
		hover_tween = create_tween()
		hover_tween.tween_property(hover_glow, "modulate:a", 0.85, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		hover_tween = create_tween()
		hover_tween.tween_property(hover_glow, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		hover_tween.tween_callback(func(): hover_glow.visible = false)
