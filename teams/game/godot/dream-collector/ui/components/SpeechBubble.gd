# SpeechBubble.gd
# 말풍선 컴포넌트 (캐릭터 대화)
# 하단 삼각형 꼬리 포함

extends Control

# ─── 설정 ───────────────────────────────────────────
const BUBBLE_PADDING = 12
const TAIL_SIZE = 12
const FADE_DURATION = 0.3

# ─── UI 노드 ─────────────────────────────────────────
@onready var bubble_panel: Panel = $BubblePanel
@onready var text_label: Label = $BubblePanel/MarginContainer/TextLabel

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()
	visible = false

func apply_styles() -> void:
	# Bubble panel (rounded white box)
	var bubble_style = StyleBoxFlat.new()
	bubble_style.bg_color = Color(1.0, 1.0, 1.0, 0.95)  # 흰색
	bubble_style.corner_radius_top_left = 12
	bubble_style.corner_radius_top_right = 12
	bubble_style.corner_radius_bottom_left = 12
	bubble_style.corner_radius_bottom_right = 12
	bubble_style.border_width_left = 2
	bubble_style.border_width_top = 2
	bubble_style.border_width_right = 2
	bubble_style.border_width_bottom = 2
	bubble_style.border_color = Color(0.2, 0.2, 0.2)  # 검은 테두리
	bubble_style.content_margin_left = BUBBLE_PADDING
	bubble_style.content_margin_right = BUBBLE_PADDING
	bubble_style.content_margin_top = BUBBLE_PADDING
	bubble_style.content_margin_bottom = BUBBLE_PADDING
	bubble_panel.add_theme_stylebox_override("panel", bubble_style)
	
	# Text label
	text_label.add_theme_font_size_override("font_size", 16)
	text_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD

# ─── 말풍선 표시 ─────────────────────────────────────
func show_message(message: String, duration: float = 3.0) -> void:
	text_label.text = message
	
	# Fade in
	modulate.a = 0.0
	visible = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)
	
	# Auto hide after duration
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		hide_message()

func hide_message() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	
	await tween.finished
	visible = false

# ─── 즉시 표시/숨김 ──────────────────────────────────
func show_instant(message: String) -> void:
	text_label.text = message
	modulate.a = 1.0
	visible = true

func hide_instant() -> void:
	visible = false
