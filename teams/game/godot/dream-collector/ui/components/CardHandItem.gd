# CardHandItem.gd
# 전투 화면에서 사용되는 핸드 카드 컴포넌트
# 신규 레이아웃: 코스트/이름/이미지/타입배너/설명/옵션 — 91x127px

extends Control

signal card_clicked(card_index: int)
signal card_hovered(card_index: int)
signal card_unhovered()

var card_data: Dictionary = {}
var card_index: int = -1
var is_selected: bool = false
var is_affordable: bool = true
var _parry_disabled_by_auto: bool = false  # 오토 시 패링 카드 비활성
var _x_overlay: Control = null

# ─── 대각선 X 오버레이 클래스 ──────────────────────────
class CardXOverlay extends Control:
	func _draw():
		var w = size.x
		var h = size.y
		var col = Color(1.0, 0.08, 0.08, 0.9)
		draw_line(Vector2(6, 6), Vector2(w - 6, h - 6), col, 8.0, true)
		draw_line(Vector2(w - 6, 6), Vector2(6, h - 6), col, 8.0, true)

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
@onready var desc_panel: Panel = $DescPanel
@onready var desc_label: Label = $DescPanel/DescLabel
@onready var option_label: Label = $OptionLabel
@onready var button: Button = $Button

# ─── 타입별 색상 정의 ──────────────────────────────────
const TYPE_COLORS = {
	"Attack": {
		"bg": Color(0.6, 0.15, 0.15),       # 어두운 빨강
		"art_bg": Color(1.0, 0.5, 0.4),
		"banner": Color("#FF6B6B"),          # 빨강
		"name_bg": Color(0.5, 0.12, 0.12),
	},
	"Skill": {
		"bg": Color(0.15, 0.45, 0.2),       # 어두운 초록
		"art_bg": Color(0.4, 0.85, 0.5),
		"banner": Color("#51CF66"),          # 초록
		"name_bg": Color(0.12, 0.35, 0.15),
	},
	"Power": {
		"bg": Color(0.15, 0.3, 0.55),       # 어두운 파랑
		"art_bg": Color(0.4, 0.7, 1.0),
		"banner": Color("#4DABF7"),          # 파랑
		"name_bg": Color(0.12, 0.25, 0.45),
	},
	"Curse": {
		"bg": Color(0.55, 0.5, 0.15),       # 어두운 노랑
		"art_bg": Color(1.0, 0.9, 0.4),
		"banner": Color("#FFD93D"),          # 노랑
		"name_bg": Color(0.45, 0.4, 0.12),
	}
}

func _ready():
	button.pressed.connect(_on_button_pressed)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	apply_styles()

func set_card(data: Dictionary, index: int):
	card_data = data
	card_index = index
	_update_display()

func _update_display():
	if card_data.is_empty():
		return
	if not is_node_ready() or not name_label:
		return

	var card_type = card_data.get("type", "Attack")

	# 카드 이름
	name_label.text = card_data.get("name", "???")

	# 코스트 (정수만)
	cost_label.text = str(int(card_data.get("cost", 0)))

	# 타입 (한글)
	type_label.text = get_type_korean(card_type)

	# 설명 (short_desc — 항상 표시)
	desc_label.text = card_data.get("short_desc", card_data.get("description", ""))

	# 일러스트 플레이스홀더
	art_placeholder.text = get_art_emoji(card_type)

	# 타입별 색상 적용
	apply_type_colors(card_type)

	# 하단 옵션 텍스트 (회피 카드: 오토 성공률)
	_update_option_label()
	# Affordability 업데이트
	_update_affordability()

func _update_option_label():
	var raw_tags = card_data.get("tags", [])
	if not (raw_tags is Array):
		option_label.text = ""
		return
	var tags: Array = raw_tags
	if "DODGE" in tags:
		var rate = card_data.get("auto_dodge_success_rate", 0.5)
		rate = clampf(float(rate), 0.0, 1.0)
		option_label.text = "Auto %d%%" % int(roundf(rate * 100.0))
	elif "PARRY" in tags:
		option_label.text = "Auto X"
	else:
		option_label.text = ""

func set_auto_parry_disabled(is_auto: bool):
	"""오토 시 패링 카드 X 표시 + 비활성 (메뉴얼 시 정상)"""
	if card_data.is_empty():
		_update_affordability()
		return
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

func apply_type_colors(card_type: String):
	var colors = TYPE_COLORS.get(card_type, TYPE_COLORS["Attack"])

	# 카드 배경
	var card_style = card_bg.get_theme_stylebox("panel")
	if card_style is StyleBoxFlat:
		card_style.bg_color = colors["bg"]

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

func apply_styles():
	# 1. 카드 배경 (어두운 계열)
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.6, 0.15, 0.15)
	card_style.corner_radius_top_left = 6
	card_style.corner_radius_top_right = 6
	card_style.corner_radius_bottom_left = 6
	card_style.corner_radius_bottom_right = 6
	card_style.border_width_left = 2
	card_style.border_width_top = 2
	card_style.border_width_right = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color(0.1, 0.1, 0.1, 0.5)
	card_bg.add_theme_stylebox_override("panel", card_style)

	# 2. 코스트 배지 (노란색 원형)
	var cost_style = StyleBoxFlat.new()
	cost_style.bg_color = Color(1, 0.8, 0.2)
	cost_style.corner_radius_top_left = 11
	cost_style.corner_radius_top_right = 11
	cost_style.corner_radius_bottom_left = 11
	cost_style.corner_radius_bottom_right = 11
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
	banner_style.corner_radius_top_left = 3
	banner_style.corner_radius_top_right = 3
	banner_style.corner_radius_bottom_left = 3
	banner_style.corner_radius_bottom_right = 3
	name_banner.add_theme_stylebox_override("panel", banner_style)
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1))

	# 4. 이미지 프레임 (직사각형, corner_radius=4)
	var art_style = StyleBoxFlat.new()
	art_style.bg_color = Color(0.2, 0.2, 0.3, 0.3)
	art_style.corner_radius_top_left = 4
	art_style.corner_radius_top_right = 4
	art_style.corner_radius_bottom_left = 4
	art_style.corner_radius_bottom_right = 4
	art_frame.add_theme_stylebox_override("panel", art_style)
	art_placeholder.add_theme_font_size_override("font_size", 28)

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
	desc_panel.add_theme_stylebox_override("panel", desc_style)
	desc_label.add_theme_font_size_override("font_size", 9)
	desc_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))

	# 7. 옵션 라벨 (하단 1줄)
	option_label.add_theme_font_size_override("font_size", 8)
	option_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.3))

func get_type_korean(type: String) -> String:
	var korean_types = {
		"Attack": "공격",
		"Skill": "스킬",
		"Power": "파워",
		"Curse": "커스"
	}
	return korean_types.get(type, "공격")

func get_art_emoji(type: String) -> String:
	var emojis = {
		"Attack": "⚔️",
		"Skill": "🛡️",
		"Power": "✨",
		"Curse": "💀"
	}
	return emojis.get(type, "⚔️")

func set_affordable(affordable: bool):
	is_affordable = affordable
	_update_affordability()

func _update_affordability():
	if _parry_disabled_by_auto:
		modulate = Color(0.5, 0.5, 0.5, 0.9)  # 오토 시 패링 카드 비활성
		return
	if not is_affordable:
		modulate = Color(0.5, 0.5, 0.5, 1)  # Gray out
	else:
		modulate = Color(1, 1, 1, 1)

const SCALE_BASE = 1.3
const SCALE_SELECTED = 1.4

func set_selected(selected: bool):
	is_selected = selected
	var s = SCALE_SELECTED / SCALE_BASE if selected else 1.0
	scale = Vector2(s, s)
	if selected:
		# 선택 시 테두리 강조
		var card_style = card_bg.get_theme_stylebox("panel")
		if card_style is StyleBoxFlat:
			card_style.border_width_left = 3
			card_style.border_width_top = 3
			card_style.border_width_right = 3
			card_style.border_width_bottom = 3
			card_style.border_color = Color(1, 1, 1, 0.9)
	else:
		# 테두리 원복
		var card_style = card_bg.get_theme_stylebox("panel")
		if card_style is StyleBoxFlat:
			card_style.border_width_left = 2
			card_style.border_width_top = 2
			card_style.border_width_right = 2
			card_style.border_width_bottom = 2
			card_style.border_color = Color(0.1, 0.1, 0.1, 0.5)

func _on_button_pressed():
	if _parry_disabled_by_auto or not is_affordable:
		return
	card_clicked.emit(card_index)

func _on_mouse_entered():
	if _parry_disabled_by_auto or not is_affordable:
		return
	card_hovered.emit(card_index)
	# Hover 효과 (테두리)
	var card_style = card_bg.get_theme_stylebox("panel")
	if card_style is StyleBoxFlat and not is_selected:
		card_style.border_color = Color(1, 1, 1, 0.6)

func _on_mouse_exited():
	card_unhovered.emit()
	# Hover 해제
	var card_style = card_bg.get_theme_stylebox("panel")
	if card_style is StyleBoxFlat and not is_selected:
		card_style.border_color = Color(0.1, 0.1, 0.1, 0.5)
