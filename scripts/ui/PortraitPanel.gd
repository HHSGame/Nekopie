class_name PortraitPanel
extends PanelContainer

@onready var portrait: TextureRect = $Portrait
@onready var frame: TextureRect = $PortraitFrame
@onready var hit_fx: TextureRect = $FxCenter/HitFx
@onready var hit_flash: ColorRect = $HitFlash
@onready var status_label: Label = $StatusOverlay/StatusLabel
@onready var buff_label: Label = $StatusOverlay/BuffLabel

func set_portrait_texture(texture: Texture2D) -> void:
	portrait.texture = texture

func set_frame_texture(texture: Texture2D) -> void:
	frame.texture = texture

func set_hit_fx_texture(texture: Texture2D) -> void:
	hit_fx.texture = texture

func set_status_text(text: String) -> void:
	status_label.text = text

func set_buff_text(text: String, visible: bool = true) -> void:
	buff_label.visible = visible
	buff_label.text = text

func play_hit_flash(color: Color) -> void:
	hit_flash.visible = true
	hit_flash.color = color
	var tween := create_tween()
	tween.tween_property(hit_flash, "color:a", 0.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): hit_flash.visible = false)

func play_hit_fx() -> void:
	if not hit_fx.texture:
		return
	hit_fx.visible = true
	hit_fx.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(hit_fx, "modulate:a", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): hit_fx.visible = false)

func pulse(scale_factor: float) -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(scale_factor, scale_factor), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
