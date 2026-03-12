# CardItem.gd
# 카드 라이브러리, 덱빌더에서 사용되는 카드 컴포넌트
# 신규 레이아웃: 코스트/이름/이미지/타입배너/설명/옵션 — 100x140px

extends Control

# ─── 카드 스프라이트 배경 ─────────────────────────────
var _card_sprite: TextureRect = null

# ─── 카드 데이터 ─────────────────────────────────────
var card_id: int = 0
var card_name: String = "Unknown Card"
var card_type: String = "attack"  # attack, skill, power, curse
var cost: int = 0
var description: String = ""
var short_desc: String = ""
var rarity: String = "common"  # common, uncommon, rare, epic, legendary

# ─── UI 노드 참조 ────────────────────────────────────
@onready var card_bg: Panel = $CardBG
@onready var cost_badge: Panel = $CostBadge
@onready var cost_label: Label = $CostBadge/CostLabel
@onready var name_banner: Panel = $NameBanner
@onready var name_label: Label = $NameBanner/NameLabel
@onready var art_frame: Panel = $ArtFrame
@onready var art_bg: ColorRect = $ArtFrame/ArtBG
@onready var art_placeholder: Label = $ArtFrame/ArtPlaceholder
@onready var type_banner: Panel = $TypeBanner
@onready var type_label: Label = $TypeBanner/TypeLabel
@onready var description_panel: Panel = $DescriptionPanel
@onready var description_label: Label = $DescriptionPanel/DescriptionLabel
@onready var option_label: Label = $OptionLabel

# ─── 타입별 색상 정의 ────────────────────────────────
const TYPE_COLORS = {
	"attack": {
		"bg": Color(0.6, 0.15, 0.15),
		"art_bg": Color(1.0, 0.5, 0.4),
		"banner": Color("#FF6B6B"),
		"name_bg": Color(0.5, 0.12, 0.12),
	},
	"skill": {
		"bg": Color(0.15, 0.45, 0.2),
		"art_bg": Color(0.4, 0.85, 0.5),
		"banner": Color("#51CF66"),
		"name_bg": Color(0.12, 0.35, 0.15),
	},
	"power": {
		"bg": Color(0.15, 0.3, 0.55),
		"art_bg": Color(0.4, 0.7, 1.0),
		"banner": Color("#4DABF7"),
		"name_bg": Color(0.12, 0.25, 0.45),
	},
	"curse": {
		"bg": Color(0.55, 0.5, 0.15),
		"art_bg": Color(1.0, 0.9, 0.4),
		"banner": Color("#FFD93D"),
		"name_bg": Color(0.45, 0.4, 0.12),
	}
}

# ─── 시그널 ──────────────────────────────────────────
signal card_clicked(card_data: Dictionary)
signal card_hovered(card_data: Dictionary)

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	custom_minimum_size = Vector2(100, 140)
	apply_styles()
	update_display()

	# 마우스 입력 감지 활성화
	mouse_filter = Control.MOUSE_FILTER_STOP

# ─── 카드 데이터 설정 ────────────────────────────────
func set_card_data(data: Dictionary) -> void:
	card_id = data.get("id", 0)
	card_name = data.get("name", "Unknown")
	card_type = data.get("type", "attack")
	cost = data.get("cost", 0)
	description = data.get("description", "")
	short_desc = data.get("short_desc", "")
	rarity = data.get("rarity", "common")

	if is_node_ready():
		update_display()

# ─── 디스플레이 업데이트 ─────────────────────────────
func update_display() -> void:
	if not is_node_ready():
		return

	# 카드 이름
	name_label.text = card_name

	# 코스트
	cost_label.text = str(cost)

	# 타입 (한글)
	type_label.text = get_type_korean(card_type)

	# 설명 (short_desc 우선, 없으면 description)
	description_label.text = short_desc if short_desc != "" else description

	# 일러스트 플레이스홀더
	art_placeholder.text = get_art_emoji(card_type)

	# 옵션 라벨 (라이브러리에서는 레어리티 표시)
	option_label.text = get_rarity_korean(rarity)

	# 타입별 색상 적용
	apply_type_colors()

# ─── 타입별 색상 적용 ────────────────────────────────
func apply_type_colors() -> void:
	var colors = TYPE_COLORS.get(card_type, TYPE_COLORS["attack"])

	# 카드 스프라이트 배경 교체
	if _card_sprite:
		_card_sprite.texture = UISprites.card_tex(card_type)

	# 카드 배경 Panel 반투명 (스프라이트가 보이도록)
	var card_style = card_bg.get_theme_stylebox("panel")
	if card_style is StyleBoxFlat:
		card_style.bg_color = Color(colors["bg"].r, colors["bg"].g, colors["bg"].b, 0.45)

	# 이름 배너 배경
	var banner_style = name_banner.get_theme_stylebox("panel")
	if banner_style is StyleBoxFlat:
		banner_style.bg_color = colors["name_bg"]

	# 일러스트 배경
	art_bg.color = colors["art_bg"]

	# 타입 배너
	var type_style = type_banner.get_theme_stylebox("panel")
	if type_style is StyleBoxFlat:
		type_style.bg_color = colors["banner"]

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	# 0. 카드 타입 스프라이트 배경 (card_bg 뒤에 배치)
	_card_sprite = TextureRect.new()
	_card_sprite.name = "_CardSprite"
	_card_sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
	_card_sprite.stretch_mode = TextureRect.STRETCH_SCALE
	_card_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_card_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_sprite.texture = UISprites.card_tex("attack")
	add_child(_card_sprite)
	move_child(_card_sprite, 0)

	# 1. 카드 배경 (반투명 오버레이)
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.6, 0.15, 0.15, 0.45)
	card_style.corner_radius_top_left = 8
	card_style.corner_radius_top_right = 8
	card_style.corner_radius_bottom_left = 8
	card_style.corner_radius_bottom_right = 8
	card_style.border_width_left = 2
	card_style.border_width_top = 2
	card_style.border_width_right = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color(0.1, 0.1, 0.1, 0.5)
	card_bg.add_theme_stylebox_override("panel", card_style)

	# 2. 코스트 배지 (스프라이트 또는 폴백)
	var cost_tex = UISprites.card_cost_badge()
	if cost_tex:
		var cost_rect = TextureRect.new()
		cost_rect.name = "CostBadgeTex"
		cost_rect.texture = cost_tex
		cost_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cost_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cost_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		cost_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cost_badge.add_child(cost_rect)
		cost_badge.move_child(cost_rect, 0)
		var transparent = StyleBoxFlat.new()
		transparent.bg_color = Color(0, 0, 0, 0)
		cost_badge.add_theme_stylebox_override("panel", transparent)
	else:
		var cost_style = StyleBoxFlat.new()
		cost_style.bg_color = Color(1, 0.8, 0.2)
		cost_style.corner_radius_top_left = 12
		cost_style.corner_radius_top_right = 12
		cost_style.corner_radius_bottom_left = 12
		cost_style.corner_radius_bottom_right = 12
		cost_style.border_width_left = 2
		cost_style.border_width_top = 2
		cost_style.border_width_right = 2
		cost_style.border_width_bottom = 2
		cost_style.border_color = Color(0.6, 0.4, 0.1)
		cost_badge.add_theme_stylebox_override("panel", cost_style)
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))

	# 3. 이름 배너 (어두운 타입색)
	var banner_style = StyleBoxFlat.new()
	banner_style.bg_color = Color(0.5, 0.12, 0.12)
	banner_style.corner_radius_top_left = 4
	banner_style.corner_radius_top_right = 4
	banner_style.corner_radius_bottom_left = 4
	banner_style.corner_radius_bottom_right = 4
	name_banner.add_theme_stylebox_override("panel", banner_style)
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1))

	# 4. 이미지 프레임 (직사각형, corner_radius=4)
	var art_style = StyleBoxFlat.new()
	art_style.bg_color = Color(0.2, 0.2, 0.3, 0.3)
	art_style.corner_radius_top_left = 4
	art_style.corner_radius_top_right = 4
	art_style.corner_radius_bottom_left = 4
	art_style.corner_radius_bottom_right = 4
	art_frame.add_theme_stylebox_override("panel", art_style)
	art_placeholder.add_theme_font_size_override("font_size", 30)

	# 5. 타입 배너 (풀 너비, 타입별 색상)
	var type_style = StyleBoxFlat.new()
	type_style.bg_color = Color("#FF6B6B")
	type_style.corner_radius_top_left = 2
	type_style.corner_radius_top_right = 2
	type_style.corner_radius_bottom_left = 2
	type_style.corner_radius_bottom_right = 2
	type_banner.add_theme_stylebox_override("panel", type_style)
	type_label.add_theme_font_size_override("font_size", 9)
	type_label.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))

	# 6. 설명 패널 (어두운 배경)
	var desc_style = StyleBoxFlat.new()
	desc_style.bg_color = Color(0.1, 0.1, 0.15, 0.85)
	desc_style.corner_radius_top_left = 3
	desc_style.corner_radius_top_right = 3
	desc_style.corner_radius_bottom_left = 3
	desc_style.corner_radius_bottom_right = 3
	description_panel.add_theme_stylebox_override("panel", desc_style)
	description_label.add_theme_font_size_override("font_size", 8)
	description_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))

	# 7. 옵션 라벨 (하단 1줄)
	option_label.add_theme_font_size_override("font_size", 8)
	option_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))

# ─── 타입 한글 변환 ──────────────────────────────────
func get_type_korean(type: String) -> String:
	var korean_types = {
		"attack": "공격",
		"skill": "스킬",
		"power": "파워",
		"curse": "커스"
	}
	return korean_types.get(type, "공격")

# ─── 일러스트 이모지 ─────────────────────────────────
func get_art_emoji(type: String) -> String:
	var emojis = {
		"attack": "⚔️",
		"skill": "🛡️",
		"power": "✨",
		"curse": "💀"
	}
	return emojis.get(type, "⚔️")

# ─── 레어리티 한글 ────────────────────────────────────
func get_rarity_korean(r: String) -> String:
	var names = {
		"COMMON": "일반",
		"RARE": "레어",
		"SPECIAL": "스페셜",
		"LEGENDARY": "전설",
		"common": "일반",
		"rare": "레어",
		"special": "스페셜",
		"legendary": "전설"
	}
	return names.get(r, "")

# ─── 마우스 입력 처리 ────────────────────────────────
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_card_clicked()

func _mouse_entered() -> void:
	# 호버 효과
	var card_style = card_bg.get_theme_stylebox("panel")
	if card_style is StyleBoxFlat:
		card_style.border_width_left = 4
		card_style.border_width_top = 4
		card_style.border_width_right = 4
		card_style.border_width_bottom = 4
		card_style.border_color = Color(1, 1, 1, 0.8)

	card_hovered.emit(get_card_data())

func _mouse_exited() -> void:
	# 호버 해제
	var card_style = card_bg.get_theme_stylebox("panel")
	if card_style is StyleBoxFlat:
		card_style.border_width_left = 2
		card_style.border_width_top = 2
		card_style.border_width_right = 2
		card_style.border_width_bottom = 2
		card_style.border_color = Color(0.1, 0.1, 0.1, 0.5)

# ─── 카드 클릭 이벤트 ────────────────────────────────
func _on_card_clicked() -> void:
	card_clicked.emit(get_card_data())
	print("[CardItem] 카드 클릭: %s (ID: %s)" % [card_name, str(card_id)])

# ─── 카드 데이터 반환 ────────────────────────────────
func get_card_data() -> Dictionary:
	return {
		"id": card_id,
		"name": card_name,
		"type": card_type,
		"cost": cost,
		"description": description,
		"short_desc": short_desc,
		"rarity": rarity
	}
