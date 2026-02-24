# CardItem.gd
# 카드 라이브러리에서 사용되는 단일 카드 컴포넌트
# Dream Collector - 100×140px 카드 디자인

extends PanelContainer

# ─── 카드 데이터 ─────────────────────────────────────
var card_id: int = 0
var card_name: String = "Unknown Card"
var card_type: String = "attack"  # attack, defense, skill, power
var cost: int = 0
var description: String = ""
var rarity: String = "common"  # common, uncommon, rare, epic, legendary

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var name_label: Label = $VBox/TopSection/HBox/NameLabel
@onready var cost_label: Label = $VBox/TopSection/HBox/CostLabel
@onready var type_label: Label = $VBox/TopSection/TypeLabel
@onready var art_placeholder: ColorRect = $VBox/ArtContainer/ArtPlaceholder
@onready var description_label: Label = $VBox/BottomSection/DescriptionLabel

# ─── 시그널 ──────────────────────────────────────────
signal card_clicked(card_data: Dictionary)
signal card_hovered(card_data: Dictionary)

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	custom_minimum_size = Vector2(UITheme.CARD.width, UITheme.CARD.height)
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
	
	name_label.text = card_name
	cost_label.text = str(cost)
	type_label.text = card_type.capitalize()
	description_label.text = description
	
	# 타입별 색상 적용
	var type_color = UITheme.COLORS.get(card_type, UITheme.COLORS.attack)
	background.color = type_color
	
	# 희귀도별 테두리 색상
	var rarity_color = UITheme.COLORS.get(rarity, UITheme.COLORS.common)
	var panel_style = get_theme_stylebox("panel")
	if panel_style is StyleBoxFlat:
		panel_style.border_color = rarity_color

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	# Panel 스타일
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = UITheme.COLORS.panel
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = UITheme.COLORS.panel_border
	panel_style.corner_radius_top_left = UITheme.RADIUS.small
	panel_style.corner_radius_top_right = UITheme.RADIUS.small
	panel_style.corner_radius_bottom_left = UITheme.RADIUS.small
	panel_style.corner_radius_bottom_right = UITheme.RADIUS.small
	add_theme_stylebox_override("panel", panel_style)
	
	# 라벨 색상
	name_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	cost_label.add_theme_color_override("font_color", UITheme.COLORS.warning)
	type_label.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	description_label.add_theme_color_override("font_color", UITheme.COLORS.text_dim)

# ─── 마우스 입력 처리 ────────────────────────────────
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_card_clicked()

func _mouse_entered() -> void:
	# 호버 효과
	var panel_style = get_theme_stylebox("panel")
	if panel_style is StyleBoxFlat:
		panel_style.border_width_left = 3
		panel_style.border_width_top = 3
		panel_style.border_width_right = 3
		panel_style.border_width_bottom = 3
	
	card_hovered.emit(get_card_data())

func _mouse_exited() -> void:
	# 호버 해제
	var panel_style = get_theme_stylebox("panel")
	if panel_style is StyleBoxFlat:
		panel_style.border_width_left = 2
		panel_style.border_width_top = 2
		panel_style.border_width_right = 2
		panel_style.border_width_bottom = 2

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
