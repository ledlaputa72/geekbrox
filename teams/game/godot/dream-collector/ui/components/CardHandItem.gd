# CardHandItem.gd
# 전투 화면에서 사용되는 핸드 카드 컴포넌트
# Iron Glory Style - 70×98px (CardItem의 축소 버전)

extends Control

signal card_clicked(card_index: int)
signal card_hovered(card_index: int)
signal card_unhovered()

var card_data: Dictionary = {}
var card_index: int = -1
var is_selected: bool = false
var is_affordable: bool = true
var _parry_disabled_by_auto: bool = false  # 오토 시 패링 카드 비활성
var _x_overlay: Label = null
var _auto_rate_label: Label = null  # 회피 카드 오토 성공률 표시

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
@onready var desc_label: Label = $DescLabel
@onready var button: Button = $Button

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
	
	var card_type = card_data.get("type", "Attack")
	
	# 카드 이름
	name_label.text = card_data.get("name", "???")
	
	# 코스트 (정수만)
	cost_label.text = str(int(card_data.get("cost", 0)))
	
	# 타입 (한글)
	type_label.text = get_type_korean(card_type)
	
	# 설명 (선택 시에만 표시)
	desc_label.text = card_data.get("description", "")
	
	# 일러스트 플레이스홀더
	art_placeholder.text = get_art_emoji(card_type)
	
	# 타입별 색상 적용
	apply_type_colors(card_type)
	
	# 회피 카드: 오토 성공률 표시 (하단 정보 영역)
	_update_auto_rate_label()
	# Affordability 업데이트
	_update_affordability()

func _update_auto_rate_label():
	var tags: Array = card_data.get("tags", [])
	if "DODGE" in tags:
		var rate = card_data.get("auto_dodge_success_rate", 0.5)
		if _auto_rate_label == null:
			_auto_rate_label = Label.new()
			_auto_rate_label.name = "AutoRateLabel"
			_auto_rate_label.add_theme_font_size_override("font_size", 8)
			_auto_rate_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.3))
			_auto_rate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			add_child(_auto_rate_label)
		_auto_rate_label.text = "오토 성공률 %d%%" % int(round(rate * 100.0))
		_auto_rate_label.visible = true
		_auto_rate_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_auto_rate_label.offset_top = -22
		_auto_rate_label.offset_bottom = -6
		_auto_rate_label.offset_left = 4
		_auto_rate_label.offset_right = -4
	else:
		if _auto_rate_label:
			_auto_rate_label.visible = false

func set_auto_parry_disabled(is_auto: bool):
	"""오토 시 패링 카드 X 표시 + 비활성 (메뉴얼 시 정상)"""
	var tags: Array = card_data.get("tags", [])
	var has_parry = "PARRY" in tags
	_parry_disabled_by_auto = is_auto and has_parry
	if _parry_disabled_by_auto:
		if _x_overlay == null:
			_x_overlay = Label.new()
			_x_overlay.name = "ParryDisabledX"
			_x_overlay.text = "✕"
			_x_overlay.add_theme_font_size_override("font_size", 36)
			_x_overlay.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
			_x_overlay.add_theme_constant_override("outline_size", 2)
			_x_overlay.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
			_x_overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_x_overlay.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			_x_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
			_x_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(_x_overlay)
		_x_overlay.visible = true
	else:
		if _x_overlay:
			_x_overlay.visible = false
	_update_affordability()

func apply_type_colors(card_type: String):
	var type_colors = {
		"Attack": {
			"bg": Color(0.8, 0.2, 0.2),
			"art_bg": Color(1.0, 0.4, 0.2),
			"banner": Color(0.4, 0.7, 1.0)
		},
		"Defense": {
			"bg": Color(0.2, 0.4, 0.8),
			"art_bg": Color(0.3, 0.6, 1.0),
			"banner": Color(0.4, 0.7, 1.0)
		},
		"Skill": {
			"bg": Color(0.2, 0.6, 0.3),
			"art_bg": Color(0.4, 0.8, 0.4),
			"banner": Color(0.4, 0.7, 1.0)
		},
		"Power": {
			"bg": Color(0.6, 0.2, 0.8),
			"art_bg": Color(0.8, 0.4, 1.0),
			"banner": Color(0.4, 0.7, 1.0)
		}
	}
	
	var colors = type_colors.get(card_type, type_colors["Attack"])
	
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

func apply_styles():
	# 1. 카드 배경
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.8, 0.2, 0.2)
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
	
	# 2. 코스트 배지
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
	cost_label.add_theme_font_size_override("font_size", 18)
	cost_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	
	# 3. 이름 배너
	var banner_style = StyleBoxFlat.new()
	banner_style.bg_color = Color(0.4, 0.7, 1.0)
	banner_style.corner_radius_top_left = 3
	banner_style.corner_radius_top_right = 3
	banner_style.corner_radius_bottom_left = 3
	banner_style.corner_radius_bottom_right = 3
	name_banner.add_theme_stylebox_override("panel", banner_style)
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	
	# 4. 원형 일러스트
	var circle_style = StyleBoxFlat.new()
	circle_style.bg_color = Color(0.3, 0.6, 0.9, 0.3)
	circle_style.corner_radius_top_left = 20
	circle_style.corner_radius_top_right = 20
	circle_style.corner_radius_bottom_left = 20
	circle_style.corner_radius_bottom_right = 20
	circle_style.border_width_left = 2
	circle_style.border_width_top = 2
	circle_style.border_width_right = 2
	circle_style.border_width_bottom = 2
	circle_style.border_color = Color(0.4, 0.7, 1.0)
	art_circle.add_theme_stylebox_override("panel", circle_style)
	art_placeholder.add_theme_font_size_override("font_size", 30)
	
	# 5. 타입 배지
	var type_style = StyleBoxFlat.new()
	type_style.bg_color = Color(0.4, 0.7, 1.0)
	type_style.corner_radius_top_left = 3
	type_style.corner_radius_top_right = 3
	type_style.corner_radius_bottom_left = 3
	type_style.corner_radius_bottom_right = 3
	type_badge.add_theme_stylebox_override("panel", type_style)
	type_label.add_theme_font_size_override("font_size", 9)
	type_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	
	# 6. 설명 레이블
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))

func get_type_korean(type: String) -> String:
	var korean_types = {
		"Attack": "공격",
		"Defense": "방어",
		"Skill": "스킬",
		"Power": "파워"
	}
	return korean_types.get(type, "공격")

func get_art_emoji(type: String) -> String:
	var emojis = {
		"Attack": "⚔️",
		"Defense": "🛡️",
		"Skill": "✨",
		"Power": "💪"
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
		# 선택 시 설명 표시
		desc_label.visible = true
		# 테두리 강조
		var card_style = card_bg.get_theme_stylebox("panel")
		if card_style is StyleBoxFlat:
			card_style.border_width_left = 3
			card_style.border_width_top = 3
			card_style.border_width_right = 3
			card_style.border_width_bottom = 3
			card_style.border_color = Color(1, 1, 1, 0.9)
	else:
		desc_label.visible = false
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
