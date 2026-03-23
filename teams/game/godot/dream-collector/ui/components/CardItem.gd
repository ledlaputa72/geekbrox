# CardItem.gd
# 카드 라이브러리, 덱빌더에서 사용되는 카드 컴포넌트
# UI Pack PNG 리디자인: 타입별 4색 카드 프레임 + Grey 중립 섹션 — 100x140px

extends Control

# ─── 카드 데이터 ─────────────────────────────────────
var card_id: int = 0
var card_name: String = "Unknown Card"
var card_type: String = "attack"  # attack, skill, power, curse
var cost: int = 0
var description: String = ""
var short_desc: String = ""
var rarity: String = "common"  # common, rare, special, legendary

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
@onready var description_panel: Panel = $DescriptionPanel
@onready var description_label: Label = $DescriptionPanel/DescriptionLabel
@onready var option_label: Label   = $OptionLabel

# ─── 타입별 텍스트 색상 (TypeBanner 라벨용) ─────────
const TYPE_TEXT_COLORS = {
	"attack": Color("#FF6B6B"),
	"skill":  Color("#51CF66"),
	"power":  Color("#74C0FC"),
	"curse":  Color("#FFD93D"),
}

# ─── 희귀도별 텍스트 색상 ──────────────────────────
const RARITY_TEXT_COLORS = {
	"COMMON":    Color(0.72, 0.72, 0.72),
	"RARE":      Color(0.40, 0.72, 1.00),
	"SPECIAL":   Color(0.86, 0.35, 0.35),
	"EPIC":      Color(0.86, 0.35, 0.35),
	"LEGENDARY": Color(1.00, 0.80, 0.10),
	"common":    Color(0.72, 0.72, 0.72),
	"rare":      Color(0.40, 0.72, 1.00),
	"special":   Color(0.86, 0.35, 0.35),
	"legendary": Color(1.00, 0.80, 0.10),
}

# ─── 시그널 ──────────────────────────────────────────
signal card_clicked(card_data: Dictionary)
signal card_hovered(card_data: Dictionary)

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	custom_minimum_size = Vector2(100, 140)
	apply_styles()
	update_display()
	# 카드 전체가 클릭되도록: 자신은 STOP, 모든 자식은 IGNORE (이벤트 통과)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_set_children_mouse_ignore(self)

func _set_children_mouse_ignore(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_children_mouse_ignore(child)

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
func set_card_data(data: Dictionary) -> void:
	card_id    = data.get("id", 0)
	card_name  = data.get("name", "Unknown")
	card_type  = data.get("type", "attack")
	cost       = data.get("cost", 0)
	description = data.get("description", "")
	short_desc = data.get("short_desc", "")
	rarity     = data.get("rarity", "common")

	if is_node_ready():
		update_display()

# ─── 디스플레이 업데이트 ─────────────────────────────
func update_display() -> void:
	if not is_node_ready():
		return
	name_label.text        = card_name
	cost_label.text        = str(cost)
	# 카드 타입 + 희귀도를 같은 줄에 표시: "스킬  [일반]"
	var rarity_ko := get_rarity_korean(rarity)
	type_label.text = get_type_korean(card_type) + "  [" + rarity_ko + "]"
	description_label.text = short_desc if short_desc != "" else description
	art_placeholder.text   = get_art_emoji(card_type)
	# option_label 숨김 (타입 라벨로 통합)
	option_label.visible = false

	apply_type_colors()

# ─── 타입별 텍스처 적용 ──────────────────────────────
func apply_type_colors() -> void:
	var t := card_type.to_lower()

	# ① 카드 전체 배경: 타입 색상 button_rectangle_flat
	var frame_tex := UISprites.card_frame_tex(t)
	_apply_tex_panel(card_bg, frame_tex, UISprites.MARGIN_PANEL)

	# ② 아트 영역: 타입 색상 button_square_flat
	var sq_tex := UISprites.card_sq_tex(t)
	_apply_tex_panel(art_frame, sq_tex, UISprites.MARGIN_SLOT)
	art_bg.visible = false  # ArtBG ColorRect 숨김 (art_frame Panel이 배경 역할)

	# ③ TypeBanner 라벨 색상: 검정 (배경이 밝은 Grey이므로 가독성 우선)
	type_label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08))

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	# 기존 SVG _CardSprite 제거 (UI Pack PNG로 대체)
	var old_sprite: Node = get_node_or_null("_CardSprite")
	if old_sprite:
		old_sprite.queue_free()

	# ── 코스트 배지: Grey button_round_depth_flat (원형, margin=0 → 원 전체 채움) ──
	var cost_round: Texture2D = UISprites.cost_badge_tex()
	_apply_tex_panel(cost_badge, cost_round, 0)
	cost_label.add_theme_font_size_override("font_size", 13)
	cost_label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08))

	# ── 이름 배너: Grey button_rectangle_flat ─────────
	var name_tex := UISprites.panel_frame()  # Grey
	_apply_tex_panel(name_banner, name_tex, UISprites.MARGIN_PANEL)
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08))

	# ── 타입 배너: Grey button_rectangle_flat ──────────
	# 텍스트 색상은 apply_type_colors()에서 타입별로 설정
	var type_tex := UISprites.panel_frame()
	_apply_tex_panel(type_banner, type_tex, UISprites.MARGIN_PANEL)
	type_label.add_theme_font_size_override("font_size", 9)

	# ── 설명 패널: Grey button_rectangle_flat (어둡게 modulate) ──
	var desc_tex := UISprites.panel_frame()
	_apply_tex_panel(description_panel, desc_tex, UISprites.MARGIN_PANEL,
			Color(0.50, 0.50, 0.55, 1.0))  # 짙은 회색
	description_label.add_theme_font_size_override("font_size", 8)
	description_label.add_theme_color_override("font_color", Color(0.96, 0.96, 0.96))

	# ── 희귀도 라벨 ────────────────────────────────────
	option_label.add_theme_font_size_override("font_size", 8)
	option_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.72))

	# 타입별 색상 적용 (card_bg, art_frame, type_label 색상)
	apply_type_colors()

# ─── 타입 한글 변환 ──────────────────────────────────
func get_type_korean(type: String) -> String:
	match type.to_lower():
		"attack": return "공격"
		"skill":  return "스킬"
		"power":  return "파워"
		"curse":  return "커스"
	return "공격"

# ─── 일러스트 이모지 ─────────────────────────────────
func get_art_emoji(type: String) -> String:
	match type.to_lower():
		"attack": return "⚔️"
		"skill":  return "🛡️"
		"power":  return "✨"
		"curse":  return "💀"
	return "⚔️"

# ─── 레어리티 한글 ────────────────────────────────────
func get_rarity_korean(r: String) -> String:
	match r.to_upper():
		"COMMON":    return "일반"
		"RARE":      return "레어"
		"SPECIAL":   return "스페셜"
		"EPIC":      return "에픽"
		"LEGENDARY": return "전설"
	return ""

# ─── 마우스 입력 처리 ────────────────────────────────
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_card_clicked()

func _mouse_entered() -> void:
	# 호버: 카드 전체 밝기 +15%
	modulate = Color(1.15, 1.15, 1.15, 1.0)
	card_hovered.emit(get_card_data())

func _mouse_exited() -> void:
	modulate = Color.WHITE

# ─── 카드 클릭 이벤트 ────────────────────────────────
func _on_card_clicked() -> void:
	card_clicked.emit(get_card_data())
	print("[CardItem] 카드 클릭: %s (ID: %s)" % [card_name, str(card_id)])

# ─── 카드 데이터 반환 ────────────────────────────────
func get_card_data() -> Dictionary:
	return {
		"id":          card_id,
		"name":        card_name,
		"type":        card_type,
		"cost":        cost,
		"description": description,
		"short_desc":  short_desc,
		"rarity":      rarity
	}
