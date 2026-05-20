extends PanelContainer
class_name CardWidget

signal clicked(card_id: String)
signal hovered(card_id: String)
signal unhovered()

const DEFAULT_ART := preload("res://art/cards/card_art_placeholder.svg")
const GEM_BASE := preload("res://art/ui/card_gem.svg")

@export var card_id := ""

@onready var name_label: Label = $ContentMargin/VBox/Header/NameLabel
@onready var cost_label: Label = $ContentMargin/VBox/Header/CostLabel
@onready var gem_icon: TextureRect = $ContentMargin/VBox/Header/GemIcon
@onready var type_icon: TextureRect = $ContentMargin/VBox/Header/TypeIcon
@onready var desc_label: Label = $ContentMargin/VBox/DescriptionLabel
@onready var art_texture: TextureRect = $ContentMargin/VBox/ArtTexture
@onready var hover_glow: TextureRect = $HoverGlow

var pending_card_data: Dictionary = {}
var hover_tween: Tween

const RARITY_COLORS := {
	"common": Color(0.8, 0.75, 0.7),
	"uncommon": Color(0.6, 0.85, 0.95),
	"rare": Color(0.95, 0.78, 0.4),
	"epic": Color(0.85, 0.45, 0.85)
}

const KIND_COLORS := {
	"attack": Color(0.95, 0.55, 0.40),
	"guard": Color(0.45, 0.70, 1.0),
	"defend": Color(0.45, 0.70, 1.0),
	"skill": Color(0.55, 0.85, 0.70),
	"status": Color(0.75, 0.55, 0.90),
	"equipment": Color(0.85, 0.75, 0.45),
	"power": Color(0.95, 0.85, 0.40),
	"curse": Color(0.55, 0.50, 0.55)
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
	var name_text: String = str(card_data.get("name", "未知卡牌"))
	var upgrade_lvl: int = int(card_data.get("upgrade_level", 0))
	if upgrade_lvl > 0:
		name_text += " +%d" % upgrade_lvl
	name_label.text = name_text
	
	var cost := int(card_data.get("cost", 0))
	cost_label.text = str(cost)
	
	# Rarity gem tint
	var rarity: String = str(card_data.get("rarity", "common"))
	var gem_color: Color = RARITY_COLORS.get(rarity, RARITY_COLORS["common"])
	gem_icon.modulate = gem_color
	
	# Kind icon
	var kind: String = str(card_data.get("kind", ""))
	var icon_path: String = str(card_data.get("icon", ""))
	if not icon_path.is_empty():
		var icon_texture: Texture2D = load(icon_path)
		type_icon.texture = icon_texture
		type_icon.visible = icon_texture != null
	else:
		type_icon.visible = false
	
	# Description
	desc_label.text = card_data.get("desc", "")
	
	# Card art
	var art_path: String = str(card_data.get("art", ""))
	if art_path.is_empty():
		art_texture.texture = DEFAULT_ART
	else:
		var loaded: Texture2D = load(art_path)
		art_texture.texture = loaded if loaded else DEFAULT_ART
	
	# Kind-based cost color
	var kind_color: Color = KIND_COLORS.get(kind, Color(1, 1, 1))
	cost_label.add_theme_color_override("font_color", kind_color)
	
	# Rarity-based frame border hint via self-modulate
	match rarity:
		"common":
			self_modulate = Color(1, 1, 1, 1)
		"uncommon":
			self_modulate = Color(0.85, 0.95, 1.0, 1)
		"rare":
			self_modulate = Color(1.0, 0.95, 0.8, 1)
		"epic":
			self_modulate = Color(1.0, 0.85, 0.95, 1)

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
		# Lift effect
		hover_tween = create_tween()
		hover_tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		hover_tween.parallel().tween_property(hover_glow, "modulate:a", 0.85, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		hover_tween.parallel().tween_property(self, "position", Vector2(0, -8), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		hover_tween = create_tween()
		hover_tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		hover_tween.parallel().tween_property(hover_glow, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		hover_tween.parallel().tween_property(self, "position", Vector2.ZERO, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		hover_tween.tween_callback(func(): hover_glow.visible = false)
