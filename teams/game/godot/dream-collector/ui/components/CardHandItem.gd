# CardHandItem.gd
# 전투 화면에서 사용되는 핸드 카드 컴포넌트
# UI Pack PNG 리디자인: 타입별 4색 카드 프레임 + Grey 중립 섹션 — 91x127px

extends Control

signal card_clicked(card_index: int)
signal card_hovered(card_index: int)
signal card_unhovered()

var card_data: Dictionary = {}
var card_index: int = -1
var is_selected: bool = false
var is_affordable: bool = true
var _parry_disabled_by_auto: bool = false
var _x_overlay: Control = null

# ─── 대각선 X 오버레이 ─────────────────────────────
class CardXOverlay extends Control:
	func _draw():
		var w = size.x; var h = size.y
		var col = Color(1.0, 0.08, 0.08, 0.9)
		draw_line(Vector2(6, 6), Vector2(w - 6, h - 6), col, 8.0, true)
		draw_line(Vector2(w - 6, 6), Vector2(6, h - 6), col, 8.0, true)

# ─── UI 노드 참조 ────────────────────────────────────
@onready var card_bg: Panel        = $CardBG
@onready var cost_badge: Panel     = $CostBadge
@onready var cost_label: Label     = $CostBadge/CostLabel
@onready var name_banner: Panel    = $NameBanner
@onready var name_label: Label     = $NameBanner/NameLabel
@onready var art_frame: Panel      = $ArtFrame
@onready var art_bg: ColorRect     = $ArtFrame/ArtBG
@onready var art_placeholder: Label = $ArtFrame/ArtPlaceholder
@onready var type_banner: Panel    = $TypeBanner
@onready var type_label: Label     = $TypeBanner/TypeLabel
@onready var desc_panel: Panel     = $DescPanel
@onready var desc_label: Label     = $DescPanel/DescLabel
@onready var option_label: Label   = $OptionLabel
@onready var button: Button        = $Button

# ─── 타입 텍스트 색상 ──────────────────────────────
const TYPE_TEXT_COLORS = {
	"Attack": Color("#FF6B6B"),
	"Skill":  Color("#51CF66"),
	"Power":  Color("#74C0FC"),
	"Curse":  Color("#FFD93D"),
}

const SCALE_BASE     = 1.3
const SCALE_SELECTED = 1.4

func _ready():
	button.pressed.connect(_on_button_pressed)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	apply_styles()

# ─── StyleBoxTexture 헬퍼 ────────────────────────────
func _make_tex_sb(tex: Texture2D, margin: int = 6) -> StyleBoxTexture:
	if tex == null:
		return null
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_top    = margin
	sb.texture_margin_bottom = margin
	sb.texture_margin_left   = margin
	sb.texture_margin_right  = margin
	return sb

func _apply_tex_panel(panel: Panel, tex: Texture2D, margin: int = 6,
		modulate_col: Color = Color.WHITE) -> void:
	var sb := _make_tex_sb(tex, margin)
	if sb == null:
		return
	sb.modulate_color = modulate_col
	panel.add_theme_stylebox_override("panel", sb)

# ─── 카드 데이터 설정 ────────────────────────────────
func set_card(data: Dictionary, index: int):
	card_data  = data
	card_index = index
	_update_display()

func _update_display():
	if card_data.is_empty():
		return
	if not is_node_ready() or not name_label:
		return

	var ct: String = card_data.get("type", "Attack")
	name_label.text    = card_data.get("name", "???")
	cost_label.text    = str(int(card_data.get("cost", 0)))
	type_label.text    = get_type_korean(ct)
	desc_label.text    = card_data.get("short_desc", card_data.get("description", ""))
	art_placeholder.text = get_art_emoji(ct)

	apply_type_colors(ct)
	_update_option_label()
	_update_affordability()

func _update_option_label():
	var raw_tags = card_data.get("tags", [])
	if not (raw_tags is Array):
		option_label.text = ""; return
	var tags: Array = raw_tags
	if "DODGE" in tags:
		var rate = clampf(float(card_data.get("auto_dodge_success_rate", 0.5)), 0.0, 1.0)
		option_label.text = "Auto %d%%" % int(roundf(rate * 100.0))
	elif "PARRY" in tags:
		option_label.text = "Auto X"
	else:
		option_label.text = ""

func set_auto_parry_disabled(is_auto: bool):
	if card_data.is_empty():
		_update_affordability(); return
	var raw_tags = card_data.get("tags", [])
	var has_parry = (raw_tags is Array) and ("PARRY" in raw_tags)
	_parry_disabled_by_auto = is_auto and has_parry
	if _parry_disabled_by_auto:
		if _x_overlay == null:
			_x_overlay = CardXOverlay.new()
			_x_overlay.name = "ParryDisabledX"
			_x_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
			_x_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(_x_overlay)
		_x_overlay.visible = true
	else:
		if _x_overlay:
			_x_overlay.visible = false
	_update_affordability()

# ─── 타입별 텍스처 적용 ──────────────────────────────
func apply_type_colors(card_type: String):
	var t := card_type.to_lower()

	# ① 카드 배경: 타입 색상 button_rectangle_flat
	var frame_tex := UISprites.card_frame_tex(t)
	_apply_tex_panel(card_bg, frame_tex, UISprites.MARGIN_PANEL)

	# ② 아트 영역: 타입 색상 button_square_flat
	var sq_tex := UISprites.card_sq_tex(t)
	_apply_tex_panel(art_frame, sq_tex, UISprites.MARGIN_SLOT)
	art_bg.visible = false  # ArtBG ColorRect 숨김

	# ③ TypeBanner 라벨 색상: 검정 (가독성 우선)
	type_label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08))

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles():
	# 기존 SVG _CardSprite 제거
	var old_sprite: Node = get_node_or_null("_CardSprite")
	if old_sprite:
		old_sprite.queue_free()

	# ── 코스트 배지: Grey button_square_flat ──────────
	_apply_tex_panel(cost_badge, UISprites.slot_tex(""), UISprites.MARGIN_SLOT)
	cost_label.add_theme_font_size_override("font_size", 13)
	cost_label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08))

	# ── 이름 배너: Grey button_rectangle_flat ─────────
	_apply_tex_panel(name_banner, UISprites.panel_frame(), UISprites.MARGIN_PANEL)
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08))

	# ── 타입 배너: Grey button_rectangle_flat ─────────
	_apply_tex_panel(type_banner, UISprites.panel_frame(), UISprites.MARGIN_PANEL)
	type_label.add_theme_font_size_override("font_size", 9)

	# ── 설명 패널: Grey 어둡게 ─────────────────────────
	_apply_tex_panel(desc_panel, UISprites.panel_frame(), UISprites.MARGIN_PANEL,
			Color(0.50, 0.50, 0.55, 1.0))
	desc_label.add_theme_font_size_override("font_size", 9)
	desc_label.add_theme_color_override("font_color", Color(0.96, 0.96, 0.96))

	# ── 옵션 라벨 ─────────────────────────────────────
	option_label.add_theme_font_size_override("font_size", 8)
	option_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.3))

# ─── 한글 변환 ───────────────────────────────────────
func get_type_korean(type: String) -> String:
	match type.to_lower():
		"attack": return "공격"
		"skill":  return "스킬"
		"power":  return "파워"
		"curse":  return "커스"
	return "공격"

func get_art_emoji(type: String) -> String:
	match type.to_lower():
		"attack": return "⚔️"
		"skill":  return "🛡️"
		"power":  return "✨"
		"curse":  return "💀"
	return "⚔️"

# ─── Affordability / 선택 상태 ───────────────────────
func set_affordable(affordable: bool):
	is_affordable = affordable
	_update_affordability()

func _update_affordability():
	if _parry_disabled_by_auto:
		modulate = Color(0.5, 0.5, 0.5, 0.9)
		return
	modulate = Color(1, 1, 1, 1) if is_affordable else Color(0.5, 0.5, 0.5, 1)

func set_selected(selected: bool):
	is_selected = selected
	var s := SCALE_SELECTED / SCALE_BASE if selected else 1.0
	scale = Vector2(s, s)
	# 선택 시 밝기로 강조
	if selected:
		card_bg.modulate = Color(1.25, 1.25, 1.25, 1.0)
	else:
		card_bg.modulate = Color.WHITE

# ─── 마우스 이벤트 ───────────────────────────────────
func _on_button_pressed():
	if _parry_disabled_by_auto or not is_affordable:
		return
	card_clicked.emit(card_index)

func _on_mouse_entered():
	if _parry_disabled_by_auto or not is_affordable:
		return
	card_hovered.emit(card_index)
	card_bg.modulate = Color(1.15, 1.15, 1.15, 1.0)

func _on_mouse_exited():
	card_unhovered.emit()
	if not is_selected:
		card_bg.modulate = Color.WHITE
