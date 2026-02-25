# CardItem.gd
# 카드 라이브러리, 덱빌더에서 사용되는 카드 컴포넌트
# Dream Collector - Iron Glory Style (100×140px)

extends Control

# ─── 카드 데이터 ─────────────────────────────────────
var card_id: int = 0
var card_name: String = "Unknown Card"
var card_type: String = "attack"  # attack, defense, skill, power
var cost: int = 0
var description: String = ""
var rarity: String = "common"  # common, uncommon, rare, epic, legendary

# ─── UI 노드 참조 ────────────────────────────────────
@onready var card_bg: Panel = $CardBG
@onready var cost_badge: Panel = $CostBadge
@onready var cost_label: Label = $CostBadge/CostLabel
@onready var name_banner: Panel = $NameBanner
@onready var name_label: Label = $NameBanner/NameLabel
@onready var art_circle: Panel = $ArtCircle
@onready var art_bg: ColorRect = $ArtCircle/ArtBG
@onready var art_placeholder: Label = $ArtCircle/ArtPlaceholder
@onready var type_badge: Panel = $TypeBadge
@onready var type_label: Label = $TypeBadge/TypeLabel
@onready var description_panel: Panel = $DescriptionPanel
@onready var description_label: Label = $DescriptionPanel/DescriptionLabel

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
	
	# 타입
	type_label.text = get_type_korean(card_type)
	
	# 설명
	description_label.text = description
	
	# 일러스트 플레이스홀더 (이모지 또는 첫 글자)
	art_placeholder.text = get_art_emoji(card_type)
	
	# 타입별 색상 적용
	apply_type_colors()

# ─── 타입별 색상 적용 ────────────────────────────────
func apply_type_colors() -> void:
	var type_colors = {
		"attack": {
			"bg": Color(0.8, 0.2, 0.2),  # 빨강
			"art_bg": Color(1.0, 0.4, 0.2),  # 주황
			"banner": Color(0.4, 0.7, 1.0)  # 하늘색
		},
		"defense": {
			"bg": Color(0.2, 0.4, 0.8),  # 파랑
			"art_bg": Color(0.3, 0.6, 1.0),  # 밝은 파랑
			"banner": Color(0.4, 0.7, 1.0)  # 하늘색
		},
		"skill": {
			"bg": Color(0.2, 0.6, 0.3),  # 초록
			"art_bg": Color(0.4, 0.8, 0.4),  # 밝은 초록
			"banner": Color(0.4, 0.7, 1.0)  # 하늘색
		},
		"power": {
			"bg": Color(0.6, 0.2, 0.8),  # 보라
			"art_bg": Color(0.8, 0.4, 1.0),  # 밝은 보라
			"banner": Color(0.4, 0.7, 1.0)  # 하늘색
		}
	}
	
	var colors = type_colors.get(card_type, type_colors["attack"])
	
	# 카드 배경
	var card_style = card_bg.get_theme_stylebox("panel")
	if card_style is StyleBoxFlat:
		card_style.bg_color = colors["bg"]
	
	# 일러스트 배경
	art_bg.color = colors["art_bg"]
	
	# 이름 배너
	var banner_style = name_banner.get_theme_stylebox("panel")
	if banner_style is StyleBoxFlat:
		banner_style.bg_color = colors["banner"]

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	# 1. 카드 배경 (전체)
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.8, 0.2, 0.2)  # 기본 빨강
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
	
	# 2. 코스트 배지 (좌상단)
	var cost_style = StyleBoxFlat.new()
	cost_style.bg_color = Color(1, 0.8, 0.2)  # 노란색
	cost_style.corner_radius_top_left = 16
	cost_style.corner_radius_top_right = 16
	cost_style.corner_radius_bottom_left = 16
	cost_style.corner_radius_bottom_right = 16
	cost_style.border_width_left = 2
	cost_style.border_width_top = 2
	cost_style.border_width_right = 2
	cost_style.border_width_bottom = 2
	cost_style.border_color = Color(0.6, 0.4, 0.1)
	cost_badge.add_theme_stylebox_override("panel", cost_style)
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	
	# 3. 이름 배너 (상단)
	var banner_style = StyleBoxFlat.new()
	banner_style.bg_color = Color(0.4, 0.7, 1.0)  # 하늘색
	banner_style.corner_radius_top_left = 4
	banner_style.corner_radius_top_right = 4
	banner_style.corner_radius_bottom_left = 4
	banner_style.corner_radius_bottom_right = 4
	name_banner.add_theme_stylebox_override("panel", banner_style)
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	
	# 4. 원형 일러스트 영역
	var circle_style = StyleBoxFlat.new()
	circle_style.bg_color = Color(0.3, 0.6, 0.9, 0.3)  # 반투명
	circle_style.corner_radius_top_left = 30
	circle_style.corner_radius_top_right = 30
	circle_style.corner_radius_bottom_left = 30
	circle_style.corner_radius_bottom_right = 30
	circle_style.border_width_left = 2
	circle_style.border_width_top = 2
	circle_style.border_width_right = 2
	circle_style.border_width_bottom = 2
	circle_style.border_color = Color(0.4, 0.7, 1.0)
	art_circle.add_theme_stylebox_override("panel", circle_style)
	art_placeholder.add_theme_font_size_override("font_size", 28)
	
	# 5. 타입 배지
	var type_style = StyleBoxFlat.new()
	type_style.bg_color = Color(0.4, 0.7, 1.0)  # 하늘색
	type_style.corner_radius_top_left = 4
	type_style.corner_radius_top_right = 4
	type_style.corner_radius_bottom_left = 4
	type_style.corner_radius_bottom_right = 4
	type_badge.add_theme_stylebox_override("panel", type_style)
	type_label.add_theme_font_size_override("font_size", 7)
	type_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	
	# 6. 설명 패널
	var desc_style = StyleBoxFlat.new()
	desc_style.bg_color = Color(0.15, 0.15, 0.2)  # 어두운 배경
	desc_style.corner_radius_bottom_left = 6
	desc_style.corner_radius_bottom_right = 6
	description_panel.add_theme_stylebox_override("panel", desc_style)
	description_label.add_theme_font_size_override("font_size", 7)
	description_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))

# ─── 타입 한글 변환 ──────────────────────────────────
func get_type_korean(type: String) -> String:
	var korean_types = {
		"attack": "공격",
		"defense": "방어",
		"skill": "스킬",
		"power": "파워"
	}
	return korean_types.get(type, "공격")

# ─── 일러스트 이모지 ─────────────────────────────────
func get_art_emoji(type: String) -> String:
	var emojis = {
		"attack": "⚔️",
		"defense": "🛡️",
		"skill": "✨",
		"power": "💪"
	}
	return emojis.get(type, "⚔️")

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
	print("[CardItem] 카드 클릭: %s (ID: %d)" % [card_name, card_id])

# ─── 카드 데이터 반환 ────────────────────────────────
func get_card_data() -> Dictionary:
	return {
		"id": card_id,
		"name": card_name,
		"type": card_type,
		"cost": cost,
		"description": description,
		"rarity": rarity
	}
